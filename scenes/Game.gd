extends Node2D

var my_player = null
var another_player = null

func _ready():
	get_tree().set_pause(true)
	
	var selfPeerID = get_tree().get_network_unique_id()
	
	# Load my player
	my_player = preload("res://entities/Player.tscn").instance()
	my_player.set_name(str(selfPeerID))
	my_player.set_network_master(selfPeerID)
	my_player.get_node("Sprite").texture = load("res://res/controller2.png")
	$Players.add_child(my_player)
	
	# Load another player
	another_player = preload("res://entities/Player.tscn").instance()
	another_player.set_name(str(Globals.player2id))
	another_player.set_network_master(Globals.player2id)
	$Players.add_child(another_player)
	
	set_positions("Start!")
	
	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring.
	# The server can call get_tree().get_rpc_sender_id() to find out who said they were done.
	rpc_id(1, "done_preconfiguring")
	
var players_done = []
remotesync func done_preconfiguring():
	var who = get_tree().get_rpc_sender_id()
	# Here are some checks you can do, for example
	assert(get_tree().is_network_server())
	assert(not who in players_done) # Was not added yet

	players_done.append(who)

	if players_done.size() == 2:
		rpc("post_configure_game")

remotesync func post_configure_game():
	# Only the server is allowed to tell a client to unpause
	if get_tree().get_rpc_sender_id() == 1:
		get_tree().set_pause(false)
		# Game starts now!


func _on_LeftScoreArea_body_entered(_body):
	rpc("set_positions", "Player 2 score!")
	$UI.rset("player2", $UI.player2 + 1)
	if $UI.player2 == 3:
		Globals.lobby.rpc("reset_game")
	

func _on_RightScoreArea_body_entered(_body):
	rpc("set_positions", "Player 1 score!")
	$UI.rset("player1", $UI.player1 + 1)
	if $UI.player1 == 3:
		Globals.lobby.rpc("reset_game")
	

remotesync func set_positions(message: String = ""):
	my_player.moving = false
	another_player.moving = false
	if is_network_master():
		my_player.position = $Player1Pos.position
		another_player.position = $Player2Pos.position
	else:
		another_player.position = $Player1Pos.position
		my_player.position = $Player2Pos.position
	$BallController.restart_ball()
	$UI.show_message(message)


func _on_OuterGameArea_body_entered(body):
	if is_instance_valid(body):
		rpc("set_positions", "Ball out!")
