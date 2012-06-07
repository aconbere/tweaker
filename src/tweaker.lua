local color = require("color")

local M = { errors = {}
          , tests = {}
          }

local function startswith(s, prefix)
  assert(type(s) == "string")
  assert(type(prefix) == "string")
  return prefix == s:sub(1, #prefix)
end

function M.r(name, test_func)
  M.tests[name] = test_func
end

function M.runtest(name, test_func)
  local function error_handler (msg)
    M.errors[name] = { msg = msg
                     , traceback = debug.traceback()
                     }
  end

  return xpcall(test_func, error_handler)
end

function M.runsuite(test_suite)
  for name, test in pairs(test_suite) do
    status, _results = M.runtest(name, test)
    if status then
      io.write(".")
    else
      io.write(color("red", "x"))
    end
  end
  io.write("\n")
end

function M.report(errors)
  for name, err in pairs(errors) do
    print(color("red", "["..name.."]: "..err.msg))
    print(err.traceback)
  end
end

function M.run()
  M.runsuite(M.tests)
  M.report(M.errors)
end

return M
