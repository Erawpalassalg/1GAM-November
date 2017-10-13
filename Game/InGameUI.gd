extends Control

onready var dialog_panel = get_node("DialogPanel")
onready var answers_container = dialog_panel.get_node("AnswersContainer")
onready var body_text_window = dialog_panel.get_node("BodyTextWindow")

var clickable_label_class = preload("res://ClickableText.tscn")

func _ready():
	Player.ui = self
	
	# Connect to player
	Player.character.connect("can_interact", self, "show_interaction_button")
	Player.character.connect("cant_interact", self, "hide_interaction_button")
	
	# Connect the UI to every bodies in the scene
	for body in get_tree().get_nodes_in_group("body"):
		body.connect("say", self, "show_dialog")
		body.connect("stop_dialog", self, "hide_dialog")
	
	# Assign the shortcut "E" to the interaction action
	var hotkey = InputEvent()
	hotkey.type = InputEvent.KEY
	hotkey.scancode = KEY_E
	var sc = ShortCut.new()
	sc.set_shortcut(hotkey)
	get_node("InteractionButton").set_shortcut(sc)
	get_node("InteractionButton").get_popup().set_light_mask(get_node("InteractionButton").get_light_mask())
	
	set_process_input(true)

func show_dialog(body, text, options):
	# Hide the interaction button
	get_node("InteractionButton").hide()
	
	# Set the new speaker's text
	body_text_window.set_text(text)
	
	# Remove old answers
	clear_answers()
	
	# Add new answers
	for option in options:
		var cl = clickable_label_class.instance()
		cl.add_to_group("dialog option")
		cl.set_speaker(body)
		cl.set_option(option)
		answers_container.add_child(cl)
	dialog_panel.show()

func hide_dialog():
	# Show the interaction button again
	show_interaction_button()
	clear_answers()
	dialog_panel.hide()

func clear_answers():
	for answer in answers_container.get_children():
		answer.queue_free()

func show_interaction_button():
	if !Player.character.is_disabled():
		get_node("InteractionButton").show()

func hide_interaction_button():
	get_node("InteractionButton").hide()
	get_node("InteractionButton").get_popup().hide()
	get_node("InteractionButton").get_popup().clear()

func _on_InteractionButton_pressed():
	var popup = get_node("InteractionButton").get_popup()
	popup.clear()
	for i in range(Player.character.interaction_possibilities.size()):
		var body = Player.character.interaction_possibilities[i]
		var b = Button.new()
		popup.add_item(body.get_name(), i)
		popup.connect("item_pressed", self, "send_start_interaction_message")
	popup.show()
	popup.set_global_pos(get_global_mouse_pos())

func send_start_interaction_message(id):
	Player.character.interaction_possibilities[id].start_dialog()