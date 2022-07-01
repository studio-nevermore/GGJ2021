class_name ItemPickup
extends Area2D

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

export(Items) var item = Items.jump

var collected := false
export(bool) var glitchside = false

func _ready():
	if glitchside and !Stats.game_data[Stats.Data.glitched]:
		queue_free()
	match item:
		Items.jump:
			if Stats.game_data[Stats.Data.upgrade_jump] == 1:
				queue_free()
		Items.jump2:
			if Stats.game_data[Stats.Data.upgrade_jump2] == 1:
				queue_free()
		Items.speed:
			if Stats.game_data[Stats.Data.upgrade_speed] == 1:
				queue_free()
		Items.melee:
			if Stats.game_data[Stats.Data.upgrade_melee] == 1:
				queue_free()
		Items.swim:
			if Stats.game_data[Stats.Data.upgrade_swim] == 1:
				queue_free()
		Items.projectile:
			if Stats.game_data[Stats.Data.upgrade_projectile] == 1:
				queue_free()
		Items.paper:
			if Stats.game_data[Stats.Data.upgrade_map] == 1:
				queue_free()
		Items.magnet:
			if Stats.game_data[Stats.Data.upgrade_magnet] == 1:
				queue_free()

func _process(delta):
	$Item.frame = item
	if collected and !$CollectParticles.emitting:
		collect_item()

func collect_item():
	match item:
		Items.jump:
			Stats.game_data[Stats.Data.upgrade_jump] = 1
		Items.jump2:
			Stats.game_data[Stats.Data.upgrade_jump2] = 1
		Items.speed:
			Stats.game_data[Stats.Data.upgrade_speed] = 1
		Items.melee:
			Stats.game_data[Stats.Data.upgrade_melee] = 1
		Items.swim:
			Stats.game_data[Stats.Data.upgrade_swim] = 1
		Items.projectile:
			Stats.game_data[Stats.Data.upgrade_projectile] = 1
		Items.paper:
			Stats.game_data[Stats.Data.upgrade_map] = 1
		Items.magnet:
			Stats.game_data[Stats.Data.upgrade_magnet] = 1
		
	collected = true
	$Item.visible = true
	#Global.get_player().get_node("Animations").play("pose")
	$AnimationPlayer.play("rise")

# TODO: better names
var labels = {
	Items.jump: "High Jump",
	Items.jump2: "Double Jump",
	Items.speed: "Speed",
	Items.melee: "Melee",
	Items.swim: "Swim",
	Items.projectile: "Projectile",
	Items.paper: "Paper",
	Items.magnet: "Magnet",
}

func _on_ItemPickup_body_entered(body):
	if !collected and body.is_in_group("player"):
		$PulseParticles.emitting = false
		$CollectParticles.emitting = true
		$CollectParticles.visible = true
		$Sprite.visible = false
		$Item.visible = false
		$Label.text = labels[item]
		$Label.visible = true
		global_position = body.global_position + Vector2(0, -6)
		collected = true
		body.get_node("EventHandler").freeze_completely()

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "rise":
		Global.get_player().get_node("EventHandler").unfreeze_completely()
		queue_free()
