class_name HUD
extends Sprite

enum Items {
	paper,
	swim,
	magnet,
	speed,
	projectile,
	jump2,
	melee,
	jump
}

var a_target := 1.0

func _process(delta):
	if Global.current_room_control and Global.current_room_control.has_player:
		visible = true
		
		$IconZ.visible = false
		$IconX.visible = false
		$IconA.visible = false
		$IconS.visible = false
		
		if Stats.game_data[Stats.Data.upgrade_jump2]:
			$IconZ.frame = Items.jump2
			$IconZ.visible = true
		elif Stats.game_data[Stats.Data.upgrade_jump]:
			$IconZ.frame = Items.jump
			$IconZ.visible = true
			
		if Stats.game_data[Stats.Data.upgrade_melee]:
			$IconX.frame = Items.melee
			$IconX.visible = true
			
		if Stats.game_data[Stats.Data.upgrade_magnet]:
			$IconA.frame = Items.magnet
			$IconA.visible = true
			
		if Stats.game_data[Stats.Data.upgrade_projectile]:
			$IconS.frame = Items.projectile
			$IconS.visible = true
			
		a_target = 1.0
		if Global.get_player().global_position.y < 60:
			a_target = 0.2
		
		modulate.a = Global.approach_value(modulate.a, a_target, 0.1)
	else:
		visible = false
