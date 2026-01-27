class_name BattleLogPanel
extends PanelContainer

@onready var log_label: RichTextLabel = $LogMargin/LogLabel

var max_lines := 40
var lines: Array = []

func set_max_lines(count: int) -> void:
	max_lines = max(count, 1)
	_refresh_label()

func clear() -> void:
	lines.clear()
	_refresh_label()

func append_line(text: String) -> void:
	if text.is_empty():
		return
	lines.append(text)
	if lines.size() > max_lines:
		lines = lines.slice(lines.size() - max_lines, lines.size())
	_refresh_label()

func _refresh_label() -> void:
	if not log_label:
		return
	log_label.text = "\n".join(lines)
	_scroll_to_bottom()

func _scroll_to_bottom() -> void:
	var line_count := log_label.get_line_count()
	log_label.call_deferred("scroll_to_line", max(line_count - 1, 0))
