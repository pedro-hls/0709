extends CharacterBody2D

@export var dialog: Resource

func _ready():
	DialogBox.add_message(dialog.msg_queue)
