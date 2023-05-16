extends CanvasLayer
class_name PauseMenu

@onready var animation_player = $AnimationPlayer
@onready var panel_container = %PanelContainer
@onready var resume_button = %ResumeButton
@onready var sfx_slider = %SfxSlider
@onready var music_slider = %MusicSlider

var is_closing := false

func _ready():
	get_tree().paused = true
	update_display()
	
	resume_button.pressed.connect(on_resume_pressed)
	sfx_slider.value_changed.connect(on_audio_slider_changed.bind("sfx"))
	music_slider.value_changed.connect(on_audio_slider_changed.bind("music"))
	
	panel_container.pivot_offset = panel_container.size / 2
	animation_player.play("default")
	
	var tween = create_tween()
	tween.tween_property(panel_container, "scale", Vector2.ZERO, 0)
	tween.tween_property(panel_container, "scale", Vector2.ONE, .3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func update_display():
	sfx_slider.value = get_bus_volume_percent("sfx")
	music_slider.value = get_bus_volume_percent("music")

	
func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		close()
		get_tree().root.set_input_as_handled()
	www
func close():www
	if is_closing:
		return
	is_closing = true
	animation_player.play_backwards("default")
	
	www
	
	await tween.finished
	
	get_tree().paused = false
	queue_free()


func get_bus_volume_percent(bus_name: String) -> float:
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = AudioServer.get_bus_volume_db(bus_index)
	return db_to_linear(volume_db)


func set_bus_volume_percent(bus_name: String, percent: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	var volume_db = linear_to_db(percent)
	AudioServer.set_bus_volume_db(bus_index, volume_db)


func on_audio_slider_changed(value: float, bus_name: String):
	set_bus_volume_percent(bus_name, value)


func on_resume_pressed():
	close()
