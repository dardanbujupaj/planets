extends PanelContainer

var planet: Planet setget _set_planet


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if weakref(planet).get_ref():
		if planet.mass != $VBoxContainer/Mass.value:
			$VBoxContainer/Mass.value = planet.mass
			$VBoxContainer/Mass/Label.text = "%0.2f" % planet.mass
	else:
		planet = null
		hide()


func _set_planet(new_planet: Planet):
	planet = new_planet
	$VBoxContainer/Name.text = planet.id
	$VBoxContainer/Color.color = planet.color
	


func _unhandled_input(event):
	if event is InputEventMouseButton:
		$VBoxContainer/Mass.release_focus()
		$VBoxContainer/Name.release_focus()
		$VBoxContainer/Color.release_focus()


func _on_Mass_value_changed(value):
	if weakref(planet).get_ref():
		planet.mass = value
	
	$VBoxContainer/Mass/Label.text = "%0.2f" % planet.mass
	$VBoxContainer/Mass.release_focus()


func _on_Color_color_changed(color):
	if weakref(planet).get_ref():
		planet.color = color
	
	$VBoxContainer/Color.release_focus()
	

func _on_Name_text_changed(new_text):
	
	if weakref(planet).get_ref():
		planet.id = new_text
