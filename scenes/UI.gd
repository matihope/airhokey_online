extends Control

var message_alpha = 1.0
var fade_message = false
remotesync var player1 = 0 setget set_player1
remotesync var player2 = 0 setget set_player2

func show_message(message):
	$Message/MessageTimer.stop()
	$Message/Label.text = message
	$Message/MessageTimer.start()
	$Message.show()
	message_alpha = 1.0
	
func set_player1(value):
	player1 = value
	$Player1Score.text = String(player1)
	
func set_player2(value):
	player2 = value
	$Player2Score.text = String(player2)

func _on_MessageTimer_timeout():
	fade_message = true

func _process(delta):
	if fade_message:
		message_alpha -= delta

		if message_alpha <= 0:
			fade_message = false
			message_alpha = 1.0
			$Message.hide()

		$Message.modulate.a = message_alpha
