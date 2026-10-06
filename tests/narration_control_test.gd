extends SceneTree
## Real production streams; actual EOF after seeking near the end, never a synthetic finished signal.
## Run with --headless --max-fps 60 --path . --script res://tests/narration_control_test.gd.
## For Compatibility captures omit --headless and set AKAR_NARRATION_CAPTURE_DIR.
const SCENES = [
	"res://scenes/landmarks/lingayen_church/exterior/lc_ext_01.tscn",
	"res://scenes/landmarks/lingayen_church/exterior/lc_ext_02.tscn",
	"res://scenes/landmarks/lingayen_church/exterior/lc_ext_03.tscn",
	"res://scenes/landmarks/lingayen_church/interior/lc_int_01.tscn",
	"res://scenes/landmarks/lingayen_church/interior/lc_int_02.tscn",
	"res://scenes/landmarks/lingayen_church/interior/lc_end_01.tscn",
	"res://scenes/landmarks/casa_real/exterior/cr_ext_01.tscn",
	"res://scenes/landmarks/casa_real/exterior/cr_ext_02.tscn",
	"res://scenes/landmarks/casa_real/exterior/cr_ext_03.tscn",
	"res://scenes/landmarks/casa_real/interior/cr_int_01.tscn",
	"res://scenes/landmarks/casa_real/interior/cr_int_02.tscn",
	"res://scenes/landmarks/casa_real/interior/cr_int_03.tscn",
	"res://scenes/landmarks/casa_real/end/cr_end_01.tscn",
	"res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_01.tscn",
	"res://scenes/landmarks/pangasinan_provincial_capitol/exterior/ppc_ext_02.tscn",
	"res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_01.tscn",
	"res://scenes/landmarks/pangasinan_provincial_capitol/interior/ppc_int_02.tscn",
	"res://scenes/landmarks/pangasinan_provincial_capitol/summary/ppc_end_01.tscn",
	"res://scenes/landmarks/urduja_house/components/uh_ext_01.tscn",
	"res://scenes/landmarks/urduja_house/components/uh_ext_02.tscn",
	"res://scenes/landmarks/urduja_house/components/uh_ext_03.tscn",
	"res://scenes/landmarks/urduja_house/components/uh_int_01.tscn",
	"res://scenes/landmarks/urduja_house/components/uh_int_02.tscn",
	"res://scenes/landmarks/urduja_house/components/uh_int_03.tscn",
	"res://scenes/landmarks/urduja_house/components/uh_int_04.tscn",
	"res://scenes/landmarks/urduja_house/components/uh_end_01.tscn",
	"res://scenes/landmarks/limahong_channel/exterior/lch_ext_01.tscn",
	"res://scenes/landmarks/limahong_channel/exterior/lch_ext_02.tscn",
	"res://scenes/landmarks/limahong_channel/exterior/lch_ext_03.tscn",
	"res://scenes/landmarks/limahong_channel/interior/lch_int_01.tscn",
	"res://scenes/landmarks/limahong_channel/interior/lch_int_02.tscn",
	"res://scenes/landmarks/limahong_channel/interior/lch_int_03.tscn",
	"res://scenes/landmarks/limahong_channel/summary/lch_end_01.tscn"
]
var checks := 0
var failures := 0
var current_id := ""
var host: Control

func _initialize() -> void:
	run.call_deferred()

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(current_id + ": " + message)

func settle(seconds: float = 0.12) -> void:
	await create_timer(seconds).timeout

func click(button: Button) -> void:
	for down in [true, false]:
		var event := InputEventMouseButton.new()
		event.button_index = MOUSE_BUTTON_LEFT
		event.position = button.get_global_rect().get_center()
		event.pressed = down
		Input.parse_input_event(event)
		await process_frame
	await settle(0.04)

func state(audio: AudioStreamPlayer, button: Button, label: String) -> void:
	check(button.text == label, "expected " + label + ", got " + button.text)
	check(audio.stream_paused == (label == "RESUME"), "pause flag for " + label)
	check(button.button_pressed == (label == "PAUSE"), "pressed styling for " + label)
	if label == "LISTEN":
		check(not audio.playing and is_zero_approx(audio.get_playback_position()), "idle stops and resets position")
	elif label == "PAUSE":
		check(audio.playing, "playback active")

func fit(button: Button, panel: Control) -> void:
	var font := button.get_theme_font("font")
	var width := font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, button.get_theme_font_size("font_size")).x
	var icon_width := button.get_theme_constant("icon_max_width")
	if icon_width <= 0: icon_width = button.icon.get_width() if button.icon else 0
	var required := width + button.get_theme_stylebox("normal").get_minimum_size().x
	if button.icon: required += icon_width + button.get_theme_constant("h_separation")
	check(button.icon != null, "speaker icon present")
	check(button.size.x + 0.5 >= required, "label/icon fit " + button.text + " at " + str(host.size) + ": " + str(button.size.x) + " < " + str(required))
	check(panel.get_global_rect().grow(0.5).encloses(button.get_global_rect()), "narration control inside host")
	print("FIT ", current_id, " ", host.size, " ", button.text, " width=", button.size.x, " required=", required)

