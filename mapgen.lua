-- Cloudscape mapgen.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


local DEBUG = false


local data = {}
local p2data = {}


local function generate(p_minp, p_maxp, seed)
	if not (p_minp and p_maxp and seed) then
		return
	end

	local minp, maxp = p_minp, p_maxp
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	if not (vm and emin and emax) then
		return
	end

	vm:get_data(data)
	p2data = vm:get_param2_data()
	local heightmap
	local area = VoxelArea:new({MinEdge = emin, MaxEdge = emax})
	local csize = vector.add(vector.subtract(maxp, minp), 1)

	local write = false
	if not cloudscape.height then
		return
	end

  do
    local avg = (minp.y + maxp.y) / 2
    avg = math.floor(avg / csize.y)
    if avg == cloudscape.height then
      write = cloudscape.cloudgen(minp, maxp, data, p2data, area)
    end
  end

  if write then
    vm:set_data(data)
    vm:set_param2_data(p2data)
    minetest.generate_ores(vm, minp, maxp)

    if DEBUG then
      vm:set_lighting({day = 8, night = 8})
    else
      vm:set_lighting({day = 0, night = 0}, minp, maxp)
      vm:calc_lighting()
    end
    vm:update_liquids()
    vm:write_to_map()
  end
end


if cloudscape.path then
	dofile(cloudscape.path .. "/cloudgen.lua")
end


local function pgenerate(...)
	local status, err = pcall(generate, ...)
	--local status, err = true
	--generate(...)
	if not status then
		print('Underworlds: Could not generate terrain:')
		print(dump(err))
		collectgarbage("collect")
	end
end


minetest.register_on_generated(pgenerate)
