extends Area2D

class_name Caixa

# Caixa de entrega. Um macaco encosta, aperta acao e ela vai para cima da cabeca dele.

# Caixa pesada: so quem tem "forte" ligado (a Nina) consegue pegar.
@export var pesada: bool = false

# Macaco que esta carregando a caixa agora (null = esta no chao).
var carregador = null

func _physics_process(_delta: float) -> void:
	if carregador != null:
		# Acompanha o macaco, em cima da cabeca dele (o desenho do macaco
		# vai ate 16 px acima do centro; a caixa tem 12 px, entao o centro dela fica em -22).
		# Multiplica pela escala porque a Nina e maior (scale 1.5).
		global_position = carregador.global_position + Vector2(0, -22 * carregador.scale.y)

# Chamada pelo Player quando ele aperta acao encostado na caixa.
func interagir(macaco) -> void:
	if carregador != null or macaco.caixa_carregada != null:
		return  # alguem ja esta com esta caixa, ou o macaco ja esta com outra
	if pesada and not macaco.forte:
		return  # pesada demais para o Pipo
	carregador = macaco
	macaco.caixa_carregada = self

# Larga a caixa no chao, nos pes de quem estava carregando.
func soltar() -> void:
	global_position = carregador.global_position + Vector2(0, 8 * carregador.scale.y - 6)
	carregador.caixa_carregada = null
	carregador = null

# Chamada pela casa quando a entrega da certo.
func entregar() -> void:
	carregador.caixa_carregada = null
	queue_free()
