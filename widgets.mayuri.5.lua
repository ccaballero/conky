require 'cairo'
require 'imlib2'

package.path = package.path .. ";/home/jacobian/.conky/?.lua"

local commons = require("commons")

function conky_widgets()
    local cs = conky_surface()

    if not cs then return end

    cr = cairo_create(cs)

    local r = 128
    local color = 0xffffff

    commons.round_rect(  5,  24, 200, 2, 0, color, 1.0)
    commons.round_rect(  5, 224, 200, 2, 0, color, 1.0)

    cairo_destroy(cr)
end

