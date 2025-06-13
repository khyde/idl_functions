pro add_data, lon, lat, smap, omodel, name, $
  longitude = longitude, polyline=poly, $
  color = color, thick = thick

; Transform from lat/lon to x/y cartesian.
  griduv = map_proj_forward(lon, lat, $
    map=smap, polylines = gridpoly, connectivity=poly)
  if (n_elements(griduv) lt 2) then $
    return
; Create the polyline object.
  opoly = obj_new('idlgrpolyline', griduv, $
    polyline = gridpoly,name = name, color = color, $
    thick = thick)
  omodel->add, opoly
end

pro att_event, event
  widget_control, event.top, get_uvalue = temp_state, /no_copy
  widget_control, temp_state.b_arr[temp_state.sel], set_button = 0
  widget_control, event.id, get_uvalue = uval
  reads, uval, temp
  widget_control, temp_state.b_arr[temp], set_button = 1
  temp_state.sel = temp
  widget_control, event.top, tlb_get_offset = xy
  widget_control, temp_state.tlb, get_uvalue = state, /no_copy
  widget_control, temp_state.text, set_value = temp_state.att_str[temp,*], $
    set_list_select = state.map_info.ind
  widget_control, event.top, tlb_set_xoffset = xy[0], tlb_set_yoffset = xy[1]
  widget_control, temp_state.tlb, set_uvalue = state, /no_copy
  widget_control, event.top, set_uvalue = temp_state, /no_copy
end

function build_view, map_info, new = new, grid = grid
  compile_opt idl2
  widget_control, hourglass = 1
  if not keyword_set(over) then begin
    temp = map_info.omodel -> get(/all)
    map_info.omodel -> Remove, /all
    if obj_valid(temp[0]) then obj_destroy, temp
  endif
  map_info.owindow -> erase
  smap = initialize_map(map_info)
  if keyword_set(new) then begin
    map_info.oview -> setproperty, $
      viewplane_rect = [smap.uv_box[0], $
                        smap.uv_box[1], $
                        smap.uv_box[2]-smap.uv_box[0], $
                        smap.uv_box[3]-smap.uv_box[1]]
    map_info.drag_view -> setproperty, $
      viewplane_rect = [smap.uv_box[0], $
                        smap.uv_box[1], $
                        smap.uv_box[2]-smap.uv_box[0], $
                        smap.uv_box[3]-smap.uv_box[1]]
  endif

  oshape = obj_new('idlffshape', map_info.file)
  oshape -> getproperty, n_entities = num_ent

; Add the data from the shape file.
  for i = 0L, num_ent-1 do begin
    ent = oshape -> getentity(i,/attribute)
    for j = 0, ent.n_parts-1 do begin
      v_start = (*ent.parts)[j]
      if j ne ent.n_parts-1 then begin
        v_end = (*ent.parts)[j+1]
      endif else begin
        v_end = ent.n_vertices
      endelse
      nv=v_end-v_start
      if (j eq 0) then poly=[nv,lindgen(nv)+v_start] $
      else poly=[poly,nv,lindgen(nv)+v_start]
    endfor

    map_info.num_att = n_tags(*ent.attributes)
    if i eq 0 then begin
      *map_info.att_str = strarr(map_info.num_att, num_ent)
      oshape -> getproperty, attribute_names = att_names
      *map_info.att_names = att_names
    endif
    k = 0
    for l = 0, map_info.num_att-1 do $
      (*map_info.att_str)[l,i] = $
      strcompress((*ent.attributes).(l), /remove_all)
    add_data, (*ent.vertices)[0,*], (*ent.vertices)[1,*], smap, $
      polyline=poly,map_info.omodel, (*ent.attributes).(k)
    ptr_free, ent.vertices, ent.parts, ent.attributes
  endfor

  if keyword_set(grid) then begin
  ; Add latitude lines.
    gridlon = dindgen(361) - 180
    latitude = 15*(indgen(11) - 5)
    for i = 0,(n_elements(latitude) - 1) do begin
      lat = latitude[i]
      gridlat = replicate(lat, 361)
      add_data, gridlon, gridlat, $
      smap, map_info.omodel, color = [180,180,180]
    endfor

  ; Add longitude lines.
    gridlat = dindgen(181) - 90
    longitude = [20*(dindgen(18) - 9), $
    -179.999d, -20.001d, -100.001d, -40.001d, 80.001d]
    for i = 0,n_elements(longitude) - 1 do begin
      lon = longitude[i]
      gridlon = replicate(lon, 181)
      add_data, gridlon, gridlat, $
        smap, map_info.omodel, /longitude, $
        color = [180,180,180]
    endfor
  endif

  if map_info.ind ne -1 then begin
    map_info.temp_obj = map_info.omodel -> get(position = map_info.ind)
    map_info.temp_obj -> setproperty, color = [255,0,0], $
      thick = map_info.thick
    endif
  obj_destroy, oshape
  map_info.smap = smap
  widget_control, hourglass = 0
  return, map_info
