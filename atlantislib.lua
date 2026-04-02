--fork of atlanta lib from unknown source.
-- variables
local uis = cloneref(game:GetService("UserInputService"))
local players = cloneref(game:GetService("Players"))
local ws = cloneref(game:GetService("Workspace"))
local http_service = cloneref(game:GetService("HttpService"))
local gui_service = cloneref(game:GetService("GuiService"))
local lighting = cloneref(game:GetService("Lighting"))
local run = cloneref(game:GetService("RunService"))
local stats = cloneref(game:GetService("Stats"))
local coregui = cloneref(game:GetService("CoreGui"))
local debris = cloneref(game:GetService("Debris"))
local tween_service = cloneref(game:GetService("TweenService"))
local sound_service = cloneref(game:GetService("SoundService"))
local starter_gui = cloneref(game:GetService("StarterGui"))
local rs = cloneref(game:GetService("ReplicatedStorage"))

local vec2 = Vector2.new
local vec3 = Vector3.new
local dim2 = UDim2.new
local dim = UDim.new 
local rect = Rect.new
local cfr = CFrame.new
local empty_cfr = cfr()
local point_object_space = empty_cfr.PointToObjectSpace
local angle = CFrame.Angles
local dim_offset = UDim2.fromOffset

local color = Color3.new
local hsv = Color3.fromHSV
local rgb = Color3.fromRGB
local hex = Color3.fromHex
local rgbseq = ColorSequence.new
local rgbkey = ColorSequenceKeypoint.new
local numseq = NumberSequence.new
local numkey = NumberSequenceKeypoint.new

local camera = ws.CurrentCamera
local lp = players.LocalPlayer 
local mouse = lp:GetMouse() 
local gui_offset = gui_service:GetGuiInset().Y

local max = math.max 
local floor = math.floor 
local min = math.min 
local abs = math.abs 
local noise = math.noise
local rad = math.rad 
local random = math.random 
local pow = math.pow 
local sin = math.sin 
local pi = math.pi 
local tan = math.tan 
local atan2 = math.atan2 
local cos = math.cos 
local round = math.round;
local clamp = math.clamp; 
local ceil = math.ceil; 
local sqrt = math.sqrt;
local acos = math.acos; 

local insert = table.insert 
local find = table.find 
local remove = table.remove
local concat = table.concat
-- 

-- library init
local library = {
	directory = "atlantis",
	folders = {
		"/fonts",
		"/configs",
		"/images"
	},
	flags = {},
	config_flags = {},
	visible_flags = {}, 
	guis = {}, 
	connections = {},   
	notifications = {},
	playerlist_data = {},

	current_tab = nil, 
	current_element_open = nil, 
	dock_button_holder = nil,  
	old_config = nil, 
	font = nil, 
	keybind_list = nil,
	binds = {}, 
	
	copied_flag = nil, 
	is_rainbow = nil,

	instances = {}, 
	drawings = {},

	display_orders = 0, 
}

local flags = library.flags
local config_flags = library.config_flags

local themes = {
	preset = {
		["outline"] = hex("#0A0A0A"),
		["inline"] = hex("#2D2D2D"),
		["accent"] = hex("#6078BE"),
		["high_contrast"] = hex("#141414"),
		["low_contrast"] = hex("#1E1E1E"),
		["text"] = hex("#B4B4B4"),
		["text_outline"] = rgb(0, 0, 0),
		["glow"] = hex("#6078BE"), 
	},

	utility = {
		["outline"] = {["BackgroundColor3"] = {}, ["Color"] = {}},
		["inline"] = {["BackgroundColor3"] = {}, ["ImageColor3"] = {}},
		["accent"] = {["BackgroundColor3"] = {}, ["TextColor3"] = {}, ["ImageColor3"] = {}, ["ScrollBarImageColor3"] = {}},
		["contrast"] = {["Color"] = {}},
		["text"] = {["TextColor3"] = {}},
		["text_outline"] = {["Color"] = {}},
		["glow"] = {["ImageColor3"] = {}}, 
		["high_contrast"] = {["BackgroundColor3"] = {}},
		["low_contrast"] = {["BackgroundColor3"] = {}}
	}, 
}

