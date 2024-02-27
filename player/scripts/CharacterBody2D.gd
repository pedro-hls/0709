extends CharacterBody2D

class_name Player

@export var speed = 100
@export var health = 100

@export var target: Player

var player_state

var damage_cooldown = false # Cooldown no dano que o Player pode tomar

var walking_direction # Guarda a direção do Player

var closest_distance = INF
var closest_enemy = null # Guarda o Inimigo mais próximo do Player

var enemy_count = 0 # Conta os inimigos que entraram no Range do Arco
var bow_area = false # Verifica se há Inimigos no Range do Arco

var bow_attacking = false

var arrow = preload("res://player/scenes/arrow.tscn")

var enemy_direction # Guarda a Direção do Inimigo
var bow_cooldown = false

var isdead = false # Verifica se o Player está morto

var isdashing = false # Verifica se o Player está usando o Dash
var dash_cooldown = false # Guarda se o Dash está em Cooldown
var direction 

var npc_in_range = false

func _physics_process(delta):
	if npc_in_range == true:
		if Input.is_action_just_pressed("interaction"):
			DialogueManager.show_dialogue_balloon(load("res://npcs/Grazi/first_dialogue.dialogue"), "start")
	
	if !isdead:
		direction = Input.get_vector("a", "d", "w", "s")

		if !bow_attacking:
			if direction.x == 0 and direction.y == 0:
				velocity = direction.normalized() * speed * 0
				idle_animation()
				player_state = "idle"
			
			if direction.x != 0 or direction.y != 0:
				velocity = direction.normalized() * speed
				play_animation(direction)
				player_state = "walking"
		
		if Input.is_action_just_pressed("dash") and $dashcooldown.is_stopped():
			dash()
			
		if bow_attacking:
			velocity = direction * speed * 0
			
		move_and_slide()

func dash():
	speed = speed * 1.8
	$dashcooldown.start()

func _on_dashcooldown_timeout():
	speed = 100
	
func _process(delta):
	if Input.is_action_just_pressed("left_mouse") and bow_cooldown == false and !isdead:
		var arrow_direction = self.global_position.direction_to(get_global_mouse_position())
		bow_cooldown = true
		bow_attacking = true
		update_arrow(arrow_direction)
		bow_animation(arrow_direction)
		
		await get_tree().create_timer(0.3).timeout
		bow_attacking = false	

#Instanciar a flecha na cena
func update_arrow(arrow_direction): #closest_enemy):
		
	var arrow_instance = arrow.instantiate()
	get_tree().current_scene.add_child(arrow_instance)
	arrow_instance.global_position = $Marker2D.global_position
	
	var arrow_rotation = $Marker2D.global_position.direction_to(get_global_mouse_position()).angle()
	arrow_instance.rotation = arrow_rotation
	
	$bowcooldown.start()

	
func _on_bowcooldown_timeout():
	bow_cooldown = false

#Detectar se os Inimigos entraram no Range do arco
#func _on_bow_range_area_body_entered(body):
	#if body.is_in_group("enemies"):
		#bow_area = true
		#enemy_count += 1
#
#Detectar se os Inimigos sairam do Range do Arco
#func _on_bow_range_area_body_exited(body):
	#if body.is_in_group("enemies"):
		#enemy_count -= 1
		#if enemy_count <= 0:
			#bow_area = false
#
#Detectar o Inimigo mais próximo
#func find_closest_enemy():
	#var all_enemies = get_tree().get_nodes_in_group("enemies")
	#var player_position = global_position
	#
	#for enemy in all_enemies:
		#var player2enemy = player_position.distance_to(enemy.global_position)
		#
		#if player2enemy < closest_distance:
			#closest_distance = player2enemy
			#closest_enemy = enemy
			#
	#update_arrow(closest_enemy)
	
# Dano ao jogador
func take_damage(damage):
	
	if !damage_cooldown:
		damage_cooldown = true
		health = health - damage
		opacity_animation()
		$CollisionShape2D.disabled = true
		await get_tree().create_timer(1).timeout
		$CollisionShape2D.disabled = false
		damage_cooldown = false
	
	if health <= 0 and isdead == false:
		isdead = true
		death()

func death():
	$AnimatedSprite2D.play("dead")

func start_damage_cooldown(damage_cooldown):
	print(damage_cooldown)
	
func opacity_animation():
	modulate.a8 = 70
	await get_tree().create_timer(0.2).timeout
	modulate.a8 = 255
	await get_tree().create_timer(0.2).timeout
	modulate.a8 = 70
	await get_tree().create_timer(0.2).timeout
	modulate.a8 = 255
	await get_tree().create_timer(0.2).timeout
	modulate.a8 = 70
	await get_tree().create_timer(0.2).timeout
	modulate.a8 = 255

func play_animation(direction):
	if direction.y < 0 and abs(direction.y) > abs(direction.x):
		$AnimatedSprite2D.play("walking_north")
		walking_direction = "north"
	if direction.x < 0 and abs(direction.x) > abs(direction.y):
		$AnimatedSprite2D.play("walking_west")
		walking_direction = "west"
	if direction.y > 0 and direction.y > abs(direction.x):
		$AnimatedSprite2D.play("walking_south")
		walking_direction = "south"
	if direction.x > 0 and direction.x > abs(direction.y):
		$AnimatedSprite2D.play("walking_east")
		walking_direction = "east"

func bow_animation(arrow_direction):
	if arrow_direction.y < 0 and abs(arrow_direction.y) > abs(arrow_direction.x):
		$AnimatedSprite2D.play("bow_north")
	if arrow_direction.x < 0 and abs(arrow_direction.x) > abs(arrow_direction.y):
		$AnimatedSprite2D.play("bow_west")
	if arrow_direction.y > 0 and arrow_direction.y > abs(arrow_direction.x):
		$AnimatedSprite2D.play("bow_south")
	if arrow_direction.x > 0 and arrow_direction.x > abs(arrow_direction.y):
		$AnimatedSprite2D.play("bow_east")

func idle_animation():
	if walking_direction == "north":
		$AnimatedSprite2D.play("idle_north")
	if walking_direction == "west":
		$AnimatedSprite2D.play("idle_west")
	if walking_direction == "east":
		$AnimatedSprite2D.play("idle_east")
	if walking_direction == "south" or walking_direction == null:
		$AnimatedSprite2D.play("idle_south")
		
func player():
	pass

func _on_interacion_area_body_entered(body):
	if body.is_in_group("npc"):
		npc_in_range = true


func _on_interacion_area_body_exited(body):
	if body.is_in_group("npc"):
		npc_in_range = false
