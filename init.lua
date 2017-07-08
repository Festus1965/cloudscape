-- Cloudscape init.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


cloudscape = {}
cloudscape.version = "1.0"
cloudscape.path = minetest.get_modpath(minetest.get_current_modname())
cloudscape.world = minetest.get_worldpath()
cloudscape.height = 50


function cloudscape.clone_node(name)
  if not (name and type(name) == 'string') then
    return
  end

  local node = minetest.registered_nodes[name]
  local node2 = table.copy(node)
  return node2
end

-- This tables looks up nodes that aren't already stored.
cloudscape.node = setmetatable({}, {
  __index = function(t, k)
    if not (t and k and type(t) == 'table') then
      return
    end

    t[k] = minetest.get_content_id(k)
    return t[k]
  end
})


dofile(cloudscape.path .. "/mapgen.lua")
dofile(cloudscape.path .. "/deco.lua")
dofile(cloudscape.path .. "/schematics.lua")
