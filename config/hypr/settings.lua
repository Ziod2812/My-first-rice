local v = require("variables")

hl.config({
    general = {
        gaps_in = v.gapsIn,
        gaps_out = v.gapsOut,
        border_size = v.borderSize,
        ["col.active_border"] = v.activeBorder,
        ["col.inactive_border"] = v.inactiveBorder,
        layout = "dwindle",
        allow_tearing = false,
        resize_on_border = true,
    },

    decoration = {
        rounding = v.rounding,
        active_opacity = v.activeOpacity,
        inactive_opacity = v.inactiveOpacity,
        fullscreen_opacity = v.fullscreenOpacity,

        shadow = {
            enabled = true,
            range = v.shadowRange,
            render_power = v.shadowRenderPower,
            color = v.shadowColor,
        },

        blur = {
            enabled = true,
            size = v.blurSize,
            passes = v.blurPasses,
            new_optimizations = true,
            xray = false,
            noise = v.blurNoise,
            contrast = v.blurContrast,
            brightness = v.blurBrightness,
            vibrancy = v.blurVibrancy,
            vibrancy_darkness = v.blurVibrancyDarkness,
        },
    },

    input = {
        kb_layout = "us",
        follow_mouse = 1,
        sensitivity = 0,
        accel_profile = "flat",

        touchpad = {
            natural_scroll = true,
            disable_while_typing = true,
            tap_to_click = true,
        },
    },

    dwindle = {
        preserve_split = true,
        smart_split = false,
        smart_resizing = true,
    },

    master = {
        new_status = "master",
        new_on_top = false,
        mfact = v.masterFactor,
    },

    misc = {
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        force_default_wallpaper = 0,
        vrr = 0,
        animate_manual_resizes = true,
        animate_mouse_windowdragging = true,
        focus_on_activate = true,
        middle_click_paste = false,
        enable_swallow = false,
    },

    xwayland = {
        force_zero_scaling = true,
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace",
})
