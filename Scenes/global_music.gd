extends AudioStreamPlayer

func _ready() -> void:
	# Whenever the song finishes, instantly call play() again
	finished.connect(play)
	play()
