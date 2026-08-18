-- This laptop routes its physical HDMI connector through the NVIDIA GPU.
-- Keep the built-in panel as the source and mirror it when HDMI-A-1 is present.

hl.monitor({
	output = 'HDMI-A-1',
	mode = 'preferred',
	position = 'auto',
	scale = 1,
	mirror = 'eDP-1',
})
