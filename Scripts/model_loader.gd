extends Node3D

@onready var model_request = $ModelRequest
@onready var license_request = $LicenseRequest

const API_ENDPOINT = "https://hub.vroid.com//api/download_licenses/"

var header = [
	"X-Api-Version: 11",
	"Authorization: Bearer " + Config.access_token,
	#"Content-Type': 'application/json"
]


func _ready():
	if Config.character_id != null:
		modelload()
	else:
		print("Load Error!")
	

func modelload():
	var post_data = "character_model_id=" + Config.character_id
	license_request.request(API_ENDPOINT,header, HTTPClient.METHOD_POST, post_data)

func _on_license_request_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	if response_code == 200:
		var response = json.parse_string(body.get_string_from_utf8())
		var download_license_id = response["data"]["id"]
		model_request.set_download_file("user://model.vrm")
		model_request.request(API_ENDPOINT + str(download_license_id) + "/download", header, HTTPClient.METHOD_GET)
	else:
		print("Failed Get License! Response Code:", str(response_code), json.parse_string(body.get_string_from_utf8()))

func _on_model_request_request_completed(result, response_code, headers, body):
	if response_code == 302:
		var url_pattern = RegEx.new()
		url_pattern.compile('<a href="(.+?)">')
		url_pattern.search(body)
		
		var redirect_url = url_pattern.get_string(1)
		
		if redirect_url:
			model_request.request(redirect_url)
	elif response_code == 200:
		load_model()
	else:
		print("Failed to download file. Response Code:", str(response_code))
		
func load_model():
	var vrm_path = ProjectSettings.globalize_path("user://") + "model.vrm"
	var gltf = GLTFDocument.new()
	var gltf_state = GLTFState.new()
	
	gltf.append_from_file(vrm_path, gltf_state)
	
	
	var node = gltf.generate_scene(gltf_state)
	node.name = "Model"
	add_child(node)
	
	if Config.character_spec == "1.0":
		node.rotation.y = 135

	
