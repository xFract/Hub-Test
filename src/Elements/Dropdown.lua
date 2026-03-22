local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local Camera = game:GetService("Workspace").CurrentCamera

local Root = script.Parent.Parent
local Creator = require(Root.Creator)
local Flipper = require(Root.Packages.Flipper)

local New = Creator.New
local Components = Root.Components

local Element = {}
Element.__index = Element
Element.__type = "Dropdown"

local CLICK_DRAG_THRESHOLD = 6

local function normalizeMultiValue(values, selectedValues)
	local normalized = {}

	if type(selectedValues) ~= "table" then
		return normalized
	end

	for value in next, selectedValues do
		if table.find(values, value) then
			normalized[value] = true
		end
	end

	return normalized
end

local function isSameSelection(currentValue, nextValue, isMulti)
	if isMulti then
		for value in next, currentValue do
			if not nextValue[value] then
				return false
			end
		end

		for value in next, nextValue do
			if not currentValue[value] then
				return false
			end
		end

		return true
	end

	return currentValue == nextValue
end

function Element:New(Idx, Config)
	local Library = self.Library

	local Dropdown = {
		Values = Config.Values,
		Value = Config.Default,
		Multi = Config.Multi,
		Buttons = {},
		ButtonsBuilt = false,
		Opened = false,
		Type = "Dropdown",
		Callback = Config.Callback or function() end,
	}

	local DropdownFrame = require(Components.Element)(Config.Title, Config.Description, self.Container, false)
	DropdownFrame.DescLabel.Size = UDim2.new(1, -170, 0, 14)

	Dropdown.SetTitle = DropdownFrame.SetTitle
	Dropdown.SetDesc = DropdownFrame.SetDesc

	-- 驕ｸ謚樔ｸｭ縺ｮ蛟､繧定｡ｨ遉ｺ縺吶ｋ繝ｩ繝吶Ν
	local DropdownDisplay = New("TextLabel", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
		Text = "Value",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		Size = UDim2.new(1, -30, 0, 14),
		Position = UDim2.new(0, 8, 0.5, 0),
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ThemeTag = {
			TextColor3 = "Text",
		},
	})

	-- 荳贋ｸ狗泙蜊ｰ繧｢繧､繧ｳ繝ｳ・・hevrons-up-down縺ｫ逶ｸ蠖薙☆繧区枚蟄苓｡ｨ險假ｼ・	local DropdownIco = New("TextLabel", {
		Text = "竍・,
		TextSize = 14,
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
		Size = UDim2.fromOffset(16, 16),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		BackgroundTransparency = 1,
		ThemeTag = {
			TextColor3 = "SubText",
		},
	})

	-- 繝峨Ο繝・・繝繧ｦ繝ｳ縺ｮ繝医Μ繧ｬ繝ｼ繝懊ち繝ｳ
	local DropdownInner = New("TextButton", {
		Size = UDim2.fromOffset(160, 30),
		Position = UDim2.new(1, -10, 0.5, 0),
		AnchorPoint = Vector2.new(1, 0.5),
		BackgroundTransparency = 0.9,
		Parent = DropdownFrame.Frame,
		ThemeTag = {
			BackgroundColor3 = "DropdownFrame",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 5),
		}),
		New("UIStroke", {
			Transparency = 0.5,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "InElementBorder",
			},
		}),
		DropdownIco,
		DropdownDisplay,
	})

	-- ===== 繝昴ャ繝励い繝・・繝ｪ繧ｹ繝亥・縺ｮ讀懃ｴ｢繝舌・ =====
	local SearchIndicator = New("Frame", {
		Size = UDim2.new(1, -4, 0, 1),
		Position = UDim2.new(0, 2, 1, 0),
		AnchorPoint = Vector2.new(0, 1),
		BackgroundTransparency = 0,
		ThemeTag = {
			BackgroundColor3 = "Accent",
		},
	})

	local SearchBox = New("TextBox", {
		FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
		PlaceholderText = "Search...",
		Text = "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		ClearTextOnFocus = false,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -16, 1, 0),
		Position = UDim2.fromOffset(8, 0),
		ThemeTag = {
			TextColor3 = "Text",
			PlaceholderColor3 = "SubText",
		},
	})

	local SearchBarFrame = New("Frame", {
		Size = UDim2.new(1, -10, 0, 28),
		Position = UDim2.fromOffset(5, 5),
		BackgroundTransparency = 0,
		ThemeTag = {
			BackgroundColor3 = "DropdownSearch",
		},
	}, {
		New("UICorner", {
			CornerRadius = UDim.new(0, 4),
		}),
		SearchIndicator,
		SearchBox,
	})

	-- ===== 繧ｹ繧ｯ繝ｭ繝ｼ繝ｫ蜿ｯ閭ｽ縺ｪ驕ｸ謚櫁い繝ｪ繧ｹ繝・=====
	local DropdownListLayout = New("UIListLayout", {
		Padding = UDim.new(0, 3),
	})

	local DropdownScrollFrame = New("ScrollingFrame", {
		-- 讀懃ｴ｢繝舌・(28px) + 荳贋ｽ咏區(5px) + 髢馴囈(5px) = 38px蛻・□縺台ｸ翫°繧臥ｩｺ縺代ｋ
		Size = UDim2.new(1, -5, 1, -43),
		Position = UDim2.fromOffset(5, 38),
		BackgroundTransparency = 1,
		BottomImage = "rbxassetid://6889812791",
		MidImage = "rbxassetid://6889812721",
		TopImage = "rbxassetid://6276641225",
		ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
		ScrollBarImageTransparency = 0.95,
		ScrollBarThickness = 4,
		BorderSizePixel = 0,
		CanvasSize = UDim2.fromScale(0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		HorizontalScrollBarInset = Enum.ScrollBarInset.Always,
	}, {
		DropdownListLayout,
	})

	-- 繝昴ャ繝励い繝・・縺ｮ螟匁棧・・ropdownHolder・・	local DropdownHolderFrame = New("Frame", {
		Size = UDim2.fromScale(1, 0.6),
		ThemeTag = {
			BackgroundColor3 = "DropdownHolder",
		},
	}, {
		SearchBarFrame,
		DropdownScrollFrame,
		New("UICorner", {
			CornerRadius = UDim.new(0, 7),
		}),
		New("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			ThemeTag = {
				Color = "DropdownBorder",
			},
		}),
		-- 繝峨Ο繝・・繧ｷ繝｣繝峨え
		New("ImageLabel", {
			BackgroundTransparency = 1,
			Image = "http://www.roblox.com/asset/?id=5554236805",
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(23, 23, 277, 277),
			Size = UDim2.fromScale(1, 1) + UDim2.fromOffset(30, 30),
			Position = UDim2.fromOffset(-15, -15),
			ImageColor3 = Color3.fromRGB(0, 0, 0),
			ImageTransparency = 0.1,
		}),
	})

	-- 繝昴ャ繝励い繝・・縺ｮ繧ｭ繝｣繝ｳ繝舌せ・井ｽ咲ｽｮ蛻ｶ蠕｡逕ｨ・・	local DropdownHolderCanvas = New("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(170, 300),
		Parent = self.Library.GUI,
		Visible = false,
	}, {
		DropdownHolderFrame,
		New("UISizeConstraint", {
			MinSize = Vector2.new(170, 0),
		}),
	})
	table.insert(Library.OpenFrames, DropdownHolderCanvas)

	-- 繝昴ャ繝励い繝・・繧偵ラ繝ｭ繝・・繝繧ｦ繝ｳ繝懊ち繝ｳ縺ｮ逶ｴ荳九↓驟咲ｽｮ縺吶ｋ
	local function RecalculateListPosition()
		local buttonPos = DropdownInner.AbsolutePosition
		local buttonSize = DropdownInner.AbsoluteSize

		-- 繝懊ち繝ｳ逶ｴ荳九ｒ蝓ｺ貅紋ｽ咲ｽｮ縺ｨ縺吶ｋ
		local targetY = buttonPos.Y + buttonSize.Y + 2
		local targetX = buttonPos.X

		-- 逕ｻ髱｢荳九↓縺ｯ縺ｿ蜃ｺ縺吝ｴ蜷医・荳頑婿蜷代↓螻暮幕縺吶ｋ
		if targetY + DropdownHolderCanvas.AbsoluteSize.Y > Camera.ViewportSize.Y - 10 then
			targetY = buttonPos.Y - DropdownHolderCanvas.AbsoluteSize.Y - 2
		end

		DropdownHolderCanvas.Position = UDim2.fromOffset(targetX, targetY)
	end

	-- 繝ｪ繧ｹ繝医・讓ｪ蟷・ｒ繝懊ち繝ｳ蟷・↓蜷医ｏ縺帙▽縺､縲√ユ繧ｭ繧ｹ繝亥ｹ・ｂ閠・・縺吶ｋ
	local ListSizeX = 0
	-- 陦ｨ遉ｺ荳企剞繧・鬆・岼蛻・↓蛻ｶ髯舌☆繧具ｼ亥推32px + padding 3px = 35px/鬆・岼・・	local MAX_VISIBLE_ITEMS = 5
	local ITEM_HEIGHT = 35
	local SEARCH_BAR_HEIGHT = 43 -- 讀懃ｴ｢繝舌・(28px) + 荳贋ｽ咏區(5px) + 髢馴囈(10px)
	local MAX_LIST_HEIGHT = (MAX_VISIBLE_ITEMS * ITEM_HEIGHT) + SEARCH_BAR_HEIGHT + 10

	local function RecalculateListSize()
		local minWidth = math.max(DropdownInner.AbsoluteSize.X, ListSizeX, 170)
		-- 繧ｳ繝ｳ繝・Φ繝・・菴薙・鬮倥＆・域､懃ｴ｢繝舌・ + 繝ｪ繧ｹ繝磯・岼 + 菴咏區・・		local contentHeight = DropdownListLayout.AbsoluteContentSize.Y + SEARCH_BAR_HEIGHT + 10
		-- 5鬆・岼蛻・ｒ雜・∴繧句ｴ蜷医・繧ｹ繧ｯ繝ｭ繝ｼ繝ｫ蜿ｯ閭ｽ縺ｫ縺吶ｋ
		DropdownHolderCanvas.Size = UDim2.fromOffset(minWidth, math.min(contentHeight, MAX_LIST_HEIGHT))
	end

	local function RecalculateCanvasSize()
		DropdownScrollFrame.CanvasSize = UDim2.fromOffset(0, DropdownListLayout.AbsoluteContentSize.Y)
	end

	RecalculateListPosition()
	RecalculateListSize()

	Creator.AddSignal(DropdownInner:GetPropertyChangedSignal("AbsolutePosition"), RecalculateListPosition)

	Creator.AddSignal(DropdownInner.MouseButton1Click, function()
		if Dropdown.Opened then
			Dropdown:Close()
		else
			Dropdown:Open()
		end
	end)

	-- 繝昴ャ繝励い繝・・螟悶け繝ｪ繝・け縺ｧ髢峨§繧句愛螳夲ｼ医ラ繝ｭ繝・・繝繧ｦ繝ｳ繝懊ち繝ｳ閾ｪ菴薙・繧ｯ繝ｪ繝・け縺ｯ髯､螟厄ｼ・	Creator.AddSignal(UserInputService.InputBegan, function(Input)
		if
			Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch
		then
			-- 繝峨Ο繝・・繝繧ｦ繝ｳ繝懊ち繝ｳ荳翫・繧ｯ繝ｪ繝・け縺ｯ MouseButton1Click 縺ｫ莉ｻ縺帙ｋ縺溘ａ髯､螟悶☆繧・			local btnPos, btnSize = DropdownInner.AbsolutePosition, DropdownInner.AbsoluteSize
			local isOnButton = Mouse.X >= btnPos.X
				and Mouse.X <= btnPos.X + btnSize.X
				and Mouse.Y >= btnPos.Y
				and Mouse.Y <= btnPos.Y + btnSize.Y
			if isOnButton then
				return
			end

			local AbsPos, AbsSize = DropdownHolderFrame.AbsolutePosition, DropdownHolderFrame.AbsoluteSize
			if
				Mouse.X < AbsPos.X
				or Mouse.X > AbsPos.X + AbsSize.X
				or Mouse.Y < (AbsPos.Y - 20 - 1)
				or Mouse.Y > AbsPos.Y + AbsSize.Y
			then
				Dropdown:Close()
			end
		end
	end)

	-- ===== 讀懃ｴ｢繝輔ぅ繝ｫ繧ｿ繝ｪ繝ｳ繧ｰ蜃ｦ逅・=====
	local function FilterDropdownList(searchText)
		local lowerSearch = string.lower(searchText)
		for ButtonInstance, Table in next, Dropdown.Buttons do
			if ButtonInstance:FindFirstChild("ButtonLabel") then
				local labelText = string.lower(ButtonInstance.ButtonLabel.Text)
				-- 讀懃ｴ｢繝・く繧ｹ繝医′遨ｺ縺ｪ繧牙・陦ｨ遉ｺ縲√◎縺・〒縺ｪ縺代ｌ縺ｰ驛ｨ蛻・ｸ閾ｴ縺ｧ繝輔ぅ繝ｫ繧ｿ
				local shouldShow = (lowerSearch == "" or string.find(labelText, lowerSearch, 1, true) ~= nil)
				ButtonInstance.Visible = shouldShow
			end
		end
		RecalculateCanvasSize()
		RecalculateListSize()
		RecalculateListPosition()
	end

	Creator.AddSignal(SearchBox:GetPropertyChangedSignal("Text"), function()
		FilterDropdownList(SearchBox.Text)
	end)

	local ScrollFrame = self.ScrollFrame
	local function EnsureButtonsBuilt()
		if Dropdown.ButtonsBuilt then
			return
		end

		Dropdown:BuildDropdownList()
	end

	function Dropdown:Open()
		EnsureButtonsBuilt()
		Dropdown.Opened = true
		ScrollFrame.ScrollingEnabled = false
		-- 讀懃ｴ｢繝・く繧ｹ繝医ｒ繧ｯ繝ｪ繧｢縺励※蜈ｨ鬆・岼繧定｡ｨ遉ｺ
		SearchBox.Text = ""
		FilterDropdownList("")
		DropdownHolderCanvas.Visible = true
		RecalculateListPosition()
		TweenService:Create(
			DropdownHolderFrame,
			TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
			{ Size = UDim2.fromScale(1, 1) }
		):Play()
	end

	function Dropdown:Close()
		Dropdown.Opened = false
		ScrollFrame.ScrollingEnabled = true
		DropdownHolderFrame.Size = UDim2.fromScale(1, 0.6)
		DropdownHolderCanvas.Visible = false
		SearchBox:ReleaseFocus()
	end

	function Dropdown:Display()
		local Values = Dropdown.Values
		local Str = ""

		if Config.Multi then
			for Idx, Value in next, Values do
				if Dropdown.Value[Value] then
					Str = Str .. Value .. ", "
				end
			end
			Str = Str:sub(1, #Str - 2)
		else
			Str = Dropdown.Value or ""
		end

		DropdownDisplay.Text = (Str == "" and "--" or Str)
	end

	function Dropdown:RefreshButtons()
		for _, ButtonData in next, Dropdown.Buttons do
			ButtonData:UpdateButton()
		end
	end

	function Dropdown:GetActiveValues()
		if Config.Multi then
			local T = {}

			for Value, Bool in next, Dropdown.Value do
				table.insert(T, Value)
			end

			return T
		else
			return Dropdown.Value and 1 or 0
		end
	end

	function Dropdown:BuildDropdownList()
		local Values = Dropdown.Values
		local Buttons = {}

		for _, Element in next, DropdownScrollFrame:GetChildren() do
			if not Element:IsA("UIListLayout") then
				Element:Destroy()
			end
		end

		local Count = 0

		for Idx, Value in next, Values do
			local Table = {}

			Count = Count + 1

			-- 驕ｸ謚樒憾諷九ｒ遉ｺ縺吝ｷｦ遶ｯ縺ｮ繧｢繧ｯ繧ｻ繝ｳ繝医ヰ繝ｼ
			local ButtonSelector = New("Frame", {
				Size = UDim2.fromOffset(4, 14),
				BackgroundColor3 = Color3.fromRGB(76, 194, 255),
				Position = UDim2.fromOffset(-1, 16),
				AnchorPoint = Vector2.new(0, 0.5),
				ThemeTag = {
					BackgroundColor3 = "Accent",
				},
			}, {
				New("UICorner", {
					CornerRadius = UDim.new(0, 2),
				}),
			})

			local ButtonLabel = New("TextLabel", {
				FontFace = Font.new("rbxasset://fonts/families/GothamSSm.json"),
				Text = Value,
				TextColor3 = Color3.fromRGB(200, 200, 200),
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundColor3 = Color3.fromRGB(255, 255, 255),
				AutomaticSize = Enum.AutomaticSize.Y,
				BackgroundTransparency = 1,
				Size = UDim2.fromScale(1, 1),
				Position = UDim2.fromOffset(10, 0),
				Name = "ButtonLabel",
				ThemeTag = {
					TextColor3 = "Text",
				},
			})

			local Button = New("TextButton", {
				Size = UDim2.new(1, -5, 0, 32),
				BackgroundTransparency = 1,
				ZIndex = 23,
				Text = "",
				Parent = DropdownScrollFrame,
				ThemeTag = {
					BackgroundColor3 = "DropdownOption",
				},
			}, {
				ButtonSelector,
				ButtonLabel,
				New("UICorner", {
					CornerRadius = UDim.new(0, 6),
				}),
			})

			local Selected

			if Config.Multi then
				Selected = Dropdown.Value[Value]
			else
				Selected = Dropdown.Value == Value
			end

			local BackMotor, SetBackTransparency = Creator.SpringMotor(1, Button, "BackgroundTransparency")
			local SelMotor, SetSelTransparency = Creator.SpringMotor(1, ButtonSelector, "BackgroundTransparency")
			local SelectorSizeMotor = Flipper.SingleMotor.new(6)

			SelectorSizeMotor:onStep(function(value)
				ButtonSelector.Size = UDim2.new(0, 4, 0, value)
			end)

			Creator.AddSignal(Button.MouseEnter, function()
				SetBackTransparency(Selected and 0.85 or 0.89)
			end)
			Creator.AddSignal(Button.MouseLeave, function()
				SetBackTransparency(Selected and 0.89 or 1)
			end)
			Creator.AddSignal(Button.MouseButton1Down, function()
				SetBackTransparency(0.92)
			end)
			Creator.AddSignal(Button.MouseButton1Up, function()
				SetBackTransparency(Selected and 0.85 or 0.89)
			end)

			function Table:UpdateButton()
				if Config.Multi then
					Selected = Dropdown.Value[Value]
					if Selected then
						SetBackTransparency(0.89)
					end
				else
					Selected = Dropdown.Value == Value
					SetBackTransparency(Selected and 0.89 or 1)
				end

				SelectorSizeMotor:setGoal(Flipper.Spring.new(Selected and 14 or 6, { frequency = 6 }))
				SetSelTransparency(Selected and 0 or 1)
			end

			local function CommitSelection()
				local Try = not Selected

				if Dropdown:GetActiveValues() == 1 and not Try and not Config.AllowNull then
					return
				end

				if Config.Multi then
					Selected = Try
					Dropdown.Value[Value] = Selected and true or nil
				else
					Selected = Try
					Dropdown.Value = Selected and Value or nil

					for _, OtherButton in next, Buttons do
						OtherButton:UpdateButton()
					end
				end

				Table:UpdateButton()
				Dropdown:Display()

				Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
				Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
			end

			local pressInput
			local pressPosition
			local pressCanvasPosition
			local dragging = false
			local function UpdateDraggingState(currentPosition)
				if not pressPosition or not pressCanvasPosition then
					return
				end

				local delta = currentPosition - pressPosition
				local canvasDelta = DropdownScrollFrame.CanvasPosition - pressCanvasPosition
				if math.abs(delta.X) > CLICK_DRAG_THRESHOLD
					or math.abs(delta.Y) > CLICK_DRAG_THRESHOLD
					or math.abs(canvasDelta.X) > 0
					or math.abs(canvasDelta.Y) > CLICK_DRAG_THRESHOLD
				then
					dragging = true
				end
			end

			Creator.AddSignal(Button.InputBegan, function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.Touch
				then
					pressInput = Input
					pressPosition = Input.Position
					pressCanvasPosition = DropdownScrollFrame.CanvasPosition
					dragging = false
				end
			end)

			Creator.AddSignal(Button.InputChanged, function(Input)
				if Input ~= pressInput or not pressPosition then
					return
				end

				UpdateDraggingState(Input.Position)
			end)

			Creator.AddSignal(UserInputService.InputChanged, function(Input)
				if Input ~= pressInput or not pressPosition then
					return
				end

				UpdateDraggingState(Input.Position)
			end)

			Creator.AddSignal(Button.InputEnded, function(Input)
				if Input ~= pressInput then
					return
				end

				UpdateDraggingState(Input.Position)
				local shouldCommit = not dragging
				pressInput = nil
				pressPosition = nil
				pressCanvasPosition = nil
				dragging = false

				if shouldCommit then
					CommitSelection()
				end
			end)

			Buttons[Button] = Table
		end

		ListSizeX = 0
		for Button, Table in next, Buttons do
			if Button.ButtonLabel then
				if Button.ButtonLabel.TextBounds.X > ListSizeX then
					ListSizeX = Button.ButtonLabel.TextBounds.X
				end
			end
		end
		ListSizeX = ListSizeX + 30

		Dropdown.Buttons = Buttons
		Dropdown.ButtonsBuilt = true
		Dropdown:RefreshButtons()
		Dropdown:Display()
		RecalculateCanvasSize()
		RecalculateListSize()
	end

	function Dropdown:SetValues(NewValues)
		if NewValues then
			Dropdown.Values = NewValues
		end

		if Dropdown.ButtonsBuilt then
			Dropdown:BuildDropdownList()
		else
			Dropdown:Display()
		end
	end

	function Dropdown:OnChanged(Func)
		Dropdown.Changed = Func
		Func(Dropdown.Value)
	end

	function Dropdown:SetValue(Val)
		local nextValue

		if Dropdown.Multi then
			nextValue = normalizeMultiValue(Dropdown.Values, Val)
		else
			if not Val then
				nextValue = nil
			elseif table.find(Dropdown.Values, Val) then
				nextValue = Val
			else
				nextValue = Dropdown.Value
			end
		end

		if isSameSelection(Dropdown.Value, nextValue, Dropdown.Multi) then
			return
		end

		Dropdown.Value = nextValue
		if Dropdown.ButtonsBuilt then
			Dropdown:RefreshButtons()
		end
		Dropdown:Display()

		Library:SafeCallback(Dropdown.Callback, Dropdown.Value)
		Library:SafeCallback(Dropdown.Changed, Dropdown.Value)
	end

	function Dropdown:Destroy()
		DropdownFrame:Destroy()
		Library.Options[Idx] = nil
	end

	Dropdown:Display()

	local Defaults = {}

	if type(Config.Default) == "string" then
		local Idx = table.find(Dropdown.Values, Config.Default)
		if Idx then
			table.insert(Defaults, Idx)
		end
	elseif type(Config.Default) == "table" then
		for _, Value in next, Config.Default do
			local Idx = table.find(Dropdown.Values, Value)
			if Idx then
				table.insert(Defaults, Idx)
			end
		end
	elseif type(Config.Default) == "number" and Dropdown.Values[Config.Default] ~= nil then
		table.insert(Defaults, Config.Default)
	end

	if next(Defaults) then
		for i = 1, #Defaults do
			local Index = Defaults[i]
			if Config.Multi then
				if type(Dropdown.Value) ~= 'table' then
					Dropdown.Value = {}
				end
				Dropdown.Value[Dropdown.Values[Index]] = true
			else
				Dropdown.Value = Dropdown.Values[Index]
			end

			if not Config.Multi then
				break
			end
		end

		Dropdown:Display()
	end

	Library.Options[Idx] = Dropdown
	return Dropdown
end

return Element