local keys = {
	[Enum.KeyCode.LeftShift] = "LS", [Enum.KeyCode.RightShift] = "RS", [Enum.KeyCode.LeftControl] = "LC",
	[Enum.KeyCode.RightControl] = "RC", [Enum.KeyCode.Insert] = "INS", [Enum.KeyCode.Backspace] = "BS",
	[Enum.KeyCode.Return] = "Ent", [Enum.KeyCode.LeftAlt] = "LA", [Enum.KeyCode.RightAlt] = "RA",
	[Enum.KeyCode.Escape] = "ESC", [Enum.KeyCode.Space] = "SPC",
}
	
library.__index = library

for _, path in next, library.folders do 
	makefolder(library.directory .. path)
end 

writefile("ffff.ttf", game:HttpGet("https://github.com/ryanoasis/nerd-fonts/blob/master/patched-fonts/JetBrainsMono/NoLigatures/Medium/JetBrainsMonoNLNerdFont-Medium.ttf"))

local tahoma = {
	name = "SmallestPixel7",
	faces = {{name = "Regular", weight = 400, style = "normal", assetId = getcustomasset("ffff.ttf")}}
}

writefile("dddd.ttf", http_service:JSONEncode(tahoma))
library.font = Font.new(getcustomasset("dddd.ttf"), Enum.FontWeight.Regular)

local config_holder 
local sgui = Instance.new("ScreenGui")
sgui.Enabled = true
sgui.Parent = gethui()
sgui.DisplayOrder = 999999

local tooltip_sgui = Instance.new("ScreenGui")
tooltip_sgui.Enabled = true
tooltip_sgui.Parent = gethui()
tooltip_sgui.DisplayOrder = 500

local notif_holder = Instance.new("ScreenGui")
notif_holder.Parent = gethui()
notif_holder.IgnoreGuiInset = true
notif_holder.DisplayOrder = 999999
notif_holder.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- MODULAR DOCK SYSTEM
library.Dock = {
    Container = nil,
    Buttons = {},
    Connections = {}
}

function library.Dock.Init(parent, position, size)
    if library.Dock.Container then return end 
    
    library.Dock.Container = library:create("Frame", {
		Parent = parent or sgui,
		Name = "AtlantisDock",
		Visible = true,
		BorderColor3 = rgb(0, 0, 0),
		AnchorPoint = vec2(0.5, 0),
		Position = position or dim2(0.5, 0, 0, 20),
		Size = size or dim2(0, 157, 0, 39),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.outline
	})
	library:apply_theme(library.Dock.Container, "outline", "BackgroundColor3")
	library:draggify(library.Dock.Container)

	local dock_inline = library:create("Frame", {
		Parent = library.Dock.Container,
		Position = dim2(0, 1, 0, 1),
		Size = dim2(1, -2, 1, -2),
		BorderSizePixel = 0,
		BackgroundColor3 = themes.preset.inline
	}) 
	library:apply_theme(dock_inline, "inline", "BackgroundColor3") 

	library.Dock.Holder = library:create("Frame", {
		Parent = dock_inline,
		Size = dim2(1, -2, 1, -2),
		Position = dim2(0, 1, 0, 1),
		BorderSizePixel = 0,
		BackgroundColor3 = rgb(255, 255, 255)
	})
	
	library:create("UIListLayout", {
		Parent = library.Dock.Holder,
		Padding = dim(0, 5),
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center
	})
    
    return library.Dock.Container
end

function library.Dock.Add(imageId, tooltipText)
    if not library.Dock.Container then library.Dock.Init() end

    local btn = library:create("ImageButton", {
        Parent = library.Dock.Holder,
        Name = tooltipText .. "DockButton",
        Size = dim2(0, 30, 0, 30),
        Image = imageId,
		BackgroundTransparency = 1,
		ImageColor3 = themes.preset.accent
    })
	library:apply_theme(btn, "accent", "ImageColor3")
	library:tool_tip({name = tooltipText, path = btn})

    table.insert(library.Dock.Buttons, btn)
    return btn
end

function library.Dock.Remove(buttonInstance)
    for i, btn in ipairs(library.Dock.Buttons) do
        if btn == buttonInstance then
            btn:Destroy()
            table.remove(library.Dock.Buttons, i)
            break
        end
    end
end

function library.Dock.WinSet(buttonInstance, targetWindow)
    if not buttonInstance or not targetWindow then return end
    
    local conn = buttonInstance.MouseButton1Click:Connect(function()
        if targetWindow.set_menu_visibility then
			targetWindow.set_menu_visibility(not targetWindow.opened)
		else
			targetWindow.Visible = not targetWindow.Visible
		end
    end)
	table.insert(library.Dock.Connections, conn)
