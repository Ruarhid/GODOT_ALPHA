extends Control
class_name UpgradeMenu

@onready var title: Label = %Title
@onready var option1: Button = %Option1
@onready var option2: Button = %Option2
@onready var option3: Button = %Option3

var upgrades: Array[Dictionary] = [
	{"name": "Health Up", "effect": "max_health", "value": 20}, 
	{"name": "Speed Up", "effect": "speed", "value": 50},
	{"name": "Attack Speed Up", "effect": "attack_cooldown", "value": -0.05},
	{"name": "Damage Up", "effect": "projectile_damage", "value": 5}]

func  _ready() -> void:
	add_to_group("upgrade_menu")
	hide()
	if not option1.pressed.is_connected(_on_option_pressed.bind(0)):
		option1.pressed.connect(_on_option_pressed.bind(0))
		print("Option1 signal connected")
	if not option2.pressed.is_connected(_on_option_pressed.bind(1)):
		option2.pressed.connect(_on_option_pressed.bind(1))
		print("Option2 signal connected")
	if not option3.pressed.is_connected(_on_option_pressed.bind(2)):
		option3.pressed.connect(_on_option_pressed.bind(2))
		print("Option3 signal connected")
	print("UpgradeMenu initialized")

func show_menu() -> void:
	if visible:
		print("UpgradeMenu already visible, skipping show")
		return
	print("Showing upgrade menu")
	var selected_upgrades = []
	var available_indices = range(upgrades.size())
	available_indices.shuffle()
	for i in range(min(3, upgrades.size())):
		selected_upgrades.append(upgrades[available_indices[i]])
	option1.text = selected_upgrades[0] ["name"] if selected_upgrades.size() > 0 else "Empty"
	option1.set_meta("upgrade_index", available_indices[0] if selected_upgrades.size() > 0 else -1)
	option2.text = selected_upgrades[1] ["name"] if selected_upgrades.size() > 1 else "Empty"
	option2.set_meta("upgrade_index",available_indices[1] if selected_upgrades.size() > 1 else -1)
	option3.text = selected_upgrades[2] ["name"] if selected_upgrades.size() > 2 else "Empty"
	option3.set_meta("upgrade_index", available_indices[2] if selected_upgrades.size() > 2 else -1)
	option1.disabled = selected_upgrades.size() <= 0
	option2.disabled = selected_upgrades.size() <= 1
	option3.disabled = selected_upgrades.size() <= 2
	show()
	if not option1.disabled:
		option1.grab_focus()
	get_tree().paused = true
	print("UpgradeMenu show, visible: ", visible) 
	print("Button texts: ", option1.text, ", ", option2.text, ", ", option3.text)
	print("Button indices: ", option1.get_meta("upgrade_index"), ", ", option2.get_meta("upgrade_index"), ", ", option3.get_meta("upgrade_index"))

func _on_option_pressed(index: int) -> void:
	var button = [option1, option2, option3] [index]
	if button.disabled:
		print("Button ", index + 1, "disabled")
		return
	var upgrade_name = button.text
	var upgrade_index = button.get_meta("upgrade_index", -1)
	print("Button ", index + 1, "pressed, upgrade: ", upgrade_name, ", upgrade_index: ", upgrade_index)
	if upgrade_index < 0 or upgrade_index >= upgrades.size():
		print("Invalid upgrade index: ", upgrade_index)
		return
	var upgrade = upgrades[upgrade_index]
	if upgrade["name"] != upgrade_name:
		print("Mismatch: button text ", upgrade_name, " does not match upgrade name ", upgrade["name"])
		return
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		print("Player not found")
		return
	print("Applying upgrade: ", upgrade_name)
	match upgrade["effect"]:
		"max_health":
			player.max_health += upgrade["value"]
			player.health += upgrade["value"]
			player.main_health_bar.max_value = player.max_health
			player.damage_health_bar.max_value = player.max_health
		"speed":
			player.speed += upgrade["value"]
		"attack_cooldown":
			player.attack_cooldown = max(0.1, player.attack_cooldown + upgrade["value"])
		"projectile_damage":
			player.set_meta("projectile_damage", player.get_meta("projectile_damage", 10) + upgrade["value"])
	print("Hiding UpgradeMenu....")
	hide()
	print("UpgradeMenu hide called, visible: ", visible)
	release_focus() # Снять фокус
	get_tree().paused = false
	print("Game unpaused, UpgradeMenu visible:", visible)
