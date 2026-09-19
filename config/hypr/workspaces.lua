for i = 1, 10 do
    hl.workspace_rule({
        workspace = tostring(i),
    })
end

hl.workspace_rule({
    workspace = "special:magic",
    gaps_in = 8,
    gaps_out = 10,
    animation = "slidevert",
})
