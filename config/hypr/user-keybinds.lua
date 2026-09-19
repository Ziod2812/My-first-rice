local mainMod = "SUPER"

local function bind(key, action, flags)
    hl.bind(key, action, flags)
end

bind(mainMod .. " + SUPER_L", hl.dsp.exec_cmd("qs -c astra ipc call launcher toggle"), { release = true })

bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty"))
bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
bind(mainMod .. " + Q", hl.dsp.window.kill())
bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind(mainMod .. " + ALT + Space", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
bind(mainMod .. " + SHIFT + X", hl.dsp.exec_cmd("hyprlock"))
bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())

bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
bind(mainMod .. " + L", hl.dsp.focus({ direction = "r" }))
bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))
bind(mainMod .. " + J", hl.dsp.focus({ direction = "d" }))

bind(mainMod .. " + SHIFT + H", hl.dsp.window.move({ direction = "l" }))
bind(mainMod .. " + SHIFT + L", hl.dsp.window.move({ direction = "r" }))
bind(mainMod .. " + SHIFT + K", hl.dsp.window.move({ direction = "u" }))
bind(mainMod .. " + SHIFT + J", hl.dsp.window.move({ direction = "d" }))


for i = 1, 9 do
    local key = tostring(i)
    bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = key }))
    bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = key }))
    bind("CTRL + " .. mainMod .. " + " .. key, hl.dsp.focus({ workspace = tostring(i + 10) }))
    bind("CTRL + " .. mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = tostring(i + 10) }))
end

bind(mainMod .. " + 0", hl.dsp.focus({ workspace = "10" }))
bind(mainMod .. " + ALT + 0", hl.dsp.window.move({ workspace = "10" }))
bind("CTRL + " .. mainMod .. " + 0", hl.dsp.focus({ workspace = "20" }))
bind("CTRL + " .. mainMod .. " + ALT + 0", hl.dsp.window.move({ workspace = "20" }))

bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "+1" }), { repeating = true })
bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
bind("CTRL + " .. mainMod .. " + Right", hl.dsp.focus({ workspace = "+1" }), { repeating = true })
bind("CTRL + " .. mainMod .. " + Left", hl.dsp.focus({ workspace = "-1" }), { repeating = true })
bind(mainMod .. " + Page_Down", hl.dsp.focus({ workspace = "+1" }), { repeating = true })
bind(mainMod .. " + Page_Up", hl.dsp.focus({ workspace = "-1" }), { repeating = true })

bind(mainMod .. " + ALT + mouse_down", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
bind(mainMod .. " + ALT + mouse_up", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })
bind("CTRL + " .. mainMod .. " + SHIFT + Right", hl.dsp.window.move({ workspace = "+1" }), { repeating = true })
bind("CTRL + " .. mainMod .. " + SHIFT + Left", hl.dsp.window.move({ workspace = "-1" }), { repeating = true })

bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special:magic" }))
bind("CTRL + " .. mainMod .. " + SHIFT + Down", hl.dsp.window.move({ workspace = "e+0" }))

bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"), { locked = true })
bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"), { locked = true })
bind(mainMod .. " + SHIFT + ALT + S", hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"), { locked = true })

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true, locked = true })
bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true, locked = true })
bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -q set 5%+"), { repeating = true, locked = true })
bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -q set 5%-"), { repeating = true, locked = true })
