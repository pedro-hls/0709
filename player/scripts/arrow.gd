extends Area2D

class_name Arrowattack

var speed = 200
@export var damage = 20
var enemy = null

# Called when the node enters the scene tree for the first time. a
func _ready():
	set_as_top_level(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = (enemy.global_position - global_position).normalized()
	position += direction * speed * delta
	
func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func _on_area_entered():
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)

func get_damage():
	return damage
		
func arrow():
	pass
