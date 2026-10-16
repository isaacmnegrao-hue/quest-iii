extends Node

@export var total_entregas: int = 5
@export var tempo_total: int = 90

var entregas = 0
var tempo_restante = 0

@onready var label_entregas: Label = $HUD/LabelEntregas
@onready var label_tempo: Label = $HUD/LabelTempo
@onready var timer: Timer = $Timer

func _ready() -> void:
	tempo_restante = tempo_total
	atualizar_hud()
	timer.start()

func _on_timer_timeout() -> void:
	tempo_restante -= 1
	atualizar_hud()
	if tempo_restante <= 0:
		get_tree().change_scene_to_file("res://Cenas/derrota.tscn")

func entregar() -> void:
	entregas += 1
	atualizar_hud()
	if entregas >= total_entregas:
		get_tree().change_scene_to_file.call_deferred("res://Cenas/vitoria.tscn")

func atualizar_hud() -> void:
	label_entregas.text = "Caixas: %d/%d" % [entregas, total_entregas]
	label_tempo.text = "Tempo: %d" % tempo_restante
