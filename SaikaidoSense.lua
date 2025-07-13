local ui_state = {}

local tab = gui.get_tab("lua")
ui_state.panel = tab:create_panel("SaikaidoSense", true)

ui_state.watermark_unibox = ui_state.panel:add_checkbox("UNI API")
ui_state.watermark_cs2box = ui_state.panel:add_checkbox("CS2")
ui_state.watermark_checkbox = ui_state.panel:add_checkbox("Enable Watermark")
ui_state.crs_checkbox = ui_state.panel:add_checkbox("Enable Crosshair")
ui_state.utft_checkbox = ui_state.panel:add_checkbox("MISC")

ui_state.panel:add_text("-----Watermark Settings")
ui_state.panel:add_text("Background Color")
ui_state.color_picker = ui_state.panel:add_color_picker("Background Color Picker", 255, 0, 0, 255)
ui_state.color_picker:set(18, 18, 18, 255)
ui_state.panel:add_text("Outline Color")
ui_state.otcolor_picker = ui_state.panel:add_color_picker("Outline Color Picker", 255, 0, 0, 255)
ui_state.otcolor_picker:set(30, 30, 30, 255)
ui_state.panel:add_text("Text Color")
ui_state.txtcolor_picker = ui_state.panel:add_color_picker("Text Color Picker", 255, 255, 255, 255)
ui_state.txtcolor_picker:set(200, 200, 200, 255)

ui_state.panel:add_text("-----Crosshair Settings")
ui_state.panel:add_text("CRS Color")
ui_state.crs_color_picker = ui_state.panel:add_color_picker("Crosshair Color Picker", 255, 255, 255, 255)
ui_state.crs_color_picker:set(255, 255, 255, 255)
ui_state.crs_thickness_slider_int = ui_state.panel:add_slider_int("Thickness Slider", 0, 10, 2)
ui_state.crs_gap_slider_int = ui_state.panel:add_slider_int("Gap Slider", 0, 10, 3)

ui_state.panel:add_text("-----MISC")
ui_state.hitsound_checkbox = ui_state.panel:add_checkbox("Hitsound")
ui_state.hitlog_checkbox = ui_state.panel:add_checkbox("Hitlog")
ui_state.speclist_checkbox = ui_state.panel:add_checkbox("Spectator List")
ui_state.c4timer_checkbox = ui_state.panel:add_checkbox("C4")
ui_state.radar_checkbox = ui_state.panel:add_checkbox("Radar")
ui_state.anti_flash_checkbox = ui_state.panel:add_checkbox("Enable Anti-Flash")

ui_state.panel:add_text("-----Hitlog Settings")
ui_state.panel:add_text("Background Color")
ui_state.htcolor_picker = ui_state.panel:add_color_picker("Hitlog Background Color Picker", 255, 0, 0, 255)
ui_state.htcolor_picker:set(18, 18, 18, 255)
ui_state.panel:add_text("Outline Color")
ui_state.htotcolor_picker = ui_state.panel:add_color_picker("Hitlog Outline Color Picker", 255, 0, 0, 255)
ui_state.htotcolor_picker:set(30, 30, 30, 255)
ui_state.panel:add_text("Text Color")
ui_state.httextcolor_picker = ui_state.panel:add_color_picker("Hitlog Text Color Picker", 255, 255, 255, 255)
ui_state.httextcolor_picker:set(200, 200, 200, 255)

ui_state.panel:add_text("-----Spectator List")
ui_state.panel:add_text("Background Color")
ui_state.speclistcolor_picker = ui_state.panel:add_color_picker("Spectator List Background Color Picker", 255, 0, 0, 255)
ui_state.speclistcolor_picker:set(18, 18, 18, 255)
ui_state.panel:add_text("Outline Color")
ui_state.speclistotcolor_picker = ui_state.panel:add_color_picker("Spectator List Outline Color Picker", 255, 0, 0, 255)
ui_state.speclistotcolor_picker:set(30, 30, 30, 255)
ui_state.panel:add_text("Text Color")
ui_state.speclisttextcolor_picker = ui_state.panel:add_color_picker("Spectator List Text Color Picker", 255, 255, 255, 255)
ui_state.speclisttextcolor_picker:set(200, 200, 200, 255)
ui_state.panel:add_text("Header background Color")
ui_state.speclistheadercolor_picker = ui_state.panel:add_color_picker("Spectator List Header Color Picker", 255, 255, 255, 255)
ui_state.speclistheadercolor_picker:set(200, 200, 200, 255)

ui_state.panel:add_text("-----ESP Settings")
ui_state.esp_checkbox = ui_state.panel:add_checkbox("Enable ESP")
ui_state.skeleton_checkbox = ui_state.panel:add_checkbox("Skeleton")
ui_state.espbox_checkbox = ui_state.panel:add_checkbox("ESP Box")
ui_state.espname_checkbox = ui_state.panel:add_checkbox("ESP Name")
ui_state.glow_checkbox = ui_state.panel:add_checkbox("Glow{MISC Should be enabled}")

ui_state.panel:add_text("Box Color Picker")
ui_state.boxcolor_picker = ui_state.panel:add_color_picker("Box Color Picker", 255, 0, 0, 255)
ui_state.boxcolor_picker:set(18, 18, 18, 255)
ui_state.panel:add_text("Skeleton Color Picker")
ui_state.skeletoncolor_picker = ui_state.panel:add_color_picker("Skeleton Color Picker", 255, 0, 0, 255)
ui_state.skeletoncolor_picker:set(18, 18, 18, 255)
ui_state.panel:add_text("Name Color Picker")
ui_state.espnamecolor_picker = ui_state.panel:add_color_picker("ESP Name Color Picker", 255, 0, 0, 255)
ui_state.espnamecolor_picker:set(18, 18, 18, 255)
ui_state.panel:add_text("CT GLOW")
ui_state.ctglowcolor_picker = ui_state.panel:add_color_picker("CT GLOW", 0, 0, 255, 255)
ui_state.ctglowcolor_picker:set(0, 0, 255, 255)
ui_state.panel:add_text("T GLOW")
ui_state.tglowcolor_picker = ui_state.panel:add_color_picker("T GLOW", 255, 0, 0, 255)
ui_state.tglowcolor_picker:set(255, 0, 0, 255)

