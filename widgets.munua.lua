require 'cairo'
require 'imlib2'

function air_clock(xc, yc, size)
    local offset = 0
    
    shadow_width = size * 0.03
    shadow_xoffset = 0
    shadow_yoffset = size * 0.01
    
    if shadow_xoffset >= shadow_yoffset then
        offset = shadow_xoffset
    else offset = shadow_yoffset
    end
    
    local clock_r = (size - 2 * offset) / (2 * 1.25)
        
    show_seconds=true
    
    -- Grab time
    
    local hours=os.date("%I")
    local mins=os.date("%M")
    local secs=os.date("%S")
    
    secs_arc=(2*math.pi/60)*secs
    mins_arc=(2*math.pi/60)*mins
    hours_arc=(2*math.pi/12)*hours+mins_arc/12
    
    -- Drop shadow
    
    local ds_pat=cairo_pattern_create_radial(
        xc+shadow_xoffset,
        yc+shadow_yoffset,
        clock_r*1.25,
        xc+shadow_xoffset,
        yc+shadow_yoffset,
        clock_r*1.25+shadow_width)
    cairo_pattern_add_color_stop_rgba(ds_pat,0,0,0,0,0.2)
    cairo_pattern_add_color_stop_rgba(ds_pat,1,0,0,0,0)
    
    cairo_move_to(cr,0,0)
    cairo_line_to(cr,conky_window.width,0)
    cairo_line_to(cr,conky_window.width, conky_window.height)
    cairo_line_to(cr,0,conky_window.height)
    cairo_close_path(cr)
    cairo_new_sub_path(cr)
    cairo_arc(cr,xc,yc,clock_r*1.25,0,2*math.pi)
    cairo_set_source(cr,ds_pat)
    cairo_set_fill_rule(cr,CAIRO_FILL_RULE_EVEN_ODD)
    cairo_fill(cr)
    
    -- Glassy border
    
    cairo_arc(cr,xc,yc,clock_r*1.25,0,2*math.pi)
    cairo_set_source_rgba(cr,0.5,0.5,0.5,0.2)
    cairo_set_line_width(cr,1)
    cairo_stroke(cr)
    
    local border_pat=cairo_pattern_create_linear(
        xc,yc-clock_r*1.25,xc,yc+clock_r*1.25)
    
    cairo_pattern_add_color_stop_rgba(border_pat,0,1,1,1,0.7)
    cairo_pattern_add_color_stop_rgba(border_pat,0.3,1,1,1,0)
    cairo_pattern_add_color_stop_rgba(border_pat,0.5,1,1,1,0)
    cairo_pattern_add_color_stop_rgba(border_pat,0.7,1,1,1,0)
    cairo_pattern_add_color_stop_rgba(border_pat,1,1,1,1,0.7)
    cairo_set_source(cr,border_pat)
    cairo_arc(cr,xc,yc,clock_r*1.125,0,2*math.pi)
    cairo_close_path(cr)
    cairo_set_line_width(cr,clock_r*0.25)
    cairo_stroke(cr)
    
    -- Set clock face
    
    cairo_arc(cr,xc,yc,clock_r,0,2*math.pi)
    cairo_close_path(cr)
    
    local face_pat=cairo_pattern_create_radial(
        xc,yc-clock_r*0.75,0,xc,yc,clock_r)
    
    cairo_pattern_add_color_stop_rgba(face_pat,0,1,1,1,0.9)
    cairo_pattern_add_color_stop_rgba(face_pat,0.5,1,1,1,0.9)
    cairo_pattern_add_color_stop_rgba(face_pat,1,0.9,0.9,0.9,0.9)
    cairo_set_source(cr,face_pat)
    cairo_fill_preserve(cr)
    cairo_set_source_rgba(cr,0.5,0.5,0.5,0.2)
    cairo_set_line_width(cr, 1)
    cairo_stroke (cr)
    
    -- Draw hour hand
    
    xh=xc+0.7*clock_r*math.sin(hours_arc)
    yh=yc-0.7*clock_r*math.cos(hours_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xh,yh)
    
    cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
    cairo_set_line_width(cr,5)
    cairo_set_source_rgba(cr,0,0,0,0.5)
    cairo_stroke(cr)
    
    -- Draw minute hand
    
    xm=xc+0.9*clock_r*math.sin(mins_arc)
    ym=yc-0.9*clock_r*math.cos(mins_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xm,ym)
    
    cairo_set_line_width(cr,3)
    cairo_stroke(cr)
    
    -- Draw seconds hand
    
    if show_seconds then
        xs=xc+0.9*clock_r*math.sin(secs_arc)
        ys=yc-0.9*clock_r*math.cos(secs_arc)
        cairo_move_to(cr,xc,yc)
        cairo_line_to(cr,xs,ys)
    
        cairo_set_line_width(cr,1)
        cairo_stroke(cr)
    end

    cairo_set_line_cap(cr, CAIRO_LINE_CAP_BUTT)
