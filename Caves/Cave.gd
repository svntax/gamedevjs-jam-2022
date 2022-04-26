extends Node2D

export (int, 0, 5000) var cave_width = 64

const GoldOre = preload("res://Ores/Gold.tscn")
const IronOre = preload("res://Ores/Iron.tscn")
const EmeraldOre = preload("res://Ores/Emerald.tscn")
const RubyOre = preload("res://Ores/Ruby.tscn")
const SapphireOre = preload("res://Ores/Sapphire.tscn")
const Golem = preload("res://Enemies/Golem.tscn")

onready var tiles_id = {
	"wall": -1,
	"dirt": -1, "dirt_broken": -1,
	"stone01": -1,
	"stone02": -1,
	"ground": -1,
	"gold01": -1, "gold02": -1, "gold03": -1,
	"emerald01": -1, "emerald02": -1,
	"iron01": -1, "iron02": -1,
	"ruby01": -1, "ruby02": -1,
	"sapphire01": -1
}

var random = RandomNumberGenerator.new()

onready var tilemap = $TileMap

func _ready():
	var player = get_tree().get_nodes_in_group("Players")[0]
	player.connect("mine", self, "mine_at_position")
	
	for golem in get_tree().get_nodes_in_group("Golems"):
		golem.connect("mine", self, "mine_at_position")
	
	# Set up dictionary for tile id's
	for key in tiles_id.keys():
		tiles_id[key] = tilemap.tile_set.find_tile_by_name(key)
		assert(tiles_id[key] != -1)
	
	generate_cave()

func generate_cave() -> void:
	tilemap.clear()
	random.randomize()
	print("Generating cave with seed: " + str(random.seed))
	for x in range(cave_width):
		for y in range(9):
			# Left-most wall
			if x == 0:
				tilemap.set_cell(x, y, tiles_id["wall"])
				continue
			# Top and bottom walls
			if y == 0 or y == 8:
				# Walls
				tilemap.set_cell(x, y, tiles_id["wall"])
			# Actual cave generation
			else:
				# Starting area is all ground
				if 1 <= x and x <= 7:
					tilemap.set_cell(x, y, tiles_id["ground"])
					continue
				elif 8 <= x and x <= 10:
					var choice = random.randf()
					if choice < 0.3:
						tilemap.set_cell(x, y, tiles_id["ground"])
					else:
						tilemap.set_cell(x, y, tiles_id["dirt"])
					continue
				# First layer: dirt, stone, gold, iron
				var choice = random.randf()
				if 11 <= x and x <= 20:
					if choice <= 0.01: # Spawn golem
						tilemap.set_cell(x, y, tiles_id["ground"])
						place_golem_at(x, y, Globals.OreType.RUBY)
					elif choice <= 0.8:
						tilemap.set_cell(x, y, tiles_id["dirt"])
					elif choice <= 0.9:
						place_gold_at(x, y)
					elif choice <= 0.95:
						tilemap.set_cell(x, y, tiles_id["ground"])
					elif choice <= 0.98:
						place_iron_at(x, y)
					else:
						place_stone_at(x, y)
				# Second layer: dirt, stone, gold, iron, emerald
				elif 21 <= x and x <= 60:
					if choice <= 0.02:
						tilemap.set_cell(x, y, tiles_id["ground"])
						place_golem_at(x, y, Globals.OreType.RUBY)
					elif choice <= 0.75:
						tilemap.set_cell(x, y, tiles_id["dirt"])
					elif choice <= 0.8:
						place_stone_at(x, y)
					elif choice <= 0.9:
						place_gold_at(x, y)
					elif choice <= 0.93:
						place_emerald_at(x, y)
					elif choice <= 0.96:
						place_iron_at(x, y)
					else:
						tilemap.set_cell(x, y, tiles_id["ground"])
				# Third layer: dirt, stone, gold, iron, emerald, ruby
				elif 61 <= x and x <= 80:
					if choice <= 0.02:
						tilemap.set_cell(x, y, tiles_id["ground"])
						place_golem_at(x, y, Globals.OreType.RUBY)
					elif choice <= 0.65:
						tilemap.set_cell(x, y, tiles_id["dirt"])
					elif choice <= 0.8:
						place_stone_at(x, y)
					elif choice <= 0.85:
						place_gold_at(x, y)
					elif choice <= 0.9:
						place_emerald_at(x, y)
					elif choice <= 0.93:
						place_ruby_at(x, y)
					elif choice <= 0.96:
						place_iron_at(x, y)
					else:
						tilemap.set_cell(x, y, tiles_id["ground"])
				# Fourth layer: all tile types
				elif 81 <= x and x <= 100:
					if choice <= 0.03:
						tilemap.set_cell(x, y, tiles_id["sapphire01"])
					elif choice <= 0.6:
						tilemap.set_cell(x, y, tiles_id["dirt"])
					elif choice <= 0.63:
						tilemap.set_cell(x, y, tiles_id["ground"])
						place_golem_at(x, y, Globals.OreType.RUBY)
					elif choice <= 0.75:
						place_stone_at(x, y)
					elif choice <= 0.78:
						place_gold_at(x, y)
					elif choice <= 0.9:
						place_emerald_at(x, y)
					elif choice <= 0.95:
						place_ruby_at(x, y)
					elif choice <= 0.98:
						place_iron_at(x, y)
					else:
						tilemap.set_cell(x, y, tiles_id["ground"])
				# Final layer: mainly rarer ores
				else:
					if choice <= 0.05:
						tilemap.set_cell(x, y, tiles_id["ground"])
						place_golem_at(x, y, Globals.OreType.RUBY)
					elif choice <= 0.5:
						tilemap.set_cell(x, y, tiles_id["dirt"])
					elif choice <= 0.7:
						place_stone_at(x, y)
					elif choice <= 0.9:
						tilemap.set_cell(x, y, tiles_id["sapphire01"])
					elif choice <= 0.95:
						place_ruby_at(x, y)
					elif choice <= 0.98:
						place_gold_at(x, y)
					else:
						tilemap.set_cell(x, y, tiles_id["ground"])

