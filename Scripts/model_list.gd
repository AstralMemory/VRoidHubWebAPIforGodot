extends Control

@onready var model_data_request = $ModelDataRequest
@onready var image_request = $ImageRequest
@onready var base_button = $ModelSelectButton

var button_count: bool = false
var button_spacing = 10
var count = 0
var image_queue: Array = []
var current_request_index: int = 0
var character_id: Array = []
var character_spec: Array = []

func _ready():
	var header = [
		"X-Api-Version: 11",
		"Authorization: Bearer " + Config.access_token
	]
	
	model_data_request.request("https://hub.vroid.com/api/account/character_models", header)
	

func _on_model_data_request_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	if response_code == 200:
		var response = json.parse_string(body.get_string_from_utf8())
		print(response)
		count = 0
		if "data" in response:
			for model in response["data"]:
				if "portrait_image" in model and "sq150" in model["portrait_image"] and "url" in model["portrait_image"]["sq150"]:
					image_queue.append(model["portrait_image"]["sq150"]["url"])
					character_id.append(model["id"])
					character_spec.append(model["latest_character_model_version"]["spec_version"])
				else:
					print("Image URL not Found for one of the models.")
			_request_next_image()
	else:
		print("Error: " + str(response_code))
		
func _request_next_image():
	if current_request_index < image_queue.size():
		var image_url = image_queue[current_request_index]
		image_request.request(image_url)


func _on_image_request_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var img = Image.new()
		var err = img.load_jpg_from_buffer(body)
		if err == OK:
			if !DirAccess.dir_exists_absolute("user://btnicon"):
				DirAccess.make_dir_absolute("user://btnicon")
			img.save_jpg("user://btnicon/icon" + str(current_request_index) + ".jpg")
			var btn = Button.new()
			btn.pressed.connect(_on_btn_pressed.bind("button" + str(current_request_index)))
			await(!FileAccess.file_exists("user://btnicon/icon" + str(current_request_index) + ".jpg"))
			var timer = Timer.new()
			add_child(timer)
			timer.start(1)
			await(timer.timeout)
			remove_child(timer)
			var icon = FileAccess.open("user://btnicon/icon" + str(current_request_index) + ".jpg", FileAccess.READ)
			var icon_data = icon.get_buffer(icon.get_length())
			icon.close()
			if img.load_jpg_from_buffer(icon_data) == OK:
				var tex = ImageTexture.new()
				btn.icon = tex.create_from_image(img)
			else:
				print("Error!")
				get_tree().quit()
			if button_count == false:
				btn.position = Vector2(base_button.position.x, base_button.position.y)
				base_button.visible = false
				button_count = true
			else:
				btn.position = Vector2(base_button.position.x + base_button.size.x + button_spacing, base_button.position.y)
			btn.size = base_button.size
			var id = character_id[current_request_index]
			var spec = character_spec[current_request_index]
			if spec != "1.0":
				btn.set_meta("character_id", id)
				btn.name = "button" + str(current_request_index)
				add_child(btn)
				base_button = btn
		current_request_index += 1
		_request_next_image()
	else:
		print("Failed to fetch image. Response Code:", str(response_code))
		
func _on_btn_pressed(pressed_button):
	var btn = get_node("/root/ModelList/" + pressed_button)
	Config.character_id = btn.get_meta("character_id")
	get_tree().change_scene_to_file("res://Scene/model_loader.tscn")
