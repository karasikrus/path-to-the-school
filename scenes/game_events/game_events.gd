extends Node

signal player_death

var last_death_scene: PackedScene

@export var death_dialog_scene: PackedScene

func emit_player_death():
	player_death.emit()
