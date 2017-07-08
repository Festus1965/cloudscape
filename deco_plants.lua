-- Cloudscape deco_plants.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


cloudscape.water_plants = {}
local function register_water_plant(desc)
	if not (desc and type(desc) == 'table') then
		return
	end

	cloudscape.water_plants[#cloudscape.water_plants+1] = desc
end


plantlist = {
	{name="water_plant_1",
	 desc="Water Plant",
	 water=true,
	},
}


for _, plant in ipairs(plantlist) do
	if plant.coral then
		groups = {cracky=3, stone=1, attached_node=1}
	else
		groups = {snappy=3,flammable=2,flora=1,attached_node=1}
	end
	if plant.groups then
		for k,v in pairs(plant.groups) do
			groups[k] = v
		end
	end

	minetest.register_node("cloudscape:"..plant.name, {
		description = plant.desc,
		drawtype = "plantlike",
		tiles = {"cloudscape_"..plant.name..".png"},
		waving = plant.wave,
		sunlight_propagates = plant.light,
		paramtype = "light",
		walkable = false,
		groups = groups,
		sounds = default.node_sound_leaves_defaults(),
		selection_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
		},
	})

	if plant.water then
		local def = {
			description = plant.desc,
			drawtype = "nodebox",
			node_box = {type='fixed', fixed={{-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}, {-0.5, 0.5, -0.001, 0.5, 1.5, 0.001}, {-0.001, 0.5, -0.5, 0.001, 1.5, 0.5}}},
			drop = "cloudscape:"..plant.name,
			tiles = { "default_sand.png", "cloudscape_"..plant.name..".png",},
			--tiles = { "default_dirt.png", "cloudscape_"..plant.name..".png",},
			sunlight_propagates = plant.light,
			--light_source = 14,
			paramtype = "light",
			light_source = plant.light_source,
			walkable = true,
			groups = groups,
			selection_box = {
				type = "fixed",
				fixed = {-0.5, 0.5, -0.5, 0.5, 11/16, 0.5},
			},
			sounds = plant.sounds or default.node_sound_leaves_defaults(),
			after_dig_node = function(pos, oldnode, oldmetadata, digger)
				if not (pos and oldnode) then
					return
				end

				local replacement = oldnode.name:gsub('.*_water_(.*)', 'default:%1')
				if replacement:find('cloud$') then
					replacement = replacement:gsub('^default', 'fun_caves')
				end
				minetest.set_node(pos, {name = replacement})
			end,
		}
		minetest.register_node("cloudscape:"..plant.name.."_water_sand", def)
		def2 = table.copy(def)
		def2.tiles = { "default_dirt.png", "cloudscape_"..plant.name..".png",}
		minetest.register_node("cloudscape:"..plant.name.."_water_dirt", def2)
		def2 = table.copy(def)
		def2.tiles = { "cloudscape_cloud.png", "cloudscape_"..plant.name..".png",}
		minetest.register_node("cloudscape:"..plant.name.."_water_cloud", def2)
		def2 = table.copy(def)
		def2.tiles = { "cloudscape_storm_cloud.png", "cloudscape_"..plant.name..".png",}
		minetest.register_node("cloudscape:"..plant.name.."_water_storm_cloud", def2)
	end
end


do
	-- Water Plant
	local water_plant_1_def_sand = {
		fill_ratio = 0.05,
		place_on = {"group:sand"},
		decoration = {"cloudscape:water_plant_1_water_sand"},
		--biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "desert", "savanna", "rainforest", "rainforest_swamp", },
		biomes = {"sandstone_grassland", "stone_grassland", "coniferous_forest", "deciduous_forest", "savanna", "rainforest", "rainforest_swamp","sandstone_grassland_ocean", "stone_grassland_ocean", "coniferous_forest_ocean", "deciduous_forest_ocean", "desert_ocean", "savanna_ocean", "desertstone_grassland", },
		y_max = 60,
	}
	if not cloudscape.use_bi_hi then
		water_plant_1_def_sand.biomes = nil
	end

	local water_plant_1_def_dirt = table.copy(water_plant_1_def_sand)
	water_plant_1_def_dirt.place_on = {"group:soil"}
	water_plant_1_def_dirt.decoration = {"cloudscape:water_plant_1_water_dirt",}
	local water_plant_1_def_cloud = table.copy(water_plant_1_def_sand)
	water_plant_1_def_cloud.place_on = {"group:cloud"}
	water_plant_1_def_cloud.decoration = {"cloudscape:water_plant_1_water_cloud",}
	local water_plant_1_def_storm_cloud = table.copy(water_plant_1_def_sand)
	water_plant_1_def_storm_cloud.place_on = {"group:cloud"}
	water_plant_1_def_storm_cloud.decoration = {"cloudscape:water_plant_1_water_storm_cloud",}

	register_water_plant(water_plant_1_def_sand)
	register_water_plant(water_plant_1_def_dirt)
	register_water_plant(water_plant_1_def_cloud)
	register_water_plant(water_plant_1_def_storm_cloud)
end


-- Get the content ids for all registered water plants.
for _, desc in pairs(cloudscape.water_plants) do
	if type(desc.decoration) == 'string' then
		desc.content_id = minetest.get_content_id(desc.decoration)
	elseif type(desc.decoration) == 'table' then
		desc.content_id = minetest.get_content_id(desc.decoration[1])
	end
end