end

function center_lat, str
  no_center_lat = ['Goodes Homolosine', $
                   'Mercator', $
                   'Sinusoidal', $
                   'Equirectangular', $
                   'Miller Cylindrical', $
                   'Robinson', $
                   'Space Oblique Mercator A', $
                   'Space Oblique Mercator B', $
                   'Interrupted Goode', $
                   'Mollweide', $
                   'Interrupted Mollweide', $
                   'Hammer', $
                   'Wagner IV', $
                   'Wagner VII']
  if where(no_center_lat eq str) eq -1 then return, 2 else return, 0
end

function center_lon, str
  no_center_lon = ['Space Oblique Mercator A', $
                   'Space Oblique Mercator B', $
                   'Interrupted Goode', $
                   'Interrupted Mollweide']
  if where(no_center_lon eq str) eq -1 then return, 1 else return, 0
end

function check_input, str, ll
  temp = byte(strcompress(str))

; Only allow one "."
  result = where(temp eq 46, cnt)
  if cnt gt 1 then return, 999

; Only allow one "-"
  result = where(temp eq 45, cnt)
  if cnt gt 1 then return, 999
  if result gt 1 then return, 999

  for i = 0, n_elements(temp)-1 do begin
  ; Only allow chars "0","1",...,"9","." and "-"
    if ((byte(strcompress(str)))[i] gt 57) or $
      (((byte(strcompress(str)))[i] lt 45) and $
      ((byte(strcompress(str)))[i] ne 32))then $
      return, 999

  ; Exclude "/" character
    if ((byte(strcompress(str)))[i] eq 47) then return, 999
  endfor
  reads, str, var

; Verify value : -180<=lat<=180 and -360<=lon<=360
  if ((ll mod 2) eq 0) then begin ; latitude
    if (abs(var) gt 180) then return, 999
  endif else begin ; longitude
    if (abs(var) gt 360) then return, 999
  endelse
  return, double(var)
end

pro clean, tlb
  widget_control, tlb, get_uvalue = state, /no_copy
  if n_elements(state) gt 0 then begin
    obj_destroy, state.map_info.drag_view
    heap_free, state.map_info
  endif
end

pro clean_att, tlb
  widget_control, tlb, get_uvalue = temp_state
  if widget_info(temp_state.tlb, /valid) then begin
    widget_control, temp_state.tlb, get_uvalue = state, /no_copy
    if n_tags(state) gt 0 then begin
      if obj_valid(state.map_info.temp_obj) then begin
        state.map_info.temp_obj -> setproperty, $
          color = [0,0,0], thick = 1
        state.map_info.owindow -> draw, state.map_info.oview
        state.map_info.ind = -1
      endif
    endif
    widget_control, temp_state.tlb, set_uvalue = state, /no_copy
  endif
end

pro context_event, event
  widget_control, event.top, get_uvalue = state, /no_copy
  if state.proj_sel gt 0 then $
    widget_control, state.proj_sel, set_button = 0
  state.proj_sel = event.id
  widget_control, event.id, get_uvalue = uval, set_button = 1
  widget_control, state.proj_str, set_value = uval
  state.map_info.proj = uval
  map_info = build_view(state.map_info, grid = state.grid, /new)
  state.map_info = map_info
  map_info.owindow -> draw, map_info.oview
  widget_control, event.top, set_uvalue = state, /no_copy
end

