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

var arrow = preload("res://player/scenes/arrow.tscn")
var bow_cooldown = false # Cooldown no uso do Arco
var bow_attacking = false # Verifica se o Player está atacando com o Arco

var enemy_direction # Guarda a Direção do Inimigo

var isdead = false # Verifica se o Player está morto

var isdashing = false # Verifica se o Player está usando o Dash
var dash_cooldown = false # Guarda se o Dash está em Cooldown
var direction 

func _physics_process(delta):
	if !isdead:
		direction = Input.get_vector("a", "d", "w", "s")

		if direction.x == 0 and direction.y == 0:
			velocity = direction.normalized() * speed * 0
			idle_animation()
			player_state = "idle"
			
		if direction.x != 0 or direction.y != 0:
			velocity = direction.normalized() * speed
			play_animation(direction)
			player_state = "walking"
			
		if bow_attacking:
			bow_animation(direction)
			velocity = direction * speed * 0
			
		move_and_slide()
		
		if Input.is_action_just_pressed("dash"):
			dash()

func dash():
	speed = speed * 3
	$dashcooldown.start()

func _on_dashcooldown_timeout():
	speed = 100
	
func _process(delta):
	if Input.is_action_just_pressed("left_mouse") and bow_cooldown == false and bow_area == true:
		closest_enemy = null
		closest_distance = INF
		find_closest_enemy()
		bow_attacking = true
		start_bow_cooldown()

#Detectar o Inimigo mais próximo
func find_closest_enemy():
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	var player_position = global_position
	
	for enemy in all_enemies:
		var player2enemy = player_position.distance_to(enemy.global_position)
		
		if player2enemy < closest_distance:
			closest_distance = player2enemy
			closest_enemy = enemy
			
	update_arrow(closest_enemy)
	
#Instanciar a flecha na cena
func update_arrow(closest_enemy):
	if closest_enemy and !bow_attacking and !isdead:
		
		var arrow_instance = arrow.instantiate()
		enemy_direction = (closest_enemy.global_position - $Marker2D.global_position)
		var rotation_angle = atan2(enemy_direction.y, enemy_direction.x)
		await get_tree().create_timer(0.2).timeout
		
		arrow_instance.rotation = rotation_angle
		arrow_instance.global_position = $Marker2D.global_position
		arrow_instance.enemy = closest_enemy
		add_child(arrow_instance)
		
		print("Tacando Flecha")

#Detectar se os Inimigos entraram no Range do arco
func _on_bow_range_area_body_entered(body):
	if body.is_in_group("enemies"):
		bow_area = true
		enemy_count += 1

#Detectar se os Inimigos sairam do Range do Arco
func _on_bow_range_area_body_exited(body):
	if body.is_in_group("enemies"):
		enemy_count -= 1
		if enemy_count <= 0:
			bow_area = false

#Cooldown do ataque do arco
func start_bow_cooldown():
	bow_cooldown = true
	await get_tree().create_timer(1.0).timeout
	bow_cooldown = false

# Desliga o status de Atacando com o Arco
func stop_bow_attacking():
	await get_tree().create_timer(0.2).timeout
	bow_attacking = false

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
	
# Diminui a opacidade do jogador
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

func player():
	pass

# Animação Walking
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

func bow_animation(direction):
	if bow_attacking:
		if enemy_direction.y < 0 and abs(enemy_direction.y) > abs(enemy_direction.x):
			$AnimatedSprite2D.play("bow_north")
		if enemy_direction.x < 0 and abs(enemy_direction.x) > abs(enemy_direction.y):
			$AnimatedSprite2D.play("bow_west")
		if enemy_direction.y > 0 and enemy_direction.y > abs(enemy_direction.x):
			$AnimatedSprite2D.play("bow_south")
		if enemy_direction.x > 0 and enemy_direction.x > abs(enemy_direction.y):
			$AnimatedSprite2D.play("bow_east")
		stop_bow_attacking()
	
# Animação Idle
func idle_animation():
	if walking_direction == "north":
		$AnimatedSprite2D.play("idle_north")
	if walking_direction == "west":
		$AnimatedSprite2D.play("idle_west")
	if walking_direction == "east":
		$AnimatedSprite2D.play("idle_east")
	if walking_direction == "south" or walking_direction == null:
		$AnimatedSprite2D.play("idle_south")
