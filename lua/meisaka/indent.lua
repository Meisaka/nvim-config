local ts = vim.treesitter
local parsers = require "nvim-treesitter.parsers"

local M = {}
M.not_want_aligned = true

---@type table<integer, string>
local indent_funcs = {}

local keys_setup = false

local indent_keys_setting = "0{,},),],:,0#,!^L,o,O,e,=#else,=#if,=if,=#endif,=#define"
---@param bufnr integer
function M.attach(bufnr)
	indent_funcs[bufnr] = vim.bo.indentexpr
	vim.bo.indentexpr = "meisaka#indent()"
	vim.schedule(function()
		vim.api.nvim_buf_set_option(bufnr, 'indentkeys', indent_keys_setting)
	end)
end
function M.detach(bufnr)
  vim.bo.indentexpr = indent_funcs[bufnr]
end
function M.is_supported(lang)
	return lang == 'cpp'
end

local function getline(lnum)
	return vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
end

---@param lnum integer
local function first_non_blank(lnum)
	local _,ws = string.find(getline(lnum), "^%s*")
	return ws or 0
end

---@param root TSNode
---@param lnum integer
---@param col? integer
---@return TSNode
local function get_first_node_at_line(root, lnum, col)
	col = col or first_non_blank(lnum)
	return root:descendant_for_range(lnum - 1, col, lnum - 1, col + 1)
end

