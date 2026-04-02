--[[
    Atlantis UI Library - Enhanced
    Original: fork of atlanta lib
    Enhancements:
        - Dock separated into its own module (Dock.Init, Dock.Add, Dock.Remove, Dock.WinSet, Dock.Destroy)
        - Panel Tabs (internal tab system for panels)
        - Groups (labeled sub-containers in panels)
        - Free elements without a group in panels
        - Rainbow Speed slider in Style menu
        - Animation tab in ColorPicker (None / Rainbow with per-picker speed)
]]

-- variables
    local uis          = cloneref(game:GetService("UserInputService"))
    local players      = cloneref(game:GetService("Players"))
    local ws           = cloneref(game:GetService("Workspace"))
    local http_service = cloneref(game:GetService("HttpService"))
    local gui_service  = cloneref(game:GetService("GuiService"))
    local lighting     = cloneref(game:GetService("Lighting"))
    local run          = cloneref(game:GetService("RunService"))
    local stats        = cloneref(game:GetService("Stats"))
    local coregui      = cloneref(game:GetService("CoreGui"))
    local debris       = cloneref(game:GetService("Debris"))
    local tween_service= cloneref(game:GetService("TweenService"))
    local sound_service= cloneref(game:GetService("SoundService"))
    local starter_gui  = cloneref(game:GetService("StarterGui"))
    local rs           = cloneref(game:GetService("ReplicatedStorage"))

    local vec2       = Vector2.new
    local vec3       = Vector3.new
    local dim2       = UDim2.new
    local dim        = UDim.new
    local rect       = Rect.new
    local cfr        = CFrame.new
    local empty_cfr  = cfr()
    local angle      = CFrame.Angles
    local dim_offset = UDim2.fromOffset

    local color  = Color3.new
    local hsv    = Color3.fromHSV
    local rgb    = Color3.fromRGB
    local hex    = Color3.fromHex
    local rgbseq = ColorSequence.new
    local rgbkey = ColorSequenceKeypoint.new
    local numseq = NumberSequence.new
    local numkey = NumberSequenceKeypoint.new

    local camera     = ws.CurrentCamera
    local lp         = players.LocalPlayer
    local mouse      = lp:GetMouse()
    local gui_offset = gui_service:GetGuiInset().Y

    local max   = math.max
    local floor = math.floor
    local min   = math.min
    local abs   = math.abs
    local noise = math.noise
    local rad   = math.rad
    local random= math.random
    local pow   = math.pow
    local sin   = math.sin
    local pi    = math.pi
    local tan   = math.tan
    local atan2 = math.atan2
    local cos   = math.cos
    local round = math.round
    local clamp = math.clamp
    local ceil  = math.ceil
    local sqrt  = math.sqrt
    local acos  = math.acos

    local insert = table.insert
    local find   = table.find
    local remove = table.remove
    local concat = table.concat
--

-- library init
    local library = {
        directory    = "atlantis",
        folders      = {"/fonts", "/configs", "/images"},
        flags        = {},
        config_flags = {},
        visible_flags= {},
        guis         = {},
        connections  = {},
        notifications= {},
        playerlist_data = {},

        current_tab,
        current_element_open,
        dock_button_holder,
        old_config,
        font,
        keybind_list,
        binds        = {},

        copied_flag,
        is_rainbow,

        instances    = {},
        drawings     = {},
        display_orders = 0,

        -- Rainbow system
        rainbow_hue        = 0,
        rainbow_speed      = 5,   -- global multiplier (style slider)
        rainbow_callbacks  = {},  -- per-colorpicker rainbow entries
    }

    local flags        = library.flags
    local config_flags = library.config_flags

    local themes = {
        preset = {
            ["outline"]       = hex("#0A0A0A"),
            ["inline"]        = hex("#2D2D2D"),
            ["accent"]        = hex("#6078BE"),
            ["high_contrast"] = hex("#141414"),
            ["low_contrast"]  = hex("#1E1E1E"),
            ["text"]          = hex("#B4B4B4"),
            ["text_outline"]  = rgb(0,0,0),
            ["glow"]          = hex("#6078BE"),
        },
        utility = {
            ["outline"]       = {["BackgroundColor3"]={}, ["Color"]={}},
            ["inline"]        = {["BackgroundColor3"]={}, ["ImageColor3"]={}},
            ["accent"]        = {["BackgroundColor3"]={}, ["TextColor3"]={}, ["ImageColor3"]={}, ["ScrollBarImageColor3"]={}},
            ["contrast"]      = {["Color"]={}},
            ["text"]          = {["TextColor3"]={}},
            ["text_outline"]  = {["Color"]={}},
            ["glow"]          = {["ImageColor3"]={}},
            ["high_contrast"] = {["BackgroundColor3"]={}},
            ["low_contrast"]  = {["BackgroundColor3"]={}},
        },
        find = {
            ["Frame"]          = "BackgroundColor3",
            ["TextLabel"]      = "TextColor3",
            ["UIGradient"]     = "Color",
            ["UIStroke"]       = "Color",
            ["ImageLabel"]     = "ImageColor3",
            ["TextButton"]     = "BackgroundColor3",
            ["ScrollingFrame"] = "ScrollBarImageColor3",
        }
    }

    local keys = {
        [Enum.KeyCode.LeftShift]          = "LS",
        [Enum.KeyCode.RightShift]         = "RS",
        [Enum.KeyCode.LeftControl]        = "LC",
        [Enum.KeyCode.RightControl]       = "RC",
        [Enum.KeyCode.Insert]             = "INS",
        [Enum.KeyCode.Backspace]          = "BS",
        [Enum.KeyCode.Return]             = "Ent",
        [Enum.KeyCode.LeftAlt]            = "LA",
        [Enum.KeyCode.RightAlt]           = "RA",
        [Enum.KeyCode.CapsLock]           = "CAPS",
        [Enum.KeyCode.One]                = "1",
        [Enum.KeyCode.Two]                = "2",
        [Enum.KeyCode.Three]              = "3",
        [Enum.KeyCode.Four]               = "4",
        [Enum.KeyCode.Five]               = "5",
        [Enum.KeyCode.Six]                = "6",
        [Enum.KeyCode.Seven]              = "7",
        [Enum.KeyCode.Eight]              = "8",
        [Enum.KeyCode.Nine]               = "9",
        [Enum.KeyCode.Zero]               = "0",
        [Enum.KeyCode.KeypadOne]          = "Num1",
        [Enum.KeyCode.KeypadTwo]          = "Num2",
        [Enum.KeyCode.KeypadThree]        = "Num3",
        [Enum.KeyCode.KeypadFour]         = "Num4",
        [Enum.KeyCode.KeypadFive]         = "Num5",
        [Enum.KeyCode.KeypadSix]          = "Num6",
        [Enum.KeyCode.KeypadSeven]        = "Num7",
        [Enum.KeyCode.KeypadEight]        = "Num8",
        [Enum.KeyCode.KeypadNine]         = "Num9",
        [Enum.KeyCode.KeypadZero]         = "Num0",
        [Enum.KeyCode.Minus]              = "-",
        [Enum.KeyCode.Equals]             = "=",
        [Enum.KeyCode.Tilde]              = "~",
        [Enum.KeyCode.LeftBracket]        = "[",
        [Enum.KeyCode.RightBracket]       = "]",
        [Enum.KeyCode.RightParenthesis]   = ")",
        [Enum.KeyCode.LeftParenthesis]    = "(",
        [Enum.KeyCode.Semicolon]          = ",",
        [Enum.KeyCode.Quote]              = "'",
        [Enum.KeyCode.BackSlash]          = "\\",
        [Enum.KeyCode.Comma]              = ",",
        [Enum.KeyCode.Period]             = ".",
        [Enum.KeyCode.Slash]              = "/",
        [Enum.KeyCode.Asterisk]           = "*",
        [Enum.KeyCode.Plus]               = "+",
        [Enum.KeyCode.Backquote]          = "`",
        [Enum.UserInputType.MouseButton1] = "MB1",
        [Enum.UserInputType.MouseButton2] = "MB2",
        [Enum.UserInputType.MouseButton3] = "MB3",
        [Enum.KeyCode.Escape]             = "ESC",
        [Enum.KeyCode.Space]              = "SPC",
    }

    library.__index = library

    for _, path in next, library.folders do
        makefolder(library.directory .. path)
    end

    writefile("ffff.ttf", game:HttpGet(
        "https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/NoLigatures/Medium/JetBrainsMonoNLNerdFont-Medium.ttf"
    ))

    local tahoma = {
        name  = "SmallestPixel7",
        faces = {{name="Regular", weight=400, style="normal", assetId=getcustomasset("ffff.ttf")}}
    }
    writefile("dddd.ttf", http_service:JSONEncode(tahoma))
    library.font = Font.new(getcustomasset("dddd.ttf"), Enum.FontWeight.Regular)

    local config_holder
--

-- ============================================================
--  DOCK MODULE
-- ============================================================
    --[[
        Dock is a self-contained module.
        Dock:Init(options)   - creates the dock bar UI
        Dock:Add(options)    - adds a button {name, image, tooltip}
        Dock:Remove(entry)   - removes a button
        Dock:WinSet(entry, sgui) - binds a button to a ScreenGui toggle
        Dock:Destroy()       - destroys the entire dock
    ]]

    library.dock = {
        _initialized  = false,
        _outline      = nil,
        _button_holder= nil,
        _sgui         = nil,
        _accent       = nil,
        entries       = {},
    }

    local Dock = library.dock

    function Dock:Init(options)
        if self._initialized then return self end
        options = options or {}

        local parent  = options.parent  or gethui()
        local pos     = options.position or dim2(0.5, 0, 0, 20)

        -- We use the shared sgui passed in (or create our own)
        local sgui_parent = options.sgui or library:create("ScreenGui", {
            Enabled      = true,
            Parent       = gethui(),
            Name         = "",
            DisplayOrder = 999998,
        })

        -- Outer outline
        local dock_outline = library:create("Frame", {
            Parent          = sgui_parent,
            Name            = "",
            Visible         = true,
            BorderColor3    = rgb(0,0,0),
            AnchorPoint     = vec2(0.5, 0),
            Position        = pos,
            Size            = dim2(0, 37, 0, 39),
            BorderSizePixel = 0,
            BackgroundColor3= themes.preset.outline,
        })
        library:apply_theme(dock_outline, "outline", "BackgroundColor3")
        dock_outline.Position = dim2(0, dock_outline.AbsolutePosition.X, 0, dock_outline.AbsolutePosition.Y)
        dock_outline.AnchorPoint = vec2(0, 0)
        library:draggify(dock_outline)

        local dock_inline = library:create("Frame", {
            Parent          = dock_outline,
            Name            = "",
            Position        = dim2(0, 1, 0, 1),
            BorderColor3    = rgb(0,0,0),
            Size            = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3= themes.preset.inline,
        })
        library:apply_theme(dock_inline, "inline", "BackgroundColor3")

        local dock_holder_bg = library:create("Frame", {
            Parent          = dock_inline,
            Name            = "",
            Size            = dim2(1, -2, 1, -2),
            Position        = dim2(0, 1, 0, 1),
            BorderColor3    = themes.preset.outline,
            BorderSizePixel = 0,
            BackgroundColor3= rgb(255,255,255),
        })
        library:apply_theme(dock_holder_bg, "outline", "BackgroundColor3")

        local accent = library:create("Frame", {
            Parent          = dock_holder_bg,
            Name            = "",
            Size            = dim2(1, 0, 0, 2),
            BorderColor3    = rgb(0,0,0),
            BorderSizePixel = 0,
            BackgroundColor3= themes.preset.accent,
        })
        library:apply_theme(accent, "accent", "BackgroundColor3")

        library:create("UIGradient", {
            Parent   = accent,
            Rotation = 90,
            Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
        })

        local UIGradient = library:create("UIGradient", {
            Parent   = dock_holder_bg,
            Rotation = 90,
            Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
        })
        library:apply_theme(UIGradient, "contrast", "Color")

        local button_holder = library:create("Frame", {
            Parent             = dock_holder_bg,
            Name               = "",
            BackgroundTransparency = 1,
            Size               = dim2(1, 0, 1, 0),
            BorderColor3       = rgb(0,0,0),
            BorderSizePixel    = 0,
            BackgroundColor3   = rgb(255,255,255),
        })

        library:create("UIListLayout", {
            Parent           = button_holder,
            Padding          = dim(0, 5),
            FillDirection    = Enum.FillDirection.Horizontal,
            SortOrder        = Enum.SortOrder.LayoutOrder,
        })

        library:create("UIPadding", {
            Parent        = button_holder,
            PaddingTop    = dim(0, 6),
            PaddingBottom = dim(0, 4),
            PaddingRight  = dim(0, 4),
            PaddingLeft   = dim(0, 4),
        })

        self._outline       = dock_outline
        self._button_holder = button_holder
        self._sgui          = sgui_parent
        self._accent        = accent
        self._initialized   = true

        -- Keep legacy reference alive
        library.dock_holder = button_holder

        return self
    end

    function Dock:Add(options)
        assert(self._initialized, "Dock:Add() called before Dock:Init()")
        options = options or {}

        local cfg = {
            name      = options.name    or "Panel",
            image     = options.image   or "rbxassetid://79856374238119",
            tooltip   = options.tooltip or options.name or "Panel",
            window    = options.window  or nil,  -- ScreenGui to toggle
            button    = nil,
            icon      = nil,
            _conn     = nil,
        }

        -- Outer button frame
        local btn = library:create("TextButton", {
            Parent          = self._button_holder,
            Name            = "",
            TextColor3      = rgb(0,0,0),
            BorderColor3    = rgb(0,0,0),
            Text            = "",
            Size            = dim2(0, 25, 0, 25),
            BorderSizePixel = 0,
            TextSize        = 14,
            BackgroundColor3= themes.preset.inline,
        })

        local btn_ol = library:create("Frame", {
            Parent          = btn,
            Name            = "",
            Position        = dim2(0, 1, 0, 1),
            BorderColor3    = rgb(0,0,0),
            Size            = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3= themes.preset.outline,
        })
        library:apply_theme(btn_ol, "outline", "BackgroundColor3")

        local btn_il = library:create("Frame", {
            Parent          = btn_ol,
            Name            = "",
            Position        = dim2(0, 1, 0, 1),
            BorderColor3    = rgb(0,0,0),
            Size            = dim2(1, -2, 1, -2),
            BorderSizePixel = 0,
            BackgroundColor3= rgb(255,255,255),
        })
        library:apply_theme(btn_il, "inline", "BackgroundColor3")

        local UIGradient = library:create("UIGradient", {
            Parent   = btn_il,
            Rotation = 90,
            Color    = rgbseq{rgbkey(0, rgb(35,35,47)), rgbkey(1, rgb(41,41,55))},
        })
        library:apply_theme(UIGradient, "contrast", "Color")

        local icon = library:create("ImageLabel", {
            Parent             = btn_il,
            Name               = "",
            ImageColor3        = themes.preset.accent,
            Image              = cfg.image,
            BackgroundTransparency = 1,
            BorderColor3       = rgb(0,0,0),
            Size               = dim2(1, 0, 1, 0),
            BorderSizePixel    = 0,
            BackgroundColor3   = rgb(255,255,255),
        })
        library:apply_theme(icon, "accent", "ImageColor3")

        library:create("UIPadding", {
            Parent        = btn_il,
            PaddingTop    = dim(0, 4),
            PaddingBottom = dim(0, 4),
            PaddingRight  = dim(0, 4),
            PaddingLeft   = dim(0, 4),
        })

        cfg.button = btn
        cfg.icon   = icon

        -- Tooltip
        library:tool_tip({name = cfg.tooltip, path = btn})

        -- Auto-bind window if provided
        if cfg.window then
            self:WinSet(cfg, cfg.window)
        end

        -- Resize dock outline to fit buttons
        local function update_dock_size()
            local count = 0
            for _ in next, self.entries do count += 1 end
            count = count + 1
            self._outline.Size = dim2(0, count * 30 + (count - 1) * 5 + 8, 0, 39)
        end

        insert(self.entries, cfg)
        update_dock_size()

        return cfg
    end

    function Dock:Remove(entry)
        assert(self._initialized, "Dock:Remove() called before Dock:Init()")
        if not entry then return end

        if entry._conn then
            entry._conn:Disconnect()
            entry._conn = nil
        end

        if entry.button and entry.button.Parent then
            entry.button:Destroy()
        end

        for i, e in next, self.entries do
            if e == entry then
                remove(self.entries, i)
                break
            end
        end
    end

    function Dock:WinSet(entry, target_sgui)
        assert(self._initialized, "Dock:WinSet() called before Dock:Init()")
        if not entry or not target_sgui then return end

        -- Disconnect previous binding
        if entry._conn then
            entry._conn:Disconnect()
            entry._conn = nil
        end

        entry.window = target_sgui

        entry._conn = entry.button.MouseButton1Click:Connect(function()
            target_sgui.Enabled = not target_sgui.Enabled
        end)

        -- Sync icon color with window state
        target_sgui:GetPropertyChangedSignal("Enabled"):Connect(function()
            entry.icon.ImageColor3 = target_sgui.Enabled
                and themes.preset.accent
                or  themes.preset.inline
        end)

        -- Set initial icon color
        entry.icon.ImageColor3 = target_sgui.Enabled
            and themes.preset.accent
            or  themes.preset.inline
    end

    function Dock:Destroy()
        if not self._initialized then return end
        for _, entry in next, self.entries do
            if entry._conn then entry._conn:Disconnect() end
        end
        if self._outline then self._outline:Destroy() end
        self._initialized   = false
        self._outline       = nil
        self._button_holder = nil
        self._accent        = nil
        self.entries        = {}
        library.dock_holder = nil
    end

    function Dock:SetVisible(bool)
        if self._outline then
            self._outline.Visible = bool
        end
    end