func run() -> void:
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_DISABLED
	root.size = Vector2i(1280, 720)
	host = Control.new()
	root.add_child(host)
	host.size = Vector2(1280, 720)
	for path in SCENES:
		current_id = path.get_file().get_basename().to_upper().replace("_", "-")
		if not OS.get_cmdline_user_args().is_empty() and current_id not in OS.get_cmdline_user_args():
			continue
		var before := failures
		var panel = load(path).instantiate()
		host.add_child(panel)
		panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		await settle()
		var uh := current_id.begins_with("UH-")
		var audio: AudioStreamPlayer = panel.audio if uh else panel._audio
		var button: Button = panel.listen if uh else panel._speaker
		var sources: Control = panel.sources if uh else panel._sources
		var sources_button: Button = panel.sources_button if uh else panel._sources_button
		var source_close: Button = panel.source_close if uh else panel._source_close
		var close_button: Button = panel.close_button if uh else panel._close
		var expected_asset: String = "res://assets/landmarks/" + path.split("/")[4] + "/audio/" + path.get_file().get_basename() + "_narration.ogg"
		var opened := [0]
		var closed := [0]
		panel.opened.connect(func(): opened[0] += 1)
		panel.closed.connect(func(): closed[0] += 1)
		for dimensions in [Vector2i(1280,720), Vector2i(960,540), Vector2i(854,480)]:
			root.size = dimensions
			host.size = dimensions
			check(panel.open_interaction(), "opens")
			await settle(0.35)
			check(audio.stream != null and audio.stream.resource_path == expected_asset, "exact baseline narration asset: " + expected_asset)
			state(audio, button, "LISTEN")
			fit(button, panel)
			await click(button)
			state(audio, button, "PAUSE")
			check(audio.get_playback_position() < 0.5, "Listen starts at beginning")
			fit(button, panel)
			await settle(0.15)
			await click(button)
			state(audio, button, "RESUME")
			var paused_at := audio.get_playback_position()
			await settle(0.12)
			check(absf(audio.get_playback_position() - paused_at) < 0.025 and paused_at > 0, "pause preserves position")
			fit(button, panel)
			var capture_dir := OS.get_environment("AKAR_NARRATION_CAPTURE_DIR")
			if not capture_dir.is_empty() and current_id in ["LC-EXT-01", "CR-EXT-01", "PPC-EXT-02", "UH-EXT-01", "UH-INT-01", "LCH-EXT-01"]:
				await RenderingServer.frame_post_draw
				root.get_texture().get_image().save_png(capture_dir.path_join(current_id + "_" + str(dimensions.x) + "_RESUME.png"))
			await click(button)
			state(audio, button, "PAUSE")
			check(audio.get_playback_position() >= paused_at, "Resume continues without restart")
			panel.close_interaction()
			await settle(0.4)
			state(audio, button, "LISTEN")
		# Full lifecycle, actual Sources and Close controls, rapid transitions and actual EOF.
		root.size = Vector2i(1280,720)
		host.size = Vector2(1280,720)
		panel.open_interaction()
		await settle(0.35)
		state(audio, button, "LISTEN")
		await click(button)
		await click(sources_button)
		check(sources.visible, "Sources button opens overlay")
		check(audio.playing and not audio.stream_paused, "Sources preserves narration")
		await click(source_close)
		check(not sources.visible, "Close Sources works")
		await click(button)
		state(audio, button, "RESUME")
		await click(close_button)
		await settle(0.4)
		state(audio, button, "LISTEN")
		check(not panel.visible, "Close button closes paused hotspot")
		panel.open_interaction()
		await settle(0.35)
		state(audio, button, "LISTEN")
		await click(button)
		check(audio.get_playback_position() < 0.5, "reopen playback starts at beginning")
		# Allow the actual supplied OGG decoder to reach EOF and emit finished.
		var finished := [0]
		audio.finished.connect(func(): finished[0] += 1)
		audio.seek(maxf(0.0, audio.stream.get_length() - 0.15))
		await settle(0.6)
		check(finished[0] == 1, "actual natural completion signal exactly once")
		state(audio, button, "LISTEN")
		await click(button)
		check(audio.get_playback_position() < 0.5, "replay after completion starts at beginning")
		panel.stop_narration()
		for i in 51:
			button.pressed.emit()
			state(audio, button, "PAUSE" if i % 2 == 0 else "RESUME")
		await settle(0.1)
		check(audio.get_stream_playback() != null and audio.max_polyphony == 1, "single playback after rapid input")
		check(audio.stream.resource_path == expected_asset, "rapid input preserves asset")
		var reset_method := "reset_interaction" if panel.has_method("reset_interaction") else ("reset_hotspot" if panel.has_method("reset_hotspot") else "")
		if not reset_method.is_empty():
			for paused in [false, true]:
				panel.stop_narration()
				button.pressed.emit()
				if paused: button.pressed.emit()
				var notifications := [opened[0], closed[0]]
				panel.call(reset_method)
				await settle(0.15)
				state(audio, button, "LISTEN")
				check(panel.visible and notifications == [opened[0], closed[0]], "reset preserves open lifecycle and signals")
		var close_count: int = closed[0]
		panel.close_interaction()
		await settle(0.4)
		check(closed[0] == close_count + 1, "one closed signal")
		panel.close_interaction()
		check(closed[0] == close_count + 1, "repeated close is idempotent")
		if not reset_method.is_empty():
			var notifications := [opened[0], closed[0]]
			panel.call(reset_method)
			await settle(0.15)
			state(audio, button, "LISTEN")
			check(not panel.visible and notifications == [opened[0], closed[0]], "closed reset preserves lifecycle and signals")
		print("RESULT ",current_id," failures=",failures-before)
		panel.queue_free()
		await settle(0.05)
	print("NARRATION: ",checks," checks; ",failures," failures")
	quit(1 if failures else 0)