pro draw_event, event
  widget_control, event.top, get_uvalue = state, /no_copy
  if size(state, /type) eq 0 then return
  case event.press of
    0: begin; Motion/Release
      result = state.map_info.owindow -> pickdata(state.map_info.oview, $
        state.map_info.omodel, [event.x,event.y], xy)
      lonlat = map_proj_inverse(xy, map = state.map_info.smap)
      widget_control, state.cursor_lon, set_value = string(lonlat[0], $
        format = '(f9.4)')
      widget_control, state.cursor_lat, set_value = string(lonlat[1], $
        format = '(f9.4)')
      if (event.release eq 1) $
      and (state.map_info.drag eq 1) then begin ; Release
        thresh = 10
        state.map_info.drag = 0
        state.map_info.drag_poly -> setproperty, color = [255,255,255]
        state.map_info.drag_poly -> getproperty, data = new_vpr
        xmin = min(new_vpr[0,*], max = xmax)
        ymin = min(new_vpr[1,*], max = ymax)
        if (xmax-xmin gt thresh) and (ymax-ymin gt thresh) then begin
          state.map_info.oview -> setproperty, viewplane_rect = $
            [xmin, ymin, xmax-xmin, ymax-ymin]
          state.map_info.drag_view -> setproperty, viewplane_rect = $
            [xmin, ymin, xmax-xmin, ymax-ymin]
          state.map_info.owindow -> draw, state.map_info.oview
          temp = map_proj_inverse([xmin,xmax], [ymin,ymax], $
            map = state.map_info.smap)
          state.map_info.limit = [temp[1,0], temp[0,0], temp[1,1], temp[0,1]]
        endif
      endif
      if state.map_info.drag eq 1 then begin ; Dragging
          state.map_info.drag_poly -> setproperty, data = $
          [[xy[0], xy[1]], $
           [state.map_info.drag_point[0], xy[1]], $
           [state.map_info.drag_point[0], state.map_info.drag_point[1]], $
           [xy[0], state.map_info.drag_point[1]], $
           [xy[0], xy[1]]], color = [0,255,127]

        state.map_info.owindow -> draw, state.map_info.drag_view, $
          /draw_instance
      endif
    end
    1: begin ; Press
      state.map_info.drag = 1
      result = state.map_info.owindow -> pickdata(state.map_info.oview, $
        state.map_info.omodel, [event.x,event.y], temp)
      state.map_info.drag_point = temp[0:1]
      state.map_info.drag_poly -> setproperty, $
        data = [[temp[0:1]], [temp[0:1]]]
      state.map_info.owindow -> draw, state.map_info.oview, $
        create_instance = 1
    end
    4: widget_displaycontextmenu, event.id, event.x, $ ; Right click
      event.y, state.contextbase
    else:
  endcase
  widget_control, event.top, set_uvalue = state, /no_copy
end

pro file_event, event
  compile_opt idl2
  widget_control, event.top, get_uvalue = state, /no_copy
  widget_control, event.id, get_uvalue = uval
  case uval[0] of
    'Open': begin
      file = get_file(path = state.shape_path)
      if obj_valid(state.map_info.temp_obj) then begin
        state.map_info.temp_obj -> setproperty, color = [0,0,0], thick = 1
        state.map_info.ind = -1
      endif
      if file eq '' then begin
        widget_control, event.top, set_uvalue = state, /no_copy
        return
      endif else begin
        state.map_info.file = file
        map_info = build_view(state.map_info, grid = state.grid)
        state.map_info = map_info
      endelse
      if widget_info(state.base, /valid) $
        then widget_control, state.base, /destroy
      state.map_info.owindow -> draw, state.map_info.oview
    end
    'Preferences': begin
      case uval[1] of
        ' 0': begin
          state.grid = 1 - state.grid
          map_info = build_view(state.map_info, grid = state.grid)
          map_info.owindow -> draw, map_info.oview
          state.map_info = map_info
        end
        else:
      endcase
      temp = 0b
      reads, uval[1], temp
      state.pref_select[temp] = 1b - state.pref_select[temp]
      widget_control, state.pref_arr[temp], $
        set_button = state.pref_select[temp]
    end ; preferences
    'Exit': begin
      widget_control, event.top, /destroy
      obj_destroy, state.map_info.drag_view
      heap_free, state.map_info
      return
    end
    else:
  endcase
  widget_control, event.top, set_uvalue = state, /no_copy