# Helper functions for placing tiles
func place_gold_at(x: int, y: int) -> void:
	var tile_id = tiles_id["gold0" + str(random.randi() % 3 + 1)]
	tilemap.set_cell(x, y, tile_id)

func place_stone_at(x: int, y: int) -> void:
	var tile_id = tiles_id["stone0" + str(random.randi() % 2 + 1)]
	tilemap.set_cell(x, y, tile_id)

func place_iron_at(x: int, y: int) -> void:
	var tile_id = tiles_id["iron0" + str(random.randi() % 2 + 1)]
	tilemap.set_cell(x, y, tile_id)

func place_emerald_at(x: int, y: int) -> void:
	var tile_id = tiles_id["emerald0" + str(random.randi() % 2 + 1)]
	tilemap.set_cell(x, y, tile_id)

func place_ruby_at(x: int, y: int) -> void:
	var tile_id = tiles_id["ruby0" + str(random.randi() % 2 + 1)]
	tilemap.set_cell(x, y, tile_id)

func place_golem_at(cell_x: int, cell_y: int, golem_ore_type = Globals.OreType.RUBY) -> void:
	var local_pos = tilemap.map_to_world(Vector2(cell_x, cell_y))
	var spawn_pos = tilemap.to_global(local_pos)
	var golem = Golem.instance()
	golem.golem_type = golem_ore_type
	golem.global_position = spawn_pos + Vector2(tilemap.cell_size.x / 2, tilemap.cell_size.y / 2)
	add_child(golem)
	golem.connect("mine", self, "mine_at_position")

func mine_at_position(pos: Vector2) -> void:
	var cell_pos = tilemap.world_to_map(pos)
	var cell_type = tilemap.get_cellv(cell_pos)
	# Non-ore cells
	if cell_type == tiles_id["dirt_broken"]:
		tilemap.set_cellv(cell_pos, tiles_id["ground"])
	elif cell_type == tiles_id["dirt"]:
		tilemap.set_cellv(cell_pos, tiles_id["dirt_broken"])
	elif cell_type == tiles_id["stone01"]:
		tilemap.set_cellv(cell_pos, tiles_id["dirt"])
	elif cell_type == tiles_id["stone02"]:
		tilemap.set_cellv(cell_pos, tiles_id["stone01"])
	# Ores
	else:
		var ore = null
		if cell_type in [tiles_id["gold01"], tiles_id["gold02"], tiles_id["gold03"]]:
			tilemap.set_cellv(cell_pos, tiles_id["ground"])
			ore = GoldOre.instance()
		elif cell_type in [tiles_id["iron01"], tiles_id["iron02"]]:
			tilemap.set_cellv(cell_pos, tiles_id["ground"])
			ore = IronOre.instance()
		elif cell_type in [tiles_id["emerald01"], tiles_id["emerald02"]]:
			tilemap.set_cellv(cell_pos, tiles_id["ground"])
			ore = EmeraldOre.instance()
		elif cell_type in [tiles_id["ruby01"], tiles_id["ruby02"]]:
			tilemap.set_cellv(cell_pos, tiles_id["ground"])
			ore = RubyOre.instance()
		elif cell_type == tiles_id["sapphire01"]:
			tilemap.set_cellv(cell_pos, tiles_id["ground"])
			ore = SapphireOre.instance()
		# If an ore did end up being mined, spawn it
		if ore != null:
			var local_pos = tilemap.map_to_world(cell_pos)
			var global_pos = tilemap.to_global(local_pos)
			ore.global_position = global_pos + Vector2(tilemap.cell_size.x / 2, tilemap.cell_size.y / 2) \
					+ Vector2(randi() % 5 - 2, randi() % 5 - 2)
			get_parent().add_child(ore)
