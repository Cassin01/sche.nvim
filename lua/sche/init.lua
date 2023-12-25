local function bmap(bufnr, mode, key, cmd, desc)
  if (type(cmd) == "string") then
    return vim.api.nvim_buf_set_keymap(bufnr, mode, key, cmd, {noremap = true, silent = true, desc = desc})
  else
    return vim.api.nvim_buf_set_keymap(bufnr, mode, key, "", {callback = cmd, noremap = true, silent = true, desc = desc})
  end
end
local function _cons(x, ...)
  return {x, ...}
end
local function _pull(x, xs)
  return _cons(x, unpack(xs))
end
local function _unfold_iter(seed, _3fobject, _3ffinish)
  local v = seed()
  if (nil == v) then
    if ((_3ffinish ~= nil) and (_3fobject ~= nil)) then
      _3ffinish(_3fobject)
    else
    end
    return {}
  else
    return _pull(v, _unfold_iter(seed, _3fobject, _3ffinish))
  end
end
local function read_lines(path)
  local f = io.open(path, "r")
  if (f ~= nil) then
    local function _4_(f0)
      _G.assert((nil ~= f0), "Missing argument f on fnl/sche/init.fnl:30")
      return f0.close(f0)
    end
    return _unfold_iter(f.lines(f), f, _4_)
  else
    return nil
  end
end
local function concat_with(d, ...)
  return table.concat({...}, d)
end
local default_cnf
local function _6_(annex)
  _G.assert((nil ~= annex), "Missing argument annex on fnl/sche/init.fnl:51")
  return ("There is a chedule: " .. annex)
end
local function _7_(annex)
  _G.assert((nil ~= annex), "Missing argument annex on fnl/sche/init.fnl:52")
  return ("There is a memo: " .. annex)
end
local function _8_(annex)
  _G.assert((nil ~= annex), "Missing argument annex on fnl/sche/init.fnl:53")
  return ("There is a todo: " .. annex)
end
local function _9_(annex)
  _G.assert((nil ~= annex), "Missing argument annex on fnl/sche/init.fnl:54")
  return ("There is a remainder: " .. annex)
end
local function _10_(annex)
  _G.assert((nil ~= annex), "Missing argument annex on fnl/sche/init.fnl:55")
  return ("There is a deadline: " .. annex)
end
local function _11_(annex)
  _G.assert((nil ~= annex), "Missing argument annex on fnl/sche/init.fnl:56")
  return ("You have completed: " .. annex)
end
default_cnf = {default_keymap = true, notify_todays_schedule = true, notify_tomorrows_schedule = true, hl = {GCalendarMikan = {fg = "#F4511E"}, GCalendarPeacock = {fg = "#039BE5"}, GCalendarGraphite = {fg = "#616161"}, GCalendarSage = {fg = "#33B679"}, GCalendarBanana = {fg = "#f6bf26"}, GCalendarLavender = {fg = "#7986cb"}, GCalendarTomato = {fg = "#d50000"}, GCalendarFlamingo = {fg = "#e67c73"}}, notify = {["@"] = _6_, ["#"] = _7_, ["+"] = _8_, ["-"] = _9_, ["!"] = _10_, ["."] = _11_}, sche_path = "none", syntax = {on = true, date = {vim_regex = "\\d\\d\\d\\d/\\d\\d/\\d\\d", lua_regex = "%d%d%d%d/%d%d/%d%d", vimstrftime = "%Y/%m/%d"}, month = "'\\<\\(January\\|Febraury\\|March\\|April\\|May\\|June\\|July\\|August\\|September\\|October\\|November\\|December\\)'", weekday = "'\\<\\(Fri\\|Mon\\|Tue\\|Wed\\|Thu\\)'", sunday = "'\\<Sun\\>'", saturday = "'\\<Sat\\>'"}}
local M = {}
local function _get_cnf()
  local cnf = vim.g["_sche#cnf"]
  if (cnf == nil) then
    return M.setup()
  else
    return cnf
  end
