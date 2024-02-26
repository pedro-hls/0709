extends Node2D

@onready var text = $text
@onready var name_display = $name_display
@onready var timer = $timer

var msg_queue: Array[Variant] = []
	
func _onready():
	text = ""
	name_display = ""
	$player_shadow.play("off")
	$npc_shadow.play("off")

func _input(event):
	if event is InputEventKey and event.is_action_pressed("ui_accept"):
		if text.visible_characters == text.get_total_character_count():
			show_message()

func add_message(_msg: Array) -> void:	
	if not visible:
		show()
		
	msg_queue.append_array(_msg)
	
	show_message()
	
	
	$npc_shadow.play("off")
	$player_shadow.play("off")
	
	if _msg[0] == "Gab":
		$npc_shadow.play("off")
		$player_shadow.play("on")
	else:
		$npc_shadow.play("off")
		$player_shadow.play("on")


func show_message() -> void:


	if msg_queue.size() <= 1:
		hide()
		return
	
	var _msg = msg_queue.pop_front()
	
	var text_colors = {
		"Gab": "#0e574a",
		"Grazi": "#3668b5"
	}
	
	# criar um dicionario para name_color
	# # fazer um if no var color
	
	var text_color = text_colors[_msg]
	
	var gab_name_color = "#13393a"
	
	if msg_queue[0] == "Gab":
		name_display.bbcode_text = "[color='%s']%s[/color]" % [gab_name_color, "Gab"]
		_msg = msg_queue.pop_front()
		#text.bbcode_text = "[color='%s']%s[/color]" % [gab_text_color, msg_queue[0]]
		$background.play("gab")
		$npc_shadow.play("on")
		$player_shadow.play("off")

	var grazi_name_color = "#1f4c8c"
	
	if msg_queue[0] == "Grazi":
		name_display.bbcode_text = "[color='%s']%s[/color]" % [grazi_name_color, "Grazi"]
		_msg = msg_queue.pop_front()
		#text.bbcode_text = "[color='%s']%s[/color]" % [grazi_text_color, msg_queue[0]]
		$background.play("grazi")
		$npc_shadow.play("off")
		$player_shadow.play("on")
		
	#if msg_queue[0] == "choice1":
	#	_msg = msg_queue.pop_front()
	
	#name_display.bbcode_text = "[color='%s']%s[/color]" % [name_color, msg_queue[0]]
	text.bbcode_text = "[color='%s']%s[/color]" % [text_color, msg_queue[0]]
	
	text.visible_characters = 0
	
	timer.start()

func _on_timer_timeout():
	text.visible_characters += 1
	if text.visible_characters == text.get_total_character_count():
		timer.stop()