---@param root TSNode
---@param lnum integer
---@param col? integer
---@return TSNode
local function get_last_node_at_line(root, lnum, col)
	col = col or (#getline(lnum) - 1)
	return root:descendant_for_range(lnum - 1, col, lnum - 1, col + 1)
end

---@param node TSNode
---@return number
local function node_length(node)
	local _, _, start_byte = node:start()
	local _, _, end_byte = node:end_()
	return end_byte - start_byte
end

---@param bufnr integer
---@param node TSNode
---@param delimiter string
---@return TSNode|nil child
---@return boolean|nil is_end
local function find_delimiter(bufnr, node, delimiter)
	for child, _ in node:iter_children() do
		if child:type() == delimiter then
			local linenr = child:start()
			local line = vim.api.nvim_buf_get_lines(bufnr, linenr, linenr + 1, false)[1]
			local end_char = { child:end_() }
			local trimmed_after_delim
			local escaped_delimiter = delimiter:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1")
			trimmed_after_delim, _ = line:sub(end_char[2] + 1):gsub("[%s" .. escaped_delimiter .. "]*", "")
			return child, #trimmed_after_delim == 0
		end
	end
end

---Memoize a function using hash_fn to hash the arguments.
---@generic F: function
---@param fn F
---@param hash_fn fun(...): any
---@return F
local function memoize(fn, hash_fn)
	local cache = setmetatable({}, { __mode = "kv" }) ---@type table<any,any>

	return function(...)
		local key = hash_fn(...)
		if cache[key] == nil then
			local v = fn(...) ---@type any
			cache[key] = v ~= nil and v or vim.NIL
		end

		local v = cache[key]
		return v ~= vim.NIL and v or nil
	end
end

local get_indents_f = function(bufnr, root, lang)
	local map = {
		["indent.auto"] = {},
		["indent.begin"] = {},
		["indent.end"] = {},
		["indent.dedent"] = {},
		["indent.branch"] = {},
		["indent.ignore"] = {},
		["indent.align"] = {},
		["indent.zero"] = {},
	}

	local query = (ts.query.get or ts.get_query)(lang, "indents")
	if not query then return map end
	for id, node, metadata in query:iter_captures(root, bufnr) do
		if query.captures[id]:sub(1, 1) ~= "_" then
			map[query.captures[id]][node:id()] = metadata or {}
		end
	end

	return map
end
local get_indents = memoize(get_indents_f , function(bufnr, root, lang)
	return tostring(bufnr) .. root:id() .. "_" .. lang
end)

local function node_info(node)
	local s_line, s_col, s_byte = node:start()
	local e_line, e_col, e_byte = node:end_()
	return ('['..tostring(s_line)
	..','..tostring(s_col)
	..'-'..tostring(e_line)
	..','..tostring(e_col)
	..']'..node:type()..';\n')
end

function M.indent(lnum)
	local w = require'meisaka.win'
	local bufnr = vim.api.nvim_get_current_buf()
	local parser = parsers.get_parser(bufnr)
	if not parser or not lnum then
		--w.sched_lines('=-1(no parser/line)')
		return -1
	end

	if not keys_setup then
		keys_setup = true
		vim.schedule(function()
			vim.api.nvim_buf_set_option(bufnr, 'indentkeys', indent_keys_setting)
		end)
	end
	--local where = { 0, vim.fn.line "$" }
	--local where = { vim.fn.line "w0" - 1, vim.fn.line "$" }
	local where = { vim.fn.line "w0" - 1, vim.fn.line "w$" }
    parser:parse(where)
	local lrow = lnum - 1
	local root, lang_tree ---@type TSNode, LanguageTree
	parser:for_each_tree(function(tstree, tree)
		if not tstree then return end
		local local_root = tstree:root()
		if ts.is_in_node_range(local_root, lrow, 0) then
			if not root or node_length(root) >= node_length(local_root) then
				root = local_root
				lang_tree = tree
			end
		end
	end)
	if not root then
		--w.sched_lines('=0(no root)')
		return 0
	end
	--local tdb = vim.inspect(where)..',root:'..node_info(root)
	local q = get_indents(vim.api.nvim_get_current_buf(), root, lang_tree:lang())
	local current_line = getline(lnum)
	local is_empty_line = string.match(current_line, "^%s*$") ~= nil
	local node ---@type TSNode
	node = get_first_node_at_line(root, lnum, first_non_blank(lnum) )
	--tdb = tdb..'"'..current_line..'" '..node_info(node)
	local indent_size = vim.fn.shiftwidth()
	local indent = 0
	-- tracks to ensure multiple indent levels are not applied for same line
	local is_processed_by_row = {}

	if is_empty_line then
		--tdb = tdb..'<empty>'
		local prevlnum = vim.fn.prevnonblank(lnum)
		local prevline = getline(prevlnum)
		local prevws = first_non_blank(prevlnum)
		local prevtrimmed = vim.trim(prevline)
		-- The final position can be trailing spaces, which should not affect indentation
		local prevnode ---@type TSNode
		prevnode = get_last_node_at_line(root, prevlnum, prevws + #prevtrimmed - 1)
		if prevnode:type():match "comment" then
			-- The final node we capture of the previous line can be a comment node, which should also be ignored
			-- Unless the last line is an entire line of comment, ignore the comment range and find the last node again
			local first_node = get_first_node_at_line(root, prevlnum, prevws)
			local _, scol, _, _ = prevnode:range()
			if first_node:id() ~= prevnode:id() then
				-- In case the last captured node is a trailing comment node, re-trim the string
				prevtrimmed = vim.trim(prevtrimmed:sub(1, scol - prevws))
				-- Add back prevws as prevws of prevtrimmed was trimmed away
				local col = prevws + #prevtrimmed - 1
				prevnode = get_last_node_at_line(root, prevlnum, col)
			end
		end
		--tdb = tdb..',previ='..tostring(prevws)
		local walkprev = prevnode
		local end_node = nil
		local end_count = 0
		local e_srow = nil
		local lastrow, _, _ = node:range()
		while walkprev and walkprev:id() ~= node:id() do
			--tdb = tdb..'\n:'..node_info(walkprev)
			local srow, _, erow = node:range()
			local i_begin = q['indent.begin'][walkprev:id()];
			local i_end = q['indent.end'][walkprev:id()]
			if i_begin then
				if end_node then
					end_node = nil
					end_count = end_count - 1
					--tdb = tdb..'>can'
				else
					--tdb = tdb..'>beg'
					node = walkprev
					if walkprev:type() == 'case_statement' then
						i_begin['indent.immediate'] = true;
					end
					break
				end
			elseif end_node and lastrow == srow then
				end_node = nil
				end_count = end_count - 1
				--tdb = tdb..'>send'
			end
			if i_end then
				--tdb = tdb..'>end:'..vim.inspect(i_end)
				end_node = walkprev
				end_count = end_count + 1
				e_srow = srow
			end
			walkprev = walkprev:parent()
		end
		if end_node then
			--tdb = tdb..'>end'
			node = end_node
		end
	end

	local _, _, root_start = root:start()
	if root_start ~= 0 then
		-- injected tree
		indent = indent + vim.fn.indent(root:start() + 1)
	end

	if q["indent.zero"][node:id()] or node:type() == 'preproc_directive' then
		--w.sched_lines(tdb..'=0(zero)')
		return 0
	end

	local is_case = false
	local is_block = false

	while node do
		local i_begin = q['indent.begin'][node:id()]
		local i_align = q['indent.align'][node:id()]
		local i_auto = q['indent.auto'][node:id()]
		local i_ignore = q['indent.ignore'][node:id()]
		local i_branch = q['indent.branch'][node:id()]
		local i_dedent = q['indent.dedent'][node:id()]
		local srow, _, erow = node:range()
		local is_processed = false

		-- do 'autoindent' if not marked as @indent
		if
			not i_begin
			and not i_align
			and i_auto
			and srow < lrow
			and lrow <= erow
		then
			--w.sched_lines(tdb..'autoind')
			return -1
		end

		-- Do not indent if we are inside an @ignore block.
		-- If a node spans from L1,C1 to L2,C2, we know that lines where L1 < line <= L2 would
		-- have their indentations contained by the node.
		if
			not i_begin
			and i_ignore
			and srow < lrow
			and lrow <= erow
		then
			--w.sched_lines(tdb..'ignore')
			return 0
		end

		--local proc_act = ''
		if
			not is_processed_by_row[srow]
			and (
				(i_branch and srow == lrow)
				or (i_dedent and srow ~= lrow)
			)
		then
			indent = indent - indent_size
			is_processed = true
			--proc_act = '<de'
		end

		-- do not indent for nodes that starts-and-ends on same line and starts on target line (lnum)
		local should_process = not is_processed_by_row[srow]
		local is_in_err = false
		if should_process then
			local parent = node:parent()
			is_in_err = parent and parent:has_error()
			--tdb=tdb..'>in_err'
		end
		local node_type = node:type()

		if node_type == 'case_statement' then
			is_case = true
		elseif node_type == 'switch_statement' and is_block and is_case then
			is_block = false
			is_case = false
		elseif is_block then --defer blocks of {} when inside a case
			indent = indent + indent_size
			proc_act = proc_act..'>blk'
			is_block = false
		end
		if
			should_process
			and i_begin
			and (srow ~= erow or is_in_err or i_begin["indent.immediate"])
			and (srow ~= lrow or i_begin["indent.start_at_same_line"])
		then
			if node_type == 'compound_statement' and is_case then
				is_block = true
			else
				indent = indent + indent_size
				--proc_act = proc_act..'>beg'
			end
			is_processed = true
		end

		if is_in_err and not i_align then
			-- only when the node is in error, promote the
			-- first child's aligned indent to the error node
			-- to work around ((ERROR "X" . (_)) @aligned_indent (#set! "delimiter" "AB"))
			-- matching for all X, instead set do
			-- (ERROR "X" @aligned_indent (#set! "delimiter" "AB") . (_))
			-- and we will fish it out here.
			for c in node:iter_children() do
				i_align = q["indent.align"][c:id()]
				if i_align then
					q["indent.align"][node:id()] = i_align
					break
				end
			end
		end
		-- do not indent for nodes that starts-and-ends on same line and starts on target line (lnum)
		if should_process and i_align and (srow ~= erow or is_in_err) and (srow ~= lrow) then
			local o_delim_node, o_is_last_in_line ---@type TSNode|nil, boolean|nil
			local c_delim_node, c_is_last_in_line ---@type TSNode|nil, boolean|nil, boolean|nil
			local indent_is_absolute = false
			if i_align["indent.open_delimiter"] then
				o_delim_node, o_is_last_in_line = find_delimiter(bufnr, node, i_align["indent.open_delimiter"])
			else
				o_delim_node = node
			end
			if i_align["indent.close_delimiter"] then
				c_delim_node, c_is_last_in_line = find_delimiter(bufnr, node, i_align["indent.close_delimiter"])
			else
				c_delim_node = node
			end

			if o_delim_node then
				local o_srow, o_scol = o_delim_node:start()
				local c_srow = nil
				if c_delim_node then
					c_srow, _ = c_delim_node:start()
				end
				if o_is_last_in_line then
					-- hanging indent (previous line ended with starting delimiter)
					-- should be processed like indent
					if should_process then
						indent = indent + indent_size * 1
						--proc_act = proc_act..'>hang'
						if c_is_last_in_line then
							-- If current line is outside the range of a node marked with `@aligned_indent`
							-- Then its indent level shouldn't be affected by `@aligned_indent` node
							if c_srow and c_srow < lrow then
								indent = math.max(indent - indent_size, 0)
								--proc_act = proc_act..'<last'
							end
						end
					end
				else
					-- aligned indent
					if c_is_last_in_line and c_srow and o_srow ~= c_srow and c_srow < lrow then
						-- If current line is outside the range of a node marked with `@aligned_indent`
						-- Then its indent level shouldn't be affected by `@aligned_indent` node
						indent = math.max(indent - indent_size, 0)
						--proc_act = proc_act..'<alout'
					elseif M.not_want_aligned then
						indent = indent + indent_size
					else
						local o_line = getline(o_srow+1)
						local tabw = vim.bo.tabstop
						local o_vcol = 0
						local o_vchr = o_scol
						for xt, xc in string.gmatch(o_line, '(\t*)([^\t]*)') do
							o_vcol = o_vcol + #xt * tabw
							o_vchr = o_vchr - #xt
							if o_vchr - #xc < 0 then
								o_vcol = o_vcol + o_vchr
								break
							else
								o_vcol = o_vcol + #xc
								o_vchr = o_vchr - #xc
							end
						end
						indent = o_vcol + (i_align["indent.increment"] or 1)
						indent_is_absolute = true
						--proc_act = proc_act..'=alcol['..tostring(o_scol)..','..tostring(o_vcol)..','..tostring(o_vchr)..']['..o_line..']'
					end
				end
				-- deal with the final line
				local avoid_last_matching_next = false
				if c_srow and c_srow ~= o_srow and c_srow == lrow then
					-- delims end on current line, and are not open and closed same line.
					-- then this last line may need additional indent to avoid clashes
					-- with the next. `indent.avoid_last_matching_next` controls this behavior,
					-- for example this is needed for function parameters.
					avoid_last_matching_next = i_align["indent.avoid_last_matching_next"] or false
				end
				if avoid_last_matching_next then
					-- last line must be indented more in cases where
					-- it would be same indent as next line (we determine this as one
					-- width more than the open indent to avoid confusing with any
					-- hanging indents)
					if indent <= vim.fn.indent(o_srow + 1) + indent_size then
						indent = indent + indent_size * 1
						--proc_act = proc_act..'>avnxt'
					end
				end
				is_processed = true
				if indent_is_absolute then
					-- don't allow further indenting by parent nodes, this is an absolute position
					--[[
					-- debugging stuff owo
					local row_status = 'non'
					if is_processed_by_row[srow] then
						if is_processed then
							row_status = 'ree'
						else
							row_status = 'was'
						end
					elseif is_processed then
						row_status = 'new'
					end
					tdb = tdb..'\nabs:('..tostring(srow)..','..tostring(erow)..','..tostring(indent)
					..','..row_status
					..')'..vim.inspect(i_begin)
					..','..vim.inspect(i_align)
					..','..vim.inspect(i_auto)
					..','..vim.inspect(i_ignore)
					..','..vim.inspect(i_branch)
					..','..vim.inspect(i_dedent)
					..','..proc_act
					..','..node_info(node)
					local t = tostring(indent)..':'..tdb
					w.sched_lines(t)
					--]]
					return indent
				end
			end
		end

		--[[
		local row_status = 'non'
		if is_processed_by_row[srow] then
			if is_processed then
				row_status = 'ree'
			else
				row_status = 'was'
			end
		elseif is_processed then
			row_status = 'new'
		end
		tdb = tdb..'('..tostring(srow)..','..tostring(erow)..','..tostring(indent)
		..','..row_status
		..')'..vim.inspect(i_begin)
		..','..vim.inspect(i_align)
		..','..vim.inspect(i_auto)
		..','..vim.inspect(i_ignore)
		..','..vim.inspect(i_branch)
		..','..vim.inspect(i_dedent)
		..','..proc_act
		..','..node_info(node)
		--]]

		is_processed_by_row[srow] = is_processed_by_row[srow] or is_processed
		node = node:parent()
	end

	--local t = tostring(indent)..':'..tdb
	--w.sched_lines(t)
	return indent
end

return M
