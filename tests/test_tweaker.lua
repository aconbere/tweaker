local tweaker = require("tweaker")

local suite = tweaker:suite("first test")

local car = 10
local bar = 10

suite:setup(function ()
  car = 20
end)

suite:teardown(function ()
  bar = 10
end)

suite:is("test_this", function()
  bar = bar + 1
  car = car + 1
  tweaker.assert(false, "failed test")
end)

suite:is("test_that", function()
  tweaker.assert(true, "passed test")
end)

suite:is("car is 20", function()
  tweaker.assert_equal(car, 20)
end)

suite:is("bar is 10", function()
  tweaker.assert_equal(bar, 10)
end)

suite:is("1 == 2", function()
  tweaker.assert_equal(1, 2)
end)

suite:is("regular failure", function()
  assert(45 == 23, "regular failure")
end)
