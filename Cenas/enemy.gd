extends Area2D

class_name Enemy

@export var h_speed:float = 20.0
@export var v_speed:float = 100.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# Fica true quando o inimigo encosta numa plataforma pela primeira vez.
var no_chao = false


func _physics_process(delta: float) -> void:
	var passo = -h_speed * delta
	position.x += passo
	ray_cast_2d.force_raycast_update()

	if ray_cast_2d.is_colliding():
		no_chao = true
	elif no_chao:
		# Chegou na beirada da plataforma: desfaz o passo e vira para o outro lado.
		position.x -= passo
		h_speed = -h_speed
		animated_sprite_2d.flip_h = not animated_sprite_2d.flip_h
	else:
		# Ainda nao tocou o chao (nasceu no ar): cai.
		position.y += v_speed * delta

func _die():
	h_speed = 0
	v_speed = 0
	animated_sprite_2d.play("dead")


func _die_from_hit():
	h_speed = 0
	v_speed = 0
	rotation_degrees = 180

	var dead_tween = get_tree().create_tween()
	dead_tween.tween_property(self, "position", position + Vector2(0, -25), 0.2)
	dead_tween.chain().tween_property(self, "position", position + Vector2(0, 500), 4)

	set_collision_layer_value(3, false)
	set_collision_layer_value(1, false)
