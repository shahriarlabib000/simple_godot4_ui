extends Button

signal lang_pressed(lang:String)
func _ready() -> void:
	pressed.connect(on_lang_btn_pressed)

func on_lang_btn_pressed() -> void:
	lang_pressed.emit(name)
	#TranslationServer.set_locale(name)