end

function get_file, path = path, $ ; Where to search
                   default = default
  file = dialog_pickfile(path = path, $
    filter='*.shp', /must_exist)
  if strlen(file) gt 0 then return, file $
  else begin
    if keyword_set(default) then begin
      file = filepath('states.shp', subdir = ['examples', 'data'])
      if (file_info(file)).exists eq 0 then return, '' $
      else return, file
    endif
  endelse
end

function initialize_map, map_info
  c = center_lon(map_info.proj) + center_lat(map_info.proj)
  case c of
    0: return, map_proj_init(map_info.proj, limit = map_info.limit)
    1: return, map_proj_init(map_info.proj, limit = map_info.limit, $
      center_longitude = map_info.center[1])
    2:
    3: return, map_proj_init(map_info.proj, limit = map_info.limit, $
      center_longitude = map_info.center[1], $
      center_latitude = map_info.center[0])
  endcase
end

pro locate_event, event
  widget_control, event.top, get_uvalue = state, /no_copy
  if not widget_info(state.base, /valid_id) then begin
    base = widget_base(group_leader = event.top, title = 'Attributes', $
      xoff = 610, yoff = 0, mbar = menu, kill_notify = 'clean_att')
    att_button = widget_button(menu, value = 'Attribute', $
      /menu, event_pro = 'att_event')
    b_arr = lonarr(state.map_info.num_att)
    for i = 0, n_elements(b_arr)-1 do b_arr[i] = $
      widget_button(att_button, value = (*state.map_info.att_names)[i], $
      uvalue = strcompress(i, /remove_all), /checked_menu)

    text = widget_list(base, xs = 50, ys = 40, $
      value = (*state.map_info.att_str)[0,*], $
      event_pro = 'text_event')

    widget_control, base, /realize
    widget_control, b_arr[0], /set_button
    temp_state = {tlb:event.top, $
                  text:text, $
                  b_arr:b_arr, $
                  sel:0, $
                  att_str:*state.map_info.att_str}
    widget_control,  base, set_uvalue = temp_state
    state.base = base
  endif
  widget_control, event.top, set_uvalue = state, /no_copy
end

pro shape_map_viewer_event, event
  widget_control, event.top, get_uvalue = state, /no_copy
  widget_control, event.top, xs = event.x, ys = event.y
  widget_control, state.draw, xs = event.x-10, ys = event.y - 120
  widget_control, state.work_base, xs = event.x-10, ys = 85
  state.map_info.owindow -> draw, state.map_info.oview
  widget_control, event.top, set_uvalue = state, /no_copy
end

pro text_event, event
  widget_control, event.top, get_uvalue = temp_state, /no_copy
  widget_control, temp_state.tlb, get_uvalue = state, /no_copy
  if state.map_info.ind ne -1 then begin
    state.map_info.temp_obj = state.map_info.omodel -> $
      get(position = state.map_info.ind)
    state.map_info.temp_obj -> setproperty, color = [0,0,0], thick=1
  endif
  state.map_info.ind = event.index
  state.map_info.temp_obj = state.map_info.omodel -> $
    get(position = event.index)
  if obj_valid(state.map_info.temp_obj) then $
    state.map_info.temp_obj -> setproperty, color = [255,0,0], $
    thick = state.map_info.thick
  state.map_info.owindow -> draw, state.map_info.oview
  widget_control, temp_state.tlb, set_uvalue = state, /no_copy
  widget_control, event.top, set_uvalue = temp_state, /no_copy
end