ui_state.panel:add_text("-----Design Mode")
ui_state.des_checkbox = ui_state.panel:add_checkbox("Design Mode")
ui_state.desmodedim_slider_int = ui_state.panel:add_slider_int("DIM Slider", 0, 10, 3)

ui_state.confpanel = tab:create_panel("SaikaidoSense Config", true)
ui_state.wtpos = ui_state.confpanel:add_input_text("Input Field", "default")
ui_state.specpos = ui_state.confpanel:add_input_text("DEBUG SHIT DONT TOUCH", "default")
ui_state.bombpanelpos = ui_state.confpanel:add_input_text("Bomb Timer Position", "25,200")

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
ui_state.save_config = ui_state.confpanel:add_button("Save Config", function()
    local config = {
        watermark = {
            enabled = ui_state.watermark_checkbox:get(),
            bg_color = {ui_state.color_picker:get()},
            outline_color = {ui_state.otcolor_picker:get()},
            text_color = {ui_state.txtcolor_picker:get()},
        },
        crosshair = {
            enabled = ui_state.crs_checkbox:get(),
            color = {ui_state.crs_color_picker:get()},
            thickness = ui_state.crs_thickness_slider_int:get(),
            gap = ui_state.crs_gap_slider_int:get(),
        },
        untrusted = {
            enabled = ui_state.utft_checkbox:get(),
            hitsound = ui_state.hitsound_checkbox:get(),
            hitlog = ui_state.hitlog_checkbox:get(),
            speclist_checkbox = ui_state.speclist_checkbox:get(),
            c4timer_checkbox = ui_state.c4timer_checkbox:get(),
            radar_checkbox = ui_state.radar_checkbox:get(),
            anti_flash_checkbox = ui_state.anti_flash_checkbox:get(),
        },
        hitlog = {
            bg_color = {ui_state.htcolor_picker:get()},
            outline_color = {ui_state.htotcolor_picker:get()},
            text_color = {ui_state.httextcolor_picker:get()},
        },
        speclist = {
            bg_color = {ui_state.speclistcolor_picker:get()},
            outline_color = {ui_state.speclistotcolor_picker:get()},
            text_color = {ui_state.speclisttextcolor_picker:get()},
            header_color = {ui_state.speclistheadercolor_picker:get()},
        },
        DEBUG = {
            watermark_position = ui_state.wtpos:get(),
            speclist_position = ui_state.specpos:get(),
            bombpanel_position = ui_state.bombpanelpos:get(),
        },
        esp = {
            espEnabled = ui_state.esp_checkbox:get(),
            skeleton_checkbox = ui_state.skeleton_checkbox:get(),
            espbox_checkbox = ui_state.espbox_checkbox:get(),
            espname_checkbox = ui_state.espname_checkbox:get(),
            glow = ui_state.glow_checkbox:get(),
            boxcolor = {ui_state.boxcolor_picker:get()},
            skeletoncolor = {ui_state.skeletoncolor_picker:get()},
            espnamecolor = {ui_state.espnamecolor_picker:get()},            
            ctglow = {ui_state.ctglowcolor_picker:get()},
            tglow = {ui_state.tglowcolor_picker:get()},
        }
    }
    local json_data = json.stringify(config)
    local ok, ferr = fs.write_to_file("saikaidosense_conf.txt", json_data)
    if ok then
        LogSuccess("Config saved to saikaidosense_conf.txt")
    else
        LogError("Config saved to saikaidosense_conf.txt")
    end
end)

ui_state.load_config = ui_state.confpanel:add_button("Load Config", function()
    if not fs.does_file_exist("saikaidosense_conf.txt") then
        LogError("No configuration file found!")
        return
    end

    local json_config = fs.read_from_file("saikaidosense_conf.txt")
    local config = json.parse(json_config)
    if not config then
        LogError("Failed to load configuration!")
        return
    end

    if config.watermark then
        ui_state.watermark_checkbox:set(config.watermark.enabled)
        if config.watermark.bg_color then
            ui_state.color_picker:set(table.unpack(config.watermark.bg_color))
        end
        if config.watermark.outline_color then
            ui_state.otcolor_picker:set(table.unpack(config.watermark.outline_color))
        end
        if config.watermark.text_color then
            ui_state.txtcolor_picker:set(table.unpack(config.watermark.text_color))
        end
    end

    if config.crosshair then
        ui_state.crs_checkbox:set(config.crosshair.enabled)
        if config.crosshair.color then
            ui_state.crs_color_picker:set(table.unpack(config.crosshair.color))
        end
        if config.crosshair.thickness then
            ui_state.crs_thickness_slider_int:set(config.crosshair.thickness)
        end
        if config.crosshair.gap then
            ui_state.crs_gap_slider_int:set(config.crosshair.gap)
        end
    end

    if config.untrusted then
        ui_state.utft_checkbox:set(config.untrusted.enabled)
        ui_state.hitsound_checkbox:set(config.untrusted.hitsound)
        ui_state.hitlog_checkbox:set(config.untrusted.hitlog)
        ui_state.speclist_checkbox:set(config.untrusted.speclist_checkbox)
        ui_state.anti_flash_checkbox:set(config.untrusted.anti_flash_checkbox)
        if config.untrusted.c4timer_checkbox ~= nil then
            ui_state.c4timer_checkbox:set(config.untrusted.c4timer_checkbox)
        end
        if config.untrusted.radar_checkbox ~= nil then
            ui_state.radar_checkbox:set(config.untrusted.radar_checkbox)
        end
    end

    if config.hitlog then
        if config.hitlog.bg_color then
            ui_state.htcolor_picker:set(table.unpack(config.hitlog.bg_color))
        end
        if config.hitlog.outline_color then
            ui_state.htotcolor_picker:set(table.unpack(config.hitlog.outline_color))
        end
        if config.hitlog.text_color then
            ui_state.httextcolor_picker:set(table.unpack(config.hitlog.text_color))
        end
    end

    if config.speclist then
        if config.speclist.bg_color then
            ui_state.speclistcolor_picker:set(table.unpack(config.speclist.bg_color))
        end
        if config.speclist.outline_color then
            ui_state.speclistotcolor_picker:set(table.unpack(config.speclist.outline_color))
        end
        if config.speclist.text_color then
            ui_state.speclisttextcolor_picker:set(table.unpack(config.speclist.text_color))
        end
        if config.speclist.header_color then
            ui_state.speclistheadercolor_picker:set(table.unpack(config.speclist.header_color))
        end
    end

    if config.esp then
        ui_state.esp_checkbox:set(config.esp.espEnabled)
        ui_state.skeleton_checkbox:set(config.esp.skeleton_checkbox)
        ui_state.espbox_checkbox:set(config.esp.espbox_checkbox)
        ui_state.espname_checkbox:set(config.esp.espname_checkbox)
        ui_state.glow_checkbox:set(config.esp.glow)
        if config.esp.boxcolor then
            ui_state.boxcolor_picker:set(table.unpack(config.esp.boxcolor))
        end
        if config.esp.skeletoncolor then
            ui_state.skeletoncolor_picker:set(table.unpack(config.esp.skeletoncolor))
        end
        if config.esp.espnamecolor then
            ui_state.espnamecolor_picker:set(table.unpack(config.esp.espnamecolor))
        end
        if config.ctglow then
            ui_state.ctglowcolor_picker:set(table.unpack(config.esp.ctglow))
        end
        if config.tglow then
            ui_state.tglowcolor_picker:set(table.unpack(config.esp.tglow))
        end
    end

    if config.DEBUG then
        if config.DEBUG.watermark_position then
            ui_state.wtpos:set(config.DEBUG.watermark_position)
        end
        
        if config.DEBUG.bombpanel_position then
            ui_state.bombpanelpos:set(config.DEBUG.bombpanel_position)
            local x, y = string.match(config.DEBUG.bombpanel_position, "^(%-?%d+),(%-?%d+)$")
            if x and y then
                bombpanel_drag_x = tonumber(x)
                bombpanel_drag_y = tonumber(y)
            end
        end
        if config.DEBUG.speclist_position then
        local pos_str = tostring(config.speclist and config.speclist.position or config.DEBUG.speclist_position or "")
    ui_state.specpos:set(pos_str)
    local x, y = string.match(pos_str, "^(%-?%d+),(%-?%d+)$")
    if x and y then
        speclist_drag_x = tonumber(x)
        speclist_drag_y = tonumber(y)
    end
        end
    end

    LogSuccess("Config loaded from saikaidosense_conf.txt")
end)

