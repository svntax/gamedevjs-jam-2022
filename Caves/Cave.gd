extends Node2D

var GoldOre = load("res://Ores/Gold.tscn")
var IronOre = load("res://Ores/Iron.tscn")
var EmeraldOre = load("res://Ores/Emerald.tscn")
var RubyOre = load("res://Ores/Ruby.tscn")
var SapphireOre = load("res://Ores/Sapphire.tscn")

onready var tiles_id = {
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

onready var tilemap = $TileMap

func _ready():
	var player = get_tree().get_nodes_in_group("Players")[0]
	player.connect("mine", self, "mine_at_position")
	
	# Set up dictionary for tile id's
	for key in tiles_id.keys():
		tiles_id[key] = tilemap.tile_set.find_tile_by_name(key)
		assert(tiles_id[key] != -1)

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
