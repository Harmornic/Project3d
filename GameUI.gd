extends Control

@onready var coinsLabel = $CoinsLabel
@onready var game_manager = get_tree().get_root().get_node("World2/GameManager")

func _process(_delta):
	if game_manager:
		coinsLabel.text = "x %d" % game_manager.score
