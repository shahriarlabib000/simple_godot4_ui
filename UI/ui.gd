extends Control

@onready var btns := $btns
@onready var settingsMenu := $settingsMenu
@onready var languageOptions := $langOptions
@export var move_dist:= 5000
@export var timespan := 0.3
var sound_allowed :bool = true

func _ready() -> void:
	%sound.button_pressed = sound_allowed
	hide_all_ui()
	$btns.show()
	
	for child:Button in languageOptions.get_children():
		child.pressed.connect(language_selected)
	
	for node:Button in get_tree().get_nodes_in_group("ui_btn"):
		node.pressed.connect(_play_ui_btn_sound)

func hide_all_ui() -> void:
	for child in get_children():
		if child is Control:
			child.hide()

func _on_languageMenuBtn_pressed() -> void:
	slide_out_ui_left(settingsMenu)
	slide_in_ui_left(languageOptions)
	
func language_selected() -> void:
	slide_out_ui_left(languageOptions)
	slide_in_ui_left(settingsMenu)

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
	sound_allowed = toggled_on
	if toggled_on:
		%sound.icon = load("res://UI/icons/sound.svg")
	else:
		%sound.icon = load("res://UI/icons/mute.svg")

func _play_ui_btn_sound() -> void:
	if sound_allowed:
		$btnSound.play()
