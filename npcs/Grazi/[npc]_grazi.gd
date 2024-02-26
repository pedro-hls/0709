extends CharacterBody2D

@export var interacion: Resource

func _ready():
	DialogBox.add_message(interacion.msg_queue)
