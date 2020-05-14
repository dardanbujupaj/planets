extends Camera


signal body_selected
signal start_creating_planet
signal stop_creating_planet


var radius = 200 setget _set_radius
var inclination = PI / 2 setget _set_inclination
var azimuth = PI / 2

var follow_node = null


func _unhandled_input(event):
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		
	if Input.is_action_pressed("zoom_in"):
		_set_radius(radius - 5)
	if Input.is_action_pressed("zoom_out"):
		_set_radius(radius + 5)
		
	if event is InputEventMouseMotion:
		
		var motion = event as InputEventMouseMotion
		
		if Input.is_action_pressed("pan"):
			_set_inclination(inclination - 0.01 * motion.relative.y)
			azimuth -= 0.01 * motion.relative.x
	
	
	if event is InputEventMouseMotion:
		$RayCast.set_cast_to(project_local_ray_normal(event.position) * 10000)
	
	if $RayCast.get_collider() != null:
		($RayCast.get_collider() as Planet).get_node("CSGSphere").material.next_pass = preload("res://Outline.tres")
	
	if Input.is_action_just_pressed("select"):
		var collider = $RayCast.get_collider()
		
		if collider != null:
			_select_body(collider)
		else:
			var world_position = project_ray_origin(event.position) + project_ray_normal(event.position) * radius
			
			emit_signal("start_creating_planet", world_position)
			
	if Input.is_action_just_released("select") and $RayCast.get_collider() == null:
		var world_position = project_ray_origin(event.position) + project_ray_normal(event.position) * radius
		emit_signal("stop_creating_planet", world_position)


func _select_body(body: Spatial):
	follow_node = body
	emit_signal("body_selected", body)
	


func _set_inclination(new_value):
	inclination = min(PI - 0.001, max(0.001, new_value))
func _set_radius(new_value):
	radius = min(1000, max(1, new_value))


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var current_look_at = Vector3()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# calculate relative camera position from rotation an distance
	var camera_position = Vector3()
	camera_position.x = radius * sin(inclination) * cos(azimuth)
	camera_position.y = radius * sin(inclination) * sin(azimuth)
	camera_position.z = radius * cos(inclination)
	
	var up_vector = Vector3(0, 0, 1)
	
	
	
	if follow_node != null and weakref(follow_node).get_ref():
		var distance = follow_node.translation - current_look_at
		
		current_look_at += distance * 10 * delta
	
	look_at_from_position(current_look_at + camera_position, current_look_at, up_vector)
	#else:
	#	$Camera.look_at_from_position($NBodySimulation.next_center + camera_position, $NBodySimulation.next_center, up_vector)
