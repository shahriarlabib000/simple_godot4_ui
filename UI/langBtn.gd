extends Button

func _ready() -> void:
	pressed.connect(on_lang_btn_pressed)

func on_lang_btn_pressed() -> void:
	TranslationServer.set_locale(name)