end

function clock_hands(xc, yc, colour, alpha, show_secs, size)
    local function rgb_to_r_g_b(colour,alpha)
        return ((colour / 0x10000) % 0x100) / 255.,
               ((colour / 0x100) % 0x100) / 255.,
               (colour % 0x100) / 255., alpha
    end
    
    local secs,mins,hours,secs_arc,mins_arc,hours_arc
    local xh,yh,xm,ym,xs,ys

    secs=os.date("%S")
    mins=os.date("%M")
    hours=os.date("%I")

    secs_arc=(2*math.pi/60)*secs
    mins_arc=(2*math.pi/60)*mins+secs_arc/60
    hours_arc=(2*math.pi/12)*hours+mins_arc/12

    xh=xc+0.4*size*math.sin(hours_arc)
    yh=yc-0.4*size*math.cos(hours_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xh,yh)

    cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
    cairo_set_line_width(cr,5)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(colour,alpha))
    cairo_stroke(cr)

    xm=xc+0.5*size*math.sin(mins_arc)
    ym=yc-0.5*size*math.cos(mins_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xm,ym)

    cairo_set_line_width(cr,3)
    cairo_stroke(cr)

    if show_secs then
        xs=xc+0.5*size*math.sin(secs_arc)
        ys=yc-0.5*size*math.cos(secs_arc)
        cairo_move_to(cr,xc,yc)
        cairo_line_to(cr,xs,ys)

        cairo_set_line_width(cr,1)
        cairo_stroke(cr)
    end

    cairo_set_line_cap(cr,CAIRO_LINE_CAP_BUTT)
end

function photo_album(album_dir, xc, yc, w_max, h_max, t, update_interval)
    local function get_file_to_use()
        num_files = tonumber(
            conky_parse("${exec ls -A " .. album_dir .. " | wc -l}"))
        if num_files == nil then num_files = 0 end
        if num_files == 0 then return "none" end
    
        updates = tonumber(conky_parse("${updates}"))
        whole = math.ceil(updates/update_interval)
    
        if whole <= num_files
        then
            num_file_to_show = whole
        else
            whole = whole % num_files
            num_file_to_show = whole
        end
    
        return conky_parse(
        "${exec ls " .. album_dir .. " | sed -n " .. num_file_to_show .. "p}")
    end

    function init_drawing_surface()
        imlib_set_cache_size(4096 * 1024)
        imlib_context_set_dither(1)
    end

    function draw_frame()
        cairo_rectangle(
            cr, xc - width/2 - t, yc - height/2 - t, width + 2*t, height + 2*t)
        cairo_set_source_rgba(cr, 1, 1, 1, 0.8)
        cairo_fill(cr)   
    end

    function draw_image()
        init_drawing_surface()
    
        image = imlib_load_image(album_dir .. filename)
        if image == nil then return end
        imlib_context_set_image(image)
    
        w_img, h_img = imlib_image_get_width(), imlib_image_get_height()
        if w_img >= h_img
        then
            width = w_max - 2*t
            height = width * (h_img/w_img)
        else
            height = h_max - 2*t
            width = height * (w_img/h_img)
        end
        
        draw_frame()
        
        buffer = imlib_create_image(width, height)
        imlib_context_set_image(buffer)
        
        imlib_blend_image_onto_image(
            image, 0, 0, 0, w_img, h_img, 0, 0, width, height)
        imlib_context_set_image(image)
        imlib_free_image()
        
        imlib_context_set_image(buffer)
        imlib_render_image_on_drawable(xc - width/2, yc - height/2)
        imlib_free_image()
    end

    if conky_window == nil then return end
    filename = get_file_to_use()
    if filename == "none"
    then
        print(album_dir .. ": No files found")
    else
        draw_image()
    end
end