-- ============================================================
--  LIBRARY FUNCTIONS
-- ============================================================

    -- misc functions
        function library:hoverify(hover, parent)
            local hover_instance = library:create("Frame", {
                Parent             = parent,
                BackgroundTransparency = 1,
                BorderColor3       = rgb(0,0,0),
                Size               = dim2(1, 0, 1, 0),
                BorderSizePixel    = 0,
                BackgroundColor3   = themes.preset.accent,
                ZIndex             = 1,
            })
            library:apply_theme(hover_instance, "accent", "BackgroundColor3")

            hover.MouseEnter:Connect(function()
                library:tween(hover_instance, {BackgroundTransparency = 0})
            end)
            hover.MouseLeave:Connect(function()
                library:tween(hover_instance, {BackgroundTransparency = 1})
            end)

            return hover_instance
        end

        function library:hovering(Object)
            if type(Object) == "table" then
                for _, obj in Object do
                    if library:hovering(obj) then return true end
                end
                return false
            else
                local yc = Object.AbsolutePosition.Y <= mouse.Y and mouse.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y
                local xc = Object.AbsolutePosition.X <= mouse.X and mouse.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X
                return yc and xc
            end
        end

        function library:make_resizable(frame)
            local Frame = Instance.new("TextButton")
            Frame.Position        = dim2(1, -10, 1, -10)
            Frame.BorderColor3    = rgb(0,0,0)
            Frame.Size            = dim2(0, 10, 0, 10)
            Frame.BorderSizePixel = 0
            Frame.BackgroundColor3= rgb(255,255,255)
            Frame.Parent          = frame
            Frame.BackgroundTransparency = 1
            Frame.Text            = ""

            local resizing  = false
            local start_size
            local start
            local og_size   = frame.Size

            Frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing   = true
                    start      = input.Position
                    start_size = frame.Size
                end
            end)
            Frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    resizing = false
                end
            end)

            library:connection(uis.InputChanged, function(input)
                if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
                    frame.Size = dim2(
                        start_size.X.Scale,
                        clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, camera.ViewportSize.X),
                        start_size.Y.Scale,
                        clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, camera.ViewportSize.Y)
                    )
                end
            end)
        end

        function library:draggify(frame)
            local dragging  = false
            local start_size= frame.Position
            local start

            frame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging   = true
                    start      = input.Position
                    start_size = frame.Position

                    if library.current_element_open then
                        library.current_element_open.set_visible(false)
                        library.current_element_open.open = false
                        library.current_element_open = nil
                    end

                    if frame.Parent:IsA("ScreenGui") and frame.Parent.DisplayOrder ~= 999999 then
                        library.display_orders += 1
                        frame.Parent.DisplayOrder = library.display_orders
                    end
                end
            end)
            frame.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            library:connection(uis.InputChanged, function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    frame.Position = dim2(
                        0,
                        clamp(start_size.X.Offset + (input.Position.X - start.X), 0, camera.ViewportSize.X - frame.Size.X.Offset),
                        0,
                        clamp(start_size.Y.Offset + (input.Position.Y - start.Y), 0, camera.ViewportSize.Y - frame.Size.Y.Offset)
                    )
                end
            end)
        end

        function library:new_drawing(class, properties)
            local ins = Drawing.new(class)
            for k, v in next, properties do ins[k] = v end
            insert(library.drawings, ins)
            return ins
        end

        function library:new_item(class, properties)
            local ins = Instance.new(class)
            for k, v in next, properties do ins[k] = v end
            insert(library.instances, ins)
            return ins
        end

        function library:convert_enum(enum)
            local parts = {}
            for part in string.gmatch(enum, "[%w_]+") do insert(parts, part) end
            local t = Enum
            for i = 2, #parts do t = t[parts[i]] end
            return t
        end

        function library:tween(obj, properties)
            tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), properties):Play()
        end

        function library:config_list_update()
            if not config_holder then return end
            local list = {}
            for _, file in next, listfiles(library.directory .. "/configs") do
                local name = string.sub(file:gsub(library.directory .. "/configs\\", ""):gsub(library.directory .. "\\configs\\", ""), 1, -5)
                list[#list + 1] = name
            end
            config_holder.refresh_options(list)
        end

        function library:get_config()
            local Config = {}
            for k, v in flags do
                if type(v) == "table" and v.key then
                    Config[k] = {active = v.active, mode = v.mode, key = tostring(v.key)}
                elseif type(v) == "table" and v["Transparency"] and v["Color"] then
                    Config[k] = {Transparency = v["Transparency"], Color = v["Color"]:ToHex()}
                else
                    Config[k] = v
                end
            end
            return http_service:JSONEncode(Config)
        end

        function library:load_config(config_json)
            local config = http_service:JSONDecode(config_json)
            for k, v in next, config do
                local fn = library.config_flags[k]
                if fn then
                    if type(v) == "table" and v["Transparency"] and v["Color"] then
                        fn(hex(v["Color"]), v["Transparency"])
                    elseif type(v) == "table" and v["active"] then
                        fn(v)
                    else
                        fn(v)
                    end
                end
            end
        end

        function library:round(number, float)
            local m = 1 / (float or 1)
            return floor(number * m + 0.5) / m
        end

        function library:apply_theme(instance, theme, property)
            insert(themes.utility[theme][property], instance)
        end

        function library:update_theme(theme, col)
            for prop, objects in next, themes.utility[theme] do
                for _, object in next, objects do
                    if object[prop] == themes.preset[theme] or object.ClassName == "UIGradient" then
                        object[prop] = col
                    end
                end
            end
            themes.preset[theme] = col
        end

        function library:connection(signal, callback)
            local conn = signal:Connect(callback)
            insert(library.connections, conn)
            return conn
        end

        function library:apply_stroke(parent)
            local stroke = library:create("UIStroke", {
                Parent          = parent,
                Color           = themes.preset.text_outline,
                LineJoinMode    = Enum.LineJoinMode.Miter,
            })
            library:apply_theme(stroke, "text_outline", "Color")
        end

        function library:create(instance, options)
            local ins = Instance.new(instance)
            for prop, value in next, options do
                ins[prop] = value
            end
            if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then
                library:apply_theme(ins, "text", "TextColor3")
                library:apply_stroke(ins)
            elseif instance == "ScreenGui" then
                insert(library.guis, ins)
            end
            return ins
        end

        -- Global rainbow heartbeat
        library:connection(run.Heartbeat, function(dt)
            if not library.is_rainbow then return end
            library.rainbow_hue = (library.rainbow_hue + dt * library.rainbow_speed * 0.03) % 1
            for _, entry in next, library.rainbow_callbacks do
                if entry.active and entry.fn then
                    entry.fn(library.rainbow_hue)
                end
            end
        end)
    --

    -- elements
        local tooltip_sgui = library:create("ScreenGui", {
            Enabled      = true,
            Parent       = gethui(),
            Name         = "",
            DisplayOrder = 500,
        })

        function library:tool_tip(options)
            local cfg = {
                name = options.name or "hi",
                path = options.path or nil,
            }

            if cfg.path then
                local tt_outline = library:create("Frame", {
                    Parent          = tooltip_sgui,
                    Size            = dim2(0, 0, 0, 22),
                    Position        = dim2(0, 500, 0, 300),
                    BorderColor3    = rgb(0,0,0),
                    BorderSizePixel = 0,
                    Visible         = false,
                    AutomaticSize   = Enum.AutomaticSize.X,
                    BackgroundColor3= themes.preset.outline,
                })

                local tt_inline = library:create("Frame", {
                    Parent          = tt_outline,
                    Position        = dim2(0, 1, 0, 1),
                    BorderColor3    = rgb(0,0,0),
                    Size            = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3= themes.preset.inline,
                })

                local tt_bg = library:create("Frame", {
                    Parent          = tt_inline,
                    Position        = dim2(0, 1, 0, 1),
                    BorderColor3    = rgb(0,0,0),
                    Size            = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3= rgb(255,255,255),
                })

                local tt_grad = library:create("UIGradient", {
                    Parent = tt_bg,
                    Color  = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
                })
                library:apply_theme(tt_grad, "contrast", "Color")

                local tt_text = library:create("TextLabel", {
                    Parent          = tt_bg,
                    FontFace        = library.font,
                    TextColor3      = themes.preset.text,
                    BorderColor3    = rgb(0,0,0),
                    Text            = " " .. cfg.name .. " ",
                    Size            = dim2(0, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Position        = dim2(0, 0, 0, -1),
                    BorderSizePixel = 0,
                    AutomaticSize   = Enum.AutomaticSize.X,
                    TextSize        = 12,
                    BackgroundColor3= rgb(255,255,255),
                })

                library:create("UIStroke", {Parent = tt_text, LineJoinMode = Enum.LineJoinMode.Miter})

                cfg.path.MouseEnter:Connect(function() tt_outline.Visible = true end)
                cfg.path.MouseLeave:Connect(function() tt_outline.Visible = false end)

                library:connection(uis.InputChanged, function(input)
                    if tt_outline.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
                        tt_outline.Position = dim_offset(input.Position.X + 10, input.Position.Y + 10)
                    end
                end)
            end

            return cfg
        end

        -- Shared "other" ScreenGui for floating elements (colorpicker, dropdown popouts)
        local other_sgui = library:create("ScreenGui", {
            Enabled      = true,
            Parent       = gethui(),
            Name         = "",
            DisplayOrder = 99999,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        })
        library.other_sgui = other_sgui

        function library:panel(options)
            local cfg = {
                name        = options.text or options.name or "Window",
                size        = options.size or dim2(0, 530, 0, 590),
                position    = options.position or dim2(0, 500, 0, 500),
                anchor_point= options.anchor_point or vec2(0, 0),
                image       = options.image or "rbxassetid://79856374238119",
                open        = true,
                items       = {},
            }

            local items = cfg.items

            -- Panel GUI
            items.sgui = library:create("ScreenGui", {
                Enabled = true,
                Parent  = gethui(),
                Name    = "",
            })

            items.main_holder = library:create("Frame", {
                Parent          = items.sgui,
                AnchorPoint     = vec2(cfg.anchor_point.X, cfg.anchor_point.Y),
                Position        = cfg.position,
                Active          = true,
                BorderColor3    = rgb(0,0,0),
                Size            = cfg.size,
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:draggify(items.main_holder)
            library:make_resizable(items.main_holder)

            local Close = library:create("TextButton", {
                Parent          = items.main_holder,
                FontFace        = library.font,
                AnchorPoint     = vec2(1, 0),
                Active          = false,
                BorderColor3    = rgb(0,0,0),
                Text            = "X",
                Size            = dim2(0, 0, 0, 0),
                Selectable      = false,
                Position        = dim2(1, -7, 0, 5),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                TextXAlignment  = Enum.TextXAlignment.Right,
                AutomaticSize   = Enum.AutomaticSize.XY,
                TextColor3      = themes.preset.text,
                TextSize        = 12,
                ZIndex          = 100,
                BackgroundColor3= rgb(255,255,255),
            })
            library:create("UIStroke", {Parent = Close})
            Close.MouseButton1Click:Connect(function() items.sgui.Enabled = false end)

            items.window_inline = library:create("Frame", {
                Parent          = items.main_holder,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(items.window_inline, "accent", "BackgroundColor3")

            items.window_holder = library:create("Frame", {
                Parent          = items.window_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = themes.preset.outline,
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            items.UIGradient = library:create("UIGradient", {
                Parent   = items.window_holder,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(items.UIGradient, "contrast", "Color")

            items.text = library:create("TextLabel", {
                Parent          = items.window_holder,
                FontFace        = library.font,
                TextColor3      = themes.preset.accent,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.name,
                BackgroundTransparency = 1,
                Position        = dim2(0, 2, 0, 4),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.XY,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_theme(items.text, "accent", "TextColor3")

            library:create("UIStroke", {Parent = items.text, LineJoinMode = Enum.LineJoinMode.Miter})

            library:create("UIPadding", {
                Parent        = items.window_holder,
                PaddingBottom = dim(0, 4),
                PaddingRight  = dim(0, 4),
                PaddingLeft   = dim(0, 4),
            })

            items.outline = library:create("Frame", {
                Parent          = items.window_holder,
                Position        = dim2(0, 0, 0, 18),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 1, -18),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(items.outline, "inline", "BackgroundColor3")

            items.inline = library:create("Frame", {
                Parent          = items.outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(items.inline, "outline", "BackgroundColor3")

            items.holder = library:create("Frame", {
                Parent          = items.inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            items.UIGradient2 = library:create("UIGradient", {
                Parent   = items.holder,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, themes.preset.high_contrast), rgbkey(1, themes.preset.low_contrast)},
            })
            library:apply_theme(items.UIGradient2, "contrast", "Color")

            library:create("UIPadding", {
                Parent        = items.holder,
                PaddingTop    = dim(0, 5),
                PaddingBottom = dim(0, 5),
                PaddingRight  = dim(0, 5),
                PaddingLeft   = dim(0, 5),
            })

            items.glow = library:create("ImageLabel", {
                Parent             = items.main_holder,
                ImageColor3        = themes.preset.glow,
                ScaleType          = Enum.ScaleType.Slice,
                BorderColor3       = rgb(0,0,0),
                BackgroundColor3   = rgb(255,255,255),
                Visible            = true,
                Image              = "http://www.roblox.com/asset/?id=18245826428",
                BackgroundTransparency = 1,
                ImageTransparency  = 0.8,
                Position           = dim2(0, -20, 0, -20),
                Size               = dim2(1, 40, 1, 40),
                ZIndex             = 2,
                BorderSizePixel    = 0,
                SliceCenter        = rect(vec2(21,21), vec2(79,79)),
            })
            library:apply_theme(items.glow, "glow", "ImageColor3")

            -- Create dock button via Dock module (if initialized)
            if library.dock._initialized then
                local entry = library.dock:Add({
                    name    = cfg.name,
                    image   = cfg.image,
                    tooltip = cfg.name,
                    window  = items.sgui,
                })
                items.button = entry.button
                items.Icon   = entry.icon
                items._dock_entry = entry
            else
                -- Fallback: create button manually
                items.button = library:create("TextButton", {
                    Parent          = library.dock_holder or other_sgui,
                    TextColor3      = rgb(0,0,0),
                    BorderColor3    = rgb(0,0,0),
                    Text            = "",
                    Size            = dim2(0, 25, 0, 25),
                    BorderSizePixel = 0,
                    TextSize        = 14,
                    BackgroundColor3= themes.preset.inline,
                })

                local bi = library:create("Frame", {
                    Parent          = items.button,
                    Position        = dim2(0, 1, 0, 1),
                    BorderColor3    = rgb(0,0,0),
                    Size            = dim2(1, -2, 1, -2),
                    BorderSizePixel = 0,
                    BackgroundColor3= rgb(255,255,255),
                })
                library:apply_theme(bi, "inline", "BackgroundColor3")

                items.Icon = library:create("ImageLabel", {
                    Parent             = bi,
                    ImageColor3        = themes.preset.accent,
                    Image              = cfg.image,
                    BackgroundTransparency = 1,
                    BorderColor3       = rgb(0,0,0),
                    Size               = dim2(1, 0, 1, 0),
                    BorderSizePixel    = 0,
                    BackgroundColor3   = rgb(255,255,255),
                })
                library:apply_theme(items.Icon, "accent", "ImageColor3")

                library:tool_tip({name = cfg.name, path = items.button})

                items.sgui:GetPropertyChangedSignal("Enabled"):Connect(function()
                    items.Icon.ImageColor3 = items.sgui.Enabled and themes.preset.accent or themes.preset.inline
                end)
                items.button.MouseButton1Click:Connect(function()
                    items.sgui.Enabled = not items.sgui.Enabled
                end)
            end

            return setmetatable(cfg, library)
        end

        local sgui = library:create("ScreenGui", {
            Enabled      = true,
            Parent       = gethui(),
            Name         = "",
            DisplayOrder = 999999,
        })

        local notif_holder = library:create("ScreenGui", {
            Parent             = gethui(),
            Name               = "",
            IgnoreGuiInset     = true,
            DisplayOrder       = 999999,
            ZIndexBehavior     = Enum.ZIndexBehavior.Sibling,
        })

        function library:fold_elements(origin, elements)
            for _, x in next, elements do
                local flag = library.visible_flags[x]
                if flag then flag(flags[origin]) end
            end
        end

        function library:indicator()
            local cfg   = {items = {}}
            local items = cfg.items

            items.Window = library:create("Frame", {
                Parent          = sgui,
                Position        = dim2(0, 400, 0, 500),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(0, 322, 0, 147),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(items.Window, "outline", "BackgroundColor3")
            library:draggify(items.Window)

            items.InfoTitle = library:create("TextLabel", {
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = "Indicators",
                Parent          = items.Window,
                Size            = dim2(1, 0, 0, 0),
                Position        = dim2(0, 7, 0, 5),
                BackgroundTransparency = 1,
                TextXAlignment  = Enum.TextXAlignment.Left,
                BorderSizePixel = 0,
                ZIndex          = 5,
                AutomaticSize   = Enum.AutomaticSize.Y,
                TextSize        = 12,
            })

            local section = setmetatable(items, library)
            items.label  = section:label({name = "Player: "})
            items.slider = section:slider({name = "Health", custom = rgb(255,0,0), min = 0, max = 100, default = 50, input = true})

            function cfg.set_visible(bool)
                items.Window.Visible = bool
            end

            function cfg.change_health(int)
                items.slider.set(int)
            end

            function cfg.change_profile(player)
                items.label.set(string.format("Player: %s (%s)", player.Name, player.DisplayName))
            end

            return setmetatable(cfg, library)
        end

        function library:window(properties)
            local window = {opened = true}
            local opened = {}
            local blur   = library:create("BlurEffect", {
                Parent  = lighting,
                Enabled = true,
                Size    = 15,
            })

            library.cache = library:create("ScreenGui", {
                Enabled = false,
                Parent  = gethui(),
                Name    = "",
            })

            -- Initialize the dock on the shared sgui
            library.dock:Init({
                sgui     = sgui,
                position = dim2(0.5, 0, 0, 20),
            })

            function window.set_menu_visibility(bool)
                window.opened = bool

                if bool then
                    for _, gui in opened do gui.Enabled = true end
                    opened = {}
                else
                    for _, gui in library.guis do
                        if gui.Enabled then
                            gui.Enabled = false
                            insert(opened, gui)
                        end
                    end
                end

                library:tween(blur, {Size = bool and (flags["Blur Size"] or 15) or 0})
                library.dock:SetVisible(bool)

                sgui.Enabled         = true
                notif_holder.Enabled = true
                tooltip_sgui.Enabled = true
                library.cache.Enabled= false

                for _, tip in tooltip_sgui:GetChildren() do
                    tip.Visible = false
                end

                if library.current_element_open then
                    library.current_element_open.set_visible(false)
                    library.current_element_open.open = false
                    library.current_element_open = nil
                end
            end

            -- Keybind list
            local kbl_outline = library:create("Frame", {
                Parent          = sgui,
                Visible         = false,
                Active          = true,
                Position        = dim2(0, 50, 0, 200),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(0, 182, 0, 25),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(kbl_outline, "outline", "BackgroundColor3")
            library:draggify(kbl_outline)
            library:make_resizable(kbl_outline)
            library.keybind_list_frame = kbl_outline

            local kbl_inline = library:create("Frame", {
                Parent          = kbl_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(kbl_inline, "inline", "BackgroundColor3")

            local kbl_bg = library:create("Frame", {
                Parent          = kbl_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            local kbl_grad = library:create("UIGradient", {
                Parent   = kbl_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, themes.preset.high_contrast), rgbkey(1, themes.preset.low_contrast)},
            })
            library:apply_theme(kbl_grad, "contrast", "Color")

            local kbl_accent = library:create("Frame", {
                Parent          = kbl_bg,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(kbl_accent, "accent", "BackgroundColor3")

            library:create("UIGradient", {
                Parent   = kbl_accent,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
            })

            local kbl_title = library:create("TextLabel", {
                Parent          = kbl_bg,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = "Keybinds",
                BackgroundTransparency = 1,
                TextTruncate    = Enum.TextTruncate.AtEnd,
                Size            = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize        = 12,
                BackgroundColor3= themes.preset.text,
            })
            library:create("UIStroke", {Parent = kbl_title, LineJoinMode = Enum.LineJoinMode.Miter})

            local kbl_list_holder = library:create("Frame", {
                Parent          = kbl_bg,
                Position        = dim2(0, -2, 1, 1),
                Size            = dim2(1, 4, 0, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(kbl_list_holder, "outline", "BackgroundColor3")

            local kbl_list_il = library:create("Frame", {
                Parent          = kbl_list_holder,
                Size            = dim2(1, -2, 1, -2),
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(kbl_list_il, "inline", "BackgroundColor3")

            local kbl_list_bg = library:create("Frame", {
                Parent          = kbl_list_il,
                Size            = dim2(1, -2, 1, -2),
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= rgb(255,255,255),
            })
            library.keybind_list = kbl_list_bg

            local kbl_list_grad = library:create("UIGradient", {
                Parent   = kbl_list_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, themes.preset.high_contrast), rgbkey(1, themes.preset.low_contrast)},
            })
            library:apply_theme(kbl_list_grad, "contrast", "Color")

            library:create("UIListLayout", {
                Parent  = kbl_list_bg,
                Padding = dim(0, -1),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            library:create("UIPadding", {
                Parent       = kbl_list_bg,
                PaddingBottom= dim(0, 4),
                PaddingLeft  = dim(0, 5),
            })

            -- Main window panel
            local main_window = library:panel({
                name     = properties and properties.name or "Atlantis | ",
                size     = dim2(0, 604, 0, 628),
                position = dim2(0, (camera.ViewportSize.X/2) - 302 - 96, 0, (camera.ViewportSize.Y/2) - 421 - 12),
                image    = "rbxassetid://98823308062942",
            })

            local items = main_window.items

            window["tab_holder"] = library:create("Frame", {
                Parent             = items.holder,
                BackgroundTransparency = 1,
                Size               = dim2(1, 0, 0, 22),
                BorderColor3       = rgb(0,0,0),
                ZIndex             = 5,
                BorderSizePixel    = 0,
                BackgroundColor3   = rgb(255,255,255),
            })

            library:create("UIListLayout", {
                Parent             = window["tab_holder"],
                FillDirection      = Enum.FillDirection.Horizontal,
                HorizontalFlex     = Enum.UIFlexAlignment.Fill,
                Padding            = dim(0, 2),
                SortOrder          = Enum.SortOrder.LayoutOrder,
            })

            local section_holder = library:create("Frame", {
                Parent             = items.holder,
                BackgroundTransparency = 1,
                Position           = dim2(0, -1, 0, 19),
                BorderColor3       = rgb(0,0,0),
                Size               = dim2(1, 0, 1, -22),
                BorderSizePixel    = 0,
                BackgroundColor3   = rgb(255,255,255),
            })
            window["section_holder"] = section_holder

            local sec_outline = library:create("Frame", {
                Parent          = section_holder,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 1, 2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(sec_outline, "outline", "BackgroundColor3")

            local sec_inline = library:create("Frame", {
                Parent          = sec_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(sec_inline, "inline", "BackgroundColor3")

            local sec_bg = library:create("Frame", {
                Parent          = sec_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })
            library.section_holder = sec_bg

            library:create("UIPadding", {
                Parent        = sec_bg,
                PaddingTop    = dim(0, 4),
                PaddingBottom = dim(0, 4),
                PaddingRight  = dim(0, 4),
                PaddingLeft   = dim(0, 4),
            })

            local sec_grad = library:create("UIGradient", {
                Parent   = sec_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(sec_grad, "contrast", "Color")
            library:make_resizable(items.main_holder)

            -- Style panel
            local style = library:panel({
                name       = "Style",
                anchor_point = vec2(0, 0),
                size       = dim2(0, 394, 0, 520),
                position   = dim2(
                    0,
                    main_window.items.main_holder.AbsolutePosition.X + main_window.items.main_holder.AbsoluteSize.X + 2,
                    0,
                    main_window.items.main_holder.AbsolutePosition.Y
                ),
                image      = "rbxassetid://115194686863276",
            })

            local watermark = library:watermark({default = os.date("Atlantis | %b %d %Y - %H:%M:%S")})

            task.spawn(function()
                while task.wait(1) do
                    watermark.change_text(os.date("Atlantis - Beta - %b %d %Y - %H:%M:%S"))
                end
            end)

            local style_items = style.items
            local col = setmetatable(style_items, library):column()
            local sec = col:section({name = "Theme"})

            sec:label({name = "Accent"})
               :colorpicker({name = "Accent", color = themes.preset.accent, flag = "accent", callback = function(c)
                   library:update_theme("accent", c)
               end})

            sec:label({name = "Contrast"})
               :colorpicker({name = "Low", color = themes.preset.low_contrast, flag = "low_contrast", callback = function()
                   if flags["high_contrast"] and flags["low_contrast"] then
                       library:update_theme("contrast", rgbseq{
                           rgbkey(0, flags["low_contrast"].Color),
                           rgbkey(1, flags["high_contrast"].Color),
                       })
                   end
                   library:update_theme("low_contrast", flags["low_contrast"].Color)
               end})
               :colorpicker({name = "High", color = themes.preset.high_contrast, flag = "high_contrast", callback = function()
                   library:update_theme("contrast", rgbseq{
                       rgbkey(0, flags["low_contrast"].Color),
                       rgbkey(1, flags["high_contrast"].Color),
                   })
                   library:update_theme("high_contrast", flags["high_contrast"].Color)
               end})

            sec:label({name = "Inline"})
               :colorpicker({name = "Inline", color = themes.preset.inline, flag = "Inline", callback = function(c)
                   library:update_theme("inline", c)
               end})

            sec:label({name = "Outline"})
               :colorpicker({name = "Outline", color = themes.preset.outline, flag = "Outline", callback = function(c)
                   library:update_theme("outline", c)
               end})

            sec:label({name = "Text Color"})
               :colorpicker({name = "Main", color = themes.preset.text, flag = "text_main", callback = function(c)
                   library:update_theme("text", c)
               end})
               :colorpicker({name = "Outline", color = themes.preset.text_outline, flag = "text_outline", callback = function(c)
                   library:update_theme("text_outline", c)
               end})

            sec:label({name = "Glow"})
               :colorpicker({name = "Glow", color = themes.preset.glow, flag = "Glow", callback = function(c)
                   library:update_theme("glow", c)
               end})

            sec:slider({name = "Blur Size", flag = "Blur Size", min = 0, max = 56, default = 15, interval = 1, callback = function(int)
                if window.opened then blur.Size = int end
            end})

            -- Rainbow Speed slider (global)
            sec:slider({
                name     = "Rainbow Speed",
                flag     = "Rainbow Speed",
                min      = 1,
                max      = 20,
                default  = 5,
                interval = 1,
                callback = function(int)
                    library.rainbow_speed = int
                end,
            })

            local sec2 = col:section({name = "Other"})
            sec2:label({name = "UI Bind"})
                :keybind({callback = window.set_menu_visibility, key = Enum.KeyCode.Insert})
            sec2:toggle({name = "Keybind List", flag = "keybind_list", callback = function(bool)
                library.keybind_list_frame.Visible = bool
            end})
            sec2:toggle({name = "Watermark", flag = "watermark", callback = function(bool)
                watermark.set_visible(bool)
            end})
            sec2:button_holder({})
            sec2:button({name = "Copy JobId", callback = function() setclipboard(game.JobId) end})
            sec2:button_holder({})
            sec2:button({name = "Copy GameID", callback = function() setclipboard(tostring(game.GameId)) end})
            sec2:button_holder({})
            sec2:button({name = "Copy Join Script", callback = function()
                setclipboard(string.format(
                    'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game.Players.LocalPlayer)',
                    game.PlaceId, game.JobId
                ))
            end})
            sec2:button_holder({})
            sec2:button({name = "Rejoin", callback = function()
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, lp)
            end})
            sec2:button_holder({})
            sec2:button({name = "Join New Server", callback = function()
                local data = http_service:JSONDecode(game:HttpGetAsync(
                    "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                ))
                local srv = data.data[random(1, #data.data)]
                if srv and srv.playing <= (flags["max_players"] or 15) then
                    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, srv.id)
                end
            end})
            sec2:slider({name = "Max Players", flag = "max_players", min = 0, max = 40, default = 15, interval = 1})

            -- Config panel
            local cfg_holder = library:panel({
                name     = "Configurations",
                size     = dim2(0, 324, 0, 410),
                position = dim2(
                    0,
                    style_items.main_holder.AbsolutePosition.X + style_items.main_holder.AbsoluteSize.X + 2,
                    0,
                    style_items.main_holder.AbsolutePosition.Y
                ),
                image    = "rbxassetid://105199726008012",
            })

            local cfg_items = cfg_holder.items
            getgenv().load_config = function(name)
                library:load_config(readfile(library.directory .. "/configs/" .. name .. ".cfg"))
            end

            local cfg_col = setmetatable(cfg_items, library):column()
            local cfg_sec = cfg_col:section({name = "Options"})
            config_holder = cfg_sec:list({flag = "config_name_list"})
            cfg_sec:textbox({flag = "config_name_text_box"})
            cfg_sec:button_holder({})
            cfg_sec:button({name = "Create", callback = function()
                writefile(library.directory.."/configs/"..flags["config_name_text_box"]..".cfg", library:get_config())
                library:config_list_update()
            end})
            cfg_sec:button({name = "Delete", callback = function()
                delfile(library.directory.."/configs/"..flags["config_name_list"]..".cfg")
                library:config_list_update()
            end})
            cfg_sec:button_holder({})
            cfg_sec:button({name = "Load", callback = function()
                library:load_config(readfile(library.directory.."/configs/"..flags["config_name_list"]..".cfg"))
                library:notification({text = "Loaded Config: "..flags["config_name_list"], time = 3})
            end})
            cfg_sec:button({name = "Save", callback = function()
                writefile(library.directory.."/configs/"..flags["config_name_list"]..".cfg", library:get_config())
                library:config_list_update()
                library:notification({text = "Saved Config: "..flags["config_name_list"], time = 3})
            end})
            cfg_sec:button_holder({})
            cfg_sec:button({name = "Refresh Configs", callback = function() library:config_list_update() end})
            cfg_sec:button_holder({})
            cfg_sec:button({name = "Unload Config", callback = function() library:load_config(library.old_config) end})
            cfg_sec:button({name = "Unload Menu", callback = function()
                library:load_config(library.old_config)
                for _, gui in library.guis do gui:Destroy() end
                for _, conn in library.connections do conn:Disconnect() end
                blur:Destroy()
            end})

            -- ESP Preview panel
            local esp_holder = library:panel({
                name       = "ESP Preview",
                anchor_point = vec2(0, 0),
                size       = dim2(0, 300, 0, 325),
                position   = dim2(
                    0,
                    style.items.main_holder.AbsolutePosition.X,
                    0,
                    style.items.main_holder.AbsolutePosition.Y + style.items.main_holder.AbsoluteSize.Y + 2
                ),
                image      = "rbxassetid://77684377836328",
            })

            local esp_items = esp_holder.items
            local esp_col   = setmetatable(esp_items, library):column()
            window.esp_section = esp_col:section({name = "Main"})

            -- Playerlist panel
            local pl_holder = library:panel({
                name     = "Playerlist",
                anchor_point = vec2(0, 0),
                size     = dim2(0, 529, 0, 445),
                position = dim2(
                    0,
                    main_window.items.main_holder.AbsolutePosition.X - 531,
                    0,
                    main_window.items.main_holder.AbsolutePosition.Y
                ),
                image    = "rbxassetid://107070078834415",
            })

            local pl_items = pl_holder.items
            local pl_col   = setmetatable(pl_items, library):column()
            local pl_sec   = pl_col:section({name = "Playerlist"})
            local playerlist = pl_sec:playerlist({})
            pl_sec:dropdown({
                name     = "Priority",
                items    = {"Enemy", "Priority", "Neutral", "Friendly"},
                default  = "Neutral",
                flag     = "PLAYERLIST_DROPDOWN",
                callback = function(text)
                    if library.prioritize then library.prioritize(text) end
                end,
            })

            return setmetatable(window, library)
        end

        function library:watermark(options)
            local cfg = {
                default = options.text or options.default or os.date("Atlantis | %b %d %Y | %H:%M"),
            }

            local wm_outline = library:create("Frame", {
                Parent          = sgui,
                BorderColor3    = rgb(0,0,0),
                AnchorPoint     = vec2(1, 0),
                Position        = dim2(1, -20, 0, 20),
                Size            = dim2(0, 0, 0, 24),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.X,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(wm_outline, "outline", "BackgroundColor3")
            wm_outline.Position = dim_offset(wm_outline.AbsolutePosition.X, wm_outline.AbsolutePosition.Y)
            library:draggify(wm_outline)

            local wm_inline = library:create("Frame", {
                Parent          = wm_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(wm_inline, "inline", "BackgroundColor3")

            local wm_bg = library:create("Frame", {
                Parent          = wm_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            local wm_grad = library:create("UIGradient", {
                Parent   = wm_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(wm_grad, "contrast", "Color")

            local wm_text = library:create("TextLabel", {
                Parent          = wm_bg,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = "  Atlantis  ",
                Size            = dim2(0, 0, 1, 0),
                BackgroundTransparency = 1,
                Position        = dim2(0, -1, 0, 1),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.X,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:create("UIStroke", {Parent = wm_text, LineJoinMode = Enum.LineJoinMode.Miter})

            local wm_accent = library:create("Frame", {
                Parent          = wm_outline,
                Position        = dim2(0, 2, 0, 2),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -4, 0, 2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(wm_accent, "accent", "BackgroundColor3")
            library:create("UIGradient", {
                Parent   = wm_accent,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
            })

            function cfg.change_text(input)
                wm_text.Text = "  " .. input .. "  "
            end

            function cfg.set_visible(bool)
                wm_outline.Visible = bool
            end

            cfg.change_text(cfg.default)
            return cfg
        end

        function library:notification(properties)
            local cfg = {
                time = properties.time or 5,
                text = properties.text or properties.name or "Notification",
            }

            local notif_outline = library:create("Frame", {
                Parent          = notif_holder,
                Size            = dim2(0, 0, 0, 24),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                Position        = dim2(0, 20, 0, 72 + (#library.notifications * 28)),
                AutomaticSize   = Enum.AutomaticSize.X,
                BackgroundColor3= themes.preset.outline,
                AnchorPoint     = vec2(1, 0),
            })

            local notif_inline = library:create("Frame", {
                Parent          = notif_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })

            local notif_bg = library:create("Frame", {
                Parent          = notif_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            local notif_grad = library:create("UIGradient", {
                Parent = notif_bg,
                Color  = rgbseq{rgbkey(0, themes.preset.high_contrast), rgbkey(1, themes.preset.low_contrast)},
            })

            local notif_text = library:create("TextLabel", {
                Parent          = notif_bg,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = "  " .. cfg.text .. "  ",
                Size            = dim2(0, 0, 1, 0),
                BackgroundTransparency = 1,
                Position        = dim2(0, 0, 0, -1),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.X,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })

            local notif_accent = library:create("Frame", {
                Parent          = notif_outline,
                Position        = dim2(0, 2, 0, 2),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(0, 1, 1, -4),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(notif_accent, "accent", "BackgroundColor3")

            local notif_bar = library:create("Frame", {
                Parent          = notif_outline,
                Position        = dim2(0, 2, 1, -3),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(0, 0, 0, 1),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(notif_bar, "accent", "BackgroundColor3")

            local idx = #library.notifications + 1
            library.notifications[idx] = notif_outline

            -- Refresh positions
            for i, notif in next, library.notifications do
                tween_service:Create(notif, TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
                    {Position = dim2(0, 20, 0, 72 + (i * 28))}):Play()
            end

            tween_service:Create(notif_outline, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                {AnchorPoint = vec2(0, 0)}):Play()
            tween_service:Create(notif_bar, TweenInfo.new(cfg.time, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                {Size = dim2(1, -4, 0, 1)}):Play()

            task.spawn(function()
                task.wait(cfg.time)
                library.notifications[idx] = nil
                tween_service:Create(notif_outline, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                    {AnchorPoint = vec2(1, 0), BackgroundTransparency = 1}):Play()
                for _, v in next, notif_outline:GetDescendants() do
                    if v:IsA("TextLabel") then
                        tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {TextTransparency = 1}):Play()
                    elseif v:IsA("Frame") then
                        tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {BackgroundTransparency = 1}):Play()
                    elseif v:IsA("UIStroke") then
                        tween_service:Create(v, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {Transparency = 1}):Play()
                    end
                end
                task.wait(1)
                notif_outline:Destroy()
            end)
        end

        -- Main window tab
        function library:tab(options)
            local cfg = {
                name    = options.name or "tab",
                enabled = false,
            }

            local tab_btn = library:create("TextButton", {
                Parent          = self.tab_holder,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = "",
                BorderSizePixel = 0,
                Size            = dim2(0, 0, 1, -2),
                ZIndex          = 5,
                TextSize        = 12,
                BackgroundColor3= themes.preset.outline,
                AutoButtonColor = false,
            })
            library:apply_theme(tab_btn, "outline", "BackgroundColor3")

            local tab_il = library:create("Frame", {
                Parent          = tab_btn,
                Size            = dim2(1, -2, 1, 0),
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                ZIndex          = 5,
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(tab_il, "inline", "BackgroundColor3")

            local tab_bg = library:create("Frame", {
                Parent          = tab_il,
                Size            = dim2(1, -2, 1, -1),
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                ZIndex          = 5,
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            local tab_grad = library:create("UIGradient", {
                Parent   = tab_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(tab_grad, "contrast", "Color")

            local tab_text = library:create("TextLabel", {
                Parent          = tab_bg,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.name,
                BackgroundTransparency = 1,
                Size            = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.X,
                TextSize        = 12,
                ZIndex          = 5,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_theme(tab_text, "accent", "TextColor3")

            local section_holder = library:create("Frame", {
                Parent          = library.section_holder,
                BackgroundTransparency = 1,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                Visible         = false,
                BackgroundColor3= rgb(255,255,255),
            })
            cfg["holder"] = section_holder

            library:create("UIListLayout", {
                Parent         = section_holder,
                FillDirection  = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding        = dim(0, 4),
                SortOrder      = Enum.SortOrder.LayoutOrder,
            })

            function cfg.open_tab()
                if library.current_tab and library.current_tab[1] ~= tab_bg then
                    local prev_bg = library.current_tab[1]
                    prev_bg.Size = dim2(1, -2, 1, -1)
                    local g = prev_bg:FindFirstChildOfClass("UIGradient")
                    if g then g.Rotation = 90 end
                    local t = prev_bg:FindFirstChildOfClass("TextLabel")
                    if t then t.TextColor3 = themes.preset.text end
                    library.current_tab[2].Visible = false
                    library.current_tab = nil
                end

                library.current_tab = {tab_bg, section_holder}
                tab_bg.Size = dim2(1, -2, 1, 0)
                local g = tab_bg:FindFirstChildOfClass("UIGradient")
                if g then g.Rotation = -90 end
                tab_text.TextColor3 = themes.preset.accent
                section_holder.Visible = true

                if library.current_element_open then
                    library.current_element_open.set_visible(false)
                    library.current_element_open.open = false
                    library.current_element_open = nil
                end
            end

            tab_btn.MouseButton1Click:Connect(cfg.open_tab)

            return setmetatable(cfg, library)
        end

        function library:column(path)
            local cfg    = {}
            local holder = path or self.holder

            local col = library:create("Frame", {
                Parent          = holder,
                BackgroundTransparency = 1,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(col, "inline", "BackgroundColor3")

            library:create("UIListLayout", {
                Parent      = col,
                Padding     = dim(0, 4),
                SortOrder   = Enum.SortOrder.LayoutOrder,
                VerticalFlex= Enum.UIFlexAlignment.Fill,
            })

            cfg["holder"] = col
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  PANEL TABS (for floating panels, NOT the main window)
        -- ============================================================
        function library:panel_tabs(options)
            local cfg = {
                names       = options.names or {"Tab 1"},
                active      = nil,
                tab_frames  = {},
                tab_buttons = {},
            }

            local holder = self.holder

            -- Tab bar
            local bar_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 24),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(bar_outline, "outline", "BackgroundColor3")

            local bar_inline = library:create("Frame", {
                Parent          = bar_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(bar_inline, "inline", "BackgroundColor3")

            local bar_bg = library:create("Frame", {
                Parent          = bar_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            local bar_grad = library:create("UIGradient", {
                Parent   = bar_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(bar_grad, "contrast", "Color")

            local bar_accent = library:create("Frame", {
                Parent          = bar_bg,
                Size            = dim2(1, 0, 0, 2),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(bar_accent, "accent", "BackgroundColor3")
            library:create("UIGradient", {
                Parent   = bar_accent,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
            })

            local bar_btn_holder = library:create("Frame", {
                Parent             = bar_bg,
                BackgroundTransparency = 1,
                Size               = dim2(1, 0, 1, 0),
                BorderColor3       = rgb(0,0,0),
                BorderSizePixel    = 0,
                BackgroundColor3   = rgb(255,255,255),
            })

            library:create("UIListLayout", {
                Parent         = bar_btn_holder,
                FillDirection  = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding        = dim(0, 2),
                SortOrder      = Enum.SortOrder.LayoutOrder,
            })

            -- Content area
            local content_area = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Position        = dim2(0, 0, 0, 24),
                Size            = dim2(1, 0, 1, -24),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local current_panel_tab = nil

            for _, name in next, cfg.names do
                local is_active = (_ == 1)

                -- Tab button
                local tbtn_outline = library:create("TextButton", {
                    Parent          = bar_btn_holder,
                    FontFace        = library.font,
                    TextColor3      = themes.preset.text,
                    BorderColor3    = rgb(0,0,0),
                    Text            = "",
                    BorderSizePixel = 0,
                    Size            = dim2(0, 0, 1, 0),
                    TextSize        = 12,
                    BackgroundColor3= themes.preset.outline,
                    AutoButtonColor = false,
                })
                library:apply_theme(tbtn_outline, "outline", "BackgroundColor3")

                local tbtn_il = library:create("Frame", {
                    Parent          = tbtn_outline,
                    Size            = dim2(1, -2, 1, 0),
                    Position        = dim2(0, 1, 0, 1),
                    BorderColor3    = rgb(0,0,0),
                    BorderSizePixel = 0,
                    BackgroundColor3= themes.preset.inline,
                })
                library:apply_theme(tbtn_il, "inline", "BackgroundColor3")

                local tbtn_bg = library:create("Frame", {
                    Parent          = tbtn_il,
                    Size            = dim2(1, -2, 1, -1),
                    Position        = dim2(0, 1, 0, 1),
                    BorderColor3    = rgb(0,0,0),
                    BorderSizePixel = 0,
                    BackgroundColor3= rgb(255,255,255),
                })

                local tbtn_grad = library:create("UIGradient", {
                    Parent   = tbtn_bg,
                    Rotation = 90,
                    Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
                })
                library:apply_theme(tbtn_grad, "contrast", "Color")

                local tbtn_text = library:create("TextLabel", {
                    Parent          = tbtn_bg,
                    FontFace        = library.font,
                    TextColor3      = is_active and themes.preset.accent or themes.preset.text,
                    BorderColor3    = rgb(0,0,0),
                    Text            = name,
                    BackgroundTransparency = 1,
                    Size            = dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize   = Enum.AutomaticSize.X,
                    TextSize        = 12,
                    BackgroundColor3= rgb(255,255,255),
                })
                library:apply_theme(tbtn_text, "text", "TextColor3")

                -- Tab content frame
                local tab_content = library:create("Frame", {
                    Parent          = content_area,
                    BorderColor3    = rgb(0,0,0),
                    Size            = dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    Visible         = is_active,
                    BackgroundTransparency = 1,
                    BackgroundColor3= rgb(255,255,255),
                })

                -- Content layout
                library:create("UIListLayout", {
                    Parent    = tab_content,
                    Padding   = dim(0, 4),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    VerticalFlex = Enum.UIFlexAlignment.Fill,
                })

                cfg.tab_frames[name]  = tab_content
                cfg.tab_buttons[name] = {outline = tbtn_outline, bg = tbtn_bg, text = tbtn_text}

                if is_active then
                    current_panel_tab = name
                    tbtn_bg.Size = dim2(1, -2, 1, 0)
                    tbtn_grad.Rotation = -90
                    tbtn_text.TextColor3 = themes.preset.accent
                end

                tbtn_outline.MouseButton1Click:Connect(function()
                    if current_panel_tab == name then return end

                    -- Deactivate old
                    if current_panel_tab then
                        local old_content = cfg.tab_frames[current_panel_tab]
                        local old_btn     = cfg.tab_buttons[current_panel_tab]
                        if old_content then old_content.Visible = false end
                        if old_btn then
                            old_btn.bg.Size = dim2(1, -2, 1, -1)
                            local og = old_btn.bg:FindFirstChildOfClass("UIGradient")
                            if og then og.Rotation = 90 end
                            old_btn.text.TextColor3 = themes.preset.text
                        end
                    end

                    -- Activate new
                    tab_content.Visible = true
                    tbtn_bg.Size = dim2(1, -2, 1, 0)
                    tbtn_grad.Rotation = -90
                    tbtn_text.TextColor3 = themes.preset.accent
                    current_panel_tab = name
                end)
            end

            -- Return wrapper so callers can do tabs:tab("Name"):column():section(...)
            local panel_tab_api = {}
            function panel_tab_api:tab(name)
                local frame = cfg.tab_frames[name]
                if not frame then
                    warn("panel_tabs: tab '" .. tostring(name) .. "' does not exist")
                    return setmetatable({holder = content_area}, library)
                end
                return setmetatable({holder = frame}, library)
            end

            return panel_tab_api
        end

        -- ============================================================
        --  GROUP (labeled container within a section/column)
        -- ============================================================
        function library:group(options)
            local cfg = {
                name  = options.name or options.text or "Group",
                items = {},
            }

            local holder = self.holder

            -- Outer border
            local grp_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(grp_outline, "outline", "BackgroundColor3")

            local grp_inline = library:create("Frame", {
                Parent          = grp_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(grp_inline, "inline", "BackgroundColor3")

            local grp_bg = library:create("Frame", {
                Parent          = grp_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= rgb(255,255,255),
            })

            local grp_grad = library:create("UIGradient", {
                Parent   = grp_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(grp_grad, "contrast", "Color")

            -- Title
            local grp_title_bar = library:create("Frame", {
                Parent          = grp_bg,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 18),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local grp_accent_line = library:create("Frame", {
                Parent          = grp_title_bar,
                Size            = dim2(1, 0, 0, 2),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(grp_accent_line, "accent", "BackgroundColor3")
            library:create("UIGradient", {
                Parent   = grp_accent_line,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
            })

            local grp_label = library:create("TextLabel", {
                Parent          = grp_title_bar,
                FontFace        = library.font,
                TextColor3      = themes.preset.accent,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.name,
                BackgroundTransparency = 1,
                Position        = dim2(0, 4, 0, 3),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.XY,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
                TextXAlignment  = Enum.TextXAlignment.Left,
            })
            library:apply_theme(grp_label, "accent", "TextColor3")
            library:apply_stroke(grp_label)

            -- Content
            local grp_content = library:create("Frame", {
                Parent          = grp_bg,
                Position        = dim2(0, 0, 0, 18),
                Size            = dim2(1, 0, 0, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            library:create("UIListLayout", {
                Parent    = grp_content,
                Padding   = dim(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            library:create("UIPadding", {
                Parent        = grp_content,
                PaddingTop    = dim(0, 3),
                PaddingBottom = dim(0, 4),
                PaddingLeft   = dim(0, 4),
                PaddingRight  = dim(0, 4),
            })

            cfg.holder = grp_content
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  MULTI_SECTION
        -- ============================================================
        function library:multi_section(options)
            local cfg = {
                names    = options.names or {"First", "Second"},
                sections = {},
            }

            local sec_frame = library:create("Frame", {
                Parent          = self.holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(sec_frame, "inline", "BackgroundColor3")

            local sec_inline = library:create("Frame", {
                Parent          = sec_frame,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(sec_inline, "outline", "BackgroundColor3")

            local sec_bg = library:create("Frame", {
                Parent          = sec_inline,
                ClipsDescendants= true,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local sec_accent = library:create("Frame", {
                Parent          = sec_bg,
                Size            = dim2(1, 0, 0, 2),
                BorderColor3    = rgb(0,0,0),
                ZIndex          = 3,
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(sec_accent, "accent", "BackgroundColor3")
            library:create("UIGradient", {
                Parent   = sec_accent,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
            })

            local sec_grad = library:create("UIGradient", {
                Parent   = sec_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(sec_grad, "contrast", "Color")

            local tab_holder = library:create("Frame", {
                Parent          = sec_bg,
                ClipsDescendants= true,
                BackgroundTransparency = 1,
                Position        = dim2(0, -1, 0, 0),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 2, 0, 21),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            library:create("UIListLayout", {
                Parent         = tab_holder,
                FillDirection  = Enum.FillDirection.Horizontal,
                HorizontalFlex = Enum.UIFlexAlignment.Fill,
                Padding        = dim(0, -3),
                SortOrder      = Enum.SortOrder.LayoutOrder,
            })

            local content_holder = library:create("Frame", {
                Parent          = sec_bg,
                Position        = dim2(0, 0, 0, 21),
                Size            = dim2(1, 0, 1, -21),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local current_multi = nil

            for i, tab_name in next, cfg.names do
                local multi = {open = false}
                local is_first = (i == 1)

                local tabb = library:create("TextButton", {
                    Parent          = tab_holder,
                    FontFace        = library.font,
                    TextColor3      = themes.preset.text,
                    BorderColor3    = rgb(0,0,0),
                    Text            = "",
                    BorderSizePixel = 0,
                    TextSize        = 12,
                    BackgroundColor3= themes.preset.outline,
                    AutoButtonColor = false,
                })
                library:apply_theme(tabb, "outline", "BackgroundColor3")

                local tabb_il = library:create("Frame", {
                    Parent          = tabb,
                    Size            = dim2(1, -2, 1, 0),
                    Position        = dim2(0, 1, 0, 1),
                    BorderColor3    = rgb(0,0,0),
                    BorderSizePixel = 0,
                    BackgroundColor3= themes.preset.inline,
                })
                library:apply_theme(tabb_il, "inline", "BackgroundColor3")

                local tabb_bg = library:create("Frame", {
                    Parent          = tabb_il,
                    Size            = dim2(1, -2, 1, -1),
                    Position        = dim2(0, 1, 0, 1),
                    BorderColor3    = rgb(0,0,0),
                    BorderSizePixel = 0,
                    BackgroundColor3= rgb(255,255,255),
                })

                local tabb_grad = library:create("UIGradient", {
                    Parent   = tabb_bg,
                    Rotation = 90,
                    Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
                })
                library:apply_theme(tabb_grad, "contrast", "Color")

                local tabb_text = library:create("TextLabel", {
                    Parent          = tabb_bg,
                    FontFace        = library.font,
                    TextColor3      = is_first and themes.preset.accent or themes.preset.text,
                    BorderColor3    = rgb(0,0,0),
                    Text            = tab_name,
                    BackgroundTransparency = 1,
                    Size            = dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    AutomaticSize   = Enum.AutomaticSize.X,
                    TextSize        = 12,
                    BackgroundColor3= rgb(255,255,255),
                })

                local tab_content = library:create("Frame", {
                    Parent          = content_holder,
                    BorderColor3    = rgb(0,0,0),
                    Size            = dim2(1, 0, 1, 0),
                    BorderSizePixel = 0,
                    Visible         = is_first,
                    AutomaticSize   = Enum.AutomaticSize.Y,
                    BackgroundTransparency = 1,
                    BackgroundColor3= rgb(255,255,255),
                })

                library:create("UIListLayout", {
                    Parent    = tab_content,
                    Padding   = dim(0, 2),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                })

                library:create("UIPadding", {
                    Parent        = tab_content,
                    PaddingTop    = dim(0, 3),
                    PaddingBottom = dim(0, 3),
                    PaddingLeft   = dim(0, 3),
                    PaddingRight  = dim(0, 3),
                })

                multi.holder = tab_content
                multi._bg    = tabb_bg
                multi._grad  = tabb_grad
                multi._text  = tabb_text
                multi._content = tab_content

                if is_first then current_multi = multi end

                tabb.MouseButton1Click:Connect(function()
                    if current_multi == multi then return end

                    if current_multi then
                        current_multi._content.Visible = false
                        current_multi._bg.Size = dim2(1, -2, 1, -1)
                        local og = current_multi._grad
                        if og then og.Rotation = 90 end
                        current_multi._text.TextColor3 = themes.preset.text
                    end

                    tab_content.Visible = true
                    tabb_bg.Size = dim2(1, -2, 1, 0)
                    tabb_grad.Rotation = -90
                    tabb_text.TextColor3 = themes.preset.accent
                    current_multi = multi
                end)

                cfg.sections[tab_name] = setmetatable(multi, library)
            end

            return cfg
        end

        -- ============================================================
        --  SECTION
        -- ============================================================
        function library:section(options)
            local cfg = {
                name  = options.name or options.text or "Section",
                items = {},
            }

            local holder = self.holder

            local sec_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(sec_outline, "outline", "BackgroundColor3")

            local sec_inline = library:create("Frame", {
                Parent          = sec_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(sec_inline, "inline", "BackgroundColor3")

            local sec_bg = library:create("Frame", {
                Parent          = sec_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundColor3= rgb(255,255,255),
            })

            local sec_grad = library:create("UIGradient", {
                Parent   = sec_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(sec_grad, "contrast", "Color")

            -- Title bar
            local title_bar = library:create("Frame", {
                Parent          = sec_bg,
                Size            = dim2(1, 0, 0, 20),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local title_accent = library:create("Frame", {
                Parent          = title_bar,
                Size            = dim2(1, 0, 0, 2),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(title_accent, "accent", "BackgroundColor3")
            library:create("UIGradient", {
                Parent   = title_accent,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
            })

            local title_text = library:create("TextLabel", {
                Parent          = title_bar,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.name,
                BackgroundTransparency = 1,
                Position        = dim2(0, 5, 0, 4),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.XY,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
                TextXAlignment  = Enum.TextXAlignment.Left,
            })
            library:apply_stroke(title_text)

            -- Content
            local content = library:create("Frame", {
                Parent          = sec_bg,
                Position        = dim2(0, 0, 0, 20),
                Size            = dim2(1, 0, 0, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                AutomaticSize   = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            library:create("UIListLayout", {
                Parent    = content,
                Padding   = dim(0, 2),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            library:create("UIPadding", {
                Parent        = content,
                PaddingTop    = dim(0, 4),
                PaddingBottom = dim(0, 4),
                PaddingLeft   = dim(0, 4),
                PaddingRight  = dim(0, 4),
            })

            cfg.holder = content
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  LABEL  (also serves as anchor for chained colorpickers)
        -- ============================================================
        function library:label(options)
            local cfg = {
                name  = options.name or "",
                items = {},
            }

            local holder = self.holder

            local row = library:create("Frame", {
                Parent          = holder,
                Size            = dim2(1, 0, 0, 20),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local lbl_text = library:create("TextLabel", {
                Parent          = row,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.name,
                BackgroundTransparency = 1,
                Position        = dim2(0, 2, 0, 0),
                Size            = dim2(1, -4, 1, 0),
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(lbl_text)

            -- Swatch container on the right (colorpickers dock here)
            local swatch_holder = library:create("Frame", {
                Parent             = row,
                AnchorPoint        = vec2(1, 0.5),
                Position           = dim2(1, -2, 0.5, 0),
                Size               = dim2(0, 0, 0, 14),
                BackgroundTransparency = 1,
                BorderColor3       = rgb(0,0,0),
                BorderSizePixel    = 0,
                AutomaticSize      = Enum.AutomaticSize.X,
                BackgroundColor3   = rgb(255,255,255),
            })

            library:create("UIListLayout", {
                Parent             = swatch_holder,
                FillDirection      = Enum.FillDirection.Horizontal,
                Padding            = dim(0, 2),
                SortOrder          = Enum.SortOrder.LayoutOrder,
                HorizontalAlignment= Enum.HorizontalAlignment.Right,
            })

            cfg.holder = swatch_holder
            cfg.row    = row

            function cfg.set(txt)
                lbl_text.Text = tostring(txt)
            end

            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  TOGGLE
        -- ============================================================
        function library:toggle(options)
            local cfg = {
                name     = options.name or "",
                flag     = options.flag or options.name,
                callback = options.callback or function() end,
                default  = options.default or false,
                items    = {},
            }

            flags[cfg.flag]        = cfg.default
            config_flags[cfg.flag] = function(v) cfg.set(v) end

            local holder = self.holder

            local row = library:create("TextButton", {
                Parent          = holder,
                Size            = dim2(1, 0, 0, 22),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local hover = library:hoverify(row, row)

            local tog_text = library:create("TextLabel", {
                Parent          = row,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.name,
                BackgroundTransparency = 1,
                Position        = dim2(0, 4, 0, 0),
                Size            = dim2(1, -28, 1, 0),
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(tog_text)

            -- Toggle box
            local box_outline = library:create("Frame", {
                Parent          = row,
                AnchorPoint     = vec2(1, 0.5),
                Position        = dim2(1, -4, 0.5, 0),
                Size            = dim2(0, 14, 0, 14),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(box_outline, "outline", "BackgroundColor3")

            local box_inline = library:create("Frame", {
                Parent          = box_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_theme(box_inline, "inline", "BackgroundColor3")

            local box_fill = library:create("Frame", {
                Parent          = box_inline,
                Position        = dim2(0, 2, 0, 2),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -4, 1, -4),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.accent,
                BackgroundTransparency = cfg.default and 0 or 1,
            })
            library:apply_theme(box_fill, "accent", "BackgroundColor3")

            function cfg.set(value)
                flags[cfg.flag] = value
                library:tween(box_fill, {BackgroundTransparency = value and 0 or 1})
                cfg.callback(value)
            end

            row.MouseButton1Click:Connect(function()
                cfg.set(not flags[cfg.flag])
            end)

            library.visible_flags[cfg.flag] = function(v) cfg.set(v) end

            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  SLIDER
        -- ============================================================
        function library:slider(options)
            local cfg = {
                name     = options.name or "",
                flag     = options.flag or options.name,
                callback = options.callback or function() end,
                min      = options.min or 0,
                max      = options.max or 100,
                default  = options.default or 0,
                interval = options.interval or 1,
                input    = options.input or false,
                custom   = options.custom or nil,
                items    = {},
            }

            flags[cfg.flag]        = cfg.default
            config_flags[cfg.flag] = function(v) cfg.set(v) end

            local holder   = self.holder
            local dragging = false

            local row = library:create("Frame", {
                Parent          = holder,
                Size            = dim2(1, 0, 0, 34),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local sld_name = library:create("TextLabel", {
                Parent          = row,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.name,
                BackgroundTransparency = 1,
                Position        = dim2(0, 2, 0, 2),
                Size            = dim2(0.7, 0, 0, 16),
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(sld_name)

            local sld_value = library:create("TextLabel", {
                Parent          = row,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = tostring(cfg.default),
                BackgroundTransparency = 1,
                Position        = dim2(0.7, 0, 0, 2),
                Size            = dim2(0.3, -2, 0, 16),
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Right,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(sld_value)

            -- Slider track
            local track_outline = library:create("Frame", {
                Parent          = row,
                Position        = dim2(0, 0, 0, 20),
                Size            = dim2(1, 0, 0, 10),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(track_outline, "outline", "BackgroundColor3")

            local track_inline = library:create("Frame", {
                Parent          = track_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(track_inline, "inline", "BackgroundColor3")

            local track_bg = library:create("TextButton", {
                Parent          = track_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                BackgroundColor3= rgb(255,255,255),
            })

            local track_grad = library:create("UIGradient", {
                Parent   = track_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(track_grad, "contrast", "Color")

            local fill = library:create("Frame", {
                Parent          = track_bg,
                Size            = dim2(0, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundColor3= cfg.custom or themes.preset.accent,
            })
            if not cfg.custom then library:apply_theme(fill, "accent", "BackgroundColor3") end

            library:create("UIGradient", {
                Parent   = fill,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
            })

            local function compute(x_pos)
                local relative = clamp(x_pos - track_bg.AbsolutePosition.X, 0, track_bg.AbsoluteSize.X)
                local frac     = relative / track_bg.AbsoluteSize.X
                local raw      = cfg.min + (cfg.max - cfg.min) * frac
                local snapped  = library:round(raw, cfg.interval)
                return clamp(snapped, cfg.min, cfg.max)
            end

            function cfg.set(value)
                value = clamp(library:round(value, cfg.interval), cfg.min, cfg.max)
                flags[cfg.flag] = value
                local frac = (value - cfg.min) / (cfg.max - cfg.min)
                library:tween(fill, {Size = dim2(frac, 0, 1, 0)})
                sld_value.Text = tostring(value)
                cfg.callback(value)
            end

            track_bg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    cfg.set(compute(input.Position.X))
                end
            end)

            track_bg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            library:connection(uis.InputChanged, function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    cfg.set(compute(input.Position.X))
                end
            end)

            cfg.set(cfg.default)
            library.visible_flags[cfg.flag] = function(v) cfg.set(v) end
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  BUTTON_HOLDER  (horizontal row for buttons)
        -- ============================================================
        function library:button_holder(options)
            local cfg = {items = {}}

            local holder = self.holder

            local bh = library:create("Frame", {
                Parent          = holder,
                Size            = dim2(1, 0, 0, 22),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            library:create("UIListLayout", {
                Parent        = bh,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex= Enum.UIFlexAlignment.Fill,
                Padding       = dim(0, 2),
                SortOrder     = Enum.SortOrder.LayoutOrder,
            })

            cfg.holder = bh
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  BUTTON
        -- ============================================================
        function library:button(options)
            local cfg = {
                name     = options.name or "",
                flag     = options.flag or options.name,
                callback = options.callback or function() end,
                items    = {},
            }

            local holder = self.holder

            local btn_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 22),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(btn_outline, "outline", "BackgroundColor3")

            local btn_inline = library:create("Frame", {
                Parent          = btn_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(btn_inline, "inline", "BackgroundColor3")

            local btn_bg = library:create("TextButton", {
                Parent          = btn_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                BackgroundColor3= rgb(255,255,255),
            })

            local btn_grad = library:create("UIGradient", {
                Parent   = btn_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(btn_grad, "contrast", "Color")

            local hover = library:hoverify(btn_bg, btn_bg)

            local btn_text = library:create("TextLabel", {
                Parent          = btn_bg,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.name,
                BackgroundTransparency = 1,
                Size            = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(btn_text)

            btn_bg.MouseButton1Click:Connect(function()
                cfg.callback()
            end)

            cfg.holder = holder
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  TEXTBOX
        -- ============================================================
        function library:textbox(options)
            local cfg = {
                name     = options.name or "",
                flag     = options.flag or options.name,
                callback = options.callback or function() end,
                default  = options.default or "",
                items    = {},
            }

            flags[cfg.flag]        = cfg.default
            config_flags[cfg.flag] = function(v) cfg.set(v) end

            local holder = self.holder

            local tb_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 22),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(tb_outline, "outline", "BackgroundColor3")

            local tb_inline = library:create("Frame", {
                Parent          = tb_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(tb_inline, "inline", "BackgroundColor3")

            local tb_bg = library:create("Frame", {
                Parent          = tb_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            local tb_grad = library:create("UIGradient", {
                Parent   = tb_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(tb_grad, "contrast", "Color")

            local tb_input = library:create("TextBox", {
                Parent             = tb_bg,
                FontFace           = library.font,
                TextColor3         = themes.preset.text,
                BorderColor3       = rgb(0,0,0),
                Text               = cfg.default,
                PlaceholderText    = cfg.name,
                PlaceholderColor3  = themes.preset.text,
                BackgroundTransparency = 1,
                Size               = dim2(1, -6, 1, 0),
                Position           = dim2(0, 3, 0, 0),
                BorderSizePixel    = 0,
                TextXAlignment     = Enum.TextXAlignment.Left,
                TextSize           = 12,
                ClearTextOnFocus   = false,
                BackgroundColor3   = rgb(255,255,255),
            })

            function cfg.set(value)
                tb_input.Text    = tostring(value)
                flags[cfg.flag]  = value
                cfg.callback(value)
            end

            tb_input.FocusLost:Connect(function()
                flags[cfg.flag] = tb_input.Text
                cfg.callback(tb_input.Text)
            end)

            cfg.holder = holder
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  LIST  (dropdown-style list, external / for config)
        -- ============================================================
        function library:list(options)
            local cfg = {
                flag     = options.flag or "list",
                callback = options.callback or function() end,
                options_list = {},
                items    = {},
            }

            flags[cfg.flag]        = ""
            config_flags[cfg.flag] = function(v) flags[cfg.flag] = v end

            local holder = self.holder

            local list_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 80),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(list_outline, "outline", "BackgroundColor3")

            local list_inline = library:create("Frame", {
                Parent          = list_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(list_inline, "inline", "BackgroundColor3")

            local list_bg = library:create("ScrollingFrame", {
                Parent             = list_inline,
                Position           = dim2(0, 1, 0, 1),
                BorderColor3       = rgb(0,0,0),
                Size               = dim2(1, -2, 1, -2),
                BorderSizePixel    = 0,
                BackgroundColor3   = rgb(255,255,255),
                ScrollBarThickness = 2,
                ScrollBarImageColor3= themes.preset.accent,
                CanvasSize         = dim2(0, 0, 0, 0),
                AutomaticCanvasSize= Enum.AutomaticSize.Y,
            })
            library:apply_theme(list_bg, "accent", "ScrollBarImageColor3")

            local list_grad = library:create("UIGradient", {
                Parent   = list_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(list_grad, "contrast", "Color")

            library:create("UIListLayout", {
                Parent    = list_bg,
                Padding   = dim(0, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            function cfg.refresh_options(new_list)
                cfg.options_list = new_list
                for _, child in list_bg:GetChildren() do
                    if child:IsA("TextButton") then child:Destroy() end
                end

                for _, item_name in next, new_list do
                    local item_btn = library:create("TextButton", {
                        Parent          = list_bg,
                        FontFace        = library.font,
                        TextColor3      = themes.preset.text,
                        BorderColor3    = rgb(0,0,0),
                        Text            = "  " .. item_name,
                        BorderSizePixel = 0,
                        Size            = dim2(1, 0, 0, 18),
                        TextSize        = 12,
                        AutoButtonColor = false,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        BackgroundColor3= themes.preset.high_contrast,
                    })

                    library:hoverify(item_btn, item_btn)

                    item_btn.MouseButton1Click:Connect(function()
                        flags[cfg.flag] = item_name
                        cfg.callback(item_name)
                    end)
                end
            end

            cfg.holder = holder
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  DROPDOWN
        -- ============================================================
        function library:dropdown(options)
            local cfg = {
                name     = options.name or "",
                flag     = options.flag or options.name,
                callback = options.callback or function() end,
                items    = options.items or {},
                default  = options.default or (options.items and options.items[1]) or "",
                open     = false,
                _items   = {},
            }

            flags[cfg.flag]        = cfg.default
            config_flags[cfg.flag] = function(v) cfg.set(v) end

            local holder = self.holder

            local dd_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, 0, 0, 22),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(dd_outline, "outline", "BackgroundColor3")

            local dd_inline = library:create("Frame", {
                Parent          = dd_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(dd_inline, "inline", "BackgroundColor3")

            local dd_bg = library:create("TextButton", {
                Parent          = dd_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                BackgroundColor3= rgb(255,255,255),
            })

            local dd_grad = library:create("UIGradient", {
                Parent   = dd_bg,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(dd_grad, "contrast", "Color")

            local dd_text = library:create("TextLabel", {
                Parent          = dd_bg,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = cfg.default,
                BackgroundTransparency = 1,
                Position        = dim2(0, 4, 0, 0),
                Size            = dim2(1, -18, 1, 0),
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(dd_text)

            local dd_arrow = library:create("TextLabel", {
                Parent          = dd_bg,
                FontFace        = library.font,
                TextColor3      = themes.preset.accent,
                BorderColor3    = rgb(0,0,0),
                Text            = "v",
                BackgroundTransparency = 1,
                AnchorPoint     = vec2(1, 0.5),
                Position        = dim2(1, -3, 0.5, 0),
                Size            = dim2(0, 14, 0, 14),
                BorderSizePixel = 0,
                TextSize        = 12,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_theme(dd_arrow, "accent", "TextColor3")
            library:apply_stroke(dd_arrow)

            -- Popout
            local pop_outline = library:create("Frame", {
                Parent          = other_sgui,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(0, 0, 0, 0),
                BorderSizePixel = 0,
                Visible         = false,
                ZIndex          = 10,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(pop_outline, "outline", "BackgroundColor3")

            local pop_inline = library:create("Frame", {
                Parent          = pop_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 10,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(pop_inline, "inline", "BackgroundColor3")

            local pop_scroll = library:create("ScrollingFrame", {
                Parent             = pop_inline,
                Position           = dim2(0, 1, 0, 1),
                BorderColor3       = rgb(0,0,0),
                Size               = dim2(1, -2, 1, -2),
                BorderSizePixel    = 0,
                ZIndex             = 10,
                BackgroundColor3   = rgb(255,255,255),
                ScrollBarThickness = 2,
                ScrollBarImageColor3= themes.preset.accent,
                CanvasSize         = dim2(0, 0, 0, 0),
                AutomaticCanvasSize= Enum.AutomaticSize.Y,
            })
            library:apply_theme(pop_scroll, "accent", "ScrollBarImageColor3")

            local pop_grad = library:create("UIGradient", {
                Parent   = pop_scroll,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(pop_grad, "contrast", "Color")

            library:create("UIListLayout", {
                Parent    = pop_scroll,
                Padding   = dim(0, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            local function populate()
                for _, child in pop_scroll:GetChildren() do
                    if child:IsA("TextButton") then child:Destroy() end
                end
                for _, item_name in next, cfg.items do
                    local opt_btn = library:create("TextButton", {
                        Parent          = pop_scroll,
                        FontFace        = library.font,
                        TextColor3      = themes.preset.text,
                        BorderColor3    = rgb(0,0,0),
                        Text            = "  " .. item_name,
                        BorderSizePixel = 0,
                        Size            = dim2(1, 0, 0, 18),
                        ZIndex          = 10,
                        TextSize        = 12,
                        AutoButtonColor = false,
                        TextXAlignment  = Enum.TextXAlignment.Left,
                        BackgroundColor3= themes.preset.high_contrast,
                    })
                    library:apply_theme(opt_btn, "high_contrast", "BackgroundColor3")
                    library:hoverify(opt_btn, opt_btn)

                    opt_btn.MouseButton1Click:Connect(function()
                        cfg.set(item_name)
                        cfg.close()
                    end)
                end
            end
            populate()

            function cfg.set(value)
                flags[cfg.flag] = value
                dd_text.Text    = value
                cfg.callback(value)
            end

            function cfg.set_visible(bool)
                pop_outline.Visible = bool
                cfg.open = bool
                if bool then
                    local abs_pos = dd_bg.AbsolutePosition
                    local abs_size= dd_bg.AbsoluteSize
                    local count   = math.min(#cfg.items, 6)
                    pop_outline.Position = dim_offset(abs_pos.X, abs_pos.Y + abs_size.Y + 2)
                    pop_outline.Size     = dim2(0, abs_size.X + 2, 0, count * 18 + 2)
                end
            end

            function cfg.close()
                cfg.set_visible(false)
            end

            dd_bg.MouseButton1Click:Connect(function()
                if library.current_element_open and library.current_element_open ~= cfg then
                    library.current_element_open.set_visible(false)
                    library.current_element_open.open = false
                end
                cfg.set_visible(not cfg.open)
                library.current_element_open = cfg.open and cfg or nil
            end)

            cfg.set(cfg.default)
            config_flags[cfg.flag] = function(v) cfg.set(v) end
            cfg.holder = holder
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  COLORPICKER  (with Animation tab: None / Rainbow)
        -- ============================================================
        function library:colorpicker(options)
            local cfg = {
                name            = options.name or "Color",
                flag            = options.flag or options.name,
                callback        = options.callback or function() end,
                color           = options.color or rgb(255, 255, 255),
                alpha           = options.alpha or options.transparency or 0,
                open            = false,
                items           = {},
                -- Animation state
                anim_mode       = "None",  -- "None" or "Rainbow"
                anim_speed      = 5,
                _rainbow_entry  = nil,
            }

            local h, s, v_val = cfg.color:ToHSV()
            local a           = cfg.alpha

            flags[cfg.flag]        = {Color = cfg.color, Transparency = a, mode = "None", speed = 5}
            config_flags[cfg.flag] = function(col, alp)
                if type(col) == "table" then
                    cfg.update_color(col.Color or cfg.color, col.Transparency or a)
                else
                    cfg.update_color(col, alp or a)
                end
            end

            local holder       = self.holder
            local dragging_sat = false
            local dragging_hue = false
            local dragging_alp = false

            -- Small swatch button (sits in label.holder or section.holder)
            local swatch_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(0, 22, 0, 14),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(swatch_outline, "outline", "BackgroundColor3")

            local swatch_inline = library:create("Frame", {
                Parent          = swatch_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            local swatch_btn = library:create("TextButton", {
                Parent          = swatch_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                BackgroundColor3= cfg.color,
            })

            -- Rainbow shimmer overlay on swatch (visible when in rainbow mode)
            local swatch_rainbow = library:create("Frame", {
                Parent          = swatch_btn,
                Size            = dim2(1, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })
            library:create("UIGradient", {
                Parent   = swatch_rainbow,
                Rotation = 0,
                Color    = rgbseq{
                    rgbkey(0,   rgb(255,0,0)),
                    rgbkey(0.17,rgb(255,255,0)),
                    rgbkey(0.33,rgb(0,255,0)),
                    rgbkey(0.5, rgb(0,255,255)),
                    rgbkey(0.67,rgb(0,0,255)),
                    rgbkey(0.83,rgb(255,0,255)),
                    rgbkey(1,   rgb(255,0,0)),
                },
            })

            -- Popup picker frame
            local picker = library:create("TextButton", {
                Parent          = other_sgui,
                Text            = "",
                AutoButtonColor = false,
                Visible         = false,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(0, 200, 0, 240),
                BorderSizePixel = 0,
                ZIndex          = 50,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(picker, "inline", "BackgroundColor3")

            local picker_ol = library:create("UIStroke", {
                Parent       = picker,
                Color        = themes.preset.outline,
                LineJoinMode = Enum.LineJoinMode.Miter,
            })
            library:apply_theme(picker_ol, "outline", "Color")

            -- Picker inner tab bar (Color | Animation)
            local picker_tabbar = library:create("Frame", {
                Parent          = picker,
                Size            = dim2(1, 0, 0, 20),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(picker_tabbar, "outline", "BackgroundColor3")

            local tabbar_ll = library:create("UIListLayout", {
                Parent        = picker_tabbar,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex= Enum.UIFlexAlignment.Fill,
                Padding       = dim(0, 1),
                SortOrder     = Enum.SortOrder.LayoutOrder,
            })

            local picker_color_content   = nil
            local picker_anim_content    = nil
            local current_picker_tab     = "Color"

            local function make_picker_tab(name)
                local tb = library:create("TextButton", {
                    Parent          = picker_tabbar,
                    FontFace        = library.font,
                    TextColor3      = themes.preset.text,
                    BorderColor3    = rgb(0,0,0),
                    Text            = name,
                    BorderSizePixel = 0,
                    TextSize        = 11,
                    AutoButtonColor = false,
                    ZIndex          = 52,
                    BackgroundColor3= themes.preset.inline,
                })
                library:apply_theme(tb, "inline", "BackgroundColor3")
                return tb
            end

            local ptab_color = make_picker_tab("Color")
            local ptab_anim  = make_picker_tab("Animation")

            local function activate_picker_tab(tab_name)
                current_picker_tab = tab_name
                local is_color = (tab_name == "Color")

                ptab_color.BackgroundColor3 = is_color and themes.preset.accent or themes.preset.inline
                ptab_anim.BackgroundColor3  = (not is_color) and themes.preset.accent or themes.preset.inline

                if picker_color_content then
                    picker_color_content.Visible = is_color
                end
                if picker_anim_content then
                    picker_anim_content.Visible = not is_color
                end
            end

            ptab_color.MouseButton1Click:Connect(function() activate_picker_tab("Color") end)
            ptab_anim.MouseButton1Click:Connect(function()  activate_picker_tab("Animation") end)

            -- ---- COLOR TAB ----
            picker_color_content = library:create("Frame", {
                Parent          = picker,
                Position        = dim2(0, 2, 0, 22),
                Size            = dim2(1, -4, 1, -24),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            -- Sat/Val 2D grid
            local sv_outline = library:create("Frame", {
                Parent          = picker_color_content,
                Size            = dim2(1, 0, 1, -78),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(sv_outline, "outline", "BackgroundColor3")

            local sv_inline = library:create("Frame", {
                Parent          = sv_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(sv_inline, "inline", "BackgroundColor3")

            local sv_color = library:create("Frame", {
                Parent          = sv_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= hsv(h, 1, 1),
            })

            -- White overlay (saturation)
            local sv_white = library:create("Frame", {
                Parent          = sv_color,
                Size            = dim2(1, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= rgb(255,255,255),
            })
            library:create("UIGradient", {
                Parent      = sv_white,
                Transparency= numseq{numkey(0, 0), numkey(1, 1)},
            })

            -- Black overlay (value)
            local sv_black = library:create("Frame", {
                Parent          = sv_white,
                Size            = dim2(1, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 52,
                BackgroundColor3= rgb(0,0,0),
            })
            library:create("UIGradient", {
                Parent      = sv_black,
                Rotation    = 270,
                Transparency= numseq{numkey(0, 0), numkey(1, 1)},
            })

            -- Sat/Val interactive button
            local sv_btn = library:create("TextButton", {
                Parent          = sv_black,
                Size            = dim2(1, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                ZIndex          = 53,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            -- Sat/Val cursor
            local sv_cursor = library:create("Frame", {
                Parent          = sv_btn,
                AnchorPoint     = vec2(0.5, 0.5),
                Position        = dim2(s, 0, 1 - v_val, 0),
                Size            = dim2(0, 6, 0, 6),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 54,
                BackgroundColor3= rgb(0,0,0),
            })
            library:create("Frame", {
                Parent          = sv_cursor,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 55,
                BackgroundColor3= rgb(255,255,255),
            })

            -- Hue slider
            local hue_outline = library:create("Frame", {
                Parent          = picker_color_content,
                AnchorPoint     = vec2(0, 1),
                Position        = dim2(0, 0, 1, -54),
                Size            = dim2(1, 0, 0, 14),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(hue_outline, "outline", "BackgroundColor3")

            local hue_inline = library:create("Frame", {
                Parent          = hue_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= rgb(255,255,255),
            })

            library:create("UIGradient", {
                Parent = hue_inline,
                Color  = rgbseq{
                    rgbkey(0,    rgb(255,0,0)),
                    rgbkey(0.167,rgb(255,255,0)),
                    rgbkey(0.333,rgb(0,255,0)),
                    rgbkey(0.5,  rgb(0,255,255)),
                    rgbkey(0.667,rgb(0,0,255)),
                    rgbkey(0.833,rgb(255,0,255)),
                    rgbkey(1,    rgb(255,0,0)),
                },
            })

            local hue_btn = library:create("TextButton", {
                Parent          = hue_inline,
                Size            = dim2(1, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                ZIndex          = 52,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local hue_cursor = library:create("Frame", {
                Parent          = hue_btn,
                AnchorPoint     = vec2(0.5, 0),
                Position        = dim2(h, 0, 0, 0),
                Size            = dim2(0, 3, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 53,
                BackgroundColor3= rgb(0,0,0),
            })
            library:create("Frame", {
                Parent          = hue_cursor,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 54,
                BackgroundColor3= rgb(255,255,255),
            })

            -- Alpha slider
            local alp_outline = library:create("Frame", {
                Parent          = picker_color_content,
                AnchorPoint     = vec2(0, 1),
                Position        = dim2(0, 0, 1, -36),
                Size            = dim2(1, 0, 0, 14),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(alp_outline, "outline", "BackgroundColor3")

            local alp_inline = library:create("Frame", {
                Parent          = alp_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= rgb(255,255,255),
            })

            library:create("UIGradient", {
                Parent = alp_inline,
                Color  = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(0,0,0))},
            })

            local alp_btn = library:create("TextButton", {
                Parent          = alp_inline,
                Size            = dim2(1, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                ZIndex          = 52,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local alp_cursor = library:create("Frame", {
                Parent          = alp_btn,
                AnchorPoint     = vec2(0.5, 0),
                Position        = dim2(1 - a, 0, 0, 0),
                Size            = dim2(0, 3, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 53,
                BackgroundColor3= rgb(0,0,0),
            })
            library:create("Frame", {
                Parent          = alp_cursor,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 54,
                BackgroundColor3= rgb(255,255,255),
            })

            -- RGB input
            local rgb_input_frame = library:create("Frame", {
                Parent          = picker_color_content,
                AnchorPoint     = vec2(0, 1),
                Position        = dim2(0, 0, 1, -18),
                Size            = dim2(1, 0, 0, 16),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(rgb_input_frame, "outline", "BackgroundColor3")

            local rgb_il = library:create("Frame", {
                Parent          = rgb_input_frame,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(rgb_il, "inline", "BackgroundColor3")

            local rgb_bg = library:create("Frame", {
                Parent          = rgb_il,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= rgb(255,255,255),
            })

            local rgb_tb = library:create("TextBox", {
                Parent             = rgb_bg,
                FontFace           = library.font,
                TextColor3         = themes.preset.text,
                BorderColor3       = rgb(0,0,0),
                Text               = "",
                PlaceholderText    = "R, G, B",
                PlaceholderColor3  = themes.preset.text,
                BackgroundTransparency = 1,
                Size               = dim2(1, -4, 1, 0),
                Position           = dim2(0, 2, 0, 0),
                BorderSizePixel    = 0,
                TextXAlignment     = Enum.TextXAlignment.Left,
                TextSize           = 11,
                ZIndex             = 52,
                ClearTextOnFocus   = false,
                BackgroundColor3   = rgb(255,255,255),
            })

            -- ---- ANIMATION TAB ----
            picker_anim_content = library:create("Frame", {
                Parent          = picker,
                Position        = dim2(0, 2, 0, 22),
                Size            = dim2(1, -4, 1, -24),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                Visible         = false,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            library:create("UIListLayout", {
                Parent    = picker_anim_content,
                Padding   = dim(0, 4),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })
            library:create("UIPadding", {
                Parent        = picker_anim_content,
                PaddingTop    = dim(0, 4),
                PaddingLeft   = dim(0, 4),
                PaddingRight  = dim(0, 4),
                ZIndex        = 51,
            })

            -- Mode selector
            local mode_row = library:create("Frame", {
                Parent          = picker_anim_content,
                Size            = dim2(1, 0, 0, 22),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local mode_label = library:create("TextLabel", {
                Parent          = mode_row,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = "Mode",
                BackgroundTransparency = 1,
                Position        = dim2(0, 2, 0, 0),
                Size            = dim2(0.4, 0, 1, 0),
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextSize        = 12,
                ZIndex          = 51,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(mode_label)

            -- Mode buttons: None | Rainbow
            local mode_btn_holder = library:create("Frame", {
                Parent          = mode_row,
                AnchorPoint     = vec2(1, 0),
                Position        = dim2(1, 0, 0, 0),
                Size            = dim2(0.58, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })
            library:create("UIListLayout", {
                Parent        = mode_btn_holder,
                FillDirection = Enum.FillDirection.Horizontal,
                HorizontalFlex= Enum.UIFlexAlignment.Fill,
                Padding       = dim(0, 2),
                SortOrder     = Enum.SortOrder.LayoutOrder,
            })

            local function make_mode_btn(label_name)
                local mb = library:create("TextButton", {
                    Parent          = mode_btn_holder,
                    FontFace        = library.font,
                    TextColor3      = themes.preset.text,
                    BorderColor3    = rgb(0,0,0),
                    Text            = label_name,
                    BorderSizePixel = 0,
                    TextSize        = 11,
                    ZIndex          = 52,
                    AutoButtonColor = false,
                    BackgroundColor3= themes.preset.outline,
                })
                library:apply_theme(mb, "outline", "BackgroundColor3")
                return mb
            end

            local mode_btn_none    = make_mode_btn("None")
            local mode_btn_rainbow = make_mode_btn("Rainbow")

            -- Speed slider (only useful for rainbow)
            local spd_row = library:create("Frame", {
                Parent          = picker_anim_content,
                Size            = dim2(1, 0, 0, 34),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local spd_label = library:create("TextLabel", {
                Parent          = spd_row,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = "Speed",
                BackgroundTransparency = 1,
                Position        = dim2(0, 2, 0, 2),
                Size            = dim2(0.65, 0, 0, 16),
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Left,
                TextSize        = 12,
                ZIndex          = 51,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(spd_label)

            local spd_value_lbl = library:create("TextLabel", {
                Parent          = spd_row,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = "5",
                BackgroundTransparency = 1,
                Position        = dim2(0.65, 0, 0, 2),
                Size            = dim2(0.35, -2, 0, 16),
                BorderSizePixel = 0,
                TextXAlignment  = Enum.TextXAlignment.Right,
                TextSize        = 12,
                ZIndex          = 51,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(spd_value_lbl)

            local spd_track_ol = library:create("Frame", {
                Parent          = spd_row,
                Position        = dim2(0, 0, 0, 20),
                Size            = dim2(1, 0, 0, 10),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(spd_track_ol, "outline", "BackgroundColor3")

            local spd_track_il = library:create("Frame", {
                Parent          = spd_track_ol,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                ZIndex          = 51,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(spd_track_il, "inline", "BackgroundColor3")

            local spd_track_btn = library:create("TextButton", {
                Parent          = spd_track_il,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                Text            = "",
                ZIndex          = 52,
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                BackgroundColor3= rgb(255,255,255),
            })

            local spd_fill = library:create("Frame", {
                Parent          = spd_track_btn,
                Size            = dim2(0.25, 0, 1, 0),
                BorderColor3    = rgb(0,0,0),
                BorderSizePixel = 0,
                ZIndex          = 52,
                BackgroundColor3= themes.preset.accent,
            })
            library:apply_theme(spd_fill, "accent", "BackgroundColor3")
            library:create("UIGradient", {
                Parent   = spd_fill,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(255,255,255)), rgbkey(1, rgb(167,167,167))},
            })

            local spd_dragging = false

            spd_track_btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    spd_dragging = true
                end
            end)
            spd_track_btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    spd_dragging = false
                end
            end)
            library:connection(uis.InputChanged, function(input)
                if spd_dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel   = clamp(input.Position.X - spd_track_btn.AbsolutePosition.X, 0, spd_track_btn.AbsoluteSize.X)
                    local frac  = rel / spd_track_btn.AbsoluteSize.X
                    local speed = floor(1 + frac * 19)
                    cfg.anim_speed = speed
                    spd_fill.Size  = dim2(frac, 0, 1, 0)
                    spd_value_lbl.Text = tostring(speed)
                    flags[cfg.flag].speed = speed
                    if cfg._rainbow_entry then
                        cfg._rainbow_entry.speed = speed
                    end
                end
            end)

            -- ---- Internal color update function ----
            local function apply_color()
                local c = hsv(h, s, v_val)
                swatch_btn.BackgroundColor3 = c
                sv_color.BackgroundColor3   = hsv(h, 1, 1)
                sv_cursor.Position          = dim2(s, 0, 1 - v_val, 0)
                hue_cursor.Position         = dim2(h, 0, 0, 0)
                alp_cursor.Position         = dim2(1 - a, 0, 0, 0)
                flags[cfg.flag]             = {Color = c, Transparency = a, mode = cfg.anim_mode, speed = cfg.anim_speed}
                cfg.callback(c, a)
                local r = floor(c.R * 255)
                local g = floor(c.G * 255)
                local b = floor(c.B * 255)
                rgb_tb.Text = r .. ", " .. g .. ", " .. b
            end

            function cfg.update_color(new_color, new_alpha)
                h, s, v_val = new_color:ToHSV()
                a = new_alpha or a
                apply_color()
            end

            -- Mode button logic
            local function set_mode(mode_name)
                cfg.anim_mode = mode_name
                flags[cfg.flag].mode = mode_name

                if mode_name == "None" then
                    mode_btn_none.BackgroundColor3    = themes.preset.accent
                    mode_btn_rainbow.BackgroundColor3 = themes.preset.outline
                    swatch_rainbow.BackgroundTransparency = 1
                    library.is_rainbow = false

                    -- Disable rainbow entry
                    if cfg._rainbow_entry then
                        cfg._rainbow_entry.active = false
                    end
                elseif mode_name == "Rainbow" then
                    mode_btn_none.BackgroundColor3    = themes.preset.outline
                    mode_btn_rainbow.BackgroundColor3 = themes.preset.accent
                    swatch_rainbow.BackgroundTransparency = 0.3
                    library.is_rainbow = true

                    -- Register/activate rainbow entry
                    if not cfg._rainbow_entry then
                        local entry = {
                            active = true,
                            speed  = cfg.anim_speed,
                            fn     = function(current_hue)
                                h = current_hue
                                apply_color()
                            end,
                        }
                        insert(library.rainbow_callbacks, entry)
                        cfg._rainbow_entry = entry
                    else
                        cfg._rainbow_entry.active = true
                    end
                end
            end

            mode_btn_none.MouseButton1Click:Connect(function()    set_mode("None") end)
            mode_btn_rainbow.MouseButton1Click:Connect(function() set_mode("Rainbow") end)
            set_mode("None")

            -- ---- Sat/Val dragging ----
            sv_btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging_sat = true
                end
            end)
            sv_btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging_sat = false
                end
            end)
            library:connection(uis.InputChanged, function(input)
                if dragging_sat and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel_x = clamp(input.Position.X - sv_btn.AbsolutePosition.X, 0, sv_btn.AbsoluteSize.X)
                    local rel_y = clamp(input.Position.Y - sv_btn.AbsolutePosition.Y, 0, sv_btn.AbsoluteSize.Y)
                    s     = rel_x / sv_btn.AbsoluteSize.X
                    v_val = 1 - (rel_y / sv_btn.AbsoluteSize.Y)
                    apply_color()
                end
            end)

            -- ---- Hue dragging ----
            hue_btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging_hue = true
                end
            end)
            hue_btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging_hue = false
                end
            end)
            library:connection(uis.InputChanged, function(input)
                if dragging_hue and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = clamp(input.Position.X - hue_btn.AbsolutePosition.X, 0, hue_btn.AbsoluteSize.X)
                    h = rel / hue_btn.AbsoluteSize.X
                    apply_color()
                end
            end)

            -- ---- Alpha dragging ----
            alp_btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging_alp = true
                end
            end)
            alp_btn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging_alp = false
                end
            end)
            library:connection(uis.InputChanged, function(input)
                if dragging_alp and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local rel = clamp(input.Position.X - alp_btn.AbsolutePosition.X, 0, alp_btn.AbsoluteSize.X)
                    a = 1 - (rel / alp_btn.AbsoluteSize.X)
                    apply_color()
                end
            end)

            -- RGB textbox
            rgb_tb.FocusLost:Connect(function()
                local text   = rgb_tb.Text
                local r, g, b = text:match("^%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*$")
                if r then
                    local new_c = rgb(clamp(tonumber(r),0,255), clamp(tonumber(g),0,255), clamp(tonumber(b),0,255))
                    h, s, v_val = new_c:ToHSV()
                    apply_color()
                end
            end)

            -- Show/hide picker
            function cfg.set_visible(bool)
                picker.Visible = bool
                cfg.open = bool
                if bool then
                    local abs_pos  = swatch_btn.AbsolutePosition
                    local abs_size = swatch_btn.AbsoluteSize
                    picker.Position = dim_offset(abs_pos.X, abs_pos.Y + abs_size.Y + 4)
                end
            end

            swatch_btn.MouseButton1Click:Connect(function()
                if library.current_element_open and library.current_element_open ~= cfg then
                    library.current_element_open.set_visible(false)
                    library.current_element_open.open = false
                end
                cfg.set_visible(not cfg.open)
                library.current_element_open = cfg.open and cfg or nil
            end)

            apply_color()
            activate_picker_tab("Color")

            cfg.holder = holder
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  KEYBIND
        -- ============================================================
        function library:keybind(options)
            local cfg = {
                name     = options.name or "",
                flag     = options.flag or options.name or "keybind",
                callback = options.callback or function() end,
                key      = options.key or Enum.KeyCode.Insert,
                items    = {},
            }

            flags[cfg.flag]        = {active = true, mode = "Toggle", key = cfg.key}
            config_flags[cfg.flag] = function(v)
                if type(v) == "table" and v.key then
                    cfg.key = library:convert_enum(v.key)
                    flags[cfg.flag] = {active = v.active, mode = v.mode, key = cfg.key}
                    kb_text.Text = keys[cfg.key] or tostring(cfg.key)
                end
            end

            local holder   = self.holder
            local listening= false

            local kb_outline = library:create("Frame", {
                Parent          = holder,
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(0, 40, 0, 14),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.outline,
            })
            library:apply_theme(kb_outline, "outline", "BackgroundColor3")

            local kb_inline = library:create("Frame", {
                Parent          = kb_outline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                BackgroundColor3= themes.preset.inline,
            })
            library:apply_theme(kb_inline, "inline", "BackgroundColor3")

            local kb_btn = library:create("TextButton", {
                Parent          = kb_inline,
                Position        = dim2(0, 1, 0, 1),
                BorderColor3    = rgb(0,0,0),
                Size            = dim2(1, -2, 1, -2),
                BorderSizePixel = 0,
                Text            = "",
                AutoButtonColor = false,
                BackgroundColor3= rgb(255,255,255),
            })

            local kb_grad = library:create("UIGradient", {
                Parent   = kb_btn,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(kb_grad, "contrast", "Color")

            local kb_text = library:create("TextLabel", {
                Parent          = kb_btn,
                FontFace        = library.font,
                TextColor3      = themes.preset.text,
                BorderColor3    = rgb(0,0,0),
                Text            = keys[cfg.key] or tostring(cfg.key),
                BackgroundTransparency = 1,
                Size            = dim2(1, 0, 1, 0),
                BorderSizePixel = 0,
                TextSize        = 11,
                BackgroundColor3= rgb(255,255,255),
            })
            library:apply_stroke(kb_text)

            kb_btn.MouseButton1Click:Connect(function()
                listening     = true
                kb_text.Text  = "..."
            end)

            library:connection(uis.InputBegan, function(input, gpe)
                if not listening then
                    -- Check if this is the bound key
                    if input.KeyCode == cfg.key or input.UserInputType == cfg.key then
                        cfg.callback(not flags[cfg.flag].active)
                        flags[cfg.flag].active = not flags[cfg.flag].active
                    end
                    return
                end
                if gpe then return end

                local new_key = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType

                if new_key == Enum.KeyCode.Escape then
                    listening    = false
                    kb_text.Text = keys[cfg.key] or tostring(cfg.key)
                    return
                end

                cfg.key           = new_key
                flags[cfg.flag]   = {active = flags[cfg.flag].active, mode = flags[cfg.flag].mode, key = new_key}
                kb_text.Text      = keys[new_key] or tostring(new_key)
                listening         = false

                -- Update keybind list
                if library.keybind_list then
                    local existing = library.keybind_list:FindFirstChild(cfg.flag)
                    if existing then existing:Destroy() end
                end
            end)

            cfg.holder = holder
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  PLAYERLIST
        -- ============================================================
        function library:playerlist(options)
            local cfg = {
                items = {},
            }

            local holder = self.holder

            local pl_scroll = library:create("ScrollingFrame", {
                Parent             = holder,
                BorderColor3       = rgb(0,0,0),
                Size               = dim2(1, 0, 0, 200),
                BorderSizePixel    = 0,
                BackgroundColor3   = themes.preset.high_contrast,
                ScrollBarThickness = 2,
                ScrollBarImageColor3= themes.preset.accent,
                CanvasSize         = dim2(0, 0, 0, 0),
                AutomaticCanvasSize= Enum.AutomaticSize.Y,
            })
            library:apply_theme(pl_scroll, "high_contrast", "BackgroundColor3")
            library:apply_theme(pl_scroll, "accent", "ScrollBarImageColor3")

            local pl_grad = library:create("UIGradient", {
                Parent   = pl_scroll,
                Rotation = 90,
                Color    = rgbseq{rgbkey(0, rgb(41,41,55)), rgbkey(1, rgb(35,35,47))},
            })
            library:apply_theme(pl_grad, "contrast", "Color")

            library:create("UIListLayout", {
                Parent    = pl_scroll,
                Padding   = dim(0, 0),
                SortOrder = Enum.SortOrder.LayoutOrder,
            })

            local player_frames = {}

            local function add_player(player)
                if player_frames[player] then return end

                local pf = library:create("TextButton", {
                    Parent          = pl_scroll,
                    FontFace        = library.font,
                    TextColor3      = themes.preset.text,
                    BorderColor3    = rgb(0,0,0),
                    Text            = player.Name,
                    BorderSizePixel = 0,
                    Size            = dim2(1, 0, 0, 22),
                    TextSize        = 12,
                    AutoButtonColor = false,
                    TextXAlignment  = Enum.TextXAlignment.Left,
                    BackgroundColor3= themes.preset.high_contrast,
                })
                library:apply_theme(pf, "high_contrast", "BackgroundColor3")
                library:hoverify(pf, pf)

                library:create("UIPadding", {
                    Parent       = pf,
                    PaddingLeft  = dim(0, 4),
                })

                player_frames[player] = pf

                pf.MouseButton1Click:Connect(function()
                    if library.indicator_instance then
                        library.indicator_instance.change_profile(player)
                    end
                end)
            end

            local function remove_player(player)
                if player_frames[player] then
                    player_frames[player]:Destroy()
                    player_frames[player] = nil
                end
            end

            -- Populate existing
            for _, player in next, players:GetPlayers() do
                if player ~= lp then add_player(player) end
            end

            library:connection(players.PlayerAdded,   function(p) add_player(p)    end)
            library:connection(players.PlayerRemoving, function(p) remove_player(p) end)

            cfg.holder = holder
            return setmetatable(cfg, library)
        end

        -- ============================================================
        --  ESP PREVIEW  (stub - used after main window creation)
        -- ============================================================
        function library:esp_preview(properties)
            local cfg = {items = {}, rotation = 0, objects = {}}

            lp.Character.Archivable = true
            local character = lp.Character:Clone()
            if character:FindFirstChild("Animate") then
                character.Animate:Destroy()
            end

            local items = cfg.items

            items.viewportframe = library:create("ViewportFrame", {
                Parent          = self.holder,
                BackgroundTransparency = 1,
                Size            = dim2(1, 0, 0, 220),
                BorderColor3    = rgb(0,0,0),
                ZIndex          = 1,
                Position        = dim2(0, 0, 0, 10),
                BorderSizePixel = 0,
                BackgroundColor3= rgb(255,255,255),
            })

            items.camera = library:create("Camera", {
                FieldOfView  = 70,
                CameraType   = Enum.CameraType.Track,
                Focus        = cfr(0,0,0),
                CFrame       = cfr(0,0,0),
                Parent       = ws,
            })

            items.viewportframe.CurrentCamera = items.camera
            character.Parent = items.viewportframe
            items.camera.CameraSubject = character

            library:connection(run.RenderStepped, function()
                cfg.rotation += 0.5
                character:SetPrimaryPartCFrame(
                    cfr(Vector3.new(0, 1, -6)) * angle(0, rad(cfg.rotation), 0)
                )
            end)

            cfg.holder = items.viewportframe
            return setmetatable(cfg, library)
        end

-- ============================================================
--  RETURN
-- ============================================================
return library