pro work_event, event
  widget_control, event.id, get_uvalue = uval
  if n_elements(uval) gt 0 then begin
    widget_control, event.top, get_uvalue = state, /no_copy
    case uval of
      'redraw': begin ; redraw the map using current limit
                      ; and center settings (in text widgets).
        wid_arr = [state.clat, state.clon, $
                   state.limit0_lat, state.limit0_lon, $
                   state.limit1_lat, state.limit1_lon]
        info_arr = dblarr(n_elements(wid_arr))
        for i = 0, n_elements(wid_arr)-1 do begin
          widget_control, wid_arr[i], get_value = tempstr

          chk = check_input(tempstr, i)
          if (chk eq 999) then begin ; Valid characters?
            strs = ['Center Latitude', 'Center Longitude', $
                    'Limit0 Latitude', 'Limit1 Latitude', $
                    'Limit0 Longitude', 'Limit1 Longitude']
            widget_control, wid_arr[i], get_uvalue = tempval
            case tempval of
              'clat': val = [0,state.map_info.center[0]]
              'clon': val = [1,state.map_info.center[1]]
              'l0lat': val = [2, state.map_info.limit[0]]
              'l0lon': val = [3,state.map_info.limit[1]]
              'l1lat': val = [4, state.map_info.limit[2]]
              'l1lon': val = [5,state.map_info.limit[3]]
            endcase
            void = dialog_message([strs[val[0]] + $
              ' value is incorrect...', 'Resetting to ' + $
              strcompress(val[1]) + '.'], /info)
            temp = val[1]
            widget_control, wid_arr[i], set_value = $
              strcompress(val[1], /remove_all)
          endif else info_arr[i] = chk
        endfor
        state.map_info.center = info_arr[0:1]
        mnlat = min(info_arr[[2,4]], max = mxlat)
        mnlon = min(info_arr[[3,5]], max = mxlon)
        state.map_info.limit = [mnlat,mnlon,mxlat,mxlon]
        vpr = map_proj_forward([mnlon,mxlon], [mnlat,mxlat], $
          map = state.map_info.smap)
        state.map_info.oview -> setproperty, viewplane_rect = $
          [vpr[0,0], vpr[1,0], vpr[0,1]-vpr[0,0], vpr[1,1]-vpr[1,0]]
        state.map_info.drag_view -> setproperty, viewplane_rect = $
          [vpr[0,0], vpr[1,0], vpr[0,1]-vpr[0,0], vpr[1,1]-vpr[1,0]]
        map_info = build_view(state.map_info, grid = state.grid, /new)
        state.map_info = map_info
        state.map_info.owindow -> draw, state.map_info.oview
      end
      'reset': begin ; reset the limits and center
        state.map_info.limit = [-90d,-180,90,180]
        state.map_info.center = [0d,0]
        widget_control, state.clat, set_value = ' 00.00000'
        widget_control, state.clon, set_value = ' 00.00000'
        widget_control, state.limit0_lat, set_value = ' -90.0000'
        widget_control, state.limit1_lat, set_value = ' 90.00000'
        widget_control, state.limit0_lon, set_value = ' -180.000'
        widget_control, state.limit1_lon, set_value = ' 180.0000'
        map_info = build_view(state.map_info, grid = state.grid, /new)
        state.map_info = map_info
        state.map_info.owindow -> draw, state.map_info.oview
      end
      'set': begin ; set limits to match the viewplane_rect
        widget_control, state.clat, set_value = $
          strcompress(state.map_info.center[0], /remove_all)
        widget_control, state.clon, set_value = $
          strcompress(state.map_info.center[1], /remove_all)
        widget_control, state.limit0_lat, set_value = $
          strcompress(state.map_info.limit[0], /remove_all)
        widget_control, state.limit1_lat, set_value = $
          strcompress(state.map_info.limit[2], /remove_all)
        widget_control, state.limit0_lon, set_value = $
          strcompress(state.map_info.limit[1], /remove_all)
        widget_control, state.limit1_lon, set_value = $
          strcompress(state.map_info.limit[3], /remove_all)
        widget_control, event.top, set_uvalue = state, /no_copy
        return
      end
      else:
    endcase
    widget_control, event.top, set_uvalue = state, /no_copy
  endif
end

