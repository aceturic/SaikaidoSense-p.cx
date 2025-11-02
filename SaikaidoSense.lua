local STATE_WAITING_FOR_PROCESS = 1
local STATE_WAITING_FOR_GAME = 2
local STATE_ACTIVE = 3
local g_current_state = STATE_WAITING_FOR_PROCESS
local status_font = render.create_font("Verdana", 24, 700)
local InitializeFeatures = nil 
local MainGameLoop = nil 

engine.register_on_engine_tick(function(tick_id)

    if g_current_state == STATE_WAITING_FOR_PROCESS then
        render.draw_text(status_font, "Waiting for cs2.exe...", 20, 20, 255, 255, 255, 255, 2, 0,0,0,200)
        
        if proc.attach_by_name("cs2.exe") then
            engine.log("Process Attached! Waiting for game to load...", 0, 255, 0, 255)
            g_current_state = STATE_WAITING_FOR_GAME
        end

    elseif g_current_state == STATE_WAITING_FOR_GAME then
        if proc.did_exit() then 
            g_current_state = STATE_WAITING_FOR_PROCESS 
            return 
        end
        render.draw_text(status_font, "Attached! Waiting to join a match...", 20, 20, 255, 255, 255, 255, 2, 0,0,0,200)
        
        local client_dll = proc.find_module("client.dll")
        if client_dll and client_dll ~= 0 then
            local local_pawn = proc.read_int64(client_dll + 0x1BE7DA0) ---- dwLocalPlayerPawn
            if local_pawn and local_pawn ~= 0 then
                engine.log("Match Active! Initializing all features.", 0, 255, 0, 255)
                
                InitializeFeatures()
                g_current_state = STATE_ACTIVE

                engine.unregister_on_engine_tick(tick_id) 
engine.register_on_engine_tick(function(...)
    local success, err = pcall(MainGameLoop, ...) 
    if not success and err then
        engine.log("SCRIPT ERROR: " .. tostring(err), 255, 100, 100, 255)
    end
end)            end
        end

    end
end)
function InitializeFeatures()

local MenuLib = { version = "3.5" }

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

function MenuLib.draw_checkbox(opt, a, x, y, mx, my, r_queue)
    opt.h = 20
    local v = Menu.values[opt.id]
    local c = Menu.colors
    if mx > x + 195 and mx < x + 225 and my > y - 2 and my < y + 18 and input.is_key_pressed(1) then
        Menu.values[opt.id] = not v
        Menu.click_consumed = true
    end
    opt.anim = math.lerp(opt.anim or(v and 1 or 0), v and 1 or 0, 0.2)
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
    if hov and input.is_key_pressed(1) then
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
    if hov and input.is_key_pressed(1) then
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

function MenuLib.draw_input_text(opt, a, x, y, mx, my, r_queue)
    opt.h = 35
    local w, h = 220, 20
    local c = Menu.colors
    if input.is_key_pressed(1) then
        local hov = mx > x and mx < x + w and my > y + 15 and my < y + 15 + h
        if hov then
            Menu.active_input_element = opt.id
            Menu.click_consumed = true
        elseif Menu.active_input_element == opt.id then
            Menu.active_input_element = nil
        end
    end
    if Menu.active_input_element == opt.id then
        if input.is_key_pressed(0x08) and #Menu.values[opt.id] > 0 then Menu.values[opt.id] = string.sub(Menu.values[opt.id], 1, -2) end
        local shift_down = input.is_key_down(0x10)
        for vk, char_map in pairs(VK_TO_CHAR) do
            if input.is_key_pressed(vk) then
                local char = shift_down and char_map.shifted or char_map.normal
                Menu.values[opt.id] = Menu.values[opt.id] .. char
            end
        end
    end
    local text_value = Menu.values[opt.id]
    local is_active = Menu.active_input_element == opt.id
    if is_active and (time.unix_ms() % 1000) < 500 then text_value = text_value .. "|" end
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    local border_color = is_active and c.accent or c.bg_light
    render.draw_rectangle(x - 1, y + 15 - 1, w + 2, h + 2, border_color[1], border_color[2], border_color[3], a, 1, false, 4)
    render.draw_rectangle(x, y + 15, w, h, c.bg_dark[1], c.bg_dark[2], c.bg_dark[3], a, 0, true, 4)
    if text_value and text_value ~= "" then render.draw_text(Menu.fonts.main, text_value, x + 5, y + 17, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0) end
end

