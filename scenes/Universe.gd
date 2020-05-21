extends Spatial

const colors = [
	Color.aquamarine,
	Color.white,
	Color.beige,
	Color.lightgray,
	Color.lightsteelblue
]

const CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


func generate_planet_name() -> String:
	var planet_name = ""
	for i in range(randi() % 3 + 2):
		planet_name += CHARACTERS[randi() % len(CHARACTERS)]
	planet_name += "-"
	for i in range(randi() % 2 + 4):
		planet_name += str(randi() % 10)
	return planet_name
		

func _unhandled_key_input(event):
	if Input.is_action_just_pressed("screenshot"):
		var image = get_viewport().get_texture().get_data()
		image.flip_y()
		image.save_png("user://test.png")
		
	if Input.is_action_just_pressed("save"):
		save_file()
	if Input.is_action_just_pressed("load"):
		load_file()

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

	
	for _i in range(50):
		var planet = preload("res://scenes/Planet.tscn").instance()
		planet.translation = Vector3(rand_range(-100, 100), rand_range(-100, 100), rand_range(-100, 100))
		planet.velocity = Vector3(rand_range(-20, 20), rand_range(-20, 20), rand_range(-20, 20))
		planet.mass = pow(rand_range(0.1, 10), 2)
		planet.color = colors[randi() % len(colors)]
		planet.id = generate_planet_name()
		
		$NBodySimulation3D.add_child(planet)


func _process(delta):
	var num_planets = $NBodySimulation3D.get_child_count()
	$PanelContainer/VBoxContainer/Label.text = "%d %s" % [num_planets, tr("PLANET" if num_planets == 1 else "PLANETS")]


func _on_Camera_body_selected(body):
	$PlanetDetails.planet = body
	$PlanetDetails.show()


var start_position
var start_time
func _on_Camera_start_creating_planet(position):
	start_position = position
	start_time = OS.get_ticks_msec()


func _on_Camera_stop_creating_planet(position):
	if start_position != null and OS.get_ticks_msec() - start_time > 150:
		
		
		var velocity = position - start_position
		var mass = (OS.get_ticks_msec() - start_time) / 5.0
		var planet = preload("res://scenes/Planet.tscn").instance()
		planet.translation = position
		planet.mass = mass
		planet.velocity = velocity
		planet.color = colors[randi() % len(colors)]
		planet.id = generate_planet_name()
		$NBodySimulation3D.add_child(planet)
		
	start_position = null
	start_time = null
	

func save_file():
	var save_dict = {}
	
	save_dict['simulation'] = {
		'G': $NBodySimulation3D.G,
		'theta': $NBodySimulation3D.theta,
		'time_multiplier': $NBodySimulation3D.time_multiplier,
	}
	
	var planets = []
	
	for planet in $NBodySimulation3D.get_children():
		planets.append(planet.save_dict())
			
	save_dict['planets'] = planets
	
	# save camera settings
	save_dict['camera'] = $Camera.save_dict()
	
	var file = File.new()
	file.open("user://save.json", File.WRITE)
	file.store_line(to_json(save_dict))
	
func load_file():
	get_tree().paused = true
	var file = File.new()
	file.open("user://save.json", File.READ)
	
	for child in $NBodySimulation3D.get_children():
		child.free()
		
	var dict = parse_json(file.get_line())
	
	
	for key in dict["simulation"]:
		$NBodySimulation3D.set(key, dict["simulation"][key])
	
	# load planets
	for planet_dict in dict["planets"]:
		var planet = preload("res://scenes/Planet.tscn").instance()
		planet.load_dict(planet_dict)
		
		$NBodySimulation3D.add_child(planet)
	
	# load camera settings
	$Camera.load_dict(dict['camera'])
	
	
	get_tree().paused = false
