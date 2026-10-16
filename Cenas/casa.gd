extends Area2D

# QUEST III: a entrega e da DUPLA.
# A casa so aceita a caixa quando quem carrega esta na porta E o outro macaco tambem.

@export var precisa_dos_dois: bool = true

var entregue = false

func _physics_process(_delta: float) -> void:
	if entregue:
		return

	var macacos = []
	for body in get_overlapping_bodies():
		if body is Player:
			macacos.append(body)

	for macaco in macacos:
		if macaco.caixa_carregada != null:
			if precisa_dos_dois and macacos.size() < 2:
				$Aviso.visible = true   # "Chame o amigo!"
				return
			_entregar(macaco)
			return

	$Aviso.visible = false

func _entregar(macaco) -> void:
	entregue = true
	macaco.caixa_carregada.entregar()
	$Aviso.visible = false
	$Sprite.texture = preload("res://Sprites/casa_entregue.png")
	$Check.visible = true
	get_tree().current_scene.entregar()
