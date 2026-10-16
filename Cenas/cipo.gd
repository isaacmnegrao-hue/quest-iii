extends Area2D

# Cipo do andar 1. Esta Area2D (o "no") fica em cima do galho.
# Quem esta la em cima aperta acao no no e o cipo desce ate o chao.
# Depois, quem esta embaixo sobe segurando o botao de pular.
# A area da corda (Corda) vai do chao ate 4 pixels ABAIXO do topo do galho.

# Empurrao para cima quando o macaco sai da corda pelo topo,
# para os pes passarem do galho e ele pousar em cima.
@export var impulso_saida: float = -180.0

var solto = false

func _ready() -> void:
	$Linha.visible = false
	$Corda.monitoring = false   # enquanto o cipo nao desce, nao da para subir

# Chamada pelo Player quando ele aperta acao encostado no no.
func interagir(_macaco) -> void:
	if solto:
		return
	solto = true
	$Linha.visible = true
	# set_deferred: ligar a deteccao no meio do calculo da fisica da erro,
	# entao o Godot liga no fim do frame.
	$Corda.set_deferred("monitoring", true)

func _on_corda_body_entered(body: Node2D) -> void:
	if body is Player:
		body.cipo_atual = self

func _on_corda_body_exited(body: Node2D) -> void:
	if body is Player and body.cipo_atual == self:
		body.cipo_atual = null
		if body.velocity.y < 0:
			# Saiu por cima (estava subindo): empurrao final.
			body.velocity.y = impulso_saida
