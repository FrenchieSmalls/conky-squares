require 'cairo'

COLOR_FONT_R = 0.95
COLOR_FONT_G = 0.95
COLOR_FONT_B = 0.95

COLOR_PRIMARY_R = 0.698
COLOR_PRIMARY_G = 0.753
COLOR_PRIMARY_B = 0.961

COLOR_SECONDARY_R = 0.263
COLOR_SECONDARY_G = 0.404
COLOR_SECONDARY_B = 0.851

COLOR_BACKGROUND_R = 0.165
COLOR_BACKGROUND_G = 0.192
COLOR_BACKGROUND_B = 0.251

COLOR_BOX1_R = 0.216
COLOR_BOX1_G = 0.404
COLOR_BOX1_B = 0.651

COLOR_BOX2_R = 0.388
COLOR_BOX2_G = 0.420
COLOR_BOX2_B = 0.949	

function init_cairo()
  if conky_window == nil then
    return false
  end

  cs = cairo_xlib_surface_create(
    conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height)

  cr = cairo_create(cs)

  font = "Overpass"

  cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
  cairo_set_source_rgba(cr, COLOR_FONT_R, COLOR_FONT_G, COLOR_FONT_B, 1)

  return true
end

function conky_main()
  if (not init_cairo()) then
    return
  end

  -- TIME
  cairo_set_font_size(cr, 110)
  cairo_set_source_rgba(cr, COLOR_FONT_R, COLOR_FONT_G, COLOR_FONT_B, 0.9)
  cairo_move_to(cr, 55, 135)
  cairo_show_text(cr, conky_parse("${time %H:%M}"))
  cairo_stroke(cr)
  
  
  -- DATE
  cairo_set_font_size(cr, 40)
  cairo_set_source_rgba(cr, COLOR_FONT_R, COLOR_FONT_G, COLOR_FONT_B, 0.9)
  cairo_move_to(cr, 64, 180)
  local time_str = string.format('%-12s',conky_parse("${time %d/%m/%Y}"))
  cairo_show_text(cr, time_str)
  cairo_stroke(cr)

  local day_str = string.format('%-12s', conky_parse("${time %A}"))
  cairo_move_to(cr, 64, 220)
  cairo_show_text(cr, day_str)
  cairo_stroke(cr)


  -- GREETING
  hour = tonumber(string.format('%-12s',conky_parse("${time %H}")))
  if hour < 12 then
	this_time = "morning"
  elseif hour > 17 then
	this_time = "evening"
  else
	this_time = "afternoon"
  end

  local greeting_str = string.format("Good "..this_time..", Chris")
  cairo_set_font_size(cr, 40)
  cairo_move_to(cr, 63, 295)
  cairo_show_text(cr, greeting_str)
  cairo_stroke(cr)
  

  -- CPU GRAPH
  -- Non-linear (sqrt instead) so graph area approximatly matches usage
  
  local cx,cy = 1049,271
  local height = 211
  local width = 44
  local gap = 12

  local cpu0 = 0.05 + math.sqrt(tonumber(conky_parse("${cpu cpu0}")) / 100.0) * 0.95
  local cpu1 = 0.05 + math.sqrt(tonumber(conky_parse("${cpu cpu1}")) / 100.0) * 0.95
  local cpu2 = 0.05 + math.sqrt(tonumber(conky_parse("${cpu cpu2}")) / 100.0) * 0.95
  local cpu3 = 0.05 + math.sqrt(tonumber(conky_parse("${cpu cpu3}")) / 100.0) * 0.95
  local cpu4 = 0.05 + math.sqrt(tonumber(conky_parse("${cpu cpu4}")) / 100.0) * 0.95


  -- CPU (total)
  cairo_set_source_rgba(cr, COLOR_SECONDARY_R, COLOR_SECONDARY_G, COLOR_SECONDARY_B, 1)
  cairo_move_to(cr, cx, cy)
  cairo_rel_line_to(cr, 4*width + 3*gap, 0)
  cairo_rel_line_to(cr, 0, -height*cpu0)
  cairo_rel_line_to(cr, -4*width - 3*gap, 0)
  cairo_rel_line_to(cr, 0, height*cpu0)
  cairo_fill(cr)


  -- CPU 1
  cairo_set_source_rgba(cr, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 1)
  cairo_move_to(cr, cx, cy)
  cairo_rel_line_to(cr, width, 0)
  cairo_rel_line_to(cr, 0, -height*cpu1)
  cairo_rel_line_to(cr, -width, 0)
  cairo_fill(cr)


  -- CPU 2
  cairo_set_source_rgba(cr, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 1)
  cairo_move_to(cr, cx + width + gap, cy)
  cairo_rel_line_to(cr, width, 0)
  cairo_rel_line_to(cr, 0, -height*cpu2)
  cairo_rel_line_to(cr, -width, 0)
  cairo_fill(cr)


  -- CPU 3
  cairo_set_source_rgba(cr, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 1)
  cairo_move_to(cr, cx + 2*width + 2*gap, cy)
  cairo_rel_line_to(cr, width, 0)
  cairo_rel_line_to(cr, 0, -height*cpu3)
  cairo_rel_line_to(cr, -width, 0)
  cairo_fill(cr)


  -- CPU 4
  cairo_set_source_rgba(cr, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 1)
  cairo_move_to(cr, cx + 3*width + 3*gap, cy)
  cairo_rel_line_to(cr, width, 0)
  cairo_rel_line_to(cr, 0, -height*cpu4)
  cairo_rel_line_to(cr, -width, 0)
  cairo_fill(cr)

  
  -- MEMORY
  
  local memperc = tonumber(conky_parse("$memperc"))

  local row,col = 0,0
  local rows = 5
  local perc = 0.0
  local perc_incr = 100.0 / 40.0
  local cx,cy = 520,495
  local grid_width = 36
  for i = 1,40 do
    if (memperc > perc) then
      cairo_set_source_rgba(cr, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 1)
      cairo_rectangle(cr, cx-grid_width/4, cy-grid_width/4, grid_width/2, grid_width/2)
    else
      cairo_set_source_rgba(cr, COLOR_SECONDARY_R, COLOR_SECONDARY_G, COLOR_SECONDARY_B, 1)
      cairo_rectangle(cr, cx-grid_width/10, cy-grid_width/10, grid_width/5, grid_width/5)
    end
    cairo_fill(cr)

    row = row + 1
    cy = cy + grid_width
    if (row >= rows) then
      row = row - rows
      cy = cy - rows*grid_width
      col = col + 1
      cx = cx + grid_width
    end
    perc = perc + perc_incr
  end



  -- RANDOMIZED BACKGROUND SQUARES
  --rand_col = math.random()
  --rand_box(rand_col,29,687,320)
  
  --rand_col = math.random()
  --rand_box(rand_col,29,687,433)
 
  --rand_col = math.random()
  --rand_box(rand_col,29,828,433)

  --rand_col = math.random()
  --rand_box(rand_col,29,800,320)

  --rand_col = math.random()
  --rand_box(rand_col,29,800,461)

  --rand_col = math.random()
  --rand_box(rand_col,29,857,575)

  --rand_col = math.random()
  --rand_box(rand_col,29,970,547)

  --rand_col = math.random()
  --rand_box(rand_col,29,1027,644)

  --rand_col = math.random()
  --rand_box(rand_col,29,998,519)

  --rand_col = math.random()
  --rand_box(rand_col,29,1027,490)

  --rand_col = math.random()
  --rand_box(rand_col,29,1055,320)

  --rand_col = math.random()
  --rand_box(rand_col,29,1167,320)

  --rand_col = math.random()
  --rand_box(rand_col,29,1252,461)

  --rand_col = math.random()
  --rand_box(rand_col,29,913,320)

  --rand_col = math.random()
  --rand_box(rand_col,29,998,264)



  -- BATTERY PERCENTAGE

  batt = tonumber(conky_parse("${battery_percent BAT0}"))

  local cx,cy = 1160,441
  local width,height = 100,100
  local filled_height = batt
  local line_width = 5

  cairo_set_source_rgba(cr, COLOR_BOX2_R, COLOR_BOX2_G, COLOR_BOX2_B, 1)
  cairo_move_to(cr, cx, cy)
  cairo_rel_line_to(cr, width, 0)
  cairo_rel_line_to(cr, 0, -height)
  cairo_rel_line_to(cr, -width, 0)
  cairo_fill(cr)

  cairo_set_source_rgba(cr, COLOR_BOX1_R, COLOR_BOX1_G, COLOR_BOX1_B, 1)
  cairo_move_to(cr, cx, cy)
  cairo_rel_line_to(cr, width, 0)
  cairo_rel_line_to(cr, 0, -filled_height)
  cairo_rel_line_to(cr, -width, 0)
  cairo_fill(cr)
