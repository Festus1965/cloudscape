-- Cloudscape init.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


cloudscape_mod = {}
cloudscape_mod.version = "1.0"
cloudscape_mod.path = minetest.get_modpath(minetest.get_current_modname())
cloudscape_mod.world = minetest.get_worldpath()
cloudscape_mod.height = 50


function cloudscape_mod.clone_node(name)
	if not (name and type(name) == 'string') then
		return
	end

	local node = minetest.registered_nodes[name]
	local node2 = table.copy(node)
	return node2
end


cloudscape_mod.place_schematic = function(minp, maxp, data, p2data, area, node, pos, schem, center)
	if not (minp and maxp and data and p2data and area and node and pos and schem and type(data) == 'table' and type(p2data) == 'table' and type(schem) == 'table') then
		return
	end

	local rot = math.random(4) - 1
	local yslice = {}
	if schem.yslice_prob then
		for _, ys in pairs(schem.yslice_prob) do
			yslice[ys.ypos] = ys.prob
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
			local dz = pos.z - minp.z + z
			local dx = pos.x - minp.x + x
			if pos.x + x > minp.x and pos.x + x < maxp.x and pos.z + z > minp.z and pos.z + z < maxp.z then
				local ivm = area:index(pos.x + x, pos.y, pos.z + z)
				local isch = z1 * schem.size.y * schem.size.x + x1 + 1
				local math_random = math.random
				for y = 0, schem.size.y - 1 do
					local dy = pos.y - minp.y + y
						if yslice[y] or 255 >= math_random(255) then
							local prob = schem.data[isch].prob or schem.data[isch].param1 or 255
							if prob >= math_random(255) and schem.data[isch].name ~= "air" then
								data[ivm] = node[schem.data[isch].name]
							end
							local param2 = schem.data[isch].param2 or 0
							p2data[ivm] = param2
						end

					ivm = ivm + area.ystride
					isch = isch + schem.size.x
				end
			end
		end
	end
end


-- Create and initialize a table for a schematic.
function cloudscape_mod.schematic_array(width, height, depth)
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


cloudscape_mod.surround = function(node, data, area, ivm)
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


dofile(cloudscape_mod.path .. "/deco.lua")
dofile(cloudscape_mod.path .. "/mapgen.lua")
