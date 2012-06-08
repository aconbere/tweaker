#!/usr/bin/env lua

local args  = {...}
local start_dir = args[1] or "."

local lfs = require("lfs")
local tweaker = require("tweaker")

local function startswith(s, prefix)
  assert(type(s) == "string")
  assert(type(prefix) == "string")
  return prefix == s:sub(1, #prefix)
end

local function endswith(s, sufix)
  assert(type(s) == "string")
  assert(type(sufix) == "string")
  return sufix == s:sub(-#sufix, #s)
end

local ignore_dirs = { ["."] = true
                    , [".."] = true
                    }

local function walk(dir)
  for filename in lfs.dir(dir) do
    if not ignore_dirs[filename] then
      local attrs = lfs.attributes(dir.."/"..filename)

      if attrs.mode == "file" and
         startswith(filename, "test") and
         endswith(filename, ".lua") then
        local mod = dir:sub(3, -1).."/"..filename:sub(1, #filename-4)
        require(mod)
      elseif attrs.mode == "directory" then
        walk(dir.."/"..filename)
      end
    end
  end
end

walk(start_dir)
tweaker:finish()