end

function library.Dock.Destroy()
    if library.Dock.Container then
        library.Dock.Container:Destroy()
        library.Dock.Container = nil
		library.Dock.Holder = nil
    end
	for _, conn in ipairs(library.Dock.Connections) do conn:Disconnect() end
	table.clear(library.Dock.Connections)
    table.clear(library.Dock.Buttons)
end
-- END DOCK SYSTEM

-- library functions 
	function library:hoverify(hover, parent) 
		local hover_instance = library:create("Frame", {
			Parent = parent,
			BackgroundTransparency = 1,
			BorderColor3 = rgb(0, 0, 0),
			Size = dim2(1, 0, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = themes.preset.accent,
			ZIndex = 1;
		}) library:apply_theme(hover_instance, "accent", "BackgroundColor3") 

		hover.MouseEnter:Connect(function()
			library:tween(hover_instance, {BackgroundTransparency = 0}) 
		end)
		
		hover.MouseLeave:Connect(function()
			library:tween(hover_instance, {BackgroundTransparency = 1}) 
		end)

		return hover_instance;
	end 

	function library:make_resizable(frame) 
		local Frame = Instance.new("TextButton")
		Frame.Position = dim2(1, -10, 1, -10)
		Frame.Size = dim2(0, 10, 0, 10)
		Frame.Parent = frame
		Frame.BackgroundTransparency = 1 
		Frame.Text = ""

		local resizing = false 
		local start_size 
		local start 
		local og_size = frame.Size  

		Frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = true
				start = input.Position
				start_size = frame.Size
			end
		end)

		Frame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				resizing = false
			end
		end)

		library:connection(uis.InputChanged, function(input, game_event) 
			if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
				frame.Size = dim2(start_size.X.Scale, math.clamp(start_size.X.Offset + (input.Position.X - start.X), og_size.X.Offset, camera.ViewportSize.X), start_size.Y.Scale, math.clamp(start_size.Y.Offset + (input.Position.Y - start.Y), og_size.Y.Offset, camera.ViewportSize.Y))
			end
		end)
	end

	function library:draggify(frame)
		local dragging = false 
		local start_size = frame.Position
		local start 

		frame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				start = input.Position
				start_size = frame.Position

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

		library:connection(uis.InputChanged, function(input, game_event) 
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				frame.Position = dim2(0, clamp(start_size.X.Offset + (input.Position.X - start.X), 0, camera.ViewportSize.X - frame.Size.X.Offset), 0, clamp(start_size.Y.Offset + (input.Position.Y - start.Y), 0, camera.ViewportSize.Y - frame.Size.Y.Offset))
			end
		end)
	end

	function library:tween(obj, properties) 
		local tween = tween_service:Create(obj, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0, false, 0), properties):Play()
		return tween
	end 

	function library:apply_theme(instance, theme, property) 
		insert(themes.utility[theme][property], instance)
	end

	function library:update_theme(theme, color)
		for _, property in next, themes.utility[theme] do 
			for m, object in next, property do 
				if object[_] == themes.preset[theme] or object.ClassName == "UIGradient" then
					object[_] = color 
				end
			end 
		end 
		themes.preset[theme] = color 
	end 

	function library:connection(signal, callback)
		local connection = signal:Connect(callback)
		insert(library.connections, connection)
		return connection 
	end

	function library:apply_stroke(parent) 
		local stroke = library:create("UIStroke", {Parent = parent, Color = themes.preset.text_outline, LineJoinMode = Enum.LineJoinMode.Miter}) 
		library:apply_theme(stroke, "text_outline", "Color")
	end

	function library:create(instance, options)
		local ins = Instance.new(instance) 
		for prop, value in next, options do ins[prop] = value end
		if instance == "TextLabel" or instance == "TextButton" or instance == "TextBox" then 	
			library:apply_theme(ins, "text", "TextColor3")
			library:apply_stroke(ins)
		elseif instance == "ScreenGui" then 
			insert(library.guis, ins)
		end
		return ins 
	end

	function library:tool_tip(options) 
		local cfg = { name = options.name or "hi", path = options.path or nil }
		if cfg.path then 
			local watermark_outline = library:create("Frame", {
				Parent = tooltip_sgui,
				Size = dim2(0, 0, 0, 22),
				Position = dim2(0, 500, 0, 300),
				Visible = false,
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = themes.preset.outline
			})
			local watermark_inline = library:create("Frame", {Parent = watermark_outline, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = themes.preset.inline})
			local watermark_background = library:create("Frame", {Parent = watermark_inline, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = rgb(255, 255, 255)})
			local text = library:create("TextLabel", {
				Parent = watermark_background,
				FontFace = library.font,
				TextColor3 = themes.preset.text,
				Text = " " .. cfg.name .. " ",
				Size = dim2(0, 0, 1, 0),
				BackgroundTransparency = 1,
				Position = dim2(0, 0, 0, -1),
				AutomaticSize = Enum.AutomaticSize.X,
				TextSize = 12
			})
			local UIStroke = library:create("UIStroke", {Parent = text, LineJoinMode = Enum.LineJoinMode.Miter})

			cfg.path.MouseEnter:Connect(function() watermark_outline.Visible = true end)   
			cfg.path.MouseLeave:Connect(function() watermark_outline.Visible = false end)
			library:connection(uis.InputChanged, function(input)
				if watermark_outline.Visible and input.UserInputType == Enum.UserInputType.MouseMovement then
					watermark_outline.Position = dim_offset(input.Position.X + 10, input.Position.Y + 10)
				end
			end)
		end 
		return cfg
	end 

	function library:panel(options) 
		local cfg = {
			name = options.text or options.name or "Window", 
			size = options.size or dim2(0, 530, 0, 590),
			position = options.position or dim2(0, 500, 0, 500),
			anchor_point = options.anchor_point or vec2(0, 0),
			items = {},
			Tabs = {},
			Groups = {}
		}
		
		local items = cfg.items
		items.sgui = library:create("ScreenGui", {Enabled = true, Parent = gethui()})
		items.main_holder = library:create("Frame", {
			Parent = items.sgui,
			AnchorPoint = vec2(cfg.anchor_point.X, cfg.anchor_point.Y),
			Position = cfg.position,
			Active = true, 
			Size = cfg.size,
			BackgroundColor3 = themes.preset.outline
		})
		library:draggify(items.main_holder)
		library:make_resizable(items.main_holder)

		local Close = library:create( "TextButton" , {
			Parent = items.main_holder, FontFace = library.font, AnchorPoint = vec2(1, 0), Text = "X",
			Size = dim2(0, 0, 0, 0), Position = dim2(1, -7, 0, 5), BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right, AutomaticSize = Enum.AutomaticSize.XY,
			TextColor3 = themes.preset.text, TextSize = 12, ZIndex = 100
		})
		Close.MouseButton1Click:Connect(function() items.sgui.Enabled = false end)
		
		items.window_inline = library:create("Frame", {Parent = items.main_holder, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = themes.preset.accent})
		library:apply_theme(items.window_inline, "accent", "BackgroundColor3") 
		
		items.window_holder = library:create("Frame", {Parent = items.window_inline, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = rgb(255, 255, 255)})
		items.text = library:create("TextLabel", {Parent = items.window_holder, FontFace = library.font, TextColor3 = themes.preset.accent, Text = cfg.name, BackgroundTransparency = 1, Position = dim2(0, 2, 0, 4), AutomaticSize = Enum.AutomaticSize.XY, TextSize = 12})
		library:apply_theme(items.text, "accent", "TextColor3")
		
		items.outline = library:create("Frame", {Parent = items.window_holder, Position = dim2(0, 0, 0, 18), Size = dim2(1, 0, 1, -18), BackgroundColor3 = themes.preset.inline})
		library:apply_theme(items.outline, "inline", "BackgroundColor3") 
		items.inline = library:create("Frame", {Parent = items.outline, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = themes.preset.outline})
		library:apply_theme(items.inline, "outline", "BackgroundColor3") 
		items.holder = library:create("Frame", {Parent = items.inline, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = rgb(255, 255, 255)})

		items.UIPadding = library:create("UIPadding", {Parent = items.holder, PaddingTop = dim(0, 5), PaddingBottom = dim(0, 5), PaddingRight = dim(0, 5), PaddingLeft = dim(0, 5)})
		
		-- PANEL COMPONENTS
		function cfg:AddTab(tabName)
			if not self.TabHolder then
				self.TabHolder = library:create("Frame", { Parent = items.holder, BackgroundTransparency = 1, Size = dim2(1, 0, 0, 25), BorderSizePixel = 0 })
				library:create("UIListLayout", { Parent = self.TabHolder, FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 2) })
			end

			local tabBtn = library:create("TextButton", { Parent = self.TabHolder, Text = tabName, Size = dim2(0, 100, 1, 0), BackgroundColor3 = themes.preset.inline, TextColor3 = themes.preset.text })
			local tabContainer = library:create("ScrollingFrame", { Parent = items.holder, Size = dim2(1, 0, 1, -30), Position = dim2(0, 0, 0, 30), BackgroundTransparency = 1, ScrollBarThickness = 2, Visible = (#self.Tabs == 0) })
			library:create("UIListLayout", { Parent = tabContainer, Padding = dim(0, 5), SortOrder = Enum.SortOrder.LayoutOrder })

			table.insert(self.Tabs, {Button = tabBtn, Container = tabContainer})

			tabBtn.MouseButton1Click:Connect(function()
				for _, t in ipairs(self.Tabs) do
					t.Container.Visible = (t.Container == tabContainer)
					t.Button.TextColor3 = (t.Container == tabContainer) and themes.preset.accent or themes.preset.text
				end
			end)
			return tabContainer
		end

		function cfg:AddGroup(groupName, parentContainer)
			local targetParent = parentContainer or items.holder
			local groupFrame = library:create("Frame", { Parent = targetParent, Size = dim2(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = themes.preset.outline, BorderSizePixel = 0 })
			local groupLabel = library:create("TextLabel", { Parent = groupFrame, Text = groupName, Size = dim2(1, 0, 0, 20), BackgroundTransparency = 1, TextColor3 = themes.preset.text })
			local elementContainer = library:create("Frame", { Parent = groupFrame, Size = dim2(1, 0, 0, 0), Position = dim2(0, 0, 0, 20), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
			library:create("UIListLayout", { Parent = elementContainer, Padding = dim(0, 4) })
			table.insert(self.Groups, groupFrame)
			return elementContainer
		end
		
		return setmetatable(cfg, library)
	end 

	function library:window(properties)
		local window = {opened = true}            
		local opened = {}
		local blur = library:create( "BlurEffect" , {Parent = lighting, Enabled = true, Size = 15})

		function window.set_menu_visibility(bool) 
			window.opened = bool 
			if bool then 
				for _,gui in opened do gui.Enabled = true end
				opened = {}
			else
				for _,gui in library.guis do 
					if gui.Enabled then gui.Enabled = false table.insert(opened, gui) end
				end
			end
			library:tween(blur, {Size = bool and (flags["Blur Size"] or 15) or 0})
			if library.Dock.Container then library.Dock.Container.Visible = bool end
			sgui.Enabled = true
		end 

		library.Dock.Init(sgui) -- Initialize the modular dock

		local main_window = library:panel({
			name = properties and properties.name or "Atlanta | ", 
			size = dim2(0, 604, 0, 628),
			position = dim2(0, (camera.ViewportSize.X / 2) - 302 - 96, 0, (camera.ViewportSize.Y / 2) - 421 - 12),
		})

		-- Bind dock button to open main window
		local winBtn = library.Dock.Add("rbxassetid://98823308062942", main_window.name)
		library.Dock.WinSet(winBtn, window)

		local items = main_window.items
		window["tab_holder"] = library:create("Frame", {Parent = items.holder, BackgroundTransparency = 1, Size = dim2(1, 0, 0, 22), ZIndex = 5})
		library:create("UIListLayout", {Parent = window["tab_holder"], FillDirection = Enum.FillDirection.Horizontal, Padding = dim(0, 2), SortOrder = Enum.SortOrder.LayoutOrder})
		
		local section_holder = library:create("Frame", {Parent = items.holder, BackgroundTransparency = 1, Position = dim2(0, -1, 0, 19), Size = dim2(1, 0, 1, -22)})
		window["section_holder"] = section_holder
		local outline = library:create("Frame", {Parent = section_holder, Position = dim2(0, 1, 0, 1), Size = dim2(1, 0, 1, 2), BackgroundColor3 = themes.preset.outline})
		library:apply_theme(outline, "outline", "BackgroundColor3") 
		local inline = library:create("Frame", {Parent = outline, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = themes.preset.inline})
		local background = library:create("Frame", {Parent = inline, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = rgb(255, 255, 255)})
		library.section_holder = background

		local style = library:panel({name = "Style", anchor_point = vec2(0, 0), size = dim2(0, 394, 0, 464), position = dim2(0, main_window.items.main_holder.AbsolutePosition.X + main_window.items.main_holder.AbsoluteSize.X + 2, 0, main_window.items.main_holder.AbsolutePosition.Y)})
		local styleBtn = library.Dock.Add("rbxassetid://115194686863276", "Style")
		library.Dock.WinSet(styleBtn, {Visible = true, set_menu_visibility = function(v) style.items.sgui.Enabled = not style.items.sgui.Enabled end})

		local items = style.items
		local column = setmetatable(items, library):column() 
		local section = column:section({name = "Theme"})
		section:label({name = "Accent"})
		:colorpicker({name = "Accent", color = themes.preset.accent, flag = "accent", callback = function(color, alpha) library:update_theme("accent", color) end})
		section:label({name = "Glow"})
		:colorpicker({name = "Glow", color = themes.preset.glow, callback = function(color, alpha) library:update_theme("glow", color) end, flag = "Glow"})
		
		section:slider({name = "Rainbow Speed", flag = "rainbow_speed", min = 0.1, max = 10, default = 2, interval = 0.1, callback = function(val) flags["rainbow_speed"] = val end})
		
		section:slider({name = "Blur Size", flag = "Blur Size", min = 0, max = 56, default = 15, interval = 1, callback = function(int) if window.opened then blur.Size = int end end})

		return setmetatable(window, library)
	end

	function library:slider(options)
		local cfg = {
			name = options.name or nil,
			suffix = options.suffix or "",
			flag = options.flag or tostring(2^789),
			callback = options.callback or function() end, 
			visible = options.visible or true, 
			min = options.min or 0,
			max = options.max or 100,
			intervals = options.interval or 1,
			default = options.default or 10,
			dragging = false,
			value = options.default or 10, 
		} 
		-- Basic Slider Logic
		local slider_REAL = library:create("TextLabel", {Parent = self.holder, Size = dim2(1, -8, 0, 24), BackgroundTransparency = 1, Text = cfg.name .. ": " .. cfg.default})
		function cfg.set(value)
			cfg.value = math.clamp(library:round(value, cfg.intervals), cfg.min, cfg.max)
			flags[cfg.flag] = cfg.value
			slider_REAL.Text = cfg.name .. ": " .. tostring(cfg.value) .. cfg.suffix
			cfg.callback(flags[cfg.flag])
		end
		cfg.set(cfg.default)
		return setmetatable(cfg, library) 
	end 

	function library:toggle(options)
		local cfg = { name = options.name or "Toggle", flag = options.flag or tostring(random(1,9999999)), callback = options.callback or function() end, default = options.default or false, enabled = options.default }
		local toggle_holder = library:create("TextButton", {Parent = self.holder, Text = cfg.name, Size = dim2(1, -8, 0, 12)})
		function cfg.set(bool) flags[cfg.flag] = bool cfg.callback(bool) end
		toggle_holder.MouseButton1Click:Connect(function() cfg.enabled = not cfg.enabled cfg.set(cfg.enabled) end)
		cfg.set(cfg.default)
		return setmetatable(cfg, library)
	end
	
	function library:colorpicker(options)
		local parent = self.right_holder or self.holder
		local cfg = {
			name = options.name or "Color", flag = options.flag or "Colorpicker", color = options.color or color(1, 1, 1), alpha = options.alpha or 1,
			callback = options.callback or function() end, right_holder = parent,
			mode = "Animation" -- Utilizing animation mode!
		}
		
		local colorpicker_button = library:create("TextButton", {Parent = parent, Size = dim2(0, 24, 0, 14), BackgroundColor3 = cfg.color})
		
		local colorpicker_holder = library:create("Frame", {Parent = sgui, Position = dim2(0, 0, 0, 0), Size = dim2(0, 190, 0, 240), Visible = false, ZIndex = 10})
		local color_tab = library:create("Frame", {Parent = colorpicker_holder, Size = dim2(1, 0, 1, -25), Position = dim2(0, 0, 0, 25)})
		local anim_tab = library:create("Frame", {Parent = colorpicker_holder, Size = dim2(1, 0, 1, -25), Position = dim2(0, 0, 0, 25), Visible = false})

		local tabs_container = library:create("Frame", {Parent = colorpicker_holder, Size = dim2(1, 0, 0, 25)})
		library:create("UIListLayout", {Parent = tabs_container, FillDirection = Enum.FillDirection.Horizontal})
		local btnColor = library:create("TextButton", {Parent = tabs_container, Text = "Color", Size = dim2(0.5, 0, 1, 0)})
		local btnAnim = library:create("TextButton", {Parent = tabs_container, Text = "Animation", Size = dim2(0.5, 0, 1, 0)})

		btnColor.MouseButton1Click:Connect(function() color_tab.Visible = true anim_tab.Visible = false end)
		btnAnim.MouseButton1Click:Connect(function() color_tab.Visible = false anim_tab.Visible = true end)

		local anim_type = "None"
		local btnRainbow = library:create("TextButton", {Parent = anim_tab, Text = "Rainbow", Size = dim2(1, 0, 0, 20)})
		local btnFlashing = library:create("TextButton", {Parent = anim_tab, Text = "Flashing", Size = dim2(1, 0, 0, 20), Position = dim2(0, 0, 0, 25)})
		
		btnRainbow.MouseButton1Click:Connect(function() anim_type = (anim_type == "Rainbow") and "None" or "Rainbow" end)
		btnFlashing.MouseButton1Click:Connect(function() anim_type = (anim_type == "Flashing") and "None" or "Flashing" end)

		function cfg.set_visible(bool)
			colorpicker_holder.Visible = bool
			if bool then colorpicker_holder.Position = dim2(0, colorpicker_button.AbsolutePosition.X, 0, colorpicker_button.AbsolutePosition.Y + 20) end
		end 

		colorpicker_button.MouseButton1Click:Connect(function() cfg.open = not cfg.open cfg.set_visible(cfg.open) end)

		function cfg.set(color, alpha)
			cfg.color = color or cfg.color
			cfg.alpha = alpha or cfg.alpha
			colorpicker_button.BackgroundColor3 = cfg.color
			flags[cfg.flag] = {Color = cfg.color, Transparency = cfg.alpha}
			cfg.callback(cfg.color, cfg.alpha)
		end

		task.spawn(function()
			while true do 
				task.wait()
				if anim_type ~= "None" then
					local speed = flags["rainbow_speed"] or 2
					local t = tick() * speed
					if anim_type == "Rainbow" then
						cfg.set(hsv(math.abs(math.sin(t)), 1, 1), cfg.alpha)
					elseif anim_type == "Flashing" then
						local flsh = math.floor(t) % 2 == 0
						cfg.set(flsh and rgb(255,255,255) or rgb(0,0,0), cfg.alpha)
					end
				end
			end     
		end)

		cfg.set(cfg.color, cfg.alpha)
		return setmetatable(cfg, library) 
	end

	-- Core Structural Functions for Sections
	function library:column(path) 
		local cfg = {holder = library:create("Frame", {Parent = path or self.holder, BackgroundTransparency = 1, Size = dim2(1, 0, 1, 0)})}
		library:create("UIListLayout", {Parent = cfg.holder, Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
		return setmetatable(cfg, library) 
	end

	function library:section(options)
		local cfg = {name = options.name or "Section"}
		local section = library:create("Frame", {Parent = self.holder, Size = dim2(1, 0, 1, 0), BackgroundColor3 = themes.preset.inline}) 
		local background = library:create("Frame", {Parent = section, Position = dim2(0, 1, 0, 1), Size = dim2(1, -2, 1, -2), BackgroundColor3 = rgb(255, 255, 255)})
		cfg.holder = library:create("Frame", {Parent = background, Size = dim2(1, 0, 0, 0)})
		library:create("UIListLayout", {Parent = cfg.holder, Padding = dim(0, 4), SortOrder = Enum.SortOrder.LayoutOrder})
		return setmetatable(cfg, library)
	end
	
	function library:label(options)
		local cfg = {name = options.text or options.name or "Label"}
		local TextLabel = library:create("TextLabel", {Parent = self.holder, Text = cfg.name, Size = dim2(1, -8, 0, 12), BackgroundTransparency = 1})
		function cfg.set(text) TextLabel.Text = text end 
		return setmetatable(cfg, library)   
	end 

return library, themes
