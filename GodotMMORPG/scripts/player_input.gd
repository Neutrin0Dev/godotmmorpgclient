extends BaseNetInput
class_name PlayerInput

var movement = Vector3.ZERO
var confidence: float = 1.
var input_jump = 0
@onready var _rollback_synchronizer := $"../RollbackSynchronizer" as RollbackSynchronizer

func _ready() -> void:
	super()
	#Predict on `after_prepare_tick`
	NetworkRollback.after_prepare_tick.connect(_predict)

func _gather():		
	movement = Vector3(
	Input.get_axis("ui_left", "ui_right"),
	Input.get_axis("ui_up","ui_down"),
	Input.get_action_strength("ui_accept"),
	)

func _process(delta: float) -> void:
	input_jump = Input.get_action_strength("ui_accept")

func _predict(_t):
	if not _rollback_synchronizer.is_predicting():
		# Not predicting, nothing to do
		confidence = 1.
		return

	if not _rollback_synchronizer.has_input():
	# Can't predict without input
		confidence = 0.
		return

	# Decay input over a short time
	var decay_time := NetworkTime.seconds_to_ticks(.15)
	var input_age := _rollback_synchronizer.get_input_age()

	# **ALWAYS** cast either side to float, otherwise the integer-integer 
	# division yields either 1 or 0 confidence
	confidence = input_age / float(decay_time)
	confidence = clampf(1. - confidence, 0., 1.)

	# Modulate input based on confidence
	movement *= confidence
