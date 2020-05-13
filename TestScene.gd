extends Spatial

const colors = [
	Color.aquamarine,
	Color.white,
	Color.beige,
	Color.lightgray,
	Color.lightsteelblue
]

var follow_node = null

enum ContextId {
	FOLLOW,
	DELETE,
}


func _unhandled_input(event):
	
	if Input.is_action_pressed("zoom_in"):
		_set_radius(radius - 5)
	if Input.is_action_pressed("zoom_out"):
		_set_radius(radius + 5)
	
	if event is InputEventMouseMotion:
		
		var motion = event as InputEventMouseMotion
		$Camera/RayCast.set_cast_to($Camera.project_local_ray_normal(event.position) * 10000)
		
		
		if Input.is_action_pressed("pan"):
			_set_inclination(inclination - 0.01 * motion.relative.y)
			azimuth -= 0.01 * motion.relative.x
		
	if Input.is_action_just_pressed("select"):
		var collider = $Camera/RayCast.get_collider()
		if collider != null:
			
			print(collider)
			
			var context = PopupMenu.new()
			context.set_hide_on_checkable_item_selection(false)
			
			context.add_check_item(tr("FOLLOW"), ContextId.FOLLOW)
			context.set_item_checked(context.get_item_index(ContextId.FOLLOW), collider != null and follow_node == collider)
			
			context.add_item(tr("DELETE"), ContextId.DELETE)
			
			context.connect("id_pressed", self, "_handle_context_pressed", [collider, context])
			
			add_child(context)
			context.rect_position = get_viewport().get_mouse_position()
			context.popup()

func _handle_context_pressed(id, body, context: PopupMenu):
	var index = context.get_item_index(id)
	match id:
		ContextId.DELETE:
			body.queue_free()
		ContextId.FOLLOW:
			context.toggle_item_checked(index)
			if context.is_item_checked(index):
				follow_node = body
			else:
				follow_node = null
		
	context.queue_free()
	

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for _i in range(50):
		var planet = preload("res://Planet.tscn").instance()
		planet.translation = Vector3(rand_range(-100, 100), rand_range(-100, 100), rand_range(-100, 100))
		planet.velocity = Vector3(rand_range(-20, 20), rand_range(-20, 20), rand_range(-20, 20))
		planet.mass = pow(rand_range(0.1, 10), 2)
		planet.color = colors[randi() % len(colors)]
		
		$NBodySimulation.add_child(planet)

var radius = 200 setget _set_radius
var inclination = PI / 2 setget _set_inclination
var azimuth = PI / 2

func _set_inclination(new_value):
	inclination = min(PI - 0.001, max(0.001, new_value))
func _set_radius(new_value):
	radius = min(1000, max(1, new_value))

func _process(delta):
	var num_planets = $NBodySimulation.get_child_count()
	$PanelContainer/VBoxContainer/Label.text = "%d %s" % [num_planets, tr("PLANET" if num_planets == 1 else "PLANETS")]
	
	# calculate relative camera position from rotation an distance
	var camera_position = Vector3()
	camera_position.x = radius * sin(inclination) * cos(azimuth)
	camera_position.y = radius * sin(inclination) * sin(azimuth)
	camera_position.z = radius * cos(inclination)
	
	var up_vector = Vector3(0, 0, 1)
	
	if follow_node != null and weakref(follow_node).get_ref():
		$Camera.look_at_from_position(follow_node.translation + camera_position, follow_node.translation, up_vector)
	else:
		$Camera.look_at_from_position($NBodySimulation.next_center + camera_position, $NBodySimulation.next_center, up_vector)
		


func _on_Pause_pressed():
	get_tree().paused = !get_tree().paused
