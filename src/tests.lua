local tweaker = require("tweaker")

local suite = tweaker.suite("name")

car = 10

suite.setup(function ()
  car = 20
end)

suite.r("test_this", function()
  assert(false, "failed test")
end)

suite.r("test_that", function()
  assert(true, "passed test")
end)

suite.r("car is 20", function()
  assert(car == 20, "car wasn't initialized")
end)

tweaker.run()
