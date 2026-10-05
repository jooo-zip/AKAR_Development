extends RefCounted
## Reset through each controller's tested cleanup/opener without notifying a host
## that the visitor closed the component. Closed components remain closed.

static func reset(panel: ConferenceRoomInteraction) -> void:
	if not panel.is_node_ready():
		return
	var was_open := panel._open
	var was_blocking := panel.is_blocking_signals()
	var return_focus := panel._return_focus
	panel.set_block_signals(true)
	panel.close_interaction()
	panel.open_interaction()
	if not was_open:
		panel.close_interaction()
	panel._return_focus = return_focus
	panel.set_block_signals(was_blocking)
