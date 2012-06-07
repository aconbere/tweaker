local function escape(value)
  return string.char(27).."["..tostring(value).."m"
end

local color_metatable = {}
function color_metatable.__call(t, style, str)
  assert(style, "style can't be nil")
  if type(style) == "string" and t[style] then
    style = t[style]
  end
  return (style..str..t.clear)
end

local M = { clear = escape(0)
          -- Foreground colors
          , black      = escape(30)
          , red        = escape(31)
          , green      = escape(32)
          , yellow     = escape(33)
          , blue       = escape(34)
          , magenta    = escape(35)
          , cyan       = escape(36)
          , white      = escape(37)
          , default    = escape(39)

          -- Font styles
          , bold       = escape(1)
          , italic     = escape(3)
          , underline  = escape(4)
          , inverse    = escape(7)
          , strike     = escape(9)

          , xbold      = escape(1)
          , xitalic    = escape(3)
          , xunderline = escape(4)
          , xinverse   = escape(7)
          , xstrike    = escape(9)

          -- Background colors
          , back = { black      = escape(40)
                   , red        = escape(41)
                   , green      = escape(42)
                   , yellow     = escape(43)
                   , blue       = escape(44)
                   , magenta    = escape(45)
                   , cyan       = escape(46)
                   , white      = escape(47)
                   , default    = escape(49)
                   }
          }
setmetatable(M, color_metatable)

-- print(M(M.green,   "attr"))
-- print(M(M.yellow,  "attr"))
-- print(M(M.blue,    "attr"))
-- print(M(M.magenta, "attr"))
-- print(M(M.red,     "attr"))
-- print(M(M.black,   "attr"))
-- 
-- print(M(M.green,   "str"))
-- print(M(M.yellow,  "str"))
-- print(M(M.blue,    "str"))
-- print(M(M.magenta, "str"))
-- print(M(M.red,     "str"))
-- print(M(M.black,   "str"))

return M
