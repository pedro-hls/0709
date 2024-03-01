extends Node

var speaker
var left_is_player

var talking = false
var talking_cooldown

func add_talking_cooldown():
	talking_cooldown = true
	await get_tree().create_timer(3).timeout
	talking_cooldown = false

var text_colors = {
	"Gab": "#0e574a",
	"Grazi": "#1f4c8c"
}
	
var name_colors = {
	"Gab": "#0e574a",
	"Grazi": "#1f4c8c"
}

