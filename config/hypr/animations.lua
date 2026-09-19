hl.curve("astraEase", {
    type = "bezier",
    points = {
        { 0.23, 1.00 },
        { 0.32, 1.00 },
    },
})

hl.curve("astraSmooth", {
    type = "bezier",
    points = {
        { 0.65, 0.00 },
        { 0.35, 1.00 },
    },
})

hl.curve("astraBack", {
    type = "bezier",
    points = {
        { 0.34, 1.56 },
        { 0.64, 1.00 },
    },
})

hl.animation({ leaf = "global", enabled = true, speed = 5, bezier = "astraEase" })
hl.animation({ leaf = "windows", enabled = true, speed = 5, bezier = "astraEase" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "astraBack", style = "popin 70%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, bezier = "astraEase", style = "popin 70%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "astraEase" })
hl.animation({ leaf = "layers", enabled = true, speed = 5, bezier = "astraEase" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "astraBack", style = "popin 70%" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "astraEase", style = "popin 70%" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "astraSmooth" })
hl.animation({ leaf = "fadeIn", enabled = true, speed = 5, bezier = "astraSmooth" })
hl.animation({ leaf = "fadeOut", enabled = true, speed = 4, bezier = "astraSmooth" })
hl.animation({ leaf = "fadeDim", enabled = true, speed = 5, bezier = "astraSmooth" })
hl.animation({ leaf = "border", enabled = true, speed = 5, bezier = "astraEase" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "astraEase", style = "slidefade" })
hl.animation({ leaf = "workspacesIn", enabled = true, speed = 6, bezier = "astraEase", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true, speed = 6, bezier = "astraEase", style = "slide" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "astraEase", style = "slidevert" })
