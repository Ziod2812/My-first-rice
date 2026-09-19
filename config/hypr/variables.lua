local M = {}

M.gapsIn = 5
M.gapsOut = {
    top = 0,
    right = 12,
    bottom = 12,
    left = 12,
}

M.borderSize = 1
M.rounding = 14

M.activeBorder = "rgba(b4befeaa)"
M.inactiveBorder = "rgba(585b7066)"

M.activeOpacity = 1.0
M.inactiveOpacity = 0.94
M.fullscreenOpacity = 1.0

M.shadowRange = 18
M.shadowRenderPower = 3
M.shadowColor = "rgba(00000055)"

M.blurSize = 8
M.blurPasses = 3
M.blurNoise = 0.0117
M.blurContrast = 0.8916
M.blurBrightness = 0.8172
M.blurVibrancy = 0.1696
M.blurVibrancyDarkness = 0.0

M.masterFactor = 0.55

return M
