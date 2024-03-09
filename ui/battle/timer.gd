extends ProgressBar


signal timeout

var tween: Tween
var enabled = global.player.battle_timer


func count_down(time: int):
	if enabled:
		tween = get_tree().create_tween()
		tween.tween_property(self, "value", 0, time)
		await tween.finished
		emit_signal("timeout")
		value = max_value


func stop():
	if enabled:
		tween.kill()
		value = max_value
