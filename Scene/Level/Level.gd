extends Node2D

onready var walls = $Walls
onready var nav_polygon_instance = $Navigation2D/NavigationPolygonInstance

#### ACCESSORS ####

func is_class(value: String): return value == "" or .is_class(value)
func get_class() -> String: return ""


#### BUILT-IN ####

func _ready() -> void:
	randomize()
	
#	exclude_tiles_from_nav_poly()




#### VIRTUALS ####



#### LOGIC ####

func exclude_tiles_from_nav_poly() -> void:
	var nav_polygon = nav_polygon_instance.get_navigation_polygon()
	
	var adj_groups_array = sort_cells_by_adjacents()
	
	for group in adj_groups_array:
		var group_polygon = get_group_polygon(group)
		nav_polygon.add_outline(group_polygon)
		nav_polygon.make_polygons_from_outlines()

	nav_polygon_instance.set_navigation_polygon(nav_polygon)


func sort_cells_by_adjacents() -> Array:
	var cell_group_array = []
	
	for cell in walls.get_used_cells():
		if cell.x < 1 or cell.y < 1 or cell.x > 38 or cell.y > 21:
			continue
		
		var group_found : bool = false
		
		if cell_group_array.empty():
			cell_group_array.append([])
		
		for group in cell_group_array:
			if group.empty():
				group.append(cell)
				group_found = true
				break
			else:
				if is_cell_adj_to_group(group, cell):
					group.append(cell)
					group_found = true
					break
		
		if !group_found:
			cell_group_array.append([cell])
	
	return cell_group_array


func is_cell_adj_to_group(group: Array, cell: Vector2) -> bool:
	for group_cell in group:
		var adj = [ group_cell + Vector2.RIGHT,
					group_cell + Vector2.LEFT,
					group_cell + Vector2.UP,
					group_cell + Vector2.DOWN]
		
		if cell in adj:
			return true
	return false


func get_group_polygon(group: Array) -> PoolVector2Array:
	var group_polygon = PoolVector2Array()
	for cell in group:
		var cell_id = walls.get_cellv(cell)
		var cell_nav_poly = walls.get_tileset().autotile_get_navigation_polygon(cell_id, Vector2.RIGHT).get_vertices()
		
		for vertex in cell_nav_poly:
			var final_vertex = vertex + cell * GAME.TILE_SIZE
			if not final_vertex in group_polygon:
				group_polygon.append(final_vertex)
	
	return group_polygon


#### INPUTS ####



#### SIGNAL RESPONSES ####