function MenuLib.draw_button(opt, a, x, y, mx, my, r_queue)
    opt.h = 30
    local w, h = 220, 25
    local c = Menu.colors
    local hov = mx > x and mx < x + w and my > y and my < y + h
    if hov and input.is_key_pressed(1) then
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
    local clicked_this_frame_to_activate = false
    if input.is_key_pressed(1) then
        if hov then
            if Menu.active_binding_element == opt.id then
                Menu.active_binding_element = nil
            else
                Menu.active_binding_element = opt.id
                clicked_this_frame_to_activate = true
                Menu.keybind_mode_selector.visible = false
            end
            Menu.click_consumed = true
        elseif Menu.active_binding_element == opt.id then
            Menu.active_binding_element = nil
        end
    end
    if hov and input.is_key_pressed(0x02) and not Menu.click_consumed then
        local selector = Menu.keybind_mode_selector
        if selector.visible and selector.element_id == opt.id then
            selector.visible = false
        else
            selector.visible = true
            selector.element_id = opt.id
            selector.x, selector.y = mx + 5, my
            Menu.active_binding_element = nil
        end
        Menu.click_consumed = true
    end
    local keybind_data = Menu.values[opt.id]
    if Menu.active_binding_element == opt.id and not clicked_this_frame_to_activate then
        for i = 1, 255 do
            if i ~= Menu.key and input.is_key_pressed(i) then
                keybind_data.key = (i == 0x1B) and 0 or i
                Menu.active_binding_element = nil
                Menu.click_consumed = true
                break
            end
        end
    end
    local mode_char = Menu.keybind_mode_selector.items[keybind_data.mode]:sub(1, 1)
    local key_text = Menu.active_binding_element == opt.id and "[...]" or string.format("[%s] [%s]", mode_char, get_key_name(keybind_data.key))
    if opt.name and opt.name ~= "" then render.draw_text(Menu.fonts.main, opt.name, x, y + 1, c.text_main[1], c.text_main[2], c.text_main[3], a, 0, 0, 0, 0, 0) end
    if Menu.active_binding_element == opt.id then
        local ac = c.accent
        render.draw_rectangle(kx - 1, y - 1, w + 2, h + 2, ac[1], ac[2], ac[3], a, 0, true, 5)
    end
    render.draw_rectangle(kx, y, w, h, (hov and c.bg_light or c.bg_dark)[1], (hov and c.bg_light or c.bg_dark)[2], (hov and c.bg_light or c.bg_dark)[3], a, 0, true, 4)
    render.draw_text(Menu.fonts.keybind, key_text, kx + 5, y + 2, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
end

function MenuLib.draw_singleselect(opt, a, x, y, mx, my, r_queue)
    opt.h = 35
    local w, h = 220, 20
    local c = Menu.colors
    local main_box_y = y + 15
    local hov = mx > x and mx < x + w and my > main_box_y and my < main_box_y + h
    if hov and input.is_key_pressed(1) then
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
    local selected_index = Menu.values[opt.id]
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
    if hov and input.is_key_pressed(1) then
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
    for i, item in ipairs(opt.items) do
        if Menu.values[opt.id][i] then table.insert(selected_items, item) end
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
                local is_ticked = Menu.values[opt.id][i] or false
                if item_hov then render.draw_rectangle(x + 2, item_y, w - 4, h, c.bg_light[1], c.bg_light[2], c.bg_light[3], a, 0, true, 4) end
                render.draw_rectangle(x + 5, item_y + 5, 10, 10, c.bg_light[1], c.bg_light[2], c.bg_light[3], a, 1, false, 3)
                if is_ticked then render.draw_rectangle(x + 5, item_y + 5, 10, 10, c.accent[1], c.accent[2], c.accent[3], a, 0, true, 3) end
                render.draw_text(Menu.fonts.main, item, x + 22, item_y + 2, c.text_dim[1], c.text_dim[2], c.text_dim[3], a, 0, 0, 0, 0, 0)
                if item_hov and input.is_key_pressed(1) then
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

local CONFIG_MANIFEST = "_config_list.json"
function MenuLib.save_config(name)
    if not name or name == "" then engine.log("Config name cannot be empty.", 255, 100, 100, 255); return end
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
        if v == name then
            exists = true
            break
        end
    end
    if not exists then table.insert(list, name) end
    fs.write_to_file(CONFIG_MANIFEST, json.stringify(list))
    engine.log("Config saved to " .. file_name, 100, 255, 100, 255)
end

function MenuLib.load_config(name)
    if not name or name == "" then engine.log("Config name cannot be empty.", 255, 100, 100, 255); return end
    
    local file_name = name .. ".json"
    if not fs.does_file_exist(file_name) then engine.log("Config file not found: " .. file_name, 255, 100, 100, 255); return end
    
    local json_string = fs.read_from_file(file_name)
    local success, config_data = pcall(json.parse, json_string)
    
    if not success or type(config_data) ~= "table" then
        engine.log("Failed to parse config file: " .. file_name, 255, 100, 100, 255)
        return
    end

    for id, loaded_value in pairs(config_data) do
        if Menu.values[id] ~= nil then
            local current_value = Menu.values[id]
            
            if type(current_value) == "table" and current_value.key ~= nil and current_value.mode ~= nil then
                if type(loaded_value) == "table" then
                    if type(loaded_value.key) == "number" then
                        current_value.key = loaded_value.key
                    end
                    if type(loaded_value.mode) == "number" then
                        current_value.mode = loaded_value.mode
                    end
                end

            elseif type(current_value) == "table" and current_value.h ~= nil then
                if type(loaded_value) == "table" and loaded_value.h ~= nil then
                    current_value.h, current_value.s, current_value.v, current_value.a = loaded_value.h, loaded_value.s, loaded_value.v, loaded_value.a
                elseif type(loaded_value) == "table" and #loaded_value == 4 then
                    local h, s, v = MenuLib.rgb_to_hsv(loaded_value[1], loaded_value[2], loaded_value[3])
                    current_value.h, current_value.s, current_value.v, current_value.a = h, s, v, loaded_value[4]
                end

            else
                if type(current_value) == type(loaded_value) then
                    Menu.values[id] = loaded_value
                end
            end
        end
    end
    engine.log("Config loaded from " .. file_name, 100, 255, 100, 255)
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

MenuLib.initialize({ key = 0x2D, default_tab = "legit" })


local legit_sub_tabs = {
    { id = "legit_pistol", name = "PISTOL", anim = 0 },
    { id = "legit_deagle", name = "DEAGLE", anim = 0 },
    { id = "legit_smg",    name = "SMG",    anim = 0 },
    { id = "legit_rifle",  name = "RIFLE",  anim = 0 },
    { id = "legit_shotgun",name = "SHOTGUN",anim = 0 },
    { id = "legit_sniper", name = "SNIPERS",anim = 0 }
}

MenuLib.add_tab("rage", "Rage")

table.insert(Menu.tabs, {id = "legit", name = "Legit", anim = 0, sub_tabs = legit_sub_tabs})
Menu.active_sub_tab = "legit_rifle"

MenuLib.add_tab("visuals", "Visuals")
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


local esp_main = MenuLib.add_group("visuals", "Player ESP", 1)
local esp_colors = MenuLib.add_group("visuals", "ESP Colors", 2)
local world_esp = MenuLib.add_group("visuals", "World Visuals", 1)
local glow_colors = MenuLib.add_group("visuals", "Glow & World Colors", 2)

local misc_general = MenuLib.add_group("misc", "General", 1)
local misc_indicators = MenuLib.add_group("misc", "Indicators", 1)
local misc_watermark = MenuLib.add_group("misc", "Watermark", 2)
local misc_crosshair = MenuLib.add_group("misc", "Crosshair", 2)
local misc_hitlog = MenuLib.add_group("misc", "Hitlog", 2)
local misc_speclist = MenuLib.add_group("misc", "Spectator List", 2)

MenuLib.add_element(rage_general, "checkbox", "rage_enabled", "Enable Rage Aimbot")
MenuLib.add_element(rage_general, "keybind", "rage_key", "Rage Key", { default_key = 0x06, default_mode = 1 })
MenuLib.add_element(rage_general, "checkbox", "rage_show_fov", "Show FOV (Targeting Radius)", { default = true })
MenuLib.add_element(rage_general, "slider_float", "rage_fov", "FOV", { min = 1.0, max = 500.0, default = 150.0 })

MenuLib.add_element(rage_aa, "label", "aa_label", "Anti-Aim Control")
MenuLib.add_element(rage_aa, "checkbox", "aa_enabled", "Enable Anti-Aim", { default = false })
MenuLib.add_element(rage_aa, "keybind", "aa_disable_key", "Disable on Key", { default = 0x05, mode = key_mode.onhotkey })
MenuLib.add_element(rage_aa, "singleselect", "aa_pitch_mode", "Pitch Angle", { items = { "None", "Down", "Up", "Jitter" }, default = 1 })
MenuLib.add_element(rage_aa, "singleselect", "aa_yaw_mode", "Yaw Mode", { items = { "None", "Backward", "Spin" }, default = 1 })
MenuLib.add_element(rage_aa, "slider_float", "aa_yaw_additive", "Yaw Additive Offset", { min = -180.0, max = 180.0, default = 0.0 })
MenuLib.add_element(rage_aa, "slider_float", "aa_spin_speed", "Spin Speed", { min = 1.0, max = 100.0, default = 15.0 })
MenuLib.add_element(rage_aa, "checkbox", "aa_jitter_enabled", "Add Random Jitter")
MenuLib.add_element(rage_aa, "slider_float", "aa_jitter_range", "Jitter Range (+/-)", { min = 0.0, max = 90.0, default = 20.0 })

MenuLib.add_element(esp_main, "checkbox", "esp_enabled", "Enable ESP")
MenuLib.add_element(esp_main, "checkbox", "esp_box", "ESP Box")
MenuLib.add_element(esp_main, "singleselect", "esp_box_type", "Box Type", { items = { "Normal", "Corner", "Filled" }, default = 3 })
MenuLib.add_element(esp_main, "singleselect", "esp_skeleton_mode", "Skeleton Style", { items = { "Off", "Normal", "Circular" } })
MenuLib.add_element(esp_main, "checkbox", "esp_name", "ESP Name")
MenuLib.add_element(esp_main, "checkbox", "esp_money", "Money ESP")
MenuLib.add_element(esp_main, "checkbox", "esp_scoped_flag", "Scoped Flag")
MenuLib.add_element(esp_main, "checkbox", "esp_flashed_flag", "Flashed Flag")
MenuLib.add_element(esp_main, "checkbox", "esp_distance", "Show Distance")
MenuLib.add_element(esp_main, "checkbox", "esp_player_weapon", "Player Weapon")

MenuLib.add_element(world_esp, "checkbox", "esp_dropped_weapons", "Show Dropped Weapons")
MenuLib.add_element(world_esp, "checkbox", "esp_projectiles", "Show Grenades")
MenuLib.add_element(world_esp, "checkbox", "esp_chickens", "Show Chickens")
MenuLib.add_element(world_esp, "checkbox", "esp_bomb", "Enable Bomb ESP")
MenuLib.add_element(world_esp, "checkbox", "esp_glow", "Glow")
MenuLib.add_element(world_esp, "checkbox", "world_nightmode", "Enable Nightmode")
MenuLib.add_element(world_esp, "slider_float", "world_nightmode_intensity", "Nightmode Intensity", { min = 1.0, max = 100.0, default = 50.0 })
MenuLib.add_element(world_esp, "checkbox", "world_smoke_mod", "Enable Smoke Color", { default = true })

MenuLib.add_element(esp_colors, "colorpicker_button", "esp_box_color", "Box Color", { default = {18, 18, 18, 255} })
MenuLib.add_element(esp_colors, "colorpicker_button", "esp_skeleton_color", "Skeleton Color", { default = {0, 255, 0, 255} })
MenuLib.add_element(esp_colors, "colorpicker_button", "esp_name_color", "Name Color", { default = {255, 255, 255, 255} })
MenuLib.add_element(esp_colors, "colorpicker_button", "esp_money_color", "Money Color", { default = {50, 200, 50, 255} })
MenuLib.add_element(esp_colors, "colorpicker_button", "esp_distance_color", "Distance Color", { default = {220, 220, 220, 255} })
MenuLib.add_element(esp_colors, "colorpicker_button", "esp_bomb_color", "Bomb ESP Color", { default = {255, 50, 50, 255} })

MenuLib.add_element(glow_colors, "colorpicker_button", "esp_ct_glow_color", "CT Glow Color", { default = {0, 0, 255, 255} })
MenuLib.add_element(glow_colors, "colorpicker_button", "esp_t_glow_color", "T Glow Color", { default = {255, 0, 0, 255} })
MenuLib.add_element(glow_colors, "colorpicker_button", "world_smoke_color", "Smoke Color", { default = {170, 0, 255, 255} })

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

MenuLib.add_element(cfg_main, "keybind", "menu_open_key", "Menu Key", { default_key = 0x2D })

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

local OFFSETS = {
    ENTITY_LIST = 0x1D15578,
    LOCAL_PLAYER_PAWN = 0x1BF14A0,
    M_HPAWN = 0x6B4,
    OBSERVER_SERVICES = 0x1418,
    OBSERVER_TARGET = 0x44,
    SANITIZED_NAME = 0x850,
    dwPlantedC4 = 0x1E37E10,
    dwGlobalVars = 0x1BE69B0,
    m_flC4Blow = 0x11A0,
    m_flCurrentTime = 0x650,
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
        icon = render.create_font("Arial", 18, 700)
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
    dwViewMatrix = 0x1E2AEC0,
    dwLocalPlayerPawn = 0x1BE7DA0,
    dwLocalPlayerController = 0x1E16870,
    dwEntityList = 0x1D0C9F8,
    dwViewAngles = 0x1E35440,
    m_hPlayerPawn = 0x8FC,
    m_bDormant = 0x10B,
    m_angEyeAngles = 0x3DF0,
    m_iHealth = 0x34C,
    m_lifeState = 0x354,
    m_Glow = 0x1E26F18,
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
    dwPlantedC4 = 0x1E30360,
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
    vSmokeColor = 0x85C,
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
    dwCSGOInput = 0x1E34D90, 
    dwForceJump = 0x1BD54A0, 
    m_bCameraInThirdPerson = 0x251, 
    m_iShotsFired = 0x272C,      -- C_CSPlayerPawn
    m_aimPunchAngle = 0x16E4,    -- C_CSPlayerPawn
    m_aimPunchCache = 0x1708,     -- C_CSPlayerPawn
    m_fFlags = 0x3F8,         -- C_BaseEntity::m_fFlags
    m_hpawn = 0x8FC,
    m_pObserverServices = 0x1408,
    m_hObserverTarget = 0x44,
    m_pWeaponServices = 0x13F0,
    m_hActiveWeapon = 0x58,
   


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
    end
    end
end

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

    local alpha_blur, alpha_welcome, alpha_box
    if DisplaySystem.state.phase == "welcome" then
        alpha_blur = DisplaySystem.config.blur_opacity * 255
        alpha_welcome = math.min(elapsed / DisplaySystem.config.welcome_duration, 1) * 255
        alpha_box = 0
    elseif DisplaySystem.state.phase == "fade_out" then
        local p = (now - DisplaySystem.state.fade_out_start) / (DisplaySystem.config.fade_duration * 1000)
        alpha_blur = DisplaySystem.config.blur_opacity * (1-p) * 255
        alpha_welcome = (1-p) * 255
        alpha_box = (1-p) * 255
    else
        alpha_blur = DisplaySystem.config.blur_opacity * 255
        alpha_welcome = 0
        alpha_box = 255
    end

    if blur_bg then
        render.draw_bitmap(blur_bg, 0, 0, vw, vh, alpha_blur)
    end

    if alpha_welcome > 0 then
        local welcome_str = ("Welcome %s to Shook for CS2"):format(DisplaySystem.config.username)
        local fw, fh = render.measure_text(DisplaySystem.fonts.welcome, welcome_str)
        render.draw_text(DisplaySystem.fonts.welcome, welcome_str,
            (vw-fw)*.5, (vh-fh)*.5,
            DisplaySystem.config.welcome_color[1],
            DisplaySystem.config.welcome_color[2],
            DisplaySystem.config.welcome_color[3],
            alpha_welcome, 2, 0, 0, 0, alpha_welcome*0.5
        )
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
            local info = ("Perception.cx | %s | FPS: %.0f | Ping: N/A"):format(DisplaySystem.config.username, DisplaySystem.state.fps_value)
            local tw, th = render.measure_text(DisplaySystem.fonts.main, info)
            local pad = DisplaySystem.config.box_padding
            local bw, bh = tw + pad*2, th + pad*2
            local bx, by = watermark_drag_x, watermark_drag_y
            render.draw_rectangle(bx, by, bw, bh, DisplaySystem.config.bg_color[1], DisplaySystem.config.bg_color[2], DisplaySystem.config.bg_color[3], alpha, 0, true)
            render.draw_rectangle(bx, by, bw, bh, DisplaySystem.config.border_color[1], DisplaySystem.config.border_color[2], DisplaySystem.config.border_color[3], alpha, 2, false)
            render.draw_text(DisplaySystem.fonts.main, info, bx + pad, by + pad,
                DisplaySystem.config.text_color[1], DisplaySystem.config.text_color[2], DisplaySystem.config.text_color[3], alpha, 1, 0, 0, 0, alpha*0.5)
        end
    end

    if crosshair_visible then
        local anim_progress, alpha
        if DisplaySystem.state._crosshair_fading_out then
            local fade_elapsed = (now - DisplaySystem.state._crosshair_fade_start_time) / 1000
            anim_progress = math.max(0, 1 - fade_elapsed / CROSSHAIR_FADE_TIME)
            alpha = math.floor(255 * anim_progress)
            if anim_progress <= 0 then
                DisplaySystem.state._crosshair_visible = false
                DisplaySystem.state._crosshair_fading_out = false
            end
        else
            local appear_elapsed = (now - DisplaySystem.state._crosshair_start_time) / 1000
            anim_progress = math.min(appear_elapsed / CROSSHAIR_APPEAR_TIME, 1)
            alpha = math.floor(255 * anim_progress)
        end
        if alpha > 0 and DisplaySystem.state.phase ~= "welcome" then
            local cx, cy = vw*.5, vh*.5
            local c = DisplaySystem.config.crosshair
            local off = c.gap * .5
            render.draw_line(cx - c.size, cy, cx - off, cy, c.color[1], c.color[2], c.color[3], alpha, c.thickness)
            render.draw_line(cx + off, cy, cx + c.size, cy, c.color[1], c.color[2], c.color[3], alpha, c.thickness)
            render.draw_line(cx, cy - c.size, cx, cy - off, c.color[1], c.color[2], c.color[3], alpha, c.thickness)
            render.draw_line(cx, cy + off, cx, cy + c.size, c.color[1], c.color[2], c.color[3], alpha, c.thickness)
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

do
    local info = ("SaikaidoSense | %s | FPS: %.0f"):format(DisplaySystem.config.username, DisplaySystem.state.fps_value)
    local tw, th = render.measure_text(DisplaySystem.fonts.main, info)
    local pad = DisplaySystem.config.box_padding
    local bw, bh = tw + pad * 2, th + pad * 2
    
    local mx, my = input.get_mouse_position()

    if not watermark_dragging then
        local over = mx >= watermark_drag_x and mx <= watermark_drag_x + bw and my >= watermark_drag_y and my <= watermark_drag_y + bh
        if over and input.is_key_pressed(1) then
            watermark_dragging = true

            watermark_drag_offset_x = mx - watermark_drag_x
            watermark_drag_offset_y = my - watermark_drag_y
        end
    end

    if watermark_dragging then

        if not input.is_key_down(1) then
            watermark_dragging = false
        else
            local new_x = mx - watermark_drag_offset_x
            local new_y = my - watermark_drag_offset_y

            MenuLib.set_value("pos_watermark", string.format("%d,%d", new_x, new_y))

            watermark_drag_x = new_x
            watermark_drag_y = new_y
        end
    end

    local bx, by = watermark_drag_x, watermark_drag_y
    render.draw_rectangle(bx, by, bw, bh, DisplaySystem.config.bg_color[1], DisplaySystem.config.bg_color[2], DisplaySystem.config.bg_color[3], alpha, 0, true)
    render.draw_rectangle(bx, by, bw, bh, DisplaySystem.config.border_color[1], DisplaySystem.config.border_color[2], DisplaySystem.config.border_color[3], alpha, 2, false)
    render.draw_text(DisplaySystem.fonts.main, info, bx + pad, by + pad,
        DisplaySystem.config.text_color[1], DisplaySystem.config.text_color[2], DisplaySystem.config.text_color[3], alpha, 1, 0, 0, 0, alpha * 0.5)
end

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




    if MenuLib.get_value("misc_hit_events_enabled") then
        process.is_open = proc.is_attached()
        process.client_dll = proc.find_module("client.dll") or 0

        if not process.is_open or process.client_dll == 0 then return end

        local entityList = proc.read_int64(process.client_dll + offsets.dwEntityList)
        local localPlayerPawn = proc.read_int64(process.client_dll + offsets.dwLocalPlayerPawn)
        if not entityList or entityList == 0 or not localPlayerPawn or localPlayerPawn == 0 then return end

        for i = 1, 64 do
            local list_entry = proc.read_int64(entityList + (8 * (i & 0x7FFF) >> 9) + 16)
            if not list_entry or list_entry == 0 then goto continue end

            local player = proc.read_int64(list_entry + 112 * (i & 0x1FF))
            if not player or player == 0 then goto continue end

            local playerPawn = proc.read_int32(player + offsets.m_hpawn)
            if not playerPawn or playerPawn == 0 then goto continue end

            local list_entry2 = proc.read_int64(entityList + 0x8 * ((playerPawn & 0x7FFF) >> 9) + 16)
            if not list_entry2 or list_entry2 == 0 then goto continue end

            local pCSPlayerPawn = proc.read_int64(list_entry2 + 112 * (playerPawn & 0x1FF))
            if not pCSPlayerPawn or pCSPlayerPawn == 0 then goto continue end

            if pCSPlayerPawn == localPlayerPawn then
                local bullet_services = proc.read_int64(player + 0x730)
                local current_damage = proc.read_int32(bullet_services + 0x118)

                if current_damage < total_damage then
                    total_damage = current_damage
                end

                if current_damage > total_damage then
                    local delta = current_damage - total_damage

                    if MenuLib.get_value("misc_hitlog") then
                        local hitlogdis = ("Hit an enemy for -" .. delta .. " damage")
                        add_hitlog_message(hitlogdis)
                    end

                    if MenuLib.get_value("misc_hitsound") then
                        local success = winapi.play_sound(hitsound_path)
                    end

                    total_damage = current_damage
                end
                goto continue
            end
            ::continue::
        end
    end

    local y = vh - 40
    local hitlog_box_spacing = 18
    local hitlog_appear_time = 0.18

    for i = #hitlog_messages, 1, -1 do
        local msg = hitlog_messages[i]
        local elapsed = (now - msg.time) / 1000

        if elapsed > HITLOG_SHOW_TIME then
            local fade = 1 - math.min((elapsed - HITLOG_SHOW_TIME) / HITLOG_FADE_TIME, 1)
            msg.alpha = math.floor(255 * fade)
            if fade <= 0 then
                table.remove(hitlog_messages, i)
                goto continue_hitlog
            end
        else
            msg.alpha = 255
        end

        local tw, th = render.measure_text(DisplaySystem.fonts.main, msg.text)
        local pad = hitlog_box_pad

        local anim_progress = 1.0
        if elapsed < hitlog_appear_time then
            anim_progress = elapsed / hitlog_appear_time
        elseif elapsed > HITLOG_SHOW_TIME then
            local fade = 1 - math.min((elapsed - HITLOG_SHOW_TIME) / HITLOG_FADE_TIME, 1)
            anim_progress = fade
        end

        local slide_offset = (1 - anim_progress) * 25

        local bw = hitlog_box_width
        local bh = hitlog_box_height
        local bx = (vw - bw) / 2
        local by = (y - hitlog_box_height + pad) + slide_offset

        render.draw_rectangle(bx, by, bw, bh, ht_bg_r, ht_bg_g, ht_bg_b, msg.alpha, 0, true)
        render.draw_rectangle(bx, by, bw, bh, ht_ot_r, ht_ot_g, ht_ot_b, msg.alpha, 2, false)
        local text_x = bx + (bw - tw) / 2
        local text_y = by + (bh - th) / 2
        render.draw_text(
            DisplaySystem.fonts.main, msg.text,
            text_x, text_y,
            ht_txt_r, ht_txt_g, ht_txt_b, msg.alpha, 1, 0, 0, 0, msg.alpha * 0.5
        )

        y = by - hitlog_box_spacing
        ::continue_hitlog::
    end
end)

local font = render.create_font("Tahoma", 13, 400)

local spectators = {}

local function get_pcs_player_pawn(pawn_handle)
    local client = proc.find_module("client.dll")
    local entity_list = proc.read_int64(client + offsets.dwEntityList)
    if entity_list == 0 then return 0 end

    local entry = proc.read_int64(entity_list + 0x8 * ((pawn_handle & 0x7FFF) >> 9) + 16)
    if entry == 0 then return 0 end

    return proc.read_int64(entry + 112 * (pawn_handle & 0x1FF))
end
local function get_name(controller)
    local name_ptr = proc.read_int64(controller + offsets.m_sSanitizedPlayerName)
    if name_ptr == 0 then return "Invalid" end
    return proc.read_string(name_ptr, 64)
end
local function get_local_pawn()
    local client = proc.find_module("client.dll")
    if client == 0 then return 0 end
    return proc.read_int64(client + offsets.dwLocalPlayerPawn)
end
local function get_entity_list_entry(index)
    local client = proc.find_module("client.dll")
    local entity_list = proc.read_int64(client + offsets.dwEntityList)
    if entity_list == 0 then return 0 end

    local entry1 = proc.read_int64(entity_list + ((8 * (index & 0x7FFF)) >> 9) + 16)
    if entry1 == 0 then return 0 end

    return proc.read_int64(entry1 + (112 * (index & 0x1FF)))
end
local function is_spectating_me(controller, local_pawn)
    local pawn_handle = proc.read_int32(controller + offsets.m_hpawn)
    if pawn_handle == 0 then return false end

    local pawn = get_pcs_player_pawn(pawn_handle)
    if pawn == 0 then return false end

    local obs_services = proc.read_int64(pawn + offsets.m_pObserverServices)
    if obs_services == 0 then return false end

    local target_handle = proc.read_int32(obs_services + offsets.m_hObserverTarget)
    if target_handle == 0 then return false end

    local target_pawn = get_pcs_player_pawn(target_handle)
    if target_pawn == 0 then return false end

    return target_pawn == local_pawn
end

local function update_speclist_anim(should_show)
    local now = winapi.get_tickcount64()
    if speclist_anim.last_tick == 0 then
        speclist_anim.last_tick = now
    end
    local dt = (now - speclist_anim.last_tick) / 1000
    speclist_anim.last_tick = now

    if should_show then
        if not speclist_anim.visible then
            speclist_anim.visible = true
            speclist_anim.fading_out = false
            speclist_anim.anim_progress = 0
        end
        if speclist_anim.anim_progress < 1 then
            speclist_anim.anim_progress = math.min(speclist_anim.anim_progress + dt / speclist_anim.anim_time, 1)
        end
    else
        if speclist_anim.visible and not speclist_anim.fading_out then
            speclist_anim.fading_out = true
        end
        if speclist_anim.fading_out then
            speclist_anim.anim_progress = math.max(speclist_anim.anim_progress - dt / speclist_anim.anim_time, 0)
            if speclist_anim.anim_progress <= 0 then
                speclist_anim.visible = false
                speclist_anim.fading_out = false
            end
        end
    end
    speclist_anim.alpha = math.floor(255 * speclist_anim.anim_progress)
    speclist_anim.slide_offset = (1 - speclist_anim.anim_progress) * 25
end

local function update_spectator_list()
    spectators = {}
    local local_pawn = get_local_pawn()
    if local_pawn == 0 then return end

    for i = 0, 64 do
        local controller = get_entity_list_entry(i)
        if controller ~= 0 then
            if is_spectating_me(controller, local_pawn) then
                table.insert(spectators, get_name(controller))
            end
        end
    end
end

local function draw_spectators()
    local should_show =  MenuLib.get_value("misc_speclist")
    update_speclist_anim(should_show)

    if not speclist_anim.visible and not speclist_anim.fading_out then return end

    local sw, sh = render.get_viewport_size()
    local x, y = speclist_drag_x, speclist_drag_y + speclist_anim.slide_offset
    local box_width = 220
    local header_height = 28
    local entry_height = 22
    local box_radius = 8

    local bg_r, bg_g, bg_b, bg_a = table.unpack(MenuLib.get_value("speclist_bg_color"))
    local border_r, border_g, border_b, border_a = table.unpack(MenuLib.get_value("speclist_outline_color"))
    local text_r, text_g, text_b, text_a = table.unpack(MenuLib.get_value("speclist_text_color"))
    local header_r, header_g, header_b, header_a = table.unpack(MenuLib.get_value("speclist_header_color"))
    local border_a = 180
    local text_a = 255

    local count = #spectators
    local box_height = header_height + (count > 0 and (count * entry_height) or entry_height)

    local alpha = speclist_anim.alpha

    render.draw_rectangle(x + 3, y + 3, box_width, box_height, 0, 0, 0, math.floor(80 * (alpha / 255)), box_radius, true)
    render.draw_rectangle(x, y, box_width, box_height, bg_r, bg_g, bg_b, math.floor(bg_a * (alpha / 255)), box_radius, true)
    render.draw_rectangle(x, y, box_width, box_height, border_r, border_g, border_b, math.floor(border_a * (alpha / 255)), box_radius, false)
    render.draw_rectangle(x, y, box_width, header_height, header_r, header_g, header_b, math.floor(header_a * (alpha / 255)), box_radius, true)
    render.draw_text(font, "Spectators", x + 16, y + 6, 255, 255, 255, alpha, 1, 0, 0, 0, math.floor(180 * (alpha / 255)))

    if count == 0 then
        render.draw_text(font, "None", x + 16, y + header_height + 4, text_r, text_g, text_b, math.floor(180 * (alpha / 255)), 1, 0, 0, 0, math.floor(120 * (alpha / 255)))
    else
        for i, name in ipairs(spectators) do
            render.draw_text(font, name, x + 16, y + header_height + (i - 1) * entry_height + 4, text_r, text_g, text_b, math.floor(text_a * (alpha / 255)), 1, 0, 0, 0, math.floor(120 * (alpha / 255)))
        end
    end
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

local function draw_bomb_panel()
    bomb_panel_alpha = math.lerp(bomb_panel_alpha, bomb_panel_target_alpha, animation_speed)
    bomb_panel_timer_bar_width = math.lerp(bomb_panel_timer_bar_width, bomb_panel_target_bar_width, animation_speed)
    if math.abs(bomb_panel_alpha - bomb_panel_target_alpha) < 1 then bomb_panel_alpha = bomb_panel_target_alpha end
    if math.abs(bomb_panel_timer_bar_width - bomb_panel_target_bar_width) < 1 then bomb_panel_timer_bar_width = bomb_panel_target_bar_width end

    if bomb_panel_alpha > 1 then
        local current_bg_alpha = math.map(bomb_panel_alpha, 0, 255, 0, panel_base_bg_alpha)
        local title_bar_height = 28
        local panel_rounding = 12

        render.draw_rectangle(panel_pos_x, panel_pos_y, panel_width, panel_height, 32, 34, 37, current_bg_alpha, 0, true, panel_rounding)
        render.draw_rectangle(panel_pos_x, panel_pos_y, panel_width, title_bar_height, 24, 25, 28, current_bg_alpha, 0, true, panel_rounding)

        local light_y = panel_pos_y + title_bar_height / 2
        render.draw_circle(panel_pos_x + 23, light_y, 6, 255, 95, 88, 255, 0, true)
        render.draw_circle(panel_pos_x + 43, light_y, 6, 254, 189, 47, 255, 0, true)
        render.draw_circle(panel_pos_x + 63, light_y, 6, 42, 202, 65, 255, 0, true)

        local title = "Bomb Info"
        local title_w = render.measure_text(bomb_panel_font_main, title)
        render.draw_text(
            bomb_panel_font_main,
            title,
            panel_pos_x + (panel_width - title_w) / 2,
            panel_pos_y + 2,
            240, 240, 240, bomb_panel_alpha,
            1, 0, 0, 0, bomb_panel_alpha * 0.8
        )

        local content_y = panel_pos_y + title_bar_height + 8
        if bomb_panel_line1_text and bomb_panel_line1_text ~= "" then
            render.draw_text(bomb_panel_font_main, bomb_panel_line1_text, panel_pos_x + 15, content_y, 220, 220, 220, bomb_panel_alpha, 1, 0, 0, 0, bomb_panel_alpha * 0.8)
        end
        if bomb_panel_line2_text and bomb_panel_line2_text ~= "" then
            render.draw_text(bomb_panel_font_sub, bomb_panel_line2_text, panel_pos_x + 15, content_y + 30, 180, 180, 180, bomb_panel_alpha, 1, 0, 0, 0, bomb_panel_alpha * 0.8)
        end

        local timer_bar_padding_x = 24
        local timer_bar_height = 10
        local timer_bar_rounding = 5
        local timer_bar_y = content_y + 54
        local bar_bg_x = panel_pos_x + timer_bar_padding_x
        local bar_bg_y = timer_bar_y
        local bar_max_width = panel_width - timer_bar_padding_x * 2

        render.draw_rectangle(bar_bg_x, bar_bg_y, bar_max_width, timer_bar_height, 60, 60, 60, bomb_panel_alpha * 0.7, 0, true, timer_bar_rounding)
        if bomb_panel_timer_bar_width > 0 then
            render.draw_rectangle(bar_bg_x, bar_bg_y, bomb_panel_timer_bar_width, timer_bar_height, bomb_panel_timer_bar_color.r, bomb_panel_timer_bar_color.g, bomb_panel_timer_bar_color.b, bomb_panel_alpha, 0, true, timer_bar_rounding)
        end
    end
end




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

local function update_bomb_panel()
    if not MenuLib.get_value("misc_c4timer") then
        bomb_panel_target_alpha = 0
        bomb_panel_target_bar_width = 0
        bomb_panel_bomb_plant_time_ms = nil
        bomb_panel_has_logged_site_id = false
        bomb_panel_line1_text = ""
        bomb_panel_line2_text = ""
        return
    end

    if not proc.is_attached() or proc.did_exit() then
        bomb_panel_target_alpha = 0
        return
    end

    if not bomb_panel_client_dll then
        bomb_panel_client_dll = proc.find_module("client.dll")
        if not bomb_panel_client_dll then
            bomb_panel_target_alpha = 0
            return
        end
    end

    local is_planted = proc.read_int8(bomb_panel_client_dll + offsets.dwPlantedC4 - 0x8) > 0

    if is_planted then
        bomb_panel_target_alpha = 255
        if bomb_panel_bomb_plant_time_ms == nil then bomb_panel_bomb_plant_time_ms = time.unix_ms() end

        local cplantedc4_ptr = proc.read_int64(bomb_panel_client_dll + offsets.dwPlantedC4)
        local cplantedc4 = proc.read_int64(cplantedc4_ptr)
        if cplantedc4 == 0 then return end

        local elapsed_ms = time.unix_ms() - bomb_panel_bomb_plant_time_ms
        local time_left = (40000 - elapsed_ms) / 1000

        if time_left < 0 then
            bomb_panel_line1_text = "Bomb Has Exploded!"
            bomb_panel_line1_color = { r = 255, g = 0, b = 0 }
            bomb_panel_line2_text = ""
            bomb_panel_target_bar_width = 0
            return
        end
        local is_defused = proc.read_int8(cplantedc4 + offsets.m_bBombDefused) > 0
        if is_defused then
            bomb_panel_line1_text = "Bomb Successfully Defused"
            bomb_panel_line1_color = { r = 0, g = 255, b = 100 }
            bomb_panel_line2_text = ""
            bomb_panel_target_bar_width = 0
            bomb_panel_bomb_plant_time_ms = nil
            return
        end
        local site_id = proc.read_int32(cplantedc4 + offsets.m_nBombSite)
        if not bomb_panel_has_logged_site_id then
            engine.log("DEBUG: Bomb site ID read from memory: " .. tostring(site_id), 255, 255, 0, 255)
            bomb_panel_has_logged_site_id = true
        end
        local site_name = "A"
        if site_id == 1 then site_name = "B" end
        local is_being_defused = proc.read_int8(cplantedc4 + offsets.m_bBeingDefused) > 0
        bomb_panel_line1_text = "Bomb Planted on Site " .. site_name
        bomb_panel_line1_color = { r = 255, g = 255, b = 255 }
        if is_being_defused then
            bomb_panel_line1_text = bomb_panel_line1_text .. " | DEFUSING"
            bomb_panel_line1_color = { r = 100, g = 150, b = 255 }
        end
        bomb_panel_line2_text = string.format("Time left: %.1fs", time_left)
        bomb_panel_target_bar_width = math.map(time_left, 40, 0, panel_width - 30, 0)
        if time_left <= 5 then
            bomb_panel_timer_bar_color = { r = 255, g = 50, b = 50 }
        elseif time_left <= 10 then
            bomb_panel_timer_bar_color = { r = 255, g = 165, b = 0 }
        else
            bomb_panel_timer_bar_color = { r = 0, g = 200, b = 80 }
        end
    else
        bomb_panel_target_alpha = 0
        bomb_panel_target_bar_width = 0
        bomb_panel_bomb_plant_time_ms = nil
        bomb_panel_has_logged_site_id = false
        bomb_panel_line1_text = ""
        bomb_panel_line2_text = ""
    end
end

local bomb_plant_time = nil          
local is_bomb_planted_previously = false 


function get_c4_screen_position(client_dll)
    local c4_ptr = proc.read_int64(client_dll + offsets.dwPlantedC4)
    if not c4_ptr or c4_ptr == 0 then return nil end
    local planted_c4 = proc.read_int64(c4_ptr)
    if planted_c4 == 0 then return nil end
    local c4_node = proc.read_int64(planted_c4 + offsets.m_pGameSceneNode)
    if c4_node == 0 then return nil end
    local c4_origin_3d = vec3.read_float(c4_node + offsets.m_vecAbsOrigin)
    if c4_origin_3d.x == 0 and c4_origin_3d.y == 0 then return nil end
    local view_matrix = {}
    for i = 0, 15 do table.insert(view_matrix, proc.read_float(client_dll + offsets.dwViewMatrix + (i * 4))) end
    return world_to_screen(view_matrix, c4_origin_3d)
end


function handle_c4_esp()
    if not MenuLib.get_value("esp_bomb") then return end
    if not proc.is_attached() or proc.did_exit() then
        return
    end
    local client_dll = proc.find_module("client.dll")
    if not client_dll or client_dll == 0 then
        return
    end
    local c4_screen_pos = get_c4_screen_position(client_dll)
    if c4_screen_pos then
        local r, g, b, a = table.unpack(MenuLib.get_value("esp_bomb_color"))
        local box_size = 2
        local text = "BOMB"
        local text_width, _ = render.measure_text(DisplaySystem.fonts.welcome, text)
        render.draw_text(DisplaySystem.fonts.welcome, text, c4_screen_pos.x - (text_width / 2), c4_screen_pos.y - 25, r, g, b, a, 2, 0,0,0,150)
    end
end


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

function trigger_click_mouse()
    local shot_delay = MenuLib.get_value("trigger_delay")
    
    trigger_schedule_action(shot_delay, function()
        input.simulate_mouse(0, 0, 2) 
        trigger_schedule_action(50, function()
             input.simulate_mouse(0, 0, 4)
        end)
    end)
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








engine.register_on_engine_tick(function()
 local is_design_mode = MenuLib.get_value("design_mode")
    -- if not (watermark_dragging or speclist_dragging or bombpanel_dragging) then
    --     watermark_drag_x, watermark_drag_y = parse_pos(MenuLib.get_value("pos_watermark"))
    --     speclist_drag_x, speclist_drag_y = parse_pos(MenuLib.get_value("pos_speclist"))
    --     bombpanel_drag_x, bombpanel_drag_y = parse_pos(MenuLib.get_value("pos_bomb"))
    -- end



   



    

    -- config.espEnabled = ui_state.esp_checkbox and ui_state.esp_checkbox:get() or false
    -- config.skeletonRendering = ui_state.skeleton_checkbox and ui_state.skeleton_checkbox:get() or false
    -- config.boxRendering = ui_state.espbox_checkbox and ui_state.espbox_checkbox:get() or false
    -- config.nameRendering = ui_state.espname_checkbox and ui_state.espname_checkbox:get() or false
    -- config.moneyRendering = ui_state.moneyesp_checkbox and ui_state.moneyesp_checkbox:get() or false 

       if not MenuLib.get_value("esp_enabled") then
        return
    end

    if not proc.is_attached() or proc.did_exit() then
        return
    end

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

                            if health > 0 and health <= 100 and team ~= local_team then
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
                                        if MenuLib.get_value("esp_money") then
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

                                        render_entity_info(entity_to_render)
                                        
                                        local skeleton_mode = MenuLib.get_value("esp_skeleton_mode")
                                        if skeleton_mode > 1 then
                                             local bones_2d = {}
                                             for name, index in pairs(BONE_MAP) do
                                                 local bone_3d = vec3.read_float(bone_array_ptr + index * 32)
                                                 if bone_3d then bones_2d[name] = world_to_screen(view_matrix, bone_3d) end
                                             end
                                             if skeleton_mode == 2 then draw_skeleton(bones_2d)
                                             elseif skeleton_mode == 3 then
                                                local scale = math.clamp(box_height / 400, 0.2, 1.1)
                                                draw_circular_skeleton(bones_2d, scale)
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
end)


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



function draw_skeleton(bones_2d)
    local r, g, b, a = table.unpack(MenuLib.get_value("esp_skeleton_color"))
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



function draw_circular_skeleton(bones_2d, scale)
    local r, g, b, a = table.unpack(MenuLib.get_value("esp_skeleton_color"))

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


function draw_filled_box(rect, r, g, b, a, is_corner)

    local top_color = { r, g, b, math.floor(a * 0.20) }

    local bottom_color = { 
        math.floor(r * 0.1), 
        math.floor(g * 0.1), 
        math.floor(b * 0.1), 
        math.floor(a * 0.40) 
    }

    
    local colors_table = {
        top_color,
        bottom_color 
    }
    

    render.draw_gradient_rectangle(rect.left, rect.top, (rect.right - rect.left), (rect.bottom - rect.top), colors_table, 0)

    local outline_thickness = 1.5
    render.draw_rectangle(rect.left - outline_thickness, rect.top - outline_thickness, (rect.right - rect.left) + outline_thickness*2, (rect.bottom - rect.top) + outline_thickness*2, 0,0,0,a, outline_thickness, false)
    
    if is_corner then
        local cs = (rect.right - rect.left) * 0.25
        render.draw_line(rect.left, rect.top, rect.left + cs, rect.top, r, g, b, a, outline_thickness)
        render.draw_line(rect.left, rect.top, rect.left, rect.top + cs, r, g, b, a, outline_thickness)
        render.draw_line(rect.right, rect.top, rect.right - cs, rect.top, r, g, b, a, outline_thickness)
        render.draw_line(rect.right, rect.top, rect.right, rect.top + cs, r, g, b, a, outline_thickness)
        render.draw_line(rect.left, rect.bottom, rect.left + cs, rect.bottom, r, g, b, a, outline_thickness)
        render.draw_line(rect.left, rect.bottom, rect.left, rect.bottom - cs, r, g, b, a, outline_thickness)
        render.draw_line(rect.right, rect.bottom, rect.right - cs, rect.bottom, r, g, b, a, outline_thickness)
        render.draw_line(rect.right, rect.bottom, rect.right, rect.bottom - cs, r, g, b, a, outline_thickness)
    else
        render.draw_rectangle(rect.left, rect.top, (rect.right - rect.left), (rect.bottom - rect.top), r, g, b, a, outline_thickness, false)
    end
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




function render_entity_info(entity)

    local function draw_safe_text(font, text, x, y, color_table, alignment)
        if not text or text == "" or not color_table then return end
        
        local r, g, b, a = table.unpack(color_table)
        if not (r and g and b and a) then r, g, b, a = 255, 255, 255, 255 end
        
        local text_w, _ = render.measure_text(font, text)
        local draw_x = x
        if alignment == "center" then
            draw_x = x - (text_w / 2)
        elseif alignment == "right" then
            draw_x = x - text_w
        end
        
        render.draw_text(font, text, draw_x, y, r, g, b, a, 1.5, 0, 0, 0, a)
    end
    
    local rect = entity.rect
    local box_height = rect.bottom - rect.top
    if box_height <= 10 then return end

    local box_width = rect.right - rect.left
    local box_center_x = rect.left + (box_width / 2)
    local padding = 5
    local bar_thickness = 4
    local text_height = 12
    local rounding = 4
    local default_color = {255, 255, 255, 255}

    if MenuLib.get_value("esp_box") then
        local box_color = MenuLib.get_value("esp_box_color") or default_color
        local r, g, b, a = table.unpack(box_color)
        local box_type_index = MenuLib.get_value("esp_box_type")
        local thickness = 1.5
        if box_type_index == 1 then 
            render.draw_rectangle(rect.left - 1, rect.top - 1, box_width + 2, box_height + 2, 0, 0, 0, a, thickness, false, 0)
            render.draw_rectangle(rect.left, rect.top, box_width, box_height, r, g, b, a, thickness, false, 0)
        elseif box_type_index == 2 then 
            local corner_size = math.max(4, box_height * 0.2)
            local function draw_corner_line(x1, y1, x2, y2)
                render.draw_line(x1, y1, x2, y2, 0, 0, 0, a, thickness + 2)
                render.draw_line(x1, y1, x2, y2, r, g, b, a, thickness)
            end
            draw_corner_line(rect.left, rect.top, rect.left + corner_size, rect.top); draw_corner_line(rect.left, rect.top, rect.left, rect.top + corner_size)
            draw_corner_line(rect.right, rect.top, rect.right - corner_size, rect.top); draw_corner_line(rect.right, rect.top, rect.right, rect.top + corner_size)
            draw_corner_line(rect.left, rect.bottom, rect.left + corner_size, rect.bottom); draw_corner_line(rect.left, rect.bottom, rect.left, rect.bottom - corner_size)
            draw_corner_line(rect.right, rect.bottom, rect.right - corner_size, rect.bottom); draw_corner_line(rect.right, rect.bottom, rect.right, rect.bottom - corner_size)
        elseif box_type_index == 3 then 
            draw_filled_box(rect, r, g, b, a, false)
        end
    end

    local hp_percent = math.clamp(entity.health / 100, 0, 1)
    local health_bar_height = box_height * hp_percent
    local hp_r, hp_g = math.floor(255 * (1 - hp_percent)), math.floor(255 * hp_percent)
    render.draw_gradient_rectangle(rect.left - bar_thickness - padding, rect.top, bar_thickness, box_height, {{20,20,20,180},{40,40,40,180}}, rounding)
    if health_bar_height > 0 then
        render.draw_gradient_rectangle(rect.left - bar_thickness - padding, rect.top + (box_height - health_bar_height), bar_thickness, health_bar_height, {{hp_r, hp_g, 0, 255}, {hp_r * 0.7, hp_g * 0.7, 0, 255}}, rounding)
    end
    if hp_percent < 0.95 and box_height > 40 then
         draw_safe_text(esp_fonts.weapon, tostring(entity.health), rect.left - padding - bar_thickness/2, rect.top + (box_height-health_bar_height) - text_height - 2, default_color, "center")
    end

    if MenuLib.get_value("esp_name") and entity.name and entity.name ~= "" then
        local name_color = MenuLib.get_value("esp_name_color") or default_color
        draw_safe_text(esp_fonts.name, entity.name, box_center_x, rect.top - text_height - padding, name_color, "center")
    end
    
    local bottom_y_pos = rect.bottom + padding
    if entity.armor and entity.armor > 0 then
        local ap_percent = math.clamp(entity.armor / 100, 0, 1)
        local armor_bar_width = box_width * ap_percent
        render.draw_gradient_rectangle(rect.left, bottom_y_pos, box_width, bar_thickness, {{20,20,20,180},{40,40,40,180}}, rounding)
        render.draw_gradient_rectangle(rect.left, bottom_y_pos, armor_bar_width, bar_thickness, {{100, 150, 255, 255}, {80, 120, 225, 255}}, rounding)
        bottom_y_pos = bottom_y_pos + bar_thickness + 2
    end
    
    local weapon_text = ""
    if MenuLib.get_value("esp_player_weapon") and entity.weapon and entity.weapon ~= "" then
        weapon_text = entity.weapon
    end
    local distance_text = ""
    if MenuLib.get_value("esp_distance") and entity.distance then
        distance_text = string.format("[%dM]", math.floor(entity.distance / 50))
    end
    local full_info_string = (weapon_text ~= "" and distance_text ~= "") and (weapon_text .. " " .. distance_text) or (weapon_text .. distance_text)
    
    draw_safe_text(esp_fonts.weapon, full_info_string, box_center_x, bottom_y_pos, default_color, "center")

    local flags_y = rect.top
    local flags_to_draw = {}
    if MenuLib.get_value("esp_money") and entity.money and entity.money > -1 then
        table.insert(flags_to_draw, { text = "$" .. entity.money, color =  MenuLib.get_value("esp_money_color") })
    end
    if MenuLib.get_value("esp_scoped_flag") and entity.is_scoped then
        table.insert(flags_to_draw, { text = "ZOOM", color = {150, 200, 255, 255} })
    end
    if MenuLib.get_value("esp_flashed_flag") and entity.is_flashed then
        table.insert(flags_to_draw, { text = "FLASHED", color = {255, 255, 255, 255} })
    end

    for _, flag in ipairs(flags_to_draw) do
        local color = flag.color or default_color
        local _, text_h = render.measure_text(esp_fonts.weapon, flag.text)
        
        local r, g, b, a = table.unpack(color)
        render.draw_rectangle(rect.right + padding, flags_y, 3, text_h, r, g, b, a, 0, true, 2)

        draw_safe_text(esp_fonts.weapon, flag.text, rect.right + padding + 6, flags_y - 2, color, "left")
        flags_y = flags_y + text_h + padding
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
    view_line_color = {255, 255, 0, 255}
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
                            local yaw = proc.read_float(pawn_addr + offsets.m_angEyeAngles + 4)
                            local color = (team ~= local_team) and radar.enemy_color or radar.team_color
                            table.insert(g.entities, {pos = {x=pos.x, y=pos.y}, yaw=yaw, color=color})
                        end
                    end
                end
            end
        end
    end
end

local function draw_radar()
    local center_x, center_y = radar.x + radar.size / 2, radar.y + radar.size / 2
    
    local rotation_offset = 90 + radar.rotation_angle
    local angle_rad = math.rad(g.local_yaw + rotation_offset)

    render.draw_rectangle(radar.x, radar.y, radar.size, radar.size, radar.bg_color[1], radar.bg_color[2], radar.bg_color[3], radar.bg_color[4], 0, true)
    render.draw_rectangle(radar.x, radar.y, radar.size, radar.size, radar.outline_color[1], radar.outline_color[2], radar.outline_color[3], radar.outline_color[4], 1, false)

    render.draw_circle(center_x, center_y, 4, radar.local_player_color[1], radar.local_player_color[2], radar.local_player_color[3], radar.local_player_color[4], 0, true)

    for _, ent in ipairs(g.entities) do
        local dx, dy = ent.pos.x - g.local_pos.x, ent.pos.y - g.local_pos.y
        local rot_x = dy * math.cos(angle_rad) - dx * math.sin(angle_rad)
        local rot_y = dy * math.sin(angle_rad) + dx * math.cos(angle_rad)
        local draw_x = center_x - (rot_x * radar.scale)
        local draw_y = center_y + (rot_y * radar.scale)
        
        if draw_x > radar.x and draw_x < radar.x + radar.size and draw_y > radar.y and draw_y < radar.y + radar.size then
            local c = ent.color
            render.draw_circle(draw_x, draw_y, 4, c[1], c[2], c[3], c[4], 0, true)
            
            local ent_angle_rad = math.rad(ent.yaw + rotation_offset)
            local line_x = draw_x + math.cos(ent_angle_rad) * 15
            local line_y = draw_y + math.sin(ent_angle_rad) * 15
            local lc = radar.view_line_color
            render.draw_line(draw_x, draw_y, line_x, line_y, lc[1], lc[2], lc[3], lc[4], 1.5)
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

    return (a << 24) | (r << 16) | (g << 8) | b
end

function update_glow()
    if not MenuLib.get_value("esp_glow") then return end
    if not client_base then return end
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
        if not list_entry or list_entry == 0 then goto continue end

        local controller_addr = proc.read_int64(list_entry + 112 * (i & 0x1FF))
        if not controller_addr or controller_addr == 0 then goto continue end

        local pawn_handle = proc.read_int32(controller_addr + offsets.m_hPlayerPawn)
        if not pawn_handle or pawn_handle == -1 or pawn_handle == 0 then goto continue end
        
        local pawn_handle_masked = pawn_handle & 0x7FFF
        local list_entry2 = proc.read_int64(entity_list + 0x8 * ((pawn_handle_masked >> 9) & 0x7F) + 16)
        if not list_entry2 or list_entry2 == 0 then goto continue end
        
        local pawn_addr = proc.read_int64(list_entry2 + 112 * (pawn_handle_masked & 0x1FF))
        if not pawn_addr or pawn_addr == 0 or pawn_addr == local_player then goto continue end

        local life_state = proc.read_int32(pawn_addr + offsets.m_lifeState)
        if life_state ~= 256 then goto continue end

        local team_num = proc.read_int32(pawn_addr + offsets.m_iTeamNum)
        if team_num == local_team_num then goto continue end

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

        ::continue::
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



function handle_world_esp()
    local should_draw_weapons = MenuLib.get_value("esp_dropped_weapons")
    local should_draw_projectiles = MenuLib.get_value("esp_projectiles")
    local should_draw_chickens = MenuLib.get_value("esp_chickens")

    if not should_draw_weapons and not should_draw_projectiles and not should_draw_chickens then
        return
    end

    if not proc.is_attached() or proc.did_exit() then return end

    local client_dll = proc.find_module("client.dll")
    if not client_dll or client_dll == 0 then return end
    
    local view_matrix = {}
    for i = 0, 15 do table.insert(view_matrix, proc.read_float(client_dll + offsets.dwViewMatrix + (i * 4))) end

    local entity_list = proc.read_int64(client_dll + offsets.dwEntityList)
    if not entity_list or entity_list == 0 then return end

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
            if not screen_pos then goto continue_loop end
            
            if should_draw_weapons and owner_handle == -1 then
                local weapon_name = WEAPONS_MAP[designer_name]
                if weapon_name then
                    draw_text_with_outline(esp_font, weapon_name, screen_pos.x, screen_pos.y, 255, 255, 255, 255)
                    goto continue_loop
                end
            end

            if should_draw_projectiles then
                local projectile_name = PROJECTILES_MAP[designer_name]
                if projectile_name then
                    draw_text_with_outline(esp_font, projectile_name, screen_pos.x, screen_pos.y, 255, 200, 100, 255)
                    goto continue_loop
                end
            end
            
            if should_draw_chickens and designer_name == "chicken" then
                draw_text_with_outline(esp_font, "Chicken", screen_pos.x, screen_pos.y, 255, 255, 0, 255)
            end
        end
        
        ::continue_loop::
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
    head = 6, neck = 5, spine = 4, pelvis = 0,
    left_shoulder = 8, left_elbow = 9, left_hand = 10,
    right_shoulder = 13, right_elbow = 14, right_hand = 15,
    left_hip = 22, left_knee = 23, left_ankle = 24,
    right_hip = 25, right_knee = 26, right_ankle = 27
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
        locked_target_pawn = 0,
        lock_lost_time = 0    
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
        local min_delay_id = weapon_category .. "_trigger_dynamic_delay_min"
        local max_delay_id = weapon_category .. "_trigger_dynamic_delay_max"
        
        local min_delay = MenuLib.get_value(min_delay_id)
        local max_delay = MenuLib.get_value(max_delay_id)

        if min_delay > max_delay then min_delay = max_delay end
        shot_delay = math.random(min_delay, max_delay)
    else
        local delay_id = weapon_category .. "_trigger_delay"
        shot_delay = MenuLib.get_value(delay_id)
    end
    
    local rapid_fire_key_id = weapon_category .. "_trigger_rapid_key"
    if is_keybind_active(rapid_fire_key_id) then
        local reduction_id = weapon_category .. "_trigger_rapid_reduction"
        local reduction_amount = MenuLib.get_value(reduction_id)
        shot_delay = shot_delay - reduction_amount
    end
    
    shot_delay = math.max(0, shot_delay) 
    last_trigger_delay = shot_delay 

    trigger_schedule_action(shot_delay, function()
        input.simulate_mouse(0, 0, 2)
        trigger_schedule_action(50, function()
             input.simulate_mouse(0, 0, 4)
        end)
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

function handle_aimbot(game, local_player_index, current_weapon_category)
    if not current_weapon_category then return end
    
    local enabled_id = current_weapon_category .. "_legit_enabled"
    local key_id = current_weapon_category .. "_legit_key"
    local fov_id = current_weapon_category .. "_legit_fov"
    local draw_fov_id = current_weapon_category .. "_legit_draw_fov"
    local vis_check_id = current_weapon_category .. "_legit_vis_check"
    local hitbox_id = current_weapon_category .. "_legit_hitbox"
    local smoothing_id = current_weapon_category .. "_legit_smoothing"
    
    if not MenuLib.get_value(enabled_id) or not is_keybind_active(key_id) then return end

    local screen_width, screen_height = render.get_viewport_size()
    local crosshair_x, crosshair_y = screen_width / 2, screen_height / 2
    local fov = MenuLib.get_value(fov_id)

    if MenuLib.get_value(draw_fov_id) then
        render.draw_circle(crosshair_x, crosshair_y, fov, 255, 255, 255, 30, 1, false)
    end
    
    local best_target_entity, best_target_dist = nil, fov

    for _, entity in ipairs(game.entities) do
        if entity.team ~= game.local_team and (not MenuLib.get_value(vis_check_id) or is_player_visible(entity.pawn_address, local_player_index)) then
            local hitbox_selection = MenuLib.get_value(hitbox_id)
            local bone_to_use
            if hitbox_selection == 1 then bone_to_use = entity.bones.head
            elseif hitbox_selection == 2 then bone_to_use = entity.bones.neck
            elseif hitbox_selection == 3 then bone_to_use = entity.bones.spine
            else bone_to_use = entity.bones.pelvis end
            
            if bone_to_use then
                local target_pos_2d = world_to_screen(game.view_matrix, bone_to_use)
                if target_pos_2d then
                    local dist_from_crosshair = math.sqrt((target_pos_2d.x - crosshair_x)^2 + (target_pos_2d.y - crosshair_y)^2)
                    if dist_from_crosshair < best_target_dist then
                        best_target_dist = dist_from_crosshair
                        best_target_entity = entity
                    end
                end
            end
        end
    end
    
    if best_target_entity then
        local hitbox_selection = MenuLib.get_value(hitbox_id)
        local target_pos_3d
        if hitbox_selection == 1 then target_pos_3d = best_target_entity.bones.head
        elseif hitbox_selection == 2 then target_pos_3d = best_target_entity.bones.neck
        elseif hitbox_selection == 3 then target_pos_3d = best_target_entity.bones.spine
        else target_pos_3d = best_target_entity.bones.pelvis end
        
        local pred_enabled_id = current_weapon_category .. "_legit_prediction_enabled"
        local pred_key_id = current_weapon_category .. "_legit_prediction_key"

        if MenuLib.get_value(pred_enabled_id) and is_keybind_active(pred_key_id) then
            local h_pred_id = current_weapon_category .. "_legit_prediction_h"
            local v_pred_id = current_weapon_category .. "_legit_prediction_v"
            
            local h_strength = MenuLib.get_value(h_pred_id)
            local v_strength = MenuLib.get_value(v_pred_id)
            
            local enemy_velocity = vec3.read_float(best_target_entity.pawn_address + offsets.m_vecVelocity)
            
            target_pos_3d.x = target_pos_3d.x + (enemy_velocity.x * h_strength)
            target_pos_3d.y = target_pos_3d.y + (enemy_velocity.y * h_strength)
            target_pos_3d.z = target_pos_3d.z + (enemy_velocity.z * v_strength)
        end
        
        local smoothing_factor = MenuLib.get_value(smoothing_id)
        if smoothing_factor > 0 then
            local target_2d = world_to_screen(game.view_matrix, target_pos_3d)
            if not target_2d then return end
            
            local distance_x = target_2d.x - crosshair_x
            local distance_y = target_2d.y - crosshair_y
            
            if math.abs(distance_x) > 1 or math.abs(distance_y) > 1 then
                local move_x = distance_x / smoothing_factor
                local move_y = distance_y / smoothing_factor
                input.simulate_mouse(math.floor(move_x + 0.5), math.floor(move_y + 0.5), 1)
            end
        end
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
    local hitchance_id = weapon_category .. "_trigger_hitchance"
    local team_check_id = weapon_category .. "_trigger_team_check"

    if not MenuLib.get_value(enabled_id) or not is_keybind_active(key_id) or input.is_menu_open() then return end
    
    trigger_process_pending_actions()
    if (winapi.get_tickcount64() - trigger_last_shot_time) < 100 then return end

    local entityId = proc.read_int32(game.local_pawn + offsets.m_iIDEntIndex)
    if entityId <= 0 then return end

    local entListEntry = proc.read_int64(game.entity_list + 0x8 * (math.floor(entityId / 512)) + 0x10)
    if entListEntry == 0 then return end
    
    local entity = proc.read_int64(entListEntry + 112 * (entityId % 512))
    if entity == 0 then return end

    local entityTeam = proc.read_int32(entity + offsets.m_iTeamNum)
    local entityHp = proc.read_int32(entity + offsets.m_iHealth)
    local ignore_teammates = MenuLib.get_value(team_check_id)

    if entityHp > 0 and (not ignore_teammates or entityTeam ~= game.local_team) and entityTeam ~= 0 then
        local current_hitchance = trigger_get_current_hitchance()
        local required_hitchance = MenuLib.get_value(hitchance_id)
        
        if current_hitchance >= required_hitchance then
            trigger_click_mouse(weapon_category)
            trigger_last_shot_time = winapi.get_tickcount64()
        end
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




local function handle_anti_aim()
    if not MenuLib.get_value("aa_enabled") or input.is_menu_open() or is_keybind_active("aa_disable_key") then
        return
    end

    local client_dll = proc.find_module("client.dll")
    if not client_dll or client_dll == 0 then return end
    
    local local_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if not local_pawn or local_pawn == 0 then return end


        local real_view_angles = vec3.read_float(game.client_dll + offsets.dwViewAngles)
    local fake_angles = real_view_angles:clone()


    local pitch_mode = MenuLib.get_value("aa_pitch_mode")
    if pitch_mode == 1 then 
        fake_angles.x = 89.0
    elseif pitch_mode == 2 then 
        fake_angles.x = -89.0
    elseif pitch_mode == 3 then 
        fake_angles.x = math.random(-89, 89)
    else 
        fake_angles.x = real_view_angles.x
    end

    local yaw_mode = MenuLib.get_value("aa_yaw_mode")
    local base_yaw = real_view_angles.y 
    
    if yaw_mode == 1 then 
        base_yaw = real_view_angles.y + 180.0
    elseif yaw_mode == 2 then 
        _G.g_spin_yaw = _G.g_spin_yaw + MenuLib.get_value("aa_spin_speed")
        if _G.g_spin_yaw > 180 then _G.g_spin_yaw = -180 end 
        if _G.g_spin_yaw < -180 then _G.g_spin_yaw = 180 end
        base_yaw = _G.g_spin_yaw
    end
    

    base_yaw = base_yaw + MenuLib.get_value("aa_yaw_additive")
    if MenuLib.get_value("aa_jitter_enabled") then
        local jitter_amount = MenuLib.get_value("aa_jitter_range")
        base_yaw = base_yaw + (math.random() * 2 * jitter_amount) - jitter_amount
    end

    fake_angles.y = base_yaw
    

    fake_angles = fake_angles:normalize_angles()

    for i = 1, 25000 do
    vec3.write_float(game.local_pawn + offsets.v_angle, fake_angles:normalize_angles())
    end
end



function main()
    if not proc.is_attached() then
        engine.log("Anti-Aim Error: Please attach to cs2.exe first.", 255, 100, 100, 255)
        return
    end
    
    engine.register_on_engine_tick(handle_anti_aim)
    engine.log("Dynamic Anti-Aim (Stable Final Version) Loaded.", 255, 100, 100, 255)
end

main()



function patch_byte(address, size, patch_bytes)
    if type(address) ~= "number" or type(size) ~= "number" or type(patch_bytes) ~= "table" then
        engine.log("Invalid parameters passed to patch()", 255, 0, 0, 255)
        return
    end

    if #patch_bytes ~= size then
        engine.log("Patch size mismatch: expected " .. size .. ", got " .. #patch_bytes, 255, 255, 0, 255)
        return
    end
    
    for i = 0, size - 1 do
        local byte = patch_bytes[i + 1]
        if type(byte) ~= "number" or byte < 0 or byte > 255 then
            engine.log("Invalid byte at index " .. (i + 1) .. ": " .. tostring(byte), 255, 0, 0, 255)
            return
        end

        proc.write_int8(address + i, byte)
    end

    engine.log(string.format("Patched %d bytes at 0x%X", size, address), 0, 255, 0, 255)
end

if client_dll then
    local address = client_dll + 0x8080F7
    local size = 2
    local patch = { 0x74, 0x10 }
    patch_byte(address, 2, patch)
end


local function update_thirdperson_view()
    if not proc.is_attached() or not client_dll then
        return
    end

if not MenuLib.get_value("misc_thirdperson") then
        proc.write_int8(client_dll + offsets.dwCSGOInput + offsets.m_bCameraInThirdPerson, 0)
        return 
    end


    if is_keybind_active("misc_thirdperson_key") then
        proc.write_int8(client_dll + offsets.dwCSGOInput + offsets.m_bCameraInThirdPerson, 100)

    else

        proc.write_int8(client_dll + offsets.dwCSGOInput + offsets.m_bCameraInThirdPerson, 0)
    end
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
    handle_movement()
update_thirdperson_view()
handle_ragebot()
handle_world_esp()
 handle_dragging()
    update_data()
    update_dynamic_scale()
    draw_radar()
    update_spectator_list()
    draw_spectators()
    update_bomb_panel()
    draw_bomb_panel()
    handle_anti_flash() 
    handle_c4_esp()
    handle_nightmode()
    handle_smoke_modulator()



update_glow()
    draw_feature_indicators()
end)




local log_once = {}
return MenuLib
end