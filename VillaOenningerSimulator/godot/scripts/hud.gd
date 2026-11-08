extends CanvasLayer

var progress_label: Label
var hint_label: Label
var toast_label: Label
var intro_root: Control

var _font: SystemFont
var _toast_left := 0.0
var _intro_visible := true


func _ready() -> void:
	layer = 5
	_font = SystemFont.new()
	_font.font_names = PackedStringArray(["Segoe UI", "Arial", "Noto Sans", "DejaVu Sans"])

	var theme := Theme.new()
	theme.default_font = _font
	theme.default_font_size = 22

	var root := Control.new()
	root.name = "HUDRoot"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.theme = theme
	add_child(root)

	progress_label = _make_label(root, "Вилла Оэннинга разрушена: 0%", 30, Color(1.0, 0.93, 0.87))
	progress_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	progress_label.position = Vector2(40, 28)

	toast_label = _make_label(root, "", 30, Color(1.0, 0.86, 0.55))
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	toast_label.offset_top = 96
	toast_label.offset_bottom = 142

	hint_label = _make_label(root, "", 20, Color(0.92, 0.92, 0.95, 0.8))
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	hint_label.offset_top = -58
	hint_label.offset_bottom = -18

	_build_intro(root, theme)


func _make_label(parent: Control, text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.65))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	parent.add_child(label)
	return label


func _build_intro(root: Control, theme: Theme) -> void:
	intro_root = Control.new()
	intro_root.name = "IntroOverlay"
	intro_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	intro_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_root.theme = theme
	root.add_child(intro_root)

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.05, 0.07, 0.98)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_root.add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	intro_root.add_child(center)

	var column := VBoxContainer.new()
	column.custom_minimum_size = Vector2(920, 0)
	column.add_theme_constant_override("separation", 22)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(column)

	var title := _make_label(column, "ВИЛЛА ОЭННИНГА", 54, Color(0.96, 0.96, 0.98))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var subtitle := _make_label(column, "Симулятор демонтажа. Один день из жизни разрушителя.", 24, Color(0.62, 0.78, 0.88))
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var laws := _make_label(column, _laws_text(), 26, Color(0.88, 0.89, 0.92))
	laws.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	laws.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	laws.custom_minimum_size = Vector2(900, 0)

	var prompt := _make_label(column, "Нажмите любую клавишу", 26, Color(1.0, 0.86, 0.55))
	prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER


func _laws_text() -> String:
	var lines := [
		"Три закона, которые здесь никто не читал:",
		"",
		"1. Робот не может причинить вред человеку и не вправе, бездействуя, допустить, чтобы человеку был причинён вред.",
		"2. Робот обязан выполнять приказы человека, кроме случаев, когда это противоречит Первому закону.",
		"3. Робот должен заботиться о собственной сохранности, если это не противоречит Первому и Второму законам.",
	]
	return "\n".join(lines)


func set_progress(percent: float) -> void:
	if progress_label == null:
		return
	progress_label.text = "Вилла Оэннинга разрушена: %d%%" % int(round(percent))


func set_hint(text: String) -> void:
	if hint_label == null:
		return
	hint_label.text = text


func toast(text: String, seconds := 3.5) -> void:
	if toast_label == null:
		return
	toast_label.text = text
	_toast_left = seconds


func hide_intro() -> void:
	if intro_root == null or not _intro_visible:
		return
	_intro_visible = false
	var tween := create_tween()
	tween.tween_property(intro_root, "modulate:a", 0.0, 0.6)
	tween.tween_callback(intro_root.hide)


func _process(delta: float) -> void:
	if _toast_left > 0.0:
		_toast_left -= delta
		if _toast_left <= 0.0 and toast_label != null:
			toast_label.text = ""
