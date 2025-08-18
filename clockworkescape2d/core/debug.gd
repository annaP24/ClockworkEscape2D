extends CanvasLayer
class_name DebugScreen

# Dieses script ermöglicht es debug informationen in der oberen linken Ecke anzeigen zu lassen
# Um es zu nutzen muss dieses skript in den settings als singleton eingestellt werden.
# Dann kann man mittels print_value ein oder mehrere debug informationen ausgeben. 
# Beispiel: 
# Debug.print_value("FPS", Engine.get_frames_per_second() )

var debug_data := {}
var enabled = true
@onready var label := Label.new()

func _ready():
	label.name = "Debug:"
	label.set_position(Vector2(10, 10))
	label.add_theme_font_size_override("font_size", 14)
	add_child(label)
	set_layer(100)

func _process(_delta):
	if enabled:
		var text := ""
		for key in debug_data.keys():
			text += "%s: %s\n" % [key, str(debug_data[key])]
		label.text = text
	else:
		label.text = ""

func print_value(key: String, value):
	debug_data[key] = value

func enable():
	enabled = true

func disable():
	enabled = false