end




-- FILE SYSTEM

function conky_fs_main()
  if (not init_cairo()) then
    return
  end

  local offset = 1048
  local gap = 79
  local dn = dbox_used("${exec du -hs /home/chris/Dropbox/ | head -n1 | awk '{print $1}'}")

  draw_volume("             /", tonumber(conky_parse("${fs_used_perc /}")) , offset)
  draw_volume("    Backups", tonumber(conky_parse("${fs_used_perc /media/chris/Backups/}")) , offset + gap)
  
  draw_volume("    Dropbox", dn , offset + 2*gap)
  

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr = nil
end



function dbox_used(arg)
  local str = conky_parse(arg)
  local n = tonumber(str:sub(1,-2)) / 2.5
  return n*100
end


function rand_box(rand_col,box_size,cx,cy)
  if (rand_col < 0.2) then
    cairo_set_source_rgba(cr, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 1)
  elseif (rand_col >= 0.2 and rand_col < 0.4) then
    cairo_set_source_rgba(cr, COLOR_SECONDARY_R, COLOR_SECONDARY_G, COLOR_SECONDARY_B, 1)
  elseif (rand_col >= 0.4 and rand_col < 0.6) then
    cairo_set_source_rgba(cr, COLOR_BOX1_R, COLOR_BOX1_G, COLOR_BOX1_B, 1)
  elseif (rand_col >= 0.6 and rand_col < 0.8) then
    cairo_set_source_rgba(cr, COLOR_BOX2_R, COLOR_BOX2_G, COLOR_BOX2_B, 1)
  else
    cairo_set_source_rgba(cr, COLOR_BACKGROUND_R, COLOR_BACKGROUND_G, COLOR_BACKGROUND_B, 1) 
  end
  cairo_rectangle(cr, cx-box_size/4, cy-box_size/4, box_size/2, box_size/2)
  cairo_fill(cr)
end


function draw_volume(name, used, cx)
  local cy = 652
  local width,height = 55,15
  local volume_height = 140
  local filled_height = volume_height * used / 100
  local line_width = 5

  cairo_set_source_rgba(cr, COLOR_SECONDARY_R, COLOR_SECONDARY_G, COLOR_SECONDARY_B, 1)
  cairo_move_to(cr, cx, cy)
  cairo_rel_line_to(cr, width, 0)
  cairo_rel_line_to(cr, 0, -volume_height)
  cairo_rel_line_to(cr, -width, 0)
  cairo_fill(cr)

  cairo_set_source_rgba(cr, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 1)
  cairo_move_to(cr, cx, cy)
  cairo_rel_line_to(cr, width, 0)
  cairo_rel_line_to(cr, 0, -filled_height)
  cairo_rel_line_to(cr, -width, 0)
  cairo_fill(cr)

  -- Drive name
  cairo_set_source_rgba(cr, COLOR_PRIMARY_R, COLOR_PRIMARY_G, COLOR_PRIMARY_B, 1)
  cairo_move_to(cr, cx, cy - volume_height -5)
  cairo_show_text(cr, name)
  cairo_stroke(cr)
end
