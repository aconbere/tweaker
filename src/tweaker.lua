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
    print(err.traceback)
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

function Suite:runtest(name, test_func)
  return xpcall(test_func, function(error_obj)
    local info = debug.getinfo(5, "Sl")
    local traceback = debug.traceback()

    if error_obj.type == __error__ then
      traceback = string.format( "%s:%d", info.short_src, info.currentline)
    end

    self._report:add_error(name, { error_msg   = error_obj.error_msg or ""
                                 , user_msg    = error_obj.user_msg
                                 , traceback   = traceback
                                 , currentline = info.currentline
                                 , source      = info.short_src
                                 })
  end)
end

function Suite:run()
  for name, test in pairs(self._tests) do
    self:_setup()
    status, _results = self:runtest(name, test)
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
