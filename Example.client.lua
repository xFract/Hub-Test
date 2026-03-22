if getgenv().Script_Maid then
    pcall(function()
        getgenv().Script_Maid:Destroy()
    end)
end

local function loadRemoteModule(url, name, required)
    local source = game:HttpGet(url)
    local chunk, compileError = loadstring(source)

    if not chunk then
        local message = string.format("%s failed to compile: %s", name, tostring(compileError))
        if required then
            error(message)
        end

        warn(message)
        return nil
    end

    local ok, result = pcall(chunk)
    if not ok then
        local message = string.format("%s failed to initialize: %s", name, tostring(result))
        if required then
            error(message)
        end

        warn(message)
        return nil
    end

    return result
end

local baseUrl = "https://raw.githubusercontent.com/xFract/Hub-Test/main"

local Fluent = loadRemoteModule(baseUrl .. "/dist/main.lua", "Fluent", true)
local SaveManager = loadRemoteModule(baseUrl .. "/Addons/SaveManager.lua", "SaveManager", true)
local InterfaceManager = loadRemoteModule(baseUrl .. "/Addons/InterfaceManager.lua", "InterfaceManager", true)
local DashboardManager = loadRemoteModule(baseUrl .. "/Addons/DashboardManager.lua", "DashboardManager", false)

local Window = Fluent:CreateWindow({
    Title = "Fract Hub",
    SubTitle = "Hub-Test Sample",
    TabWidth = 160,
    Size = UDim2.fromOffset(560, 420),
    Acrylic = true,
    Theme = "Cyan",
    Logo = "rbxassetid://92450040427767",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {}
if DashboardManager then
    Tabs.Dashboard = Window:AddTab({ Title = "Dashboard", Icon = "layout-dashboard" })
end
Window:AddTabSection("Main")
Tabs.Main = Window:AddTab({ Title = "Main", Icon = "box" })
Window:AddTabSection("Settings")
Tabs.Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
Tabs.Config = Window:AddTab({ Title = "Config", Icon = "save" })

if DashboardManager then
    DashboardManager:SetLibrary(Fluent)
    DashboardManager:BuildDashboardTab(Tabs.Dashboard, {
        GameName = "Hub-Test Sample",
        Developer = "xFract",
        Discord = "https://discord.gg/c3qbzApe"
    })
end

local MainSection = Tabs.Main:AddSection("Main Controls")
MainSection:AddParagraph({
    Title = "Overview",
    Content = DashboardManager
        and "This sample loads Fluent and the addons directly from the Hub-Test GitHub repository."
        or "This sample loads Fluent from Hub-Test. DashboardManager is currently skipped because the remote file failed to load."
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
            Title = "Hub-Test Sample",
            Content = "This dialog confirms the remote loadstring sample is wired correctly.",
            Buttons = {
                {
                    Title = "Notify",
                    Callback = function()
                        Fluent:Notify({
                            Title = "Fract Hub",
                            Content = "Remote sample is working.",
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
SaveManager:SetFolder("FractHub/HubTestSample")
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
    Content = DashboardManager
        and "The Hub-Test sample has been loaded."
        or "The sample loaded without DashboardManager. Check the console warning for details.",
    Duration = 6
})