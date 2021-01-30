extends Node

var default_dir := "user://"

func settings_save() -> void:
	var path = "settings.fox"
	var file = File.new()
	
	file = file_open(path, file)
	file.store_buffer(Stats.game_settings)
	
	file.close()

func settings_load() -> void:
	var path = "settings.fox"
	var file = File.new()
	
	if file.file_exists(default_dir + path):
		file = file_open(path, file)
		Stats.game_settings = file.get_buffer(file.get_len())
		file.close()
	else:
		Stats.initialize_settings()
		settings_save()
		
	Stats.set_all_settings()

func data_save() -> void:
	var path = "profile.fox"
	var file = File.new()
	
	file = file_open(path, file)
	file.store_buffer(Stats.game_data)
	
	file.close()

func data_load() -> void:
	var path = "profile.fox"
	var file = File.new()
	
	if file.file_exists(default_dir + path):
		file = file_open(path, file)
		Stats.game_data = file.get_buffer(file.get_len())
		file.close()
		
		if Stats.game_data[Stats.Data.version] != Stats.data_version:
			Stats.initialize_data()
			data_save()
	else:
		Stats.initialize_data()
		data_save()
	
func file_delete(path: String) -> void:
	var dir = Directory.new()
	dir.remove(default_dir + path)

func file_create(path: String, file: File) -> File:
	file.open(default_dir + path, file.WRITE)
	file.close()
	return file
	
func file_open(path: String, file: File) -> File:
	if !file.file_exists(default_dir + path):
		file.close()
		file_create(path, file)
		
	file.open(default_dir + path, file.READ_WRITE)
	return file

func file_close(file: File) -> void:
	file.close()