pro shape_map_viewer, file = file
  xs = 600 & ys = 500
  tlb = widget_base(col = 1, mbar = menu, xs = xs, ys = ys, $
    title = 'ShapeFile Viewer v0.1', /tlb_size_events)
  file_button = widget_button(menu, value = 'File', /menu, $
    event_pro = 'file_event')
  new_file = widget_button(file_button, value = 'Open File', $
    uvalue = 'Open')
  pref_button = widget_button(file_button, value = 'Preferences', $
    /menu, /checked_menu)
  prefstr = ['Grid']
  pref_arr = lonarr(n_elements(prefstr))
  pref_select = bytarr(n_elements(prefstr))
  for i = 0, n_elements(prefstr)-1 do $
    pref_arr[i] = widget_button(pref_button, value = prefstr[i], $
    uvalue = ['Preferences', strcompress(i), prefstr[i]], /checked_menu)
  exit_button = widget_button(file_button, value = 'Exit', $
    uvalue = 'Exit')

  work_base = widget_base(tlb, xs = xs*4.99/5, ys = 85, $
    event_pro = 'work_event')
  label_center = widget_label(work_base, value = 'Center', $
    xs = 45, ys = 15, xoff = 70, yoff = 0)
  label_limit0 = widget_label(work_base, value = 'Limit #1', $
    xs = 50, ys = 15, xoff = 135, yoff = 0)
  label_limit0 = widget_label(work_base, value = 'Limit #2', $
    xs = 50, ys = 15, xoff = 200, yoff = 0)

  lat_label = widget_label(work_base, value = 'Latitude:', $
    xs = 60, ys = 15, xoff = 5, yoff = 25)
  clat = widget_text(work_base, value = '00.0000', /editable, $
    xs = 7, ys = 1, xoff = 70, yoff = 20, uvalue = 'clat')
  limit0_lat = widget_text(work_base, value = '-90.000', /editable, $
    xs = 7, ys = 1, xoff = 135, yoff = 20, uvalue = 'l0lat')
  limit1_lat = widget_text(work_base, value = '90.0000', /editable, $
    xs = 7, ys = 1, xoff = 200, yoff = 20, uvalue = 'l1lat')

  lon_label = widget_label(work_base, value = 'Longitude:', $
    xs = 60, ys = 15, xoff = 5, yoff = 55)
  clon = widget_text(work_base, value = '00.0000', /editable, $
    xs = 7, ys = 1, xoff = 70, yoff = 50, uvalue = 'clon')
  limit0_lon = widget_text(work_base, value = '-180.00', /editable, $
    xs = 7, ys = 1, xoff = 135, yoff = 50, uvalue = 'l0lon')
  limit1_lon = widget_text(work_base, value = '180.000', /editable, $
    xs = 7, ys = 1, xoff = 200, yoff = 50, uvalue = 'l1lon')

  set_limits = widget_button(work_base, value = 'Set Limits', $
    xs = 70, ys = 20, xoff = 270, yoff = 0, uvalue = 'set', $
    tooltip = 'Set limits to match the view.')
  redraw_button = widget_button(work_base, value = 'Redraw', $
    xs = 70, ys = 20, xoff = 270, yoff = 25, uvalue = 'redraw', $
    tooltip = 'Redraw the map using the specified limits.')
  reset_button = widget_button(work_base, value = 'Reset Map', $
    xs = 70, ys = 20, xoff = 270, yoff = 50, uvalue = 'reset', $
    tooltip = 'Reset the map limits to [-90,-180,90,180] and redraw.')

  info_base = widget_base(work_base, $
    xs = 260, ys = 80, xoff = 360, yoff = 0)
  proj_label = widget_label(info_base, value = 'Projection:', $
    xs = 65, ys = 20, xoff = 0, yoff = 0)
  proj_str = widget_label(info_base, value = 'Equirectangular', $
    /dynamic_resize, xoff = 70, yoff = 0)

  locate_button = widget_button(info_base, value = 'Locate', $
    xs = 70, ys = 20, xoff = 55, yoff = 25, $
    event_pro = 'locate_event', tooltip = 'Locate features on the map.')

  cltln = widget_label(info_base, value = ' Latitude / Longitude', $
    xs = 140, ys = 15, xoff = 30, yoff = 50)
  cursor_lat = widget_label(info_base, value = '', $
    xs = 52, ys = 15, xoff = 30, yoff = 65)
  spc = widget_label(info_base, value = ' /', $
    xs = 10, ys = 15, xoff = 82, yoff = 65)
  cursor_lon = widget_label(info_base, value = '', $
    xs = 52, ys = 15, xoff = 92, yoff = 65)

; No tool tips in Unix draw widget...
  if strlowcase(!version.os_family) eq 'unix' then $
    draw = widget_draw(tlb, xs = xs*4.99/5, ys = ys*4./5, $
      graphics_level = 2, /button_events, /motion_events, $
      event_pro = 'draw_event', retain = 2, renderer = 1) $
  else $
    draw = widget_draw(tlb, xs = xs*4.99/5, ys = ys*4./5, $
      graphics_level = 2, /button_events, /motion_events, $
      event_pro = 'draw_event', retain = 2, renderer = 1, $
      tooltip = 'Right-Click for a list of map projections.')

