extends KinematicBody2D

remotesync func set_pos(pos):
	position = pos
	
var moving = false
remote var target_position = position
	
func _unhandled_input(event):
	if not is_network_master():
		return
		
	if event is InputEventScreenTouch:
		if event.pressed and event.position.distance_to(global_position) < 32.0 * scale.x:
			moving = true
		else:
			moving = false
		
	if event is InputEventScreenDrag and moving:
		target_position = event.position - position


func _physics_process(delta):
	if is_network_master():
		move_and_slide(target_position / delta)
		target_position = Vector2.ZERO
		rpc_unreliable("set_pos", position)
