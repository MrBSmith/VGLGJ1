extends Control

#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("hp_changed", self, "_on_EVENTS_hp_changed")
	__ = EVENTS.connect("nb_kunai_changed", self, "_on_EVENTS_nb_kunai_changed")
	
	for container in $VBoxContainer.get_children():
		for icon in container.get_children():
			icon.get_texture().set_local_to_scene(true)
			icon.get_texture().get_atlas().set_local_to_scene(true)
	
	_update_icons("HP", 3)
	_update_icons("Kunai", 4)

#### VIRTUALS ####



#### LOGIC ####

func _update_icons(container_name: String, value: int) -> void:
	var container = $VBoxContainer.get_node(container_name)
	
	var max_value = container.get_child_count()
	
	for i in range(max_value):
		var icon_texture = container.get_child(i).get_texture()
		var texture_size = icon_texture.get_atlas().get_size()
		var full = i < value
		var texture_x = 0 if full else texture_size.x / 2 
		
		var rect = Rect2(texture_x, 0, texture_size.x / 2, texture_size.y)
		icon_texture.set_region(rect)


#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_hp_changed(hp: int) -> void:
	_update_icons("HP", hp)


func _on_EVENTS_nb_kunai_changed(nb_kunai: int) -> void:
	_update_icons("Kunai", nb_kunai)
