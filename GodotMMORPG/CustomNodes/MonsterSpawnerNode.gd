# MonsterSpawner.gd
@tool
class_name MonsterSpawner
extends Area3D

@onready var raycast : RayCast3D = $RayCast3D
@onready var rng = RewindableRandomNumberGenerator.new(15)
# Variables exportées (modifiables dans l'inspecteur)
@export var monster_scene: PackedScene  # Scène du monstre à spawner
@export var monster_counter: int = 3     # Nombre max de monstres
@export var MonsterPlaceHolder: Node # Node ou les monstres seront instancier
# Variables internes
var current_monsters_count: int = 0
var players_in_zone: Array = []
var spawn_timer: Timer
var random_position

func _ready() -> void:
	NetworkTime.stop()
	NetworkTime.start()
	NetworkTime.on_tick.connect(monster_spawning)
	
func monster_spawning(ticktime, tick):
	current_monsters_count = $MonsterPlaceHolder.get_child_count()
	if current_monsters_count == 0 :
		batch_monster_spawn()
	
func batch_monster_spawn():
	var collision_shape : CollisionShape3D = $CollisionShape3D
	var radius : float = 0.0
	if collision_shape.shape is SphereShape3D:
		var sphere_shape = collision_shape.shape as SphereShape3D
		radius = sphere_shape.radius

	for i in range(monster_counter):
		var monster = monster_scene.instantiate() as CharacterBody3D
		random_position = Vector3(
			rng.randf_range(-radius, radius),
			1,
			rng.randf_range(-radius, radius)
		)
		monster.name = name + str(i)
		MonsterPlaceHolder.add_child(monster)
		monster.set_multiplayer_authority(1)
		monster.global_position = global_position + random_position
		
		
	