end
local create_autocmd = vim.api.nvim_create_autocmd
local create_augroup = vim.api.nvim_create_augroup
local function append(lst, x)
  lst[(#lst + 1)] = x
  return lst
end
local function pack(line, list)
  local elm
  if string.match(line, ("^%s+" .. "@" .. ".*$")) then
    local kind_2_auto = string.match(line, ("^%s+(" .. "@" .. ").*$"))
    local desc_3_auto = string.match(line, ("^%s+" .. "@" .. "%s+(.*)%s*$"))
    elm = {[kind_2_auto] = desc_3_auto}
  else
    if string.match(line, ("^%s+" .. "#" .. ".*$")) then
      local kind_2_auto = string.match(line, ("^%s+(" .. "#" .. ").*$"))
      local desc_3_auto = string.match(line, ("^%s+" .. "#" .. "%s+(.*)%s*$"))
      elm = {[kind_2_auto] = desc_3_auto}
    else
      if string.match(line, ("^%s+" .. "%+" .. ".*$")) then
        local kind_2_auto = string.match(line, ("^%s+(" .. "%+" .. ").*$"))
        local desc_3_auto = string.match(line, ("^%s+" .. "%+" .. "%s+(.*)%s*$"))
        elm = {[kind_2_auto] = desc_3_auto}
      else
        if string.match(line, ("^%s+" .. "%-" .. ".*$")) then
          local kind_2_auto = string.match(line, ("^%s+(" .. "%-" .. ").*$"))
          local desc_3_auto = string.match(line, ("^%s+" .. "%-" .. "%s+(.*)%s*$"))
          elm = {[kind_2_auto] = desc_3_auto}
        else
          if string.match(line, ("^%s+" .. "!" .. ".*$")) then
            local kind_2_auto = string.match(line, ("^%s+(" .. "!" .. ").*$"))
            local desc_3_auto = string.match(line, ("^%s+" .. "!" .. "%s+(.*)%s*$"))
            elm = {[kind_2_auto] = desc_3_auto}
          else
            if string.match(line, ("^%s+" .. "%." .. ".*$")) then
              local kind_2_auto = string.match(line, ("^%s+(" .. "%." .. ").*$"))
              local desc_3_auto = string.match(line, ("^%s+" .. "%." .. "%s+(.*)%s*$"))
              elm = {[kind_2_auto] = desc_3_auto}
            else
              elm = line
            end
          end
        end
      end
    end
  end
  local function tbl_3f(o)
    return (type(o) == "table")
  end
  if ((list == nil) or (#list == 0)) then
    if tbl_3f(elm) then
      return {elm}
    else
      return {}
    end
  else
    if tbl_3f(elm) then
      return append(list, elm)
    else
      return list
    end
  end
end
local function parser(b_lines)
  local sy = _get_cnf().syntax
  local l_date = sy.date.lua_regex
  local ret = {}
  local date = ""
  for _, v in ipairs(b_lines) do
    if (string.match(v, ("^" .. l_date .. ".*$")) ~= nil) then
      date = string.match(v, ("^" .. l_date))
      do end (ret)[date] = {}
    else
      ret[date] = pack(v, ret[date])
    end
  end
  return ret
end
local function syntax(group, pat, ...)
  return vim.cmd(concat_with(" ", "syntax", "match", group, pat, ...))
end
local function set_highlight(group, fg, bg)
  for k, v in pairs(_get_cnf().hl) do
    vim.api.nvim_set_hl(0, k, v)
  end
  return nil
end
do
  local opt_1_auto
  local function _23_()
    return set_highlight()
  end
  local _24_
  if (type("match-hi-sche") == "string") then
    _24_ = vim.api.nvim_create_augroup("match-hi-sche", {clear = true})
  elseif (type("match-hi-sche") == "number") then
    _24_ = "match-hi-sche"
  else
    _24_ = print("au: group must be number or string", "match-hi-sche")
  end
  opt_1_auto = {callback = _23_, group = _24_}
  for k_2_auto, v_3_auto in pairs((nil or {})) do
    opt_1_auto[k_2_auto] = v_3_auto
  end
  vim.api.nvim_create_autocmd("ColorScheme", opt_1_auto)
end
local function _overwrite(default_cnf0, cnf)
  if (type(default_cnf0) == "table") then
    local ret = default_cnf0
    for k, v in pairs(default_cnf0) do
      if (type(v) == "table") then
        local new_v = cnf[k]
        if (new_v ~= nil) then
          ret[k] = _overwrite(v, new_v)
        else
        end
      else
        local new_v = cnf[k]
        if (new_v ~= nil) then
          ret[k] = new_v
        else
        end
      end
    end
    return ret
  else
    return print("Err(sche.nvim): The default_cnf is not table.")
  end
end
M.setup = function(_3fconfig)
  if (_3fconfig == nil) then
    return default_cnf
  else
    local cnf = _overwrite(default_cnf, _3fconfig)
    if (cnf == nil) then
      return default_cnf
    else
      vim.g["_sche#cnf"] = cnf
      return cnf
    end
  end
end
local function read_data(data)
  local notify = _get_cnf().notify
  local ret = ""
  for k, v in pairs(notify) do
    local annex = data[k]
    if (annex ~= nil) then
      ret = v(annex)
    else
    end
  end
  return ret
end
local function get_data(sd)
  local ll = {}
  if (sd ~= nil) then
    for _, v in ipairs(sd) do
      if (type(v) == "table") then
        ll = append(ll, read_data(v))
      else
        ll = append(ll, v)
      end
    end
  else
  end
  return ll
end
local function do_notify(date, data, title)
  local sd = data[date]
  if ((sd ~= nil) and (#sd ~= 0)) then
    local ll = get_data(sd)
    return require("notify")(ll, nil, {title = title})
  else
    return nil
  end
end
local function notify_todays_schedule()
  local data = vim.g["_sche#data"]
  if (data ~= nil) then
    local t = os.time()
    local today = os.date("%Y/%m/%d", t)
    return do_notify(today, data, "Today's schedule")
  else
    return nil
  end
end
local function notify_tomorrows_schedule()
  local data = vim.g["_sche#data"]
  if (data ~= nil) then
    local t = os.time()
    local tomorrow = os.date("%Y/%m/%d", (t + 86400))
    return do_notify(tomorrow, data, "Tomorrow's schedule")
  else
    return nil
  end
end
local function notify_main()
  local sche_path = _get_cnf().sche_path
  if ((sche_path ~= nil) and (sche_path ~= "none")) then
    local lines = read_lines(sche_path)
    if (lines ~= nil) then
      local data = parser(lines)
      vim.g["_sche#data"] = data
    else
    end
    if _get_cnf().notify_todays_schedule then
      notify_todays_schedule()
    else
    end
    if _get_cnf().notify_tomorrows_schedule then
      return notify_tomorrows_schedule()
    else
      return nil
    end
  else
    return nil
  end
end
do
  local opt_1_auto
  local function _42_()
    local async_8_auto = nil
    local function _43_()
      notify_main()
      return async_8_auto:close()
    end
    async_8_auto = vim.loop.new_async(vim.schedule_wrap(_43_))
    return async_8_auto:send()
  end
  local _44_
  if (type("sche-parse") == "string") then
    _44_ = vim.api.nvim_create_augroup("sche-parse", {clear = true})
  elseif (type("sche-parse") == "number") then
    _44_ = "sche-parse"
  else
    _44_ = print("au: group must be number or string", "sche-parse")
  end
  opt_1_auto = {callback = _42_, group = _44_}
  for k_2_auto, v_3_auto in pairs(({pattern = {"*.sche"}} or {})) do
    opt_1_auto[k_2_auto] = v_3_auto
  end
  vim.api.nvim_create_autocmd({"BufWritePost", "BufNewFile", "BufReadPost"}, opt_1_auto)
end
do
  local opt_1_auto
  local function _46_()
    if (vim.g["_sche#entered"] == nil) then
      do
        local async_8_auto = nil
        local function _47_()
          notify_main()
          return async_8_auto:close()
        end
        async_8_auto = vim.loop.new_async(vim.schedule_wrap(_47_))
        async_8_auto:send()
      end
      vim.g["_sche#entered"] = true
      return nil
    else
      return nil
    end
  end
  local _49_
  if (type("sche-parse") == "string") then
    _49_ = vim.api.nvim_create_augroup("sche-parse", {clear = true})
  elseif (type("sche-parse") == "number") then
    _49_ = "sche-parse"
  else
    _49_ = print("au: group must be number or string", "sche-parse")
  end
  opt_1_auto = {callback = _46_, group = _49_}
  for k_2_auto, v_3_auto in pairs((nil or {})) do
    opt_1_auto[k_2_auto] = v_3_auto
  end
  vim.api.nvim_create_autocmd({"VimEnter"}, opt_1_auto)
end
local keysource = {}
local function _51_()
  local sy = _get_cnf().syntax
  local date = sy.date.vimstrftime
  local date0 = vim.fn.strftime(("^" .. date))
  return vim.fn.search(date0)
end
local function _52_()
  local sy = _get_cnf().syntax
  local date = sy.date.vimstrftime
  local date0 = vim.fn.strftime(("^" .. date), (os.time() + 86400))
  return vim.fn.search(date0)
end
local function _53_()
  local item_dict = {["@"] = "schedule", ["-"] = "reminder", ["+"] = "todo", ["!"] = "deadline", ["."] = "done", ["#"] = "note"}
  local function _54_(item)
    _G.assert((nil ~= item), "Missing argument item on fnl/sche/init.fnl:216")
    return (item .. " " .. item_dict[item])
  end
  local function _55_(choice)
    _G.assert((nil ~= choice), "Missing argument choice on fnl/sche/init.fnl:218")
    local cline = vim.api.nvim_get_current_line()
    if (cline == "") then
      return vim.api.nvim_set_current_line(("  " .. choice .. " "))
    else
      vim.cmd("normal! o")
      vim.api.nvim_set_current_line(("  " .. choice .. " "))
      return vim.cmd("normal! $")
    end
  end
  return vim.ui.select(vim.tbl_keys(item_dict), {prompt = "Sche built in marks", format_item = _54_}, _55_)
end
local function _57_()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, 1)
  local ob = parser(lines)
  return print(vim.inspect(ob))
end
local function _58_()
  local keys = vim.fn.sort(vim.tbl_keys(keysource))
  local function _59_(item)
    _G.assert((nil ~= item), "Missing argument item on fnl/sche/init.fnl:235")
    return item
  end
  local function _60_(choice)
    _G.assert((nil ~= choice), "Missing argument choice on fnl/sche/init.fnl:236")
    return keysource[choice]()
  end
  return vim.ui.select(keys, {prompt = "Sche keysource", format_item = _59_}, _60_)
end
keysource = {["goto-today"] = _51_, ["goto-tomorrow"] = _52_, ["select-mark"] = _53_, ["parse-sche"] = _57_, ["keysource-navigater"] = _58_}
local default_keymap
local function _61_()
  local s = keysource
  for _, k in ipairs({{"n", "<space><space>t", s["goto-today"], "sche: goto-today"}, {"n", "<space><space>y", s["goto-tomorrow"], "sche: goto-tomorrow"}, {"n", "<space><space>m", s["select-mark"], "sche: select-mark"}, {"n", "<space><space>p", s["parse-sche"], "sche: parse-sche"}, {"n", "<space><space>n", s["keysource-navigater"], "sche: keysource-navigater"}}) do
    bmap(0, unpack(k))
  end
  return nil
end
default_keymap = _61_
local function buf_setup()
  return default_keymap()
end
local function _62_()
  if _get_cnf().default_keymap then
    buf_setup()
  else
  end
  buf_setup()
  do end (vim.bo)["filetype"] = "sche"
  local indent = 2
  vim.bo["tabstop"] = indent
  vim.bo["shiftwidth"] = indent
  vim.bo["softtabstop"] = indent
  local sy = _get_cnf().syntax
  local v_date = sy.date.vim_regex
  local ftime_date = sy.date.vimstrftime
  local syntax_on = sy.on
  if syntax_on then
    syntax("Comment", "'^;.*'")
    syntax("Statement", sy.month)
    syntax("Function", ("'^" .. v_date .. "'"))
    syntax("Special", "'\\s\\+@'")
    syntax("GCalendarBanana", "'\\s\\++'")
    syntax("Special", "'\\s\\+-'")
    syntax("GCalendarLavender", "'\\s\\+#'")
    syntax("GCalendarBanana", "'\\s\\+\\.'")
    syntax("GCalendarFlamingo", "'\\s\\+!'")
    syntax("GCalendarGraphite", sy.weekday)
    syntax("GCalendarMikan", sy.sunday)
    syntax("GCalendarPeacock", sy.saturday)
    return syntax("GCalendarSage", vim.fn.strftime(("'" .. ftime_date .. "'")))
  else
    return nil
  end
end
create_autocmd({"BufReadPost", "BufNewFile"}, {callback = _62_, pattern = {"*.sche"}, group = create_augroup("sche-syntax", {clear = true})})
local function _65_(opt)
  _G.assert((nil ~= opt), "Missing argument opt on fnl/sche/init.fnl:297")
  M.setup(opt)
  return set_highlight()
end
return {keysource = keysource, setup = _65_}
