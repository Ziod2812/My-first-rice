hl.window_rule({
    match = {
        class = "^(pavucontrol)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(nm-connection-editor)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        class = "^(blueman-manager)$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^Picture-in-Picture$",
    },
    float = true,
    pin = true,
})

hl.window_rule({
    match = {
        title = "^Open File$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^Save File$",
    },
    float = true,
})

hl.window_rule({
    match = {
        title = "^Choose.*$",
    },
    float = true,
})