function ring(name, arg, max, bgc, bga, fgc, fga, xc, yc, r, t, sa, ea)
    local function rgb_to_r_g_b(colour, alpha)
        return ((colour / 0x10000) % 0x100) / 255.,
               ((colour / 0x100) % 0x100) / 255.,
               (colour % 0x100) / 255., alpha
    end
    
    local function draw_ring(pct)
        local angle_0 = sa * (2 * math.pi/360) - math.pi/2
        local angle_f = ea * (2 * math.pi/360) - math.pi/2
        local pct_arc = pct * (angle_f - angle_0)

        -- Draw background ring

        cairo_arc(cr, xc, yc, r, angle_0, angle_f)
        cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc, bga))
        cairo_set_line_width(cr, t)
        cairo_stroke(cr)
    
        -- Draw indicator ring

        cairo_arc(cr, xc, yc, r, angle_0, angle_0 + pct_arc)
        cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))
        cairo_stroke(cr)
    end
    
    local function setup_ring()
        local str = ''
        local value = 0
        
        str = string.format('${%s %s}', name, arg)
        str = conky_parse(str)
        
        value = tonumber(str)
        if value == nil then value = 0 end
        pct = value/max
        
        draw_ring(pct)
    end    
    
    local updates = conky_parse('${updates}')
    update_num = tonumber(updates)
    
    if update_num > 5 then setup_ring() end
end

function ring_ccw(name, arg, max, bgc, bga, fgc, fga, xc, yc, r, t, sa, ea)
    local function rgb_to_r_g_b(colour, alpha)
        return ((colour / 0x10000) % 0x100) / 255.,
               ((colour / 0x100) % 0x100) / 255.,
               (colour % 0x100) / 255., alpha
    end
    
    local function draw_ring(pct)
        local angle_0 = sa * (2 * math.pi/360) - math.pi/2
        local angle_f = ea * (2 * math.pi/360) - math.pi/2
        local pct_arc = pct * (angle_f - angle_0)

        -- Draw background ring

        cairo_arc_negative(cr, xc, yc, r, angle_0, angle_f)
        cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc, bga))
        cairo_set_line_width(cr, t) 
        cairo_stroke(cr)
    
        -- Draw indicator ring

        cairo_arc_negative(cr, xc, yc, r, angle_0, angle_0 - pct_arc)
        cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))
        cairo_stroke(cr)
    end
    
    local function setup_ring()
        local str = ''
        local value = 0
        
        str = string.format('${%s %s}', name, arg)
        str = conky_parse(str)
        
        value = tonumber(str)
        if value == nil then value = 0 end
        pct = value/max
        
        draw_ring(pct)
    end    
    
    local updates = conky_parse('${updates}')
    update_num = tonumber(updates)
    
    if update_num > 5 then setup_ring() end
end

function round_rect(x0, y0, w, h, r, colour, alpha)
    local function rgb_to_r_g_b(colour, alpha)
        return ((colour / 0x10000) % 0x100) / 255.,
               ((colour / 0x100) % 0x100) / 255.,
               (colour % 0x100) / 255., alpha
    end
    
    cairo_move_to(cr, x0, y0)
    cairo_rel_move_to(cr, r, 0)
    cairo_rel_line_to(cr, w-2*r, 0)
    cairo_rel_curve_to(cr, r, 0, r, 0, r, r)
    cairo_rel_line_to(cr, 0, h-2*r)
    cairo_rel_curve_to(cr, 0, r, 0, r, -r, r)
    cairo_rel_line_to(cr, -(w-2*r), 0)
    cairo_rel_curve_to(cr, -r, 0, -r, 0, -r, -r)
    cairo_rel_line_to(cr, 0, -(h-2*r))
    cairo_rel_curve_to(cr, 0, -r, 0, -r, r, -r)
    cairo_close_path(cr)

    cairo_set_source_rgba(cr, rgb_to_r_g_b(colour, alpha))
    cairo_fill(cr)
end
    
function draw_cover(xc, yc, width, height, t, color)
    cover=string.reverse('/media/music/'..conky_parse('${mpd_file}'))
    index=string.find(cover,'/')
    cover=string.reverse(string.sub(cover,index))
        ..conky_parse('${mpd_artist}')..' - '
        ..conky_parse('${mpd_album}')..' - frontal.jpg'

    image = imlib_load_image(cover)
    if image == nil then return end

    _t=t*2
    round_rect(
        xc-((width+_t)/2),
        yc-((height+_t)/2),
        width+_t,
        height+_t,
        t, color, 0.25
    )

    imlib_context_set_image(image)

    w_img, h_img = imlib_image_get_width(), imlib_image_get_height()
    buffer = imlib_create_image(width, height)
    imlib_context_set_image(buffer)

    imlib_blend_image_onto_image(image, 0, 0, 0, w_img, h_img, 0, 0, width, height)
    imlib_context_set_image(image)
    imlib_free_image()

    imlib_context_set_image(buffer)
    imlib_render_image_on_drawable(xc - width/2, yc - height/2)
    imlib_free_image()
