extends CharacterBody2D

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

#initalising Player class (inputs, movement)
@export var _speed: float = 300.0
@export var _jump_velocity: float = -400.0   # was -400, bigger negative = higher jump
@export var _gravity: float = 980.0
var _inventory: Inventory = Inventory.new()
#player inventory

func _ready() -> void:
	z_index = 10 #its layer level relative to others (z being the cooardinate)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	_handle_jump()
	move_and_slide()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += _gravity * delta

func _handle_movement() -> void:
	var direction: float = 0.0
	if Input.is_action_pressed("ui_right"):
		direction += 1.0
	if Input.is_action_pressed("ui_left"):
		direction -= 1.0
	velocity.x = direction * _speed

	if direction != 0:
		_sprite.play("walk")
		_sprite.flip_h = direction < 0
	else:
		_sprite.stop()
	
func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = _jump_velocity
		AudioManager.play_sfx("jump")
	
		
#collecting items code
func collect_item(item_type: String) -> bool:
	'called by an Item when player walks over it'
	var success: bool = _inventory.add_item(item_type)
	if success:
		AudioManager.play_sfx("collect")
	return success
	
func get_inventory() -> Inventory:
	return _inventory