; Context Menu (PROJECTIONS) ***********************
  options_arr = ['Projections']
  projstr_arr = ['Stereographic', $
                 'Orthographic', $
                 'Lambert Azimuthal', $
                 'Gnomonic', $
                 'Azimuthal Equidistant', $
                 'Satellite', $
                 'Cylindrical', $
                 'Mercator', $
                 'Mollweide', $
                 'Sinusoidal', $
                 'Aitoff', $
                 'Hammer Aitoff', $
                 'Miller Cylindrical', $
                 'Robinson', $
                 'Goodes Homolosine', $
                 'UTM', $
                 'Polar Stereographic', $
                 'Polyconic', $
                 'Transverse Mercator', $
                 'Azimuthal', $
                 'Equirectangular', $
                 'Van der Grinten', $
                 'Interrupted Goode', $
                 'Interrupted Mollweide', $
                 'Hammer', $
                 'Wagner IV', $
                 'Wagner VII']
  projstr_arr = projstr_arr[sort(projstr_arr)]

  contextbase = widget_base(tlb, /context_menu, $
    event_pro = 'context_event')
  context_opts = lonarr(n_elements(options_arr))
  for i = 0, n_elements(context_opts)-1 do $
    context_opts[i] = widget_button(contextbase, $
    value = options_arr[i], /menu)
  projection_opts = lonarr(n_elements(projstr_arr))

  for i = 0, n_elements(projection_opts)-1 do $
      projection_opts[i] = widget_button(context_opts[0], $
      value = projstr_arr[i], uvalue = projstr_arr[i], $
      /checked_menu)

  proj = 'Equirectangular'
  temp = where(projstr_arr eq proj)
  widget_control, projection_opts[temp], set_button = 1

; Enter the path to directory containing shape files.
  shape_path = ''

  if not keyword_set(file) then $
    file = get_file(path = shape_path, /default)
    if file eq '' then begin
      void = dialog_message(['No data entered...', 'Exiting routine.'], /info)
      return
    endif

  widget_control, tlb, /realize
  widget_control, draw, get_value = owindow

  map_info = {file:file, $
              proj:proj, $
              center:[0d,0], $ ; [lat,lon]
              limit:[-90d,-180,90,180], $ ; [latmin, lonmin, latmax, lonmax]
              smap:!map, $
              drag_point:[0d,0], drag:0, $
              drag_model:obj_new('idlgrmodel'), $
              drag_view:obj_new('idlgrview', transparent = 1), $
              drag_poly:obj_new('idlgrpolyline', color = [255,0,0]), $
              thick:2, $
              omodel:obj_new('idlgrmodel'), $
              oview:obj_new('idlgrview'), $
              owindow:owindow, temp_obj:obj_new(), $
              num_att:0, att_str:ptr_new(/allocate), $
              ind:-1, att_names:ptr_new(/allocate)}

  map_info = build_view(map_info, grid = 0, /new)
  owindow -> setproperty, graphics_tree = map_info.oview

  map_info.drag_model -> add, map_info.drag_poly
  map_info.drag_view -> add, map_info.drag_model
  map_info.owindow -> draw, map_info.drag_view

  map_info.oview -> add, map_info.omodel
  map_info.owindow -> draw, map_info.oview

  state = {shape_path:shape_path, $
           file:file, $
           draw:draw, work_base:work_base, $
           clat:clat, $
           clon:clon, $
           limit0_lat:limit0_lat, $
           limit1_lat:limit1_lat, $
           limit0_lon:limit0_lon, $
           limit1_lon:limit1_lon, $
           contextbase:contextbase, $
           proj_str:proj_str, $
           proj_sel:projection_opts[temp], $
           map_info:map_info, $
           pref_arr:pref_arr, $
           pref_select:pref_select, grid:0, $
           base:0L, $
           cursor_lat:cursor_lat, cursor_lon:cursor_lon}

  widget_control, tlb, set_uvalue = state, /no_copy
  xmanager, 'shape_map_viewer', tlb, cleanup = 'clean'
end
