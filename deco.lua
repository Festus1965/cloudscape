-- Cloudscape deco.lua
-- Copyright Duane Robertson (duane@duanerobertson.com), 2017
-- Distributed under the LGPLv2.1 (https://www.gnu.org/licenses/old-licenses/lgpl-2.1.en.html)


local newnode = cloudscape_mod.clone_node("default:dirt")
newnode.description = "Cloud"
newnode.tiles = {'cloudscape_cloud.png'}
newnode.sunlight_propagates = true
minetest.register_node("cloudscape:cloud", newnode)

newnode = cloudscape_mod.clone_node("default:dirt")
newnode.description = "Storm Cloud"
newnode.tiles = {'cloudscape_storm_cloud.png'}
--newnode.sunlight_propagates = true
minetest.register_node("cloudscape:storm_cloud", newnode)

minetest.register_node("cloudscape:wispy_cloud", {
	description = "Wispy Cloud",
	tiles = {'cloudscape_wisp.png'},
	sunlight_propagates = true,
	use_texture_alpha = true,
	drawtype = "glasslike",
	paramtype = 'light',
	walkable = false,
	buildable_to = true,
	pointable = false,
})

minetest.register_node("cloudscape:moon_weed", {
	description = "Moon Weed",
	drawtype = "plantlike",
	tiles = {"cloudscape_moon_weed.png"},
	inventory_image = "cloudscape_moon_weed.png",
	waving = false,
	sunlight_propagates = true,
	paramtype = "light",
	light_source = 8,
	walkable = false,
	groups = {snappy=3,flammable=2,flora=1,attached_node=1},
	sounds = default.node_sound_leaves_defaults(),
	selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -5/16, 0.5},
	},
})

minetest.register_node("cloudscape:leaves_lumin", {
	description = "Leaves",
	drawtype = "allfaces_optional",
	waving = 1,
	visual_scale = 1.3,
	tiles = {"default_leaves.png^[colorize:#FFDF00:150"},
	special_tiles = {"default_leaves_simple.png^[colorize:#FFDF00:150"},
	paramtype = "light",
	is_ground_content = false,
	light_source = 8,
	groups = {snappy = 3, leafdecay = 4, flammable = 2, leaves = 1},
	drop = {
		max_items = 1,
		items = {
			--{
			--	-- player will get sapling with 1/20 chance
			--	items = {'default:sapling'},
			--	rarity = 20,
			--},
			{
				-- player will get leaves only if he get no saplings,
				-- this is because max_items is 1
				items = {'cloudscape:leaves_lumin'},
			}
		}
	},
	sounds = default.node_sound_leaves_defaults(),

	after_place_node = default.after_place_leaves,
})

minetest.register_node("cloudscape:lumin_tree", {
	description = "Lumin Tree",
	tiles = {
		"default_tree_top.png", "default_tree_top.png", "cloudscape_lumin_tree.png"
	},
	paramtype = "light",
	drawtype = "nodebox",
	node_box = {
		type = "fixed", 
		fixed = { {-0.25, -0.5, -0.25, 0.25, 0.5, 0.25}, }
	},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {tree = 1, choppy = 2, flammable = 2},
	sounds = default.node_sound_wood_defaults(),

	on_place = minetest.rotate_node
})

newnode = cloudscape_mod.clone_node("default:stone_with_iron")
newnode.description = "Silver Lining"
newnode.tiles = {'cloudscape_cloud.png^default_mineral_coal.png^[colorize:#FFFFFF:175'}
newnode.drop = "cloudscape:silver_lump"
minetest.register_node("cloudscape:silver_lining", newnode)

minetest.register_craftitem("cloudscape:silver_lump", {
	description = "Lump of Silver",
	inventory_image = 'default_coal_lump.png^[colorize:#FFFFFF:175',
})

minetest.register_craftitem("cloudscape:silver_ingot", {
	description = "Silver Ingot",
	inventory_image = 'default_steel_ingot.png^[colorize:#FFFFFF:175',
})

minetest.register_craft({
	type = "cooking",
	output = "cloudscape:silver_ingot",
	recipe = "cloudscape:silver_lump",
})


cloudscape_mod.schematics = {}
do
	local w, h, d = 5, 8, 5
	local s = cloudscape_mod.schematic_array(w, h, d)

	for y = 0, math.floor(h/2)-1 do
		s.data[2*d*h + y*d + 2 + 1].name = 'cloudscape:lumin_tree'
		s.data[2*d*h + y*d + 2 + 1].param1 = 255
	end

	for z = 0, d-1 do
		for y = math.floor(h/2), h-1 do
			for x = 0, w-1 do
				if y < h - 1 or (x ~= 0 and x ~= w-1 and z ~= 0 and z ~= d-1) then
					s.data[z*d*h + y*d + x + 1].name = 'cloudscape:leaves_lumin'

					if y == h-1 or x == 0 or x == w-1 or z == 0 or z == d-1 then
						s.data[z*d*h + y*d + x + 1].param1 = 150
					else
						s.data[z*d*h + y*d + x + 1].param1 = 225
					end
				end
			end
		end
	end

	for z = math.floor(d/2)-1, math.floor(d/2)+1, 2 do
		for x = math.floor(w/2)-1, math.floor(w/2)+1, 2 do
			s.data[z*d*h + math.floor(h/2)*d + x + 1].name = 'cloudscape:lumin_tree'
			s.data[z*d*h + math.floor(h/2)*d + x + 1].param1 = 150
		end
	end

	for y = 0, h-1 do
		if y / 3 == math.floor(y / 3) then
			s.yslice_prob[#s.yslice_prob+1] = {ypos=y,prob=170}
		end
	end

	cloudscape_mod.schematics['lumin_tree'] = s
end


if cloudscape_mod.path then
  dofile(cloudscape_mod.path .. "/deco_plants.lua")
end
