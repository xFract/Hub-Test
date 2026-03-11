-- DashboardManager: ダッシュボードUI構築アドオン
-- InterfaceManagerと同パターンで、TabのContainerに直接カード型UIを配置する

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local Stats = game:GetService("Stats")

local DashboardManager = {}

DashboardManager.Library = nil

function DashboardManager:SetLibrary(library)
	self.Library = library
end

-- ===== ユーティリティ: Creator.Newへのショートカット =====
local Creator, New

local function InitCreator()
	if Creator then return end
	-- Library.GUIの親からCreatorモジュールを参照する
	-- アドオンとしてloadstringで読み込まれるため、直接requireは使えない
	-- 代わりにLibrary経由でテーマ情報を取得し、手動でUI構築する
end

-- ===== ヘルパー関数群 =====

-- Robloxアバターのサムネイル画像URLを取得
local function GetAvatarUrl(userId)
	local success, url = pcall(function()
		return Players:GetUserThumbnailAsync(
			userId,
			Enum.ThumbnailType.HeadShot,
			Enum.ThumbnailSize.Size100x100
		)
	end)
	return success and url or ""
end

-- 現在のゲーム名を取得
local function GetGameName()
	local success, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	return success and info and info.Name or "Unknown"
end

-- サーバー内のプレイヤー数と最大人数を取得
local function GetServerInfo()
	local playerCount = #Players:GetPlayers()
	local maxPlayers = Players.MaxPlayers
	return playerCount, maxPlayers
end

-- フレンド情報を集計
local function GetFriendStats()
	local localPlayer = Players.LocalPlayer
	local inServer = 0
	local online = 0
	local offline = 0
	local total = 0

	local success, friendPages = pcall(function()
		return localPlayer:GetFriendsOnline(200)
	end)

	if success and friendPages then
		for _, friend in ipairs(friendPages) do
			total = total + 1
			-- IsInSameGame フィールドで同一ゲーム内かを判定
			if friend.PlaceId == game.PlaceId then
				inServer = inServer + 1
			else
				online = online + 1
			end
		end
	end

	-- オフラインフレンド数は正確に取得できないため概算値として表示
	-- （GetFriendsOnlineはオンラインのみ返すため）
	offline = 0

	return {
		InServer = inServer,
		Online = online,
		Offline = offline,
		Total = total,
	}
end

-- エクスプロイト環境の検出
local function GetExecutorName()
	-- 主要エクスプロイト環境の識別関数を確認
	if identifyexecutor then
		local success, name = pcall(identifyexecutor)
		if success and name then
			return name
		end
	end
	-- フォールバック判定
	if syn then return "Synapse X"
	elseif fluxus then return "Fluxus"
	elseif getexecutorname then
		local s, n = pcall(getexecutorname)
		if s then return n end
	end
	return "Unknown"
end

-- リージョン推定（PingベースのJP/US/EU程度の簡易判定）
local function GetRegion()
	-- Stats.NetworkのPing値で大まかなリージョンを推定
	local success, ping = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if not success then return "??" end
	-- 非常に簡易的な判定（実際のリージョニングとは異なる）
	if ping < 80 then return "JP"
	elseif ping < 200 then return "AS"
	elseif ping < 350 then return "US"
	else return "EU" end
end

