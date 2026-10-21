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

    commons.clock_hands(64, 64, color, 1.0, true, 72)

    commons.segment(color, 0.1, 64, 64, r-(12*7)+3, 5,   0, 360)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5,   0,   1)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5,  30,  31)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5,  60,  61)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5,  90,  91)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5, 120, 121)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5, 150, 151)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5, 180, 181)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5, 210, 211)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5, 240, 241)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5, 270, 271)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5, 300, 301)
    commons.segment(color, 1.0, 64, 64, r-(13*7)+3, 5, 330, 331)

    cairo_destroy(cr)
end

