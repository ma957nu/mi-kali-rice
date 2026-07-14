local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local helpers = require("helpers")
local gears = require("gears")
local naughty = require("naughty")

local dpi = beautiful.xresources.apply_dpi

-- Variables de estado globales del widget
local current_ip = ""
local my_interface_menu = nil -- Variable de control para evitar menús duplicados

-- 1. Componentes visuales independientes
local title_icon = wibox.widget {
    markup = helpers.colorize_text("🌐 IP STATUS", "#865DFF"),
    font = beautiful.font_name .. "Bold 10",
    align = "center",
    widget = wibox.widget.textbox
}

local iface_text = wibox.widget {
    font = beautiful.font_name .. "Medium 11",
    align = "center",
    widget = wibox.widget.textbox
}

local ip_val_text = wibox.widget {
    font = beautiful.font_name .. "Mono Bold 11",
    align = "center",
    widget = wibox.widget.textbox
}

-- 2. Funciones de lógica de red
local function get_iface()
    local f = io.open(os.getenv("HOME") .. "/.config/awesome/network_interface")
    if not f then return "eth0" end
    local iface = f:read("*l")
    f:close()
    if not iface or iface == "" then return "eth0" end
    return iface
end

local function update_ip()
    local iface = get_iface()
    
    iface_text:set_markup(helpers.colorize_text(iface .. " ▼", "#865DFF"))

    awful.spawn.easy_async_with_shell(
        "ip -4 addr show " .. iface .. " 2>/dev/null | grep -oP 'inet \\K[0-9.]+'",
        function(stdout)
            local ip = stdout:gsub("\n", "")
            if ip == "" then
                current_ip = ""
                ip_val_text:set_markup(helpers.colorize_text("Desconectado", "#FF4A4A"))
            else
                current_ip = ip
                ip_val_text:set_markup(helpers.colorize_text(ip, beautiful.xforeground or "#FFFFFF"))
            end
        end
    )
end

-- 3. Menú interactivo inteligente (Controla la existencia previa)
local function open_interface_menu()
    -- Si el menú ya está abierto en pantalla, lo cerramos y limpiamos la variable
    if my_interface_menu and my_interface_menu.wibox.visible then
        my_interface_menu:hide()
        my_interface_menu = nil
        return
    end

    -- Escanea las interfaces reales activas en tu máquina
    awful.spawn.easy_async_with_shell("ls /sys/class/net", function(stdout)
        local menu_items = {}
        
        for iface in stdout:gmatch("[^\n]+") do
            if iface ~= "lo" then
                table.insert(menu_items, { 
                    iface, 
                    function()
                        awful.spawn.easy_async_with_shell(
                            "echo '" .. iface .. "' > " .. os.getenv("HOME") .. "/.config/awesome/network_interface", 
                            function()
                                update_ip() 
                            end
                        )
                    end 
                })
            end
        end
        
        -- Creamos la instancia asignándole el estilo visual para que combine
        my_interface_menu = awful.menu({ 
            items = menu_items,
            theme = { 
                width = dpi(110),
                bg_focus = "#865DFF", -- Fondo morado al seleccionar con el ratón
                fg_focus = "#FFFFFF"  -- Texto blanco al seleccionar
            }
        })
        
        my_interface_menu:show()
    end)
end

-- 4. Copiar IP al portapapeles (Clic Derecho)
local function copy_ip_to_clipboard()
    if current_ip ~= "" and current_ip ~= "Desconectado" then
        awful.spawn.with_shell("echo -n '" .. current_ip .. "' | xclip -selection clipboard")
        naughty.notify({
            title = "📋 Portapapeles",
            text = "IP " .. current_ip .. " copiada con éxito.",
            timeout = 2,
            position = "top_right"
        })
    end
end

-- 5. Asignación de interacciones de ratón
iface_text:buttons(gears.table.join(
    awful.button({ }, 1, function () open_interface_menu() end)
))

-- 6. Diseño del Layout (Estructura limpia)
local widget_content = wibox.widget {
    layout = wibox.layout.fixed.vertical,
    spacing = dpi(12),
    title_icon,
    iface_text,
    ip_val_text
}

local final_card = wibox.widget {
    {
        widget_content,
        top = dpi(14),
        bottom = dpi(14),
        left = dpi(12),
        right = dpi(12),
        widget = wibox.container.margin
    },
    bg = beautiful.dashboard_box_bg or "#1C252C",
    shape = helpers.rrect(dpi(6)),
    widget = wibox.container.background
}

final_card:buttons(gears.table.join(
    awful.button({ }, 3, function () copy_ip_to_clipboard() end)
))

-- 7. Temporizador de autorefresco automático (Cada 5 segundos)
gears.timer {
    timeout = 5,
    autostart = true,
    call_now = true,
    callback = update_ip
}

return final_card
