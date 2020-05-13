extends Spatial
class_name Planet

export var mass: float = 1.00 setget _set_mass
export var velocity: Vector3 = Vector3()
export var color: Color = Color.white setget _set_color


const DENSITY = 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape.shape = $CollisionShape.shape.duplicate()
	_set_color(color)
	_set_mass(mass)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _set_mass(new_mass: float):
	mass = new_mass
	if has_node("CSGSphere"):
		var radius = pow(3 * new_mass / 4 * PI * DENSITY, 1/3.0)

		$CSGSphere.radius = radius
		$CollisionShape.shape.radius = radius
	
func _set_color(new_color: Color):
	color = new_color
	
	if has_node("CSGSphere"):
		var material = SpatialMaterial.new()
		material.albedo_color = new_color
		$CSGSphere.material = material




func _on_Planet_area_entered(area):
	if area.mass < mass:
		var new_mass = mass + area.mass
		velocity = (area.velocity * area.mass + velocity * mass) / new_mass
		_set_mass(new_mass)
		area.queue_free()
