extends Area2D
class_name HurtboxComponent

signal damage(deadly: bool)

func _ready():
	area_entered.connect(on_area_entered)
	body_entered.connect(on_body_entered)


func on_area_entered(_area: Area2D):
	emit_damage()


func on_body_entered(body: Node2D):
	var deadly = true
	if body is Enemy:
		deadly = false
		
	emit_damage(deadly)
	print(("deadly" if deadly else "non-deadly") + "damage emitted")


func emit_damage(deadly: bool = true):
	damage.emit(deadly)
