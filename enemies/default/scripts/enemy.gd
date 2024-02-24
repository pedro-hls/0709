extends CharacterBody2D

class_name Green_slime

@export var normal_speed = 35
var health = 40
var direction
var dead = false
var player_in_area = false
var Arrowattack
var Player
var knockbacking = false
var damage = 20
var speed = normal_speed
var enemy_collision = false

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@export var target = CharacterBody2D

func ready():
	dead = false
	Player

func _physics_process(delta):
			
		if player_in_area and !knockbacking and !dead:
			$detection_area/detection.disabled = false
			$limit_area/limit.disabled = false
			$hitbox/CollisionShape2D.disabled = false
			
			#direction = (Player.position - position).normalized()
			#speed = normal_speed
			#velocity = direction * speed * delta * 100
			#move_and_slide()
			
			direction = to_local(nav_agent.get_next_path_position()).normalized()
			velocity = direction * speed
			move_and_slide()
				
			if direction.y > 0 and direction.y > abs(direction.x):
				$AnimatedSprite2D.play("walking_south")
			if direction.x > 0 and direction.x > abs(direction.y):
				$AnimatedSprite2D.play("walking_east")
			if direction.x < 0 and abs(direction.x) > abs(direction.y):
				$AnimatedSprite2D.play("walking_west")
			if direction.y < 0 and abs(direction.y) > abs(direction.x):
				$AnimatedSprite2D.play("walking_north")
					
		if !player_in_area:
			$AnimatedSprite2D.play("idle")
			
		if knockbacking:
			velocity = direction * speed * delta * 4
			knockbacking_delay()

#Quando o player inicia fora do range, da erro
func make_path():
	if Player != null:
		nav_agent.target_position = Player.global_position
	
#Detection Range
func _on_detection_area_body_entered(body):
	if body is Player:
		player_in_area = true
		Player = body
		
#Limit Detection
func _on_limit_area_body_exited(body):
	if body is Player:
		player_in_area = false
		Player = body

#Detect Arrow
func _on_damage_arrow_area_entered(area):
	if area is Arrowattack:
		var arrow_instance = area as Arrowattack
		var damage = arrow_instance.get_damage()
		take_damage(damage)
		area.queue_free()

#Damage
func take_damage(damage):
	health -= damage
	print("Vida Slime ", health)
	
	knockbacking_delay()
	
	if health <= 0 and !dead:
		death()
		
	modulate.a8 = 70
	await get_tree().create_timer(0.1).timeout
	modulate.a8 = 255
	await get_tree().create_timer(0.3).timeout
	
#Death
func death():
	dead = true
	$AnimatedSprite2D.play("death")
	$detection_area/detection.disabled = true
	$limit_area/limit.disabled = true
	$hitbox/CollisionShape2D.disabled = true
	await get_tree().create_timer(0.6).timeout
	queue_free()
	print("Slime Morreu")

#Knockback
@export var knockback_strength = 10
var current_knockback_direction = Vector2.ZERO

func knockbacking_delay():
	knockbacking = true
	await get_tree().create_timer(0.3).timeout
	knockbacking = false

func _on_hitbox_body_entered(body):
	if body is Player:
		Player.take_damage(damage)
		knockbacking_delay()
		return damage

func enemy():
	pass

func _on_timer_timeout():
	make_path()


func _on_navigation_agent_2d_velocity_computed(safe_velocity):
	pass # Replace with function body.
