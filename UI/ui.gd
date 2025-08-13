extends Control

# signal defs
signal play_pressed
signal  language_selected(language: String)
signal  sound_toggled(toggled_on: bool)
signal gameplay_stopped
signal gameplay_resumed
signal return_to_menu

@onready var mainMenu := $mainMenu
@onready var settingsMenu := $settingsMenu
@onready var languageOptions := $langOptions
@onready var inGameUi := $inGameUi
@onready var backBtn := %back
@onready var resumeBtn := %resume
@onready var mainMenuReturn := %mainMenuReturn

@export var move_dist:= 5000
@export var timespan := 0.3

var sound_allowed := true
enum anim_direction {LEFT, RIGHT, UP, DOWN}

#builtin funcs
func _ready() -> void:
	%sound.button_pressed = sound_allowed
	hide_all_ui()
	show_and_grab_child_focus(mainMenu)
	
	for child:Button in get_tree().get_nodes_in_group("lang_btn"):
		child.lang_pressed.connect(_language_selected)
	
	for node:Button in get_tree().get_nodes_in_group("ui_btn"):
		node.pressed.connect(_ui_btn_pressed)


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_anything_pressed():
		var btn :Control = get_viewport().gui_get_focus_owner()
		if btn:
			var parent :Control = btn.get_parent()
			var next_btn :Control = null
			var idx :int = btn.get_index()
			if event.is_action_pressed("ui_up"):
				if parent.get_child_count()-1 >= idx-1:
					next_btn = parent.get_child(idx-1)
				else:
					next_btn = parent.get_child(-1)
			elif event.is_action_pressed("ui_down"):
				if idx+1 <= parent.get_child_count()-1:
					next_btn = parent.get_child(idx+1)
				else:
					next_btn = parent.get_child(0)
			if next_btn:
				next_btn.grab_click_focus()
				next_btn.grab_focus()

#declared funcs
func show_and_grab_child_focus(node:Control) -> void:
	node.show()
	if DisplayServer.has_hardware_keyboard():
		if node.visible:
			if node.get_child_count() > 0:
				var child := node.get_child(0)
				if child is Control:
					child.grab_click_focus()
					child.grab_focus()
		else:
			get_viewport().gui_release_focus()

func hide_all_ui() -> void:
	for child in get_children():
		if child is Control:
			child.hide()

#animation funcs
func slide_in(ui:Control, dir:anim_direction) -> void:
	show_and_grab_child_focus(ui)
	var tween: Tween = create_tween()
	var move_val := Vector2.ZERO
	match dir:
		anim_direction.LEFT:
			move_val = Vector2(move_dist, 0)
		anim_direction.RIGHT:
			move_val = Vector2(-move_dist, 0)
		anim_direction.UP:
			move_val = Vector2(0, move_dist)
		anim_direction.DOWN:
			move_val = Vector2(0, -move_dist)
	
	ui.position -= move_val
	tween.tween_property(ui, "position", ui.position + move_val, timespan)
	await tween.finished

func slide_out(ui:Control, dir:anim_direction) -> void:
	var pos := ui.position
	var tween: Tween = create_tween()
	var move_val:Vector2 = Vector2.ZERO
	match dir:
		anim_direction.LEFT:
			move_val = Vector2(-move_dist, 0)
		anim_direction.RIGHT:
			move_val = Vector2(move_dist, 0)
		anim_direction.UP:
			move_val = Vector2(0, -move_dist)
		anim_direction.DOWN:
			move_val = Vector2(0, move_dist)
			
	tween.tween_property(ui, "position", ui.position + move_val, timespan)
	await tween.finished
	ui.hide()
	ui.position = pos

func bring_settings() -> void:
	slide_out(mainMenu, anim_direction.LEFT)
	slide_in(settingsMenu, anim_direction.RIGHT)

#signals
func _on_languageMenuBtn_pressed() -> void:
	slide_out(settingsMenu, anim_direction.LEFT)
	slide_in(languageOptions, anim_direction.UP)

func _language_selected(lang: String) -> void:
	TranslationServer.set_locale(lang)
	language_selected.emit(lang)
	slide_out(languageOptions, anim_direction.DOWN)
	slide_in(settingsMenu, anim_direction.LEFT)

func _on_play_pressed() -> void:
	play_pressed.emit()
	slide_out(mainMenu,anim_direction.LEFT)
	inGameUi.show()

func _on_settings_pressed() -> void:
	backBtn.show()
	resumeBtn.hide()
	mainMenuReturn.hide()
	bring_settings()

func _on_mainMenuReturn_pressed() -> void:
	return_to_menu.emit()
	gameplay_stopped.emit()
	inGameUi.hide()
	mainMenuReturn.hide()
	resumeBtn.hide()
	backBtn.show()
	slide_out(settingsMenu,anim_direction.LEFT)
	slide_in(mainMenu,anim_direction.RIGHT)

func _on_in_game_settings_pressed() -> void:
	gameplay_stopped.emit()
	backBtn.hide()
	resumeBtn.show()
	mainMenuReturn.show()
	bring_settings()

func _on_resume_pressed() -> void:
	gameplay_resumed.emit()
	slide_out(settingsMenu,anim_direction.RIGHT)

func _on_back_pressed() -> void:
	slide_out(settingsMenu, anim_direction.RIGHT)
	slide_in(mainMenu, anim_direction.LEFT)

func _on_sounds_toggled(toggled_on: bool) -> void:
	sound_toggled.emit(toggled_on)
	sound_allowed = toggled_on
	if toggled_on:
		%sound.icon = load("res://UI/icons/sound.svg")
	else:
		%sound.icon = load("res://UI/icons/mute.svg")

func _ui_btn_pressed() -> void:
	if sound_allowed:
		$btnSound.play()
