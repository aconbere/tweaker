local color = require("color")
local class = require("class")

local Report = class()

local __error__ = {}

function Report:init()
  self._errors = {}
end

function Report:add_error(name, error_obj)
  self._errors[name] = error_obj
end

function Report:print()
  for name, err in pairs(self._errors) do
    print(color("bold", color("red", "["..name.."]: "..err.error_msg)))
    if err.traceback then
      print(err.traceback)
    end
  end
end

local Suite = class()

function Suite:init(name)
  self._tests    = {}
  self._suites   = {}
  self._setup    = function() end
  self._teardown = function() end
  self._name     = name
  self._report   = Report.new()
end

function Suite.error(test, error_msg, user_msg)
  if not test then
    error({ error_msg = error_msg
          , user_msg  = user_msg
          , type      = __error__
          })
  end
end

function Suite.assert(t, msg)
  Suite.error(t, "assertion failed!", msg)
end

function Suite.assert_equal(a, b, user_msg)
  Suite.error(a == b,
              tostring(a).." not equal "..tostring(b),
              user_msg)
end

function Suite.assert_in(t, value, msg)
  local set = {}
  for i,v in ipairs(t) do
    set[v] = true
  end

  Suite.error(set[value],
              tostring(value).." not in found in table",
              msg)
end

function Suite:setup(func)
  self._setup = func
end

function Suite:teardown(func)
  self._teardown = func
end

function Suite:is(name, test_func)
  self._tests[name] = test_func
end

local function parse_info(depth)
  local lines = {}

  --[[
  Funny story: This function is mostly ripped right out of lunit. When I first
  read it my puny scheme like brain immediately saw an oportunity to refactor
  this while loop into a recursive function call.

  When I had finished implimenting it, I kept running into an infinite loop.
  At first I thought it was just another exception being raised inside my own
  function. But after ages of debugging nothing was showing up.

  Finally it occurred to me, that if you are walking down the stack recusively
  every time you recurse you're also adding a new frame, so you just sit
  there, endlessly replaying your recursive call.

  I think this could be defeated by incrementing +2 instead of +1. But at that
  point I think the while loop is clearer.

  This ammused me greatly.
  ]]

  while true do
    local info = debug.getinfo(depth, "Snlf")

    if type(info) ~= "table" then
      break
    end

    local line = {}       -- Ripped from ldblib.c...

    table.insert(line, string.format("%s:", info.short_src))

    if info.currentline > 0 then
      table.insert(line, string.format("%d:", info.currentline))
    end

    if info.namewhat ~= "" then
      table.insert(line, string.format(" in function '%s'", info.name))
    else
      if info.what == "main" then
        table.insert(line, " in main chunk")
      elseif info.what == "C" or info.what == "tail" then
        table.insert(line, " ?")
      else
        table.insert(line, string.format(" in function <%s:%d>", info.short_src, info.linedefined))
      end
    end
    table.insert(lines, table.concat(line))
    depth = depth + 1
  end

  return table.concat(lines, "\n")
end

local function _traceback(e)
  local _error_obj = e
  -- by the time we start popping off the stack we will be 4 deep from our
  -- exception. determined by trial and error.
  local tweaker_stack_depth = 4

  if type(_error_obj) == "table" and _error_obj.type == __error__ then
    local info = debug.getinfo(6, "Sl")
    _error_obj.source = info.short_src
    _error_obj.currentline = info.currentline
    _error_obj.traceback = string.format( "%s:%d", info.short_src, info.currentline)
  else
    _error_obj = { error_msg = tostring(_error_obj) }
    _error_obj.traceback = parse_info(tweaker_stack_depth)
  end

  return _error_obj
end

function Suite:runtest(name, test_func)
  return xpcall(test_func, function(error_obj)
    self._report:add_error(name, _traceback(error_obj))
  end)
end

function Suite:run()
  for name, test in pairs(self._tests) do
    self:_setup()
    local status, _results = self:runtest(name, test)
    if status then
      io.write(".")
    else
      io.write(color("red", "x"))
    end
    self:_teardown()
  end

  for name, suite in pairs(self._suites) do
    suite:run()
  end
end

function Suite:suite(name)
  local new_suite = Suite.new(name)
  if name then
    self._suites[name] = new_suite
  else
    table.insert(self._suites, new_suite)
  end
  return new_suite
end

function Suite:report()
  self._report:print()

  for name, suite in pairs(self._suites) do
    suite:report()
  end
end

function Suite:finish()
  self:run()
  io.write("\n")
  self:report()
end

return Suite.new("main")
