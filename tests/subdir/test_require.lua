local tweaker = require("tweaker")
local suite = tweaker:suite("nested test")

suite:is("test_this_over_here", function()
  tweaker.assert(false, "failed test")
end)

suite:is("test_that_over_here", function()
  tweaker.assert(true, "passed test")
end)

