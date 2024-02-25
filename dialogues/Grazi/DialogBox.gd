extends NinePatchRect

@onready var text = $text
@onready var timer = $timer

var msg_queue: Array[Variant] = []

#func _ready() -> void:
#	text = "aaaaaaa"

func _input(event):
	if event is InputEventKey and event.is_action_pressed("ui_accept"):
		show_message()

func add_message(_msg: Array) -> void:	
	if not visible:
		show()
	
	msg_queue.append_array(_msg)
	show_message()

func show_message() -> void:

	if msg_queue.size() == 0:
		hide()
		return
	
	var _msg = msg_queue.pop_front()

	text.bbcode_text = _msg
	text.visible_characters = 0
	
	timer.start()

func _on_timer_timeout():
	text.visible_characters += 1
	print(text.visible_characters)
	if text.visible_characters == text.get_total_character_count():
	#if text.visible_characters == 20:
		timer.stop()
