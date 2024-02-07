extends CharacterBody2D

class_name Bow

var dead = false
var player_in_area = false
var player

func ready():
	position = player.position
