class_name SlopeChecker
extends Area2D

var nearby_slopes = []

func _on_SlopeChecker_body_shape_entered(body_id, body, body_shape, area_shape):
	var p
	for c in body.get_children():
		if c is CollisionPolygon2D:
			p = c.polygon
			break
	if p:
		
		nearby_slopes.append([body])
	

func _on_SlopeChecker_body_shape_exited(body_id, body, body_shape, area_shape):
	var i = 0
	for n in nearby_slopes:
		if n[0] == body:
			nearby_slopes.remove(i)
			break
		i += 1
