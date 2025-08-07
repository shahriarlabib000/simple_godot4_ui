extends Control

@onready var btns := $btns
@onready var settingsMenu := $settingsMenu
@export var move_dist:= 5000
@export var timespan := 0.3

func _on_play_pressed() -> void:
	slide_in_ui_left(btns)

func _on_settings_pressed() -> void:
	settingsMenu.show()
	slide_out_ui_left(btns)
	slide_in_ui_left(settingsMenu)


func _on_back_pressed() -> void:
	slide_out_ui_left(settingsMenu)
	slide_in_ui_left(btns)
	

func slide_in_ui_left(ui:Control) -> void:
	ui.show()
	var tween:Tween = create_tween()
	ui.position.x -= move_dist
	tween.tween_property(ui,"position",ui.position + Vector2(move_dist,0),timespan)
	await tween.finished
	
	
func slide_out_ui_left(ui:Control) -> void:
	var pos:= ui.position
	var tween:Tween = create_tween()
	tween.tween_property(ui,"position",ui.position - Vector2(move_dist,0),timespan)
	await tween.finished
	ui.hide()
	ui.position = pos


func _on_sounds_toggled(toggled_on: bool) -> void:
	if toggled_on:
		%sounds.icon = load("res://icons/sound.svg")
	else:
		%sounds.icon = load("res://icons/mute.svg")
