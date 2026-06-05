extends VBoxContainer
class_name  Stats

@onready var collectables: Label = %Collectables
@onready var deaths: Label = %Deaths
@onready var level: Label = %Level
@onready var timelaps: Label = %Timelaps
@onready var progress_label: Label = %ProgressLabel


func fill_data(data : Dictionary):
	var readable_time = GameManager.format_play_time(data["time"])
	collectables.text = str(data["collected"])
	deaths.text = str(data["deaths"])
	timelaps.text = readable_time
	level.text = str(data["level"])
	var formatted = "%.2f" % data["progress"]
	progress_label.text = formatted + " %"
