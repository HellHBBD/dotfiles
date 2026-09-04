-- This laptop routes its physical HDMI connector through the NVIDIA GPU.
-- Display mode is selected at runtime by scripts/display-mode.sh.

hl.monitor({
	output = 'eDP-1',
	mode = 'preferred',
	position = '0x0',
	scale = 1.25,
})

hl.monitor({
	output = 'HDMI-A-1',
	mode = 'preferred',
	position = 'auto-right',
	scale = 1,
})

-- Hyprland can restore a workspace to a reconnecting mirror output after its
-- own mirror migration has run. Repair that state after the output is ready.
hl.on('monitor.added', function(monitor)
	if monitor.name ~= 'HDMI-A-1' then
		return
	end

	hl.timer(function()
		hl.exec_cmd('bash ~/.config/hypr/scripts/display-mode.sh --repair-mirror')
	end, { timeout = 500, type = 'oneshot' })
end)
