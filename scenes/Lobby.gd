extends Control

var peer = null

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	Globals.lobby = self

func _player_connected(id):
	Globals.player2id = id
	# Load world
	var world = load("res://scenes/Game.tscn").instance()
	get_node("/root").add_child(world)

func _player_disconnected(id):
	reset_game()

func _on_ButtonHost_pressed():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(6969, 2)
	get_tree().network_peer = peer
	$WaitingForConnections.show()
	$Connect.hide()

func _on_ButtonJoin_pressed():
	peer = NetworkedMultiplayerENet.new()
	var server_ip = $Connect/ServerIpInput.text
	if server_ip:
		peer.create_client(server_ip, 6969)
		get_tree().network_peer = peer
		$WaitingForHost.show()
		$Connect.hide()
	
func _server_disconnected():
	reset_game()
	
remotesync func reset_game():
	$Connect.show()
	$WaitingForConnections.hide()
	$WaitingForHost.hide()
	get_node("/root/Game").queue_free()
	get_tree().network_peer = null
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if is_network_master():
				peer.disconnect_peer(Globals.player2id)
		get_tree().quit()
	
