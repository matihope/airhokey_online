extends Node2D

onready var ball = $Ball

remote func set_pos(pos):
	ball.position = pos

func _ready():
	restart_ball()

func _process(delta):
	if is_network_master():
		rpc_unreliable("set_pos", ball.position)
		
remotesync func restart_ball():
	if is_network_master():
		for child in get_children():
			if "Ball" in child.name:
				child.queue_free()
		ball = load("res://entities/ServerBall.tscn").instance()
		add_child(ball)
