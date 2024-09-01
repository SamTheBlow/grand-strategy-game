class_name PositionScreenToWorld
## Takes a screen position and turns it into a position on the world map.


func result(screen_position: Vector2, viewport: Viewport) -> Vector2:
	var camera: Camera2D = viewport.get_camera_2d()
	var viewport_rect: Rect2 = viewport.get_visible_rect()
	return (
			(screen_position - viewport_rect.size * 0.5) / camera.zoom
			+ camera.get_screen_center_position()
	)
