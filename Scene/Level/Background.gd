extends CanvasLayer

onready var background_color = $TextureRect.get_modulate()
export var flash_color : Color

#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("player_hurt", self, "_on_EVETNS_player_hurt")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVETNS_player_hurt() -> void:
	$TextureRect.set_modulate(flash_color)
	yield(get_tree().create_timer(0.2), "timeout")
	
	$TextureRect.set_modulate(background_color)
	
