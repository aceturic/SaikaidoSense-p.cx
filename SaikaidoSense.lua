---@diagnostic disable
package.preload['polys.engine'] = (function (...)
local engine = _G.engine or {}

function engine.log(message, r, g, b, a)

    if r == 255 and g == 0 and b == 0 then
        log_error(tostring(message))
    else
        log(tostring(message))
    end
end

function engine.register_on_engine_tick(callback)
    table.insert(_G.Polyfill_TickCallbacks, callback)
end


function engine.unregister_on_engine_tick(id)
    if id and _G.Polyfill_TickCallbacks[id] then
        _G.Polyfill_TickCallbacks[id] = nil
    end
end

function engine.register_onunload(callback)
    table.insert(_G.Polyfill_UnloadCallbacks, callback)
end

function engine.register_on_network_callback(callback)
    table.insert(_G.Polyfill_NetCallbacks, callback)
end

function engine.get_username()
    return "User" 
end

_G.engine = engine
return engine
 end)

package.preload['polys.fs'] = (function (...)
local fs = _G.fs or {}
local m = _G.m

function fs.does_file_exist(file_name)
    return does_file_exist(file_name)
end

function fs.read_from_file(file_name)
    local ok, data = read_file(file_name)
    if ok then return data end
    return ""
end

function fs.write_to_file(file_name, data)
    return create_file(file_name, data)
end

function fs.delete_file(file_name)
    return delete_file(file_name)
end

function fs.get_file_size(file_name)
    local ok, data = read_file(file_name)
    if ok then return #data end
    return 0
end

function fs.write_to_file_from_buffer(file_name, buffer_handle)
    local data = ""
    if buffer_handle then
        if buffer_handle._type == "ffi_buffer" and buffer_handle.ptr then
            local ffi = require("ffi")
            data = ffi.string(buffer_handle.ptr, buffer_handle.size)
        elseif buffer_handle._type == "lua_buffer" and buffer_handle.data then
            for i=1, buffer_handle.size do
                data = data .. string.char(buffer_handle.data[i])
            end
        end
    end
    return fs.write_to_file(file_name, data)
end

function fs.read_from_file_to_buffer(file_name, buffer_handle)
    local data = fs.read_from_file(file_name)
    if not data or not buffer_handle then return false end

    if buffer_handle._type == "ffi_buffer" then
        local ffi = require("ffi")
        ffi.copy(buffer_handle.ptr, data, math.min(#data, buffer_handle.size))
    elseif buffer_handle._type == "lua_buffer" then
        for i=1, math.min(#data, buffer_handle.size) do
            buffer_handle.data[i] = string.byte(data, i)
        end
    end
    return true
end

function fs.compress(str)
    return str
end

function fs.decompress(str)
    return str
end

_G.fs = fs
return fs
 end)

package.preload['polys.gui'] = (function (...)
local gui = _G.gui or {}

local TAB_INDICES = {
    ["aimbot"] = 0,
    ["visuals"] = 1,
    ["lua"] = 4, 
    ["settings"] = 3,
}


local PanelWrapper = {}
PanelWrapper.__index = PanelWrapper

function PanelWrapper.new(panel_obj)
    local self = setmetatable({}, PanelWrapper)
    self.panel = panel_obj
    return self
end

function PanelWrapper:add_checkbox(label)
    local cb = self.panel:add_checkbox(label, false)
    return cb
end

function PanelWrapper:add_slider_int(label, postfix, default, min, max, step)
    local s = self.panel:add_slider_int(label, postfix or "", default, min, max, step or 1)
    return s
end

function PanelWrapper:add_slider_float(label, postfix, value, min, max, step)
    local s = self.panel:add_slider_double(label, postfix or "", value, min, max, step or 1)
    return s
end

function PanelWrapper:add_button(label, callback)
    local btn = self.panel:add_button(label, callback)
    return btn
end

function PanelWrapper:add_text(label)

    self.panel:add_button(label, function() end)
end

function PanelWrapper:add_input_text(label, default)
    local inp = self.panel:add_input(label, default)
    return inp
end

function PanelWrapper:add_color_picker(label, r, g, b, a)
    local col = self.panel:add_color(label, {r, g, b, a})
    return col
end

function PanelWrapper:add_keybind(label, key, mode)

    local kb = self.panel:add_keybind(label, key, mode)
    return kb
end

function PanelWrapper:add_single_select(name, options_table, initial_index, is_expandable)
    local ss = self.panel:add_single_select(name, options_table, initial_index or 0, is_expandable or false)
    return ss
end

function PanelWrapper:add_multi_select(label, list)
    local options = {}
    for i, v in ipairs(list) do
        table.insert(options, {v, true}) 
    end
    local ms = self.panel:add_multi_select(label, options, false)
    return ms
end

local TabWrapper = {}
TabWrapper.__index = TabWrapper

function TabWrapper.new(index)
    local self = setmetatable({}, TabWrapper)
    self.index = index
    return self
end

function TabWrapper:create_panel(label, small_panel)

    local subtab = ui.create_subtab(self.index, label)
    local panel = subtab:add_panel(label, small_panel or false)
    return PanelWrapper.new(panel)
end

function TabWrapper:create_subtab(label)
    local subtab = ui.create_subtab(self.index, label)
    return SubTabWrapper.new(subtab)
end

local SubTabWrapper = {}
SubTabWrapper.__index = SubTabWrapper

function SubTabWrapper.new(subtab_obj)
    local self = setmetatable({}, SubTabWrapper)
    self.subtab = subtab_obj
    return self
end

function SubTabWrapper:create_panel(label, small_panel)
    local panel = self.subtab:add_panel(label, small_panel or false)
    return PanelWrapper.new(panel)
end

function gui.get_tab(name)
    local idx = TAB_INDICES[string.lower(name)] or 4
    return TabWrapper.new(idx)
end


_G.gui = gui
_G.SubTabWrapper = SubTabWrapper

return gui
 end)

package.preload['polys.input'] = (function (...)
local input = _G.input or {}

function input.simulate_mouse(dx, dy, flag)
    if flag == 1 then
        mouse_move_relative(dx, dy)
    elseif flag == 2 then

        mouse_left_click()
    elseif flag == 4 then

    else
        mouse_move_relative(dx, dy)
    end
end

function input.simulate_keyboard(key, flag)
    if not flag or flag == 0 then win_key_press(key)
    elseif flag == 1 then win_key_down(key)
    elseif flag == 2 then win_key_up(key) end
end

function input.is_key_pressed(key) return key_fired(key) end
function input.is_key_down(key) return key_down(key) end
function input.is_key_toggled(key) return key_toggle(key) end
function input.get_mouse_position() return get_mouse_pos() end
function input.get_mouse_move_delta() return get_mouse_delta() end
function input.get_scroll_delta() return get_scroll_delta() end
function input.get_clipboard() return copy_from_clipboard() end
function input.set_clipboard(text) copy_to_clipboard(text) end
function input.is_menu_open() return false end

_G.input = input
return input
 end)

package.preload['polys.m'] = (function (...)
local m = _G.m or {}
local has_ffi, ffi = pcall(require, "ffi")

function m.alloc(size)
    if has_ffi then
        local ptr = ffi.new("uint8_t[?]", size)
        return { _type = "ffi_buffer", ptr = ptr, size = size }
    else
        local t = {}
        for i=1, size do t[i] = 0 end
        return { _type = "lua_buffer", data = t, size = size }
    end
end

function m.free(handle)
    if handle then
        handle.ptr = nil
        handle.data = nil
    end
end

function m.get_size(handle)
    return handle and handle.size or 0
end

local function check_bounds(handle, offset, type_size)
    if not handle or offset < 0 or (offset + type_size) > handle.size then
        return false
    end
    return true
end

function m.read_int8(handle, offset)
    if not check_bounds(handle, offset, 1) then return 0 end
    if handle._type == "ffi_buffer" then
        return handle.ptr[offset]
    else
        return handle.data[offset + 1] or 0
    end
end

function m.read_int16(handle, offset)
    if not check_bounds(handle, offset, 2) then return 0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int16_t*", handle.ptr + offset)
        return ptr[0]
    else
        local b1 = handle.data[offset + 1]
        local b2 = handle.data[offset + 2]
        local val = b1 + (b2 * 256)
        if val > 32767 then val = val - 65536 end
        return val
    end
end

function m.read_int32(handle, offset)
    if not check_bounds(handle, offset, 4) then return 0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int32_t*", handle.ptr + offset)
        return ptr[0]
    else
        local b1 = handle.data[offset + 1]
        local b2 = handle.data[offset + 2]
        local b3 = handle.data[offset + 3]
        local b4 = handle.data[offset + 4]
        local val = b1 + (b2 * 256) + (b3 * 65536) + (b4 * 16777216)

        if val > 2147483647 then val = val - 4294967296 end
        return val
    end
end

function m.read_int64(handle, offset)
    if not check_bounds(handle, offset, 8) then return 0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int64_t*", handle.ptr + offset)
        return tonumber(ptr[0]) 
    else
        return m.read_int32(handle, offset)
    end
end

function m.read_float(handle, offset)
    if not check_bounds(handle, offset, 4) then return 0.0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("float*", handle.ptr + offset)
        return tonumber(ptr[0])
    else
        return 0.0 
    end
end

function m.read_double(handle, offset)
    if not check_bounds(handle, offset, 8) then return 0.0 end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("double*", handle.ptr + offset)
        return tonumber(ptr[0])
    else
        return 0.0
    end
end

function m.read_string(handle, offset)
    if not handle then return "" end
    local str = ""
    if handle._type == "ffi_buffer" then
        local ptr = handle.ptr + offset
        return ffi.string(ptr)
    else
        for i = offset + 1, handle.size do
            local b = handle.data[i]
            if b == 0 then break end
            str = str .. string.char(b)
        end
    end
    return str
end

function m.write_int8(handle, offset, value)
    if not check_bounds(handle, offset, 1) then return end
    if handle._type == "ffi_buffer" then
        handle.ptr[offset] = value
    else
        handle.data[offset + 1] = value % 256
    end
end

function m.write_int16(handle, offset, value)
    if not check_bounds(handle, offset, 2) then return end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int16_t*", handle.ptr + offset)
        ptr[0] = value
    else
        handle.data[offset + 1] = value % 256
        handle.data[offset + 2] = math.floor(value / 256) % 256
    end
end

function m.write_int32(handle, offset, value)
    if not check_bounds(handle, offset, 4) then return end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("int32_t*", handle.ptr + offset)
        ptr[0] = value
    else
        handle.data[offset + 1] = value % 256
        handle.data[offset + 2] = math.floor(value / 256) % 256
        handle.data[offset + 3] = math.floor(value / 65536) % 256
        handle.data[offset + 4] = math.floor(value / 16777216) % 256
    end
end

function m.write_float(handle, offset, value)
    if not check_bounds(handle, offset, 4) then return end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("float*", handle.ptr + offset)
        ptr[0] = value
    end
end

function m.write_double(handle, offset, value)
    if not check_bounds(handle, offset, 8) then return end
    if handle._type == "ffi_buffer" then
        local ptr = ffi.cast("double*", handle.ptr + offset)
        ptr[0] = value
    end
end

function m.write_string(handle, offset, str)
    if not handle then return end
    if handle._type == "ffi_buffer" then
        ffi.copy(handle.ptr + offset, str)
    else
        for i = 1, #str do
            if offset + i <= handle.size then
                handle.data[offset + i] = string.byte(str, i)
            end
        end
        if offset + #str + 1 <= handle.size then
            handle.data[offset + #str + 1] = 0 
        end
    end
end

_G.m = m
return m
 end)

package.preload['polys.math'] = (function (...)
local m = math

function m.clamp(x, min, max)
    if x < min then return min end
    if x > max then return max end
    return x
end

function m.lerp(a, b, t)
    return a + (b - a) * t
end

function m.round(x)
    return math.floor(x + 0.5)
end

function m.round_up(x)
    return math.ceil(x)
end

function m.round_down(x)
    return math.floor(x)
end

function m.round_to_nearest(x, step)
    if step == 0 then return x end
    return math.floor(x / step + 0.5) * step
end

function m.sign(x)
    if x > 0 then return 1 end
    if x < 0 then return -1 end
    return 0
end

function m.map(x, in_min, in_max, out_min, out_max)
    return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function m.saturate(x)
    return m.clamp(x, 0, 1)
end

function m.is_nan(x)
    return x ~= x
end

function m.is_inf(x)
    return x == math.huge or x == -math.huge
end

function m.smoothstep(edge0, edge1, x)
    x = m.clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0)
    return x * x * (3 - 2 * x)
end

function m.inverse_lerp(a, b, x)
    return (x - a) / (b - a)
end

function m.fract(x)
    return x - math.floor(x)
end

function m.wrap(x, min, max)
    return min + (x - min) % (max - min)
end



return m
 end)

package.preload['polys.net'] = (function (...)
local net = _G.net or {}

function net.send_request(url, headers, post_fields)


    if post_fields and post_fields ~= "" then

        local ctype = "application/x-www-form-urlencoded"
        if headers and type(headers) == "table" then
            for k, v in pairs(headers) do
                if string.lower(k) == "content-type" then ctype = v break end
            end
        end

        local ok, status, body = net_http_post(url, ctype, post_fields, 5000)
        return body or "" 
    else
        local ok, status, body = net_http_get(url, 5000)
        return body or ""
    end
end

function net.resolve(hostname)
    return "127.0.0.1" 
end

function net.create_socket(ip, port)
    return {
        send = function() return 0 end,
        receive = function() return nil, "not supported" end,
        close = function() end
    }
end

function net.base64_encode(str)
    return util.base64_encode(str)
end

function net.base64_decode(str)
    return util.base64_decode(str)
end

_G.net = net
return net
 end)

package.preload['polys.process'] = (function (...)
local proc = _G.proc or {}

local _Internal_CurrentProcess = nil
local _Internal_AttachedName = nil

function proc.attach_by_pid(process_id, has_corrupt_cr3)
    if _Internal_CurrentProcess then
        deref_process(_Internal_CurrentProcess)
    end
    _Internal_CurrentProcess = ref_process(process_id)
    _Internal_AttachedName = nil
    return _Internal_CurrentProcess ~= nil
end

function proc.attach_by_name(process_name, has_corrupt_cr3)
    if _Internal_CurrentProcess then
        deref_process(_Internal_CurrentProcess)
    end
    _Internal_CurrentProcess = ref_process(process_name)
    _Internal_AttachedName = process_name
    return _Internal_CurrentProcess ~= nil
end

function proc.attach_by_window(window_class, window_name, has_corrupt_cr3)
    local hwnd = find_window(window_name, window_class)
    if hwnd then
        local tid, pid = get_window_thread_process_id(hwnd)
        if pid then
            return proc.attach_by_pid(pid, has_corrupt_cr3)
        end
    end
    return false
end

function proc.is_attached()
    return _Internal_CurrentProcess and _Internal_CurrentProcess:alive()
end

function proc.did_exit()
    return not (_Internal_CurrentProcess and _Internal_CurrentProcess:alive())
end

function proc.pid()
    if proc.is_attached() then
        return _Internal_CurrentProcess:pid()
    end
    return 0
end

function proc.peb()
    if proc.is_attached() then
        return _Internal_CurrentProcess:peb()
    end
    return 0
end

function proc.base_address()
    if proc.is_attached() then
        return _Internal_CurrentProcess:base_address()
    end
    return 0
end

function proc.handle()
    if proc.is_attached() then
        return _Internal_CurrentProcess
    end
    return nil
end

function proc.get_base_module()
    if proc.is_attached() then
        if _Internal_AttachedName then
            local address, size = _Internal_CurrentProcess:get_module(_Internal_AttachedName)
            
            return address, size
        end
        return _Internal_CurrentProcess:base_address(), 0 
    end
    return 0, 0
end

function proc.find_module(module_name)
    if proc.is_attached() then
        return _Internal_CurrentProcess:get_module(module_name)
    end
    return 0, 0
end

function proc.find_signature(base_address, size, signature)
    if proc.is_attached() then
        return _Internal_CurrentProcess:find_code_pattern(base_address, size, signature)
    end
    return 0
end

function proc.read_double(address)
    if proc.is_attached() then return _Internal_CurrentProcess:rf64(address) end; return 0
end
function proc.read_float(address)
    if proc.is_attached() then return _Internal_CurrentProcess:rf32(address) end; return 0
end
function proc.read_int64(address)
    if proc.is_attached() then return _Internal_CurrentProcess:r64(address) end; return 0
end
function proc.read_int32(address)
    if proc.is_attached() then return _Internal_CurrentProcess:r32(address) end; return 0
end
function proc.read_int16(address)
    if proc.is_attached() then return _Internal_CurrentProcess:r16(address) end; return 0
end
function proc.read_int8(address)
    if proc.is_attached() then return _Internal_CurrentProcess:r8(address) end; return 0
end

function proc.read_string(address, size)
    if proc.is_attached() then return _Internal_CurrentProcess:rs(address, size) end; return ""
end
function proc.read_wide_string(address, size)
    if proc.is_attached() then return _Internal_CurrentProcess:rws(address, size) end; return ""
end

function proc.read_to_memory_buffer(address, buffer, size)

    if proc.is_attached() then
         local data = _Internal_CurrentProcess:rs(address, size) 
         if type(buffer) == "table" then
             buffer.data = data
         end
    end
end

function proc.dump(file_name)

    -----Damn this func is missing
end

function proc.write_double(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:wf64(address, value) end; return false
end
function proc.write_float(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:wf32(address, value) end; return false
end
function proc.write_int64(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:w64(address, value) end; return false
end
function proc.write_int32(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:w32(address, value) end; return false
end
function proc.write_int16(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:w16(address, value) end; return false
end
function proc.write_int8(address, value)
    if proc.is_attached() then return _Internal_CurrentProcess:w8(address, value) end; return false
end
function proc.write_string(address, text)
    if proc.is_attached() then return _Internal_CurrentProcess:ws(address, text) end; return false
end
function proc.write_wide_string(address, text)
    if proc.is_attached() then return _Internal_CurrentProcess:wws(address, text) end; return false
end

function proc.write_from_memory_buffer(address, buffer, size)
    if proc.is_attached() and type(buffer) == "table" and buffer.data then
        return _Internal_CurrentProcess:ws(address, buffer.data)
    end
    return false
end


function proc.read_struct(base_address, descriptor)
    if proc.is_attached() then
        return _Internal_CurrentProcess:read_struct(base_address, descriptor)
    end
    return nil
end

-- table proc:read_struct_array(
--     uint64 base_address,
--     integer count,
--     integer struct_size,
--     table descriptor
-- )
function proc.read_struct_array(base_address, count, struct_size, descriptor)
    if proc.is_attached() then
        return _Internal_CurrentProcess:read_struct_array(base_address, count, struct_size, descriptor)
    end
    return false
end


_G.proc = proc
return proc

 end)

package.preload['polys.render'] = (function (...)
local render = _G.render or {}
local net = _G.net

local function unpack_color(r, g, b, a)
    return r, g, b, a or 255
end

function render.draw_line(x1, y1, x2, y2, r, g, b, a, thickness)
    draw_line(x1, y1, x2, y2, r, g, b, a, thickness)
end

function render.draw_rectangle(x, y, width, height, r, g, b, a, thickness, filled, rounding)
    rounding = rounding or 0
    a = a or 255
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)
    a = math.floor(a)
    if filled then
        draw_rect_filled(x, y, width, height, r, g, b, a, rounding, 15)
    else
        draw_rect(x, y, width, height, r, g, b, a, thickness, rounding, 15)
    end
end

function render.draw_circle(x, y, radius, r, g, b, a, thickness, filled)
    draw_circle(x, y, radius, r, g, b, a, thickness, filled)
end

function render.draw_triangle(x1, y1, x2, y2, x3, y3, r, g, b, a, thickness, filled)
    local points = {x1, y1, x2, y2, x3, y3}
    draw_polygon(points, 3, r, g, b, a, thickness, filled)
end

function render.draw_polygon(points_table, r, g, b, a, thickness, filled)

    local flat_points = {}
    for i, pt in ipairs(points_table) do
        if type(pt) == "table" then
            table.insert(flat_points, pt[1])
            table.insert(flat_points, pt[2])
        else
            table.insert(flat_points, pt)
        end
    end

    draw_polygon(flat_points, #flat_points / 2, r, g, b, a, thickness, filled)
end

function render.draw_ellipse(x, y, rx, ry, r, g, b, a, thickness, filled)
    local points = {}
    local segments = 32
    for i = 0, segments - 1 do
        local theta = (i / segments) * math.pi * 2
        table.insert(points, x + rx * math.cos(theta))
        table.insert(points, y + ry * math.sin(theta))
    end
    draw_polygon(points, segments, r, g, b, a, thickness, filled)
end

function render.draw_arc(x, y, rx, ry, start_angle, sweep_angle, r, g, b, a, thickness, filled)
    local points = {}
    local segments = 16
    local start_rad = math.rad(start_angle)
    local sweep_rad = math.rad(sweep_angle)

    if filled then table.insert(points, x); table.insert(points, y) end

    for i = 0, segments do
        local theta = start_rad + (i / segments) * sweep_rad
        table.insert(points, x + rx * math.cos(theta))
        table.insert(points, y + ry * math.sin(theta))
    end

    draw_polygon(points, #points/2, r, g, b, a, thickness, filled)
end

function render.create_font(path, size, anti_aliased, load_color)
    return create_font(path, size, anti_aliased or false, load_color or false)
end

function render.create_font_from_buffer(font_label, size, buffer_handle, anti_aliased, load_color)
    local data = buffer_handle

    if type(buffer_handle) == "table" then
        if buffer_handle._type == "ffi_buffer" and buffer_handle.ptr then
            local ffi = require("ffi")
            data = ffi.string(buffer_handle.ptr, buffer_handle.size)
        elseif buffer_handle._type == "lua_buffer" and buffer_handle.data then
            local t = {}
            for i=1, buffer_handle.size do
                t[i] = string.char(buffer_handle.data[i])
            end
            data = table.concat(t)
        end
    end

    return create_font_mem(font_label, size, data, anti_aliased or false, load_color or false)
end

function render.draw_text(font, text, x, y, r, g, b, a, outline_thickness, o_r, o_g, o_b, o_a)
    r = math.floor(r or 255)
    g = math.floor(g or 255)
    b = math.floor(b or 255)
    a = math.floor(a or 255)
    
    local er = math.floor(o_r or 0)
    local eg = math.floor(o_g or 0)
    local eb = math.floor(o_b or 0)
    local ea = math.floor(o_a or 0)

    local effect = 0 
    local effect_amount = 0

    if outline_thickness and outline_thickness > 0 then
        effect = 1 
        effect_amount = outline_thickness
    end

    draw_text(text, x, y, r, g, b, a, font, effect, er, eg, eb, ea, effect_amount, true)
end

function render.measure_text(font_handle, text)
    local w, h = get_text_size(font_handle, text, 10000, 10000)
    return w, h
end

function render.get_viewport_size()
    return get_view()
end

function render.get_fps()
    return get_fps()
end

function render.clip_start(x, y, width, height)
    clip_push(x, y, width, height)
end

function render.clip_end()
    clip_pop()
end

function render.create_bitmap_from_url(url)
    local ok, status, body = net_http_get(url)
    if ok and status == 200 then
        return create_bitmap(body)
    end
    return nil
end

function render.create_bitmap_from_buffer(buffer_handle)
    local data = buffer_handle
    if type(buffer_handle) == "table" then
        if buffer_handle._type == "ffi_buffer" and buffer_handle.ptr then
            local ffi = require("ffi")
            data = ffi.string(buffer_handle.ptr, buffer_handle.size)
        elseif buffer_handle._type == "lua_buffer" and buffer_handle.data then
            local t = {}
            for i=1, buffer_handle.size do
                t[i] = string.char(buffer_handle.data[i])
            end
            data = table.concat(t)
        end
    end
    return create_bitmap(data)
end

function render.create_bitmap_from_file(file_name)
    local ok, data = read_file(file_name)
    if ok then
        return create_bitmap(data)
    end
    return nil
end

function render.draw_four_corner_gradient(x, y, width, height, r1, g1, b1, r2, g2, b2, r3, g3, b3, r4, g4, b4)

    draw_four_corner_gradient(x, y, width, height,
        r1, g1, b1, 255,
        r2, g2, b2, 255,
        r3, g3, b3, 255,
        r4, g4, b4, 255,
        0)
end

function render.draw_gradient_line(x1, y1, x2, y2, color_table, thickness)

    local r,g,b,a = 255, 255, 255, 255
    if type(color_table) == "table" and #color_table >= 4 then
        r,g,b,a = color_table[1], color_table[2], color_table[3], color_table[4]
    end
    draw_line(x1, y1, x2, y2, r, g, b, a, thickness)
end

function render.draw_gradient_rectangle(x, y, width, height, color_table, rounding)
    local r1, g1, b1, a1 = 255, 255, 255, 255
    local r2, g2, b2, a2 = 255, 255, 255, 255

    if type(color_table) == "table" then
        if type(color_table[1]) == "table" then
            local c1 = color_table[1] or {255,255,255,255}
            local c2 = color_table[2] or c1
            
            r1, g1, b1, a1 = c1[1], c1[2], c1[3], c1[4]
            r2, g2, b2, a2 = c2[1], c2[2], c2[3], c2[4]
        else
            if #color_table >= 4 then 
                r1,g1,b1,a1 = color_table[1], color_table[2], color_table[3], color_table[4] 
            end
            if #color_table >= 8 then
                r2,g2,b2,a2 = color_table[5], color_table[6], color_table[7], color_table[8]
            else
                r2,g2,b2,a2 = r1,g1,b1,a1 
            end
        end
    end

    draw_four_corner_gradient(
        x, y, width, height,
        math.floor(r1 or 255), math.floor(g1 or 255), math.floor(b1 or 255), math.floor(a1 or 255),
        math.floor(r1 or 255), math.floor(g1 or 255), math.floor(b1 or 255), math.floor(a1 or 255), -- Top Right matches Top Left (Horizontal/Vertical hybrid)
        math.floor(r2 or 255), math.floor(g2 or 255), math.floor(b2 or 255), math.floor(a2 or 255),
        math.floor(r2 or 255), math.floor(g2 or 255), math.floor(b2 or 255), math.floor(a2 or 255), -- Bottom Right matches Bottom Left
        math.floor(rounding or 0)
    )
end

_G.render = render
return render
 end)

package.preload['polys.str'] = (function (...)
local str = _G.str or {}

function str.trim(s)
    return s:match("^%s*(.-)%s*$")
end

function str.ltrim(s)
    return s:match("^%s*(.*)")
end

function str.rtrim(s)
    return s:match("(.-)%s*$")
end

function str.pad_left(s, len, char)
    if #s >= len then return s end
    return string.rep(char or " ", len - #s) .. s
end

function str.pad_right(s, len, char)
    if #s >= len then return s end
    return s .. string.rep(char or " ", len - #s)
end

function str.strip_prefix(s, prefix)
    if str.startswith(s, prefix) then
        return s:sub(#prefix + 1)
    end
    return s
end

function str.strip_suffix(s, suffix)
    if str.endswith(s, suffix) then
        return s:sub(1, -#suffix - 1)
    end
    return s
end

function str.startswith(s, prefix)
    return s:sub(1, #prefix) == prefix
end

function str.endswith(s, suffix)
    return suffix == "" or s:sub(-#suffix) == suffix
end

function str.contains(s, substring)
    return s:find(substring, 1, true) ~= nil
end

function str.indexof(s, substr, start)
    return s:find(substr, start or 1, true)
end

function str.last_indexof(s, substr)
    local i = 0
    local found = nil
    while true do
        i = s:find(substr, i + 1, true)
        if not i then break end
        found = i
    end
    return found
end

function str.count(s, substr)
    local c = 0
    local i = 0
    while true do
        i = s:find(substr, i + 1, true)
        if not i then break end
        c = c + 1
    end
    return c
end

function str.empty(s)
    return s == nil or s == ""
end

function str.equals(a, b)
    return a == b
end

function str.replace(s, from, to)

    local pattern = from:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%1")
    local result, _ = s:gsub(pattern, to:gsub("%%", "%%%%")) 
    return result
end

function str.repeat_str(s, count)
    return string.rep(s, count)
end

function str.reverse(s)
    return string.reverse(s)
end

function str.insert(s, pos, substr)
    return s:sub(1, pos-1) .. substr .. s:sub(pos)
end

function str.remove(s, start, END)
    return s:sub(1, start-1) .. s:sub(END+1)
end

function str.substitute(s, tbl)
    return (s:gsub("{(.-)}", function(key)
        return tbl[key] or "{"..key.."}"
    end))
end

function str.upper(s)
    return string.upper(s)
end

function str.lower(s)
    return string.lower(s)
end

function str.split(s, delimiter)
    local result = {}
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match)
    end
    return result
end

function str.slice(s, start, END)
    return string.sub(s, start, END)
end

function str.utf8len(s)
    return utf8.len(s)
end

function str.utf8sub(s, start, END)

    return string.sub(s, start, END)
end

_G.str = str
return str
 end)

package.preload['polys.time'] = (function (...)
local time = _G.time or {}

time.SECONDS_PER_MINUTE = 60
time.SECONDS_PER_HOUR = 3600
time.SECONDS_PER_DAY = 86400
time.DAYS_PER_WEEK = 7
time.WEEKDAY_NAMES = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}
time.MONTH_NAMES = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
time.MONTH_DAYS = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
time.MONTH_DAYS_LEAP = {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}
time.MONTH_NAME_TO_INDEX = {}
for i, v in ipairs(time.MONTH_NAMES) do time.MONTH_NAME_TO_INDEX[v] = i end

function time.unix()
    return os.time()
end

function time.unix_ms()

    return os.time() * 1000
end

function time.now_utc()
    return os.date("!%Y-%m-%d %H:%M:%S")
end

function time.now_local()
    return os.date("%Y-%m-%d %H:%M:%S")
end

function time.format(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

function time.format_custom(timestamp, format)

    return os.date("!" .. format, timestamp)
end

function time.delta(t1, t2)
    return math.abs(t1 - t2)
end

function time.compare(t1, t2)
    if t1 < t2 then return -1 end
    if t1 > t2 then return 1 end
    return 0
end

function time.same_day(t1, t2)
    local d1 = os.date("!*t", t1)
    local d2 = os.date("!*t", t2)
    return d1.year == d2.year and d1.month == d2.month and d1.day == d2.day
end

function time.diff_table(t1, t2)
    local diff = math.abs(t1 - t2)
    local days = math.floor(diff / 86400)
    local remainder = diff % 86400
    local hours = math.floor(remainder / 3600)
    remainder = remainder % 3600
    local minutes = math.floor(remainder / 60)
    local seconds = remainder % 60
    return {days=days, hours=hours, minutes=minutes, seconds=seconds}
end

function time.between(now, start, END)
    return now >= start and now <= END
end

function time.weekday(timestamp)
    local d = os.date("!*t", timestamp)
    return d.wday - 1

end

function time.day_of_year(timestamp)
    local d = os.date("!*t", timestamp)
    return d.yday
end

function time.year_month_day(timestamp)
    local d = os.date("!*t", timestamp)
    return {year=d.year, month=d.month, day=d.day}
end

function time.is_weekend(timestamp)
    local w = time.weekday(timestamp)
    return w == 0 or w == 6
end

function time.is_leap_year(timestamp)
    local y = os.date("!*t", timestamp).year
    return (y % 4 == 0 and y % 100 ~= 0) or (y % 400 == 0)
end

function time.days_in_month(year, month)
    local is_leap = (year % 4 == 0 and year % 100 ~= 0) or (year % 400 == 0)
    if is_leap then return time.MONTH_DAYS_LEAP[month] end
    return time.MONTH_DAYS[month]
end

function time.timestamp_utc(y, m, d, h, min, s)
    return os.time({year=y, month=m, day=d, hour=h, min=min, sec=s}) 

end

function time.add_days(timestamp, days)
    return timestamp + (days * 86400)
end

function time.start_of_day(timestamp)
    local d = os.date("!*t", timestamp)
    d.hour = 0; d.min = 0; d.sec = 0
    return os.time(d)
end

function time.end_of_day(timestamp)
    local d = os.date("!*t", timestamp)
    d.hour = 23; d.min = 59; d.sec = 59
    return os.time(d)
end

function time.to_table(timestamp)
    return os.date("*t", timestamp)
end

function time.from_table(tbl)
    return os.time(tbl)
end

function time.to_utc_table(timestamp)
    return os.date("!*t", timestamp)
end

function time.from_utc_table(tbl)

    return os.time(tbl)
end

function time.is_valid(timestamp)
    return type(timestamp) == "number" and timestamp > 0
end

function time.is_dst(timestamp)
    local d = os.date("*t", timestamp)
    return d.isdst
end

function time.utc_offset()
    local now = os.time()
    local utc = os.time(os.date("!*t", now))
    return os.difftime(now, utc)
end

function time.get_timezone()
    return os.date("%z")
end

function time.seconds_to_hhmmss(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

_G.time = time
return time
 end)

package.preload['polys.vectors'] = (function (...)
local vec2_impl = {}
local vec3_impl = {}
local vec4_impl = {}



local function make_vector_proxy(original_constructor, type_name)
    local proxy = {}

    setmetatable(proxy, {
        __call = function(_, ...)
            return original_constructor(...)
        end
    })

    return proxy
end

_G.vec2 = make_vector_proxy(vector2, "vec2")
_G.vec3 = make_vector_proxy(vector3, "vec3")
_G.vec4 = make_vector_proxy(vector4, "vec4")

function _G.vec2.read_float(address)
   
    local v = vector2()
    local proc = _G.proc and _G._Internal_CurrentProcess 
   
    if _G.proc and _G.proc.is_attached() then

    end

    local x = _G.proc.read_float(address)
    local y = _G.proc.read_float(address + 4)
    return vector2(x, y)
end

function _G.vec2.read_double(address)
    local x = _G.proc.read_double(address)
    local y = _G.proc.read_double(address + 8)
    return vector2(x, y)
end

function _G.vec2.write_float(address, v)
    _G.proc.write_float(address, v.x)
    _G.proc.write_float(address + 4, v.y)
end

function _G.vec2.write_double(address, v)
    _G.proc.write_double(address, v.x)
    _G.proc.write_double(address + 8, v.y)
end


function _G.vec3.read_float(address)
    local x = _G.proc.read_float(address)
    local y = _G.proc.read_float(address + 4)
    local z = _G.proc.read_float(address + 8)
    return vector3(x, y, z)
end

function _G.vec3.read_double(address)
    local x = _G.proc.read_double(address)
    local y = _G.proc.read_double(address + 8)
    local z = _G.proc.read_double(address + 16)
    return vector3(x, y, z)
end

function _G.vec3.write_float(address, v)
    _G.proc.write_float(address, v.x)
    _G.proc.write_float(address + 4, v.y)
    _G.proc.write_float(address + 8, v.z)
end

function _G.vec3.write_double(address, v)
    _G.proc.write_double(address, v.x)
    _G.proc.write_double(address + 8, v.y)
    _G.proc.write_double(address + 16, v.z)
end



local v3_dummy = vector3()
local v3_mt = getmetatable(v3_dummy) or debug.getmetatable(v3_dummy)

if v3_mt then
    v3_mt.to_forward = function(self)

        local pitch = math.rad(self.x)
        local yaw = math.rad(self.y)
        local cp = math.cos(pitch)
        local sp = math.sin(pitch)
        local cy = math.cos(yaw)
        local sy = math.sin(yaw)
        return vector3(cp * cy, cp * sy, -sp)
    end

    v3_mt.to_right = function(self)

        local fwd = self:to_forward()
        local up = vector3(0, 0, 1) 

        return vector3(0, 1, 0) 
    end

    v3_mt.to_up = function(self)
        return vector3(0, 0, 1) 
    end

    v3_mt.to_qangle = function(self)
        return vector3(0, 0, 0)
    end

    v3_mt.normalize_angles = function(self)
        local x = self.x
        local y = self.y
        return vector3(x, y, self.z)
    end

    v3_mt.clamp_angles = function(self)
        return self
    end

 
    _G.vec3.from_qangle = function(pitch, yaw)
        local v = vector3(pitch, yaw, 0)
        return v:to_forward()
    end

    _G.vec3.normalize_angle = function(angle)
        return angle 
    end
else

    log_error("Polyfill: Cannot modify vector metatables. Instance methods like :to_forward() may fail.")
end

function _G.vec4.read_float(address)
    local x = _G.proc.read_float(address)
    local y = _G.proc.read_float(address + 4)
    local z = _G.proc.read_float(address + 8)
    local w = _G.proc.read_float(address + 12)
    return vector4(x, y, z, w)
end

function _G.vec4.read_double(address)
    local x = _G.proc.read_double(address)
    local y = _G.proc.read_double(address + 8)
    local z = _G.proc.read_double(address + 16)
    local w = _G.proc.read_double(address + 24)
    return vector4(x, y, z, w)
end

function _G.vec4.write_float(address, v)
    _G.proc.write_float(address, v.x)
    _G.proc.write_float(address + 4, v.y)
    _G.proc.write_float(address + 8, v.z)
    _G.proc.write_float(address + 12, v.w)
end

function _G.vec4.write_double(address, v)
    _G.proc.write_double(address, v.x)
    _G.proc.write_double(address + 8, v.y)
    _G.proc.write_double(address + 16, v.z)
    _G.proc.write_double(address + 24, v.w)
end
 end)

package.preload['polys.winapi'] = (function (...)
local winapi = _G.winapi or {}

function winapi.get_tickcount64()
    return get_tickcount64()
end

function winapi.play_sound(file_name)
end

function winapi.get_hwnd(class_name, window_name)
    return find_window(window_name, class_name)
end

function winapi.post_message(hwnd, msg, wparam, lparam)
    return post_message(hwnd, msg, wparam, lparam)
end

function winapi.get_foreground_window()
    return 0
end

function winapi.get_window_rect(hwnd)
    return get_window_rect(hwnd)
end

function winapi.get_window_thread_process_id(hwnd)
    local tid, pid = get_window_thread_process_id(hwnd)
    return tid, pid
end

function winapi.get_window_style(hwnd)
    return 0 
end

function winapi.is_window_visible(hwnd)
    return true
end

function winapi.is_window_enabled(hwnd)
    return true
end

_G.winapi = winapi
return winapi
 end)




_G.polyfill = {}

_G.Polyfill_TickCallbacks = {}
_G.Polyfill_UnloadCallbacks = {}
_G.Polyfill_NetCallbacks = {}

_G.engine = {}
_G.render = {}
_G.proc = {}
_G.fs = {}
_G.input = {}
_G.gui = {}
_G.net = {}
_G.time = {}
_G.winapi = {}
_G.m = {}
_G.str = {}

function polyfill.main()

    return 1 
end

function polyfill.on_frame()
    for id, callback in pairs(_G.Polyfill_TickCallbacks) do
        if callback then
            local success, err = pcall(callback, id)
            if not success then
           
            end
        end
    end
end

function polyfill.on_unload()
    for i = 1, #Polyfill_UnloadCallbacks do
        if Polyfill_UnloadCallbacks[i] then
            Polyfill_UnloadCallbacks[i]()
        end
    end
end

require("polys.engine")
require("polys.render")
require("polys.process")
require("polys.m")
require("polys.fs")
require("polys.input")
require("polys.gui")
require("polys.time")
require("polys.str")
require("polys.math")
require("polys.net")
require("polys.winapi")
require("polys.vectors")



main = polyfill.main
on_frame = polyfill.on_frame
on_unload = polyfill.on_unload


local STATE_IDLE = 0
local STATE_WAITING_FOR_PROCESS = 1
local STATE_WAITING_FOR_GAME = 2
local STATE_ACTIVE = 3

-- 2. Global Variables
local g_current_state = STATE_IDLE
local g_loader_alpha = 0
local g_btn_anim = 0
local g_spinner_rot = 0

-- 3. Fonts
local f_title = render.create_font("Verdana", 28, 700)
local f_sub   = render.create_font("Verdana", 12, 400)
local f_btn   = render.create_font("Verdana", 14, 700)
local f_card  = render.create_font("Verdana", 16, 600)

-- 4. Forward Declarations
local InitializeFeatures = nil 
local MainGameLoop = nil 

local function DrawSpinner(x, y, radius, thickness, color_a)
    local steps = 20
    g_spinner_rot = g_spinner_rot + 5
    if g_spinner_rot > 360 then g_spinner_rot = 0 end
    
    for i = 1, steps do
        local angle = math.rad(g_spinner_rot + (i * (360/steps)))
        local next_angle = math.rad(g_spinner_rot + ((i+1) * (360/steps)))
        
        local alpha = math.floor(color_a * (i / steps))
        
        local x1 = x + math.cos(angle) * radius
        local y1 = y + math.sin(angle) * radius
        local x2 = x + math.cos(next_angle) * radius
        local y2 = y + math.sin(next_angle) * radius
        
        render.draw_line(x1, y1, x2, y2, 255, 255, 255, alpha, thickness)
    end
end

local function DrawModernLoader()
    g_loader_alpha = math.lerp(g_loader_alpha, 255, 0.05)
    local a = math.floor(g_loader_alpha)
    if a < 5 then return end

    local sw, sh = render.get_viewport_size()
    local w, h = 600, 380
    local x, y = (sw/2) - (w/2), (sh/2) - (h/2)
    local mx, my = input.get_mouse_position()

    local c_bg = {20, 20, 25}
    local c_sidebar = {28, 28, 35}
    local c_accent = {130, 100, 255} 
    local c_card = {35, 35, 42}

    render.draw_rectangle(x-2, y-2, w+4, h+4, c_accent[1], c_accent[2], c_accent[3], a, 0, true, 10)
    render.draw_rectangle(x, y, w, h, c_bg[1], c_bg[2], c_bg[3], a, 0, true, 8)
    
    local sb_w = 180
    render.draw_rectangle(x, y, sb_w, h, c_sidebar[1], c_sidebar[2], c_sidebar[3], a, 0, true, 8)
    render.draw_rectangle(x + sb_w - 10, y, 10, h, c_sidebar[1], c_sidebar[2], c_sidebar[3], a, 0, true, 0) -- Square off right side

    render.draw_text(f_title, "SHOOK", x + 25, y + 30, c_accent[1], c_accent[2], c_accent[3], a, 0,0,0,0,0)
    render.draw_text(f_sub, "External solution", x + 25, y + 60, 150, 150, 150, a, 0,0,0,0,0)

    local u_y = y + h - 60
    render.draw_circle(x + 35, u_y + 20, 18, 50, 50, 60, a, 0, true)
    render.draw_text(f_btn, "S", x + 30, u_y + 12, 255, 255, 255, a, 0,0,0,0,0)
    render.draw_text(f_btn, engine.get_username(), x + 65, u_y + 8, 220, 220, 220, a, 0,0,0,0,0)
    render.draw_text(f_sub, "Lifetime Sub", x + 65, u_y + 26, 0, 255, 100, a, 0,0,0,0,0)
    render.draw_line(x + 20, u_y - 10, x + sb_w - 20, u_y - 10, 60, 60, 70, a, 1)

    local cx = x + sb_w + 20
    local cy = y + 20
    local cw = w - sb_w - 40
    
    render.draw_text(f_card, "Subscription Status", cx, cy + 10, 255, 255, 255, a, 0,0,0,0,0)

    local card_y = cy + 50
    local card_h = 80
    
    render.draw_rectangle(cx, card_y, cw, card_h, c_card[1], c_card[2], c_card[3], a, 0, true, 6)
    render.draw_rectangle(cx, card_y, cw, card_h, 60, 60, 70, a, 1, false, 6)

    render.draw_rectangle(cx + 15, card_y + 15, 50, 50, c_accent[1], c_accent[2], c_accent[3], a, 0, true, 4)
    render.draw_text(f_title, "CS2", cx + 18, card_y + 22, 255, 255, 255, a, 0,0,0,0,0)

    render.draw_text(f_card, "Counter-Strike 2", cx + 80, card_y + 15, 255, 255, 255, a, 0,0,0,0,0)
    render.draw_text(f_sub, "Status: Undetected", cx + 80, card_y + 40, 100, 255, 100, a, 0,0,0,0,0)

    local btn_w, btn_h = 140, 30
    local btn_x = cx + cw - btn_w - 15
    local btn_y = card_y + card_h - btn_h - 15
    
    if g_current_state == STATE_IDLE then
        local hovered = mx >= btn_x and mx <= btn_x + btn_w and my >= btn_y and my <= btn_y + btn_h
        g_btn_anim = math.lerp(g_btn_anim, hovered and 1 or 0, 0.15)
        
        local br = math.floor(math.lerp(c_accent[1], 160, g_btn_anim))
        local bg = math.floor(math.lerp(c_accent[2], 130, g_btn_anim))
        local bb = math.floor(math.lerp(c_accent[3], 255, g_btn_anim))

        render.draw_rectangle(btn_x, btn_y, btn_w, btn_h, br, bg, bb, a, 0, true, 4)
        
        local txt = "LOAD"
        local tw, th = render.measure_text(f_btn, txt)
        render.draw_text(f_btn, txt, btn_x + (btn_w/2) - (tw/2), btn_y + (btn_h/2) - (th/2), 255, 255, 255, a, 0,0,0,0,0)

        if hovered and input.is_key_pressed(1) then
            g_current_state = STATE_WAITING_FOR_PROCESS
        end

    else
        local status_text = "Initializing..."
        if g_current_state == STATE_WAITING_FOR_PROCESS then status_text = "Waiting for CS2..." end
        if g_current_state == STATE_WAITING_FOR_GAME then status_text = "Waiting for Match..." end

        render.draw_rectangle(btn_x, btn_y, btn_w, btn_h, 45, 45, 55, a, 0, true, 4)
        render.draw_rectangle(btn_x, btn_y, btn_w, btn_h, 60, 60, 70, a, 1, false, 4)

        local tw, th = render.measure_text(f_sub, status_text)
        local content_w = tw + 20 
        local start_draw_x = btn_x + (btn_w/2) - (content_w/2)
        
        DrawSpinner(start_draw_x, btn_y + (btn_h/2), 8, 2, a)
        render.draw_text(f_sub, status_text, start_draw_x + 15, btn_y + (btn_h/2) - (th/2), 200, 200, 200, a, 0,0,0,0,0)
    end
end

engine.register_on_engine_tick(function(tick_id)

    if g_current_state < STATE_ACTIVE then
        
        DrawModernLoader()

        if g_current_state == STATE_WAITING_FOR_PROCESS then
            if proc.attach_by_name("cs2.exe") then
                engine.log("Attached to CS2.", 0, 255, 0, 255)
                g_current_state = STATE_WAITING_FOR_GAME
            end
        end

        if g_current_state == STATE_WAITING_FOR_GAME then
            if proc.did_exit() then 
                g_current_state = STATE_WAITING_FOR_PROCESS 
                return 
            end
            
            local client_dll = proc.find_module("client.dll")
            if client_dll and client_dll ~= 0 then
                local local_pawn = proc.read_int64(client_dll + 0x1BEEF28) -- dwLocalPlayerPawn
                if local_pawn and local_pawn ~= 0 then
                    engine.log("Match Found. Injecting.", 130, 100, 255, 255)
                    
                    InitializeFeatures()
                    g_current_state = STATE_ACTIVE
                    
                    engine.unregister_on_engine_tick(tick_id) 
                    engine.register_on_engine_tick(function(...)
                        local success, err = pcall(MainGameLoop, ...) 
                        if not success and err then
                            engine.log("RUNTIME ERROR: " .. tostring(err), 255, 50, 50, 255)
                        end
                    end)            
                end
            end
        end
    end
end)
function InitializeFeatures()

    if not table.unpack then table.unpack = _G.unpack end 

        local key_mode = {
        always = 0,
        hold = 1,
        toggle = 2,
        onhotkey = 1,   
        single = 3
    }

local MenuLib = { version = "4.0" }

local function round(n, p)
    p = 10^(p or 0)
    return math.floor(n * p + 0.5) / p
end

function MenuLib.hsv_to_rgb(h, s, v, a)
    h, s, v, a = h or 0, s or 0, v or 0, a or 255
    local r, g, b
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    if i == 0 then r, g, b = v, t, p elseif i == 1 then r, g, b = q, v, p elseif i == 2 then r, g, b = p, v, t elseif i == 3 then r, g, b = p, q, v elseif i == 4 then r, g, b = t, p, v elseif i == 5 then r, g, b = v, p, q end
    return round(r * 255), round(g * 255), round(b * 255), round(a)
end

function MenuLib.rgb_to_hsv(r, g, b)
    r, g, b = (r or 0) / 255, (g or 0) / 255, (b or 0) / 255
    local max, min = math.max(r, g, b), math.min(r, g, b)
    local h, s, v = 0, 0, max
    local d = max - min
    if max ~= 0 then s = d / max end
    if max ~= min then
        if max == r then h = (g - b) / d + (g < b and 6 or 0) elseif max == g then h = (b - r) / d + 2 else h = (r - g) / d + 4 end
        h = h / 6
    end
    return h, s, v
end

function MenuLib.draw_checkered_background(x, y, w, h, alpha)
    local c1 = { 60, 60, 60, alpha }
    local c2 = { 80, 80, 80, alpha }
    local sq = 8
    for i = 0, math.floor(w / sq) do
        for j = 0, math.floor(h / sq) do
            local color = ((i + j) % 2 == 0) and c1 or c2
            render.draw_rectangle(x + i * sq, y + j * sq, sq, sq, color[1], color[2], color[3], color[4], 0, true)
        end
    end
end

local Menu = { initialized = false, visible = false, key = 0x2D, current_theme = "default",theme_anim = {
        is_transitioning = false,
        progress = 0,
        speed = 0.05, 
        source_colors = {},
        target_colors = {}
    },active_tab = nil, active_sub_tab = nil, active_binding_element = nil, active_input_element = nil, active_select_element = nil, click_consumed = false, tab_anim_y = 0, tabs = {}, elements = {}, values = {}, groups = {}, anim = { alpha = 0, target_alpha = 0, speed = 0.1 }, window = { x = 0, y = 0, w = 620, h = 750, dragging = false, drag_x = 0, drag_y = 0 }, fonts = {}, colors = { bg_dark = { 22, 23, 27 }, bg_mid = { 35, 37, 43 }, bg_light = { 50, 52, 60 }, text_main = { 220, 220, 220 }, text_dim = { 150, 150, 150 }, accent = { 130, 100, 255 } }, info_window = { visible = false, x = 0, y = 0, w = 350, h = 220, dragging = false, drag_x = 0, drag_y = 0, anim = { alpha = 0, target_alpha = 0, speed = 0.15 } }, color_pickers = {}, keybind_mode_selector = { visible = false, element_id = nil, x = 0, y = 0, w = 110, anim = { alpha = 0, target_alpha = 0, speed = 0.2 }, items = { "Hold", "Toggle", "Single Press" }, item_h = 22 } }
local VK_NAMES = {[0x01]="M1",[0x02]="M2",[0x04]="M3",[0x05]="M4",[0x06]="M5",[0x08]="Bsp",[0x09]="Tab",[0x0D]="Enter",[0x10]="Shift",[0x11]="Ctrl",[0x12]="Alt",[0x13]="Pause",[0x14]="Caps",[0x1B]="Esc",[0x20]="Space",[0x21]="PgUp",[0x22]="PgDown",[0x23]="End",[0x24]="Home",[0x25]="Left",[0x26]="Up",[0x27]="Right",[0x28]="Down",[0x2D]="Ins",[0x2E]="Del",[0x30]="0",[0x31]="1",[0x32]="2",[0x33]="3",[0x34]="4",[0x35]="5",[0x36]="6",[0x37]="7",[0x38]="8",[0x39]="9",[0x41]="A",[0x42]="B",[0x43]="C",[0x44]="D",[0x45]="E",[0x46]="F",[0x47]="G",[0x48]="H",[0x49]="I",[0x4A]="J",[0x4B]="K",[0x4C]="L",[0x4D]="M",[0x4E]="N",[0x4F]="O",[0x50]="P",[0x51]="Q",[0x52]="R",[0x53]="S",[0x54]="T",[0x55]="U",[0x56]="V",[0x57]="W",[0x58]="X",[0x59]="Y",[0x5A]="Z",[0x60]="Num0",[0x61]="Num1",[0x62]="Num2",[0x63]="Num3",[0x64]="Num4",[0x65]="Num5",[0x66]="Num6",[0x67]="Num7",[0x68]="Num8",[0x69]="Num9",[0x6A]="Num*",[0x6B]="Num+",[0x6C]="NumEnter",[0x6D]="Num-",[0x6E]="Num.",[0x6F]="Num/",[0x70]="F1",[0x71]="F2",[0x72]="F3",[0x73]="F4",[0x74]="F5",[0x75]="F6",[0x76]="F7",[0x77]="F8",[0x78]="F9",[0x79]="F10",[0x7A]="F11",[0x7B]="F12",[0x90]="NumLk",[0x91]="ScrLk",[0xBA]=";",[0xBB]="=",[0xBC]=",",[0xBD]="-",[0xBE]=".",[0xBF]="/",[0xC0]="`",[0xDB]="[",[0xDC]="\\",[0xDD]="]",[0xDE]="'" }
local function get_key_name(vk) if vk and vk > 0 then return VK_NAMES[vk] or string.format("K:0x%X", vk) end return "NONE" end
local VK_TO_CHAR = { [0x30] = { normal = "0", shifted = ")" },[0x31]={ normal = "1", shifted = "!" },[0x32]={ normal = "2", shifted = "@" },[0x33]={ normal = "3", shifted = "#" },[0x34]={ normal = "4", shifted = "$" },[0x35]={ normal = "5", shifted = "%" },[0x36]={ normal = "6", shifted = "^" },[0x37]={ normal = "7", shifted = "&" },[0x38]={ normal = "8", shifted = "*" },[0x39]={ normal = "9", shifted = "(" },[0x41]={ normal = "a", shifted = "A" },[0x42]={ normal = "b", shifted = "B" },[0x43]={ normal = "c", shifted = "C" },[0x44]={ normal = "d", shifted = "D" },[0x45]={ normal = "e", shifted = "E" },[0x46]={ normal = "f", shifted = "F" },[0x47]={ normal = "g", shifted = "G" },[0x48]={ normal = "h", shifted = "H" },[0x49]={ normal = "i", shifted = "I" },[0x4A]={ normal = "j", shifted = "J" },[0x4B]={ normal = "k", shifted = "K" },[0x4C]={ normal = "l", shifted = "L" },[0x4D]={ normal = "m", shifted = "M" },[0x4E]={ normal = "n", shifted = "N" },[0x4F]={ normal = "o", shifted = "O" },[0x50]={ normal = "p", shifted = "P" },[0x51]={ normal = "q", shifted = "Q" },[0x52]={ normal = "r", shifted = "R" },[0x53]={ normal = "s", shifted = "S" },[0x54]={ normal = "t", shifted = "T" },[0x55]={ normal = "u", shifted = "U" },[0x56]={ normal = "v", shifted = "V" },[0x57]={ normal = "w", shifted = "W" },[0x58]={ normal = "x", shifted = "X" },[0x59]={ normal = "y", shifted = "Y" },[0x5A]={ normal = "z", shifted = "Z" },[0x20]={ normal = " ", shifted = " " },[0xBA]={ normal = ";", shifted = ":" },[0xBB]={ normal = "=", shifted = "+" },[0xBC]={ normal = ",", shifted = "<" },[0xBD]={ normal = "-", shifted = "_" },[0xBE]={ normal = ".", shifted = ">" },[0xBF]={ normal = "/", shifted = "?" },[0xC0]={ normal = "`", shifted = "~" },[0xDB]={ normal = "[", shifted = "{" },[0xDC]={ normal = "\\", shifted = "|" },[0xDD]={ normal = "]", shifted = "}" },[0xDE]={ normal = "'", shifted = '"' } }


local themes = {
    default = {
        name = "Default",
        colors = { 
            bg_dark = { 22, 23, 27 }, bg_mid = { 35, 37, 43 }, bg_light = { 50, 52, 60 }, 
            text_main = { 220, 220, 220 }, text_dim = { 150, 150, 150 }, 
            accent = { 130, 100, 255 } 
        },
        fonts = { title = nil }
    },
    halloween = {
        name = "Halloween",
        colors = { 
            bg_dark = { 18, 15, 12 }, bg_mid = { 35, 30, 25 }, bg_light = { 55, 50, 45 }, 
            text_main = { 240, 240, 240 }, text_dim = { 160, 160, 160 }, 
            accent = { 255, 140, 0 } 
        },
        fonts = { title = nil }
    },
    cyberpunk = {
        name = "Cyberpunk",
        colors = {
            bg_dark = { 10, 12, 30 }, bg_mid = { 20, 25, 50 }, bg_light = { 30, 35, 65 },
            text_main = { 220, 220, 255 }, text_dim = { 140, 140, 180 },
            accent = { 0, 255, 255 } 
        },
        fonts = { title = nil }
    },
    ocean = {
        name = "Ocean",
        colors = {
            bg_dark = { 15, 25, 35 }, bg_mid = { 25, 40, 55 }, bg_light = { 40, 60, 75 },
            text_main = { 210, 225, 240 }, text_dim = { 130, 150, 170 },
            accent = { 60, 180, 220 }
        },
        fonts = { title = nil }
    },
    vampire = {
        name = "Vampire",
        colors = {
            bg_dark = { 15, 15, 20 }, bg_mid = { 28, 25, 30 }, bg_light = { 45, 40, 45 },
            text_main = { 220, 210, 210 }, text_dim = { 150, 140, 140 },
            accent = { 180, 20, 40 }
        },
        fonts = { title = nil }
    }
}





function MenuLib.initialize(config)
    config = config or {}
    local sw, sh = render.get_viewport_size()
    Menu.window.x, Menu.window.y = sw / 2 - Menu.window.w / 2, sh / 2 - Menu.window.h / 2
    Menu.active_tab = config.default_tab or ""
    
    Menu.fonts.main = render.create_font("Verdana", 12, 500)
    Menu.fonts.keybind = render.create_font("Verdana", 11, 500)
    Menu.fonts.tab = render.create_font("Verdana", 14, 500)
    Menu.fonts.group = render.create_font("Verdana", 12, 700)
    Menu.fonts.title = render.create_font("Verdana", 22,400)

    themes.default.fonts.title = render.create_font("Verdana", 22, 400)
    themes.halloween.fonts.title = render.create_font("Verdana", 22, 400)
    themes.cyberpunk.fonts.title = render.create_font("Verdana", 22, 400)
    themes.ocean.fonts.title = render.create_font("Verdana", 22, 400)
    themes.vampire.fonts.title = render.create_font("Verdana", 22, 400)
    
    for name, theme in pairs(themes) do
        if not theme.fonts.title then
            engine.log(string.format("Warning: Font for '%s' theme failed to load. Using default.", name), 255, 200, 100, 255)
        end
    end

    MenuLib.set_theme(Menu.current_theme)
    
    
    engine.register_on_engine_tick(MenuLib.render_all)
    Menu.initialized = true
end


local function update_theme_animation()
    local anim = Menu.theme_anim
    if not anim.is_transitioning then return end
    
    anim.progress = math.min(1.0, anim.progress + anim.speed)
    
    for key, source_rgb in pairs(anim.source_colors) do
        local target_rgb = anim.target_colors[key]
        if target_rgb then
            local new_rgb = {}
            new_rgb[1] = math.floor(math.lerp(source_rgb[1], target_rgb[1], anim.progress))
            new_rgb[2] = math.floor(math.lerp(source_rgb[2], target_rgb[2], anim.progress))
            new_rgb[3] = math.floor(math.lerp(source_rgb[3], target_rgb[3], anim.progress))
            Menu.colors[key] = new_rgb
        end
    end
    
    if anim.progress >= 1.0 then
        anim.is_transitioning = false
    end
end


function MenuLib.set_theme(theme_name)
    local theme = themes[theme_name]
    if not theme or Menu.current_theme == theme_name or Menu.theme_anim.is_transitioning then 
        return 
    end

    Menu.fonts.title = theme.fonts.title or themes.default.fonts.title
    Menu.current_theme = theme_name
    
    local anim = Menu.theme_anim
    
    anim.source_colors = {}
    for k, v in pairs(Menu.colors) do
        anim.source_colors[k] = { v[1], v[2], v[3] }
    end
    
    anim.target_colors = theme.colors
    
    anim.progress = 0
    anim.is_transitioning = true
    
end

function MenuLib.add_tab(id, name)
    table.insert(Menu.tabs, {id = id, name = name, anim = 0})
    if not Menu.active_tab or Menu.active_tab == "" then
        Menu.active_tab = id
    end
end

function MenuLib.add_group(parent_id, name, column)
    local id = parent_id .. "_" .. name
    Menu.groups[id] = {id = id, name = name, tab = parent_id, col = column or 1, elements = {}}
    return id
end

function MenuLib.add_element(group_id, type, id, name, config)
    config = config or {}
    local group = Menu.groups[group_id]
    if not group then return end
    local el = {id = id, type = type, name = name, anim = 0,  is_active = true}
    if type == "checkbox" then
        el.draw = MenuLib.draw_checkbox
        Menu.values[id] = config.default or false
    elseif type == "slider" then
        el.min, el.max, el.drag = config.min or 0, config.max or 100, false
        el.draw = MenuLib.draw_slider
        Menu.values[id] = config.default or el.min
    elseif type == "slider_float" then
        el.min, el.max, el.drag = config.min or 0, config.max or 100, false
        el.draw = MenuLib.draw_slider_float
        Menu.values[id] = config.default or el.min
    elseif type == "keybind" then
        el.binding = false
        el.draw = MenuLib.draw_keybind
        Menu.values[id] = {key = config.default_key or 0, mode = config.default_mode or 1}
    elseif type == "label" then
        el.draw = MenuLib.draw_label
    elseif type == "input_text" then
        el.draw = MenuLib.draw_input_text
        Menu.values[id] = config.default or ""
    elseif type == "button" then
        el.draw = MenuLib.draw_button
        el.callback = config.callback or function() end
    elseif type == "singleselect" then
        el.draw = MenuLib.draw_singleselect
        el.items = config.items or {}
        Menu.values[id] = config.default or 1
        el.onChange = config.onChange
    elseif type == "multiselect" then
        el.draw = MenuLib.draw_multiselect
        el.items = config.items or {}
        Menu.values[id] = config.default or {}
    elseif type == "colorpicker_button" then
        el.draw = MenuLib.draw_colorpicker_button
        local default_rgba = config.default or {255, 255, 255, 255}
        local h, s, v = MenuLib.rgb_to_hsv(default_rgba[1], default_rgba[2], default_rgba[3])
        Menu.values[id] = {h = h, s = s, v = v, a = default_rgba[4]}
        Menu.color_pickers[id] = {id = id, title = name, visible = false, x = 0, y = 0, w = 240, h = 270, dragging = false, drag_x = 0, drag_y = 0, dragging_sv = false, dragging_hue = false, dragging_alpha = false, anim = {alpha = 0, target_alpha = 0, speed = 0.15}}
    end
    table.insert(group.elements, el)
    Menu.elements[id] = el
end

function MenuLib.get_keybind_value(id)
    local default_bind = { key = 0, mode = 1 }
    local stored_bind = Menu.values[id]

    if type(stored_bind) ~= "table" then
        return default_bind
    end
    
    local key_is_valid = type(stored_bind.key) == "number"
    local mode_is_valid = type(stored_bind.mode) == "number"

    return {
        key = key_is_valid and stored_bind.key or default_bind.key,
        mode = mode_is_valid and stored_bind.mode or default_bind.mode
    }
end

function MenuLib.get_value(id)
    local value = Menu.values[id]
    if type(value) == "table" and value.h ~= nil then
        local r, g, b, a = MenuLib.hsv_to_rgb(value.h, value.s, value.v, value.a)
        return {r, g, b, a}
    end
    return value
end

function MenuLib.set_value(id, value)
    if Menu.values[id] ~= nil then
        Menu.values[id] = value
    end
end

function MenuLib.render_all()
    if not Menu.initialized then return end
        update_theme_animation()

    MenuLib.render_menu()
    for _, picker in pairs(Menu.color_pickers) do
        MenuLib.render_single_color_picker(picker)
    end
    MenuLib.render_keybind_mode_selector()
      if MenuLib.Notify then 
        MenuLib.Notify.render()
    end
end

function MenuLib.render_keybind_mode_selector()
    local selector = Menu.keybind_mode_selector
    selector.anim.target_alpha = selector.visible and Menu.anim.alpha > 0.99 and 1 or 0
    selector.anim.alpha = math.lerp(selector.anim.alpha, selector.anim.target_alpha, selector.anim.speed)
    if selector.anim.alpha < 0.01 then return end
    local a = math.floor(255 * selector.anim.alpha)
    local c = Menu.colors
    local mx, my = input.get_mouse_position()
    selector.h = #selector.items * selector.item_h + 10
    render.draw_rectangle(selector.x + 2, selector.y + 2, selector.w, selector.h, 0, 0, 0, math.floor(80 * (a / 255)), 0, true, 4)
    render.draw_rectangle(selector.x, selector.y, selector.w, selector.h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 4)
    render.draw_rectangle(selector.x, selector.y, selector.w, selector.h, c.bg_light[1], c.bg_light[2], c.bg_light[3], a, 1, false, 4)
    local current_y = selector.y + 5
    for i, item in ipairs(selector.items) do
        local hov = mx > selector.x and mx < selector.x + selector.w and my > current_y and my < current_y + selector.item_h
        if hov then
            render.draw_rectangle(selector.x + 2, current_y, selector.w - 4, selector.item_h, c.accent[1], c.accent[2], c.accent[3], a, 0, true, 4)
        end
        render.draw_text(Menu.fonts.main, item, selector.x + 10, current_y + 3, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0)
        if hov and input.is_key_pressed(1) then
            if selector.element_id and Menu.values[selector.element_id] then
                Menu.values[selector.element_id].mode = i
            end
            selector.visible = false
            Menu.click_consumed = true
        end
        current_y = current_y + selector.item_h
    end
end

function MenuLib.render_menu()
    local render_after_queue = {}
    Menu.click_consumed = false

    local menu_bind = MenuLib.get_keybind_value("menu_open_key")
    if menu_bind and input.is_key_pressed(menu_bind.key) then
        Menu.visible = not Menu.visible
        if not Menu.visible then
            for _, p in pairs(Menu.color_pickers) do p.visible = false end
            Menu.keybind_mode_selector.visible = false
        end
    end

    Menu.anim.target_alpha = Menu.visible and 1 or 0
    Menu.anim.alpha = math.lerp(Menu.anim.alpha, Menu.anim.target_alpha, Menu.anim.speed)
    
    if Menu.anim.alpha < 0.01 then
        if Menu.window.dragging then Menu.window.dragging = false end
        if Menu.active_binding_element and Menu.elements[Menu.active_binding_element] then Menu.elements[Menu.active_binding_element].binding = false; Menu.active_binding_element = nil end
        if Menu.active_select_element and Menu.elements[Menu.active_select_element] then Menu.elements[Menu.active_select_element].is_open = false; Menu.active_select_element = nil end
        MenuLib.render_info_window()
        return
    end

    local w, a, s, mx, my = Menu.window, math.floor(255 * Menu.anim.alpha), 20 * (1 - Menu.anim.alpha), input.get_mouse_position()
    local c = Menu.colors

    if not w.dragging and input.is_key_pressed(1) and mx > w.x and mx < w.x + 120 and my > w.y and my < w.y + 50 and not Menu.click_consumed then
        w.dragging, w.drag_x, w.drag_y = true, mx - w.x, my - w.y; Menu.click_consumed = true
    end
    if not input.is_key_down(1) then w.dragging = false end
    if w.dragging then w.x, w.y = mx - w.drag_x, my - w.drag_y end

    render.draw_rectangle(w.x + 4, w.y + 4, w.w, w.h, 0, 0, 0, 80 * (a / 255), 0, true, 6)
    render.draw_rectangle(w.x, w.y, w.w, w.h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 6)
    render.draw_rectangle(w.x + 120, w.y, w.w - 120, w.h, c.bg_mid[1], c.bg_mid[2], c.bg_mid[3], a, 0, true, 6)
    render.draw_text(Menu.fonts.title, "Shook", w.x + 20, w.y + 15 - s, 255, 255, 255, a, 1, 0, 0, 0, a * 0.7)

    local initial_tab_y = w.y + 60 - s
    local target_y = initial_tab_y
    if Menu.active_tab == "" and #Menu.tabs > 0 then Menu.active_tab = Menu.tabs[1].id end
    
    local active_main_tab = nil
    for i, tab in ipairs(Menu.tabs) do
        if tab.id == Menu.active_tab then target_y = initial_tab_y + (i - 1) * 40; active_main_tab = tab; end
    end
    
    Menu.tab_anim_y = math.lerp(Menu.tab_anim_y or target_y, target_y, 0.1)
    render.draw_rectangle(w.x, Menu.tab_anim_y - 2, 3, 30, c.accent[1], c.accent[2], c.accent[3], a, 0, true, 2)
    
    for i, tab in ipairs(Menu.tabs) do
        local cur_y = initial_tab_y + (i-1) * 40; local hov=mx>w.x+10 and mx<w.x+110 and my>cur_y and my<cur_y+30; local act = Menu.active_tab == tab.id;
        tab.anim = math.lerp(tab.anim or 0, act and 1 or 0, 0.15);
        if tab.anim > 0.01 then render.draw_rectangle(w.x+5, cur_y-2, 110, 30, c.accent[1], c.accent[2], c.accent[3], math.floor(tab.anim*80*(a/255)),0,true,4) end
        if hov and not act then render.draw_rectangle(w.x+5, cur_y-2, 110, 30, 255, 255, 255, math.floor(50*(a/255)), 0, true, 4) end
        local tc = act and c.text_main or c.text_dim;
        render.draw_text(Menu.fonts.tab, tab.name, w.x+25, cur_y+5, tc[1], tc[2], tc[3], a, 0, 0, 0, 0, 0)
        if hov and input.is_key_pressed(1) and not Menu.click_consumed then
            Menu.active_tab = tab.id
            if tab.sub_tabs and #tab.sub_tabs > 0 then Menu.active_sub_tab = tab.sub_tabs[1].id else Menu.active_sub_tab = nil end
            Menu.click_consumed = true
        end
    end

    if active_main_tab and active_main_tab.sub_tabs then
        local sub_tab_bar_y, current_x = w.y + 20, w.x + 140
        for _, sub_tab in ipairs(active_main_tab.sub_tabs) do
            local text_w, text_h = render.measure_text(Menu.fonts.main, sub_tab.name)
            local is_active = Menu.active_sub_tab == sub_tab.id
            local is_hovered = mx > current_x and mx < current_x + text_w + 10 and my > sub_tab_bar_y and my < sub_tab_bar_y + text_h + 4
            local tc = is_active and c.text_main or c.text_dim
            if is_hovered and not is_active then tc = {255, 255, 255} end
            
            render.draw_text(Menu.fonts.main, sub_tab.name, current_x + 5, sub_tab_bar_y + 2, tc[1], tc[2], tc[3], a, 0, 0, 0, 0, 0)
            sub_tab.anim = math.lerp(sub_tab.anim or 0, is_active and 1 or 0, 0.2)
            if sub_tab.anim > 0.01 then render.draw_rectangle(current_x, sub_tab_bar_y + text_h + 2, text_w + 10, 2, c.accent[1], c.accent[2], c.accent[3], math.floor(sub_tab.anim * a), 0, true, 1) end
            
            if is_hovered and input.is_key_pressed(1) and not Menu.click_consumed then
                Menu.active_sub_tab = sub_tab.id
                Menu.click_consumed = true
            end
            current_x = current_x + text_w + 20
        end
    end

    
    local content_start_y = w.y + (active_main_tab and active_main_tab.sub_tabs and 60 or 30) - s
    local x1, x2 = w.x + 140, w.x + 375
    local current_y1, current_y2 = content_start_y, content_start_y
    local ELEMENT_PADDING = 5

    for _, group in pairs(Menu.groups) do
        local should_draw = false
        if active_main_tab and active_main_tab.sub_tabs then
            if group.tab == Menu.active_sub_tab then
                should_draw = true
            end
        else
            if group.tab == Menu.active_tab then
                should_draw = true
            end
        end
        
        if should_draw then
            local x, y
            if group.col == 1 then
                x, y = x1, current_y1 
            else 
                x, y = x2, current_y2
            end

            render.draw_text(Menu.fonts.group, group.name, x, y, c.text_dim[1],c.text_dim[2],c.text_dim[3],a,0,0,0,0,0)
            local local_y_cursor = y + 25
                  
            for _, el in ipairs(group.elements) do
                if el.is_active then
                    el.draw(el, a, x, local_y_cursor, mx, my, render_after_queue) 
                    local_y_cursor = local_y_cursor + el.h + ELEMENT_PADDING
                end
            end
            
            if group.col == 1 then
                current_y1 = local_y_cursor + 20 
            else 
                current_y2 = local_y_cursor + 20
            end
        end
    end
    
    local btn_x,btn_y=w.x+20,w.y+w.h-30;local btn_text="[?] Info";local btn_w_est=50;local hov=mx>btn_x and mx<btn_x+btn_w_est and my>btn_y-2 and my<btn_y+12;local tc=hov and c.text_main or c.text_dim;render.draw_text(Menu.fonts.main,btn_text,btn_x,btn_y,tc[1],tc[2],tc[3],a,0,0,0,0,0);if hov and input.is_key_pressed(1)then Menu.info_window.visible=not Menu.info_window.visible;if Menu.info_window.visible then local sw,sh=render.get_viewport_size();Menu.info_window.x=sw/2-Menu.info_window.w/2;Menu.info_window.y=sh/2-Menu.info_window.h/2 end;Menu.click_consumed=true end;MenuLib.render_info_window();if input.is_key_pressed(1)and not Menu.click_consumed then if Menu.active_select_element then local el=Menu.elements[Menu.active_select_element];if el then el.is_open=false end;Menu.active_select_element=nil end;if Menu.keybind_mode_selector.visible then local sel=Menu.keybind_mode_selector;if not(mx>sel.x and mx<sel.x+sel.w and my>sel.y and my<sel.y+sel.h)then sel.visible=false end end end
    for _,f in ipairs(render_after_queue)do f()end
end






local function can_interact(element_id)

    if Menu.click_consumed then 
        return false 
    end
    
    if Menu.active_select_element then
        if Menu.active_select_element == element_id then
            return true
        else
            return false
        end
    end
    
    if Menu.active_binding_element then
        if Menu.active_binding_element == element_id then
            return true
        else
            return false
        end
    end
    
    return true
end

function MenuLib.draw_checkbox(opt, a, x, y, mx, my, r_queue)
    opt.h = 20
    local v = Menu.values[opt.id]
    local c = Menu.colors
    local is_hovered = mx > x + 195 and mx < x + 225 and my > y - 2 and my < y + 18
    
    if is_hovered and input.is_key_pressed(1) and can_interact(opt.id) then
        Menu.values[opt.id] = not v
        Menu.click_consumed = true
    end
    
    opt.anim = math.lerp(opt.anim or (v and 1 or 0), v and 1 or 0, 0.2)
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    render.draw_rectangle(x + 195, y, 30, 16, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 8)
    if opt.anim > 0.01 then
        local bgr, bgg, bgb = math.lerp(c.bg_dark[1], c.accent[1], opt.anim), math.lerp(c.bg_dark[2], c.accent[2], opt.anim), math.lerp(c.bg_dark[3], c.accent[3], opt.anim)
        render.draw_rectangle(x + 195, y, 30, 16, bgr, bgg, bgb, a, 0, true, 8)
        render.draw_circle(x + 195 + 8 + (14 * opt.anim), y + 8, 6, 255, 255, 255, a, 0, true)
    else
        render.draw_circle(x + 195 + 8, y + 8, 6, 100, 100, 100, a, 0, true)
    end
end

function MenuLib.draw_slider(opt, a, x, y, mx, my, r_queue)
    opt.h = 35
    local w = 220
    local c = Menu.colors
    local hov = mx > x and mx < x + w and my > y + 18 and my < y + 32
    
    if hov and input.is_key_pressed(1) and can_interact(opt.id) then
        opt.is_dragging = true
        Menu.click_consumed = true
    end
    if not input.is_key_down(1) then opt.is_dragging = false end
    
    if opt.is_dragging then
        Menu.values[opt.id] = math.clamp(math.round(math.map(mx, x, x + w, opt.min, opt.max)), opt.min, opt.max)
        Menu.click_consumed = true
    end

    local v = Menu.values[opt.id]
    local r = (v - opt.min) / (opt.max - opt.min)
    local vs = string.format("%d", v)
    opt.anim_ratio = math.lerp(opt.anim_ratio or r, r, 0.15)
    
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    render.draw_text(Menu.fonts.main, vs, x + w - 35, y, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
    render.draw_rectangle(x, y + 20, w, 4, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 2)
    if opt.anim_ratio > 0.001 then render.draw_rectangle(x, y + 20, w * opt.anim_ratio, 4, c.accent[1], c.accent[2], c.accent[3], a, 0, true, 2) end
    render.draw_circle(x + w * opt.anim_ratio, y + 22, 5, 255, 255, 255, a, 0, true)
end

function MenuLib.draw_slider_float(opt, a, x, y, mx, my, r_queue)
    opt.h = 35
    local w = 220
    local c = Menu.colors
    local hov = mx > x and mx < x + w and my > y + 18 and my < y + 32
    
    if hov and input.is_key_pressed(1) and can_interact(opt.id) then
        opt.is_dragging = true
        Menu.click_consumed = true
    end
    if not input.is_key_down(1) then opt.is_dragging = false end
    
    if opt.is_dragging then
        local val = math.map(mx, x, x + w, opt.min, opt.max)
        Menu.values[opt.id] = math.clamp(val, opt.min, opt.max)
        Menu.click_consumed = true
    end

    local v = Menu.values[opt.id]
    local r = (v - opt.min) / (opt.max - opt.min)
    local vs = string.format("%.2f", v)
    opt.anim_ratio = math.lerp(opt.anim_ratio or r, r, 0.15)
    
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    render.draw_text(Menu.fonts.main, vs, x + w - 40, y, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
    render.draw_rectangle(x, y + 20, w, 4, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 2)
    if opt.anim_ratio > 0.001 then render.draw_rectangle(x, y + 20, w * opt.anim_ratio, 4, c.accent[1], c.accent[2], c.accent[3], a, 0, true, 2) end
    render.draw_circle(x + w * opt.anim_ratio, y + 22, 5, 255, 255, 255, a, 0, true)
end

function MenuLib.draw_label(opt, a, x, y, mx, my, r_queue)
    opt.h = 20
    local c = Menu.colors
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0) end
end

local input_timers = { backspace = 0 }

function MenuLib.draw_input_text(opt, a, x, y, mx, my, r_queue)
    opt.h = 35
    local w, h = 220, 20
    
    local c = Menu.colors or { 
        bg_dark={20,20,20}, bg_light={50,50,50}, 
        text_main={255,255,255}, text_dim={150,150,150}, accent={100,100,255} 
    }
    
    local hov = mx > x and mx < x + w and my > y + 15 and my < y + 15 + h
    if input.is_key_pressed(1) and can_interact(opt.id) then
        if hov then
            Menu.active_input_element = opt.id
            Menu.click_consumed = true
        elseif Menu.active_input_element == opt.id then
            Menu.active_input_element = nil
        end
    end
    
    if Menu.values[opt.id] == nil then Menu.values[opt.id] = "" end
    local current_text = tostring(Menu.values[opt.id])
    local now = winapi.get_tickcount64()

    if Menu.active_input_element == opt.id then
        
        if input.is_key_pressed(0x0D) or input.is_key_pressed(0x1B) then
            Menu.active_input_element = nil
        end


        local backspace_down = input.is_key_down(0x08)
        if backspace_down then
            if input.is_key_pressed(0x08) then

                if #current_text > 0 then
                    current_text = current_text:sub(1, -2)
                    input_timers.backspace = now + 400 
                end
            elseif now > input_timers.backspace then
  
                if #current_text > 0 then
                    current_text = current_text:sub(1, -2)
                    input_timers.backspace = now + 50 
                end
            end
        end

        if _G.get_recent_key_input then
            local typed = _G.get_recent_key_input()
            if typed and typed ~= "" then

                local safe = typed:gsub("[^%w%s%-%_%.,!@#$%%]", "") 
                current_text = current_text .. safe
            end
        else
            if VK_TO_CHAR then
                local shift = input.is_key_down(0x10)
                if input.is_key_pressed(0x20) then current_text = current_text .. " " end
                
                for vk, chars in pairs(VK_TO_CHAR) do
                    if vk ~= 0x20 and input.is_key_pressed(vk) then
                        local char = shift and chars.shifted or chars.normal
                        current_text = current_text .. char
                    end
                end
            end
        end
        
        Menu.values[opt.id] = current_text
    end
    
    local is_active = Menu.active_input_element == opt.id
    local display_text = current_text

    if is_active then
        if (now % 1000) < 500 then
            display_text = display_text .. "|"
        end
    end

    local max_chars = 26
    if #display_text > max_chars then
        display_text = "..." .. string.sub(display_text, -max_chars)
    end

    if opt.name and opt.name ~= "" then 
        render.draw_text(Menu.fonts.main, opt.name, x, y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0,0,0,0,0) 
    end
    
    local br = is_active and c.accent[1] or c.bg_light[1]
    local bg = is_active and c.accent[2] or c.bg_light[2]
    local bb = is_active and c.accent[3] or c.bg_light[3]
    local bg_r, bg_g, bg_b = c.bg_dark[1], c.bg_dark[2], c.bg_dark[3]

    render.draw_rectangle(x, y + 15, w, h, bg_r, bg_g, bg_b, a, 0, true, 4)
    
    render.draw_rectangle(x - 1, y + 14, w + 2, h + 2, br, bg, bb, a, 1, false, 4)
    
    if display_text ~= "" then 
        render.draw_text(Menu.fonts.main, display_text, x + 6, y + 19, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0,0,0,0,0) 
    end
end
function MenuLib.draw_button(opt, a, x, y, mx, my, r_queue)
    opt.h = 30
    local w, h = 220, 25
    local c = Menu.colors
    local hov = mx > x and mx < x + w and my > y and my < y + h
    
    if hov and input.is_key_pressed(1) and can_interact(opt.id) then
        opt.callback()
        Menu.click_consumed = true
    end
    
    local bg = hov and c.accent or c.bg_light
    render.draw_rectangle(x, y, w, h, bg[1], bg[2], bg[3], a, 0, true, 4)
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x + 10, y + 5, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
end

function MenuLib.draw_keybind(opt, a, x, y, mx, my, r_queue)
    opt.h = 20
    local w, h = 100, 20
    local kx = x + 120
    local c = Menu.colors
    local hov = mx > kx and mx < kx + w and my > y and my < y + h

    if can_interact(opt.id) then
        if hov and input.is_key_pressed(1) then 
            if Menu.active_binding_element == opt.id then
                Menu.active_binding_element = nil 
            else
                Menu.active_binding_element = opt.id 
                Menu.keybind_mode_selector.visible = false
            end
            Menu.click_consumed = true
        end
        if hov and input.is_key_pressed(2) then 
            local selector = Menu.keybind_mode_selector
            if selector.visible and selector.element_id == opt.id then
                selector.visible = false
            else
                selector.visible = true; selector.element_id = opt.id
                selector.x, selector.y = mx + 5, my
                Menu.active_binding_element = nil
            end
            Menu.click_consumed = true
        end
    end

    local keybind_data = Menu.values[opt.id]
    if Menu.active_binding_element == opt.id then
        for i = 1, 255 do
            if i ~= 1 and input.is_key_pressed(i) then 
                keybind_data.key = (i == 0x1B) and 0 or i
                Menu.active_binding_element = nil
                Menu.click_consumed = true
                break
            end
        end
    end

    -- 3. Draw
    local mode_char = Menu.keybind_mode_selector.items[keybind_data.mode] and Menu.keybind_mode_selector.items[keybind_data.mode]:sub(1, 1) or "H"
    local key_name = (keybind_data.key == 0) and "None" or get_key_name(keybind_data.key)
    local key_text = (Menu.active_binding_element == opt.id) and "[...]" or string.format("[%s] %s", mode_char, key_name)

    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y + 1, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    
    local box_col = (hov or Menu.active_binding_element == opt.id) and c.bg_light or c.bg_dark
    render.draw_rectangle(kx, y, w, h, box_col[1], box_col[2], box_col[3], a, 0, true, 4)
    
    if Menu.active_binding_element == opt.id then
        render.draw_rectangle(kx, y, w, h, c.accent[1], c.accent[2], c.accent[3], a, 1, false, 4)
    end
    render.draw_text(Menu.fonts.keybind, key_text, kx + 5, y + 2, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
end

function MenuLib.draw_singleselect(opt, a, x, y, mx, my, r_queue)
    opt.h = 35
    local w, h = 220, 20
    local c = Menu.colors
    local main_box_y = y + 15
    local hov = mx > x and mx < x + w and my > main_box_y and my < main_box_y + h
    
    if can_interact(opt.id) and hov and input.is_key_pressed(1) then
        if opt.is_open then
            opt.is_open = false
            Menu.active_select_element = nil
        else
            if Menu.active_select_element and Menu.elements[Menu.active_select_element] then 
                Menu.elements[Menu.active_select_element].is_open = false 
            end
            
            opt.is_open = true
            Menu.active_select_element = opt.id
        end
        Menu.click_consumed = true
    end
    
    local selected_index = Menu.values[opt.id] or 1
    local selected_text = (opt.items[selected_index] or "None")
    
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    local border_color = opt.is_open and c.accent or c.bg_light
    render.draw_rectangle(x - 1, main_box_y - 1, w + 2, h + 2, border_color[1], border_color[2], border_color[3], a, 1, false, 4)
    render.draw_rectangle(x, main_box_y, w, h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 4)
    if selected_text and selected_text ~= "" then render.draw_text(Menu.fonts.main, selected_text, x + 5, main_box_y + 2, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0) end
    local arrow_x, arrow_y = x + w - 12, main_box_y + 8
    render.draw_triangle(arrow_x, arrow_y, arrow_x + 6, arrow_y, arrow_x + 3, arrow_y + 3, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 1, true)
    
    if opt.is_open then
        table.insert(r_queue, function()
            local list_y = main_box_y + h
            render.draw_rectangle(x, list_y, w, #opt.items * h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 4)
            for i, item in ipairs(opt.items) do
                local item_y = list_y + (i - 1) * h
                local item_hov = mx > x and mx < x + w and my > item_y and my < item_y + h
                
                if item_hov then render.draw_rectangle(x + 2, item_y, w - 4, h, c.bg_light[1], c.bg_light[2], c.bg_light[3], a, 0, true, 4) end
                render.draw_text(Menu.fonts.main, item, x + 5, item_y + 2, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
                
                if item_hov and input.is_key_pressed(1) then
                    Menu.values[opt.id] = i
                    opt.is_open = false
                    Menu.active_select_element = nil
                    Menu.click_consumed = true
                    if opt.onChange and type(opt.onChange) == "function" then opt.onChange(i, item) end
                end
            end
        end)
    end
end

function MenuLib.draw_multiselect(opt, a, x, y, mx, my, r_queue)
    opt.h = 35
    local w, h = 220, 20
    local c = Menu.colors
    local main_box_y = y + 15
    local hov = mx > x and mx < x + w and my > main_box_y and my < main_box_y + h
    
    if can_interact(opt.id) and hov and input.is_key_pressed(1) then
        if opt.is_open then
            opt.is_open = false
            Menu.active_select_element = nil
        else
            if Menu.active_select_element and Menu.elements[Menu.active_select_element] then Menu.elements[Menu.active_select_element].is_open = false end
            opt.is_open = true
            Menu.active_select_element = opt.id
        end
        Menu.click_consumed = true
    end
    
    local selected_items = {}
    if Menu.values[opt.id] then
        for i, item in ipairs(opt.items) do
            if Menu.values[opt.id][i] then table.insert(selected_items, item) end
        end
    end
    
    local display_text = table.concat(selected_items, ", ")
    if display_text == "" then display_text = "None" end
    if #selected_items > 3 then display_text = #selected_items .. " items selected" end
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    local border_color = opt.is_open and c.accent or c.bg_light
    render.draw_rectangle(x - 1, main_box_y - 1, w + 2, h + 2, border_color[1], border_color[2], border_color[3], a, 1, false, 4)
    render.draw_rectangle(x, main_box_y, w, h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 4)
    if display_text and display_text ~= "" then render.draw_text(Menu.fonts.main, display_text, x + 5, main_box_y + 2, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0) end
    local arrow_x, arrow_y = x + w - 12, main_box_y + 8
    render.draw_triangle(arrow_x, arrow_y, arrow_x + 6, arrow_y, arrow_x + 3, arrow_y + 3, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 1, true)
    
    if opt.is_open then
        table.insert(r_queue, function()
            local list_y = main_box_y + h
            render.draw_rectangle(x, list_y, w, #opt.items * h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 4)
            for i, item in ipairs(opt.items) do
                local item_y = list_y + (i - 1) * h
                local item_hov = mx > x and mx < x + w and my > item_y and my < item_y + h
                
                local is_ticked = (Menu.values[opt.id] and Menu.values[opt.id][i]) or false
                
                if item_hov then render.draw_rectangle(x + 2, item_y, w - 4, h, c.bg_light[1], c.bg_light[2], c.bg_light[3], a, 0, true, 4) end
                render.draw_rectangle(x + 5, item_y + 5, 10, 10, c.bg_light[1], c.bg_light[2], c.bg_light[3], a, 1, false, 3)
                if is_ticked then render.draw_rectangle(x + 5, item_y + 5, 10, 10, c.accent[1], c.accent[2], c.accent[3], a, 0, true, 3) end
                render.draw_text(Menu.fonts.main, item, x + 22, item_y + 2, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
                
                if item_hov and input.is_key_pressed(1) then
                    if not Menu.values[opt.id] then Menu.values[opt.id] = {} end
                    Menu.values[opt.id][i] = not is_ticked
                    Menu.click_consumed = true
                end
            end
        end)
    end
end


function MenuLib.draw_colorpicker_button(opt, a, x, y, mx, my, render_queue)
    opt.h = 20
    local w, h = 30, 16
    local swatch_x = x + 190
    local c = Menu.colors
    local hsva_val = Menu.values[opt.id]
    local r, g, b, color_alpha = MenuLib.hsv_to_rgb(hsva_val.h, hsva_val.s, hsva_val.v, hsva_val.a)
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y + 1, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    render.draw_rectangle(swatch_x, y, w, h, c.bg_light[1], c.bg_light[2], c.bg_light[3], a, 1, false, 4)
    render.draw_rectangle(swatch_x + 1, y + 1, w - 2, h - 2, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 3)
    render.draw_rectangle(swatch_x + 1, y + 1, w - 2, h - 2, r, g, b, color_alpha, 0, true, 3)
    local hov = mx > swatch_x and mx < swatch_x + w and my > y and my < y + h
    if hov then render.draw_rectangle(swatch_x, y, w, h, 255, 255, 255, 40, 0, true, 4) end
    if hov and input.is_key_pressed(1) and not Menu.click_consumed then
        local cpw = Menu.color_pickers[opt.id]
        cpw.visible = not cpw.visible
        if cpw.visible then
            cpw.x, cpw.y = Menu.window.x + Menu.window.w + 10, Menu.window.y
        end
        Menu.click_consumed = true
    end
end

function MenuLib.draw_glow_rect(x, y, w, h, rounding, glow_color, master_alpha)
    local r, g, b, a
    if glow_color.h then r, g, b, a = MenuLib.hsv_to_rgb(glow_color.h, glow_color.s, glow_color.v, glow_color.a) else r, g, b, a = glow_color[1], glow_color[2], glow_color[3], glow_color[4] end
    local steps = 4
    local size_increase = 1.5
    for i = steps, 1, -1 do
        local step_alpha = math.floor((a / steps) * 0.5 * (master_alpha / 255))
        local offset = i * size_increase
        render.draw_rectangle(x - offset, y - offset, w + offset * 2, h + offset * 2, r, g, b, step_alpha, 0, true, rounding + offset)
    end
end

function MenuLib.render_single_color_picker(cpw)
    cpw.anim.target_alpha = cpw.visible and 1 or 0
    cpw.anim.alpha = math.lerp(cpw.anim.alpha, cpw.anim.target_alpha, 0.25)
    if cpw.anim.alpha < 0.01 then
        cpw.dragging, cpw.dragging_sv, cpw.dragging_hue, cpw.dragging_alpha = false, false, false, false
        return
    end
    local master_alpha = math.floor(255 * cpw.anim.alpha)
    local c = Menu.colors
    local mx, my = input.get_mouse_position()
    local layout = {padding = 15, title_h = 35, sv_size = 150, hue_w = 20, slider_h = 22, preview_h = 40, gap = 12, rounding = 8}
    cpw.w = layout.padding * 2 + layout.sv_size + layout.gap + layout.hue_w
    cpw.h = layout.title_h + layout.sv_size + layout.gap + layout.slider_h + layout.gap + layout.preview_h + layout.padding
    if input.is_key_pressed(1) and not(cpw.dragging_sv or cpw.dragging_hue or cpw.dragging_alpha) then
        if mx > cpw.x and mx < cpw.x + cpw.w and my > cpw.y and my < cpw.y + layout.title_h then
            cpw.dragging, cpw.drag_x, cpw.drag_y = true, mx - cpw.x, my - cpw.y
            Menu.click_consumed = true
        end
    end
    if not input.is_key_down(1) then cpw.dragging, cpw.dragging_sv, cpw.dragging_hue, cpw.dragging_alpha = false, false, false, false end
    if cpw.dragging then cpw.x, cpw.y = mx - cpw.drag_x, my - cpw.drag_y end
    local sv_x, sv_y = cpw.x + layout.padding, cpw.y + layout.title_h
    local hue_x, hue_y = sv_x + layout.sv_size + layout.gap, sv_y
    local alpha_x, alpha_y = sv_x, sv_y + layout.sv_size + layout.gap
    local alpha_w = layout.sv_size + layout.gap + layout.hue_w
    if input.is_key_pressed(1) then
        if mx > sv_x and mx < sv_x + layout.sv_size and my > sv_y and my < sv_y + layout.sv_size then cpw.dragging_sv = true; Menu.click_consumed = true end
        if mx > hue_x and mx < hue_x + layout.hue_w and my > hue_y and my < hue_y + layout.sv_size then cpw.dragging_hue = true; Menu.click_consumed = true end
        if mx > alpha_x and mx < alpha_x + alpha_w and my > alpha_y and my < alpha_y + layout.slider_h then cpw.dragging_alpha = true; Menu.click_consumed = true end
    end
    local current_hsva = Menu.values[cpw.id]
    if cpw.dragging_sv then
        current_hsva.s = math.clamp((mx - sv_x) / layout.sv_size, 0, 1)
        current_hsva.v = math.clamp(1 - (my - sv_y) / layout.sv_size, 0, 1)
    end
    if cpw.dragging_hue then current_hsva.h = math.clamp(1 - (my - hue_y) / layout.sv_size, 0, 1) end
    if cpw.dragging_alpha then current_hsva.a = math.floor(math.clamp((mx - alpha_x) / alpha_w * 255, 0, 255)) end
    local r, g, b = MenuLib.hsv_to_rgb(current_hsva.h, current_hsva.s, current_hsva.v)
    render.draw_rectangle(cpw.x, cpw.y, cpw.w, cpw.h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], master_alpha, 0, true, layout.rounding)
    render.draw_text(Menu.fonts.title, cpw.title, cpw.x + layout.padding, cpw.y + 8, c.text_main[1], c.text_main[2], c.text_main[3], master_alpha, 0, 0, 0, 0, 0)
    render.draw_line(cpw.x + 8, cpw.y + layout.title_h, cpw.x + cpw.w - 8, cpw.y + layout.title_h, c.bg_light[1], c.bg_light[2], c.bg_light[3], master_alpha, 1)
    local close_x, close_y, size = cpw.x + cpw.w - 22, cpw.y + 11, 12
    local hov_close = mx > close_x - 3 and mx < close_x + size + 3 and my > close_y - 3 and my < close_y + size + 3
    local clr = hov_close and c.accent or c.text_dim
    render.draw_line(close_x, close_y, close_x + size, close_y + size, clr[1], clr[2], clr[3], master_alpha, 1.5)
    render.draw_line(close_x, close_y + size, close_x + size, close_y, clr[1], clr[2], clr[3], master_alpha, 1.5)
    if hov_close and input.is_key_pressed(1) then cpw.visible = false; Menu.click_consumed = true end
    local hue_r, hue_g, hue_b = MenuLib.hsv_to_rgb(current_hsva.h, 1, 1)
    for i = 0, layout.sv_size - 1, 2 do
        local ratio = i / layout.sv_size
        local r_lerp = math.lerp(255, hue_r, ratio)
        local g_lerp = math.lerp(255, hue_g, ratio)
        local b_lerp = math.lerp(255, hue_b, ratio)
        render.draw_rectangle(sv_x + i, sv_y, 2, layout.sv_size, r_lerp, g_lerp, b_lerp, master_alpha, 0, true)
    end
    render.draw_gradient_rectangle(sv_x, sv_y, layout.sv_size, layout.sv_size, {{0, 0, 0, 0}, {0, 0, 0, 255}}, 0)
    for i = 0, layout.sv_size - 1 do
        local hr, hg, hb = MenuLib.hsv_to_rgb(1 - i / layout.sv_size, 1, 1)
        render.draw_line(hue_x, hue_y + i, hue_x + layout.hue_w, hue_y + i, hr, hg, hb, master_alpha, 1)
    end
    local alpha_rounding = layout.slider_h / 2
    MenuLib.draw_checkered_background(alpha_x, alpha_y, alpha_w, layout.slider_h, master_alpha)
    render.draw_gradient_rectangle(alpha_x, alpha_y, alpha_w, layout.slider_h, {{r, g, b, 0}, {r, g, b, master_alpha}}, alpha_rounding)
    render.draw_rectangle(sv_x - 1, sv_y - 1, layout.sv_size + 2, layout.sv_size + 2, c.bg_light[1], c.bg_light[2], c.bg_light[3], master_alpha, 1, false, 8)
    render.draw_rectangle(hue_x - 1, hue_y - 1, layout.hue_w + 2, layout.sv_size + 2, c.bg_light[1], c.bg_light[2], c.bg_light[3], master_alpha, 1, false, 4)
    render.draw_rectangle(alpha_x - 1, alpha_y - 1, alpha_w + 2, layout.slider_h + 2, c.bg_light[1], c.bg_light[2], c.bg_light[3], master_alpha, 1, false, alpha_rounding + 1)
    render.draw_circle(sv_x + current_hsva.s * layout.sv_size, sv_y + (1 - current_hsva.v) * layout.sv_size, 5, 0, 0, 0, math.floor(master_alpha * 0.6), 1, false)
    render.draw_circle(sv_x + current_hsva.s * layout.sv_size, sv_y + (1 - current_hsva.v) * layout.sv_size, 4, 255, 255, 255, master_alpha, 1, false)
    render.draw_rectangle(hue_x - 2, hue_y + (1 - current_hsva.h) * layout.sv_size - 2, layout.hue_w + 4, 4, 255, 255, 255, master_alpha, 1, false, 2)
    local alpha_cursor_x = alpha_x + (current_hsva.a / 255) * alpha_w
    render.draw_rectangle(alpha_cursor_x - 4, alpha_y - 2, 8, layout.slider_h + 4, 255, 255, 255, master_alpha, 1.5, false, 4)
    local preview_y = alpha_y + layout.slider_h + layout.gap
    local preview_w = 90
    MenuLib.draw_glow_rect(alpha_x, preview_y, preview_w, layout.preview_h, layout.rounding, {r, g, b, 120}, master_alpha)
    render.draw_rectangle(alpha_x, preview_y, preview_w, layout.preview_h, r, g, b, current_hsva.a, 0, true, layout.rounding - 1)
    local hex_x = alpha_x + preview_w + layout.gap
    local hex_w = alpha_w - preview_w - layout.gap
    render.draw_rectangle(hex_x, preview_y, hex_w, layout.preview_h, c.bg_mid[1], c.bg_mid[2], c.bg_mid[3], master_alpha, 0, true, layout.rounding)
    local hex_text = string.format("#%02X%02X%02X", r, g, b)
    render.draw_text(Menu.fonts.main, hex_text, hex_x + 12, preview_y + 11, c.text_dim[1], c.text_dim[2], c.text_dim[3], master_alpha, 0, 0, 0, 0, 0)
end






function MenuLib.render_info_window()
    local iw = Menu.info_window
    iw.anim.target_alpha = (iw.visible and Menu.anim.alpha > 0.99) and 1 or 0
    iw.anim.alpha = math.lerp(iw.anim.alpha, iw.anim.target_alpha, iw.anim.speed)
    if iw.anim.alpha < 0.01 then
        iw.dragging = false
        return
    end

    local a = math.floor(255 * iw.anim.alpha)
    local c = Menu.colors
    local mx, my = input.get_mouse_position()

    if not iw.dragging and input.is_key_pressed(1) and mx > iw.x and mx < iw.x + iw.w and my > iw.y and my < iw.y + 30 then
        iw.dragging, iw.drag_x, iw.drag_y = true, mx - iw.x, my - iw.y
    end
    if not input.is_key_down(1) then iw.dragging = false end
    if iw.dragging then iw.x, iw.y = mx - iw.drag_x, my - iw.drag_y end

    render.draw_rectangle(iw.x + 4, iw.y + 4, iw.w, iw.h, 0, 0, 0, 80 * (a / 255), 0, true, 6)
    render.draw_rectangle(iw.x, iw.y, iw.w, iw.h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 6)
    render.draw_gradient_rectangle(iw.x, iw.y, iw.w, 3, {{c.accent[1], c.accent[2], c.accent[3], a}, {c.accent[1] * 0.7, c.accent[2] * 0.7, c.accent[3] * 0.7, a}}, 6)
    local text_y = iw.y + 55 
    render.draw_text(Menu.fonts.main, "Product:", iw.x + 20, text_y, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
    render.draw_text(Menu.fonts.main, "Shook for CS2", iw.x + 100, text_y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0)
    text_y = text_y + 30
    render.draw_text(Menu.fonts.main, "Version:", iw.x + 20, text_y, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
    render.draw_text(Menu.fonts.main, MenuLib.version, iw.x + 100, text_y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0)
    text_y = text_y + 30
    render.draw_text(Menu.fonts.main, "Credits:", iw.x + 20, text_y, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
    render.draw_text(Menu.fonts.main, "Saikaido", iw.x + 100, text_y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0)

    local radius = 10
    local spacing = 28 
    local theme_keys = {"default", "halloween", "cyberpunk", "ocean", "vampire"} 
    
    local num_themes = #theme_keys
    local total_width = (num_themes - 1) * spacing
    local start_x = (iw.x + iw.w / 2) - (total_width / 2)
    local y_pos = iw.y + iw.h - 55

    for i, theme_name in ipairs(theme_keys) do
        local x_pos = start_x + (i - 1) * spacing
        local theme_colors = themes[theme_name].colors
        
        render.draw_circle(x_pos, y_pos, radius, theme_colors.accent[1], theme_colors.accent[2], theme_colors.accent[3], a, 0, true)

        if Menu.current_theme == theme_name then
            render.draw_circle(x_pos, y_pos, radius + 2, 255, 255, 255, a, 2, false)
        end
        
        if input.is_key_pressed(1) and not iw.dragging then
            if math.sqrt((mx - x_pos)^2 + (my - y_pos)^2) < radius then
                MenuLib.set_theme(theme_name)
            end
        end
    end
    
    local btn_text = "[ Close ]"
    local btn_w, _ = render.measure_text(Menu.fonts.main, btn_text)
    local btn_x = iw.x + (iw.w - btn_w) / 2
    local btn_y = iw.y + iw.h - 25
    
    local hov = mx > btn_x and mx < btn_x + btn_w and my > btn_y - 5 and my < btn_y + 15
    local tc = hov and c.accent or c.text_main
    render.draw_text(Menu.fonts.main, btn_text, btn_x, btn_y, tc[1], tc[2], tc[3], a, 0, 0, 0, 0, 0)
    if hov and input.is_key_pressed(1) then iw.visible = false end
    
end



   MenuLib.Notify = { 
        list = {},
        conf = {
            width = 240,
            height = 40,
            x_pad = 20, 
            y_pad = 20,   
            rounding = 6
        }
    }
    
    function MenuLib.Notify.push(text, type_id)
        local time = winapi.get_tickcount64()
        

        local colors = {
            [1] = {130, 100, 255}, 
            [2] = {100, 255, 110},
            [3] = {255, 80, 80}
        }
        
        if type_id == 1 and Menu.colors and Menu.colors.accent then
            local c = Menu.colors.accent
            colors[1] = {c[1], c[2], c[3]}
        end

        table.insert(MenuLib.Notify.list, 1, {
            id = time + math.random(1,1000),
            text = text,
            type = type_id or 1,
            color = colors[type_id] or colors[1],
            start_time = time,
            duration = 3000,
            alpha = 0,    
            anim_y = 0     
        })
    end

    function MenuLib.Notify.render()
        local conf = MenuLib.Notify.conf
        local sw, sh = render.get_viewport_size()
        local now = winapi.get_tickcount64()
        

        local c_bg = Menu.colors.bg_dark or {22, 23, 27}
        local c_outline = {60, 60, 70}
        local c_text = {230, 230, 230}
        
        local x_start = sw - conf.width - conf.x_pad
        local y_start = conf.y_pad + 25 
        
        for i = #MenuLib.Notify.list, 1, -1 do
            local n = MenuLib.Notify.list[i]
            local elapsed = now - n.start_time
            
     
            local target_alpha = 0
            
            if elapsed < 250 then 
                target_alpha = 255 
            elseif elapsed > n.duration then
                target_alpha = 0  
            else
                target_alpha = 255
            end
            
            n.alpha = math.lerp(n.alpha, target_alpha, 0.15)
            
            if elapsed > n.duration and n.alpha < 2 then
                table.remove(MenuLib.Notify.list, i)
                goto continue_notify
            end
            
            local a = math.floor(n.alpha)
            if a > 2 then
 
                local slide_off = (255 - a) * 0.2 
                local bx = x_start + slide_off
                local by = y_start
                
                render.draw_rectangle(bx + 3, by + 3, conf.width, conf.height, 0, 0, 0, math.floor(a * 0.3), conf.rounding, true)
                
                render.draw_rectangle(bx, by, conf.width, conf.height, c_bg[1], c_bg[2], c_bg[3], math.floor(a * 0.95), conf.rounding, true)
                
                local acc = n.color
                render.draw_rectangle(bx, by + 2, 3, conf.height - 4, acc[1], acc[2], acc[3], a, 2, true)
                
                local grad_cols = {{acc[1], acc[2], acc[3], math.floor(a * 0.25)}, {acc[1], acc[2], acc[3], 0}}
                render.draw_gradient_rectangle(bx + 3, by, conf.width - 3, conf.height, grad_cols, conf.rounding)
                
                render.draw_rectangle(bx, by, conf.width, conf.height, c_outline[1], c_outline[2], c_outline[3], math.floor(a * 0.6), 1, false, conf.rounding)
                
                local icon = (n.type == 2) and "success" or ((n.type == 3) and "error" or "info")
                local icon_char = (n.type == 2) and "S" or ((n.type == 3) and "!" or "i") 
                
                render.draw_circle(bx + 20, by + conf.height/2, 9, acc[1], acc[2], acc[3], math.floor(a * 0.15), 0, true)
                render.draw_circle(bx + 20, by + conf.height/2, 9, acc[1], acc[2], acc[3], a, 1, false) 
                

                local font = Menu.fonts.main 
                
                render.draw_text(font, n.text, bx + 40, by + (conf.height / 2) - 6, c_text[1], c_text[2], c_text[3], a, 0, 0,0,0,0)
                
                local visual_height = (conf.height + 6) * (n.alpha / 255) 
                y_start = y_start + visual_height
            end
            
            ::continue_notify::
        end
    end

local CONFIG_MANIFEST = "_config_list.json"
function MenuLib.save_config(name)
    if not name or name == "" then 
        MenuLib.Notify.push("Error: Name cannot be empty", 3)
        return 
    end
    local file_name = name .. ".json"
    local config_data = {}
    for id, value in pairs(Menu.values) do config_data[id] = value end
    local json_string = json.stringify(config_data)
    fs.write_to_file(file_name, json_string)
    
    local list = {}
    if fs.does_file_exist(CONFIG_MANIFEST) then
        local success, data = pcall(json.parse, fs.read_from_file(CONFIG_MANIFEST))
        if success and type(data) == "table" then list = data end
    end
    local exists = false
    for _, v in ipairs(list) do
        if v == name then exists = true; break end
    end
    if not exists then table.insert(list, name) end
    fs.write_to_file(CONFIG_MANIFEST, json.stringify(list))

    MenuLib.Notify.push("Config saved: " .. name, 2)
end

function MenuLib.save_config(name)
    if not name or name == "" then 
        MenuLib.Notify.push("Config name cannot be empty", MenuLib.Notify.Type.ERROR)
        return 
    end
    
    local file_name = name .. ".json"
    local config_data = {}
    for id, value in pairs(Menu.values) do config_data[id] = value end
    
    local json_string = json.stringify(config_data)
    fs.write_to_file(file_name, json_string)
    
    local list = {}
    if fs.does_file_exist(CONFIG_MANIFEST) then
        local success, data = pcall(json.parse, fs.read_from_file(CONFIG_MANIFEST))
        if success and type(data) == "table" then list = data end
    end
    
    local exists = false
    for _, v in ipairs(list) do
        if v == name then exists = true; break end
    end
    
    if not exists then 
        table.insert(list, name) 
        fs.write_to_file(CONFIG_MANIFEST, json.stringify(list))
    end
    
    MenuLib.Notify.push("Saved config: " .. name, MenuLib.Notify.Type.SUCCESS)
    engine.log("Config saved to " .. file_name, 100, 255, 100, 255)
end

function MenuLib.load_config(name)
    if not name or name == "" then 
        MenuLib.Notify.push("Error: Select a config", 3)
        return 
    end
    
    local file_name = name .. ".json"
    if not fs.does_file_exist(file_name) then 
        MenuLib.Notify.push("Error: File not found", 3)
        return 
    end
    
    local json_string = fs.read_from_file(file_name)
    local success, config_data = pcall(json.parse, json_string)
    
    if not success or type(config_data) ~= "table" then
        MenuLib.Notify.push("Error: Corrupt config", 3)
        return
    end

    for id, loaded_value in pairs(config_data) do
        if Menu.values[id] ~= nil then
             local current_value = Menu.values[id]
            if type(current_value) == "table" and current_value.key ~= nil then
                 if type(loaded_value) == "table" then
                     current_value.key = loaded_value.key; current_value.mode = loaded_value.mode
                 end
            elseif type(current_value) == "table" and current_value.h ~= nil then
                 if type(loaded_value)=="table" and loaded_value.h then
                    current_value.h = loaded_value.h; current_value.s = loaded_value.s; 
                    current_value.v = loaded_value.v; current_value.a = loaded_value.a
                 end
            else
                 Menu.values[id] = loaded_value
            end
        end
    end
    MenuLib.Notify.push("Config loaded successfully", 2)
end

function MenuLib.refresh_config_list(element_id)
    local select_el = Menu.elements[element_id]
    if not select_el or select_el.type ~= "singleselect" then return end
    
    local valid_configs = {}
    if fs.does_file_exist(CONFIG_MANIFEST) then
        local success, list = pcall(json.parse, fs.read_from_file(CONFIG_MANIFEST))
        if success and type(list) == "table" then
            for _, name in ipairs(list) do
                local file_name = name .. ".json"
                if fs.does_file_exist(file_name) then
                    table.insert(valid_configs, name)
                end
            end
        end
    end
    select_el.items = valid_configs
    if #valid_configs == 0 then select_el.items = {"No configs found"} end
    Menu.values[select_el.id] = 1
    
    MenuLib.Notify.push("Config list refreshed", 1)
end

function MenuLib.refresh_config_list(element_id)
    local select_el = Menu.elements[element_id]
    if not select_el or select_el.type ~= "singleselect" then return end
    local valid_configs = {}
    if fs.does_file_exist(CONFIG_MANIFEST) then
        local success, list = pcall(json.parse, fs.read_from_file(CONFIG_MANIFEST))
        if success and type(list) == "table" then
            for _, name in ipairs(list) do
                local file_name = name .. ".json"
                if fs.does_file_exist(file_name) then
                    local s, _ = pcall(json.parse, fs.read_from_file(file_name))
                    if s then table.insert(valid_configs, name) end
                end
            end
        end
    end
    select_el.items = valid_configs
    if #valid_configs == 0 then select_el.items = {"No configs found"} end
    Menu.values[select_el.id] = 1
    engine.log("Config list refreshed.", 200, 200, 255, 255)
end
----CS2


local INDICATOR_OPTIONS = { 
    "Rage Aimbot", "Legit Aimbot", "Anti-Aim", "Triggerbot", 
    "RCS"
}


-- local MenuLib = require("Shooktestmenu")

function is_keybind_active(keybind_id)
    local bind = MenuLib.get_keybind_value(keybind_id)
    if not bind or bind.key == 0 then
        return false 
    end


    if bind.mode == 1 then 
        return input.is_key_down(bind.key)
    elseif bind.mode == 2 then
        return input.is_key_toggled(bind.key)
    elseif bind.mode == 3 then 
        return input.is_key_pressed(bind.key)
    end
    
    return false
end

function parse_pos(pos_string)
    if type(pos_string) ~= "string" then return 0, 0 end
    local x, y = string.match(pos_string, "^(-?%d+),(-?%d+)$")
    if x and y then
        return tonumber(x), tonumber(y)
    end
    return 0, 0 
end

function parse_pos(pos_string)
    if type(pos_string) ~= "string" then return 0, 0 end
    local x, y = string.match(pos_string, "^(-?%d+),(-?%d+)$")
    if x and y then
        return tonumber(x), tonumber(y)
    end
    return 0, 0
end

MenuLib.initialize({ key = 0x2E, default_tab = "legit" })


local legit_sub_tabs = {
    { id = "legit_pistol", name = "PISTOL", anim = 0 },
    { id = "legit_deagle", name = "DEAGLE", anim = 0 },
    { id = "legit_smg",    name = "SMG",    anim = 0 },
    { id = "legit_rifle",  name = "RIFLE",  anim = 0 },
    { id = "legit_shotgun",name = "SHOTGUN",anim = 0 },
    { id = "legit_sniper", name = "SNIPERS",anim = 0 }
}

    local visuals_sub_tabs = {
        { id = "vis_enemy", name = "ENEMY", anim = 0 },
        { id = "vis_team",  name = "TEAM",  anim = 0 },
        { id = "vis_world", name = "WORLD", anim = 0 },
        { id = "vis_misc",  name = "MISC",  anim = 0 }
    }

MenuLib.add_tab("rage", "Rage")

table.insert(Menu.tabs, {id = "legit", name = "Legit", anim = 0, sub_tabs = legit_sub_tabs})
Menu.active_sub_tab = "legit_rifle"

table.insert(Menu.tabs, {id = "visuals", name = "Visuals", anim = 0, sub_tabs = visuals_sub_tabs})
MenuLib.add_tab("misc", "Misc")
MenuLib.add_tab("configs", "Configs")


local rage_general = MenuLib.add_group("rage", "Rage Aimbot", 1)
local rage_aa = MenuLib.add_group("rage", "Anti-Aim", 2)


function create_weapon_settings(sub_tab_id, weapon_name)
    local legit_general = MenuLib.add_group(sub_tab_id, weapon_name .. " Aimbot", 1)
    local legit_rcs = MenuLib.add_group(sub_tab_id, "Recoil Control", 2)
    local legit_trigger = MenuLib.add_group(sub_tab_id, "Triggerbot", 2)

    MenuLib.add_element(legit_general, "checkbox", sub_tab_id .. "_legit_enabled", "Enable Aimbot")
    MenuLib.add_element(legit_general, "checkbox", sub_tab_id .. "_legit_vis_check", "Visibility Check")
    MenuLib.add_element(legit_general, "keybind", sub_tab_id .. "_legit_key", "Aimbot Key", { default_key = 90, default_mode = 1 })
    MenuLib.add_element(legit_general, "slider", sub_tab_id .. "_legit_fov", "Aim FOV", { min = 0, max = 100, default = 10 })
    MenuLib.add_element(legit_general, "slider", sub_tab_id .. "_legit_smoothing", "Aim Smoothing", { min = 5, max = 100, default = 8 })
    MenuLib.add_element(legit_general, "slider_float", sub_tab_id .. "_legit_switch_delay", "Target Switch Delay", { min = 0.0, max = 1.0, default = 0.3 })
    MenuLib.add_element(legit_general, "singleselect", sub_tab_id .. "_legit_hitbox", "Aim Hitbox", { items = { "Head", "Neck", "Body", "Pelvis" } })
    MenuLib.add_element(legit_general, "slider", sub_tab_id .. "_legit_human_factor", "Human Factor", { min = 5, max = 100, default = 8 })
    MenuLib.add_element(legit_general, "singleselect", sub_tab_id .. "_legit_target_mode", "Aim Priority", { items = { "Closest to Crosshair" } })
    MenuLib.add_element(legit_general, "checkbox", sub_tab_id .. "_legit_draw_fov", "Draw FOV Circle")
    MenuLib.add_element(legit_general, "checkbox", sub_tab_id .. "_legit_prediction_enabled", "Enable Prediction")
    MenuLib.add_element(legit_general, "keybind", sub_tab_id .. "_legit_prediction_key", "Prediction Key", { default_key = 0, default_mode = 1 })
    MenuLib.add_element(legit_general, "slider_float", sub_tab_id .. "_legit_prediction_h", "Horizontal Prediction", { min = 0.0, max = 1.0, default = 0.05 })
    MenuLib.add_element(legit_general, "slider_float", sub_tab_id .. "_legit_prediction_v", "Vertical Prediction", { min = 0.0, max = 1.0, default = 0.0 })
    MenuLib.add_element(legit_trigger, "keybind", sub_tab_id .. "_trigger_rapid_key", "PredictionBot", { default = 0, mode = key_mode.onhotkey })
    MenuLib.add_element(legit_trigger, "slider", sub_tab_id .. "_trigger_rapid_reduction", "PredictionBot Delay Reduction (ms)", { min = 0, max = 100, default = 20 })

    MenuLib.add_element(legit_rcs, "checkbox", sub_tab_id .. "_rcs_enabled", "Enable RCS")
    MenuLib.add_element(legit_rcs, "slider_float", sub_tab_id .. "_rcs_strength_x", "Strength (Vertical)", { min = 0.0, max = 2.0, default = 2.0 })
    MenuLib.add_element(legit_rcs, "slider_float", sub_tab_id .. "_rcs_strength_y", "Strength (Horizontal)", { min = 0.0, max = 2.0, default = 2.0 })
    MenuLib.add_element(legit_rcs, "slider", sub_tab_id .. "_rcs_start_bullet", "Start Bullet", { min = 1, max = 10, default = 2 })

    MenuLib.add_element(legit_trigger, "checkbox", sub_tab_id .. "_trigger_enabled", "Enable Triggerbot", { default = true })
    MenuLib.add_element(legit_trigger, "keybind", sub_tab_id .. "_trigger_key", "Trigger Hotkey", { default = 0x05, mode = key_mode.onhotkey })
    
    MenuLib.add_element(legit_trigger, "slider", sub_tab_id .. "_trigger_delay", "Trigger Delay (ms)", { min = 0, max = 250, default = 25 })
    
    MenuLib.add_element(legit_trigger, "checkbox", sub_tab_id .. "_trigger_dynamic_delay_enabled", "Enable Dynamic Delay")

    MenuLib.add_element(legit_trigger, "slider", sub_tab_id .. "_trigger_dynamic_delay_min", "Min Dynamic Delay (ms)", { min = 0, max = 250, default = 20 })
    MenuLib.add_element(legit_trigger, "slider", sub_tab_id .. "_trigger_dynamic_delay_max", "Max Dynamic Delay (ms)", { min = 0, max = 250, default = 60 })

    MenuLib.add_element(legit_trigger, "slider", sub_tab_id .. "_trigger_hitchance", "Min Hitchance (%)", { min = 0, max = 100, default = 70 })
    MenuLib.add_element(legit_trigger, "checkbox", sub_tab_id .. "_trigger_team_check", "Team Check", { default = true })
end

for _, sub_tab in ipairs(legit_sub_tabs) do
    create_weapon_settings(sub_tab.id, sub_tab.name)
end


  -- [[ VISUALS GROUPS ]]
    
    -- 1. Enemy
    local vis_enemy_main = MenuLib.add_group("vis_enemy", "Enemy ESP", 1)
    local vis_enemy_colors = MenuLib.add_group("vis_enemy", "Enemy Colors", 2)
    local vis_enemy_glow = MenuLib.add_group("vis_enemy", "Enemy Glow", 2)

    -- 2. Team
    local vis_team_main = MenuLib.add_group("vis_team", "Team ESP", 1)
    local vis_team_colors = MenuLib.add_group("vis_team", "Team Colors", 2)

    -- 3. World
    local vis_world_main = MenuLib.add_group("vis_world", "World ESP", 1)
    local vis_world_settings = MenuLib.add_group("vis_world", "World Settings", 2)
    local vis_world_colors = MenuLib.add_group("vis_world", "Colors", 2)

    -- 4. Misc (Visuals)
    local vis_misc_main = MenuLib.add_group("vis_misc", "Crosshair & Indicators", 1)
    local vis_misc_view = MenuLib.add_group("vis_misc", "View", 2)

    -- [[ RAGE ELEMENTS ]]
    MenuLib.add_element(rage_general, "checkbox", "rage_enabled", "Enable Rage Aimbot")
    MenuLib.add_element(rage_general, "keybind", "rage_key", "Rage Key", { default_key = 0x06, default_mode = 1 })
    MenuLib.add_element(rage_general, "checkbox", "rage_show_fov", "Show FOV", { default = true })
    MenuLib.add_element(rage_general, "slider_float", "rage_fov", "FOV", { min = 1.0, max = 500.0, default = 150.0 })

    -- [[ ENEMY VISUALS ELEMENTS ]]
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_enabled", "Enable Enemy ESP")
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_box", "Box")
    MenuLib.add_element(vis_enemy_main, "singleselect", "esp_box_type", "Box Type", { items = { "Normal", "Corner", "Filled" }, default = 3 })
    MenuLib.add_element(vis_enemy_main, "singleselect", "esp_skeleton_mode", "Skeleton", { items = { "Off", "Normal", "Circular", "Capsule" } })
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_name", "Name")
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_money", "Money")
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_health", "Health Bar", { default = true })
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_armor", "Armor Bar")
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_distance", "Distance")
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_player_weapon", "Weapon")
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_scoped_flag", "Scoped Flag")
    MenuLib.add_element(vis_enemy_main, "checkbox", "esp_flashed_flag", "Flashed Flag")

    MenuLib.add_element(vis_enemy_colors, "colorpicker_button", "esp_box_color", "Box Color", { default = {255, 50, 50, 255} })
    MenuLib.add_element(vis_enemy_colors, "colorpicker_button", "esp_skeleton_color", "Skeleton Color", { default = {200, 200, 200, 255} })
    MenuLib.add_element(vis_enemy_colors, "colorpicker_button", "esp_name_color", "Name Color", { default = {255, 255, 255, 255} })
    MenuLib.add_element(vis_enemy_colors, "colorpicker_button", "esp_money_color", "Money Color", { default = {50, 200, 50, 255} })
    MenuLib.add_element(vis_enemy_colors, "colorpicker_button", "esp_distance_color", "Distance Color", { default = {220, 220, 220, 255} })
    
    MenuLib.add_element(vis_enemy_glow, "checkbox", "esp_glow_enemy", "Enable Glow")
    MenuLib.add_element(vis_enemy_glow, "colorpicker_button", "esp_glow_color_enemy", "Glow Color", { default = {255, 0, 0, 255} })

    -- [[ TEAM VISUALS ELEMENTS ]]
    MenuLib.add_element(vis_team_main, "checkbox", "team_esp_enabled", "Enable Team ESP")
    MenuLib.add_element(vis_team_main, "checkbox", "team_box", "Box")
    MenuLib.add_element(vis_team_main, "singleselect", "team_box_type", "Box Type", { items = { "Normal", "Corner", "Filled" }, default = 1 })
    MenuLib.add_element(vis_team_main, "singleselect", "team_skeleton_mode", "Skeleton", { items = { "Off", "Normal", "Circular", "Capsule" } })
    MenuLib.add_element(vis_team_main, "checkbox", "team_name", "Name")
    MenuLib.add_element(vis_team_main, "checkbox", "team_health", "Health Bar", { default = true })
    MenuLib.add_element(vis_team_main, "checkbox", "team_weapon", "Weapon")
    
    MenuLib.add_element(vis_team_colors, "colorpicker_button", "team_box_color", "Box Color", { default = {0, 150, 255, 255} })
    MenuLib.add_element(vis_team_colors, "colorpicker_button", "team_skeleton_color", "Skeleton Color", { default = {200, 200, 200, 255} })
    MenuLib.add_element(vis_team_colors, "colorpicker_button", "team_name_color", "Name Color", { default = {255, 255, 255, 255} })
    
    -- [[ WORLD VISUALS ELEMENTS ]]
    MenuLib.add_element(vis_world_main, "checkbox", "esp_dropped_weapons", "Dropped Weapons")
    MenuLib.add_element(vis_world_main, "checkbox", "esp_projectiles", "Grenades")
    MenuLib.add_element(vis_world_main, "checkbox", "esp_bomb", "C4 Bomb")
    MenuLib.add_element(vis_world_main, "checkbox", "esp_chickens", "Chickens")

    MenuLib.add_element(vis_world_settings, "checkbox", "world_nightmode", "Nightmode")
    MenuLib.add_element(vis_world_settings, "slider_float", "world_nightmode_intensity", "Nightmode Intensity", { min = 1.0, max = 100.0, default = 50.0 })
    MenuLib.add_element(vis_world_settings, "checkbox", "world_smoke_mod", "Smoke Color Mod", { default = true })

    MenuLib.add_element(vis_world_colors, "colorpicker_button", "esp_bomb_color", "Bomb Color", { default = {255, 50, 50, 255} })
    MenuLib.add_element(vis_world_colors, "colorpicker_button", "world_smoke_color", "Smoke Color", { default = {170, 0, 255, 255} })

    -- [[ MISC VISUALS ELEMENTS ]]
    MenuLib.add_element(vis_misc_main, "checkbox", "sniper_crosshair_enabled", "Sniper Crosshair")
    MenuLib.add_element(vis_misc_main, "checkbox", "recoil_dot_enabled", "Recoil Dot")
    MenuLib.add_element(vis_misc_main, "colorpicker_button", "recoil_dot_color", "Recoil Dot Color", { default = {255, 0, 0, 255} })
    MenuLib.add_element(vis_misc_main, "checkbox", "crosshair_enabled", "Custom Crosshair")
    MenuLib.add_element(vis_misc_main, "colorpicker_button", "crosshair_color", "Crosshair Color", { default = {255, 255, 255, 255} })
    MenuLib.add_element(vis_misc_main, "slider", "crosshair_thickness", "Thickness", { min = 0, max = 10, default = 2 })
    MenuLib.add_element(vis_misc_main, "slider", "crosshair_gap", "Gap", { min = 0, max = 10, default = 3 })

    MenuLib.add_element(vis_misc_view, "checkbox", "misc_thirdperson", "Thirdperson")
    MenuLib.add_element(vis_misc_view, "keybind", "misc_thirdperson_key", "Thirdperson Key", { default_key = 86, default_mode = 2 })

local misc_general = MenuLib.add_group("misc", "General", 1)
local misc_indicators = MenuLib.add_group("misc", "Indicators", 1)
local misc_watermark = MenuLib.add_group("misc", "Watermark", 2)
local misc_crosshair = MenuLib.add_group("misc", "Crosshair", 2)
local misc_hitlog = MenuLib.add_group("misc", "Hitlog", 2)
local misc_speclist = MenuLib.add_group("misc", "Spectator List", 2)


MenuLib.add_element(misc_general, "checkbox", "misc_hitsound", "Hitsound - UC")
MenuLib.add_element(misc_general, "checkbox", "misc_hitlog", "Hitlog - uc")
MenuLib.add_element(misc_general, "checkbox", "misc_speclist", "Spectator List - UC")
MenuLib.add_element(misc_general, "checkbox", "misc_c4timer", "C4 Timer Panel")
MenuLib.add_element(misc_general, "checkbox", "misc_radar", "Radar")
MenuLib.add_element(misc_general, "checkbox", "misc_anti_flash", "Enable Anti-Flash")
MenuLib.add_element(misc_general, "checkbox", "misc_thirdperson", "Enable Thirdperson")
MenuLib.add_element(misc_general, "keybind", "misc_thirdperson_key", "Thirdperson Key", { default_key = 86, default_mode = 2 })
MenuLib.add_element(misc_general, "checkbox", "misc_bhop", "Enable Bunnyhop", { default = true })

MenuLib.add_element(misc_indicators, "multiselect", "indicator_features", "Enabled Indicators", { items = INDICATOR_OPTIONS, default = {[1]=true,[2]=true} })
MenuLib.add_element(misc_indicators, "colorpicker_button", "indicator_accent_color", "Indicator Accent", { default = {255, 0, 0, 255} })
MenuLib.add_element(misc_indicators, "checkbox", "design_mode", "Design Mode (Overlay Edit)")
MenuLib.add_element(misc_indicators, "slider", "design_dim", "Screen Dim", { min = 0, max = 10, default = 3 })
MenuLib.add_element(misc_indicators, "input_text", "pos_watermark", "Watermark Position", { default = "20,20" })
MenuLib.add_element(misc_indicators, "input_text", "pos_speclist", "Spectator List Position", { default = "100,120" })
MenuLib.add_element(misc_indicators, "input_text", "pos_bomb", "Bomb Timer Position", { default = "25,200" })

MenuLib.add_element(misc_watermark, "checkbox", "watermark_enabled", "Enable Watermark")
MenuLib.add_element(misc_watermark, "colorpicker_button", "watermark_bg_color", "Background Color", { default = {18, 18, 18, 255} })
MenuLib.add_element(misc_watermark, "colorpicker_button", "watermark_outline_color", "Outline Color", { default = {30, 30, 30, 255} })
MenuLib.add_element(misc_watermark, "colorpicker_button", "watermark_text_color", "Text Color", { default = {200, 200, 200, 255} })


MenuLib.add_element(misc_crosshair, "checkbox", "sniper_crosshair_enabled", "Sniper Crosshair", { default = true })

MenuLib.add_element(misc_crosshair, "checkbox", "recoil_dot_enabled", "Show Recoil Dot", { default = true })
MenuLib.add_element(misc_crosshair, "colorpicker_button", "recoil_dot_color", "Recoil Dot Color", { default = {255, 0, 0, 255} })

MenuLib.add_element(misc_crosshair, "checkbox", "crosshair_enabled", "Enable Crosshair")
MenuLib.add_element(misc_crosshair, "colorpicker_button", "crosshair_color", "Crosshair Color", { default = {255, 255, 255, 255} })
MenuLib.add_element(misc_crosshair, "slider", "crosshair_thickness", "Thickness", { min = 0, max = 10, default = 2 })
MenuLib.add_element(misc_crosshair, "slider", "crosshair_gap", "Gap", { min = 0, max = 10, default = 3 })

MenuLib.add_element(misc_hitlog, "colorpicker_button", "hitlog_bg_color", "Background Color", { default = {18, 18, 18, 255} })
MenuLib.add_element(misc_hitlog, "colorpicker_button", "hitlog_outline_color", "Outline Color", { default = {30, 30, 30, 255} })
MenuLib.add_element(misc_hitlog, "colorpicker_button", "hitlog_text_color", "Text Color", { default = {200, 200, 200, 255} })

MenuLib.add_element(misc_speclist, "colorpicker_button", "speclist_bg_color", "Background Color", { default = {18, 18, 18, 255} })
MenuLib.add_element(misc_speclist, "colorpicker_button", "speclist_outline_color", "Outline Color", { default = {30, 30, 30, 255} })
MenuLib.add_element(misc_speclist, "colorpicker_button", "speclist_text_color", "Text Color", { default = {200, 200, 200, 255} })
MenuLib.add_element(misc_speclist, "colorpicker_button", "speclist_header_color", "Header Color", { default = {200, 200, 200, 255} })

local cfg_main = MenuLib.add_group("configs", "Manage Settings", 1)

MenuLib.add_element(cfg_main, "label", "cfg_info", "Select a config to load or overwrite.")
MenuLib.add_element(cfg_main, "singleselect", "cfg_list_select", "Saved Configs", {
    items = {"Click Refresh..."}
})
MenuLib.add_element(cfg_main, "label", "cfg_info_2", "Or type a name below to create a new config.")
MenuLib.add_element(cfg_main, "input_text", "cfg_name_input", "New Config Name", { default = "" })

MenuLib.add_element(cfg_main, "button", "cfg_load", "Load Selected Config", {
    callback = function()
        local list_element = Menu.elements["cfg_list_select"]
        if not list_element then return end
        
        local selected_index = MenuLib.get_value("cfg_list_select")
        local selected_name = list_element.items[selected_index]
        
        if selected_name and selected_name ~= "No configs found" and selected_name ~= "Click Refresh..." then
            MenuLib.load_config(selected_name)
        else
            engine.log("No config selected to load.", 255, 100, 100, 255)
        end
    end
})

MenuLib.add_element(cfg_main, "button", "cfg_save", "Save Config", {
    callback = function()
        local new_name_from_input = MenuLib.get_value("cfg_name_input")
        
        if new_name_from_input and new_name_from_input ~= "" then
            MenuLib.save_config(new_name_from_input)
            MenuLib.set_value("cfg_name_input", "") 
            MenuLib.refresh_config_list("cfg_list_select")
        
        else
            local list_element = Menu.elements["cfg_list_select"]
            if not list_element then return end
            
            local selected_index = MenuLib.get_value("cfg_list_select")
            local selected_name = list_element.items[selected_index]
            
            if selected_name and selected_name ~= "No configs found" and selected_name ~= "Click Refresh..." then
                MenuLib.save_config(selected_name)
            else
                engine.log("No config selected to save over, and no new name provided.", 255, 100, 100, 255)
            end
        end
    end
})

MenuLib.add_element(cfg_main, "button", "cfg_refresh", "Refresh List", {
    callback = function()
        MenuLib.refresh_config_list("cfg_list_select")
    end
})


MenuLib.refresh_config_list("cfg_list_select")

MenuLib.add_element(cfg_main, "keybind", "menu_open_key", "Menu Key", { default_key = 0x2E })

engine.log("SaikaidoSense UI Fully Loaded! Press INSERT to open.", 130, 100, 255, 255)


local config_logs = {}
local function LogSuccess(msg)
    table.insert(config_logs, {
        text = msg,
        time = winapi.get_tickcount64(),
        color = {0, 255, 0, 255},
    })
end
local function LogError(msg)
    table.insert(config_logs, {
        text = msg,
        time = winapi.get_tickcount64(),
        color = {255, 0, 0, 255},
    })
end







local bombpanel_drag_x, bombpanel_drag_y = 25, 200
local bombpanel_dragging = false
local bombpanel_drag_offset_x, bombpanel_drag_offset_y = 0, 0

local hitlog_cache = {
    health = {},
    last_local_shots = -1,
    last_shot_time = 0
}

local DESIGN_MODE_APPEAR_TIME = 0.18
local DESIGN_MODE_FADE_TIME = 0.18
local WATERMARK_APPEAR_TIME = 0.18
local WATERMARK_FADE_TIME = 0.18
local CROSSHAIR_APPEAR_TIME = 0.12
local CROSSHAIR_FADE_TIME = 0.12

local screen_size_x, screen_size_y = render.get_viewport_size()
local DisplaySystem = {
    config = {
        welcome_duration = 3,
        fade_duration = 0.5,
        box_padding = 8,
        blur_opacity = 0.8,
        username = engine.get_username(),
        crosshair = {
            enabled = true,
            color = {255, 255, 255},
            size = 12,
            thickness = 2,
            gap = 3
        },
        watermark_enabled = true,
        -- watermark_position = ui_state.wtpos:get(),
        bg_color = {18, 18, 18},
        border_color = {100, 100, 255},
        text_color = {200, 200, 200},
        welcome_color = {255, 255, 255},
    },
    state = {
        phase = "welcome",
        start_time = winapi.get_tickcount64(),
        fade_out_start = 0,
        frame_count = 0,
        last_fps_time = winapi.get_tickcount64(),
        fps_value = render.get_fps(),
        _design_mode_start_time = 0,
        _design_mode_fade_start_time = 0,
        _design_mode_visible = false,
        _design_mode_fading_out = false,
        _watermark_start_time = 0,
        _watermark_fade_start_time = 0,
        _watermark_visible = false,
        _watermark_fading_out = false,
        _crosshair_start_time = 0,
        _crosshair_fade_start_time = 0,
        _crosshair_visible = false,
        _crosshair_fading_out = false,
    },
    fonts = {
        welcome = render.create_font("Arial", 48, 700),
        main = render.create_font("Verdana", 14, 500),
        icon = render.create_font("Arial", 18, 700),
        logo = render.create_font("Verdana", 12, 700) 
    }
}


local speclist_anim = {
    visible = false,
    anim_progress = 0,
    anim_time = 0.18,
    alpha = 0,
    slide_offset = 0,
    fading_out = false,
    last_state = false,
    last_tick = 0,
}


local nightmode_state = {
    has_saved_original_values = false,
    original_min_exposure = 1.0,
    original_max_exposure = 1.0,
}


local trigger_last_shot_time = 0
local trigger_pending_actions = {}
local last_trigger_delay = 0

local offsets = {
    dwViewMatrix = 0x1E323D0,
    dwLocalPlayerPawn = 0x1BEEF28,
    dwLocalPlayerController = 0x1E1DC18,
    dwEntityList = 0x1D13CE8,
    dwGlobalVars = 0x1BE41C0,
    dwViewAngles = 0x1E3C800,
    m_hPlayerPawn = 0x8FC,
    m_bDormant = 0x10B,
    m_angEyeAngles = 0x3DF0,
    m_iHealth = 0x34C,
    m_lifeState = 0x354,
    m_Glow = 0xCB0,
    m_glowColorOverride = 0x40,
    m_bGlowing = 0x51,
    m_iGlowType = 0x30,
    m_iTeamNum = 0x3EB,
    m_ArmorValue = 0x274C,
    m_vOldOrigin = 0x15A0,
    m_pGameSceneNode = 0x330,
    m_modelState = 0x190,
    m_boneArray = 0x80,
    m_nodeToWorld = 0x10,
    m_sSanitizedPlayerName = 0x850,
    dwPlantedC4 = 0x1E36BE8,
    m_nBombSite = 0x1164,
    m_bBeingDefused = 0x119C,
    m_bBombDefused = 0x11B4,
    m_flFlashDuration = 0x1610,
    m_vecAbsOrigin = 0xD0,  
    m_hOwnerEntity = 0x520,      -- C_BaseEntity
    m_pCameraServices = 0x1428,  
    m_hPostProcessing = 0x1F4,   -- NOT UPDATED OFFSET  
    m_flMinExposure = 0x1014,        
    m_flMaxExposure = 0x1018,
    m_pInGameMoneyServices = 0x7F8,
    m_iAccount = 0x40,
    m_pEntity = 0x10,
    m_designerName = 0x20,
    -- C_SmokeGrenadeProjectile offset
    vSmokeColor = 0x1474,
    m_iIDEntIndex = 0x3ECC,
    m_vecVelocity = 0x430,
    m_pClippingWeapon = 0x3DE0,
    m_bIsScoped = 0x2718,
     m_iszPlayerName = 0x6E8,
    m_AttributeManager = 0x1390,
    m_Item = 0x50,
    m_iItemDefinitionIndex = 0x1BA,
    m_entitySpottedState = 0x2700, 
    m_bSpotted = 0x8,
     m_vecViewOffset = 0xD80,
     m_boneArray_aim = 0x80,
     m_bSpottedByMask = 0xC,
     v_angle = 0x14A8,
    dwCSGOInput = 0x1E3C150, 
    dwForceJump = 0x1BD54A0, 
    m_bCameraInThirdPerson = 0x251, 
    m_iShotsFired = 0x272C,      -- C_CSPlayerPawn
    m_aimPunchAngle = 0x16E4,    -- C_CSPlayerPawn
    m_aimPunchCache = 0x1708,     -- C_CSPlayerPawn
    m_fFlags = 0x3F8,         -- C_BaseEntity::m_fFlags
    m_hpawn = 0x6B4,
    m_pObserverServices = 0x1408,
    m_hObserverTarget = 0x44,
    m_pWeaponServices = 0x13F0,
    m_hActiveWeapon = 0x58,
    m_flC4Blow = 0x1190,
   


}

local g = {
    font = render.create_font("Verdana", 12, 700),
    small_font = render.create_font("Verdana", 11, 400)
}

local esp_fonts = {
    font = render.create_font("Verdana", 12, 700),
    small_font = render.create_font("Verdana", 11, 400),
     name = render.create_font("Verdana", 12, 700),
    weapon = render.create_font("Verdana", 11, 400)
}

local BONE_MAP = {
    head = 6, neck_0 = 5, neck = 5, spine = 4, spine_1 = 4, spine_2 = 2, pelvis = 0,
    arm_upper_L = 8, arm_lower_L = 9, hand_L = 10,
    arm_upper_R = 13, arm_lower_R = 14, hand_R = 15,
    leg_upper_L = 22, leg_lower_L = 23, ankle_L = 24,
    leg_upper_R = 25, leg_lower_R = 26, ankle_R = 27
}

local BONE_MAP_aim = {
    head = 6, neck = 5, spine = 4, pelvis = 0,
    left_shoulder = 8, left_elbow = 9, left_hand = 10,
    right_shoulder = 13, right_elbow = 14, right_hand = 15,
    left_hip = 22, left_knee = 23, left_ankle = 24,
    right_hip = 25, right_knee = 26, right_ankle = 27
}

local hitsound_path = "sounds/hitsound.mp3"
local total_damage = 0
local process = {
    is_open = false,
    client_dll = 0,
}


local TARGET_DESIGNER_NAME = "smokegrenade_projectile"

local hitlog_messages = {}
local function add_hitlog_message(msg)
    table.insert(hitlog_messages, {
        text = msg,
        time = winapi.get_tickcount64(),
        alpha = 255
    })
end
local HITLOG_SHOW_TIME = 2.5
local HITLOG_FADE_TIME = 0.5
local hitlog_box_pad = 12
local hitlog_box_width = 0
local hitlog_box_height = 0
do
    local example_msgs = {
        "Hit an enemy for -100 damage",
        "Hit an enemy for -55 damage",
        "Hit an enemy for -1 damage",
        "Hit an enemy for -999 damage"
    }
    for _, msg in ipairs(example_msgs) do
        local tw, th = render.measure_text(DisplaySystem.fonts.main, msg)
        if tw > hitlog_box_width then hitlog_box_width = tw end
        if th > hitlog_box_height then hitlog_box_height = th end
    end
    hitlog_box_width = hitlog_box_width + hitlog_box_pad * 2
    hitlog_box_height = hitlog_box_height + hitlog_box_pad * 2
end

local configlog_box_pad = 6
local configlog_box_spacing = 8
local configlog_box_width, configlog_box_height = 0, 0
do
    local sample = "Config saved!"
    local tw, th = render.measure_text(DisplaySystem.fonts.main, sample)
    configlog_box_width = tw + configlog_box_pad * 2
    configlog_box_height = th + configlog_box_pad * 2
end

local watermark_drag_x, watermark_drag_y = 20, 20
local watermark_dragging = false
local watermark_drag_offset_x, watermark_drag_offset_y = 0, 0
local speclist_drag_x, speclist_drag_y = 100, 120
local speclist_dragging = false
local speclist_drag_offset_x, speclist_drag_offset_y = 0, 0

-- local function update_speclist_textfields()
--     if ui_state and ui_state.specpos then
--         ui_state.specpos:set(string.format("%d,%d", speclist_drag_x, speclist_drag_y))
--     end
-- end
-- local function update_watermark_textfields()
--     if ui_state and ui_state.wtpos then
--         ui_state.wtpos:set(string.format("%d,%d", watermark_drag_x, watermark_drag_y))
--     end
-- end

-- if bombpanel_dragging then
--     bombpanel_drag_x = mx - bombpanel_drag_offset_x
--     bombpanel_drag_y = my - bombpanel_drag_offset_y
--     if ui_state.bombpanelpos then
--         ui_state.bombpanelpos:set(string.format("%d,%d", bombpanel_drag_x, bombpanel_drag_y))
--     end
-- end
-- if ui_state and ui_state.bombpanelpos and not bombpanel_dragging then
--     local val = ui_state.bombpanelpos:get()
--     local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
--     if x and y then
--         bombpanel_drag_x = tonumber(x)
--         bombpanel_drag_y = tonumber(y)
--     end
-- end

-- if ui_state and ui_state.specpos and ui_state.specpos.on_change then
--     ui_state.specpos:on_change(function(val)
--         local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
--         if x and y then
--             speclist_drag_x = tonumber(x)
--             speclist_drag_y = tonumber(y)
--         end
--     end)
-- end

if watermark_dragging then
    watermark_drag_x = mx - watermark_drag_offset_x
    watermark_drag_y = my - watermark_drag_offset_y
    update_watermark_textfields()
end


local function draw_capsule_line(p1, p2, radius, r, g, b, a)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local len = math.sqrt(dx*dx + dy*dy)

    if len <= 0 then return end

    local nx = -dy / len
    local ny = dx / len

    local ox = nx * radius
    local oy = ny * radius

    local points = {
        p1.x + ox, p1.y + oy,
        p2.x + ox, p2.y + oy,
        p2.x - ox, p2.y - oy,
        p1.x - ox, p1.y - oy
    }

    render.draw_polygon(points, r, g, b, a, 0, true)
    render.draw_circle(p1.x, p1.y, radius, r, g, b, a, 0, true)
    render.draw_circle(p2.x, p2.y, radius, r, g, b, a, 0, true)
end

function draw_capsule_skeleton(bones_2d, scale, color)
    local r, g, b, a = table.unpack(color)
    

    local base = 3.8 * scale 

    local connections = {
        -- Torso
        {"pelvis",  "spine_1", 3.4}, 
        {"spine_1", "spine_2", 3.6}, 
        {"spine_2", "spine_3", 3.6}, 
        {"spine_3", "neck",    2.8}, 
        {"neck",    "head",    3.0}, 

        -- Shoulders
        {"spine_3", "clavicle_L", 2.2},
        {"spine_3", "clavicle_R", 2.2},

        -- Arms
        {"clavicle_L", "arm_upper_L", 2.0}, 
        {"arm_upper_L", "arm_lower_L", 1.8}, 
        {"arm_lower_L", "hand_L",      1.5},

        {"clavicle_R", "arm_upper_R", 2.0}, 
        {"arm_upper_R", "arm_lower_R", 1.8}, 
        {"arm_lower_R", "hand_R",      1.5},

        -- Legs
        {"pelvis", "leg_upper_L", 3.0}, 
        {"leg_upper_L", "leg_lower_L", 2.6}, 
        {"leg_lower_L", "ankle_L", 2.2},

        {"pelvis", "leg_upper_R", 3.0}, 
        {"leg_upper_R", "leg_lower_R", 2.6}, 
        {"leg_lower_R", "ankle_R", 2.2},
    }

    local function draw_segment(p1, p2, radius)
        local dx = p2.x - p1.x
        local dy = p2.y - p1.y
        local len = math.sqrt(dx*dx + dy*dy)
        if len <= 0 then return end

        local nx, ny = -dy/len, dx/len
        local ox, oy = nx*radius, ny*radius

        local fill_points = {
            p1.x + ox, p1.y + oy,
            p2.x + ox, p2.y + oy,
            p2.x - ox, p2.y - oy,
            p1.x - ox, p1.y - oy
        }
        render.draw_polygon(fill_points, r, g, b, 70, 0, true)
        render.draw_circle(p1.x, p1.y, radius, r, g, b, 70, 0, true)
        render.draw_circle(p2.x, p2.y, radius, r, g, b, 70, 0, true)
        -- Sides
        render.draw_line(p1.x + ox, p1.y + oy, p2.x + ox, p2.y + oy, r, g, b, 255, 1)
        render.draw_line(p1.x - ox, p1.y - oy, p2.x - ox, p2.y - oy, r, g, b, 255, 1)
        -- End caps
        render.draw_circle(p1.x, p1.y, radius, r, g, b, 255, 1, false)
        render.draw_circle(p2.x, p2.y, radius, r, g, b, 255, 1, false)
    end

    for _, bond in ipairs(connections) do
        local p1 = bones_2d[bond[1]]
        local p2 = bones_2d[bond[2]]
        if p1 and p2 then
            draw_segment(p1, p2, base * bond[3])
        end
    end
    
    local function draw_foot_capsule(ank)
        local p = bones_2d[ank]
        if p then
            local foot_end = { x = p.x, y = p.y + (6 * scale) }
            draw_segment(p, foot_end, base * 2.0)
        end
    end
    draw_foot_capsule("ankle_L")
    draw_foot_capsule("ankle_R")

    for _, bond in ipairs(connections) do
        local p1 = bones_2d[bond[1]]
        local p2 = bones_2d[bond[2]]
        if p1 and p2 then
            render.draw_line(p1.x, p1.y, p2.x, p2.y, 255, 255, 255, 220, 1)
        end
    end
    
    -- Feet Wireframe
    local function draw_foot_wire(ank)
        local p = bones_2d[ank]
        if p then
            local foot_end = { x = p.x, y = p.y + (6 * scale) }
            render.draw_line(p.x, p.y, foot_end.x, foot_end.y, 255, 255, 255, 220, 1)
        end
    end
    draw_foot_wire("ankle_L")
    draw_foot_wire("ankle_R")
end



function draw_esp_placeholder()
    local vw, vh = render.get_viewport_size()

    local box_height = 280
    local box_width = box_height / 2.0
    local box_center_x = vw / 2
    local box_top_y = vh / 2 - box_height / 2
    
    local rect = {
        top = box_top_y,
        bottom = box_top_y + box_height,
        left = box_center_x - (box_width / 2),
        right = box_center_x + (box_width / 2)
    }


    local placeholder_entity = {
        health = 85,
        armor = 75,
        name = "Placeholder",
        weapon = "AK47",
        distance = 13,
        rect = rect,
        team = 2 
    }
    
    render_entity_info(placeholder_entity)

local skeleton_mode = MenuLib.get_value("esp_skeleton_mode")
    if skeleton_mode > 1 then
        local bones_2d = {
            head = vec2(box_center_x, rect.top + (box_height * 0.05)),
            neck_0 = vec2(box_center_x, rect.top + (box_height * 0.15)),
            spine_1 = vec2(box_center_x, rect.top + (box_height * 0.30)),
            pelvis = vec2(box_center_x, rect.top + (box_height * 0.55)),
            arm_upper_L = vec2(rect.left + (box_width * 0.25), rect.top + (box_height * 0.32)),
            arm_lower_L = vec2(rect.left + (box_width * 0.15), rect.top + (box_height * 0.50)),
            hand_L = vec2(rect.left + (box_width * 0.1), rect.top + (box_height * 0.65)),
            arm_upper_R = vec2(rect.right - (box_width * 0.25), rect.top + (box_height * 0.32)),
            arm_lower_R = vec2(rect.right - (box_width * 0.15), rect.top + (box_height * 0.50)),
            hand_R = vec2(rect.right - (box_width * 0.1), rect.top + (box_height * 0.65)),
            leg_upper_L = vec2(box_center_x - (box_width * 0.15), rect.top + (box_height * 0.75)),
            leg_lower_L = vec2(box_center_x - (box_width * 0.2), rect.top + (box_height * 0.90)),
            ankle_L = vec2(box_center_x - (box_width * 0.25), rect.bottom),
            leg_upper_R = vec2(box_center_x + (box_width * 0.15), rect.top + (box_height * 0.75)),
            leg_lower_R = vec2(box_center_x + (box_width * 0.2), rect.top + (box_height * 0.90)),
            ankle_R = vec2(box_center_x + (box_width * 0.25), rect.bottom)
        }
        
        if skeleton_mode == 2 then
            draw_skeleton(bones_2d)
        elseif skeleton_mode == 3 then
            draw_circular_skeleton(bones_2d, 1.0)
        elseif skeleton_mode == 4 then
    local scale = math.clamp(box_height / 320, 0.3, 1.6)
    draw_capsule_skeleton(bones_2d, scale)
        end
    end
end

local hitlog_health_cache = {}

engine.register_on_engine_tick(function()
    local now = winapi.get_tickcount64()
    local elapsed = (now - DisplaySystem.state.start_time) / 1000
    local vw, vh = render.get_viewport_size()

 if not watermark_dragging then
        watermark_drag_x, watermark_drag_y = parse_pos(MenuLib.get_value("pos_watermark"))
    end

    do
        local LOG_DURATION = 2.0
        local LOG_FADE = 0.48
        local SLIDE_IN = 36
        local SCALE_IN = 0.98
        local CORNER_RADIUS = 14
        local OUTLINE_THICKNESS = 1.5
        local ICON_SIZE = 32
        local ICON_PAD = 18
        local TITLE_FONT = DisplaySystem.fonts.welcome
        local TEXT_FONT = DisplaySystem.fonts.main
        local pad_x, pad_y = 22, 18
        local timer_bar_height = 5
        local timer_bar_radius = 3
        local vw, vh = render.get_viewport_size()
        local y = vh - 56

        for i = #config_logs, 1, -1 do
            local log = config_logs[i]
            local elapsed_log = (now - log.time) / 1000
            local alpha, slide, scale
            if elapsed_log < LOG_FADE then
                local p = elapsed_log / LOG_FADE
                local ease = 1 - (1-p)^5
                alpha = math.floor(log.color[4] * ease)
                slide = SLIDE_IN * (1-ease)
                scale = SCALE_IN + (1-SCALE_IN)*ease + 0.01*math.sin(p*6.2832)
            elseif elapsed_log > LOG_DURATION then
                local p = math.min((elapsed_log - LOG_DURATION) / LOG_FADE, 1)
                alpha = math.floor(log.color[4] * (1-p)^2)
                slide = 0
                scale = 1
                if p >= 1 then
                    table.remove(config_logs, i)
                    goto continue_configlog
                end
            else
                alpha, slide, scale = log.color[4], 0, 1
            end

            local title = "SaikaidoSense"
            local message = log.text

            local tw_title, th_title = render.measure_text(TITLE_FONT, title)
            local tw_msg, th_msg = render.measure_text(TEXT_FONT, message)

            local content_w = math.max(tw_title, tw_msg)
            local bw = ICON_PAD + ICON_SIZE + pad_x + content_w + pad_x
            local bh = pad_y + th_title + 4 + th_msg + pad_y + timer_bar_height + 8

            local ICON_FONT = DisplaySystem.fonts.icon
            local bx = vw - bw * scale - 36 + slide
            local by = y - bh * scale

            render.draw_rectangle(bx + 6, by + 6, bw * scale, bh * scale, 0, 0, 0, alpha * 0.18, CORNER_RADIUS + 2, true)
            render.draw_rectangle(bx, by, bw * scale, bh * scale, 18, 18, 22, alpha, CORNER_RADIUS, true)
            render.draw_rectangle(bx, by, bw * scale, bh * scale, 60, 70, 90, alpha * 0.22, CORNER_RADIUS, false)
            render.draw_rectangle(bx + ICON_PAD, by + pad_y, ICON_SIZE, ICON_SIZE, 40, 120, 255, alpha, ICON_SIZE/2, true)
            render.draw_text(ICON_FONT, "S", bx + ICON_PAD + 6, by + pad_y - 2, 255, 255, 255, alpha, 1, 0, 0, 0, alpha * 0.22)
            render.draw_text(TITLE_FONT, title, bx + ICON_PAD + ICON_SIZE + pad_x, by + pad_y, 255, 255, 255, alpha, 1, 0, 0, 0, alpha * 0.22)
            render.draw_text(TEXT_FONT, message, bx + ICON_PAD + ICON_SIZE + pad_x, by + pad_y + th_title + 4, 200, 200, 200, alpha, 1, 0, 0, 0, alpha * 0.18)

            if elapsed_log < LOG_DURATION then
                local timer_p = math.max(0, 1 - (elapsed_log / LOG_DURATION))
                local bar_w = (bw * scale - pad_x * 2) * timer_p
                local bar_x = bx + pad_x
                local bar_y = by + bh * scale - timer_bar_height - 8
                render.draw_rectangle(bar_x, bar_y, bar_w, timer_bar_height, 40, 120, 255, math.floor(alpha * 0.85), timer_bar_radius, true)
            end

            y = by - configlog_box_spacing - bh * (scale - 1) * 0.5
            ::continue_configlog::
        end
    end

    local watermark_active = MenuLib.get_value("watermark_enabled")
    local watermark_visible = DisplaySystem.state._watermark_visible
    local watermark_fading_out = DisplaySystem.state._watermark_fading_out

    if watermark_active then
        if not watermark_visible then
            DisplaySystem.state._watermark_start_time = now
            DisplaySystem.state._watermark_visible = true
            DisplaySystem.state._watermark_fading_out = false
        end
    else
        if watermark_visible and not watermark_fading_out then
            DisplaySystem.state._watermark_fade_start_time = now
            DisplaySystem.state._watermark_fading_out = true
        end
    end

    local crosshair_active = MenuLib.get_value("crosshair_enabled")
    local crosshair_visible = DisplaySystem.state._crosshair_visible
    local crosshair_fading_out = DisplaySystem.state._crosshair_fading_out

    if crosshair_active then
        if not crosshair_visible then
            DisplaySystem.state._crosshair_start_time = now
            DisplaySystem.state._crosshair_visible = true
            DisplaySystem.state._crosshair_fading_out = false
        end
    else
        if crosshair_visible and not crosshair_fading_out then
            DisplaySystem.state._crosshair_fade_start_time = now
            DisplaySystem.state._crosshair_fading_out = true
        end
    end

    local des_active = MenuLib.get_value("design_mode")
    local des_visible = DisplaySystem.state._design_mode_visible
    local des_fading_out = DisplaySystem.state._design_mode_fading_out

    if des_active then
        if not des_visible then
            DisplaySystem.state._design_mode_start_time = now
            DisplaySystem.state._design_mode_visible = true
            DisplaySystem.state._design_mode_fading_out = false
        end
    else
        if des_visible and not des_fading_out then
            DisplaySystem.state._design_mode_fade_start_time = now
            DisplaySystem.state._design_mode_fading_out = true
        end
    end

    DisplaySystem.config.crosshair.enabled = crosshair_active
    local cr_r, cr_g, cr_b = table.unpack(MenuLib.get_value("crosshair_color"))
    DisplaySystem.config.crosshair.color = {cr_r, cr_g, cr_b}
    DisplaySystem.config.crosshair.thickness = MenuLib.get_value("crosshair_thickness")
    DisplaySystem.config.crosshair.gap = MenuLib.get_value("crosshair_gap")
    DisplaySystem.config.watermark_enabled = watermark_active
    local positions = {
        "Top Left", "Top Center", "Top Right",
        "Bottom Left", "Bottom Center", "Bottom Right"
    }
    DisplaySystem.config.watermark_position = positions[posIdx] or "Top Left"
    local bg_r, bg_g, bg_b = table.unpack(MenuLib.get_value("watermark_bg_color"))
    DisplaySystem.config.bg_color = {bg_r, bg_g, bg_b}
    local bo_r, bo_g, bo_b = table.unpack(MenuLib.get_value("watermark_outline_color"))
    DisplaySystem.config.border_color = {bo_r, bo_g, bo_b}
    local tx_r, tx_g, tx_b = table.unpack(MenuLib.get_value("watermark_text_color"))
    DisplaySystem.config.text_color = {tx_r, tx_g, tx_b}
    local ht_bg_r, ht_bg_g, ht_bg_b = table.unpack(MenuLib.get_value("hitlog_bg_color"))
    local ht_ot_r, ht_ot_g, ht_ot_b = table.unpack(MenuLib.get_value("hitlog_outline_color"))
    local ht_txt_r, ht_txt_g, ht_txt_b = table.unpack(MenuLib.get_value("hitlog_text_color"))
    DisplaySystem.state.fps_value = render.get_fps()

    if DisplaySystem.state.phase == "welcome" and elapsed > DisplaySystem.config.welcome_duration then
        DisplaySystem.state.phase = "fade_out"
        DisplaySystem.state.fade_out_start = now
    elseif DisplaySystem.state.phase == "fade_out" then
        local p = (now - DisplaySystem.state.fade_out_start) / (DisplaySystem.config.fade_duration * 1000)
        if p > 1 then DisplaySystem.state.phase = "main" end
    end


if not watermark_dragging then
    watermark_drag_x, watermark_drag_y = parse_pos(MenuLib.get_value("pos_watermark"))
end
    
    -- if ui_state and ui_state.wtpos and not watermark_dragging then
    --     local val = ui_state.wtpos:get()
    --     local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
    --     if x and y then
    --         watermark_drag_x = tonumber(x)
    --         watermark_drag_y = tonumber(y)
    --     end
    -- end


    

 local now = winapi.get_tickcount64()
    local elapsed = (now - DisplaySystem.state.start_time) / 1000
    local vw, vh = render.get_viewport_size()
    local cx, cy = vw / 2, vh / 2

    if elapsed < DisplaySystem.config.welcome_duration then
        local progress = elapsed / DisplaySystem.config.welcome_duration
        
        local function ease_out_cubic(t) return 1 - (1 - t)^3 end
        local function ease_in_out_sine(t) return -(math.cos(math.pi * t) - 1) / 2 end

        local alpha = 0
        if progress < 0.2 then
            alpha = math.map(progress, 0, 0.2, 0, 255) 
        elseif progress > 0.8 then
            alpha = math.map(progress, 0.8, 1.0, 255, 0) 
        else
            alpha = 255 
        end
        alpha = math.floor(alpha)

        local bg_alpha = math.floor(alpha * 0.6)
        render.draw_rectangle(0, 0, vw, vh, 10, 10, 12, bg_alpha, 0, true)

        local slide_up = (1 - ease_out_cubic(progress)) * 40 
        local title_y = cy - 20 + slide_up
        
        local title_text = "SHOOK"
        local tw, th = render.measure_text(DisplaySystem.fonts.welcome, title_text)
        render.draw_text(DisplaySystem.fonts.welcome, title_text, cx - tw/2 + 2, title_y + 2, 0, 0, 0, alpha, 0, 0, 0, 0, 0)
        

        render.draw_text(DisplaySystem.fonts.welcome, title_text, cx - tw/2, title_y, 130, 100, 255, alpha, 0, 0, 0, 0, 0)

        if progress > 0.15 then
            local sub_alpha = alpha
            if progress < 0.3 then sub_alpha = math.map(progress, 0.15, 0.3, 0, 255) end
            if progress > 0.8 then sub_alpha = alpha end
            
            local sub_text = "welcome back, " .. DisplaySystem.config.username
            local sw, sh = render.measure_text(DisplaySystem.fonts.main, sub_text)
            render.draw_text(DisplaySystem.fonts.main, sub_text, cx - sw/2, title_y + th + 5, 200, 200, 200, sub_alpha, 0, 0, 0, 0, 0)
        end

        local line_width_max = 200
        local line_prog = ease_in_out_sine(math.min(progress * 2, 1)) 
        if progress > 0.8 then line_prog = math.map(progress, 0.8, 1.0, 1, 0) end 
        
        local current_width = line_width_max * line_prog
        local line_x = cx - (current_width / 2)
        local line_y = title_y + th + 25
        
        render.draw_rectangle(line_x, line_y, current_width, 2, 130, 100, 255, alpha, 0, true, 1)

    elseif elapsed > DisplaySystem.config.welcome_duration then
         DisplaySystem.state.phase = "main"
    end
    
    if elapsed < DisplaySystem.config.welcome_duration then

    end


if watermark_visible then
        local anim_progress, alpha
        if DisplaySystem.state._watermark_fading_out then
            local fade_elapsed = (now - DisplaySystem.state._watermark_fade_start_time) / 1000
            anim_progress = math.max(0, 1 - fade_elapsed / WATERMARK_FADE_TIME)
            alpha = math.floor(255 * anim_progress)
            if anim_progress <= 0 then
                DisplaySystem.state._watermark_visible = false
                DisplaySystem.state._watermark_fading_out = false
            end
        else
            local appear_elapsed = (now - DisplaySystem.state._watermark_start_time) / 1000
            anim_progress = math.min(appear_elapsed / WATERMARK_APPEAR_TIME, 1)
            alpha = math.floor(255 * anim_progress)
        end
        local mx, my = input.get_mouse_position()
        if watermark_dragging then
            watermark_drag_x = mx - watermark_drag_offset_x
            watermark_drag_y = my - watermark_drag_offset_y
            update_watermark_textfields()
        end
        if alpha > 0 then
            local bx, by = watermark_drag_x, watermark_drag_y
            local rounding = 6
            local accent = Menu.colors.accent 
            local bg = Menu.colors.bg_dark
            local dim = Menu.colors.text_dim
            

            local f_bold = Menu.fonts.group 
            local f_norm = Menu.fonts.main  
            

            local txt_title = "SHOOK"
            local txt_fps   = string.format("FPS: %d", math.floor(DisplaySystem.state.fps_value))
            local txt_user  = DisplaySystem.config.username or "User"
            local txt_ping  = "Ping: 0ms" 

            local pad_x, pad_y = 12, 7
            local w_title = render.measure_text(f_bold, txt_title)
            local w_div   = 16 
            local w_user  = render.measure_text(f_norm, txt_user)
            local w_fps   = render.measure_text(f_norm, txt_fps)
            
            local bw = pad_x + w_title + w_div + w_user + w_div + w_fps + pad_x
            local bh = 30
            
            render.draw_rectangle(bx, by, bw, bh, bg[1], bg[2], bg[3], math.floor(alpha * 0.95), 0, true, rounding)
            
            render.draw_rectangle(bx + 2, by + 2, bw, bh, 0, 0, 0, math.floor(alpha * 0.3), 0, true, rounding + 2)

            local bar_h = 2
            local grad_colors = {
                {accent[1], accent[2], accent[3], alpha},
                {accent[1], accent[2], accent[3], math.floor(alpha * 0.3)}
            }
            render.draw_gradient_rectangle(bx, by, bw, bar_h, grad_colors, rounding)

            render.draw_rectangle(bx, by, bw, bh, 60, 60, 65, math.floor(alpha * 0.4), 1, false, rounding)
            
            local cursor_x = bx + pad_x
            local text_y = by + (bh / 2) - 6 

            render.draw_text(f_bold, txt_title, cursor_x, text_y, accent[1], accent[2], accent[3], alpha, 0, 0, 0, 0, 0)
            cursor_x = cursor_x + w_title

            local function draw_sep(cx, cy, a)
                local sx = math.floor(cx + (w_div / 2))
                render.draw_line(sx, cy - 5, sx, cy + 6, 70, 70, 80, a, 1)
            end

            draw_sep(cursor_x, text_y + 6, alpha)
            cursor_x = cursor_x + w_div
            render.draw_text(f_norm, txt_user, cursor_x, text_y, 220, 220, 220, alpha, 0, 0, 0, 0, 0)
            cursor_x = cursor_x + w_user

            draw_sep(cursor_x, text_y + 6, alpha)
            cursor_x = cursor_x + w_div
            render.draw_text(f_norm, txt_fps, cursor_x, text_y, dim[1], dim[2], dim[3], alpha, 0, 0, 0, 0, 0)
        end
    end

    if ui_state and ui_state.wtpos and not watermark_dragging then
        local val = ui_state.wtpos:get()
        local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
        if x and y then
            watermark_drag_x = tonumber(x)
            watermark_drag_y = tonumber(y)
        end
    end

    if des_visible then
        local anim_progress, alpha, slide_offset

        if des_fading_out then
            local fade_elapsed = (now - DisplaySystem.state._design_mode_fade_start_time) / 1000
            anim_progress = math.max(0, 1 - fade_elapsed / DESIGN_MODE_FADE_TIME)
            alpha = math.floor(255 * anim_progress)
            slide_offset = (1 - anim_progress) * 25

            if anim_progress <= 0 then
                DisplaySystem.state._design_mode_visible = false
                DisplaySystem.state._design_mode_fading_out = false
            end
        else
            local appear_elapsed = (now - DisplaySystem.state._design_mode_start_time) / 1000
            anim_progress = math.min(appear_elapsed / DESIGN_MODE_APPEAR_TIME, 1)
            alpha = math.floor(255 * anim_progress)
            slide_offset = (1 - anim_progress) * 25
        end

       if alpha > 0 then
    local dim_slider_value = MenuLib.get_value("design_dim")
    local target_dim_opacity = math.floor((dim_slider_value / 10) * 255)
    local animated_dim_opacity = math.floor(target_dim_opacity * anim_progress)
    render.draw_rectangle(0, 0, vw, vh, 0, 0, 0, animated_dim_opacity, 0, true)

    local ht_bg_r, ht_bg_g, ht_bg_b, _ = table.unpack(MenuLib.get_value("hitlog_bg_color"))
    local ht_ot_r, ht_ot_g, ht_ot_b, _ = table.unpack(MenuLib.get_value("hitlog_outline_color"))
    local ht_txt_r, ht_txt_g, ht_txt_b, _ = table.unpack(MenuLib.get_value("hitlog_text_color"))

    do
        local hitlogs = { {text="Hit an enemy for -86 damage", alpha=alpha} }
        local y = vh - 40
        local hitlog_box_spacing = 18
        for _, msg in ipairs(hitlogs) do
            local tw, th = render.measure_text(DisplaySystem.fonts.main, msg.text)
            local pad = hitlog_box_pad
            local bw, bh = hitlog_box_width, hitlog_box_height
            local bx = (vw - bw) / 2
            local by = (y - bh + pad) + slide_offset
            
            render.draw_rectangle(bx, by, bw, bh, ht_bg_r, ht_bg_g, ht_bg_b, msg.alpha, 0, true)
            render.draw_rectangle(bx, by, bw, bh, ht_ot_r, ht_ot_g, ht_ot_b, msg.alpha, 2, false)
            local text_x = bx + (bw - tw) / 2
            local text_y = by + (bh - th) / 2
            render.draw_text(DisplaySystem.fonts.main, msg.text, text_x, text_y, ht_txt_r, ht_txt_g, ht_txt_b, msg.alpha, 1, 0, 0, 0, msg.alpha*0.5)
            y = by - hitlog_box_spacing
        end
    end

-- do
--     local info = ("SaikaidoSense | %s | FPS: %.0f"):format(DisplaySystem.config.username, DisplaySystem.state.fps_value)
--     local tw, th = render.measure_text(DisplaySystem.fonts.main, info)
--     local pad = DisplaySystem.config.box_padding
--     local bw, bh = tw + pad * 2, th + pad * 2
    
--     local mx, my = input.get_mouse_position()

--     if not watermark_dragging then
--         local over = mx >= watermark_drag_x and mx <= watermark_drag_x + bw and my >= watermark_drag_y and my <= watermark_drag_y + bh
--         if over and input.is_key_pressed(1) then
--             watermark_dragging = true

--             watermark_drag_offset_x = mx - watermark_drag_x
--             watermark_drag_offset_y = my - watermark_drag_y
--         end
--     end

--     if watermark_dragging then

--         if not input.is_key_down(1) then
--             watermark_dragging = false
--         else
--             local new_x = mx - watermark_drag_offset_x
--             local new_y = my - watermark_drag_offset_y

--             MenuLib.set_value("pos_watermark", string.format("%d,%d", new_x, new_y))

--             watermark_drag_x = new_x
--             watermark_drag_y = new_y
--         end
--     end

--     local bx, by = watermark_drag_x, watermark_drag_y
--     render.draw_rectangle(bx, by, bw, bh, DisplaySystem.config.bg_color[1], DisplaySystem.config.bg_color[2], DisplaySystem.config.bg_color[3], alpha, 0, true)
--     render.draw_rectangle(bx, by, bw, bh, DisplaySystem.config.border_color[1], DisplaySystem.config.border_color[2], DisplaySystem.config.border_color[3], alpha, 2, false)
--     render.draw_text(DisplaySystem.fonts.main, info, bx + pad, by + pad,
--         DisplaySystem.config.text_color[1], DisplaySystem.config.text_color[2], DisplaySystem.config.text_color[3], alpha, 1, 0, 0, 0, alpha * 0.5)
-- end

            do
                local cx, cy = vw*.5, vh*.5
                local c = DisplaySystem.config.crosshair
                local off = c.gap * .5
                render.draw_line(cx - c.size, cy, cx - off, cy, c.color[1], c.color[2], c.color[3], alpha, c.thickness)
                render.draw_line(cx + off, cy, cx + c.size, cy, c.color[1], c.color[2], c.color[3], alpha, c.thickness)
                render.draw_line(cx, cy - c.size, cx, cy - off, c.color[1], c.color[2], c.color[3], alpha, c.thickness)
                render.draw_line(cx, cy + off, cx, cy + c.size, c.color[1], c.color[2], c.color[3], alpha, c.thickness)
            end
            local function update_bombpanel_textfields()
                if ui_state and ui_state.bombpanelpos then
                    ui_state.bombpanelpos:set(string.format("%d,%d", bombpanel_drag_x, bombpanel_drag_y))
                end
            end
           do
    local bw, bh = 320, 110
    local rounding = 12
    local bar_pad_x = 24
    local bar_h = 10
    local bar_round = 5
    local title_bar_h = 28
    local panel_base_bg_alpha = 180
    
    local bg_alpha = math.map(alpha, 0, 255, 0, panel_base_bg_alpha)

    if not bombpanel_dragging then
        bombpanel_drag_x, bombpanel_drag_y = parse_pos(MenuLib.get_value("pos_bomb"))
    end

    local bx, by = bombpanel_drag_x, bombpanel_drag_y

    local mx, my = input.get_mouse_position()
    local over = mx >= bx and mx <= bx + bw and my >= by and my <= by + bh
    
    if over and input.is_key_pressed(1) and not bombpanel_dragging then
        bombpanel_dragging = true
        bombpanel_drag_offset_x = mx - bx
        bombpanel_drag_offset_y = my - by
    end

    if bombpanel_dragging then
        if not input.is_key_down(1) then
            bombpanel_dragging = false
        else
            local new_x = mx - bombpanel_drag_offset_x
            local new_y = my - bombpanel_drag_offset_y
            MenuLib.set_value("pos_bomb", string.format("%d,%d", new_x, new_y))
        end
    end
    
    render.draw_rectangle(bx, by, bw, bh, 32, 34, 37, bg_alpha, 0, true, rounding)
    render.draw_rectangle(bx, by, bw, title_bar_h, 24, 25, 28, bg_alpha, 0, true, rounding)
    local light_y = by + title_bar_h / 2
    render.draw_circle(bx + 23, light_y, 6, 255, 95, 88, 255, 0, true)
    render.draw_circle(bx + 43, light_y, 6, 254, 189, 47, 255, 0, true)
    render.draw_circle(bx + 63, light_y, 6, 42, 202, 65, 255, 0, true)
    
    local title = "Bomb Info"
    local title_w = render.measure_text(DisplaySystem.fonts.main, title)
    render.draw_text(
        DisplaySystem.fonts.main,
        title,
        bx + (bw - title_w) / 2,
        by + 2,
        240, 240, 240, alpha,
        1, 0, 0, 0, alpha * 0.8
    )
    
    local line1 = "Bomb Planted on Site A"
    local line2 = "Time left: 40.0s"
    local content_y = by + title_bar_h + 8
    render.draw_text(DisplaySystem.fonts.main, line1, bx + 15, content_y, 220, 220, 220, alpha, 1, 0, 0, 0, alpha * 0.8)
    render.draw_text(DisplaySystem.fonts.main, line2, bx + 15, content_y + 30, 180, 180, 180, alpha, 1, 0, 0, 0, alpha * 0.8)
    
    local bar_y = content_y + 54
    local bar_x = bx + bar_pad_x
    local bar_w = bw - bar_pad_x * 2
    render.draw_rectangle(bar_x, bar_y, bar_w, bar_h, 60, 60, 60, alpha * 0.7, 0, true, bar_round)
    render.draw_rectangle(bar_x, bar_y, bar_w, bar_h, 0, 200, 80, alpha, 0, true, bar_round)
end
do
    local box_width = 220
    local header_height = 28
    local entry_height = 22
    local box_radius = 8

    local bg_r, bg_g, bg_b, bg_a = table.unpack(MenuLib.get_value("speclist_bg_color"))
    local border_r, border_g, border_b, border_a = table.unpack(MenuLib.get_value("speclist_outline_color"))
    local text_r, text_g, text_b, text_a = table.unpack(MenuLib.get_value("speclist_text_color"))
    local header_r, header_g, header_b, header_a = table.unpack(MenuLib.get_value("speclist_header_color"))
    
    local preview_names = {"Spectator1", "Spectator2"}
    local count = #preview_names
    local box_height = header_height + (count > 0 and (count * entry_height) or entry_height)
    
    if not speclist_dragging then
        speclist_drag_x, speclist_drag_y = parse_pos(MenuLib.get_value("pos_speclist"))
    end

    local x, y = speclist_drag_x, speclist_drag_y + slide_offset

    local mx, my = input.get_mouse_position()
    local over = mx >= speclist_drag_x and mx <= speclist_drag_x + box_width and my >= speclist_drag_y and my <= speclist_drag_y + box_height

    if over and input.is_key_pressed(1) and not speclist_dragging then
        speclist_dragging = true
        speclist_drag_offset_x = mx - speclist_drag_x
        speclist_drag_offset_y = my - speclist_drag_y
    end

    if speclist_dragging then
        if not input.is_key_down(1) then
            speclist_dragging = false
        else
            local new_x = mx - speclist_drag_offset_x
            local new_y = my - speclist_drag_offset_y
            MenuLib.set_value("pos_speclist", string.format("%d,%d", new_x, new_y))
        end
    end
    
    render.draw_rectangle(x + 3, y + 3, box_width, box_height, 0, 0, 0, math.floor(80 * (alpha / 255)), box_radius, true)
    render.draw_rectangle(x, y, box_width, box_height, bg_r, bg_g, bg_b, math.floor(bg_a * (alpha/255)), box_radius, true)
    render.draw_rectangle(x, y, box_width, box_height, border_r, border_g, border_b, math.floor(border_a * (alpha / 255)), box_radius, false)
    render.draw_rectangle(x, y, box_width, header_height, header_r, header_g, header_b, math.floor(header_a * (alpha/255)), box_radius, true)
    render.draw_text(DisplaySystem.fonts.main, "Spectators", x + 16, y + 6, 255, 255, 255, alpha, 1, 0, 0, 0, 180)

    for i, name in ipairs(preview_names) do
        render.draw_text(DisplaySystem.fonts.main, name, x + 16, y + header_height + (i - 1) * entry_height + 4, text_r, text_g, text_b, alpha, 1, 0, 0, 0, 120)
    end
end
            
            -- do
            --     local box_height = 280
            --     local box_width = box_height / 2.0
            --     local box_center_x = vw / 2
            --     local box_top_y = vh / 2 - box_height / 2
            --     local rect = {
            --         top = box_top_y, bottom = box_top_y + box_height,
            --         left = box_center_x - (box_width / 2), right = box_center_x + (box_width / 2)
            --     }
                
            --     if ui_state.espbox_checkbox:get() then
            --         local r, g, b, a = ui_state.boxcolor_picker:get()
            --         render.draw_rectangle(rect.left, rect.top, box_width, box_height, r, g, b, a, 1, false)
            --         render.draw_rectangle(rect.left - 1, rect.top - 1, box_width + 2, box_height + 2, 0, 0, 0, a, 1, false)
            --         render.draw_rectangle(rect.left + 1, rect.top + 1, box_width - 2, box_height - 2, 0, 0, 0, a, 1, false)
            --     end

            --     if ui_state.espname_checkbox:get() then
            --         local r, g, b, a = ui_state.espnamecolor_picker:get()
            --         local name = "Placeholder"
            --         local tw, th = render.measure_text(g.font, name)
            --         render.draw_text(g.font, name, box_center_x - tw / 2, rect.top - 16, r, g, b, a, 1, 0,0,0,a)
            --     end

            --     if ui_state.moneyesp_checkbox:get() then
            --         local r, g, b, a = ui_state.moneycolor_picker:get()
            --         local money = "$1337"
            --         render.draw_text(g.small_font, money, rect.right + 4, rect.top, r, g, b, a, 1, 0,0,0,a)
            --     end

            --     local health = 85
            --     local health_bar_h = math.clamp(box_height * (health / 100.0), 0, box_height)
            --     render.draw_rectangle(rect.left - 6, rect.top - 1, 4, box_height + 2, 0,0,0,180, 0, true)
            --     render.draw_rectangle(rect.left - 5, rect.top + (box_height - health_bar_h), 2, health_bar_h, 50, 200, 50, 255, 0, true)
                
            --     local armor = 75
            --     local armor_bar_h = math.clamp(box_height * (armor / 100.0), 0, box_height)
            --     render.draw_rectangle(rect.left - 11, rect.top - 1, 4, box_height + 2, 0,0,0,180, 0, true)
            --     render.draw_rectangle(rect.left - 10, rect.top + (box_height - armor_bar_h), 2, armor_bar_h, 100, 150, 255, 255, 0, true)
            
            --     if ui_state.skeleton_checkbox:get() then
            --         local r, g, b, a = ui_state.skeletoncolor_picker:get()
            --         local bones_2d = {
            --             head = vec2(box_center_x, rect.top + (box_height * 0.05)),
            --             neck_0 = vec2(box_center_x, rect.top + (box_height * 0.15)),
            --             spine_1 = vec2(box_center_x, rect.top + (box_height * 0.30)),
            --             spine_2 = vec2(box_center_x, rect.top + (box_height * 0.45)),
            --             pelvis = vec2(box_center_x, rect.top + (box_height * 0.55)),
            --             arm_upper_L = vec2(rect.left + (box_width * 0.2), rect.top + (box_height * 0.32)),
            --             arm_lower_L = vec2(rect.left + (box_width * 0.1), rect.top + (box_height * 0.50)),
            --             hand_L = vec2(rect.left + (box_width * 0.05), rect.top + (box_height * 0.65)),
            --             arm_upper_R = vec2(rect.right - (box_width * 0.2), rect.top + (box_height * 0.32)),
            --             arm_lower_R = vec2(rect.right - (box_width * 0.1), rect.top + (box_height * 0.50)),
            --             hand_R = vec2(rect.right - (box_width * 0.05), rect.top + (box_height * 0.65)),
            --             leg_upper_L = vec2(box_center_x - (box_width * 0.15), rect.top + (box_height * 0.75)),
            --             leg_lower_L = vec2(box_center_x - (box_width * 0.2), rect.top + (box_height * 0.90)),
            --             ankle_L = vec2(box_center_x - (box_width * 0.25), rect.bottom),
            --             leg_upper_R = vec2(box_center_x + (box_width * 0.15), rect.top + (box_height * 0.75)),
            --             leg_lower_R = vec2(box_center_x + (box_width * 0.2), rect.top + (box_height * 0.90)),
            --             ankle_R = vec2(box_center_x + (box_width * 0.25), rect.bottom)
            --         }
            --         draw_skeleton(bones_2d)
            --     end
            -- end
        end
            draw_esp_placeholder()
        return
    end







    
     
    local use_log = MenuLib.get_value("misc_hitlog")
    local use_sound = MenuLib.get_value("misc_hitsound")
    
    if not (use_log or use_sound) then return end

    local client_dll = proc.find_module("client.dll")
    if not client_dll or client_dll == 0 or not proc.is_attached() then return end

    local localPawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if localPawn == 0 then return end
    
    local localTeam = proc.read_int32(localPawn + offsets.m_iTeamNum)
    

    local current_shots = proc.read_int32(localPawn + offsets.m_iShotsFired)
    
    if hitlog_cache.last_local_shots == -1 then
        hitlog_cache.last_local_shots = current_shots
    end

    if current_shots > hitlog_cache.last_local_shots then
        hitlog_cache.last_shot_time = winapi.get_tickcount64()
        hitlog_cache.last_local_shots = current_shots
    end

    if current_shots < hitlog_cache.last_local_shots then 
        hitlog_cache.last_local_shots = current_shots 
    end


    local is_my_damage_window = (winapi.get_tickcount64() - hitlog_cache.last_shot_time) < 300

      local entityList = proc.read_int64(client_dll + offsets.dwEntityList)
    if entityList == 0 then return end

    for i = 1, 64 do
        local list_entry = proc.read_int64(entityList + 8 * ((i & 0x7FFF) >> 9) + 16)
        if list_entry == 0 then goto skip_ent end
        
        local controller = proc.read_int64(list_entry + 112 * (i & 0x1FF))
        if controller == 0 then goto skip_ent end
        
        local pawn_handle = proc.read_int32(controller + offsets.m_hPlayerPawn)
        if pawn_handle == 0 then goto skip_ent end
        
        local list_entry2 = proc.read_int64(entityList + 0x8 * ((pawn_handle & 0x7FFF) >> 9) + 16)
        if list_entry2 == 0 then goto skip_ent end

        local pawn = proc.read_int64(list_entry2 + 112 * (pawn_handle & 0x1FF))
        if pawn == 0 or pawn == localPawn then goto skip_ent end

        local health = proc.read_int32(pawn + offsets.m_iHealth)
        local team = proc.read_int32(pawn + offsets.m_iTeamNum)

        if team ~= localTeam then
            local old_health = hitlog_cache.health[i]
            
            if not old_health then
                hitlog_cache.health[i] = health
            else

                if health < old_health and health >= 0 then
                    local dmg = old_health - health
                    
    
                    if dmg > 0 and dmg <= 150 and is_my_damage_window then
                        local name_ptr = proc.read_int64(controller + offsets.m_sSanitizedPlayerName)
                        local name = proc.read_string(name_ptr, 32)
                        if not name or name == "" then name = "Enemy" end
                        
                        local txt = string.format("Hit %s for %d (%d remaining)", name, dmg, health)
                        if health <= 0 then 
                            txt = string.format("Eliminated %s", name) 
                        end
                        
                        if use_log then add_hitlog_message(txt) end
                        if use_sound then winapi.play_sound("sounds/hitsound.mp3") end
                    end
                end

                hitlog_cache.health[i] = health
            end
        else
            hitlog_cache.health[i] = nil
        end

        ::skip_ent::
    end
    
    local now = winapi.get_tickcount64()
    local vw, vh = render.get_viewport_size()
    local y_start = vh - 120 
    
    for i = #hitlog_messages, 1, -1 do
        local msg = hitlog_messages[i]
        local elapsed = (now - msg.time) / 1000.0
        
        if elapsed > HITLOG_SHOW_TIME then
            msg.alpha = math.floor(255 * (1 - (elapsed - HITLOG_SHOW_TIME)/0.5))
            if msg.alpha <= 0 then table.remove(hitlog_messages, i); goto draw_skip end
        else
            msg.alpha = 255
        end
        
        local font = DisplaySystem.fonts.main
        local tw, th = render.measure_text(font, msg.text)
        local bw, bh = tw + 20, th + 12
        local bx = (vw - bw) / 2
        local by = y_start
    
        local slide_factor = 1.0
        if elapsed < 0.2 then slide_factor = elapsed / 0.2 end
        by = by + (1.0 - slide_factor) * 20

        local c_bg = {18, 18, 18, math.floor(msg.alpha * 0.9)}
        local c_txt = {220, 220, 220, msg.alpha}
        local c_acc = {130, 100, 255, msg.alpha} 

        render.draw_rectangle(bx, by, bw, bh, c_bg[1], c_bg[2], c_bg[3], c_bg[4], 0, true, 4)
        render.draw_rectangle(bx, by+2, 2, bh-4, c_acc[1], c_acc[2], c_acc[3], c_acc[4], 0, true, 2)
        render.draw_text(font, msg.text, bx + 12, by + 6, c_txt[1], c_txt[2], c_txt[3], c_txt[4], 0,0,0,0,0)
        
        y_start = y_start - (bh + 5)
        ::draw_skip::
    end
end)
local font = render.create_font("Tahoma", 13, 400)


local spec_font = render.create_font("Verdana", 12, 500)
local spectators = {}

if not speclist_anim then
    speclist_anim = { visible = false, anim_progress = 0, alpha = 0, slide_offset = 0, last_tick = 0 }
end



local panel_pos_x = 25
local panel_pos_y = 200
local panel_width = 320
local panel_height = 110
local panel_rounding = 8
local panel_base_bg_alpha = 200
local animation_speed = 0.1

local font_main_name = "Verdana"
local font_main_size = 22
local font_main_weight = 700
local font_sub_name = "Verdana"
local font_sub_size = 14
local font_sub_weight = 700

local bomb_panel_font_main = render.create_font(font_main_name, font_main_size, font_main_weight)
local bomb_panel_font_sub = render.create_font(font_sub_name, font_sub_size, font_sub_weight)

local bomb_panel_alpha, bomb_panel_target_alpha = 0, 0
local bomb_panel_timer_bar_width, bomb_panel_target_bar_width = 0, 0
local bomb_panel_timer_bar_color = { r = 0, g = 255, b = 0 }
local bomb_panel_line1_text, bomb_panel_line2_text = "", ""
local bomb_panel_line1_color = { r = 255, g = 255, b = 255 }
local bomb_panel_bomb_plant_time_ms = nil
local bomb_panel_has_logged_site_id = false
local bomb_panel_client_dll = nil






-- ui_state.indicator_features_select:set(1, true) -- Rage Aimbot
-- ui_state.indicator_features_select:set(2, true) -- Legit Aimbot
-- ui_state.indicator_features_select:set(5, true) -- ESP
-- ui_state.indicator_features_select:set(6, true) -- Player Glow


local VK_NAMES = {
    [0x01]="Mouse1",[0x02]="Mouse2",[0x04]="Mouse3",[0x05]="Mouse4",[0x06]="Mouse5",[0x08]="Bsp",[0x09]="Tab",
    [0x0D]="Enter",[0x10]="Shift",[0x11]="Ctrl",[0x12]="Alt",[0x14]="Caps",[0x1B]="Esc",[0x20]="Space",
    [0x21]="PgUp",[0x22]="PgDn",[0x23]="End",[0x24]="Home",[0x25]="Left",[0x26]="Up",[0x27]="Right",[0x28]="Down",
    [0x2D]="Ins",[0x2E]="Del",[0x30]="0",[0x31]="1",[0x32]="2",[0x33]="3",[0x34]="4",[0x35]="5",[0x36]="6",
    [0x37]="7",[0x38]="8",[0x39]="9",[0x41]="A",[0x42]="B",[0x43]="C",[0x44]="D",[0x45]="E",[0x46]="F",[0x47]="G",
    [0x48]="H",[0x49]="I",[0x4A]="J",[0x4B]="K",[0x4C]="L",[0x4D]="M",[0x4E]="N",[0x4F]="O",[0x50]="P",[0x51]="Q",
    [0x52]="R",[0x53]="S",[0x54]="T",[0x55]="U",[0x56]="V",[0x57]="W",[0x58]="X",[0x59]="Y",[0x5A]="Z",
    [0x60]="Num0",[0x61]="Num1",[0x62]="Num2",[0x63]="Num3",[0x64]="Num4",[0x65]="Num5",[0x66]="Num6",
    [0x67]="Num7",[0x68]="Num8",[0x69]="Num9",[0x6A]="*",[0x6B]="+",[0x6D]="-",[0x6E]=".",[0x6F]="Num/",
    [0x70]="F1",[0x71]="F2",[0x72]="F3",[0x73]="F4",[0x74]="F5",[0x75]="F6",[0x76]="F7",[0x77]="F8",[0x78]="F9",
    [0x79]="F10",[0x7A]="F11",[0x7B]="F12",[0xBA]=";",[0xBB]="=",[0xBC]=",",[0xBD]="-",[0xBE]=".",[0xBF]="/",[0xC0]="`",
    [0xDB]="[",[0xDC]="\\",[0xDD]="]",[0xDE]="'"
}
local function get_key_name(vk) if vk and vk > 0 then return VK_NAMES[vk] or string.format("K:%d", vk) end return "NONE" end

-- local features_to_track = {
--     [1]={el=ui_state.rage_enabled,key_el=ui_state.aim_key,value_el=ui_state.fov_slider,prefix="FOV: ",suffix="",format="%.1f"},
--     [2]={el=ui_state.aim_enabled_checkbox,key_el=ui_state.aim_keybind,value_el=ui_state.aim_fov_slider,prefix="FOV: ",suffix=""},
--     [3]={el=ui_state.aa_enabled,key_el=ui_state.aim_keybind,value_el=ui_state.jitter_range,prefix="jitter: ",suffix="",format="%.1f"},
--     [4]={el=ui_state.trigger_bot_enable,key_el=ui_state.trigger_bot_key,value_el=ui_state.trigger_hitchance,prefix="HC: ",suffix="%"},
--     [5]={el=ui_state.enabledrcs,key_el=ui_state.aim_keybind,value_el=ui_state.start_bullet,prefix="Bullet: ",suffix=""},
-- }
-- for i=1, #features_to_track do features_to_track[i].anim = 0 end

local indicator_config = {
    x=15,y=520,padding=8,font=render.create_font("Verdana",13,700),
    bg={20,20,20,230},text={220,220,220,255},key_text={180,180,180,255},anim_speed=0.1
}




function handle_anti_flash()
    if not MenuLib.get_value("misc_anti_flash") then return end
    local client_dll = proc.find_module("client.dll")
    if not client_dll or client_dll == 0 then return end
    local local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if not local_pawn or local_pawn == 0 then return end
    local flash_address = local_pawn + offsets.m_flFlashDuration
    local current_flash_duration = proc.read_float(flash_address)
    if current_flash_duration > 0 then
        proc.write_float(flash_address, 0.0)
    end
end


local function handle_smoke_modulator()
    if not MenuLib.get_value("world_smoke_mod") then return end
    
    local client_dll = proc.find_module("client.dll")
    if not client_dll or client_dll == 0 then return end
    
    local r, g, b, _ = table.unpack(MenuLib.get_value("world_smoke_color"))
    local color_vec = vec3(r / 255.0, g / 255.0, b / 255.0)

    for i = 64, 2048 do
        local entity_list = proc.read_int64(client_dll + offsets.dwEntityList)
        if entity_list == 0 then return end

        local list_entry = proc.read_int64(entity_list + 0x8 * ((i >> 9) & 0x7F) + 0x10)
        if not list_entry or list_entry == 0 then goto continue_smoke_loop end
        
        local entity = proc.read_int64(list_entry + 112 * (i & 0x1FF))
        if not entity or entity == 0 then goto continue_smoke_loop end
        
        local item_info_ptr = proc.read_int64(entity + 0x10)
        if not item_info_ptr or item_info_ptr == 0 then goto continue_smoke_loop end

        local item_type_ptr = proc.read_int64(item_info_ptr + 0x20)
        if not item_type_ptr or item_type_ptr == 0 then goto continue_smoke_loop end
        
        local designer_name = proc.read_string(item_type_ptr, 128)

        if designer_name and designer_name == "smokegrenade_projectile" then
            local color_addr = entity + offsets.vSmokeColor
            vec3.write_float(color_addr, color_vec)
        end
        
        ::continue_smoke_loop::
    end
end



function handle_nightmode()
    local is_enabled = MenuLib.get_value("world_nightmode")



    local client_dll = proc.find_module("client.dll")
    if not client_dll or client_dll == 0 then return end
    
    local local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if not local_pawn or local_pawn == 0 then
        if nightmode_state.has_saved_original_values then
            nightmode_state.has_saved_original_values = false
        end
        return
    end

    local camera_services = proc.read_int64(local_pawn + offsets.m_pCameraServices)
    if not camera_services or camera_services == 0 then return end
    
    local post_processing_handle = proc.read_int32(camera_services + offsets.m_hPostProcessing)
    if not post_processing_handle or post_processing_handle == -1 then return end

    local entity_list = proc.read_int64(client_dll + offsets.dwEntityList)
    local list_entry = proc.read_int64(entity_list + 0x8 * ((post_processing_handle & 0x7FFF) >> 9) + 0x10)
    if not list_entry or list_entry == 0 then return end
    local post_processing_entity = proc.read_int64(list_entry + 112 * (post_processing_handle & 0x1FF))
    if not post_processing_entity or post_processing_entity == 0 then return end

    local min_exposure_addr = post_processing_entity + offsets.m_flMinExposure
    local max_exposure_addr = post_processing_entity + offsets.m_flMaxExposure


    if is_enabled then
        if not nightmode_state.has_saved_original_values then
            nightmode_state.original_min_exposure = proc.read_float(min_exposure_addr)
            nightmode_state.original_max_exposure = proc.read_float(max_exposure_addr)
            nightmode_state.has_saved_original_values = true
        end
        
        local slider_val =  MenuLib.get_value("world_nightmode_intensity")
        local new_exposure_value = 0.1 - ((slider_val - 1.0) * 0.0010)
        
        if proc.read_float(min_exposure_addr) ~= new_exposure_value then
            proc.write_float(min_exposure_addr, new_exposure_value)
            proc.write_float(max_exposure_addr, new_exposure_value)
        end
    
    else
        if nightmode_state.has_saved_original_values then
            proc.write_float(min_exposure_addr, nightmode_state.original_min_exposure)
            proc.write_float(max_exposure_addr, nightmode_state.original_max_exposure)
            
            nightmode_state.has_saved_original_values = false
        end
    end
end


function trigger_schedule_action(ms, callback)
    table.insert(trigger_pending_actions, {
        execute_at = winapi.get_tickcount64() + ms,
        callback = callback
    })
end

function trigger_process_pending_actions()
    if #trigger_pending_actions == 0 then return end
    
    local current_time_ms = winapi.get_tickcount64()
    
    for i = #trigger_pending_actions, 1, -1 do
        local action = trigger_pending_actions[i]
        if current_time_ms >= action.execute_at then
            action.callback()
            table.remove(trigger_pending_actions, i)
        end
    end
end



function trigger_get_current_hitchance()
    local client_dll = proc.find_module("client.dll")
    if not client_dll then return 0 end
    
    local local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if local_pawn == 0 then return 0 end
    
    local velocity_vec = vec3.read_float(local_pawn + offsets.m_vecVelocity)
    local current_speed = velocity_vec:length_2d()

    local hitchance = math.map(current_speed, 0, 250.0, 100, 0)
    
    return math.clamp(hitchance, 0, 100)
end






local indicator_config = {
    x = 15,
    y = 520,
    padding = 8,
    font = render.create_font("Verdana", 13, 700),
    anim_speed = 0.15
}

local INDICATOR_MAPPINGS = {
    [1] = { name = "Rage Aimbot", enabled_id = "rage_enabled", keybind_id = "rage_key", anim = 0 },
    [2] = { 
        name = "Legit Aimbot", 
        per_weapon = true, 
        enabled_id = "_legit_enabled", 
        keybind_id = "_legit_key", 
        prediction_enabled_id = "_legit_prediction_enabled", 
        prediction_keybind_id = "_legit_prediction_key", 
        anim = 0 
    },
    [3] = { name = "Anti-Aim", enabled_id = "aa_enabled", keybind_id = "aa_disable_key", inverted_key = true, anim = 0 },
    [4] = { name = "Triggerbot", per_weapon = true, enabled_id = "_trigger_enabled", keybind_id = "_trigger_key", anim = 0 },
    [5] = { name = "RCS", per_weapon = true, enabled_id = "_rcs_enabled", anim = 0 }
}

local function draw_feature_indicators()
    local colors = Menu.colors
    local font = Menu.fonts.main
    if not font then return end

    local features_to_draw = {}
    local indicator_selection = MenuLib.get_value("indicator_features")

    if not indicator_selection then return end

    local weapon_category = nil
    local client_dll = proc.find_module("client.dll")
    if client_dll then
        local local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
        if local_pawn and local_pawn ~= 0 then
            local weapon_id = get_active_weapon_id(local_pawn)
            weapon_category = get_weapon_category(weapon_id)
        end
    end

    for i = 1, #INDICATOR_OPTIONS do
        if indicator_selection[i] then
            local mapping = INDICATOR_MAPPINGS[i]
            if mapping then
                local is_active = false
                local display_value = "[READY]"
                local enabled_id, keybind_id = mapping.enabled_id, mapping.keybind_id
                
                if mapping.per_weapon then
                    if weapon_category then
                        enabled_id = weapon_category .. mapping.enabled_id
                        if keybind_id then keybind_id = weapon_category .. keybind_id end
                    else
                        goto continue_loop 
                    end
                end

                if MenuLib.get_value(enabled_id) then
                    is_active = keybind_id and is_keybind_active(keybind_id) or true
                    if mapping.inverted_key then is_active = not is_active end

                    if is_active then
                        display_value = "[ACTIVE]"
             
                        if mapping.name == "Legit Aimbot" and weapon_category then
                            local pred_enabled_id = weapon_category .. mapping.prediction_enabled_id
                            local pred_key_id = weapon_category .. mapping.prediction_keybind_id
                            if MenuLib.get_value(pred_enabled_id) and is_keybind_active(pred_key_id) then
                                display_value = "[PREDICTING]"
                            end
                        end
                    end
                else
                    is_active = false
                end
                
                local target = is_active and 1.0 or 0.0
                mapping.anim = math.lerp(mapping.anim or 0, target, 0.15)
                if mapping.anim < 0.01 then mapping.anim = 0 end

                if mapping.anim > 0 then
                    table.insert(features_to_draw, { name = mapping.name, value = display_value, anim = mapping.anim })
                end
            end
        end
        ::continue_loop::
    end

    if #features_to_draw == 0 then return end

    local max_name, max_val, text_h = 0, 0, 0
    for _, f in ipairs(features_to_draw) do
        local nw, h = render.measure_text(font, f.name); text_h = h
        local vw = render.measure_text(font, f.value)
        if nw > max_name then max_name = nw end
        if vw > max_val then max_val = vw end
    end
    
    local pad = 8
    local box_w = max_name + max_val + (pad * 3)
    local box_h = (#features_to_draw * text_h) + ((#features_to_draw + 1) * pad)
    
    local bg = colors.bg_dark
    render.draw_rectangle(indicator_config.x + 2, indicator_config.y + 2, box_w, box_h, 0, 0, 0, 100, 0, true, 5)
    render.draw_rectangle(indicator_config.x, indicator_config.y, box_w, box_h, bg[1], bg[2], bg[3], 230, 0, true, 4)
    
    local r, g, b, a = table.unpack(MenuLib.get_value("indicator_accent_color"))
    render.draw_gradient_rectangle(indicator_config.x, indicator_config.y, box_w, 2.5, {{r, g, b, a}, {r * 0.7, g * 0.7, b * 0.7, a}}, 4)

    local current_y = indicator_config.y + pad
    for _, f in ipairs(features_to_draw) do
        local p = f.anim
        local alpha = math.floor(255 * p)
        local slide = -20 * (1 - p)
        local main_text_color = { colors.text_main[1], colors.text_main[2], colors.text_main[3], alpha }
        local dim_text_color = { colors.text_dim[1], colors.text_dim[2], colors.text_dim[3], alpha }

        render.draw_text(font, f.name, indicator_config.x + pad + slide, current_y, main_text_color[1], main_text_color[2], main_text_color[3], main_text_color[4], 1, 0, 0, 0, alpha * 0.5)
        local val_w = render.measure_text(font, f.value)
        render.draw_text(font, f.value, indicator_config.x + box_w - pad - val_w, current_y, dim_text_color[1], dim_text_color[2], dim_text_color[3], dim_text_color[4], 1, 0, 0, 0, alpha * 0.5)
        
        current_y = current_y + text_h + pad
    end
end








MainGameLoop = function()
    local is_design_mode = MenuLib.get_value("design_mode")

    if not proc.is_attached() or proc.did_exit() then return end

    local client_dll = proc.find_module("client.dll")
    if client_dll == 0 then return end

    local view_matrix = {}
    for i = 0, 15 do table.insert(view_matrix, proc.read_float(client_dll + offsets.dwViewMatrix + (i * 4))) end

    local local_player_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if local_player_pawn == 0 then return end

    local local_team = proc.read_int32(local_player_pawn + offsets.m_iTeamNum)
    local local_origin_node = proc.read_int64(local_player_pawn + offsets.m_pGameSceneNode)
    if local_origin_node == 0 then return end
    local local_origin = vec3.read_float(local_origin_node + offsets.m_vecAbsOrigin)

    local entity_list = proc.read_int64(client_dll + offsets.dwEntityList)
    if entity_list == 0 then return end

    for i = 0, 63 do
        local list_entry_head = proc.read_int64(entity_list + 0x10)
        
        if list_entry_head ~= 0 then
            local entity_controller = proc.read_int64(list_entry_head + 112 * (i & 0x1FF))
            if entity_controller ~= 0 then
                local pawn_handle = proc.read_int32(entity_controller + offsets.m_hPlayerPawn)
                if pawn_handle ~= -1 and pawn_handle ~= 0 then
                    local list_entry2 = proc.read_int64(entity_list + 0x8 * ((pawn_handle & 0x7FFF) >> 9) + 16)
                    if list_entry2 ~= 0 then
                        local entity_pawn = proc.read_int64(list_entry2 + 112 * (pawn_handle & 0x1FF))
                        
                        if entity_pawn ~= 0 and entity_pawn ~= local_player_pawn and proc.read_int32(entity_pawn + offsets.m_lifeState) == 256 then
                            local health = proc.read_int32(entity_pawn + offsets.m_iHealth)
                            local team = proc.read_int32(entity_pawn + offsets.m_iTeamNum)
                            
                            local is_enemy = (team ~= local_team)
                            local should_draw = false
                            local prefix = ""

                            if is_enemy and MenuLib.get_value("esp_enabled") then
                                should_draw = true; prefix = "esp" 
                            elseif not is_enemy and MenuLib.get_value("team_esp_enabled") then
                                should_draw = true; prefix = "team" 
                            end

                            if should_draw and health > 0 and health <= 100 then
                                local game_scene_node = proc.read_int64(entity_pawn + offsets.m_pGameSceneNode)
                                local bone_array_ptr = proc.read_int64(game_scene_node + offsets.m_modelState + offsets.m_boneArray)
                                
                                if bone_array_ptr ~= 0 then
                                    local head_pos_3d = vec3.read_float(bone_array_ptr + BONE_MAP.head * 32)
                                    local origin_3d = vec3.read_float(game_scene_node + offsets.m_vecAbsOrigin)
                                    
                                    local head_top_3d = vec3(head_pos_3d.x, head_pos_3d.y, head_pos_3d.z + 8.0)
                                    local screen_pos_head = world_to_screen(view_matrix, head_top_3d)
                                    local screen_pos_feet = world_to_screen(view_matrix, origin_3d)

                                    if screen_pos_head and screen_pos_feet then
                                        local box_height = math.abs(screen_pos_head.y - screen_pos_feet.y)
                                        local box_width = box_height / 2.0
                                        
                                        local money = -1
                                        if MenuLib.get_value(prefix .. "_money") then
                                            local money_services = proc.read_int64(entity_controller + offsets.m_pInGameMoneyServices)
                                            if money_services ~= 0 then money = proc.read_int32(money_services + offsets.m_iAccount) end
                                        end

                                        local entity_to_render = {
                                            health = health, team = team,
                                            is_scoped = proc.read_int8(entity_pawn + offsets.m_bIsScoped) > 0,     
                                            is_flashed = proc.read_float(entity_pawn + offsets.m_flFlashDuration) > 0, 
                                            distance = get_distance_manual(origin_3d, local_origin),
                                            money = money, 
                                            armor = proc.read_int32(entity_pawn + offsets.m_ArmorValue),
                                            weapon = get_active_weapon_name(entity_pawn),
                                            rect = {
                                                top = screen_pos_head.y, bottom = screen_pos_feet.y,
                                                left = screen_pos_head.x - (box_width / 2), right = screen_pos_head.x + (box_width / 2)
                                            },
                                            name = proc.read_string(proc.read_int64(entity_controller + offsets.m_sSanitizedPlayerName), 64)
                                        }
                                        
                                        render_entity_info(entity_to_render, prefix)
                                        
                                        local skeleton_mode = MenuLib.get_value(prefix .. "_skeleton_mode")
                                        if skeleton_mode > 1 then
                                             local bones_2d = {}
                                             for name, index in pairs(BONE_MAP) do
                                                 local bone_3d = vec3.read_float(bone_array_ptr + index * 32)
                                                 if bone_3d then 
                                                     bones_2d[name] = world_to_screen(view_matrix, bone_3d) 
                                                 end
                                             end
                                             
                                             local skel_color = MenuLib.get_value(prefix .. "_skeleton_color") or {255, 255, 255, 255}

                                             if skeleton_mode == 2 then 
                                                 draw_skeleton(bones_2d, skel_color)
                                             elseif skeleton_mode == 3 then
                                                draw_circular_skeleton(bones_2d, 1.0, skel_color)
                                             elseif skeleton_mode == 4 then
                                                local scale = math.max(0.1, box_height / 300.0)
                                                draw_capsule_skeleton(bones_2d, scale, skel_color)
                                             end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


function get_distance_manual(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    local dz = pos1.z - pos2.z
    return math.sqrt(dx*dx + dy*dy + dz*dz)
end

function world_to_screen(view_matrix, position)
    local screen_width, screen_height = render.get_viewport_size()
    local w = view_matrix[13] * position.x + view_matrix[14] * position.y + view_matrix[15] * position.z + view_matrix[16]
    
    if w < 0.01 then return nil end

    local screen_x = view_matrix[1] * position.x + view_matrix[2] * position.y + view_matrix[3] * position.z + view_matrix[4]
    local screen_y = view_matrix[5] * position.x + view_matrix[6] * position.y + view_matrix[7] * position.z + view_matrix[8]

    local inv_w = 1.0 / w
    screen_x = screen_x * inv_w
    screen_y = screen_y * inv_w

    local x = screen_width / 2.0 + (0.5 * screen_x * screen_width + 0.5)
    local y = screen_height / 2.0 - (0.5 * screen_y * screen_height + 0.5)

    if x < 0 or x > screen_width or y < 0 or y > screen_height then
        return nil
    end

    return vec2(x, y)
end

function get_active_weapon_name(entity_pawn)
    if not entity_pawn or entity_pawn == 0 then return "UNKNOWN" end

    local clipping_weapon_ptr = proc.read_int64(entity_pawn + offsets.m_pClippingWeapon)
    if not clipping_weapon_ptr or clipping_weapon_ptr == 0 then return "UNKNOWN" end

    local item_definition_ptr = proc.read_int64(clipping_weapon_ptr + 0x10)
    if not item_definition_ptr or item_definition_ptr == 0 then return "UNKNOWN" end
    
    local designer_name_ptr = proc.read_int64(item_definition_ptr + 0x20)
    if not designer_name_ptr or designer_name_ptr == 0 then return "UNKNOWN" end

    local weapon_name_raw = proc.read_string(designer_name_ptr, 40)
    if not weapon_name_raw or weapon_name_raw == "" then return "UNKNOWN" end
    
    local _, _, weapon_name = string.find(weapon_name_raw, "weapon_(.+)")
    if weapon_name then
        return string.upper(weapon_name) 
    end
    
    return "WEAPON"
end



function draw_skeleton(bones_2d, color)
    local r, g, b, a = table.unpack(color)
    local function connect(b1, b2)
        if bones_2d[b1] and bones_2d[b2] then
             render.draw_line(bones_2d[b1].x, bones_2d[b1].y, bones_2d[b2].x, bones_2d[b2].y, r, g, b, a, 1)
        end
    end

    connect("head", "neck_0"); connect("neck_0", "spine_1"); connect("spine_1", "spine_2"); connect("spine_2", "pelvis")
    connect("spine_1", "arm_upper_L"); connect("arm_upper_L", "arm_lower_L"); connect("arm_lower_L", "hand_L")
    connect("spine_1", "arm_upper_R"); connect("arm_upper_R", "arm_lower_R"); connect("arm_lower_R", "hand_R")
    connect("pelvis", "leg_upper_L"); connect("leg_upper_L", "leg_lower_L"); connect("leg_lower_L", "ankle_L")
    connect("pelvis", "leg_upper_R"); connect("leg_upper_R", "leg_lower_R"); connect("leg_lower_R", "ankle_R")
end

function draw_circular_skeleton(bones_2d, scale, color)
    local r, g, b, a = table.unpack(color)

    local BONE_CONNECTIONS = {
        {"head", "neck_0"}, {"neck_0", "spine_1"}, {"spine_1", "pelvis"},
        {"spine_1", "arm_upper_L"}, {"arm_upper_L", "arm_lower_L"}, {"arm_lower_L", "hand_L"},
        {"spine_1", "arm_upper_R"}, {"arm_upper_R", "arm_lower_R"}, {"arm_lower_R", "hand_R"},
        {"pelvis", "leg_upper_L"}, {"leg_upper_L", "leg_lower_L"}, {"leg_lower_L", "ankle_L"},
        {"pelvis", "leg_upper_R"}, {"leg_upper_R", "leg_lower_R"}, {"leg_lower_R", "ankle_R"}
    }
    
    local function draw_bone_tube(p1, p2, radius)
        local delta = p2 - p1
        local dist = delta:length()
        local step = radius * 0.75

        if dist < step then
            render.draw_circle(p1.x, p1.y, radius, r, g, b, a, 1.5, false)
            render.draw_circle(p2.x, p2.y, radius, r, g, b, a, 1.5, false)
            return
        end

        for i = 0, dist, step do
            local point = p1 + (delta * (i / dist))
            render.draw_circle(point.x, point.y, radius, r, g, b, a, 1.5, false)
        end
    end

    for _, pair in ipairs(BONE_CONNECTIONS) do
        local pos1 = bones_2d[pair[1]]
        local pos2 = bones_2d[pair[2]]
        if pos1 and pos2 then
            draw_bone_tube(pos1, pos2, math.max(1.5, 3 * scale))
        end
    end
end


local function draw_filled_box(rect, r, g, b, a)
    local w = rect.right - rect.left
    local h = rect.bottom - rect.top
    local top_col = {r, g, b, 0}
    local bot_col = {r, g, b, math.floor(a * 0.4)} 
    render.draw_gradient_rectangle(rect.left, rect.top, w, h, {top_col, bot_col}, 0)
    render.draw_rectangle(rect.left, rect.top, w, h, r, g, b, a, 1, false)
    render.draw_rectangle(rect.left-1, rect.top-1, w+2, h+2, 0, 0, 0, math.floor(a*0.6), 1, false)
    render.draw_rectangle(rect.left+1, rect.top+1, w-2, h-2, 0, 0, 0, math.floor(a*0.6), 1, false)
end



function draw_outlined_text(font, text, x, y, r, g, b, a, alignment)
    if not text or text == "" then return end
    
    local text_w, text_h = render.measure_text(font, text)
    local draw_x = x
    local draw_y = y

    if alignment == "center" then
        draw_x = x - (text_w / 2)
    elseif alignment == "right" then
        draw_x = x - text_w
    end
    
    render.draw_text(font, text, draw_x, draw_y, r, g, b, a, 1, 0, 0, 0, a)
end




function draw_filled_box(rect, r, g, b, a, is_corner)
    local fill_alpha_top = math.floor(a * 0.05) 
    local fill_alpha_bot = math.floor(a * 0.15) 

    local top_color = { r, g, b, fill_alpha_top }
    local bottom_color = { r, g, b, fill_alpha_bot }

    local colors_table = { top_color, bottom_color }

    render.draw_gradient_rectangle(rect.left, rect.top, (rect.right - rect.left), (rect.bottom - rect.top), colors_table, 0)

    local outline_thickness = 1
    render.draw_rectangle(rect.left, rect.top, (rect.right - rect.left), (rect.bottom - rect.top), r, g, b, a, outline_thickness, false)
end


local function draw_shook_gradient_bar(x, y, w, h, value, max, color_c, is_vertical)
    local pct = math.clamp(value / max, 0, 1)
    local a = color_c[4]
    
    render.draw_rectangle(x, y, w, h, 20, 22, 27, 180, 0, true) 
    render.draw_rectangle(x, y, w, h, 0, 0, 0, a, 1, false)

    if is_vertical then
        local fill_h = math.floor(h * pct)
        local bar_y = y + (h - fill_h)
        
        if fill_h > 0 then
            local r, g, b = color_c[1], color_c[2], color_c[3]
            local dr, dg, db = math.floor(r*0.6), math.floor(g*0.6), math.floor(b*0.6)
            
            render.draw_gradient_rectangle(x + 1, bar_y + 1, w - 2, fill_h - 2, 
                {{r, g, b, a}, {dr, dg, db, a}}, 0) 
        end
    else
        local fill_w = math.floor(w * pct)
        
        if fill_w > 0 then
            local r, g, b = color_c[1], color_c[2], color_c[3]
            local dr, dg, db = math.floor(r*0.7), math.floor(g*0.7), math.floor(b*0.7)

            local grad_col = {{r,g,b,a}, {dr,dg,db,a}}
            render.draw_gradient_rectangle(x + 1, y + 1, fill_w - 2, h - 2, grad_col, 0)
        end
    end
end


local function draw_capsule_line(p1, p2, radius, r, g, b, a)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local len = math.sqrt(dx*dx + dy*dy)

    if len <= 0 then return end

    local nx = -dy / len
    local ny = dx / len

    local ox = nx * radius
    local oy = ny * radius

    local points = {
        p1.x + ox, p1.y + oy,
        p2.x + ox, p2.y + oy,
        p2.x - ox, p2.y - oy,
        p1.x - ox, p1.y - oy
    }

    render.draw_polygon(points, r, g, b, a, 0, true)
    render.draw_circle(p1.x, p1.y, radius, r, g, b, a, 0, true)
    render.draw_circle(p2.x, p2.y, radius, r, g, b, a, 0, true)
end

function draw_capsule_skeleton(bones_2d, scale, color)
    local r, g, b, a = table.unpack(color)
    local outline_a = math.max(0, a - 40)

    local base = 4.5 * scale 

    local connections = {
        -- Torso (Thickest)
        {"pelvis",  "spine_1", 3.8}, 
        {"spine_1", "spine_2", 4.0}, 
        {"spine_2", "spine_3", 4.2}, 
        {"spine_3", "neck",    3.0}, 
        {"neck",    "head",    3.2}, 

        -- Shoulders
        {"spine_3", "clavicle_L", 2.5},
        {"spine_3", "clavicle_R", 2.5},

        -- Arms (Tapered)
        {"clavicle_L", "arm_upper_L", 2.2}, 
        {"arm_upper_L", "arm_lower_L", 1.9}, 
        {"arm_lower_L", "hand_L",      1.6},

        {"clavicle_R", "arm_upper_R", 2.2}, 
        {"arm_upper_R", "arm_lower_R", 1.9}, 
        {"arm_lower_R", "hand_R",      1.6},

        -- Legs (Athletic)
        {"pelvis", "leg_upper_L", 3.2}, 
        {"leg_upper_L", "leg_lower_L", 2.6}, 
        {"leg_lower_L", "ankle_L", 2.0},

        {"pelvis", "leg_upper_R", 3.2}, 
        {"leg_upper_R", "leg_lower_R", 2.6}, 
        {"leg_lower_R", "ankle_R", 2.0},
    }

    local outline_thickness = math.max(1.0, 1.5 * scale) 
    
    for _, bond in ipairs(connections) do
        local p1 = bones_2d[bond[1]]
        local p2 = bones_2d[bond[2]]
        if p1 and p2 then
            local radius = (base * bond[3]) + outline_thickness
            draw_capsule_line(p1, p2, radius, 0, 0, 0, math.floor(outline_a * 0.8))
        end
    end
    
    for _, bond in ipairs(connections) do
        local p1 = bones_2d[bond[1]]
        local p2 = bones_2d[bond[2]]
        if p1 and p2 then
            local radius = base * bond[3]
            draw_capsule_line(p1, p2, radius, r, g, b, a)
        end
    end

    -- Feet
    local function draw_foot_pass(ank, is_outline)
        local p = bones_2d[ank]
        if p then
            local foot_len = 5 * (scale / 0.8) 
            local foot_end = { x = p.x, y = p.y + foot_len }
            
            local radius = (1.8 * base)
            if is_outline then radius = radius + outline_thickness end
            
            local fr, fg, fb, fa = r, g, b, a
            if is_outline then fr,fg,fb,fa = 0,0,0, math.floor(outline_a * 0.8) end
            
            draw_capsule_line(p, foot_end, radius, fr, fg, fb, fa)
        end
    end

    draw_foot_pass("ankle_L", true); draw_foot_pass("ankle_R", true)
    draw_foot_pass("ankle_L", false); draw_foot_pass("ankle_R", false)
end



function render_entity_info(entity, prefix)
    local rect = entity.rect
    local box_height = rect.bottom - rect.top
    if box_height <= 2 then return end

    local box_width = rect.right - rect.left
    local box_center_x = rect.left + (box_width / 2)
    
    local bar_width = 4
    local bar_padding = 5
    local font_main = esp_fonts.name or Menu.fonts.group
    local font_small = esp_fonts.weapon or Menu.fonts.main
    local default_col = {255, 255, 255, 255}

    local is_box = MenuLib.get_value(prefix .. "_box")
    local is_name = MenuLib.get_value(prefix .. "_name")
    local is_health = MenuLib.get_value(prefix .. "_health")
    local is_armor = MenuLib.get_value(prefix .. "_armor")
    local is_weapon = MenuLib.get_value(prefix .. "_player_weapon") or MenuLib.get_value(prefix .. "_weapon")
    local is_money = MenuLib.get_value(prefix .. "_money")
    local is_dist = MenuLib.get_value(prefix .. "_distance")

    if is_box then
        local col = MenuLib.get_value(prefix .. "_box_color") or default_col
        local r, g, b, a = math.floor(col[1]), math.floor(col[2]), math.floor(col[3]), math.floor(col[4])
        local box_type = MenuLib.get_value(prefix .. "_box_type")

        if box_type == 2 then 
            local len = math.max(8, box_height * 0.18)
            local function corner_line(x1, y1, x2, y2)
                render.draw_line(x1, y1, x2, y2, 0, 0, 0, a, 3) 
                render.draw_line(x1, y1, x2, y2, r, g, b, a, 1) 
            end
            
            corner_line(rect.left, rect.top, rect.left + len, rect.top)
            corner_line(rect.left, rect.top, rect.left, rect.top + len)
            corner_line(rect.right, rect.top, rect.right - len, rect.top)
            corner_line(rect.right, rect.top, rect.right, rect.top + len)
            corner_line(rect.left, rect.bottom, rect.left + len, rect.bottom)
            corner_line(rect.left, rect.bottom, rect.left, rect.bottom - len)
            corner_line(rect.right, rect.bottom, rect.right - len, rect.bottom)
            corner_line(rect.right, rect.bottom, rect.right, rect.bottom - len)

        elseif box_type == 3 then
            draw_filled_box(rect, r, g, b, a)
        else
            render.draw_rectangle(rect.left - 1, rect.top - 1, box_width + 2, box_height + 2, 0, 0, 0, a * 0.8, 1, false)
            render.draw_rectangle(rect.left + 1, rect.top + 1, box_width - 2, box_height - 2, 0, 0, 0, a * 0.8, 1, false)
            render.draw_rectangle(rect.left, rect.top, box_width, box_height, r, g, b, a, 1, false)
        end
    end

    if is_name and entity.name then
        local col = MenuLib.get_value(prefix .. "_name_color") or default_col
        local tw, th = render.measure_text(font_main, entity.name)
        
        render.draw_text(font_main, entity.name, box_center_x - tw/2 + 1, rect.top - th - 3, 0, 0, 0, col[4], 0,0,0,0,0)
        render.draw_text(font_main, entity.name, box_center_x - tw/2, rect.top - th - 4, col[1], col[2], col[3], col[4], 0,0,0,0,0)
    end

    local cur_left_offset = rect.left - bar_padding - bar_width
    
    if is_health ~= false then
        local hp_color = {
            math.floor((100 - entity.health) * 2.55),
            math.floor(entity.health * 2.55),      
            0, 255
        }
        
        draw_shook_gradient_bar(cur_left_offset, rect.top, bar_width, box_height, entity.health, 100, hp_color, true)
        
        if entity.health < 98 then
            local hp_str = tostring(entity.health)
            local htw, hth = render.measure_text(font_small, hp_str)
            local text_y = rect.top + (box_height * (1 - entity.health/100)) - (hth/2)
            
            if text_y < rect.top then text_y = rect.top end
            if text_y > rect.bottom - hth then text_y = rect.bottom - hth end

            render.draw_text(font_small, hp_str, cur_left_offset - htw - 2, text_y, 255, 255, 255, 255, 1, 0,0,0,150)
        end
        cur_left_offset = cur_left_offset - 6 
    end

    local cur_bot_y = rect.bottom + 4

    if is_armor and entity.armor and entity.armor > 0 then
        local armor_col = {0, 140, 255, 255} 
        local arm_height = 3
        draw_shook_gradient_bar(rect.left, cur_bot_y, box_width, arm_height, entity.armor, 100, armor_col, false)
        cur_bot_y = cur_bot_y + arm_height + 3
    end

    if is_weapon and entity.weapon then
        local w_name = entity.weapon
        if w_name ~= "UNKNOWN" and w_name ~= "" then
            local tw, th = render.measure_text(font_small, w_name)
            render.draw_text(font_small, w_name, box_center_x - tw/2, cur_bot_y, 230, 230, 230, 255, 1, 0,0,0,180)
            cur_bot_y = cur_bot_y + th
        end
    end

    if is_dist then
        local dist_str = math.floor(entity.distance) .. "m"
        local col = MenuLib.get_value(prefix .. "_distance_color") or default_col
        local tw, th = render.measure_text(font_small, dist_str)
        
        render.draw_text(font_small, dist_str, box_center_x - tw/2, cur_bot_y, col[1], col[2], col[3], col[4], 1, 0,0,0,100)
    end

    local flags_x = rect.right + bar_padding
    local flags_y = rect.top
    
    local function add_flag(text, r, g, b)
        local tw, th = render.measure_text(font_small, text)
        render.draw_text(font_small, text, flags_x, flags_y, r, g, b, 255, 1, 0,0,0,180)
        flags_y = flags_y + th
    end

    if is_money and entity.money then 
        add_flag("$" .. entity.money, 130, 235, 130) 
    end
    
    if entity.is_scoped and MenuLib.get_value(prefix .. "_scoped_flag") then 
        add_flag("ZOOM", 130, 200, 255) 
    end
    
    if entity.is_flashed and MenuLib.get_value(prefix .. "_flashed_flag") then 
        add_flag("BLIND", 255, 230, 80) 
    end
end

    local client_dll = proc.find_module("client.dll")
    if client_dll == 0 then return end
 local game = {}
    game.client_dll = client_dll
    game.view_matrix = {}
    for i = 0, 15 do table.insert(game.view_matrix, proc.read_float(client_dll + offsets.dwViewMatrix + (i * 4))) end
    
    game.local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if game.local_pawn == 0 then return end
    game.local_team = proc.read_int32(game.local_pawn + offsets.m_iTeamNum)
    game.entity_list = proc.read_int64(client_dll + offsets.dwEntityList)
    
    game.entities = {}





local radar = {
    x = 200, y = 200,
    size = 250,
    scale = 0.24,
    rotation_angle = 90,
    bg_color = {25, 25, 25, 180},
    outline_color = {150, 0, 255, 255},
    local_player_color = {255, 255, 255, 255},
    enemy_color = {255, 0, 0, 255},
    team_color = {0, 150, 255, 255},
    view_line_color = {255, 255, 0, 255},
    name_font = render.create_font("Verdana", 10, 500) -- Font for radar names
}

local g = {
    client_module = nil,
    entities = {},
    local_pos = {x=0, y=0},
    local_yaw = 0,
    is_dragging = false,
    drag_offset = {x=0, y=0}
}

local function read_vec3(address)
    return {
        x = proc.read_float(address),
        y = proc.read_float(address + 4),
        z = proc.read_float(address + 8)
    }
end

local function update_data()
    g.entities = {}

    if not g.client_module then g.client_module = proc.find_module("client.dll") end
    if not g.client_module or g.client_module == 0 then return end

    local lpawn_addr = proc.read_int64(g.client_module + offsets.dwLocalPlayerPawn)
    if not lpawn_addr or lpawn_addr == 0 then return end

    local local_team = proc.read_int32(lpawn_addr + offsets.m_iTeamNum)
    local local_pos_vec = read_vec3(lpawn_addr + offsets.m_vOldOrigin)
    g.local_pos = {x = local_pos_vec.x, y = local_pos_vec.y}
    g.local_yaw = proc.read_float(g.client_module + offsets.dwViewAngles + 4)
    
    local entity_list_addr = proc.read_int64(g.client_module + offsets.dwEntityList)
    local lpawn_ctrl_addr = proc.read_int64(g.client_module + offsets.dwLocalPlayerController)

    for i = 1, 64 do
        local entry_addr = proc.read_int64(entity_list_addr + 0x8 * (i >> 9) + 0x10)
        if entry_addr ~= 0 then
            local ctrl_addr = proc.read_int64(entry_addr + 112 * (i & 0x1FF))
            if ctrl_addr ~= 0 and ctrl_addr ~= lpawn_ctrl_addr then
                local pawn_handle = proc.read_int32(ctrl_addr + offsets.m_hPlayerPawn) & 0x7FFF
                if pawn_handle > 0 then
                    local pawn_entry_addr = proc.read_int64(entity_list_addr + 0x8 * (pawn_handle >> 9) + 0x10)
                    if pawn_entry_addr ~= 0 then
                        local pawn_addr = proc.read_int64(pawn_entry_addr + 112 * (pawn_handle & 0x1FF))
                        if pawn_addr ~= 0 and proc.read_int32(pawn_addr + offsets.m_iHealth) > 0 and proc.read_int32(pawn_addr + offsets.m_bDormant) == 0 then
                            local team = proc.read_int32(pawn_addr + offsets.m_iTeamNum)
                            local pos = read_vec3(pawn_addr + offsets.m_vOldOrigin)
                            
                            -- Read Name
                            local name_ptr = proc.read_int64(ctrl_addr + offsets.m_sSanitizedPlayerName)
                            local player_name = proc.read_string(name_ptr, 32)
                            if not player_name or player_name == "" then player_name = "Enemy" end

                            local color = (team ~= local_team) and radar.enemy_color or radar.team_color
                            
                            -- Store pawn_addr for yaw reading later
                            table.insert(g.entities, {
                                pos = {x=pos.x, y=pos.y}, 
                                pawn_address = pawn_addr,
                                color = color,
                                team = team,
                                name = player_name
                            })
                        end
                    end
                end
            end
        end
    end
end

local radar_state = {
    x = 20, y = 350,
    size = 200,
    scale = 18.0, 
    dragging = false, drag_off_x = 0, drag_off_y = 0
}

local function draw_modern_radar(game)
    if not MenuLib.get_value("misc_radar") then return end

    local x, y = radar_state.x, radar_state.y
    local size = radar_state.size
    local cx, cy = x + (size / 2), y + (size / 2)
    local r_radius = (size / 2) - 3 

    -- Drag Logic
    local mx, my = input.get_mouse_position()
    if Menu.visible then 
        local hov = mx > x and mx < x + size and my > y and my < y + size
        if hov and input.is_key_pressed(1) and not radar_state.dragging then
            radar_state.dragging = true; radar_state.drag_off_x = mx - x; radar_state.drag_off_y = my - y
        end
    end
    if radar_state.dragging then
        if not input.is_key_down(1) then radar_state.dragging = false else
            radar_state.x = mx - radar_state.drag_off_x; radar_state.y = my - radar_state.drag_off_y
            x, y = radar_state.x, radar_state.y; cx, cy = x + (size/2), y + (size/2)
        end
    end

    -- Background
    render.draw_rectangle(x, y, size, size, 22, 22, 27, 240, 0, true, 8)
    render.draw_rectangle(x, y, size, size, 70, 70, 80, 255, 1.5, false, 8)
    render.draw_line(cx, y + 5, cx, y + size - 5, 255, 255, 255, 40, 1)
    render.draw_line(x + 5, cy, x + size - 5, cy, 255, 255, 255, 40, 1)

    -- Local Data (Yaw/Pos)
    local l_yaw = g.local_yaw
    local rad_yaw = math.rad(l_yaw) 
    local l_pos = g.local_pos

    -- Draw Center (Local Player)
    render.draw_circle(cx, cy, 3, 255, 255, 255, 255, 0, true)

    -- Iterate Cached Entities (g.entities has the names now)
    for _, ent in ipairs(g.entities) do
        local dx = ent.pos.x - l_pos.x
        local dy = ent.pos.y - l_pos.y
        
        local rot_x = dx * math.sin(rad_yaw) - dy * math.cos(rad_yaw)
        local rot_y = dx * math.cos(rad_yaw) + dy * math.sin(rad_yaw)
        
        local map_x = rot_x / radar_state.scale
        local map_y = -rot_y / radar_state.scale 

        local dist = math.sqrt(map_x^2 + map_y^2)
        if dist > r_radius then
            map_x = (map_x / dist) * r_radius
            map_y = (map_y / dist) * r_radius
        end

        local draw_x = cx + map_x
        local draw_y = cy + map_y

        -- Direction Line if inside radar
        if dist <= r_radius then
            local ent_yaw = proc.read_float(ent.pawn_address + offsets.m_angEyeAngles + 4) 
            if not ent_yaw or ent_yaw == 0 then ent_yaw = 0 end
            
            local relative_yaw = math.rad(ent_yaw - l_yaw - 90) 
            local dir_len = 12
            local lx = draw_x + math.cos(relative_yaw) * dir_len
            local ly = draw_y + math.sin(relative_yaw) * dir_len
            
            render.draw_line(draw_x, draw_y, lx, ly, 255, 255, 255, 150, 1)
        end

        -- Draw Dot
        local r, g_val, b = table.unpack(ent.color)
        render.draw_circle(draw_x, draw_y, 4, r, g_val, b, 255, 0, true)
        render.draw_circle(draw_x, draw_y, 5, 0, 0, 0, 180, 1, false)

        -- Draw Name
        if ent.name then
            local tw, th = render.measure_text(radar.name_font, ent.name)
            render.draw_text(radar.name_font, ent.name, draw_x - tw/2, draw_y - 12, 255, 255, 255, 255, 0,0,0,0,0)
        end
    end
end

local function update_dynamic_scale()
    local max_dist = 1
    for _, ent in ipairs(g.entities) do
        local dist = math.sqrt((ent.pos.x - g.local_pos.x)^2 + (ent.pos.y - g.local_pos.y)^2)
        if dist > max_dist then
            max_dist = dist
        end
    end
    local new_scale = (radar.size / 2) / max_dist
    radar.scale = math.max(0.01, math.min(new_scale, 0.5))
end

local function handle_dragging()
    local mx, my = input.get_mouse_position()
    if input.is_key_pressed(1) and (mx > radar.x and mx < radar.x + radar.size and my > radar.y and my < radar.y + radar.size) then
        g.is_dragging = true
        g.drag_offset = {x = mx - radar.x, y = my - radar.y}
    end

    if g.is_dragging then
        if input.is_key_down(1) then
            radar.x = mx - g.drag_offset.x
            radar.y = my - g.drag_offset.y
        else
            g.is_dragging = false
        end
    end
end

local function on_engine_tick()
    if not MenuLib.get_value("misc_radar") then
        return
    end

    if not g.client_module then return end
   
   

end

local function on_script_load_radar()
    if not proc.is_attached() then
        engine.log("Error: Attach to cs2.exe first.", 255, 0, 0, 255)
        return
    end

    g.client_module = proc.find_module("client.dll")
    if g.client_module and g.client_module > 0 then
        engine.log("Radar Script Loaded.", 0, 255, 0, 255)
        engine.register_on_engine_tick(on_engine_tick)
    else
        engine.log("Critical Error: Could not find client.dll.", 255, 0, 0, 255)
    end
end

on_script_load_radar()

local client_base = nil

local function to_argb(r, g, b, a)
    local clamp = function(x) return math.max(0, math.min(1, x)) end
    r = math.floor(clamp(r) * 255)
    g = math.floor(clamp(g) * 255)
    b = math.floor(clamp(b) * 255)
    a = math.floor(clamp(a) * 255)

    return (a << 24) | (b << 16) | (g << 8) | r
end

function update_glow()
    if not MenuLib.get_value("esp_glow") then return end
    
    local client_base = proc.find_module("client.dll")
    if not client_base or client_base == 0 then return end
    if not proc.is_attached() or proc.did_exit() then return end

    local local_player = proc.read_int64(client_base + offsets.dwLocalPlayerPawn)
    if not local_player or local_player == 0 then return end
    
    local local_team_num = proc.read_int32(local_player + offsets.m_iTeamNum)

    local entity_list = proc.read_int64(client_base + offsets.dwEntityList)
    if not entity_list or entity_list == 0 then return end

    local ct_r, ct_g, ct_b, ct_a = table.unpack(MenuLib.get_value("esp_ct_glow_color"))
    local t_r, t_g, t_b, t_a = table.unpack(MenuLib.get_value("esp_t_glow_color"))

    local ct_color = { ct_r / 255.0, ct_g / 255.0, ct_b / 255.0, ct_a / 255.0 }
    local t_color = { t_r / 255.0, t_g / 255.0, t_b / 255.0, t_a / 255.0 }

    for i = 1, 64 do
        local list_entry = proc.read_int64(entity_list + (8 * (i & 0x7FFF) >> 9) + 16)
        if not list_entry or list_entry == 0 then goto continue_glow end

        local controller_addr = proc.read_int64(list_entry + 112 * (i & 0x1FF))
        if not controller_addr or controller_addr == 0 then goto continue_glow end

        local pawn_handle = proc.read_int32(controller_addr + offsets.m_hPlayerPawn)
        if not pawn_handle or pawn_handle == -1 or pawn_handle == 0 then goto continue_glow end
        
        local pawn_handle_masked = pawn_handle & 0x7FFF
        local list_entry2 = proc.read_int64(entity_list + 0x8 * ((pawn_handle_masked >> 9) & 0x7F) + 16)
        if not list_entry2 or list_entry2 == 0 then goto continue_glow end
        
        local pawn_addr = proc.read_int64(list_entry2 + 112 * (pawn_handle_masked & 0x1FF))
        if not pawn_addr or pawn_addr == 0 or pawn_addr == local_player then goto continue_glow end

        local life_state = proc.read_int32(pawn_addr + offsets.m_lifeState)
        if life_state ~= 256 then goto continue_glow end

        local team_num = proc.read_int32(pawn_addr + offsets.m_iTeamNum)
        
        local color = nil
        if team_num == 2 then
            color = t_color
        elseif team_num == 3 then 
            color = ct_color
        end

        if color then
            local glow_addr = pawn_addr + offsets.m_Glow
            local color_packed = to_argb(color[1], color[2], color[3], color[4])
            
            proc.write_int32(glow_addr + offsets.m_glowColorOverride, color_packed)
            proc.write_int32(glow_addr + offsets.m_bGlowing, 1)
            proc.write_int32(glow_addr + offsets.m_iGlowType, 3) 
        end

        ::continue_glow::
    end
end






local WEAPONS_MAP = {
    ["weapon_ak47"] = "AK-47", ["weapon_m4a1"] = "M4A4", ["weapon_awp"] = "AWP", ["weapon_deagle"] = "Desert Eagle",
    ["weapon_elite"] = "Dual Berettas", ["weapon_famas"] = "Famas", ["weapon_fiveseven"] = "Five-SeveN",
    ["weapon_g3sg1"] = "G3SG1", ["weapon_galilar"] = "Galil AR", ["weapon_glock"] = "Glock-18",
    ["weapon_m4a1_silencer"] = "M4A1-S", ["weapon_mac10"] = "MAC-10", ["weapon_mag7"] = "MAG-7",
    ["weapon_mp5sd"] = "MP5-SD", ["weapon_mp7"] = "MP7", ["weapon_mp9"] = "MP9", ["weapon_negev"] = "Negev",
    ["weapon_nova"] = "Nova", ["weapon_p90"] = "P90", ["weapon_p250"] = "P250",
    ["weapon_hkp2000"] = "P2000", ["weapon_sawedoff"] = "Sawed-Off", ["weapon_scar20"] = "SCAR-20",
    ["weapon_sg556"] = "SG 553", ["weapon_ssg08"] = "SSG 08", ["weapon_taser"] = "Zeus x27",
    ["weapon_tec9"] = "Tec-9", ["weapon_ump45"] = "UMP-45", ["weapon_usp_silencer"] = "USP-S",
    ["weapon_xm1014"] = "XM1014", ["weapon_aug"] = "AUG", ["weapon_bizon"] = "PP-Bizon",
    ["weapon_cz75a"] = "CZ75-Auto", ["weapon_m249"] = "M249", ["weapon_revolver"] = "R8 Revolver"
}
local PROJECTILES_MAP = {
    ["smokegrenade_projectile"] = "Smoke", ["flashbang_projectile"] = "Flashbang",
    ["hegrenade_projectile"] = "HE Grenade", ["molotov_projectile"] = "Molotov Fire",
    ["incendiarygrenade_projectile"] = "Incendiary Fire", ["decoy_projectile"] = "Decoy"
}

local esp_font = render.create_font("verdana.ttf", 12)

local function world_to_screen(view_matrix, position_3d)
    local screen_w = view_matrix[13] * position_3d.x + view_matrix[14] * position_3d.y + view_matrix[15] * position_3d.z + view_matrix[16]
    if screen_w < 0.1 then return nil end
    local screen_x = view_matrix[1] * position_3d.x + view_matrix[2] * position_3d.y + view_matrix[3] * position_3d.z + view_matrix[4]
    local screen_y = view_matrix[5] * position_3d.x + view_matrix[6] * position_3d.y + view_matrix[7] * position_3d.z + view_matrix[8]
    local inv_w = 1.0 / screen_w
    local sx, sy = screen_x * inv_w, screen_y * inv_w
    local screen_width, screen_height = render.get_viewport_size()
    local x, y = (screen_width / 2.0) + (sx * screen_width) / 2.0, (screen_height / 2.0) - (sy * screen_height) / 2.0
    return vec2(x, y)
end

local function draw_text_with_outline(font, text, x, y, r, g, b, a)
    if not font then return end 
    local int_x, int_y = math.floor(x), math.floor(y)
    render.draw_text(font, text, int_x-1, int_y, 0, 0, 0, a, 0,0,0,0,0)
    render.draw_text(font, text, int_x+1, int_y, 0, 0, 0, a, 0,0,0,0,0)
    render.draw_text(font, text, int_x, int_y-1, 0, 0, 0, a, 0,0,0,0,0)
    render.draw_text(font, text, int_x, int_y+1, 0, 0, 0, a, 0,0,0,0,0)
    render.draw_text(font, text, int_x, int_y, r, g, b, a, 0,0,0,0,0)
end



local grenade_start_times = {}
local predicted_infernos = {}
local last_frame_grenades = {}
local grenade_anim_states = {} 

local theme = {
    bg       = {22, 23, 27},             
    outline  = {60, 60, 65},             
    text     = {255, 255, 255, 255},
    text_dim = {180, 180, 180, 255},
    
    smoke_acc = {130, 100, 255, 255},
    fire_acc  = {255, 75, 75, 255},
    flash_acc = {255, 215, 50, 255},
    decoy_acc = {100, 235, 100, 255},
    he_acc    = {235, 235, 235, 255}
}

local function lerp(a, b, t)
    return a + (b - a) * t
end


local function draw_dynamic_panel(screen_pos, name, dist_m, progress, accent_color, morph_factor)
    if not screen_pos then return end
    if morph_factor < 0.01 then morph_factor = 0 end 
    
    local dist_str = string.format("%dm", math.floor(dist_m))
    if morph_factor < 0.5 then dist_str = "[" .. dist_str .. "]" end 

    local font_main = esp_fonts.name or Menu.fonts.group or DisplaySystem.fonts.main
    local font_sub = esp_fonts.weapon or Menu.fonts.main or DisplaySystem.fonts.main

    local w_name, h_name = render.measure_text(font_main, name)
    local w_dist, h_dist = render.measure_text(font_sub, dist_str)
    

    local panel_alpha = math.floor(220 * morph_factor)     
    local outline_alpha = math.floor(255 * morph_factor)  
    local text_shadow = math.floor(200 * (1.0 - morph_factor))
    
    local pad_x = 12
    local pad_y = lerp(0, 6, morph_factor)         
    local bar_h = 2
    local bar_gap = 4
    
    local content_spacing = lerp(2, h_name + bar_gap + bar_h + 3, morph_factor)

    local min_width = 40
    local total_w = math.max(min_width, w_name + pad_x * 2)
    local total_h = pad_y * 2 + h_name + bar_gap + bar_h + 2 + h_dist 
    if morph_factor < 0.1 then total_h = h_name + h_dist + 4 end

    local bx = math.floor(screen_pos.x - total_w / 2)
    local by = math.floor(screen_pos.y)

    if panel_alpha > 5 then
        render.draw_rectangle(bx, by, total_w, total_h, theme.bg[1], theme.bg[2], theme.bg[3], panel_alpha, 0, true, 6)
        render.draw_rectangle(bx, by, total_w, total_h, theme.outline[1], theme.outline[2], theme.outline[3], outline_alpha, 1, false, 6)
    end

    local name_y_offset = lerp(-(h_name + 2), pad_y, morph_factor) 
    local name_x = math.floor(screen_pos.x - w_name / 2)
    local name_y = math.floor(by + name_y_offset)
    
    if morph_factor < 0.1 then 
        render.draw_text(font_main, name, name_x, name_y, accent_color[1], accent_color[2], accent_color[3], 255, 1, 0, 0, 0, 180)
    else
        render.draw_text(font_main, name, name_x, name_y, 255, 255, 255, 255, 0, 0, 0, 0, 0)
    end


    local bar_y = name_y + h_name + bar_gap
    if morph_factor > 0.3 and progress > 0 then
        local bar_max_w = total_w - 16
        local cur_bar_w = math.floor(bar_max_w * progress)
        local bar_x = bx + (total_w - bar_max_w) / 2
        local bar_alpha = math.floor(255 * ((morph_factor - 0.3) / 0.7)) 

        render.draw_rectangle(bar_x, bar_y, bar_max_w, bar_h, 40, 40, 45, math.min(200, bar_alpha), 0, true, 1)
        if cur_bar_w > 0 then
            render.draw_rectangle(bar_x, bar_y, cur_bar_w, bar_h, accent_color[1], accent_color[2], accent_color[3], bar_alpha, 0, true, 1)
        end
    end


    local dist_y_offset = lerp(1, pad_y + h_name + bar_gap + bar_h + 3, morph_factor) 
    if morph_factor < 0.1 then dist_y_offset = 1 end 

    local dist_x = math.floor(screen_pos.x - w_dist / 2)
    local dist_y = math.floor(by + dist_y_offset)
    
    render.draw_text(font_sub, dist_str, dist_x, dist_y, theme.text_dim[1], theme.text_dim[2], theme.text_dim[3], theme.text_dim[4], (morph_factor < 0.5 and 1 or 0), 0,0,0,150)
end

function handle_world_esp()
    local should_draw_weapons = MenuLib.get_value("esp_dropped_weapons")
    local should_draw_projectiles = MenuLib.get_value("esp_projectiles")
    local should_draw_chickens = MenuLib.get_value("esp_chickens")

    if not should_draw_weapons and not should_draw_projectiles and not should_draw_chickens then return end
    if not proc.is_attached() or proc.did_exit() then return end

    local client_dll = proc.find_module("client.dll")
    if not client_dll or client_dll == 0 then return end
    
    local now = winapi.get_tickcount64()

    local local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    local local_origin = vec3(0,0,0)
    if local_pawn and local_pawn ~= 0 then
        local local_node = proc.read_int64(local_pawn + offsets.m_pGameSceneNode)
        if local_node and local_node ~= 0 then local_origin = vec3.read_float(local_node + offsets.m_vecAbsOrigin) end
    end

    local view_matrix = {}
    for i = 0, 15 do table.insert(view_matrix, proc.read_float(client_dll + offsets.dwViewMatrix + (i * 4))) end

    local entity_list = proc.read_int64(client_dll + offsets.dwEntityList)
    if not entity_list or entity_list == 0 then return end

    local current_frame_grenades = {} 

    for i = 64, 2048 do
        local list_entry = proc.read_int64(entity_list + 0x8 * ((i >> 9) & 0x7F) + 0x10)
        if not list_entry or list_entry == 0 then goto continue_loop end
        
     local entity = proc.read_int64(list_entry + 112 * (i & 0x1FF)) 
        if not entity or entity == 0 then goto continue_loop end
        local owner_handle = proc.read_int32(entity + offsets.m_hOwnerEntity)

        if (should_draw_weapons and owner_handle == -1) or should_draw_projectiles or should_draw_chickens then
            local item_info_ptr = proc.read_int64(entity + 0x10)
            if not item_info_ptr or item_info_ptr == 0 then goto continue_loop end

            local item_type_ptr = proc.read_int64(item_info_ptr + 0x20)
            if not item_type_ptr or item_type_ptr == 0 then goto continue_loop end
            
            local designer_name = proc.read_string(item_type_ptr, 128)
            if not designer_name or designer_name == "" then goto continue_loop end

            local game_scene_node = proc.read_int64(entity + offsets.m_pGameSceneNode)
            if not game_scene_node or game_scene_node == 0 then goto continue_loop end
            
            local entity_origin = vec3.read_float(game_scene_node + offsets.m_vecAbsOrigin)
            if entity_origin.x == 0 and entity_origin.y == 0 and entity_origin.z == 0 then goto continue_loop end

            local screen_pos = world_to_screen(view_matrix, entity_origin)
            local dist_m = get_distance_manual(entity_origin, local_origin) / 39.37 

            if should_draw_weapons and owner_handle == -1 then
                if screen_pos and WEAPONS_MAP[designer_name] then
                    draw_dynamic_panel(screen_pos, WEAPONS_MAP[designer_name], dist_m, 0, theme.text, 0.0)
                end
            end


            if should_draw_projectiles then

                if designer_name:find("_projectile") then
                    current_frame_grenades[i] = { name = designer_name, pos = entity_origin, index = i }
                end

                if not grenade_anim_states[i] then grenade_anim_states[i] = 0.0 end

                if screen_pos then
                    if designer_name == "smokegrenade_projectile" then
                        local vel = vec3.read_float(entity + offsets.m_vecVelocity)
                        local speed = math.sqrt(vel.x^2 + vel.y^2 + vel.z^2)
                        
                        local is_landed = (speed < 15) or (grenade_start_times[entity] and speed < 100)
                        local target_morph = is_landed and 1.0 or 0.0
                        
                        grenade_anim_states[i] = lerp(grenade_anim_states[i], target_morph, 0.15) 

                        if not is_landed then
                            grenade_start_times[entity] = nil
                            draw_dynamic_panel(screen_pos, "Smoke", dist_m, 0, theme.smoke_acc, grenade_anim_states[i])
                        else
                            local max_duration = 21.5
                            if not grenade_start_times[entity] then grenade_start_times[entity] = now end
                            local elapsed = (now - grenade_start_times[entity]) / 1000.0
                            local progress = math.max(0, 1 - (elapsed / max_duration))
                            if progress > 0 then
                                draw_dynamic_panel(screen_pos, "Smoke", dist_m, progress, theme.smoke_acc, grenade_anim_states[i])
                            end
                        end

                    elseif designer_name == "molotov_projectile" or designer_name == "incendiarygrenade_projectile" then
                        grenade_anim_states[i] = lerp(grenade_anim_states[i], 0.0, 0.2)
                        local label = (designer_name == "molotov_projectile") and "Molotov" or "Incendiary"
                        draw_dynamic_panel(screen_pos, label, dist_m, 0, theme.fire_acc, grenade_anim_states[i])

                    elseif designer_name == "decoy_projectile" then
                        grenade_anim_states[i] = lerp(grenade_anim_states[i], 1.0, 0.15)
                        draw_dynamic_panel(screen_pos, "Decoy", dist_m, 1.0, theme.decoy_acc, grenade_anim_states[i])

                    elseif designer_name == "flashbang_projectile" then
                        grenade_anim_states[i] = lerp(grenade_anim_states[i], 0.0, 0.2)
                        draw_dynamic_panel(screen_pos, "Flash", dist_m, 0, theme.flash_acc, grenade_anim_states[i])
                    elseif designer_name == "hegrenade_projectile" then
                        grenade_anim_states[i] = lerp(grenade_anim_states[i], 0.0, 0.2)
                        draw_dynamic_panel(screen_pos, "HE", dist_m, 0, theme.he_acc, grenade_anim_states[i])
                    end
                end
            end
            
            if should_draw_chickens and designer_name == "chicken" and screen_pos then
                draw_dynamic_panel(screen_pos, "Chicken", dist_m, 0, {200, 200, 200, 255}, 0.0)
            end
        end
        
        ::continue_loop::
    end

    local MOLOTOV_DURATION_MS = 7000 

    for idx, g_data in pairs(last_frame_grenades) do
        if not current_frame_grenades[idx] then
            if g_data.name == "molotov_projectile" or g_data.name == "incendiarygrenade_projectile" then
                predicted_infernos[idx] = {
                    pos = g_data.pos,
                    time = now,
                    expiration = now + MOLOTOV_DURATION_MS,
                    name = (g_data.name == "molotov_projectile") and "Molotov" or "Incendiary",
                    color = theme.fire_acc
                }

                grenade_anim_states[idx] = 0.0
            end
        end
    end

    last_frame_grenades = current_frame_grenades

    for idx, inferno in pairs(predicted_infernos) do
        if now > inferno.expiration then
            predicted_infernos[idx] = nil 
            grenade_anim_states[idx] = nil
        else
            if not grenade_anim_states[idx] then grenade_anim_states[idx] = 0.0 end
            grenade_anim_states[idx] = lerp(grenade_anim_states[idx], 1.0, 0.1)

            local screen_pos = world_to_screen(view_matrix, inferno.pos)
            
            if screen_pos then
                local dist_m = get_distance_manual(inferno.pos, local_origin) / 39.37
                local remaining = inferno.expiration - now
                local progress = math.max(0, remaining / MOLOTOV_DURATION_MS)
                
                draw_dynamic_panel(screen_pos, inferno.name, dist_m, progress, inferno.color, grenade_anim_states[idx])
            end
        end
    end

    if now % 100 == 0 then
        for k, v in pairs(grenade_anim_states) do
            if not current_frame_grenades[k] and not predicted_infernos[k] then
                grenade_anim_states[k] = nil
            end
        end
    end
end






local WEAPON_MAP = {
    [32] = "P2000", [61] = "USP-S", [4] = "Glock", [2] = "Dual Berettas", [36] = "P250",
    [30] = "Tec-9", [63] = "CZ75-Auto", [1] = "Desert Eagle", [3] = "Five-SeveN",
    [64] = "R8", [35] = "Nova", [25] = "XM1014", [27] = "MAG-7", [29] = "Sawed-Off",
    [14] = "M249", [28] = "Negev", [17] = "MAC-10", [23] = "MP5-SD", [24] = "UMP-45",
    [19] = "P90", [26] = "Bizon", [34] = "MP9", [33] = "MP7", [10] = "FAMAS",
    [16] = "M4A4", [60] = "M4A1-S", [8] = "AUG", [43] = "Galil", [7] = "AK-47",
    [39] = "SG 553", [40] = "SSG 08", [9] = "AWP", [38] = "SCAR-20", [11] = "G3SG1",
    [44] = "Hegrenade", [45] = "Smoke", [46] = "Molotov", [47] = "Decoy", [49] = "C4",
    [42] = "Knife", [59] = "Knife", [500] = "Bayonet", [505] = "Flip Knife", [506] = "Gut Knife",
    [507] = "Karambit", [508] = "M9 Bayonet", [512] = "Falchion", [515] = "Butterfly", [520] = "Navaja"
}

local BONE_MAP = {
    head = 6,
    neck = 5,
    spine_3 = 4, -- Upper Chest
    spine_2 = 3, -- Mid Torso
    spine_1 = 2, -- Lower Torso
    pelvis = 0,
    
    -- Left Arm Chain
    clavicle_L = 7,
    arm_upper_L = 8,
    arm_lower_L = 9,
    hand_L = 10,
    
    -- Right Arm Chain
    clavicle_R = 12,
    arm_upper_R = 13,
    arm_lower_R = 14,
    hand_R = 15,
    
    -- Left Leg Chain
    leg_upper_L = 22,
    leg_lower_L = 23,
    ankle_L = 24,
    
    -- Right Leg Chain
    leg_upper_R = 25,
    leg_lower_R = 26,
    ankle_R = 27
}

local BONE_CONNECTIONS = {
    {"head", "neck"}, {"neck", "spine"}, {"spine", "pelvis"},
    {"spine", "left_shoulder"}, {"left_shoulder", "left_elbow"}, {"left_elbow", "left_hand"},
    {"spine", "right_shoulder"}, {"right_shoulder", "right_elbow"}, {"right_elbow", "right_hand"},
    {"pelvis", "left_hip"}, {"left_hip", "left_knee"}, {"left_knee", "left_ankle"},
    {"pelvis", "right_hip"}, {"right_hip", "right_knee"}, {"right_knee", "right_ankle"}
}

local globals = {
aimbot_state = {
    last_target_index = -1,
    last_switch_time = 0,
    current_target_index = -1
}
}

function is_player_visible(player_pawn, local_player_index)
    if not player_pawn or player_pawn == 0 or not local_player_index or local_player_index < 1 then
        return false
    end
    local spotted_by_mask_addr = player_pawn + offsets.m_entitySpottedState + offsets.m_bSpottedByMask
    local mask = proc.read_int64(spotted_by_mask_addr)

    return ((mask >> (local_player_index - 1)) & 1) == 1
end

function world_to_screen(view_matrix, position_3d)
    local screen_w = view_matrix[13] * position_3d.x + view_matrix[14] * position_3d.y + view_matrix[15] * position_3d.z +
    view_matrix[16]
    if screen_w < 0.01 then return nil end

    local screen_x = view_matrix[1] * position_3d.x + view_matrix[2] * position_3d.y + view_matrix[3] * position_3d.z +
    view_matrix[4]
    local screen_y = view_matrix[5] * position_3d.x + view_matrix[6] * position_3d.y + view_matrix[7] * position_3d.z +
    view_matrix[8]
    local inv_w = 1.0 / screen_w

    local sx = screen_x * inv_w
    local sy = screen_y * inv_w
    local screen_width, screen_height = render.get_viewport_size()

    local x = (screen_width / 2.0) + (sx * screen_width) / 2.0
    local y = (screen_height / 2.0) - (sy * screen_height) / 2.0

    return vec2(x, y)
end


local WEAPON_CATEGORIES = {
    legit_pistol = { 32, 61, 4, 2, 36, 30, 63, 3 }, -- Pistols (No Deagle/R8)
    legit_deagle = { 1, 64 },                       -- Deagle and R8
    legit_smg = { 17, 23, 24, 19, 26, 34, 33 },   -- SMGs
    legit_rifle = { 10, 16, 60, 8, 43, 7, 39 },   -- Rifles
    legit_shotgun = { 35, 25, 27, 29 },           -- Shotguns
    legit_sniper = { 40, 9, 38, 11 }             -- Snipers
}


function get_active_weapon_id(pawn, entity_list_addr)
    if not pawn or pawn == 0 or not entity_list_addr or entity_list_addr == 0 then 
        return -1 
    end

    local weapon_services = proc.read_int64(pawn + offsets.m_pWeaponServices)
    if not weapon_services or weapon_services == 0 then return -1 end

    local active_weapon_handle = proc.read_int32(weapon_services + offsets.m_hActiveWeapon)
    if not active_weapon_handle or active_weapon_handle == -1 then return -1 end

    local handle_masked = active_weapon_handle & 0x7FFF
    local list_entry = proc.read_int64(entity_list_addr + 0x8 * (handle_masked >> 9) + 16)
    if not list_entry or list_entry == 0 then return -1 end
    
    local weapon_entity = proc.read_int64(list_entry + 112 * (handle_masked & 0x1FF))
    if not weapon_entity or weapon_entity == 0 then return -1 end
    
    local weapon_id = proc.read_int16(weapon_entity + offsets.m_AttributeManager + offsets.m_Item + offsets.m_iItemDefinitionIndex)
    
    if not weapon_id then
        return -1
    end
    
    return weapon_id
end


local weapon_category_ids = {
    "legit_pistol", "legit_deagle", "legit_smg", 
    "legit_rifle", "legit_shotgun", "legit_sniper"
}

local function update_triggerbot_ui_visibility()
    for _, category_id in ipairs(weapon_category_ids) do
        local dynamic_checkbox_id = category_id .. "_trigger_dynamic_delay_enabled"
        local static_slider_id = category_id .. "_trigger_delay"
        local min_slider_id = category_id .. "_trigger_dynamic_delay_min"
        local max_slider_id = category_id .. "_trigger_dynamic_delay_max"

        local dynamic_checkbox = Menu.elements[dynamic_checkbox_id]
        local static_slider = Menu.elements[static_slider_id]
        local min_slider = Menu.elements[min_slider_id]
        local max_slider = Menu.elements[max_slider_id]

        if dynamic_checkbox and static_slider and min_slider and max_slider then
            local is_dynamic_enabled = MenuLib.get_value(dynamic_checkbox_id)
            
            static_slider.is_active = not is_dynamic_enabled
            min_slider.is_active = is_dynamic_enabled
            max_slider.is_active = is_dynamic_enabled
        end
    end
end
function get_weapon_category(weapon_id)
    if weapon_id == -1 then return nil end
    for category_id, id_list in pairs(WEAPON_CATEGORIES) do
        for _, id in ipairs(id_list) do
            if id == weapon_id then
                return category_id
            end
        end
    end
    return nil
end



function trigger_schedule_action(ms, callback)
    if type(ms) ~= "number" then
        engine.log("Error: Invalid delay passed to trigger_schedule_action. Must be a number.", 255, 100, 100, 255)
        return 
    end
    
    table.insert(trigger_pending_actions, {
        execute_at = winapi.get_tickcount64() + ms,
        callback = callback
    })
end

function trigger_process_pending_actions()
    if #trigger_pending_actions == 0 then return end
    
    local current_time_ms = winapi.get_tickcount64()
    
    for i = #trigger_pending_actions, 1, -1 do
        local action = trigger_pending_actions[i]
        if current_time_ms >= action.execute_at then
            action.callback()
            table.remove(trigger_pending_actions, i)
        end
    end
end

function trigger_click_mouse(weapon_category)
    local shot_delay = 0
    local dynamic_enabled_id = weapon_category .. "_trigger_dynamic_delay_enabled"

    if Menu.elements[dynamic_enabled_id] and MenuLib.get_value(dynamic_enabled_id) then
        local min_delay = MenuLib.get_value(weapon_category .. "_trigger_dynamic_delay_min")
        local max_delay = MenuLib.get_value(weapon_category .. "_trigger_dynamic_delay_max")
        if min_delay > max_delay then min_delay = max_delay end
        shot_delay = math.random(min_delay, max_delay)
    else
        shot_delay = MenuLib.get_value(weapon_category .. "_trigger_delay")
    end
    
    shot_delay = math.max(0, shot_delay) 
    last_trigger_delay = shot_delay 

    trigger_schedule_action(shot_delay, function()
        input.simulate_mouse(0, 0, 2)
    end)
end




function draw_triggerbot_debug_info()
    local client_dll = proc.find_module("client.dll")
    if not client_dll then return end
    
    local local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if not local_pawn or local_pawn == 0 then return end
    
    local weapon_id = get_active_weapon_id(local_pawn)
    local weapon_category = get_weapon_category(weapon_id)

    if not weapon_category then return end
    
    local enabled_id = weapon_category .. "_trigger_enabled"
    if MenuLib.get_value(enabled_id) then
        local debug_text = string.format("Active Trigger Delay: %dms", last_trigger_delay)
        
        local screen_width, screen_height = render.get_viewport_size()
        local y_pos = screen_height - 30
        local x_pos = 10                

        render.draw_text(Menu.fonts.main, debug_text, x_pos, y_pos, 255, 255, 255, 255, 1.5, 0, 0, 0, 200)
    end
end

function trigger_get_current_hitchance()
    local client_dll = proc.find_module("client.dll")
    if not client_dll then return 0 end
    
    local local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if local_pawn == 0 then return 0 end
    
    local velocity_vec = vec3.read_float(local_pawn + offsets.m_vecVelocity)
    local current_speed = velocity_vec:length_2d()

    local hitchance = math.map(current_speed, 0, 250.0, 100, 0)
    
    return math.clamp(hitchance, 0, 100)
end

local rcs_state = {
    old_punch = vec3(0, 0, 0)
}

local _aim_state = { current_target_index = -1, last_kill_time = 0 }

function handle_aimbot(game, local_player_index, current_weapon_category)
    if not current_weapon_category then return end
    
    local enabled_id = current_weapon_category .. "_legit_enabled"
    local key_id = current_weapon_category .. "_legit_key"
    
    if not MenuLib.get_value(enabled_id) or not is_keybind_active(key_id) then 
        _aim_state.current_target_index = -1
        return 
    end

    local fov = MenuLib.get_value(current_weapon_category .. "_legit_fov")
    local smoothing = math.max(1.0, MenuLib.get_value(current_weapon_category .. "_legit_smoothing"))
    local hitbox_id = current_weapon_category .. "_legit_hitbox"
    
    local sw, sh = render.get_viewport_size()
    local cx, cy = sw / 2, sh / 2

    if MenuLib.get_value(current_weapon_category .. "_legit_draw_fov") then
        render.draw_circle(cx, cy, fov, 255, 255, 255, 30, 1, false)
    end
    
    local best_target = nil
    local best_dist = fov

    for _, entity in ipairs(game.entities) do
        if entity.team ~= game.local_team and is_player_visible(entity.pawn_address, local_player_index) then
            local hitbox_val = MenuLib.get_value(hitbox_id)
            local bone_pos = entity.bones.head 
            if hitbox_val == 2 then bone_pos = entity.bones.neck
            elseif hitbox_val == 3 then bone_pos = entity.bones.spine
            elseif hitbox_val == 4 then bone_pos = entity.bones.pelvis end

            if bone_pos then
                local s_pos = world_to_screen(game.view_matrix, bone_pos)
                if s_pos then
                    local dist = math.sqrt((s_pos.x - cx)^2 + (s_pos.y - cy)^2)
                    if dist < best_dist then
                        best_dist = dist
                        best_target = { pos = s_pos, index = entity.index } 
                    end
                end
            end
        end
    end

    if best_target then
        local dx = best_target.pos.x - cx
        local dy = best_target.pos.y - cy


        local move_x = dx / smoothing
        local move_y = dy / smoothing

        if math.abs(move_x) >= 1 or math.abs(move_y) >= 1 then
            input.simulate_mouse(math.floor(move_x), math.floor(move_y), 1)
        end
    else
        _aim_state.current_target_index = -1
    end
end




function handle_rcs(weapon_category, game)
    if not weapon_category then return end 

    local enabled_id = weapon_category .. "_rcs_enabled"
    local strength_x_id = weapon_category .. "_rcs_strength_x"
    local strength_y_id = weapon_category .. "_rcs_strength_y"
    local start_bullet_id = weapon_category .. "_rcs_start_bullet"
    
    if not MenuLib.get_value(enabled_id) then return end
    
    local shots_fired = proc.read_int32(game.local_pawn + offsets.m_iShotsFired)
    
    if shots_fired >= MenuLib.get_value(start_bullet_id) then
        local current_view_angles = vec3.read_float(game.client_dll + offsets.dwViewAngles)
        local aim_punch = vec3.read_float(game.local_pawn + offsets.m_aimPunchAngle)
        local recoil_delta = (aim_punch - rcs_state.old_punch)
        
        local strength_x = MenuLib.get_value(strength_x_id)
        local strength_y = MenuLib.get_value(strength_y_id)
        
        local new_angles = vec3(current_view_angles.x - (recoil_delta.x * strength_x), current_view_angles.y - (recoil_delta.y * strength_y), 0)
        
        new_angles.x = math.clamp(new_angles.x, -89.0, 89.0)
        new_angles.y = math.wrap(new_angles.y, -180.0, 180.0)
        vec3.write_float(game.client_dll + offsets.dwViewAngles, new_angles)
        
        rcs_state.old_punch = aim_punch
    else
        rcs_state.old_punch = vec3(0, 0, 0)
    end
end

function handle_triggerbot(weapon_category, game)
    if not weapon_category then return end

    local enabled_id = weapon_category .. "_trigger_enabled"
    local key_id = weapon_category .. "_trigger_key"

    if not MenuLib.get_value(enabled_id) then return end


    if not is_keybind_active(key_id) then return end

    trigger_process_pending_actions()
    if (winapi.get_tickcount64() - trigger_last_shot_time) < 100 then return end

    local entityId = proc.read_int32(game.local_pawn + offsets.m_iIDEntIndex)
    if entityId <= 0 then return end 

    local entListEntry = proc.read_int64(game.entity_list + 0x8 * ((entityId & 0x7FFF) >> 9) + 16)
    local entity = proc.read_int64(entListEntry + 112 * (entityId & 0x1FF))
    if entity == 0 then return end

    local entityTeam = proc.read_int32(entity + offsets.m_iTeamNum)
    local entityHp = proc.read_int32(entity + offsets.m_iHealth)
    local localTeam = game.local_team


    --engine.log(string.format("TARGET FOUND: ID=%d | HP=%d | Team=%d (Local=%d)", entityId, entityHp, entityTeam, localTeam), 0, 255, 0, 255)

    if entityHp > 0 then
        local team_check = MenuLib.get_value(weapon_category .. "_trigger_team_check")
        if team_check and entityTeam == localTeam then 
            ---engine.log("Blocked: Teammate", 255, 200, 0, 255)
            return 
        end

        ---engine.log("FIRING!", 255, 0, 0, 255)
        trigger_click_mouse(weapon_category)
        trigger_last_shot_time = winapi.get_tickcount64()
    else
        ---engine.log("Blocked: Zero HP (Bad Offset?)", 255, 100, 100, 255)
    end
end



function draw_recoil_crosshair(game)
    if not MenuLib.get_value("recoil_dot_enabled") then
        return
    end

    local shots_fired = proc.read_int32(game.local_pawn + offsets.m_iShotsFired)
    if not shots_fired or shots_fired < 1 then
        return
    end

    local screen_w, screen_h = render.get_viewport_size()
    local screen_center_x, screen_center_y = screen_w / 2, screen_h / 2
    
    local aim_punch = vec3.read_float(game.local_pawn + offsets.m_aimPunchAngle)
    if not aim_punch then return end

    local recoil_scale = 2.0
    
    local punch_x_pixels = aim_punch.y * recoil_scale * 5.7 
    local punch_y_pixels = aim_punch.x * recoil_scale * 6.7
    
    local dot_x = screen_center_x - punch_x_pixels
    local dot_y = screen_center_y + punch_y_pixels
    
    local r, g, b, a = table.unpack(MenuLib.get_value("recoil_dot_color"))
    
    render.draw_circle(dot_x, dot_y, 2, r, g, b, a, 0, true)
end




function draw_sniper_crosshair(game_data)
    if not MenuLib.get_value("sniper_crosshair_enabled") then
        return
    end

    if not game_data or not game_data.local_pawn or game_data.local_pawn == 0 then
        return
    end

    local weapon_id = get_active_weapon_id(game_data.local_pawn, game_data.entity_list)
    local weapon_category = get_weapon_category(weapon_id)

    if weapon_category ~= "legit_sniper" then
        return 
    end

    local is_scoped = proc.read_int8(game_data.local_pawn + offsets.m_bIsScoped) > 0
    if is_scoped then
        return 
    end

    local r, g, b, a = table.unpack(MenuLib.get_value("crosshair_color"))
    local thickness = MenuLib.get_value("crosshair_thickness")
    local gap = MenuLib.get_value("crosshair_gap")
    local length = 10 

    local screen_w, screen_h = render.get_viewport_size()
    local center_x, center_y = screen_w / 2, screen_h / 2

    render.draw_line(center_x, center_y - gap, center_x, center_y - gap - length, r, g, b, a, thickness)
    render.draw_line(center_x, center_y + gap, center_x, center_y + gap + length, r, g, b, a, thickness)
    render.draw_line(center_x - gap, center_y, center_x - gap - length, center_y, r, g, b, a, thickness)
    render.draw_line(center_x + gap, center_y, center_x + gap + length, center_y, r, g, b, a, thickness)
end














local BONE_ID_HEAD = 6


function get_head_position(pawn_address)
    local game_scene = proc.read_int64(pawn_address + offsets.m_pGameSceneNode)
    if not game_scene or game_scene == 0 then return nil end
    
    local bone_array_ptr = proc.read_int64(game_scene + offsets.m_boneArray_aim)
    if not bone_array_ptr or bone_array_ptr == 0 then return nil end

    return vec3.read_float(bone_array_ptr + BONE_ID_HEAD * 32)
end


function world_to_screen_manual(view_matrix_addr, position)
    local screen_w, screen_h = render.get_viewport_size()
    local vm = {}
    for i=0,15 do table.insert(vm, proc.read_float(view_matrix_addr + (i*4))) end
    local w = vm[13]*position.x + vm[14]*position.y + vm[15]*position.z + vm[16]
    if w < 0.01 then return nil end
    local sx = vm[1]*position.x + vm[2]*position.y + vm[3]*position.z + vm[4]
    local sy = vm[5]*position.x + vm[6]*position.y + vm[7]*position.z + vm[8]
    local x = (screen_w/2) + (0.5 * (sx/w) * screen_w + 0.5)
    local y = (screen_h/2) - (0.5 * (sy/w) * screen_h + 0.5)
    return vec2(x, y)
end





local function handle_ragebot()

    if not proc.is_attached() or proc.did_exit() then return end
    if not MenuLib.get_value("rage_enabled") or not is_keybind_active("rage_key") then return end

    local client_dll = proc.find_module("client.dll"); if not client_dll then return end
    
    local local_player_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if not local_player_pawn or local_player_pawn == 0 then return end

    local local_origin_node = proc.read_int64(local_player_pawn + offsets.m_pGameSceneNode)
    if not local_origin_node or local_origin_node == 0 then return end
    local local_origin = vec3.read_float(local_origin_node + offsets.m_nodeToWorld)
    local view_offset = vec3.read_float(local_player_pawn + offsets.m_vecViewOffset)
    local camera_pos = local_origin + view_offset

    local screen_w, screen_h = render.get_viewport_size()
    local crosshair_pos = vec2(screen_w / 2, screen_h / 2)
    local fov_radius = MenuLib.get_value("rage_fov")
    
    if MenuLib.get_value("rage_show_fov") then render.draw_circle(crosshair_pos.x, crosshair_pos.y, fov_radius, 255, 0, 0, 100, 1.5, false) end

    local best_target = { distance = fov_radius + 1, bone_pos = nil }
    local view_matrix_addr = client_dll + offsets.dwViewMatrix
    local entity_list_addr = proc.read_int64(client_dll + offsets.dwEntityList)

    for i = 1, 64 do
        local player_pawn = 0
        local list_entry = proc.read_int64(entity_list_addr + 0x8 * ((i >> 9) & 0x7F) + 0x10)
        if list_entry and list_entry ~= 0 then
            local player_controller = proc.read_int64(list_entry + 112 * (i & 0x1FF))
            if player_controller and player_controller ~= 0 then
                local pawn_handle = proc.read_int32(player_controller + offsets.m_hPlayerPawn)
                if pawn_handle and pawn_handle ~= -1 then
                    local pawn_handle_masked = pawn_handle & 0x7FFF
                    local list_entry2 = proc.read_int64(entity_list_addr + 0x8 * ((pawn_handle_masked >> 9) & 0x7F) + 0x10)
                    if list_entry2 and list_entry2 ~= 0 then
                        player_pawn = proc.read_int64(list_entry2 + 112 * (pawn_handle_masked & 0x1FF))
                    end
                end
            end
        end
     
        if player_pawn and player_pawn ~= 0 and player_pawn ~= local_player_pawn then
            if proc.read_int32(player_pawn + offsets.m_iHealth) > 0 and proc.read_int32(player_pawn + offsets.m_iTeamNum) ~= proc.read_int32(local_player_pawn + offsets.m_iTeamNum) then

                local head_pos = nil
                local game_scene_node = proc.read_int64(player_pawn + offsets.m_pGameSceneNode)
                if game_scene_node and game_scene_node ~= 0 then
                    local bone_array_ptr = proc.read_int64(game_scene_node + offsets.m_modelState + offsets.m_boneArray)
                    if bone_array_ptr and bone_array_ptr ~= 0 then
                        head_pos = vec3.read_float(bone_array_ptr + BONE_MAP.head * 32)
                    end
                end

                if head_pos then
                    local screen_pos = world_to_screen_manual(view_matrix_addr, head_pos)
                    if screen_pos then
                        local distance = screen_pos:distance(crosshair_pos)
                        if distance < best_target.distance then
                            best_target = { distance = distance, bone_pos = head_pos }
                        end
                    end
                end
            end
        end
    end

    if best_target.bone_pos then
        local direction = (best_target.bone_pos - camera_pos):normalize()
        direction.z = math.clamp(direction.z, -1.0, 1.0)
        
        local pitch = -math.deg(math.asin(direction.z))
        local yaw = math.deg(vec2(direction.x, direction.y):angle())
        
        local new_angles = vec3(pitch, yaw, 0)
        new_angles.x = math.clamp(new_angles.x, -89.0, 89.0)
        new_angles.y = math.wrap(new_angles.y, -180.0, 180.0)
        new_angles.z = 0 
        
        vec3.write_float(client_dll + offsets.dwViewAngles, new_angles)
    end
end


if _G.g_spin_yaw == nil then
    _G.g_spin_yaw = 0
end







local rcs_state = {
    old_punch = vec3(0, 0, 0)
}


local PLUS_JUMP, MINUS_JUMP = 65537, 256
local KEY_A, KEY_D, SPACE_BAR = 0x41, 0x44, 0x20


local state = { client_dll = nil }

local function handle_movement()
    if not proc.is_attached() then return end
    
    if not state.client_dll then state.client_dll = proc.find_module("client.dll"); if not state.client_dll then return end end
    
    local local_pawn = proc.read_int64(state.client_dll + offsets.dwLocalPlayerPawn); if not local_pawn or local_pawn == 0 then return end
    local force_jump_addr = state.client_dll + offsets.dwForceJump
    local flags = proc.read_int32(local_pawn + offsets.m_fFlags)
    local is_on_ground = (flags & 1) == 1

    if MenuLib.get_value("misc_bhop") and input.is_key_down(SPACE_BAR) then
        proc.write_int32(force_jump_addr, is_on_ground and PLUS_JUMP or MINUS_JUMP)
    end

end


local DEBUG_MODE = true

engine.register_on_engine_tick(function()

    --draw_triggerbot_debug_info()
    update_triggerbot_ui_visibility()

    if not proc.is_attached() or proc.did_exit() then
        return
    end

    local client_dll = proc.find_module("client.dll")
    if client_dll == 0 then return end

    local game = {}
    game.client_dll = client_dll
    game.view_matrix = {}
    for i = 0, 15 do table.insert(game.view_matrix, proc.read_float(client_dll + offsets.dwViewMatrix + (i * 4))) end

    game.local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if game.local_pawn == 0 then return end
    game.local_team = proc.read_int32(game.local_pawn + offsets.m_iTeamNum)
    game.entity_list = proc.read_int64(client_dll + offsets.dwEntityList)

    game.entities = {}


local weapon_id = get_active_weapon_id(game.local_pawn, game.entity_list)
    local weapon_category = get_weapon_category(weapon_id)


    if game.entity_list and game.entity_list ~= 0 then
        local list_entry_head = proc.read_int64(game.entity_list + 0x10)
        
        for i = 1, 64 do
            if not list_entry_head or list_entry_head == 0 then goto continue_main_loop end
            
            local entity_controller = proc.read_int64(list_entry_head + 112 * (i & 0x1FF))
            if not entity_controller or entity_controller == 0 then goto continue_main_loop end
            
            local pawn_handle = proc.read_int32(entity_controller + offsets.m_hPlayerPawn)
            if not pawn_handle or pawn_handle == -1 or pawn_handle == 0 then goto continue_main_loop end

            local pawn_handle_masked = pawn_handle & 0x7FFF
            local list_entry2 = proc.read_int64(game.entity_list + 0x8 * ((pawn_handle_masked >> 9) & 0x7F) + 16)
            if not list_entry2 or list_entry2 == 0 then goto continue_main_loop end

            local pawn_addr = proc.read_int64(list_entry2 + 112 * (pawn_handle_masked & 0x1FF))
            if not pawn_addr or pawn_addr == 0 or pawn_addr == game.local_pawn then goto continue_main_loop end
            
            local life_state = proc.read_int32(pawn_addr + offsets.m_lifeState)
            if life_state ~= 256 then goto continue_main_loop end

            local entity = { pawn_address = pawn_addr, team = proc.read_int32(pawn_addr + offsets.m_iTeamNum), bones = {} }
            local game_scene_node = proc.read_int64(pawn_addr + offsets.m_pGameSceneNode)

            if game_scene_node and game_scene_node ~= 0 then
                local bone_array_ptr = proc.read_int64(game_scene_node + offsets.m_modelState + offsets.m_boneArray)
                if bone_array_ptr and bone_array_ptr ~= 0 then
                    for name, index in pairs(BONE_MAP) do entity.bones[name] = vec3.read_float(bone_array_ptr + index * 32) end
                end
            end
            table.insert(game.entities, entity)

            ::continue_main_loop::
        end
    end

    local local_player_index = nil
    local local_player_controller = proc.read_int64(client_dll + offsets.dwLocalPlayerController)
    if local_player_controller and local_player_controller ~= 0 and game.entity_list and game.entity_list ~= 0 then
        local list_entry_head_for_index = proc.read_int64(game.entity_list + 0x10)
        if list_entry_head_for_index and list_entry_head_for_index ~= 0 then
            for i = 1, 64 do
                local entity_controller_for_index = proc.read_int64(list_entry_head_for_index + 112 * (i & 0x1FF))
                if entity_controller_for_index == local_player_controller then
                    local_player_index = i
                    break
                end
            end
        end
    end

  if local_player_index then
        handle_aimbot(game, local_player_index, weapon_category)
    end

       handle_rcs(weapon_category, game)
    handle_triggerbot(weapon_category, game)
        draw_recoil_crosshair(game)
    draw_sniper_crosshair(game)
    handle_world_esp()
    handle_movement()
handle_ragebot()

 handle_dragging()
    update_data()
    update_dynamic_scale()
    draw_modern_radar(game)
    handle_anti_flash() 
    handle_nightmode()
    handle_smoke_modulator()
    update_glow()
    draw_feature_indicators()
end)




local log_once = {}
return MenuLib
end
