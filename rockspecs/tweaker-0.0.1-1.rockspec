package = "Tweaker"

version = "0.0.1-1"

source = { url = "git://github.com/aconbere/tweaker.git"
         , tag = "v0.0.1"
         }

description = { summary = "Simple test runner"
              , detailed = [[
                  Tweaker is an extremely simple test collection and running
                  tool.
                ]]
              , license = "MIT/X11"
              , maintainer = "Anders Conbere <aconbere@gmail.com>"
              }

dependencies = { "lua == 5.1"
               , "luafilesystem"
               }

build = { type = "builtin"
        , modules = { tweaker = "./src/tweaker.lua"
                    , color   = "./src/color.lua"
                    , class   = "./src/class.lua"
                    }

        , install = { bin = { tweak = "src/tweak.lua"
                            }
                    }
        }
