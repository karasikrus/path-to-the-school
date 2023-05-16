extends ColorRect
class_name DialogBox

signal dialog_end

@export var dialog_path = ""
@export var text_speed: float = 0.05

@onready var timer = $Timer
@onready var end_phrase_timer = $EndPhraseTimer
@onready var name_label: RichTextLabel = $Name
@onready var text_label: RichTextLabel = $Text
@onready var indicator = $Indicator
@onready var portrait_left: Sprite2D = $PortraitLeft
@onready var portrait_right: Sprite2D = $PortraitRight

var dialog
var phrase_num = 0
var finished = false


func _ready():
	timer.wait_time = text_speed
	dialog = get_dialog()
	next_phrase()


func _process(_delta):
	indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			next_phrase()
		else:
			text_label.visible_characters = len(text_label.get_parsed_text())


func get_dialog() -> Array:
	if !FileAccess.file_exists(dialog_path):
		print("no file")
		return []
	var file = FileAccess.open(dialog_path, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	var output = json.data
	
	if typeof(output) == TYPE_ARRAY:
		print(output)
		return output
	else:
		print("wrong file format")
		return []


func next_phrase():
	if phrase_num >= len(dialog):
		dialog_end.emit()
		queue_free()
		return
	finished = false
	
	update_portrait()
	name_label.text = dialog[phrase_num]["name"]
	text_label.text = dialog[phrase_num]["text"]
	
	text_label.visible_characters = 0
	var parsed_text = text_label.get_parsed_text()
	
	while text_label.visible_characters < len(parsed_text):
		text_label.visible_characters += 1
		
		timer.start()
		await timer.timeout
	end_phrase_timer.start()
	await end_phrase_timer.timeout
	
	finished = true
	phrase_num += 1
	return


func update_portrait():
	portrait_left.visible = false
	portrait_right.visible = false
	var sprite_name = dialog[phrase_num]["image"]
	var sprite_position = get_sprite_position(dialog[phrase_num]["name"])
	var portrait := portrait_left
	match sprite_position:
		"left":
			portrait = portrait_left
		"right":
			portrait = portrait_right
	var portrait_path = "res://portraits/" + sprite_name
	if !ResourceLoader.exists(portrait_path):
		$ErrorSprite.visible = true
		return
	var portrait_image = load(portrait_path)
	portrait.texture = portrait_image
	portrait.visible = true

func get_sprite_position(character_name: String) -> String:
	if character_name == "Внучка":
		return "right"
	else:
		return "left"
		
