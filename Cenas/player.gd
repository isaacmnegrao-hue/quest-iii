extends CharacterBody2D

class_name Player

# QUEST III: o mesmo script serve para os dois macacos (Pipo e Nina).
# O que muda entre eles sao os valores no Inspector de cada instancia.

@export_group("Controles")
# Prefixo das acoes do Mapa de Entrada: "p1" (A/D, W, S) ou "p2" (setas).
# O script monta o nome da acao juntando textos: "p1" + "_jump" = "p1_jump".
@export var prefixo: String = "p1"

@export_group("Locomotion")
@export var speed: float = 20.0
@export var jump_velocity: float = -350.0
@export var run_speed_damping: float = 0.5
@export var desaceleracao: float = 1500.0

@export_group("Colaboracao")
# true so na Nina: a cabeca dela vira uma plataforma onde o Pipo pode subir.
@export var cabeca_e_plataforma: bool = false
# true so na Nina: so ela consegue pegar caixa pesada.
@export var forte: bool = false
# Velocidade para subir no cipo (segurando o botao de pular).
@export var velocidade_subida: float = 90.0
# Cor para diferenciar os dois enquanto os assets novos nao chegam.
@export var cor: Color = Color.WHITE

@export_group("Stomping Enemies")
@export var min_stomp_degree = 35
@export var max_stomp_degree = 145
@export var stomp_y_velocity = -150

@export_group("Dano")
@export var tempo_atravessando: float = 0.45
@export var tempo_invencivel: float = 1.2

var invencivel = false
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Cipo em que o macaco esta encostado agora (null = nenhum). Quem preenche e o proprio cipo.
var cipo_atual = null
# Caixa que o macaco esta carregando agora (null = maos vazias).
var caixa_carregada = null

func _ready() -> void:
	# O grupo deixa a camera achar os dois macacos sem precisar arrastar no Inspector.
	add_to_group("jogadores")
	$AnimatedSprite2D.self_modulate = cor

	if cabeca_e_plataforma:
		# A cabeca e um corpo separado, filho do macaco. Sem esta linha,
		# o proprio macaco colidiria com a propria cabeca.
		add_collision_exception_with($Cabeca)
	else:
		$Cabeca.queue_free()

func _physics_process(delta: float) -> void:

	# --- Vertical: cipo ou gravidade ---
	if cipo_atual != null:
		if Input.is_action_pressed(prefixo + "_jump"):
			velocity.y = -velocidade_subida   # segurando pular: sobe
		else:
			velocity.y = 0                    # soltou: fica pendurado
	elif not is_on_floor():
		velocity.y += gravity * delta

	# --- Pulo (so fora do cipo, porque no cipo o mesmo botao serve para subir) ---
	if cipo_atual == null:
		if Input.is_action_just_pressed(prefixo + "_jump") and is_on_floor():
			velocity.y = jump_velocity

		if Input.is_action_just_released(prefixo + "_jump") and velocity.y < 0:
			velocity.y *= 0.5

	# --- Acao: pegar/soltar caixa, puxar o no do cipo ---
	if Input.is_action_just_pressed(prefixo + "_action"):
		_interagir()

	# --- Horizontal (igual a QUEST II) ---
	var direction = Input.get_axis(prefixo + "_left", prefixo + "_right")

	if direction:
		velocity.x = lerp(velocity.x, speed * direction, run_speed_damping * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, desaceleracao * delta)

	$AnimatedSprite2D._trigger_animation(velocity, direction)

	move_and_slide()

# Procura algo "usavel" encostado no macaco (caixa, no do cipo...).
# Qualquer Area2D que tenha uma funcao interagir() serve: assim, coisas novas
# (alavanca do andar 2, por exemplo) funcionam sem mexer neste script.
func _interagir() -> void:
	for area in $Area2D.get_overlapping_areas():
		if area != caixa_carregada and area.has_method("interagir"):
			area.interagir(self)
			return

	# Nada para usar por perto: se estiver carregando uma caixa, solta no chao.
	if caixa_carregada != null and is_on_floor():
		caixa_carregada.soltar()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if not (area is Enemy) or invencivel:
		return

	# Espinho nao pode ser pisado: encostar nele de qualquer jeito machuca.
	if area is Espinho:
		_levar_dano()
		return

	var angle = rad_to_deg(position.angle_to_point((area as Enemy).position))

	if angle > min_stomp_degree and angle < max_stomp_degree:
		(area as Enemy)._die()
		velocity.y = stomp_y_velocity
	else:
		_levar_dano()

# (QUEST II) Ao levar dano, o macaquinho atravessa as plataformas por um instante
# e fica piscando. Na QUEST III isso vai virar a teia (andar 3).
func _levar_dano():
	invencivel = true
	velocity = Vector2.ZERO
	set_collision_mask_value(5, false)   # camada 5 = plataformas

	var pisca = create_tween().set_loops()
	pisca.tween_property(self, "modulate:a", 0.3, 0.1)
	pisca.tween_property(self, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(tempo_atravessando).timeout
	set_collision_mask_value(5, true)

	await get_tree().create_timer(tempo_invencivel).timeout
	pisca.kill()
	modulate.a = 1.0
	invencivel = false
