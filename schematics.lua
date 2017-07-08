-- Cloudscape schematics.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


-- Create and initialize a table for a schematic.
function cloudscape.schematic_array(width, height, depth)
  if not (width and height and depth and type(width) == 'number' and type(height) == 'number' and type(depth) == 'number') then
    return
  end

  -- Dimensions of data array.
  local s = {size={x=width, y=height, z=depth}}
  s.data = {}

  for z = 0,depth-1 do
    for y = 0,height-1 do
      for x = 0,width-1 do
        local i = z*width*height + y*width + x + 1
        s.data[i] = {}
        s.data[i].name = "air"
        s.data[i].param1 = 000
      end
    end
  end

  s.yslice_prob = {}

  return s
end


cloudscape.surround = function(node, data, area, ivm)
	if not (node and data and area and ivm and type(data) == 'table' and type(ivm) == 'number') then
		return
	end

	-- Check to make sure that a plant root is fully surrounded.
	-- This is due to the kludgy way you have to make water plants
	--  in minetest, to avoid bubbles.
	for x1 = -1,1,2 do
		local n = data[ivm+x1] 
		if n == node["default:river_water_source"] or n == node["default:water_source"] or n == node["air"] then
			return false
		end
	end
	for z1 = -area.zstride,area.zstride,2*area.zstride do
		local n = data[ivm+z1] 
		if n == node["default:river_water_source"] or n == node["default:water_source"] or n == node["air"] then
			return false
		end
	end

	return true
end


--local displaceable = table.copy(cloudscape.ground_nodes)
local displaceable = {}
displaceable[cloudscape.node['default:water_source']] = true


cloudscape.place_schematic = function(minp, maxp, data, p2data, area, node, pos, schem, center)
  if not (minp and maxp and data and p2data and area and node and pos and schem and type(data) == 'table' and type(p2data) == 'table' and type(schem) == 'table') then
    return
  end

  local rot = math.random(4) - 1
  local yslice = {}  -- true if the slice should be removed
  if schem.yslice_prob then
    for _, ys in pairs(schem.yslice_prob) do
      yslice[ys.ypos] = ((ys.prob or 254) < math.random(254))
    end
  end

  if center then
    pos.x = pos.x - math.floor(schem.size.x / 2)
    pos.z = pos.z - math.floor(schem.size.z / 2)
  end

  for z1 = 0, schem.size.z - 1 do
    for x1 = 0, schem.size.x - 1 do
      local x, z
      if rot == 0 then
        x, z = x1, z1
      elseif rot == 1 then
        x, z = schem.size.z - z1 - 1, x1
      elseif rot == 2 then
        x, z = schem.size.x - x1 - 1, schem.size.z - z1 - 1
      elseif rot == 3 then
        x, z = z1, schem.size.x - x1 - 1
      end
      --local dz = pos.z - minp.z + z
      --local dx = pos.x - minp.x + x
      --if pos.x + x > minp.x and pos.x + x < maxp.x and pos.z + z > minp.z and pos.z + z < maxp.z then
      if true then
        local ivm = area:index(pos.x + x, pos.y, pos.z + z)
        local isch = z1 * schem.size.y * schem.size.x + x1 + 1
        for y = 0, schem.size.y - 1 do
          --local dy = pos.y - minp.y + y
          if not yslice[y] then
            if data[ivm] == node['air'] or data[ivm] == node['ignore'] or (schem.data[isch].force_place and displaceable[data[ivm]]) then
              local prob = schem.data[isch].prob or schem.data[isch].param1 or 255
              if prob >= math.random(254) and schem.data[isch].name ~= "air" then
                data[ivm] = node[schem.data[isch].name]
              end
              local param2 = schem.data[isch].param2 or 0
              p2data[ivm] = param2
            end

            ivm = ivm + area.ystride
          end
          isch = isch + schem.size.x
        end
      end
    end
  end
end


cloudscape.schematics = {}

local default_schematic_path = minetest.get_modpath("default").."/schematics/"
local function convert_mts(mts)
  local sch = minetest.serialize_schematic(default_schematic_path..'/'..mts, 'lua', {})
  sch = minetest.deserialize('return {'..sch..'}')
  return sch.schematic
end


do
  local sch = {
    --{name='acacia_bush', file='acacia_bush.mts'},
    --{name='acacia_log', file='acacia_log.mts'},
    --{name='acacia_tree_from_sapling', file='acacia_tree_from_sapling.mts'},
    {name='acacia_tree', file='acacia_tree.mts'},
    --{name='apple_log', file='apple_log.mts'},
    --{name='apple_tree_from_sapling', file='apple_tree_from_sapling.mts'},
    {name='apple_tree', file='apple_tree.mts'},
    --{name='aspen_log', file='aspen_log.mts'},
    --{name='aspen_tree_from_sapling', file='aspen_tree_from_sapling.mts'},
    {name='aspen_tree', file='aspen_tree.mts'},
    --{name='bush', file='bush.mts'},
    --{name='corals', file='corals.mts'},
    --{name='jungle_log', file='jungle_log.mts'},
    --{name='jungle_tree_from_sapling', file='jungle_tree_from_sapling.mts'},
    {name='jungle_tree', file='jungle_tree.mts'},
    --{name='large_cactus', file='large_cactus.mts'},
    --{name='papyrus', file='papyrus.mts'},
    --{name='pine_log', file='pine_log.mts'},
    --{name='pine_tree_from_sapling', file='pine_tree_from_sapling.mts'},
    {name='pine_tree', file='pine_tree.mts'},
    --{name='snowy_pine_tree_from_sapling', file='snowy_pine_tree_from_sapling.mts'},
  }

  for _, s in pairs(sch) do
    cloudscape.schematics[s.name] = convert_mts(s.file)
  end
end


do
  local t = table.copy(cloudscape.schematics['apple_tree'])
  for i, _ in pairs(t.data) do
    if t.data[i].name == 'default:leaves' or t.data[i].name == 'default:apple' then
      t.data[i].name = 'cloudscape:leaves_lumin'
    elseif t.data[i].name == 'default:tree' then
      t.data[i].name = 'cloudscape:lumin_tree'
    end
  end
  cloudscape.schematics['lumin_tree'] = t
end
