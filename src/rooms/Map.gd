class_name Map
extends Sprite

var mapcells = [
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null],
	[null, null, null, null]
]

var mapcells_available = [
	[false, false, false, false],
	[false, false, false, false],
	[false, false, false, false],
	[false, false, false, false]
]

var mapcells_name = [
	["aa bwbwbwbw", "uwuwuwuwu", "wawaaaaa", "aafklsdf"],
	["uwu uuuuuuuwu", "OWO", "wawabbbhhhfhf", "hi whats up"],
	["hjjdd..", "WAOWIE", "'w'", "eeeuuuuufuffufufu"],
	["6", "yayayayayaya", "NONONONONO", "a"]
]

var selected_cell := Vector2(-1, -1)
var open := false

func _ready():
	var mapcell_base = $Cells/MapCell
	var w = 0
	var h = 0
	for i in mapcells:
		for j in i:
			mapcells[h][w] = mapcell_base.duplicate()
			mapcells[h][w].material = mapcells[h][w].material.duplicate()
			$Cells.add_child(mapcells[h][w])
			mapcells[h][w].position += Vector2(40 * w, 20 * h)
			mapcells[h][w].frame = w + h * 4
			w += 1
		h += 1
		w = 0
	mapcell_base.queue_free()

func _process(delta):
	var w = 0
	var h = 0
	var cell_index = 0
	for i in mapcells:
		for j in i:
			mapcells_available[h][w] = false
			j.visible = false
			if Stats.game_data[Stats.Data.map_cells + cell_index] == 1:
				mapcells_available[h][w] = true
				j.visible = true
					
			cell_index += 1
			w += 1
			
			if j:
				j.material.set_shader_param("intensity", 0.0)
		h += 1
		w = 0
	$CellName.text = mapcells_name[selected_cell.y][selected_cell.x]
			
	if Global.current_pausestate == Global.PauseState.NORMAL:
		if Input.is_action_just_pressed("ui_map") and Global.current_room_control.map_cell != Vector2(-1, -1):
			open = true
			Global.set_pause_state(Global.PauseState.PAUSED)
			$AnimationPlayer.play("appear")
	if Global.current_pausestate == Global.PauseState.PAUSED and open and !$AnimationPlayer.is_playing():
		if Input.is_action_just_pressed("ui_map"):
			$AnimationPlayer.play("disappear")
						
		var move_dir = Vector2.ZERO
		if Input.is_action_just_pressed("ui_left"):
			move_dir.x = -1
		if Input.is_action_just_pressed("ui_right"):
			move_dir.x = 1
		if Input.is_action_just_pressed("ui_up"):
			move_dir.y = -1
		if Input.is_action_just_pressed("ui_down"):
			move_dir.y = 1
			
		if move_dir.x != 0:
			selected_cell.x = Global.shift_index(selected_cell.x, 0, mapcells[0].size() - 1, move_dir.x)
			while !mapcells_available[selected_cell.y][selected_cell.x]:
				selected_cell.x = Global.shift_index(selected_cell.x, 0, mapcells[0].size() - 1, move_dir.x)
		
		if move_dir.y != 0:
			selected_cell.y = Global.shift_index(selected_cell.y, 0, mapcells.size() - 1, move_dir.y)
			while !mapcells_available[selected_cell.y][selected_cell.x]:
				selected_cell.y = Global.shift_index(selected_cell.y, 0, mapcells.size() - 1, move_dir.y)
			
	var scell = mapcells[selected_cell.y][selected_cell.x]
	if scell:
		scell.material.set_shader_param("intensity", 1.0)
			
	visible = Global.current_pausestate == Global.PauseState.PAUSED and open
	


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "disappear":
		Global.set_pause_state(Global.PauseState.NORMAL)
		open = false
