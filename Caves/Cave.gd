extends Node2D

onready var tiles_id = {
	"dirt": -1,
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
	if cell_type == tiles_id["dirt"]:
		tilemap.set_cellv(cell_pos, tiles_id["ground"])
	elif cell_type == tiles_id["stone01"]:
		tilemap.set_cellv(cell_pos, tiles_id["dirt"])
	elif cell_type == tiles_id["stone02"]:
		tilemap.set_cellv(cell_pos, tiles_id["stone01"])
