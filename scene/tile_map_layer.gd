extends TileMapLayer

func _ready() -> void:
	var filled_tiles := get_used_cells()
	for filled_tile: Vector2i in filled_tiles:
		var neigboring_tiles := get_surrounding_cells(filled_tile)
		for neigboring_tile: Vector2i in neigboring_tiles:
			if get_cell_source_id(neigboring_tile) == -1:
				set_cell(neigboring_tile, 0, Vector2i.ZERO)