function DashboardManager:BuildDashboardTab(tab, config)
	assert(self.Library, "Must set DashboardManager.Library first")

	config = config or {}
	local gameName = config.GameName or GetGameName()
	local developer = config.Developer or "Unknown"
	local discordUrl = config.Discord or ""
	local changelog = config.Changelog or "No changelog available."
	local accountStatus = config.AccountStatus or "Coming Soon."

	local localPlayer = Players.LocalPlayer
	local container = tab.ContainerFrame or tab.Container

	-- ===== カード生成ヘルパー =====
	-- Section.luaと同様のガラスモーフィズムカードを生成する
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

		-- テーマ適用（Library経由）
		if self.Library and self.Library.GUI then
			-- Creator.AddThemeObjectの代替として手動で色を適用
			pcall(function()
				local Themes = require(self.Library.GUI.Parent) -- fallback
			end)
		end

		return cardFrame
	end

	-- テキストラベル生成ヘルパー
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
		label.Parent = props.Parent
		label.LayoutOrder = props.LayoutOrder or 0
		if props.AnchorPoint then
			label.AnchorPoint = props.AnchorPoint
		end
		return label
	end

	-- カードタイトル（アイコン絵文字 + タイトルテキスト）
	local function MakeCardTitle(parent, emoji, title)
		return MakeLabel({
			Text = emoji .. "  " .. title,
			TextSize = 15,
			Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextColor3 = Color3.fromRGB(240, 250, 255),
			Size = UDim2.new(1, 0, 0, 18),
			Parent = parent,
		})
	end

	-- サブテキスト（説明文）
	local function MakeSubText(parent, text, posY)
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

	-- 横並びカード行コンテナ
	local function MakeRow(layoutOrder)
		local row = Instance.new("Frame")
		row.BackgroundTransparency = 1
		row.Size = UDim2.new(1, 0, 0, 0) -- AutomaticSizeで決定
		row.AutomaticSize = Enum.AutomaticSize.Y
		row.LayoutOrder = layoutOrder
		row.Parent = container

		local rowLayout = Instance.new("UIListLayout")
		rowLayout.FillDirection = Enum.FillDirection.Horizontal
		rowLayout.Padding = UDim.new(0, 6)
		rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rowLayout.Parent = row

		return row
	end

	-- ===== ① Welcome バナー =====
	local welcomeCard = MakeCard({
		Size = UDim2.new(1, 0, 0, 70),
		LayoutOrder = 1,
		Name = "WelcomeCard",
	})

	-- アバター画像
	local avatarImage = Instance.new("ImageLabel")
	avatarImage.Size = UDim2.fromOffset(50, 50)
	avatarImage.Position = UDim2.fromOffset(0, 0)
	avatarImage.BackgroundTransparency = 1
	avatarImage.Parent = welcomeCard

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(0, 8)
	avatarCorner.Parent = avatarImage

	-- アバター画像の非同期読み込み
	task.spawn(function()
		local url = GetAvatarUrl(localPlayer.UserId)
		if url and url ~= "" then
			avatarImage.Image = url
		end
	end)

	-- ユーザー名とあいさつ
	MakeLabel({
		Text = "Welcome, " .. localPlayer.DisplayName,
		TextSize = 18,
		Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
		TextColor3 = Color3.fromRGB(240, 250, 255),
		Size = UDim2.new(1, -130, 0, 22),
		Position = UDim2.fromOffset(60, 2),
		Parent = welcomeCard,
	})

	MakeLabel({
		Text = "How's Your Day Going? | " .. localPlayer.Name,
		TextSize = 11,
		TextColor3 = Color3.fromRGB(160, 170, 180),
		Size = UDim2.new(1, -130, 0, 14),
		Position = UDim2.fromOffset(60, 28),
		Parent = welcomeCard,
	})

	-- 時刻表示（右上）
	local timeLabel = MakeLabel({
		Text = "",
		TextSize = 16,
		Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextColor3 = Color3.fromRGB(200, 210, 220),
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 110, 0, 20),
		Position = UDim2.new(1, -122, 0, 2),
		Parent = welcomeCard,
	})

	local dateLabel = MakeLabel({
		Text = "",
		TextSize = 11,
		TextColor3 = Color3.fromRGB(140, 150, 160),
		TextXAlignment = Enum.TextXAlignment.Right,
		Size = UDim2.new(0, 110, 0, 14),
		Position = UDim2.new(1, -122, 0, 26),
		Parent = welcomeCard,
	})

	-- 時刻の定期更新
	task.spawn(function()
		while task.wait(1) do
			local now = os.date("*t")
			timeLabel.Text = string.format("%02d : %02d : %02d", now.hour, now.min, now.sec)
			dateLabel.Text = string.format("%02d / %02d / %02d", now.year % 100, now.month, now.day)
		end
	end)

	-- ===== ② Discord / Changelog / Account 行 =====
	local row1 = MakeRow(2)

	-- Discord カード
	local discordCard = MakeCard({
		Size = UDim2.new(0.33, -4, 0, 70),
		LayoutOrder = 1,
		Name = "DiscordCard",
		Parent = row1,
	})
	MakeCardTitle(discordCard, "💬", "Discord")
	local discordSub = MakeSubText(discordCard, "Tap to join the discord of\nyour script.", 24)

	-- Discordカードのクリック処理
	local discordButton = Instance.new("TextButton")
	discordButton.Size = UDim2.fromScale(1, 1)
	discordButton.Position = UDim2.fromOffset(-12, -10)
	discordButton.BackgroundTransparency = 1
	discordButton.Text = ""
	discordButton.ZIndex = 10
	discordButton.Parent = discordCard

	discordButton.MouseButton1Click:Connect(function()
		if discordUrl and discordUrl ~= "" then
			-- クリップボードにコピー（エクスプロイト環境用）
			pcall(function()
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

	-- Changelog カード
	local changelogCard = MakeCard({
		Size = UDim2.new(0.34, -4, 0, 70),
		LayoutOrder = 2,
		Name = "ChangelogCard",
		Parent = row1,
	})
	MakeCardTitle(changelogCard, "📋", "Changelog")
	MakeSubText(changelogCard, changelog, 24)

	-- Account カード
	local accountCard = MakeCard({
		Size = UDim2.new(0.33, -4, 0, 70),
		LayoutOrder = 3,
		Name = "AccountCard",
		Parent = row1,
	})
	MakeCardTitle(accountCard, "👤", "Account")
	MakeSubText(accountCard, accountStatus, 24)

	-- ===== ③ Server / Velocity / Friends 行 =====
	local row2 = MakeRow(3)

	-- Server カード（情報量が多いため大きめ）
	local serverCard = MakeCard({
		Size = UDim2.new(0.38, -4, 0, 160),
		LayoutOrder = 1,
		Name = "ServerCard",
		Parent = row2,
	})
	MakeCardTitle(serverCard, "🌐", "Server")

	local playerCount, maxPlayers = GetServerInfo()

	-- ゲーム名表示
	MakeLabel({
		Text = "Currently Playing " .. gameName,
		TextSize = 10,
		TextColor3 = Color3.fromRGB(140, 150, 160),
		Size = UDim2.new(1, 0, 0, 12),
		Position = UDim2.fromOffset(0, 22),
		TextWrapped = true,
		Parent = serverCard,
	})

	-- サーバー情報グリッド
	local gridY = 40
	local function AddServerStat(label, value, col, row)
		local xOffset = col * 110
		local yOffset = gridY + (row * 36)

		MakeLabel({
			Text = label,
			TextSize = 12,
			Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextColor3 = Color3.fromRGB(220, 230, 240),
			Size = UDim2.new(0, 100, 0, 14),
			Position = UDim2.fromOffset(xOffset, yOffset),
			Parent = serverCard,
		})
		local valueLabel = MakeLabel({
			Text = value,
			TextSize = 10,
			TextColor3 = Color3.fromRGB(140, 150, 160),
			Size = UDim2.new(0, 100, 0, 12),
			Position = UDim2.fromOffset(xOffset, yOffset + 16),
			TextWrapped = true,
			Parent = serverCard,
		})
		return valueLabel
	end

	local playersValueLabel = AddServerStat("Players", playerCount .. " Player" .. (playerCount ~= 1 and "s" or "") .. " In\nThis Server", 0, 0)
	local capacityValueLabel = AddServerStat("Capacity", maxPlayers .. " Players In\ncan join.", 1, 0)

	-- FPSとレイテンシ
	local fpsValue = "60 FPS"
	local pingValue = "?"
	pcall(function()
		pingValue = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms"
	end)
	AddServerStat("Latency", fpsValue .. "\n" .. pingValue, 0, 1)
	AddServerStat("Join Script", "Tap to copy a\npastable script", 1, 1)

	-- リージョン
	local region = GetRegion()
	AddServerStat("Players", "~", 0, 2)
	AddServerStat("Region", region, 1, 2)

	-- Velocity カード
	local velocityCard = MakeCard({
		Size = UDim2.new(0.28, -4, 0, 160),
		LayoutOrder = 2,
		Name = "VelocityCard",
		Parent = row2,
	})

	local executorName = "Unknown"
	pcall(function()
		executorName = GetExecutorName()
	end)

	MakeCardTitle(velocityCard, "⚡", "Velocity")
	MakeSubText(velocityCard, "Your Executor Seems To Be\nSupported By This Script.", 24)
	MakeLabel({
		Text = executorName,
		TextSize = 12,
		Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
		TextColor3 = Color3.fromRGB(85, 155, 185),
		Size = UDim2.new(1, 0, 0, 16),
		Position = UDim2.fromOffset(0, 60),
		Parent = velocityCard,
	})

	-- Friends カード
	local friendsCard = MakeCard({
		Size = UDim2.new(0.34, -4, 0, 160),
		LayoutOrder = 3,
		Name = "FriendsCard",
		Parent = row2,
	})
	MakeCardTitle(friendsCard, "👥", "Friends")

	-- フレンド情報のグリッド表示
	local friendGridY = 32
	local function AddFriendStat(label, value, col, row)
		local xOffset = col * 80
		local yOffset = friendGridY + (row * 44)

		MakeLabel({
			Text = label,
			TextSize = 12,
			Font = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.SemiBold),
			TextColor3 = Color3.fromRGB(220, 230, 240),
			Size = UDim2.new(0, 75, 0, 14),
			Position = UDim2.fromOffset(xOffset, yOffset),
			Parent = friendsCard,
		})
		local valLabel = MakeLabel({
			Text = value,
			TextSize = 10,
			TextColor3 = Color3.fromRGB(140, 150, 160),
			Size = UDim2.new(0, 75, 0, 12),
			Position = UDim2.fromOffset(xOffset, yOffset + 18),
			Parent = friendsCard,
		})
		return valLabel
	end

	-- フレンド統計を非同期で取得・表示
	local inServerLabel = AddFriendStat("In Server", "...", 0, 0)
	local offlineLabel = AddFriendStat("Offline", "...", 1, 0)
	local onlineLabel = AddFriendStat("Online", "...", 0, 1)
	local totalLabel = AddFriendStat("Total", "...", 1, 1)

	task.spawn(function()
		local stats = GetFriendStats()
		inServerLabel.Text = stats.InServer .. " friends"
		offlineLabel.Text = stats.Offline .. " friends"
		onlineLabel.Text = stats.Online .. " friends"
		totalLabel.Text = stats.Total .. " friends"
	end)

	return tab
end

return DashboardManager
