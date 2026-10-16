extends Enemy

class_name Passaro

@export var limite_esquerdo: float = -190.0  # ate onde ele voa para a esquerda
@export var limite_direito: float = 190.0    # ate onde ele voa para a direita
@export var amplitude: float = 6.0           # altura da "onda" do voo
@export var gravidade_queda: float = 600.0   # aceleracao da queda depois de morto

var base_y = 0.0
var tempo = 0.0
var vivo = true
var caindo = false
var velocidade_queda = 0.0

func _ready() -> void:
	base_y = position.y

func _physics_process(delta: float) -> void:
	if caindo:
		_cair(delta)
		return
	if not vivo:
		return
	tempo += delta
	position.x += h_speed * delta
	if position.x < limite_esquerdo:
		h_speed = abs(h_speed)
	elif position.x > limite_direito:
		h_speed = -abs(h_speed)
	animated_sprite_2d.flip_h = h_speed < 0
	position.y = base_y + sin(tempo * 4.0) * amplitude

# Depois de pisado: cai ate encostar num galho ou no chao e fica parado la.
func _cair(delta: float) -> void:
	velocidade_queda = min(velocidade_queda + gravidade_queda * delta, 300.0)
	position.y += velocidade_queda * delta
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		position.y = ray_cast_2d.get_collision_point().y - 2
		caindo = false

func _die():
	vivo = false
	caindo = true
	set_collision_layer_value(3, false)    # nao machuca mais
	animated_sprite_2d.stop()
	animated_sprite_2d.flip_v = true        # de barriga para cima
	ray_cast_2d.enabled = true              # passa a procurar o chao
