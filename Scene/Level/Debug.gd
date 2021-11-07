extends Control

#### ACCESSORS ####

func is_class(value: String): return value == "" or .is_class(value)
func get_class() -> String: return ""


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("new_difficulty", self, "_on_EVENTS_new_difficulty")
	__ = EVENTS.connect("wave_started", self, "_on_EVENTS_wave_started")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_new_difficulty(difficulty: int) -> void:
	$VBoxContainer/Difficulty.set_text("Current difficulty: %d" % difficulty)


func _on_EVENTS_wave_started(wave_id: int) -> void:
	$VBoxContainer/Wave.set_text("Current wave: %d" % wave_id)
