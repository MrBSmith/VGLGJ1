extends Control


#### ACCESSORS ####


#### BUILT-IN ####

func _ready() -> void:
	var __ = EVENTS.connect("score_changed", self, "_on_EVENTS_score_changed")

#### VIRTUALS ####



#### LOGIC ####



#### INPUTS ####



#### SIGNAL RESPONSES ####

func _on_EVENTS_score_changed(score: int) -> void:
	$HBoxContainer/Score.set_text(String(score))
