extends BaseNetInput
class_name MonsterInput

#Position et radius du monsterspawner
var spawning_area_position
var spawning_area_radius

var movement = Vector3.ZERO
var target_position = Vector3.ZERO
var target_pos_bool : bool = false
var distance_approx = 0.2
var monster_position = Vector3.ZERO

@onready var sync_seed = get_parent().name.hash()
@onready var rng = RandomNumberGenerator.new()
@onready var monster = get_parent()

func _gather():
	if target_pos_bool == false:
		target_position = monster_get_next_position()
		if target_position != Vector3.ZERO:
			target_pos_bool = true
	else:
		var movement_direction = target_position - monster.global_position
		movement = movement_direction.normalized()
		var distance = movement_direction.length()
		if distance < distance_approx:
			movement = Vector3.ZERO
			target_pos_bool = false
			
func monster_get_next_position() -> Vector3:
	rng.seed = sync_seed
	var angle = rng.randf_range(0, TAU)
	var distance = rng.randf_range(-spawning_area_radius, spawning_area_radius) 
	
	var random_position = Vector3(
		spawning_area_position.x + cos(angle) * distance,
		spawning_area_position.y,
		spawning_area_position.z + sin(angle) * distance   # ⭐ ET ICI
	)
	sync_seed += rng.randf_range(-10.0, 10.0)
	return random_position
	
func get_spawning_area(area_radius, area_position):
	spawning_area_radius = area_radius
	spawning_area_position = area_position
