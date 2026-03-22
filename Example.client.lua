local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Fluent = require(ReplicatedStorage:WaitForChild("Fluent"))
local Addons = ReplicatedStorage:WaitForChild("FluentAddons")
local SaveManager = require(Addons:WaitForChild("SaveManager"))
local InterfaceManager = require(Addons:WaitForChild("InterfaceManager"))
local DashboardManager = require(Addons:WaitForChild("DashboardManager"))

local Window = Fluent:CreateWindow({
    Title = "Fract Hub",
    SubTitle = "Local Sample",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 420),
    Acrylic = true,
    Theme = "Cyan",
    Logo = "rbxassetid://92450040427767",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {}
Tabs.Dashboard = Window:AddTab({ Title = "Dashboard", Icon = "layout-dashboard" })
Window:AddTabSection("Main")
Tabs.Main = Window:AddTab({ Title = "Main", Icon = "box" })
Window:AddTabSection("Settings")
Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
Tabs.Config = Window:AddTab({ Title = "Config", Icon = "save" })

DashboardManager:SetLibrary(Fluent)
DashboardManager:BuildDashboardTab(Tabs.Dashboard, {
    GameName = "Local Sample",
    Developer = "xFract",
    Discord = "https://discord.gg/c3qbzApe"
})

local Options = Fluent.Options

local MainSection = Tabs.Main:AddSection("Main Controls")
MainSection:AddParagraph({
    Title = "Overview",
    Content = "This sample runs entirely from local Rojo modules, including SaveManager, InterfaceManager, and DashboardManager."
})

local AutoFarmToggle = MainSection:AddToggle("AutoFarm", {
    Title = "Auto Farm",
    Default = false
})

MainSection:AddDropdown("TargetMode", {
    Title = "Target Mode",
    Description = "A moderate list for dropdown testing.",
    Values = { "Closest", "Highest HP", "Lowest HP", "Boss", "Quest", "Event", "Elite", "Manual" },
    Default = "Closest",
    Multi = false
})

MainSection:AddSlider("FarmDistance", {
    Title = "Distance",
    Default = 15,
    Min = 0,
    Max = 50,
    Rounding = 0
})

MainSection:AddInput("SearchText", {
    Title = "Search Text",
    Default = "Fluent",
    Placeholder = "Type here",
    Finished = false
})

MainSection:AddButton({
    Title = "Show Dialog",
    Description = "Exercises dialog and notification paths.",
    Callback = function()
        Window:Dialog({
            Title = "Local Sample",
            Content = "This dialog confirms the local sample is wired correctly.",
            Buttons = {
                {
                    Title = "Notify",
                    Callback = function()
                        Fluent:Notify({
                            Title = "Fract Hub",
                            Content = "Local sample is working.",
                            Duration = 5
                        })
                    end
                },
                {
                    Title = "Close"
                }
            }
        })
    end
})

local VisualSection = Tabs.Main:AddSection("Visual Controls")
local Colorpicker = VisualSection:AddColorpicker("AccentColor", {
    Title = "Accent Color",
    Default = Color3.fromRGB(96, 205, 255)
})

local Keybind = VisualSection:AddKeybind("QuickAction", {
    Title = "Quick Action",
    Default = "RightShift",
    Mode = "Toggle"
})

Colorpicker:OnChanged(function()
    print("Accent Color:", Colorpicker.Value)
end)

Keybind:OnChanged(function(value)
    print("Quick Action:", value)
end)

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetFolder("FractHub/LocalSample")
InterfaceManager:SetFolder("FractHub")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Config)
SaveManager:LoadAutoloadConfig()

Window:SelectTab(1)

AutoFarmToggle:OnChanged(function(value)
    print("Auto Farm:", value)
end)

Fluent:Notify({
    Title = "Fract Hub",
    Content = "The local sample has been loaded.",
    Duration = 6
})
