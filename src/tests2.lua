tweaker = require("tweaker")

tweaker.r("test_this_over_here",
function()
  assert(false, "failed test")
end)

tweaker.r("test_that_over_here",
function()
  assert(true, "passed test")
end)