end

function conky_widgets()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(
        conky_window.display, conky_window.drawable, conky_window.visual,
        conky_window.width, conky_window.height)
    cr = cairo_create(cs)

    r = 128
    color = 0x1A1A1A

    round_rect(70, 194, 130, 1, 0, color, 0.5)
    round_rect(70, 351, 130, 1, 0, color, 0.5)
    round_rect(70, 460, 130, 1, 0, color, 0.5)
    round_rect(70, 547, 210, 1, 0, color, 0.5)
    round_rect(70, 680, 210, 1, 0, color, 0.5)
    round_rect(70, 921, 210, 1, 0, color, 0.5)

    round_rect(350, 350, 280, 1, 0, color, 0.5)
    round_rect(350, 519, 280, 1, 0, color, 0.5)
    round_rect(350, 818, 280, 1, 0, color, 0.5)

    clock_hands(694, 241, color, 0.8, true, 100)
    ring('time', '%I', 12, color, 0.2, color, 0.8, 694, 241, 36, 5, 0, 360)
    ring('time', '%M', 60, color, 0.2, color, 0.8, 694, 241, 26, 5, 0, 360)
    ring('time', '%S', 60, color, 0.2, color, 0.8, 694, 241, 16, 5, 0, 360)

    ring('cpu', 'cpu0', 100, color, 0.2, color, 0.8, 276, 241, r-(15*7)+3, 5,   0, 360)
    ring('cpu', 'cpu1', 100, color, 0.2, color, 0.8, 276, 241, r-(14*7)+3, 5,  30,  90)
    ring('cpu', 'cpu2', 100, color, 0.2, color, 0.8, 276, 241, r-(14*7)+3, 5, 120, 180)
    ring('cpu', 'cpu3', 100, color, 0.2, color, 0.8, 276, 241, r-(14*7)+3, 5, 210, 270)
    ring('cpu', 'cpu4', 100, color, 0.2, color, 0.8, 276, 241, r-(14*7)+3, 5, 300, 360)
    ring('cpu', 'cpu5', 100, color, 0.2, color, 0.8, 276, 241, r-(13*7)+3, 5, 360, 420)
    ring('cpu', 'cpu6', 100, color, 0.2, color, 0.8, 276, 241, r-(13*7)+3, 5, 450, 510)
    ring('cpu', 'cpu7', 100, color, 0.2, color, 0.8, 276, 241, r-(13*7)+3, 5, 540, 600)
    ring('cpu', 'cpu8', 100, color, 0.2, color, 0.8, 276, 241, r-(13*7)+3, 5, 630, 690)

    ring('memperc',  '', 100, color, 0.2, color, 0.8, 276, 355, r-(15*7), 5,  0, 360)
    ring('swapperc', '', 100, color, 0.2, color, 0.8, 276, 355, r-(14*7), 5, 90, 270)

    ring('battery_percent BAT1', '', 100, color, 0.2, color, 0.8, 276, 465, r-(14*7), 5, 0, 360)

    ring('fs_used_perc', '/',       100, color, 0.2, color, 0.8, 694, 405, r-(15*7), 5,   0, 120)
    ring('fs_used_perc', '/boot',   100, color, 0.2, color, 0.8, 694, 405, r-(14*7), 5,  60, 180)
    ring('fs_used_perc', '/home',   100, color, 0.2, color, 0.8, 694, 405, r-(13*7), 5, 120, 240)
    ring('fs_used_perc', '/usr',    100, color, 0.2, color, 0.8, 694, 405, r-(15*7), 5, 180, 300)
    ring('fs_used_perc', '/var',    100, color, 0.2, color, 0.8, 694, 405, r-(14*7), 5, 240, 360)
    ring('fs_used_perc', '/opt',    100, color, 0.2, color, 0.8, 694, 405, r-(13*7), 5, 300, 420)
    ring('fs_used_perc', '/tmp',    100, color, 0.2, color, 0.8, 694, 505, r-(15*7), 5,   0,  90)
    ring('fs_used_perc', '/docker', 100, color, 0.2, color, 0.8, 694, 505, r-(14*7), 5,  90, 180)
    ring('fs_used_perc', '/media',  100, color, 0.2, color, 0.8, 694, 505, r-(15*7), 5, 180, 270)

    if conky_parse('${mpd_status}') == 'Playing'
    then
        draw_cover(390, 950, 60, 60, 4, color)
    end
  
    ring('mpd_percent', '', 100, color, 0.2, color, 0.8, 390, 864, r-(14*7), 5, 0, 360)

    cairo_destroy(cr)
end

