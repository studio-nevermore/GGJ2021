extends Node2D

var game_view: Viewport
var dir = "src/rooms/"
var ext = ".tscn"

func load_scene(path: String) -> void:
	call_deferred("_load_scene_deferred", path)
	
func _load_scene_deferred(path: String) -> void:
	if game_view:
		for n in game_view.get_children():
			if n.name != "GUI" and n.name != "Music":
				n.free()
		var pscene = load(dir + path + ext)
		var scene = pscene.instance()
		game_view.add_child(scene)
		scene.get_node("RoomControl").reready()
	else:
		push_error("Could not load scene - game viewport not found.")
