extends Area2D

class_name Arrowattack

var speed = 200
@export var damage = 20
var enemy = null

# Called when the node enters the scene tree for the first time.
func _ready():
	animation()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	global_position += speed * direction.normalized() * delta
	await get_tree().create_timer(1).timeout
	global_position += speed * direction.normalized() * delta * 0
	
func animation():
	$AnimatedSprite2D.play("default_arrow")
	
func _on_visible_on_screen_enabler_2d_screen_exited():
	queue_free()

func _on_area_entered():
	if enemy.has_method("take_damage"):
		enemy.take_damage(damage)

func get_damage():
	return damage
		
func arrow():
	pass
