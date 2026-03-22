-- DashboardManager: 繝繝・す繝･繝懊・繝蔚I讒狗ｯ峨い繝峨が繝ｳ
-- InterfaceManager縺ｨ蜷後ヱ繧ｿ繝ｼ繝ｳ縺ｧ縲ゝab縺ｮContainer縺ｫ逶ｴ謗･繧ｫ繝ｼ繝牙梛UI繧帝・鄂ｮ縺吶ｋ

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")

local DashboardManager = {}

DashboardManager.Library = nil
DashboardManager.Tab = nil

function DashboardManager:SetLibrary(library)
	self.Library = library
end

-- ===== 繝ｦ繝ｼ繝・ぅ繝ｪ繝・ぅ: Creator.New縺ｸ縺ｮ繧ｷ繝ｧ繝ｼ繝医き繝・ヨ =====
local Creator, New

local function InitCreator()
	if Creator then return end
	-- Library.GUI縺ｮ隕ｪ縺九ｉCreator繝｢繧ｸ繝･繝ｼ繝ｫ繧貞盾辣ｧ縺吶ｋ
	-- 繧｢繝峨が繝ｳ縺ｨ縺励※loadstring縺ｧ隱ｭ縺ｿ霎ｼ縺ｾ繧後ｋ縺溘ａ縲∫峩謗･require縺ｯ菴ｿ縺医↑縺・	-- 莉｣繧上ｊ縺ｫLibrary邨檎罰縺ｧ繝・・繝樊ュ蝣ｱ繧貞叙蠕励＠縲∵焔蜍輔〒UI讒狗ｯ峨☆繧・end

-- ===== 繝倥Ν繝代・髢｢謨ｰ鄒､ =====

