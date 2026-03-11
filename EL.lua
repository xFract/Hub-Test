-- ==============================================
-- 📜 Fract-Hub (Fluentベース) 利用可能な全要素と使用例
-- ==============================================
-- 開発用のテンプレート集です。コピー＆ペーストして活用できます。
-- ==============================================

local Fluent = loadstring(game:HttpGet("https://raw.githubusercontent.com/xFract/Fract-Hub/master/dist/main.lua"))()

-- ==============================================
-- 🪟 1. ウィンドウの作成 (Window)
-- ==============================================
local Window = Fluent:CreateWindow({
    Title = "Fract Hub",           -- ヘッダーのメインタイトル
    SubTitle = "Element Catalog",  -- ヘッダーのサブタイトル
    TabWidth = 160,                -- 左側タブリストの横幅
    Size = UDim2.fromOffset(520, 380), -- 起動時のウィンドウサイズ
    Acrylic = true,                -- 背景のぼかし効果（透明感のあるUI）
    Theme = "Cyan",                -- 初期テーマ (Dark, Light, Cyan, Rose, Amethyst, Aqua 等)
    Logo = "rbxassetid://92450040427767", -- オリジナルロゴの画像ID（省略可）
    MinimizeKey = Enum.KeyCode.LeftControl -- ウィンドウの表示/非表示を切り替えるキー
})

-- ==============================================
-- 📑 2. タブとセクションの作成 (Tabs & Sections)
-- ==============================================

-- タブ間の区切りとして見出し（セクションヘッダー）を追加
Window:AddTabSection("Basic Components")

-- タブを追加
local Tab1 = Window:AddTab({ Title = "Basic", Icon = "component" })
-- 使用可能なアイコン名一覧はlucide-iconsをベースにしています (例: settings, swords, save, layout-dashboard等)

-- ===== 3. ダッシュボードの追加方法 (DashboardManagerアドオン) =====
-- （アドオンを読み込んでいる場合）
-- local DashboardManager = loadstring(...)
-- DashboardManager:SetLibrary(Fluent)
-- DashboardManager:BuildDashboardTab(Window, {
--     GameName = "My Game",
--     Developer = "My Name",
--     Discord = "https://discord.gg/xxxxxxxx",
-- })


-- タブの中にカード型の枠(Section)を作成
local Section1 = Tab1:AddSection("Buttons & Toggles")
local Section2 = Tab1:AddSection("Sliders & Inputs")


-- ==============================================
-- 🧩 4. 利用可能なUI要素一覧 (Elements)
-- ==============================================

-- 【Paragraph】 (パラグラフ / 文章の表示)
Section1:AddParagraph({
    Title = "Paragraph Example",
    Content = "これはパラグラフUIです。\nユーザーに長めの説明や指示を伝えるのに便利です。"
})

-- 【Button】 (ボタン)
Section1:AddButton({
    Title = "Regular Button",
    Description = "とてもシンプルなボタン要素です。",
    Callback = function()
		print("ボタンがクリックされました！")
        
        -- 【Dialog】 (ダイアログ/ポップアップ)
		-- ボタンクリック時に確認ダイアログを出すことができます
        Window:Dialog({
            Title = "確認ダイアログ",
            Content = "本当にこの設定を適用しますか？",
            Buttons = {
                {
                    Title = "Confirm",
                    Callback = function()
                        print("確定されました。")
                    end
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("キャンセルされました。")
                    end
                }
            }
        })
    end
})

-- 【Toggle】 (トグルスイッチ / オンオフ設定)
local MyToggle = Section1:AddToggle("ToggleFlag", { -- 第1引数はSaveManager用の一意のID
    Title = "Auto Farm",
    Description = "自動ファーム機能をオン/オフします。",
    Default = false, -- 初期値
    Callback = function(state)
        print("Toggle changed to:", state)
    end
})
-- 値が変更されたときのイベント登録
MyToggle:OnChanged(function()
    print("状態が変化しました:", Fluent.Options.ToggleFlag.Value)
end)
-- スクリプトから強制的に値を切り替える場合:
-- MyToggle:SetValue(true)

