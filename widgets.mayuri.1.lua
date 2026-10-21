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

    commons.ring('cpu', 'cpu0',  100, color, 0.2, color, 1.0, 266, 155, r-(16*7)+3, 5,   0, 360)
    commons.ring('cpu', 'cpu1',  100, color, 0.2, color, 1.0, 266, 235, r-(16*7)+3, 5,   0,  90)
    commons.ring('cpu', 'cpu2',  100, color, 0.2, color, 1.0, 266, 235, r-(16*7)+3, 5,  90, 180)
    commons.ring('cpu', 'cpu3',  100, color, 0.2, color, 1.0, 266, 235, r-(16*7)+3, 5, 180, 270)
    commons.ring('cpu', 'cpu4',  100, color, 0.2, color, 1.0, 266, 235, r-(16*7)+3, 5, 270, 360)
    commons.ring('cpu', 'cpu5',  100, color, 0.2, color, 1.0, 266, 315, r-(16*7)+3, 5,   0,  90)
    commons.ring('cpu', 'cpu6',  100, color, 0.2, color, 1.0, 266, 315, r-(16*7)+3, 5,  90, 180)
    commons.ring('cpu', 'cpu7',  100, color, 0.2, color, 1.0, 266, 315, r-(16*7)+3, 5, 180, 270)
    commons.ring('cpu', 'cpu8',  100, color, 0.2, color, 1.0, 266, 315, r-(16*7)+3, 5, 270, 360)
    commons.ring('cpu', 'cpu9',  100, color, 0.2, color, 1.0, 266, 395, r-(16*7)+3, 5,   0,  90)
    commons.ring('cpu', 'cpu10', 100, color, 0.2, color, 1.0, 266, 395, r-(16*7)+3, 5,  90, 180)
    commons.ring('cpu', 'cpu11', 100, color, 0.2, color, 1.0, 266, 395, r-(16*7)+3, 5, 180, 270)
    commons.ring('cpu', 'cpu12', 100, color, 0.2, color, 1.0, 266, 395, r-(16*7)+3, 5, 270, 360)
    commons.ring('cpu', 'cpu13', 100, color, 0.2, color, 1.0, 266, 475, r-(16*7)+3, 5,   0,  90)
    commons.ring('cpu', 'cpu14', 100, color, 0.2, color, 1.0, 266, 475, r-(16*7)+3, 5,  90, 180)
    commons.ring('cpu', 'cpu15', 100, color, 0.2, color, 1.0, 266, 475, r-(16*7)+3, 5, 180, 270)
    commons.ring('cpu', 'cpu16', 100, color, 0.2, color, 1.0, 266, 475, r-(16*7)+3, 5, 270, 360)

    commons.ring('memperc',  '', 100, color, 0.2, color, 1.0, 266, 555, r-(16*7)+3, 5,   0, 360)
    commons.ring('swapperc', '', 100, color, 0.2, color, 1.0, 266, 635, r-(16*7)+3, 5,   0, 360)

    commons.round_rect(  5, 157, 200, 2, 0, color, 1.0)
    commons.round_rect(  5, 537, 200, 2, 0, color, 1.0)
    commons.round_rect(  5, 677, 200, 2, 0, color, 1.0)

    cairo_destroy(cr)
end