-- Roblox繧｢繝舌ち繝ｼ縺ｮ繧ｵ繝繝阪う繝ｫ逕ｻ蜒酋RL繧貞叙蠕・local function GetAvatarUrl(userId)
	local success, url = pcall(function()
		return Players:GetUserThumbnailAsync(
			userId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)
	return success and url or ""
end

-- 迴ｾ蝨ｨ縺ｮ繧ｲ繝ｼ繝蜷阪ｒ蜿門ｾ・local function GetGameName()
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	return success and info and info.Name or "Unknown"
end

-- 繧ｵ繝ｼ繝舌・蜀・・繝励Ξ繧､繝､繝ｼ謨ｰ縺ｨ譛螟ｧ莠ｺ謨ｰ繧貞叙蠕・local function GetServerInfo()
	local playerCount = #Players:GetPlayers()
	local maxPlayers = Players.MaxPlayers
	return playerCount, maxPlayers
end

-- 繝ｪ繝ｼ繧ｸ繝ｧ繝ｳ謗ｨ螳夲ｼ・ing繝吶・繧ｹ縺ｮJP/US/EU遞句ｺｦ縺ｮ邁｡譏灘愛螳夲ｼ・local function GetRegion()
	-- Stats.Network縺ｮPing蛟､縺ｧ螟ｧ縺ｾ縺九↑繝ｪ繝ｼ繧ｸ繝ｧ繝ｳ繧呈耳螳・	local success, ping = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if not success then return "??" end
	-- 髱槫ｸｸ縺ｫ邁｡譏鍋噪縺ｪ蛻､螳夲ｼ亥ｮ滄圀縺ｮ繝ｪ繝ｼ繧ｸ繝ｧ繝九Φ繧ｰ縺ｨ縺ｯ逡ｰ縺ｪ繧具ｼ・	if ping < 80 then return "JP"
	elseif ping < 200 then return "AS"
	elseif ping < 350 then return "US"
	else return "EU" end
end

function DashboardManager:BuildDashboardTab(tab, config)
	assert(self.Library, "Must set DashboardManager.Library first")
	assert(tab, "Must pass Tab object")

	self.Tab = tab

	config = config or {}
	local gameName = config.GameName or GetGameName()
	local developer = config.Developer or "Unknown"
	local discordUrl = config.Discord or ""

	local localPlayer = Players.LocalPlayer
	local container = tab.SingleScrollFrame or tab.ContainerFrame or tab.Container
	local dashboardVisible = container.Visible
	local statsConnection

	-- ===== 繝励Ξ繝ｼ繧ｹ繧｢繧､繧ｳ繝ｳ繧定レ譎ｯ逕ｻ蜒上→縺励※驟咲ｽｮ =====
	-- ScrollingFrame縺ｮ隕ｪ・・ontainerHolder逶ｸ蠖難ｼ峨↓驟咲ｽｮ縺励ゞIListLayout縺ｮ蠖ｱ髻ｿ繧貞女縺代↑縺・ｈ縺・↓縺吶ｋ
	local backgroundParent = container.Parent

	local backgroundImage = Instance.new("ImageLabel")
	backgroundImage.Size = UDim2.fromScale(1, 1)
	backgroundImage.Position = UDim2.fromOffset(0, 0)
	backgroundImage.BackgroundTransparency = 1
	backgroundImage.ImageTransparency = 0.82
	backgroundImage.ScaleType = Enum.ScaleType.Crop
	backgroundImage.ZIndex = 0
	backgroundImage.Parent = backgroundParent

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(0, 6)
	bgCorner.Parent = backgroundImage

	-- 繧ｲ繝ｼ繝繧｢繧､繧ｳ繝ｳ繧貞虚逧・↓蜿門ｾ・	task.spawn(function()
		local success, info = pcall(function()
			return MarketplaceService:GetProductInfo(game.PlaceId)
		end)
		if success and info then
			local iconId = info.IconImageAssetId
			if iconId and iconId ~= 0 then
				backgroundImage.Image = "rbxassetid://" .. tostring(iconId)
			end
		end
	end)

	-- 閭梧勹逕ｻ蜒上・荳翫↓繧ｰ繝ｩ繝・・繧ｷ繝ｧ繝ｳ繧ｪ繝ｼ繝舌・繝ｬ繧､・郁ｦ冶ｪ肴ｧ遒ｺ菫晢ｼ・	local gradientOverlay = Instance.new("Frame")
	gradientOverlay.Size = UDim2.fromScale(1, 1)
	gradientOverlay.Position = UDim2.fromOffset(0, 0)
	gradientOverlay.BackgroundColor3 = Color3.fromRGB(15, 17, 21)
	gradientOverlay.BackgroundTransparency = 0.15
	gradientOverlay.ZIndex = 0
	gradientOverlay.Parent = backgroundParent

	local overlayCorner = Instance.new("UICorner")
	overlayCorner.CornerRadius = UDim.new(0, 6)
	overlayCorner.Parent = gradientOverlay

	local gradient = Instance.new("UIGradient")
	gradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.5),
		NumberSequenceKeypoint.new(0.4, 0.15),
		NumberSequenceKeypoint.new(1, 0),
	})
	gradient.Rotation = 90
	gradient.Parent = gradientOverlay

	-- ScrollingFrame縺ｮZIndex繧偵が繝ｼ繝舌・繝ｬ繧､繧医ｊ蜑埼擇縺ｫ險ｭ螳・	container.ZIndex = 2

	-- 繝繝・す繝･繝懊・繝峨ち繝悶′陦ｨ遉ｺ縺輔ｌ縺ｦ縺・ｋ譎ゅ・縺ｿ閭梧勹繧定｡ｨ遉ｺ
	-- ・・ontainer縺ｮVisible繝励Ο繝代ユ繧｣縺ｫ騾｣蜍包ｼ・	local function syncBackgroundVisibility()
		local isVisible = container.Visible
		dashboardVisible = isVisible
		backgroundImage.Visible = isVisible
		gradientOverlay.Visible = isVisible
		if not isVisible and statsConnection then
			statsConnection:Disconnect()
			statsConnection = nil
		end
	end
	syncBackgroundVisibility()
	container:GetPropertyChangedSignal("Visible"):Connect(syncBackgroundVisibility)

	-- ===== 繧ｫ繝ｼ繝臥函謌舌・繝ｫ繝代・ =====
	-- Section.lua縺ｨ蜷梧ｧ倥・繧ｬ繝ｩ繧ｹ繝｢繝ｼ繝輔ぅ繧ｺ繝繧ｫ繝ｼ繝峨ｒ逕滓・縺吶ｋ
	local function MakeCard(props)
		local cardFrame = Instance.new("Frame")
		cardFrame.BackgroundTransparency = 0.89
		cardFrame.Size = props.Size or UDim2.new(1, 0, 0, 100)
		cardFrame.LayoutOrder = props.LayoutOrder or 0
		cardFrame.Name = props.Name or "Card"
		cardFrame.Parent = props.Parent or container

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = cardFrame

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Transparency = 0.5
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Color = Color3.fromRGB(40, 45, 55)
		stroke.Parent = cardFrame

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 10)
		padding.PaddingBottom = UDim.new(0, 10)
		padding.PaddingLeft = UDim.new(0, 12)
		padding.PaddingRight = UDim.new(0, 12)
		padding.Parent = cardFrame

		-- 繝・・繝樣←逕ｨ・・ibrary邨檎罰・・		if self.Library and self.Library.GUI then
			-- Creator.AddThemeObject縺ｮ莉｣譖ｿ縺ｨ縺励※謇句虚縺ｧ濶ｲ繧帝←逕ｨ
			pcall(function()
				local Themes = require(self.Library.GUI.Parent) -- fallback
			end)
		end

		return cardFrame
	end

	-- 繝・く繧ｹ繝医Λ繝吶Ν逕滓・繝倥Ν繝代・
	local function MakeLabel(props)
		local label = Instance.new("TextLabel")
		label.BackgroundTransparency = 1
		label.FontFace = props.Font or Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Regular)
		label.Text = props.Text or ""
		label.TextColor3 = props.TextColor3 or Color3.fromRGB(240, 250, 255)
		label.TextSize = props.TextSize or 13
		label.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
		label.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Top
		label.Size = props.Size or UDim2.new(1, 0, 0, 16)
		label.Position = props.Position or UDim2.new(0, 0, 0, 0)
		label.RichText = props.RichText or false
		label.TextWrapped = props.TextWrapped or false
		label.TextTruncate = props.TextTruncate or Enum.TextTruncate.None
		label.Parent = props.Parent
		label.LayoutOrder = props.LayoutOrder or 0
		if props.AnchorPoint then
			label.AnchorPoint = props.AnchorPoint
		end
		return label
	end

	-- 繧ｫ繝ｼ繝峨ち繧､繝医Ν・医い繧､繧ｳ繝ｳ邨ｵ譁・ｭ・+ 繧ｿ繧､繝医Ν繝・く繧ｹ繝茨ｼ・	local function MakeCardTitle(parent, emoji, title)
		return MakeLabel({
			Text = emoji .. "  " .. title,
			TextSize = 15,
			Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextColor3 = Color3.fromRGB(240, 250, 255),
			Size = UDim2.new(1, 0, 0, 18),
			Parent = parent,
		})
	end

	-- 繧ｵ繝悶ユ繧ｭ繧ｹ繝茨ｼ郁ｪｬ譏取枚・・	local function MakeSubText(parent, text, posY)
		return MakeLabel({
			Text = text,
			TextSize = 11,
			TextColor3 = Color3.fromRGB(160, 170, 180),
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(0, posY or 24),
			TextWrapped = true,
			Parent = parent,
		})
	end

	-- 讓ｪ荳ｦ縺ｳ繧ｫ繝ｼ繝芽｡後さ繝ｳ繝・リ
	local function MakeRow(layoutOrder)
		local row = Instance.new("Frame")
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, 0, 0, 0) -- AutomaticSize縺ｧ豎ｺ螳・		row.AutomaticSize = Enum.AutomaticSize.Y
		row.LayoutOrder = layoutOrder
		row.Parent = container

		local rowLayout = Instance.new("UIListLayout")
		rowLayout.FillDirection = Enum.FillDirection.Horizontal
		rowLayout.Padding = UDim.new(0, 6)
		rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rowLayout.Parent = row

		return row
	end

	-- ===== 竭 Welcome 繝舌リ繝ｼ =====
	local welcomeCard = MakeCard({
		Size = UDim2.new(1, 0, 0, 70),
		LayoutOrder = 1,
		Name = "WelcomeCard",
	})

	local welcomeLeftWidthOffset = 192
	local welcomeRightMargin = 12
	local welcomeTimeWidth = 108

	-- 繧｢繝舌ち繝ｼ逕ｻ蜒・	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Size = UDim2.fromOffset(50, 50)
	avatarImage.Position = UDim2.fromOffset(0, 0)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Parent = welcomeCard

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(0, 8)
	avatarCorner.Parent = avatarImage

	-- 繧｢繝舌ち繝ｼ逕ｻ蜒上・髱槫酔譛溯ｪｭ縺ｿ霎ｼ縺ｿ
	task.spawn(function()
		local url = GetAvatarUrl(localPlayer.UserId)
		if url and url ~= "" then
			avatarImage.Image = url
		end
	end)

	-- 繝ｦ繝ｼ繧ｶ繝ｼ蜷阪→縺ゅ＞縺輔▽
	MakeLabel({
		Text = localPlayer.DisplayName,
		TextSize = 18,
		Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
		TextColor3 = Color3.fromRGB(240, 250, 255),
		Size = UDim2.new(1, -welcomeLeftWidthOffset, 0, 22),
		Position = UDim2.fromOffset(60, 2),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = welcomeCard,
	})

	MakeLabel({
		Text = "Welcome, " .. localPlayer.Name,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(160, 170, 180),
		Size = UDim2.new(1, -welcomeLeftWidthOffset, 0, 14),
		Position = UDim2.fromOffset(60, 28),
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = welcomeCard,
	})

	-- 譎ょ綾陦ｨ遉ｺ・亥承荳奇ｼ・	local timeLabel = MakeLabel({
		Text = "",
		TextSize = 16,
		Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextColor3 = Color3.fromRGB(200, 210, 220),
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, welcomeTimeWidth, 0, 20),
		Position = UDim2.new(1, -welcomeRightMargin, 0, 2),
		AnchorPoint = Vector2.new(1, 0),
		Parent = welcomeCard,
	})

	local dateLabel = MakeLabel({
		Text = "",
		TextSize = 11,
		TextColor3 = Color3.fromRGB(140, 150, 160),
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, welcomeTimeWidth, 0, 14),
		Position = UDim2.new(1, -welcomeRightMargin, 0, 26),
		AnchorPoint = Vector2.new(1, 0),
		Parent = welcomeCard,
	})

	-- 譎ょ綾縺ｮ螳壽悄譖ｴ譁ｰ
	task.spawn(function()
		while task.wait(1) do
			if dashboardVisible then
				local now = os.date("*t")
				timeLabel.Text = string.format("%02d : %02d : %02d", now.hour, now.min, now.sec)
				dateLabel.Text = string.format("%02d / %02d / %02d", now.year % 100, now.month, now.day)
			end
		end
	end)

	-- ===== 竭｡ Discord 陦・=====
	local row1 = MakeRow(2)

	-- Discord 繧ｫ繝ｼ繝会ｼ亥・蟷・ｼ・	local discordCard = MakeCard({
		Size = UDim2.new(1, 0, 0, 70),
		LayoutOrder = 1,
		Name = "DiscordCard",
		Parent = row1,
	})

	-- Discord繝ｭ繧ｴ繧｢繧､繧ｳ繝ｳ + 繧ｿ繧､繝医Ν
	local discordIcon = Instance.new("ImageLabel")
	discordIcon.Size = UDim2.fromOffset(18, 18)
	discordIcon.Position = UDim2.fromOffset(0, 0)
	discordIcon.BackgroundTransparency = 1
	discordIcon.Image = "rbxassetid://125393786192650"
	discordIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	discordIcon.ScaleType = Enum.ScaleType.Fit
	discordIcon.Parent = discordCard

	MakeLabel({
		Text = "Discord",
		TextSize = 15,
		Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextColor3 = Color3.fromRGB(240, 250, 255),
		Size = UDim2.new(1, -26, 0, 18),
		Position = UDim2.fromOffset(24, 0),
		Parent = discordCard,
	})
	local discordSub = MakeSubText(discordCard, "Tap to join the discord of your script.", 24)

	-- Discord繧ｫ繝ｼ繝峨・繧ｯ繝ｪ繝・け蜃ｦ逅・	local discordButton = Instance.new("TextButton")
	discordButton.Size = UDim2.fromScale(1, 1)
	discordButton.Position = UDim2.fromOffset(-12, -10)
	discordButton.BackgroundTransparency = 1
	discordButton.Text = ""
	discordButton.ZIndex = 10
	discordButton.Parent = discordCard

	discordButton.MouseButton1Click:Connect(function()
		if discordUrl and discordUrl ~= "" then
			-- 繧ｯ繝ｪ繝・・繝懊・繝峨↓繧ｳ繝斐・・医お繧ｯ繧ｹ繝励Ο繧､繝育腸蠅・畑・・			pcall(function()
				if setclipboard then
					setclipboard(discordUrl)
				elseif toclipboard then
					toclipboard(discordUrl)
				end
			end)
			if self.Library and self.Library.Notify then
				self.Library:Notify({
					Title = "Discord",
					Content = "Discord link copied to clipboard!",
					Duration = 3,
				})
			end
		end
	end)

	-- ===== 竭｢ Server 陦・=====
	local row2 = MakeRow(3)

	-- Server 繧ｫ繝ｼ繝会ｼ亥・蟷・ｼ・	local serverCard = MakeCard({
		Size = UDim2.new(1, 0, 0, 184),
		LayoutOrder = 1,
		Name = "ServerCard",
		Parent = row2,
	})
	MakeCardTitle(serverCard, "倹", "Server")

	local playerCount, maxPlayers = GetServerInfo()

	-- 繧ｲ繝ｼ繝蜷崎｡ｨ遉ｺ
	MakeLabel({
		Text = "Currently Playing " .. gameName,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(140, 150, 160),
		Size = UDim2.new(1, 0, 0, 24),
		Position = UDim2.fromOffset(0, 22),
		TextWrapped = true,
		Parent = serverCard,
	})

	-- 繧ｵ繝ｼ繝舌・諠・ｱ繧ｰ繝ｪ繝・ラ
	local statsGrid = Instance.new("Frame")
	statsGrid.Name = "StatsGrid"
	statsGrid.BackgroundTransparency = 1
	statsGrid.Position = UDim2.fromOffset(0, 52)
	statsGrid.Size = UDim2.new(1, 0, 0, 110)
	statsGrid.Parent = serverCard

	local statsLayout = Instance.new("UIGridLayout")
	statsLayout.CellPadding = UDim2.fromOffset(8, 8)
	statsLayout.CellSize = UDim2.new(0.5, -4, 0, 30)
	statsLayout.FillDirectionMaxCells = 2
	statsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
	statsLayout.Parent = statsGrid

	local function AddServerStat(label, value, col, row)
		local statFrame = Instance.new("Frame")
		statFrame.BackgroundTransparency = 1
		statFrame.LayoutOrder = row * 2 + col + 1
		statFrame.Parent = statsGrid

		MakeLabel({
			Text = label,
			TextSize = 12,
			Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextColor3 = Color3.fromRGB(220, 230, 240),
			Size = UDim2.new(1, 0, 0, 14),
			Position = UDim2.fromOffset(0, 0),
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = statFrame,
		})
		local valueLabel = MakeLabel({
			Text = value,
			TextSize = 10,
			TextColor3 = Color3.fromRGB(140, 150, 160),
			Size = UDim2.new(1, 0, 0, 24),
			Position = UDim2.fromOffset(0, 16),
			TextWrapped = true,
			Parent = statFrame,
		})
		return valueLabel
	end

	local playersValueLabel = AddServerStat("Players", playerCount .. " Player" .. (playerCount ~= 1 and "s" or "") .. " In\nThis Server", 0, 0)
	local capacityValueLabel = AddServerStat("Capacity", maxPlayers .. " Players In\ncan join.", 1, 0)

	-- FPS/Latency・亥虚逧・↓譖ｴ譁ｰ縺輔ｌ繧具ｼ・	local latencyValueLabel = AddServerStat("Latency", "... FPS\n...ms", 0, 1)
	AddServerStat("Join Script", "Tap to copy a\npastable script", 1, 1)

	-- 繝ｪ繝ｼ繧ｸ繝ｧ繝ｳ
	local region = GetRegion()
	AddServerStat("Players", "~", 0, 2)
	local regionValueLabel = AddServerStat("Region", region, 1, 2)

	-- 繧ｵ繝ｼ繝舌・諠・ｱ縺ｮ蜍慕噪譖ｴ譁ｰ・・遘偵＃縺ｨ縺ｫPlayer謨ｰ/FPS/Ping繧貞叙蠕励・蜿肴丐・・	task.spawn(function()
		local frameCount = 0
		local lastTime = tick()
		local currentFPS = 60

		-- FPS縺ｮ險育ｮ礼畑RenderStepped繝輔ャ繧ｯ
		local function ensureStatsConnection()
			if statsConnection then
				return
			end

			statsConnection = RunService.RenderStepped:Connect(function()
				if not dashboardVisible then
					return
				end
				frameCount = frameCount + 1
				local elapsed = tick() - lastTime
				if elapsed >= 1 then
					currentFPS = math.floor(frameCount / elapsed)
					frameCount = 0
					lastTime = tick()
				end
			end)
		end

		ensureStatsConnection()

		-- 2遘偵＃縺ｨ縺ｫ蜈ｨ繝・・繧ｿ繧呈峩譁ｰ
		while task.wait(2) do
			if not dashboardVisible then
				continue
			end
			if not statsConnection then
				ensureStatsConnection()
			end
			-- 繝励Ξ繧､繝､繝ｼ謨ｰ縺ｮ譖ｴ譁ｰ
			local currentPlayers = #Players:GetPlayers()
			playersValueLabel.Text = currentPlayers .. " Player" .. (currentPlayers ~= 1 and "s" or "") .. " In\nThis Server"
			capacityValueLabel.Text = Players.MaxPlayers .. " Players In\ncan join."

			-- FPS/Ping縺ｮ譖ｴ譁ｰ
			local pingStr = "?"
			pcall(function()
				pingStr = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
			end)
			latencyValueLabel.Text = currentFPS .. " FPS\n" .. pingStr
		end
	end)

	return tab
end

return DashboardManager





