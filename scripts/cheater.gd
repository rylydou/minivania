class_name Cheater extends CanvasLayer

var menu_open := false

var commands: Dictionary

func _ready() -> void:
	update_menu()
	
	register_command('quit', func(): get_tree().quit())
	register_command('reload', func(): get_tree().reload_current_scene())
	register_command('upgrade', func(upgrade_name: String): Upgrades.set_upgrade(upgrade_name, true))
	register_command('downgrade', func(upgrade_name: String): Upgrades.set_upgrade(upgrade_name, false))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed('cheater'):
		menu_open = not menu_open
		update_menu()

func update_menu() -> void:
	$Center/Console.visible = menu_open
	if menu_open:
		$Center/Console/Input.grab_focus()
		$Center/Console/Input.clear()

func _on_console_input_text_submitted(new_text: String) -> void:
	menu_open = false
	update_menu()
	
	for command_name in commands:
		if new_text.begins_with(command_name):
			var command: Callable = commands[command_name]
			var param_str = new_text.trim_prefix(command_name)
			var params = param_str.split(' ', false)
			print('-> %s' % command)
			command.callv(params)

func register_command(prefix: String, command: Callable) -> void:
	commands[prefix] = command