-- 【Slider】 (スライダー / 数値の選択)
local MySlider = Section2:AddSlider("SliderVal", {
    Title = "Damage Increment",
    Description = "ダメージの増加量を設定します。",
    Default = 5,
    Min = 1,
    Max = 100,
    Rounding = 1,     -- 小数点以下の桁数 (0: 整数, 1: 小数第1位まで等)
    Suffix = " %",    -- 数値の後ろにつける単位文字列
    Callback = function(Value)
        print("スライダーの値:", Value)
    end
})
-- スクリプトから強制的に値を設定する場合:
-- MySlider:SetValue(50)

-- 【Input】 (テキストボックス / 文字入力)
local MyInput = Section2:AddInput("InputText", {
    Title = "Custom Text",
    Description = "文字や数値を入力できます。",
    Default = "Hello",
    Placeholder = "ここに文字列を入力...",
    Numeric = false,   -- true にすると数字しか入力できなくなります
    Finished = false,  -- true にすると Enterキーを押す か フォーカスが外れた時だけCallbackが呼ばれます
    Callback = function(Value)
        print("入力された文字:", Value)
    end
})


-- もう一つのタブを作成
Window:AddTabSection("Advanced Components")
local Tab2 = Window:AddTab({ Title = "Advanced", Icon = "settings" })
local AdvSection = Tab2:AddSection("Selection & Display")

-- 【Dropdown】 (ドロップダウンリスト / 選択肢)
local MyDropdown = AdvSection:AddDropdown("SelectTarget", {
    Title = "Target Selection",
    Description = "ドロップダウンから対象を選んでください。",
    Values = {"Player", "NPC", "Boss", "Object", "Ore"},
    Multi = false,        -- true に設定すると複数選択モードになり、値はテーブルで返ります
    Default = "Player",   -- Multi = true の場合は {"Player", "Boss"} のようにテーブルで指定
    Callback = function(Value)
        print("選択された項目:", Value)
    end
})
-- リストの項目をプログラムから後で更新する場合:
-- MyDropdown:SetValues({"New Option 1", "New Option 2", "New Option 3"})
-- MyDropdown:SetValue("New Option 1")


-- 【Colorpicker】 (カラーピッカー / 色の選択)
local MyColorpicker = AdvSection:AddColorpicker("UI_Color", {
    Title = "Highlight Color",
    Description = "特定のエフェクトの色を設定します。",
    Default = Color3.fromRGB(85, 170, 255),
    Transparency = 0, -- アルファ（透明度）が必要な場合は0~1で指定
    Callback = function(Value)
        print("選択された色:", Value)
    end
})


-- 【Keybind】 (キーバインド / ショートカットキー)
local MyKeybind = AdvSection:AddKeybind("Action_Key", {
    Title = "Dash Skill Bind",
    Mode = "Toggle", -- "Always", "Toggle", "Hold" の3種類から操作モードを選択
    Default = Enum.KeyCode.E, 
    Callback = function(Value)
        print("キーが押されたか、トグル状態が変化しました:", Value)
    end,
    ChangedCallback = function(NewKey)
        print("キーの割り当てが変更されました:", NewKey)
    end
})


-- ==============================================
-- 📢 5. 通知機能 (Notifications)
-- ==============================================
-- ユーザーにポップアップでメッセージを知らせることができます
Fluent:Notify({
    Title = "Fract Hub",
    Content = "The script successfully loaded all contents.",
    SubContent = "Enjoy your game!", -- サブテキスト（省略可）
    Duration = 5 -- 表示される秒数
})


-- 最後に、起動時に選択状態にしておくタブを指定します (1 = 一番最初のタブ)
Window:SelectTab(1)