local bombpanel_drag_x, bombpanel_drag_y = 25, 200
local bombpanel_dragging = false
local bombpanel_drag_offset_x, bombpanel_drag_offset_y = 0, 0

local OFFSETS = {
    ENTITY_LIST = 0x1A044E0,
    LOCAL_PLAYER_PAWN = 0x18580D0,
    M_HPAWN = 0x62C,
    OBSERVER_SERVICES = 0x11C0,
    OBSERVER_TARGET = 0x44,
    SANITIZED_NAME = 0x778,
    dwPlantedC4 = 0x1A71C40,
    dwGlobalVars = 0x184BEB0,
    m_flC4Blow = 0xFC0,
    m_flCurrentTime = 0x5C0,
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
        watermark_position = ui_state.wtpos:get(),
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
    }
}

local config = {
    teamCheck = true,
    headCircle = true,
    skeletonRendering = ui_state.skeleton_checkbox and ui_state.skeleton_checkbox:get() or true,
    boxRendering = ui_state.espbox_checkbox and ui_state.espbox_checkbox:get() or true,
    nameRendering = ui_state.espname_checkbox and ui_state.espname_checkbox:get() or true,
    healthBarRendering = true,
    healthTextRendering = true,
    debug_logging = true
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

local offsets = {
    dwViewMatrix = 0x1A6D280,
    dwLocalPlayerPawn = 0x18580D0,
    dwLocalPlayerController = 0x1A52D20,
    dwEntityList = 0x1A044E0,
    dwViewAngles = 0x1A774E0,
    m_hPlayerPawn = 0x824,
    m_bDormant = 0xEF,
    m_angEyeAngles = 0x1438,
    m_iHealth = 0x344,
    m_lifeState = 0x348,
    m_Glow = 0xC00,
    m_glowColorOverride = 0x40,
    m_bGlowing = 0x51,
    m_iGlowType = 0x30,
    m_iTeamNum = 0x3E3,
    m_vOldOrigin = 0x1324,
    m_pGameSceneNode = 0x328,
    m_modelState = 0x170,
    m_boneArray = 0x80,
    m_nodeToWorld = 0x10,
    m_sSanitizedPlayerName = 0x778,
    dwPlantedC4 = 0x1A71C40,
    m_nBombSite = 0xF94,
    m_bBeingDefused = 0xFCC,
    m_bBombDefused = 0xFE4,
    m_flFlashDuration = 0x140C
}

local g = {
    font = render.create_font("Verdana", 12, 700)
}

local BONE_MAP = {
    head = 6, neck_0 = 5, spine_1 = 4, spine_2 = 2, pelvis = 0,
    arm_upper_L = 8, arm_lower_L = 9, hand_L = 10,
    arm_upper_R = 13, arm_lower_R = 14, hand_R = 15,
    leg_upper_L = 22, leg_lower_L = 23, ankle_L = 24,
    leg_upper_R = 25, leg_lower_R = 26, ankle_R = 27
}

local hitsound_path = "sounds/hitsound.mp3"
local total_damage = 0
local process = {
    is_open = false,
    client_dll = 0,
}
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

local function update_speclist_textfields()
    if ui_state and ui_state.specpos then
        ui_state.specpos:set(string.format("%d,%d", speclist_drag_x, speclist_drag_y))
    end
end
local function update_watermark_textfields()
    if ui_state and ui_state.wtpos then
        ui_state.wtpos:set(string.format("%d,%d", watermark_drag_x, watermark_drag_y))
    end
end

if bombpanel_dragging then
    bombpanel_drag_x = mx - bombpanel_drag_offset_x
    bombpanel_drag_y = my - bombpanel_drag_offset_y
    if ui_state.bombpanelpos then
        ui_state.bombpanelpos:set(string.format("%d,%d", bombpanel_drag_x, bombpanel_drag_y))
    end
end
if ui_state and ui_state.bombpanelpos and not bombpanel_dragging then
    local val = ui_state.bombpanelpos:get()
    local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
    if x and y then
        bombpanel_drag_x = tonumber(x)
        bombpanel_drag_y = tonumber(y)
    end
end

if ui_state and ui_state.specpos and ui_state.specpos.on_change then
    ui_state.specpos:on_change(function(val)
        local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
        if x and y then
            speclist_drag_x = tonumber(x)
            speclist_drag_y = tonumber(y)
        end
    end)
end

if watermark_dragging then
    watermark_drag_x = mx - watermark_drag_offset_x
    watermark_drag_y = my - watermark_drag_offset_y
    update_watermark_textfields()
end

engine.register_on_engine_tick(function()
    local now = winapi.get_tickcount64()
    local elapsed = (now - DisplaySystem.state.start_time) / 1000
    local vw, vh = render.get_viewport_size()

    if ui_state and ui_state.wtpos and not watermark_dragging then
        local val = ui_state.wtpos:get()
        local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
        if x and y then
            watermark_drag_x = tonumber(x)
            watermark_drag_y = tonumber(y)
        end
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
        local ICON_FONT = render.create_font("Arial", 18, 700)
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

    local watermark_active = ui_state.watermark_checkbox:get()
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

    local crosshair_active = ui_state.crs_checkbox:get()
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

    local des_active = ui_state.des_checkbox:get()
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
    local cr_r, cr_g, cr_b = ui_state.crs_color_picker:get()
    DisplaySystem.config.crosshair.color = {cr_r, cr_g, cr_b}
    DisplaySystem.config.crosshair.thickness = ui_state.crs_thickness_slider_int:get()
    DisplaySystem.config.crosshair.gap = ui_state.crs_gap_slider_int:get()
    DisplaySystem.config.watermark_enabled = watermark_active
    local positions = {
        "Top Left", "Top Center", "Top Right",
        "Bottom Left", "Bottom Center", "Bottom Right"
    }
    DisplaySystem.config.watermark_position = positions[posIdx] or "Top Left"
    local bg_r, bg_g, bg_b = ui_state.color_picker:get()
    DisplaySystem.config.bg_color = {bg_r, bg_g, bg_b}
    local bo_r, bo_g, bo_b = ui_state.otcolor_picker:get()
    DisplaySystem.config.border_color = {bo_r, bo_g, bo_b}
    local tx_r, tx_g, tx_b = ui_state.txtcolor_picker:get()
    DisplaySystem.config.text_color = {tx_r, tx_g, tx_b}
    local ht_bg_r, ht_bg_g, ht_bg_b = ui_state.htcolor_picker:get()
    local ht_ot_r, ht_ot_g, ht_ot_b = ui_state.htotcolor_picker:get()
    local ht_txt_r, ht_txt_g, ht_txt_b = ui_state.httextcolor_picker:get()
    DisplaySystem.state.fps_value = render.get_fps()

    if DisplaySystem.state.phase == "welcome" and elapsed > DisplaySystem.config.welcome_duration then
        DisplaySystem.state.phase = "fade_out"
        DisplaySystem.state.fade_out_start = now
    elseif DisplaySystem.state.phase == "fade_out" then
        local p = (now - DisplaySystem.state.fade_out_start) / (DisplaySystem.config.fade_duration * 1000)
        if p > 1 then DisplaySystem.state.phase = "main" end
    end

    if ui_state and ui_state.wtpos and not watermark_dragging then
        local val = ui_state.wtpos:get()
        local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
        if x and y then
            watermark_drag_x = tonumber(x)
            watermark_drag_y = tonumber(y)
        end
    end

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
        local welcome_str = ("Welcome %s to Perception.cx"):format(DisplaySystem.config.username)
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
            local dim_slider = (ui_state.desmodedim_slider_int and ui_state.desmodedim_slider_int:get()) or 5
            if dim_slider == 0 then dim_slider = 5 end
            local target_dim_opacity = math.floor((dim_slider / 10) * 255)
            local animated_dim_opacity = math.floor(target_dim_opacity * anim_progress)
            render.draw_rectangle(0, 0, vw, vh, 0, 0, 0, animated_dim_opacity, 0, true)

            local hitlogs = {
                {text="Hit an enemy for -86 damage", alpha=alpha},
            }
            local y = vh - 40
            local hitlog_box_spacing = 18
            for i, msg in ipairs(hitlogs) do
                local tw, th = render.measure_text(DisplaySystem.fonts.main, msg.text)
                local pad = hitlog_box_pad
                local bw = hitlog_box_width
                local bh = hitlog_box_height
                local bx = (vw - bw) / 2
                local by = (y - hitlog_box_height + pad) + slide_offset
                render.draw_rectangle(bx, by, bw, bh, ht_bg_r, ht_bg_g, ht_bg_b, msg.alpha, 0, true)
                render.draw_rectangle(bx, by, bw, bh, ht_ot_r, ht_ot_g, ht_ot_b, msg.alpha, 2, false)
                local text_x = bx + (bw - tw) / 2
                local text_y = by + (bh - th) / 2
                render.draw_text(DisplaySystem.fonts.main, msg.text, text_x, text_y, ht_txt_r, ht_txt_g, ht_txt_b, msg.alpha, 1, 0, 0, 0, msg.alpha*0.5)
                y = by - hitlog_box_spacing
            end

            if ui_state and ui_state.wtpos and not watermark_dragging then
                local val = ui_state.wtpos:get()
                local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
                if x and y then
                    watermark_drag_x = tonumber(x)
                    watermark_drag_y = tonumber(y)
                end
            end

            do
                local info = ("Perception.cx | %s | FPS: %.0f | Ping: N/A"):format(DisplaySystem.config.username, DisplaySystem.state.fps_value)
                local tw, th = render.measure_text(DisplaySystem.fonts.main, info)
                local pad = DisplaySystem.config.box_padding
                local bw, bh = tw + pad*2, th + pad*2
                local mx, my = input.get_mouse_position()
                if watermark_dragging then
                    watermark_drag_x = mx - watermark_drag_offset_x
                    watermark_drag_y = my - watermark_drag_offset_y
                    update_watermark_textfields()
                end
                local over = mx >= watermark_drag_x and mx <= watermark_drag_x + bw and my >= watermark_drag_y and my <= watermark_drag_y + bh
                if over and input.is_key_pressed(0x01) and not watermark_dragging then
                    watermark_dragging = true
                    watermark_drag_offset_x = mx - watermark_drag_x
                    watermark_drag_offset_y = my - watermark_drag_y
                end
                if watermark_dragging and not input.is_key_down(0x01) then
                    watermark_dragging = false
                end
                if watermark_dragging then
                    watermark_drag_x = mx - watermark_drag_offset_x
                    watermark_drag_y = my - watermark_drag_offset_y
                end
                local bx, by = watermark_drag_x, watermark_drag_y
                render.draw_rectangle(bx, by, bw, bh, DisplaySystem.config.bg_color[1], DisplaySystem.config.bg_color[2], DisplaySystem.config.bg_color[3], alpha, 0, true)
                render.draw_rectangle(bx, by, bw, bh, DisplaySystem.config.border_color[1], DisplaySystem.config.border_color[2], DisplaySystem.config.border_color[3], alpha, 2, false)
                render.draw_text(DisplaySystem.fonts.main, info, bx + pad, by + pad,
                    DisplaySystem.config.text_color[1], DisplaySystem.config.text_color[2], DisplaySystem.config.text_color[3], alpha, 1, 0, 0, 0, alpha*0.5)
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

                if ui_state and ui_state.bombpanelpos and not bombpanel_dragging then
                    local val = ui_state.bombpanelpos:get()
                    local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
                    if x and y then
                        bombpanel_drag_x = tonumber(x)
                        bombpanel_drag_y = tonumber(y)
                    end
                end

                local bx, by = bombpanel_drag_x, bombpanel_drag_y

                local mx, my = input.get_mouse_position()
                if bombpanel_dragging then
                    bombpanel_drag_x = mx - bombpanel_drag_offset_x
                    bombpanel_drag_y = my - bombpanel_drag_offset_y
                    update_bombpanel_textfields()
                end
                local over = mx >= bombpanel_drag_x and mx <= bombpanel_drag_x + bw and my >= bombpanel_drag_y and my <= bombpanel_drag_y + bh
                if over and input.is_key_pressed(0x01) and not bombpanel_dragging then
                    bombpanel_dragging = true
                    bombpanel_drag_offset_x = mx - bombpanel_drag_x
                    bombpanel_drag_offset_y = my - bombpanel_drag_y
                end
                if bombpanel_dragging and not input.is_key_down(0x01) then
                    bombpanel_dragging = false
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

                local bg_r, bg_g, bg_b, bg_a = ui_state.speclistcolor_picker and ui_state.speclistcolor_picker:get() or 18, 18, 18, 255
                local border_r, border_g, border_b = ui_state.speclistotcolor_picker and select(1, ui_state.speclistotcolor_picker:get()) or 30, 30, 30
                local text_r, text_g, text_b = ui_state.speclisttextcolor_picker and select(1, ui_state.speclisttextcolor_picker:get()) or 200, 200, 200
                local header_r, header_g, header_b, header_a = ui_state.speclistheadercolor_picker and ui_state.speclistheadercolor_picker:get() or 60, 120, 255, 255
                local border_a = 180
                local text_a = 255

                local preview_names = {"Spectator1", "Spectator2"}
                local count = #preview_names
                local box_height = header_height + (count > 0 and (count * entry_height) or entry_height)
                local mx, my = input.get_mouse_position()
                local over = mx >= speclist_drag_x and mx <= speclist_drag_x + box_width and my >= speclist_drag_y and my <= speclist_drag_y + box_height
                if over and input.is_key_pressed(0x01) and not speclist_dragging then
                    speclist_dragging = true
                    speclist_drag_offset_x = mx - speclist_drag_x
                    speclist_drag_offset_y = my - speclist_drag_y
                end
                if speclist_dragging and not input.is_key_down(0x01) then
                    speclist_dragging = false
                end
                if speclist_dragging then
                    speclist_drag_x = mx - speclist_drag_offset_x
                    speclist_drag_y = my - speclist_drag_offset_y
                    update_speclist_textfields()
                end

                local x, y = speclist_drag_x, speclist_drag_y + slide_offset

                render.draw_rectangle(x + 3, y + 3, box_width, box_height, 0, 0, 0, 80, box_radius, true)
                render.draw_rectangle(x, y, box_width, box_height, bg_r, bg_g, bg_b, bg_a, box_radius, true)
                render.draw_rectangle(x, y, box_width, box_height, border_r, border_g, border_b, border_a, box_radius, false)
                render.draw_rectangle(x, y, box_width, header_height, header_r, header_g, header_b, header_a, box_radius, true)
                render.draw_text(DisplaySystem.fonts.main, "Spectators", x + 16, y + 6, 255, 255, 255, 255, 1, 0, 0, 0, 180)

                for i, name in ipairs(preview_names) do
                    render.draw_text(DisplaySystem.fonts.main, name, x + 16, y + header_height + (i - 1) * entry_height + 4, text_r, text_g, text_b, text_a, 1, 0, 0, 0, 120)
                end
            end
        end
        return
    end

    if ui_state.utft_checkbox:get() then
        process.is_open = proc.attach_by_name("cs2.exe")
        process.client_dll = proc.find_module("client.dll") or 0

        if not process.is_open or process.client_dll == 0 then return end

        local entityList = proc.read_int64(process.client_dll + OFFSETS.ENTITY_LIST)
        local localPlayerPawn = proc.read_int64(process.client_dll + OFFSETS.LOCAL_PLAYER_PAWN)
        if not entityList or entityList == 0 or not localPlayerPawn or localPlayerPawn == 0 then return end

        for i = 1, 64 do
            local list_entry = proc.read_int64(entityList + (8 * (i & 0x7FFF) >> 9) + 16)
            if not list_entry or list_entry == 0 then goto continue end

            local player = proc.read_int64(list_entry + 120 * (i & 0x1FF))
            if not player or player == 0 then goto continue end

            local playerPawn = proc.read_int32(player + OFFSETS.M_HPAWN)
            if not playerPawn or playerPawn == 0 then goto continue end

            local list_entry2 = proc.read_int64(entityList + 0x8 * ((playerPawn & 0x7FFF) >> 9) + 16)
            if not list_entry2 or list_entry2 == 0 then goto continue end

            local pCSPlayerPawn = proc.read_int64(list_entry2 + 120 * (playerPawn & 0x1FF))
            if not pCSPlayerPawn or pCSPlayerPawn == 0 then goto continue end

            if pCSPlayerPawn == localPlayerPawn then
                local bullet_services = proc.read_int64(player + 0x730)
                local current_damage = proc.read_int32(bullet_services + 0x118)

                if current_damage < total_damage then
                    total_damage = current_damage
                end

                if current_damage > total_damage then
                    local delta = current_damage - total_damage

                    if ui_state.hitlog_checkbox:get() then
                        local hitlogdis = ("Hit an enemy for -" .. delta .. " damage")
                        add_hitlog_message(hitlogdis)
                    end

                    if ui_state.hitsound_checkbox:get() then
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
    local entity_list = proc.read_int64(client + OFFSETS.ENTITY_LIST)
    if entity_list == 0 then return 0 end

    local entry = proc.read_int64(entity_list + 0x8 * ((pawn_handle & 0x7FFF) >> 9) + 16)
    if entry == 0 then return 0 end

    return proc.read_int64(entry + 120 * (pawn_handle & 0x1FF))
end
local function get_name(controller)
    local name_ptr = proc.read_int64(controller + OFFSETS.SANITIZED_NAME)
    if name_ptr == 0 then return "Invalid" end
    return proc.read_string(name_ptr, 64)
end
local function get_local_pawn()
    local client = proc.find_module("client.dll")
    if client == 0 then return 0 end
    return proc.read_int64(client + OFFSETS.LOCAL_PLAYER_PAWN)
end
local function get_entity_list_entry(index)
    local client = proc.find_module("client.dll")
    local entity_list = proc.read_int64(client + OFFSETS.ENTITY_LIST)
    if entity_list == 0 then return 0 end

    local entry1 = proc.read_int64(entity_list + ((8 * (index & 0x7FFF)) >> 9) + 16)
    if entry1 == 0 then return 0 end

    return proc.read_int64(entry1 + (120 * (index & 0x1FF)))
end
local function is_spectating_me(controller, local_pawn)
    local pawn_handle = proc.read_int32(controller + OFFSETS.M_HPAWN)
    if pawn_handle == 0 then return false end

    local pawn = get_pcs_player_pawn(pawn_handle)
    if pawn == 0 then return false end

    local obs_services = proc.read_int64(pawn + OFFSETS.OBSERVER_SERVICES)
    if obs_services == 0 then return false end

    local target_handle = proc.read_int32(obs_services + OFFSETS.OBSERVER_TARGET)
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
    local should_show = (ui_state.utft_checkbox and ui_state.utft_checkbox:get()) and (ui_state.speclist_checkbox and ui_state.speclist_checkbox:get())
    update_speclist_anim(should_show)

    if not speclist_anim.visible and not speclist_anim.fading_out then return end

    local sw, sh = render.get_viewport_size()
    local x, y = speclist_drag_x, speclist_drag_y + speclist_anim.slide_offset
    local box_width = 220
    local header_height = 28
    local entry_height = 22
    local box_radius = 8

    local bg_r, bg_g, bg_b, bg_a = ui_state.speclistcolor_picker and ui_state.speclistcolor_picker:get() or 18, 18, 18, 255
    local border_r, border_g, border_b = ui_state.speclistotcolor_picker and select(1, ui_state.speclistotcolor_picker:get()) or 30, 30, 30
    local text_r, text_g, text_b = ui_state.speclisttextcolor_picker and select(1, ui_state.speclisttextcolor_picker:get()) or 200, 200, 200
    local header_r, header_g, header_b, header_a = ui_state.speclistheadercolor_picker and ui_state.speclistheadercolor_picker:get() or 60, 120, 255, 255
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

local function update_bomb_panel()
    if not (ui_state.c4timer_checkbox and ui_state.c4timer_checkbox:get()) then
        bomb_panel_target_alpha = 0
        bomb_panel_target_bar_width = 0
        bomb_panel_bomb_plant_time_ms = nil
        bomb_panel_has_logged_site_id = false
        bomb_panel_line1_text = ""
        bomb_panel_line2_text = ""
        return
    end

    if not proc.attach_by_name("cs2.exe") or proc.did_exit() then
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


function handle_anti_flash()
    if not (ui_state.utft_checkbox:get() and ui_state.anti_flash_checkbox:get()) then return end
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

engine.register_on_engine_tick(function()
    if ui_state and ui_state.specpos and not speclist_dragging then
        local val = ui_state.specpos:get()
        local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
        if x and y then
            speclist_drag_x = tonumber(x)
            speclist_drag_y = tonumber(y)
        end
    end

    if not (des_visible and alpha > 0) then
        if ui_state and ui_state.bombpanelpos then
            local val = ui_state.bombpanelpos:get()
            local x, y = string.match(val, "^(%-?%d+),(%-?%d+)$")
            if x and y then
                panel_pos_x = tonumber(x)
                panel_pos_y = tonumber(y)
            end
        end
    end

    update_spectator_list()
    draw_spectators()
    update_bomb_panel()
    draw_bomb_panel()
    handle_anti_flash() 

    config.espEnabled = ui_state.esp_checkbox and ui_state.esp_checkbox:get() or false
    config.skeletonRendering = ui_state.skeleton_checkbox and ui_state.skeleton_checkbox:get() or false
    config.boxRendering = ui_state.espbox_checkbox and ui_state.espbox_checkbox:get() or false
    config.nameRendering = ui_state.espname_checkbox and ui_state.espname_checkbox:get() or false

    if not config.espEnabled then return end

    if not proc.attach_by_name("cs2.exe") then return end
    if proc.did_exit() then return end

    local client_dll = proc.find_module("client.dll")
    if not client_dll and config.debug_logging and not log_once.client_dll then
        engine.log("[ESP DBG] Could not find client.dll.", 255, 0, 0, 255); log_once.client_dll = true
        return
    end

    local view_matrix = {}
    for i = 0, 15 do table.insert(view_matrix, proc.read_float(client_dll + offsets.dwViewMatrix + (i * 4))) end

    local local_player_pawn = proc.read_int64(client_dll + offsets.dwLocalPlayerPawn)
    if local_player_pawn == 0 then
        if config.debug_logging and not log_once.lpp then
            engine.log("[ESP DBG] LocalPlayerPawn is 0. Are you in a match?", 255, 100, 0, 255); log_once.lpp = true
        end
        return
    end

    local local_team = proc.read_int32(local_player_pawn + offsets.m_iTeamNum)
    local local_origin_node = proc.read_int64(local_player_pawn + offsets.m_pGameSceneNode)
    if local_origin_node == 0 then return end
    local local_origin = vec3.read_float(local_origin_node + offsets.m_nodeToWorld)

    local entity_list = proc.read_int64(client_dll + offsets.dwEntityList)
    if entity_list == 0 then return end

    for i = 0, 63 do
        local list_entry = proc.read_int64(entity_list + 0x10)
        if list_entry == 0 then goto continue end

        local entity_controller = proc.read_int64(list_entry + 120 * (i & 0x1FF))
        if entity_controller == 0 then goto continue end

        local pawn_handle = proc.read_int32(entity_controller + offsets.m_hPlayerPawn)
        if pawn_handle == -1 then goto continue end

        local pawn_handle_masked = pawn_handle & 0x7FFF
        local list_entry2 = proc.read_int64(entity_list + 8 * math.floor(pawn_handle_masked / 512) + 16)
        if list_entry2 == 0 then goto continue end

        local entity_pawn = proc.read_int64(list_entry2 + 120 * (pawn_handle_masked & 0x1FF))
        if entity_pawn == 0 or entity_pawn == local_player_pawn then goto continue end

        if proc.read_int32(entity_pawn + offsets.m_lifeState) ~= 256 then goto continue end
        local health = proc.read_int32(entity_pawn + offsets.m_iHealth)
        if health <= 0 or health > 100 then goto continue end

        local team = proc.read_int32(entity_pawn + offsets.m_iTeamNum)
        if config.teamCheck and team == local_team then goto continue end

        local game_scene_node = proc.read_int64(entity_pawn + offsets.m_pGameSceneNode)
        if game_scene_node == 0 then goto continue end

        local bone_array_ptr = proc.read_int64(game_scene_node + offsets.m_modelState + offsets.m_boneArray)
        if bone_array_ptr == 0 then goto continue end

        local bones_3d, bones_2d = {}, {}
        for name, index in pairs(BONE_MAP) do
            bones_3d[name] = vec3.read_float(bone_array_ptr + index * 32)
            if bones_3d[name] then
                bones_2d[name] = world_to_screen(view_matrix, bones_3d[name])
            end
        end

        if not bones_3d.head or not bones_2d.head then goto continue end

        local origin_3d = vec3.read_float(entity_pawn + offsets.m_vOldOrigin)
        local screen_pos_feet = world_to_screen(view_matrix, origin_3d)
        if not screen_pos_feet then goto continue end

        local box_height = math.abs((bones_2d.head.y - screen_pos_feet.y) + 10)
        local box_width = box_height / 2.0

        local head_bottom_screen = world_to_screen(view_matrix, vec3(bones_3d.head.x, bones_3d.head.y, bones_3d.head.z - 5))

        local entity_to_render = {
            health = health, team = team, distance = local_origin:distance(origin_3d),
            rect = {
                top = bones_2d.head.y, bottom = screen_pos_feet.y,
                left = bones_2d.head.x - (box_width / 2), right = bones_2d.head.x + (box_width / 2)
            },
            head_pos = head_bottom_screen and {x = bones_2d.head.x, y = bones_2d.head.y, z = head_bottom_screen.y},
            name = config.nameRendering and proc.read_string(proc.read_int64(entity_controller + offsets.m_sSanitizedPlayerName), 64)
        }

        render_entity_info(entity_to_render)
        if config.skeletonRendering then draw_skeleton(bones_2d) end

        ::continue::
    end
end)

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

local skel_color = ui_state.skeletoncolor_picker and {ui_state.skeletoncolor_picker:get()} or {255, 255, 255, 255}
local skel_r, skel_g, skel_b, skel_a = table.unpack(skel_color)

function draw_skeleton(bones_2d)
    local function connect(b1, b2)
        if bones_2d[b1] and bones_2d[b2] then
            render.draw_line(bones_2d[b1].x, bones_2d[b1].y, bones_2d[b2].x, bones_2d[b2].y, skel_r, skel_g, skel_b, skel_a, 1)
        end
    end

    connect("head", "neck_0"); connect("neck_0", "spine_1"); connect("spine_1", "spine_2"); connect("spine_2", "pelvis")
    connect("spine_1", "arm_upper_L"); connect("arm_upper_L", "arm_lower_L"); connect("arm_lower_L", "hand_L")
    connect("spine_1", "arm_upper_R"); connect("arm_upper_R", "arm_lower_R"); connect("arm_lower_R", "hand_R")
    connect("pelvis", "leg_upper_L"); connect("leg_upper_L", "leg_lower_L"); connect("leg_lower_L", "ankle_L")
    connect("pelvis", "leg_upper_R"); connect("leg_upper_R", "leg_lower_R"); connect("leg_lower_R", "ankle_R")
end

function render_entity_info(entity)
    local color_r, color_g, color_b = 255, 120, 122
    if entity.team == 3 then
        color_r, color_g, color_b = 120, 142, 255
    end
    
    local outline_r, outline_g, outline_b, outline_a = 0, 0, 0, 200
    local rect, box_height = entity.rect, entity.rect.bottom - entity.rect.top

    local box_color = ui_state.boxcolor_picker and {ui_state.boxcolor_picker:get()} or {255, 255, 255, 255}
    local box_r, box_g, box_b, box_a = table.unpack(box_color)

    if config.boxRendering then
        render.draw_rectangle(rect.left - 1, rect.top - 1, rect.right-rect.left + 2, box_height + 2, outline_r, outline_g, outline_b, outline_a, 1, false)
        render.draw_rectangle(rect.left + 1, rect.top + 1, rect.right-rect.left - 2, box_height - 2, outline_r, outline_g, outline_b, outline_a, 1, false)
        render.draw_rectangle(rect.left, rect.top, rect.right - rect.left, box_height, box_r, box_g, box_b, 255, 1, false)
    end

    if config.headCircle and entity.head_pos then
        local head_radius = math.abs(entity.head_pos.z - entity.head_pos.y) / 2
        local center_y = entity.head_pos.y + head_radius
        render.draw_circle(entity.head_pos.x, center_y, head_radius + 1, outline_r, outline_g, outline_b, outline_a, 1, false)
        render.draw_circle(entity.head_pos.x, center_y, head_radius, 255, 255, 255, 255, 1, false)
    end
    
    if config.healthBarRendering then
        local health_green_val = math.round(math.map(entity.health, 0, 100, 0, 255))
        local health_bar_height = math.clamp((box_height) * (entity.health / 100.0), 1, box_height)
        render.draw_rectangle(rect.left - 5, rect.top-1, 4, box_height + 2, outline_r, outline_g, outline_b, outline_a, 1, false)
        render.draw_rectangle(rect.left - 4, rect.top + (box_height - health_bar_height), 2, health_bar_height, 255 - health_green_val, health_green_val, 50, 255, 1, true)
    end
    
    local name_color = ui_state.espnamecolor_picker and {ui_state.espnamecolor_picker:get()} or {255, 255, 255, 255}
    local name_r, name_g, name_b, name_a = table.unpack(name_color)

    if config.nameRendering and entity.name and entity.name ~= "" then
        local text_x = (rect.left + rect.right) / 2 - (#entity.name * 3.5)
        local text_y = rect.top - 14
        render.draw_text(g.font, entity.name, text_x, text_y, name_r, name_g, name_b, name_a, 1, outline_r, outline_g, outline_b, outline_a)
    end

    if config.healthTextRendering and not config.healthBarRendering then
        local hp_str = tostring(entity.health)
        render.draw_text(g.font, hp_str, rect.left-8-(#hp_str*8), rect.top, 0, 255, 50, 255, 1, outline_r, outline_g, outline_b, outline_a)
    end
end

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
            local ctrl_addr = proc.read_int64(entry_addr + 0x78 * (i & 0x1FF))
            if ctrl_addr ~= 0 and ctrl_addr ~= lpawn_ctrl_addr then
                local pawn_handle = proc.read_int32(ctrl_addr + offsets.m_hPlayerPawn) & 0x7FFF
                if pawn_handle > 0 then
                    local pawn_entry_addr = proc.read_int64(entity_list_addr + 0x8 * (pawn_handle >> 9) + 0x10)
                    if pawn_entry_addr ~= 0 then
                        local pawn_addr = proc.read_int64(pawn_entry_addr + 0x78 * (pawn_handle & 0x1FF))
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
    if not (ui_state.utft_checkbox:get() and ui_state.radar_checkbox:get()) then
        return
    end

    if not g.client_module then return end
    
    handle_dragging()
    update_data()
    update_dynamic_scale()
    draw_radar()
end

local function on_script_load_radar()
    if not proc.attach_by_name("cs2.exe") then
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

local function update_glow()
    if not (ui_state.esp_checkbox:get() and ui_state.glow_checkbox:get() and ui_state.utft_checkbox:get()) then
        return
    end
    
    if not client_base then
        return
    end

    local local_player = proc.read_int64(client_base + offsets.dwLocalPlayerPawn)
    if local_player == 0 then return end
    
    local entity_list = proc.read_int64(client_base + offsets.dwEntityList)
    if entity_list == 0 then return end

    local ct_r, ct_g, ct_b, ct_a = ui_state.ctglowcolor_picker:get()
    local t_r, t_g, t_b, t_a = ui_state.tglowcolor_picker:get()

    local ct_color = { ct_r / 255.0, ct_g / 255.0, ct_b / 255.0, ct_a / 255.0 }
    local t_color = { t_r / 255.0, t_g / 255.0, t_b / 255.0, t_a / 255.0 }

    for i = 1, 64 do
        local list_entry = proc.read_int64(entity_list + (8 * (i & 0x7FFF) >> 9) + 16)
        if not list_entry or list_entry == 0 then goto continue end

        local controller_addr = proc.read_int64(list_entry + 120 * (i & 0x1FF))
        if not controller_addr or controller_addr == 0 then goto continue end

        local pawn_handle = proc.read_int32(controller_addr + offsets.m_hPlayerPawn)
        if not pawn_handle or pawn_handle == -1 then goto continue end
        
        local list_entry2 = proc.read_int64(entity_list + 0x8 * ((pawn_handle & 0x7FFF) >> 9) + 16)
        if not list_entry2 or list_entry2 == 0 then goto continue end
        
        local pawn_addr = proc.read_int64(list_entry2 + 120 * (pawn_handle & 0x1FF))
        if pawn_addr == 0 or pawn_addr == local_player then goto continue end

        local life_state = proc.read_int32(pawn_addr + offsets.m_lifeState)
        if life_state ~= 256 then goto continue end

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

        ::continue::
    end
end


local function on_script_load_glow()
    if not proc.attach_by_name("cs2.exe") then
        engine.log("Error: Please attach to the cs2.exe process first.", 255, 0, 0, 255)
        return
    end

    engine.log("Attached to process with PID: " .. proc.pid(), 0, 255, 0, 255)
    
    local base, size = proc.find_module("client.dll")
    if base then
        client_base = base
        engine.log("Found client.dll at: 0x" .. string.format("%X", client_base), 0, 255, 0, 255)
        
        engine.register_on_engine_tick(update_glow)
        engine.log("Glow script is now running.", 0, 255, 255, 255)
    else
        engine.log("Error: Could not find client.dll module.", 255, 0, 0, 255)
    end
end

on_script_load_glow()

local log_once = {}