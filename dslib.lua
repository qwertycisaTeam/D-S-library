-- [lib by Aliwave] Last update: 29.05.26 optimization [memory leaks], rework of base functions
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
local Camera = workspace.CurrentCamera

if PlayerGui:FindFirstChild("DuskShine_Mega") then
    PlayerGui.DuskShine_Mega:Destroy()
end

if getgenv().DS_Connections then
    for _, conn in pairs(getgenv().DS_Connections) do
        if typeof(conn) == "RBXScriptConnection" then conn:Disconnect() end
    end
end
getgenv().DS_Connections = {}

local MainFont = Font.new("rbxassetid://16658237174") -- Libre Baskerville
local LoaderFont = Font.new("rbxassetid://12187365104") -- Blaka

if getgenv().DS_LibraryLoaded then 
    return getgenv().DS_LibraryLoaded 
end

pcall(function()
    if VersionURL ~= "" and ScriptURL ~= "" then
        local fetchVersion = game:HttpGet(VersionURL):gsub("%s+", "") -- Убираем пробелы
        if fetchVersion ~= "" and fetchVersion ~= CurrentVersion then
            warn("[D&S] Found new version ("..fetchVersion..")! Updating...")
            getgenv().DS_StopExecution = true 
            loadstring(game:HttpGet(ScriptURL))()
        end
    end
end)

if getgenv().DS_StopExecution then return end

local Library = {}
getgenv().DS_LibraryLoaded = Library

-- 1. СИСТЕМА ТЕМ
local Themes = {
    Dark = {
        Background = Color3.fromRGB(15, 15, 20),
        Sidebar    = Color3.fromRGB(20, 20, 25),
        Section    = Color3.fromRGB(28, 28, 33),
        Text       = Color3.fromRGB(255, 255, 255),
        SubText    = Color3.fromRGB(120, 120, 130),
        Accent     = Color3.fromRGB(255, 255, 255),
        Stroke     = Color3.fromRGB(45, 45, 50),
        ToggleOff  = Color3.fromRGB(55, 55, 60),
        ToggleOn   = Color3.fromRGB(255, 255, 255),
        Knob       = Color3.fromRGB(20, 20, 25),
        Red        = Color3.fromRGB(255, 95, 87),
        Yellow     = Color3.fromRGB(255, 189, 46),
        Green      = Color3.fromRGB(39, 201, 63)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 250),
        Sidebar    = Color3.fromRGB(255, 255, 255),
        Section    = Color3.fromRGB(235, 235, 240),
        Text       = Color3.fromRGB(20, 20, 25),
        SubText    = Color3.fromRGB(100, 100, 110),
        Accent     = Color3.fromRGB(0, 122, 255),
        Stroke     = Color3.fromRGB(220, 220, 230),
        ToggleOff  = Color3.fromRGB(200, 200, 210),
        ToggleOn   = Color3.fromRGB(0, 122, 255),
        Knob       = Color3.fromRGB(255, 255, 255),
        Red        = Color3.fromRGB(255, 95, 87),
        Yellow     = Color3.fromRGB(255, 189, 46),
        Green      = Color3.fromRGB(39, 201, 63)
    },
    Galaxy = {
        Background = Color3.fromRGB(12, 10, 20),   
        Sidebar    = Color3.fromRGB(18, 15, 30),    
        Section    = Color3.fromRGB(25, 20, 42),    
        Text       = Color3.fromRGB(240, 240, 255),  
        SubText    = Color3.fromRGB(150, 140, 190),  
        Accent     = Color3.fromRGB(110, 60, 255),  
        Stroke     = Color3.fromRGB(50, 40, 80),    
        ToggleOff  = Color3.fromRGB(40, 30, 70),    
        ToggleOn   = Color3.fromRGB(110, 60, 255), 
        Knob       = Color3.fromRGB(20, 15, 35),    
        Red        = Color3.fromRGB(255, 95, 87),
        Yellow     = Color3.fromRGB(255, 189, 46),
        Green      = Color3.fromRGB(39, 201, 63)
    },
    Emerald = {
        Background = Color3.fromRGB(15, 22, 18),     
        Sidebar    = Color3.fromRGB(20, 28, 22),      
        Section    = Color3.fromRGB(26, 36, 28),      
        Text       = Color3.fromRGB(240, 255, 240),  
        SubText    = Color3.fromRGB(130, 160, 140),   
        Accent     = Color3.fromRGB(46, 204, 113),   
        Stroke     = Color3.fromRGB(45, 60, 50),     
        ToggleOff  = Color3.fromRGB(40, 55, 45),
        ToggleOn   = Color3.fromRGB(46, 204, 113),
        Knob       = Color3.fromRGB(20, 28, 22),
        Red        = Color3.fromRGB(255, 95, 87),
        Yellow     = Color3.fromRGB(255, 189, 46),
        Green      = Color3.fromRGB(39, 201, 63)
    },
    BlueDeepWave = {
        Background = Color3.fromRGB(10, 15, 25),      
        Sidebar    = Color3.fromRGB(15, 22, 35),
        Section    = Color3.fromRGB(22, 30, 48),
        Text       = Color3.fromRGB(235, 245, 255),  
        SubText    = Color3.fromRGB(120, 140, 180),   
        Accent     = Color3.fromRGB(0, 170, 255),    
        Stroke     = Color3.fromRGB(40, 50, 75),
        ToggleOff  = Color3.fromRGB(35, 45, 65),
        ToggleOn   = Color3.fromRGB(0, 170, 255),
        Knob       = Color3.fromRGB(15, 22, 35),
        Red        = Color3.fromRGB(255, 95, 87),
        Yellow     = Color3.fromRGB(255, 189, 46),
        Green      = Color3.fromRGB(39, 201, 63)
    }
}

local ThemeFileName = "DuskShine_Theme.txt"
local CurrentThemeName = "Dark"

if isfile and isfile(ThemeFileName) then
    local success, savedTheme = pcall(function() return readfile(ThemeFileName) end)
    if success and Themes[savedTheme] then
        CurrentThemeName = savedTheme
    end
end

local AnonFileName = "DuskShine_Anon.txt"
getgenv().AnonymousMode = false
if isfile and isfile(AnonFileName) then
    local success, savedAnon = pcall(function() return readfile(AnonFileName) end)
    if success and savedAnon == "true" then
        getgenv().AnonymousMode = true
    end
end

local CurrentTheme = Themes[CurrentThemeName]
local ThemeObjects = {} 

task.spawn(function()
    while task.wait(5) do
        for element, _ in pairs(ThemeObjects) do
            if typeof(element) ~= "Instance" or not element.Parent then
                ThemeObjects[element] = nil
            end
        end
    end
end)

local TweenService = game:GetService("TweenService")

local function ApplyGradient(uiElement, accentColor)
    local grad = uiElement:FindFirstChild("DuskShine_Gradient")
    if not grad then
        grad = Instance.new("UIGradient")
        grad.Name = "DuskShine_Gradient"
        grad.Rotation = 45
        grad.Offset = Vector2.new(-0.8, 0)
        grad.Parent = uiElement
        
        local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
        TweenService:Create(grad, tweenInfo, {Offset = Vector2.new(0.8, 0)}):Play()
    end
    
    local h, s, v = accentColor:ToHSV()
    local glowColor = Color3.fromHSV(h, math.clamp(s - 0.3, 0, 1), math.clamp(v + 0.4, 0, 1))
    
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, accentColor),
        ColorSequenceKeypoint.new(0.5, glowColor),
        ColorSequenceKeypoint.new(1, accentColor)
    })
end

getgenv().Themes = Themes
getgenv().CurrentTheme = CurrentTheme
getgenv().ThemeObjects = ThemeObjects

local function AddTheme(UIElement, Property, ThemeKey)
    if not ThemeObjects[UIElement] then ThemeObjects[UIElement] = {} end
    ThemeObjects[UIElement][Property] = ThemeKey
    UIElement[Property] = CurrentTheme[ThemeKey]
    
    if ThemeKey == "Accent" and not UIElement:IsA("ImageLabel") then
        ApplyGradient(UIElement, CurrentTheme.Accent)
    else
        local grad = UIElement:FindFirstChild("DuskShine_Gradient")
        if grad then grad:Destroy() end
    end
    
    return UIElement
end

local ThemeCycle = {"Dark", "Light", "Galaxy", "Emerald", "BlueDeepWave"}

Library.AnonItems = { Avatars = {}, Names = {}, UIDs = {} }

function Library:SetAnonymousMode(state)
    getgenv().AnonymousMode = state

    if writefile then
        pcall(function() writefile("DuskShine_Anon.txt", tostring(state)) end)
    end
    
    local screenGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("DuskShine_Mega")
    if screenGui then
        for _, v in pairs(screenGui:GetDescendants()) do
            if (v:IsA("ImageLabel") or v:IsA("ImageButton")) and v.Image:find("AvatarHeadShot") then
                v.ImageTransparency = state and 1 or 0
                
                if state then
                    v.BackgroundColor3 = Color3.new(0, 0, 0)
                    v.BackgroundTransparency = 0
                else
                    v.BackgroundColor3 = CurrentTheme.Section
                end
                
                local letter = v:FindFirstChild("AnonTextA")
                if not letter then
                    letter = Instance.new("TextLabel", v)
                    letter.Name = "AnonTextA"
                    letter.Size = UDim2.new(1, 0, 1, 0)
                    letter.BackgroundTransparency = 1
                    letter.Text = "A"
                    letter.Font = Enum.Font.GothamBold
                    letter.TextScaled = true
                    AddTheme(letter, "TextColor3", "Accent")
                    
                    local pad = Instance.new("UIPadding", letter)
                    pad.PaddingTop = UDim.new(0.2, 0); pad.PaddingBottom = UDim.new(0.2, 0)
                end
                letter.Visible = state
            end
            
            if v:IsA("TextLabel") then
                if v.Name == "NickLabel" then
                    v.Text = state and "Hidden User" or game:GetService("Players").LocalPlayer.DisplayName
                elseif v.Name == "UIDLabel" then
                    v.Text = state and "Blacklist UID: PROTECTED" or "Blacklist UID: " .. tostring(game:GetService("Players").LocalPlayer.UserId)
                elseif v.Name == "WelcomeLabel" then
                    local nameToUse = state and "Hidden User" or game:GetService("Players").LocalPlayer.DisplayName
                    v.Text = "Welcome back, <b><font color='rgb(255,255,255)'>" .. nameToUse .. "</font></b>!"
                end
            end
        end
    end
end

function Library:ToggleTheme()
    local currentIndex = table.find(ThemeCycle, CurrentThemeName) or 1
    local nextIndex = currentIndex + 1
    if nextIndex > #ThemeCycle then 
        nextIndex = 1 
    end

    CurrentThemeName = ThemeCycle[nextIndex]
    CurrentTheme = Themes[CurrentThemeName]
    getgenv().CurrentTheme = CurrentTheme
    
    if writefile then
        pcall(function() writefile(ThemeFileName, CurrentThemeName) end)
    end

    for UIElement, Props in pairs(ThemeObjects) do
        if UIElement and UIElement.Parent then 
            for Property, ThemeKey in pairs(Props) do
                TweenService:Create(UIElement, TweenInfo.new(0.3), {[Property] = CurrentTheme[ThemeKey]}):Play()
                
                if ThemeKey == "Accent" then
                    local grad = UIElement:FindFirstChild("DuskShine_Gradient")
                    if grad then
                        local c = CurrentTheme.Accent
                        local glowPower = 0.35
                        if CurrentThemeName == "Galaxy" or CurrentThemeName == "BlueDeepWave" then glowPower = 0.45 end
                        
                        local glow = Color3.new(math.clamp(c.R + glowPower, 0, 1), math.clamp(c.G + glowPower, 0, 1), math.clamp(c.B + glowPower, 0, 1))

                        grad.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, c),
                            ColorSequenceKeypoint.new(0.5, glow),
                            ColorSequenceKeypoint.new(1, c)
                        })
                    end
                end
            end
        else
            ThemeObjects[UIElement] = nil
        end
    end
end

function Library:ChangeAccentColor(newColor)
    CurrentTheme.Accent = newColor
    
    for UIElement, Props in pairs(ThemeObjects) do
        if UIElement and UIElement.Parent then 
            for Property, ThemeKey in pairs(Props) do
                if ThemeKey == "Accent" then
                    TweenService:Create(UIElement, TweenInfo.new(0.2), {[Property] = newColor}):Play()
                    
                    if not UIElement:IsA("ImageLabel") then
                        ApplyGradient(UIElement, newColor)
                    end
                end
            end
        end
    end
end

-- <shortify> --
local function Make(className, properties, themeProps)
    local inst = Instance.new(className)
    
    for prop, value in pairs(properties) do
        inst[prop] = value
    end
    
    if themeProps then
        for prop, themeKey in pairs(themeProps) do
            AddTheme(inst, prop, themeKey)
        end
    end

    return inst
end

local function TBT(obj, time, props, style, dir)
    style = style or Enum.EasingStyle.Sine
    dir = dir or Enum.EasingDirection.Out
    local info = TweenInfo.new(time, style, dir)
    local tween = TweenService:Create(obj, info, props)
    tween:Play()

    tween.Completed:Connect(function()
        tween:Destroy()
    end)

    return tween
end

local function CheckBlacklist()
    local success, response = pcall(function()
        return request({
            Url = "https://duskandshine.xyz/api/blacklist",
            Method = "GET"
        })
    end)
    
    if success and response and response.Body then
        local myName = game:GetService("Players").LocalPlayer.Name
        for line in response.Body:gmatch("[^\r\n]+") do
            local cleanName = line:gsub("%s+", "")
            if cleanName:lower() == myName:lower() then
                return true 
            end
        end
    end
    return false
end

if CheckBlacklist() then return end 

-- > Safety Notify < -- 
task.spawn(function()
    local InfoGui = Make("ScreenGui", {
        Name = "DS_IndependentNotice", DisplayOrder = 99, IgnoreGuiInset = true, Parent = PlayerGui
    })

    local Notice = Make("TextLabel", {
        Text = "discord.gg/duskshine is our only official discord, please get your script from there and stay safe!", FontFace = Font.new("rbxassetid://12187365104"), TextSize = 30, Size = UDim2.new(0, 1000, 0, 70), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.8, 0),
        BackgroundTransparency = 1, TextTransparency = 1, Parent = InfoGui
    })

    local Stroke = Make("UIStroke", {
        Thickness = 0.5, Color = Color3.fromRGB(128, 0, 128), Transparency = 1, Parent = Notice
    })

    local ts = game:GetService("TweenService")
    local ti = TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    TBT(Notice, 0.8, {TextTransparency = 0})
    TBT(Stroke, 0.8, {Transparency = 0.2})

    task.wait(6)

    TBT(Stroke, 0.8, {Transparency = 1})
    local fade = TBT(Notice, 0.8, {TextTransparency = 1})

    fade.Completed:Connect(function()
        InfoGui:Destroy()
    end)
end)

-- < loader >
function Library:RunLoader(ScreenGui, OnComplete)
    local Blur = Make("BlurEffect", {Size = 0, Parent = game:GetService("Lighting")})
    TweenService:Create(Blur, TweenInfo.new(0.5), {Size = 15}):Play()

    local LoaderCard = Make("Frame", {
        Size = UDim2.new(0, 380, 0, 220), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 0), BorderSizePixel = 0, BackgroundTransparency = 1, Parent = ScreenGui
    }, { BackgroundColor3 = "Background" })

    Make("UICorner", {CornerRadius = UDim.new(0, 16), Parent = LoaderCard})

    -- ИСПРАВЛЕНО: Указали Color = "Accent", система сама накинет градиент!
    local Stroke = Make("UIStroke", {
        Thickness = 2, Transparency = 1, Parent = LoaderCard
    }, { Color = "Accent" })

    local Logo = Make("ImageLabel", {
        Size = UDim2.new(0, 110, 0, 110), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.35, 0), BackgroundTransparency = 1, Image = "rbxassetid://72958619361915", ImageTransparency = 1, Parent = LoaderCard
    })

    local Title = Make("TextLabel", {
        Text = "dusk & shine", Size = UDim2.new(1, 0, 0, 40), Position = UDim2.new(0, 0, 0.52, 0), 
        FontFace = LoaderFont, TextSize = 42, TextTransparency = 1, BackgroundTransparency = 1, Parent = LoaderCard
    }, { TextColor3 = "Accent" })

    local Status = Make("TextLabel", {
        Text = "Loading Assets...", Size = UDim2.new(1, 0, 0, 20), Position = UDim2.new(0, 0, 0.68, 0), 
        Font = Enum.Font.GothamMedium, TextSize = 13, TextTransparency = 1, BackgroundTransparency = 1, Parent = LoaderCard
    }, { TextColor3 = "SubText" })

    local BarBG = Make("Frame", {
        Size = UDim2.new(0, 240, 0, 4), AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.82, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = LoaderCard
    }, { BackgroundColor3 = "Section" })

    Make("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarBG})

    local BarFill = Make("Frame", {
        Size = UDim2.new(0, 0, 1, 0), BorderSizePixel = 0, Parent = BarBG
    }, { BackgroundColor3 = "Accent" })

    Make("UICorner", {CornerRadius = UDim.new(1, 0), Parent = BarFill})

    TBT(LoaderCard, 0.5, {BackgroundTransparency = 0.05}) 
    TBT(Stroke, 0.5, {Transparency = 0}) 
    TBT(Logo, 0.6, {ImageTransparency = 0, Position = UDim2.new(0.5, 0, 0.3, 0)}) 
    TBT(Title, 0.6, {TextTransparency = 0}) 
    TBT(Status, 0.6, {TextTransparency = 0}) 
    TBT(BarBG, 0.6, {BackgroundTransparency = 0})
    
    task.wait(0.6)

    Status.Text = "Injecting Scripts..."
    TBT(BarFill, 0.8, {Size = UDim2.new(0.6, 0, 1, 0)}).Completed:Wait()
    
    Status.Text = "Starting UI..."
    TBT(BarFill, 0.5, {Size = UDim2.new(1, 0, 1, 0)}).Completed:Wait()

    task.wait(0.3)

    TBT(LoaderCard, 0.4, {BackgroundTransparency = 1, Size = UDim2.new(0, 400, 0, 240)}) 
    TBT(Stroke, 0.4, {Transparency = 1}) 
    TBT(Logo, 0.3, {ImageTransparency = 1}) 
    TBT(Title, 0.3, {TextTransparency = 1})
    TBT(Status, 0.3, {TextTransparency = 1}) 
    TBT(BarBG, 0.3, {BackgroundTransparency = 1}) 
    TBT(BarFill, 0.3, {BackgroundTransparency = 1}) 
    TBT(Blur, 0.5, {Size = 0})
    
    task.wait(0.5)

    LoaderCard:Destroy()
    Blur:Destroy()
    if OnComplete then OnComplete() end
end

-- 3. СОЗДАНИЕ ОКНА
function Library:CreateWindow()
    local ScreenGui = Make("ScreenGui", {
        Name = "DuskShine_Mega", Parent = PlayerGui, ResetOnSpawn = false,
        IgnoreGuiInset = true, ZIndexBehavior = "Global", DisplayOrder = 100
    })

    local NotifyHolder = Make("Frame", {
        Name = "Notifications", Size = UDim2.new(1, -20, 1, -20), Position = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0, 0), BackgroundTransparency = 1, Parent = ScreenGui, ZIndex = 100
    })

    Make("UIListLayout", {
        HorizontalAlignment = "Right", VerticalAlignment = "Bottom",
        Padding = UDim.new(0, 5), SortOrder = "LayoutOrder", Parent = NotifyHolder
    })

    getgenv().MainUIScale = Make("UIScale", {
        Parent = ScreenGui, Scale = (getgenv().UIScaleSize or 100) / 100
    })

    local MainFrame = Make("CanvasGroup", {
        Size = UDim2.new(0, 680, 0, 450), AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0), BorderSizePixel = 0, GroupTransparency = 1,
        Visible = false, BackgroundTransparency = 0.15, Parent = ScreenGui
    }, { BackgroundColor3 = "Background" })

    Make("UIGradient", {
        Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.new(1,1,1)), ColorSequenceKeypoint.new(1, Color3.new(0.8,0.8,0.8))},
        Rotation = 45, Parent = MainFrame
    })

    local ParticlesCanvas = Make("Frame", {
        Name = "ParticleCanvas", Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1,
        ClipsDescendants = true, ZIndex = 1, Parent = MainFrame
    })

    getgenv().MenuParticlesEnabled = getgenv().MenuParticlesEnabled == nil and true or getgenv().MenuParticlesEnabled

    task.spawn(function()
        while task.wait(0.1) do
            if not ScreenGui or not ScreenGui.Parent then break end
            if getgenv().MenuParticlesEnabled and MainFrame.Visible then
                local isComet = math.random(1, 8) == 1
                local size = isComet and 0 or math.random(3, 6)
                local startX = math.random(0, 100) / 100
                
                local p = Make("Frame", {
                    Size = isComet and UDim2.new(0, 2, 0, math.random(20, 45)) or UDim2.new(0, size, 0, size),
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BackgroundTransparency = isComet and 0.2 or math.random(0, 30) / 100,
                    Position = UDim2.new(startX, 0, 0, -50),
                    BorderSizePixel = 0, ZIndex = 1, Parent = ParticlesCanvas
                })

                if not isComet then Make("UICorner", {CornerRadius = UDim.new(1, 0), Parent = p}) end
                Make("UIStroke", {Color = Color3.new(1, 1, 1), Thickness = 1.5, Transparency = 0.5, Parent = p})

                local endX = startX + (isComet and (math.random(-20, 20) / 100) or 0)
                TBT(p, math.random(15, 40) / 10, {Position = UDim2.new(endX, 0, 1, 50), BackgroundTransparency = 1}, Enum.EasingStyle.Linear).Completed:Connect(function() 
                    p:Destroy() 
                end)
            end
        end
    end)

    Make("UICorner", {CornerRadius = UDim.new(0, 14), Parent = MainFrame})
    Make("UIStroke", {Thickness = 1, Transparency = 0.5, Parent = MainFrame}, {Color = "Stroke"})

    local Sidebar = Make("Frame", {
    Size = UDim2.new(0, 60, 1, 0), 
    BorderSizePixel = 0, BackgroundTransparency = 0.4, Parent = MainFrame}, { BackgroundColor3 = "Sidebar" })

    Make("UICorner", {CornerRadius = UDim.new(0, 12), Parent = Sidebar})
    Make("Frame", { 
        Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BorderSizePixel = 0, Parent = Sidebar
    }, { BackgroundColor3 = "Stroke" })

    local TabsContainer = Make("Frame", {
        Size = UDim2.new(1, 0, 1, -80), Position = UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1, Parent = Sidebar
    })
    Make("UIListLayout", {HorizontalAlignment = "Center", Padding = UDim.new(0, 20), Parent = TabsContainer})

    local Avatar = Make("ImageButton", {
    Size = UDim2.new(0, 36, 0, 36), 
    Position = UDim2.new(0.5, -18, 1, -65), 
    Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=100&h=100", Parent = Sidebar}, { BackgroundColor3 = "Section" })

    Make("UICorner", {CornerRadius = UDim.new(1, 0), Parent = Avatar})
    Make("UIStroke", {Thickness = 1, Parent = Avatar}, {Color = "Stroke"})

    local SideAnonA = Instance.new("TextLabel", Avatar)
    SideAnonA.Size = UDim2.new(1,0,1,0); SideAnonA.BackgroundTransparency = 1
    SideAnonA.Text = "A"; SideAnonA.Font = Enum.Font.GothamBold; SideAnonA.TextSize = 20
    AddTheme(SideAnonA, "TextColor3", "Accent")
    SideAnonA.Visible = getgenv().AnonymousMode == true
    if getgenv().AnonymousMode then Avatar.ImageTransparency = 1; Avatar.BackgroundTransparency = 0; Avatar.BackgroundColor3 = Color3.new(0,0,0) end
    table.insert(Library.AnonItems.Avatars, {ImageObj = Avatar, Letter = SideAnonA})

    task.spawn(function()
        while task.wait(1) do
            if not ScreenGui or not ScreenGui.Parent then break end
            if isProfileOpen then UpdateStatsText() end
        end
    end)

    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -60, 0, 60)
    Header.Position = UDim2.new(0, 60, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local TitleContainer = Instance.new("Frame")
    TitleContainer.Size = UDim2.new(0, 250, 1, 0)
    TitleContainer.Position = UDim2.new(0, 25, 0, 0)
    TitleContainer.BackgroundTransparency = 1
    TitleContainer.Parent = Header
    
    local TitleLayout = Instance.new("UIListLayout")
    TitleLayout.FillDirection = Enum.FillDirection.Horizontal
    TitleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TitleLayout.Parent = TitleContainer

    local TitleDusk = Instance.new("TextLabel")
    TitleDusk.Text = "Dusk & "
    TitleDusk.Size = UDim2.new(0, 0, 1, 0)
    TitleDusk.AutomaticSize = Enum.AutomaticSize.X
    TitleDusk.BackgroundTransparency = 1
    TitleDusk.Font = Enum.Font.GothamBold
    TitleDusk.TextSize = 20
    AddTheme(TitleDusk, "TextColor3", "Text")
    TitleDusk.Parent = TitleContainer

    local TitleShine = Instance.new("TextLabel")
    TitleShine.Text = "Shine"
    TitleShine.Size = UDim2.new(0, 0, 1, 0)
    TitleShine.AutomaticSize = Enum.AutomaticSize.X
    TitleShine.BackgroundTransparency = 1
    TitleShine.Font = Enum.Font.GothamBold
    TitleShine.TextSize = 20
    AddTheme(TitleShine, "TextColor3", "Accent")
    TitleShine.Parent = TitleContainer

    local Ver = Instance.new("TextLabel")
    Ver.Text = "  " .. (getgenv().DuskVersion or "v1.0.0 [beta]")
    Ver.Size = UDim2.new(0, 0, 1, 0)
    Ver.AutomaticSize = Enum.AutomaticSize.X
    Ver.Font = Enum.Font.GothamMedium
    Ver.TextSize = 14
    Ver.BackgroundTransparency = 1
    AddTheme(Ver, "TextColor3", "SubText")
    Ver.Parent = TitleContainer

    local OnlineFrame = Instance.new("Frame")
    OnlineFrame.Name = "OnlineCounter"
    OnlineFrame.Size = UDim2.new(0, 0, 1, 0)
    OnlineFrame.AutomaticSize = Enum.AutomaticSize.X
    OnlineFrame.BackgroundTransparency = 1 
    OnlineFrame.Parent = TitleContainer 

    local Pill = Instance.new("Frame")
    Pill.Size = UDim2.new(0, 0, 0, 24)
    Pill.AutomaticSize = Enum.AutomaticSize.X
    Pill.AnchorPoint = Vector2.new(0, 0.5)
    Pill.Position = UDim2.new(0, 10, 0.5, 0)
    AddTheme(Pill, "BackgroundColor3", "Section")
    Pill.Parent = OnlineFrame
    Instance.new("UICorner", Pill).CornerRadius = UDim.new(1, 0)
    
    local PillStroke = Instance.new("UIStroke", Pill)
    AddTheme(PillStroke, "Color", "Stroke")
    PillStroke.Thickness = 1

    local PillLayout = Instance.new("UIListLayout", Pill)
    PillLayout.FillDirection = Enum.FillDirection.Horizontal
    PillLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    PillLayout.Padding = UDim.new(0, 6)

    local PillPad = Instance.new("UIPadding", Pill)
    PillPad.PaddingLeft = UDim.new(0, 10)
    PillPad.PaddingRight = UDim.new(0, 12)

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 8, 0, 8)
    Indicator.BackgroundColor3 = Color3.fromRGB(15, 205, 105)
    Indicator.Parent = Pill
    Instance.new("UICorner", Indicator).CornerRadius = UDim.new(1, 0)
    
    local IndStroke = Instance.new("UIStroke", Indicator)
    IndStroke.Color = Color3.fromRGB(15, 205, 105)
    IndStroke.Transparency = 0.6
    IndStroke.Thickness = 2

    local OnlineText = Instance.new("TextLabel")
    OnlineText.BackgroundTransparency = 1
    OnlineText.Size = UDim2.new(0, 0, 1, 0)
    OnlineText.AutomaticSize = Enum.AutomaticSize.X
    OnlineText.Text = "Currently playing: n/a" 
    AddTheme(OnlineText, "TextColor3", "SubText")
    OnlineText.Font = Enum.Font.GothamMedium
    OnlineText.TextSize = 12
    OnlineText.Parent = Pill

    task.spawn(function()
        while task.wait(25) do 
            if not OnlineText or not OnlineText.Parent then break end

            local url = "https://duskandshine.xyz/online?id=" .. tostring(LocalPlayer.UserId)
            pcall(function()
                local response = game:HttpGet(url)
                local data = game:GetService("HttpService"):JSONDecode(response)
                
                if data and data.online then
                    -- Формат без скобок
                    OnlineText.Text = "Currently playing: " .. tostring(data.online)
                    
                    game:GetService("TweenService"):Create(Indicator, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
                    task.wait(0.4)
                    if Indicator and Indicator.Parent then
                        game:GetService("TweenService"):Create(Indicator, TweenInfo.new(0.4), {BackgroundColor3 = Color3.fromRGB(15, 205, 105)}):Play()
                    end
                end
            end)
        end
    end)

    local MacFrame = Instance.new("Frame")
    MacFrame.Size = UDim2.new(0, 60, 0, 20)
    MacFrame.Position = UDim2.new(1, -75, 0.5, -10)
    MacFrame.BackgroundTransparency = 1
    MacFrame.Parent = Header
    local MacLayout = Instance.new("UIListLayout"); MacLayout.FillDirection = Enum.FillDirection.Horizontal; MacLayout.Padding = UDim.new(0, 8); MacLayout.Parent = MacFrame

    local OpenBtn = Instance.new("TextButton")
    OpenBtn.Size = UDim2.new(0, 140, 0, 40)
    OpenBtn.AnchorPoint = Vector2.new(0.5, 0)
    OpenBtn.Position = UDim2.new(0.5, 0, 0, -60)
    OpenBtn.ZIndex = 15
    OpenBtn.Text = "Open Menu"
    OpenBtn.FontFace = MainFont
    OpenBtn.TextSize = 14
    OpenBtn.Visible = false
    AddTheme(OpenBtn, "BackgroundColor3", "Sidebar")
    AddTheme(OpenBtn, "TextColor3", "Text")
    OpenBtn.Parent = ScreenGui
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 8)
    local OS = Instance.new("UIStroke"); AddTheme(OS, "Color", "Accent"); OS.Thickness = 2; OS.Parent = OpenBtn

    local FloatingWidget = Instance.new("CanvasGroup")
    FloatingWidget.Name = "FloatingWidget"
    FloatingWidget.Size = UDim2.new(0, 50, 0, 50)
    FloatingWidget.Position = UDim2.new(0.5, 0, 0.1, 0)
    FloatingWidget.AnchorPoint = Vector2.new(0.5, 0.5)
    AddTheme(FloatingWidget, "BackgroundColor3", "Sidebar")
    FloatingWidget.Visible = false
    FloatingWidget.GroupTransparency = 1
    FloatingWidget.ZIndex = 15
    FloatingWidget.Parent = ScreenGui

    Instance.new("UICorner", FloatingWidget).CornerRadius = UDim.new(1, 0)
    local FWStroke = Instance.new("UIStroke")
    FWStroke.Thickness = 2
    AddTheme(FWStroke, "Color", "Accent")
    FWStroke.Parent = FloatingWidget

    local FloatingLogo = Instance.new("ImageLabel")
    FloatingLogo.Size = UDim2.new(0, 26, 0, 26)
    FloatingLogo.Position = UDim2.new(0.5, 0, 0.5, 0)
    FloatingLogo.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatingLogo.BackgroundTransparency = 1
    FloatingLogo.Image = "rbxassetid://72958619361915"
    AddTheme(FloatingLogo, "ImageColor3", "Text")
    FloatingLogo.ZIndex = 16
    FloatingLogo.Parent = FloatingWidget

    local FloatingClick = Instance.new("TextButton")
    FloatingClick.Size = UDim2.new(1, 0, 1, 0)
    FloatingClick.BackgroundTransparency = 1
    FloatingClick.Text = ""
    FloatingClick.ZIndex = 17
    FloatingClick.Parent = FloatingWidget

    local function CloseMenu()
        TweenService:Create(MainFrame, TweenInfo.new(0.3), {GroupTransparency = 1, Size = UDim2.new(0, 700, 0, 400)}):Play()
        if OpenBtn.Visible then TweenService:Create(OpenBtn, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play() end
        if FloatingWidget.Visible then TweenService:Create(FloatingWidget, TweenInfo.new(0.3), {GroupTransparency = 1}):Play() end
        task.wait(0.3)
        ScreenGui:Destroy()
    end

    local MenuBlur = game:GetService("Lighting"):FindFirstChild("MenuBlur") or Instance.new("BlurEffect")
    MenuBlur.Name = "MenuBlur"
    MenuBlur.Size = 0
    MenuBlur.Parent = game:GetService("Lighting")
    MenuBlur.Enabled = false
    getgenv().MenuBlurEnabled = getgenv().MenuBlurEnabled or false

    local ToggleMini -- 1. ОБЪЯВЛЯЕМ ФУНКЦИЮ ЗАРАНЕЕ!

    local dragging = false
    local dragInput, dragStart, startPos
    local isClick = false

    FloatingClick.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            isClick = true
            dragStart = input.Position
            startPos = FloatingWidget.Position
        end
    end)

    FloatingClick.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            if delta.Magnitude > 7 then 
                isClick = false 
            end
            FloatingWidget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- 2. ВЫНОСИМ END СОБЫТИЕ НАРУЖУ (Убиваем утечку памяти)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                if isClick and ToggleMini then
                    ToggleMini()
                end
            end
        end
    end)

    ToggleMini = function()
        if MainFrame.Visible then
            local t = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {GroupTransparency = 1, Size = UDim2.new(0, 700, 0, 400)})
            t:Play(); t.Completed:Wait()
            MainFrame.Visible = false
            
            if getgenv().CloserType == "Floating Logo" then
                FloatingWidget.Visible = true
                FloatingWidget.Size = UDim2.new(0, 0, 0, 0)
                TweenService:Create(FloatingWidget, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50), GroupTransparency = 0}):Play()
            else
                OpenBtn.Visible = true
                OpenBtn.BackgroundTransparency = 1
                TweenService:Create(OpenBtn, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, 10), BackgroundTransparency = 0}):Play()
            end
            
            if MenuBlur.Enabled then
                local tweenOut = TweenService:Create(MenuBlur, TweenInfo.new(0.5), {Size = 0})
                tweenOut:Play()
                task.delay(0.5, function() if not MainFrame.Visible then MenuBlur.Enabled = false end end)
            end
        else
            if getgenv().CloserType == "Floating Logo" then
                local t = TweenService:Create(FloatingWidget, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0), GroupTransparency = 1})
                t:Play(); t.Completed:Wait()
                FloatingWidget.Visible = false
            else
                local t = TweenService:Create(OpenBtn, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0, -50)})
                t:Play(); t.Completed:Wait()
                OpenBtn.Visible = false
            end

            MainFrame.Visible = true
            TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {GroupTransparency = 0, Size = UDim2.new(0, 750, 0, 480)}):Play()
            
            if getgenv().MenuBlurEnabled then
                MenuBlur.Enabled = true
                MenuBlur.Size = 0
                TweenService:Create(MenuBlur, TweenInfo.new(0.5), {Size = 24}):Play()
            end
        end
    end

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
            if dragToggle then
                dragToggle = false
                if isClick then ToggleMini() end
            end
        end
    end)

    OpenBtn.MouseButton1Click:Connect(ToggleMini)
    FloatingClick.MouseButton1Click:Connect(ToggleMini)

    local function MakeMac(themeKey, cb)
        local b = Instance.new("TextButton")
        b.Text = ""; b.Size = UDim2.new(0, 14, 0, 14); 
        AddTheme(b, "BackgroundColor3", themeKey) 
        b.Parent = MacFrame
        Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
        b.MouseButton1Click:Connect(cb)
        b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency=0.3}):Play() end)
        b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundTransparency=0}):Play() end)
    end

    MakeMac("Red", CloseMenu)
    MakeMac("Yellow", ToggleMini)
    MakeMac("Green", function() Library:ToggleTheme() end)

    local function UpdateMacButtons()
        local Viewport = Camera.ViewportSize
        local isMobile = Viewport.X < 900 
        
        local btnSize = isMobile and 30 or 20
        local pad = isMobile and 14 or 8
        local totalWidth = (btnSize * 3) + (pad * 2)
        
        MacFrame.Size = UDim2.new(0, totalWidth, 0, btnSize)
        MacFrame.Position = UDim2.new(1, -totalWidth - 15, 0.5, -(btnSize/2))
        MacLayout.Padding = UDim.new(0, pad)
        
        for _, child in pairs(MacFrame:GetChildren()) do
            if child:IsA("TextButton") then
                child.Size = UDim2.new(0, btnSize, 0, btnSize)
            end
        end
    end

    Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateMacButtons)
    UpdateMacButtons()

    local Pages = Instance.new("Frame")
    Pages.Size = UDim2.new(1, -60, 1, -60)
    Pages.Position = UDim2.new(0, 60, 0, 60)
    Pages.BackgroundTransparency = 1
    Pages.ClipsDescendants = true
    Pages.Parent = MainFrame

    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    Header.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)

    local ProfilePage = Instance.new("Frame")
    ProfilePage.Size = UDim2.new(1, 0, 1, 0)
    ProfilePage.BackgroundTransparency = 1
    ProfilePage.Visible = false
    ProfilePage.Parent = Pages

    local ProfileTitle = Instance.new("TextLabel")
    ProfileTitle.Text = "User Profile"
    ProfileTitle.Size = UDim2.new(1, -50, 0, 40)
    ProfileTitle.Position = UDim2.new(0, 25, 0, 10)
    ProfileTitle.BackgroundTransparency = 1
    AddTheme(ProfileTitle, "TextColor3", "Text")
    ProfileTitle.FontFace = MainFont
    ProfileTitle.TextSize = 24
    ProfileTitle.TextXAlignment = Enum.TextXAlignment.Left
    ProfileTitle.Parent = ProfilePage

    local BigAvatar = Instance.new("ImageLabel")
    BigAvatar.Size = UDim2.new(0, 80, 0, 80)
    BigAvatar.Position = UDim2.new(0, 25, 0, 60)
    BigAvatar.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
    AddTheme(BigAvatar, "BackgroundColor3", "Section")
    BigAvatar.Parent = ProfilePage
    Instance.new("UICorner", BigAvatar).CornerRadius = UDim.new(1, 0)
    local BigAvStroke = Instance.new("UIStroke"); AddTheme(BigAvStroke, "Color", "Stroke"); BigAvStroke.Thickness = 2; BigAvStroke.Parent = BigAvatar

    local BigAnonA = Instance.new("TextLabel", BigAvatar)
    BigAnonA.Size = UDim2.new(1,0,1,0); BigAnonA.BackgroundTransparency = 1
    BigAnonA.Text = "A"; BigAnonA.Font = Enum.Font.GothamBold; BigAnonA.TextSize = 40
    AddTheme(BigAnonA, "TextColor3", "Accent")
    BigAnonA.Visible = getgenv().AnonymousMode == true
    if getgenv().AnonymousMode then BigAvatar.ImageTransparency = 1; BigAvatar.BackgroundTransparency = 0; BigAvatar.BackgroundColor3 = Color3.new(0,0,0) end
    table.insert(Library.AnonItems.Avatars, {ImageObj = BigAvatar, Letter = BigAnonA})

    local NickLabel = Instance.new("TextLabel")
    NickLabel.Text = getgenv().AnonymousMode and "Hidden User" or LocalPlayer.DisplayName
    NickLabel.Size = UDim2.new(1, -130, 0, 30)
    NickLabel.Position = UDim2.new(0, 120, 0, 70)
    NickLabel.BackgroundTransparency = 1
    AddTheme(NickLabel, "TextColor3", "Text")
    NickLabel.FontFace = MainFont
    NickLabel.TextSize = 20
    NickLabel.TextXAlignment = Enum.TextXAlignment.Left
    NickLabel.Parent = ProfilePage

    local UIDLabel = Instance.new("TextLabel")
    UIDLabel.Text = "Blacklist UID: " .. (getgenv().AnonymousMode and "PROTECTED" or tostring(LocalPlayer.UserId))
    UIDLabel.Size = UDim2.new(1, -130, 0, 20)
    UIDLabel.Position = UDim2.new(0, 120, 0, 100)
    UIDLabel.BackgroundTransparency = 1
    UIDLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
    UIDLabel.FontFace = MainFont
    UIDLabel.TextSize = 13
    UIDLabel.TextXAlignment = Enum.TextXAlignment.Left
    UIDLabel.Parent = ProfilePage

    local StatsContainer = Instance.new("Frame")
    StatsContainer.Size = UDim2.new(1, -50, 1, -170)
    StatsContainer.Position = UDim2.new(0, 25, 0, 160)
    AddTheme(StatsContainer, "BackgroundColor3", "Section")
    StatsContainer.Parent = ProfilePage
    Instance.new("UICorner", StatsContainer).CornerRadius = UDim.new(0, 10)
    local StatsStroke = Instance.new("UIStroke"); AddTheme(StatsStroke, "Color", "Stroke"); StatsStroke.Parent = StatsContainer

    local StatsLabel = Instance.new("TextLabel")
    StatsLabel.Size = UDim2.new(1, -30, 1, -30)
    StatsLabel.Position = UDim2.new(0, 15, 0, 15)
    StatsLabel.BackgroundTransparency = 1
    AddTheme(StatsLabel, "TextColor3", "SubText")
    StatsLabel.FontFace = MainFont
    StatsLabel.TextSize = 14
    StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
    StatsLabel.Parent = StatsContainer

    local function UpdateStatsText()
        local ts = getgenv().ProfileData.TimeSpent or 0
        local days = math.floor(ts / 86400)
        local hours = math.floor((ts % 86400) / 3600)
        local mins = math.floor((ts % 3600) / 60)
        
        local fi = getgenv().ProfileData.FirstInjected or "Just now"
        local fv = getgenv().ProfileData.FirstVersion or getgenv().DuskVersion or "v3.2.1"
        local pots = getgenv().ProfileData.AgePotionsFarmed or 0
        local bucks = getgenv().ProfileData.BucksEarned or 0
        
        StatsLabel.Text = "First time injected: " .. fi .. " (" .. fv .. ")\n\n" ..
                          "Time spent: " .. string.format("%dd %dh %dm", days, hours, mins) .. "\n\n" ..
                          "Total Age Potions farmed: " .. tostring(pots) .. "\n\n" ..
                          "Total Bucks earned: " .. tostring(bucks) .. " $"
    end

    Avatar.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages:GetChildren()) do 
            if p:IsA("ScrollingFrame") and p.Visible then
                TweenService:Create(p, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0, 0, 0, 25), BackgroundTransparency = 1}):Play()
                task.delay(0.2, function() p.Visible = false end)
            end
        end
        
        for _, b in pairs(TabsContainer:GetChildren()) do
            if b:IsA("ImageButton") then
                TweenService:Create(b, TweenInfo.new(0.3), {ImageColor3 = CurrentTheme.SubText}):Play()
                local ind = b:FindFirstChild("Frame")
                if ind then TweenService:Create(ind, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play() end
            end
        end
        
        UpdateStatsText()
        ProfilePage.Visible = true
        ProfilePage.Position = UDim2.new(-0.1, 0, 0, 0)
        TweenService:Create(ProfilePage, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
    end)

    task.spawn(function()
        while task.wait(1) do
            if ProfilePage.Visible then UpdateStatsText() end
        end
    end)

    Library:RunLoader(ScreenGui, function()
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.5), {GroupTransparency = 0}):Play()
    end)

    task.defer(function()
        Library:SetAnonymousMode(getgenv().AnonymousMode == true)
    end)

    return {Tabs = TabsContainer, Pages = Pages}
end

function Library:Notify(title, text, duration)
    local TweenService = game:GetService("TweenService")
    local ScreenGui = PlayerGui:FindFirstChild("DuskShine_Mega")
    if not ScreenGui then return end
    local Holder = ScreenGui:FindFirstChild("Notifications")
    if not Holder then return end

    duration = duration or 3
    local defaultIcon = "rbxassetid://283952329"

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(0, 320, 0, 55)
    Container.BackgroundTransparency = 1
    Container.Parent = Holder

    local Canvas = Instance.new("CanvasGroup")
    Canvas.Size = UDim2.new(1, 0, 1, -5)
    Canvas.Position = UDim2.new(1, 30, 0, 0)
    Canvas.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
    Canvas.GroupTransparency = 1 
    Canvas.BorderSizePixel = 0
    Canvas.Parent = Container
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6) 
    Corner.Parent = Canvas
    
    local CanvasStroke = Instance.new("UIStroke")
    CanvasStroke.Thickness = 1
    CanvasStroke.Transparency = 0.5
    AddTheme(CanvasStroke, "Color", "Stroke")
    CanvasStroke.Parent = Canvas

    local LeftBar = Instance.new("Frame")
    LeftBar.Size = UDim2.new(0, 3, 1, -16)
    LeftBar.Position = UDim2.new(0, 8, 0.5, 0)
    LeftBar.AnchorPoint = Vector2.new(0, 0.5)
    LeftBar.BorderSizePixel = 0
    AddTheme(LeftBar, "BackgroundColor3", "Accent")
    LeftBar.Parent = Canvas
    
    local LeftBarCorner = Instance.new("UICorner")
    LeftBarCorner.CornerRadius = UDim.new(1, 0)
    LeftBarCorner.Parent = LeftBar

    local TTitle = Instance.new("TextLabel")
    TTitle.Text = title
    TTitle.Font = Enum.Font.GothamBold
    TTitle.TextSize = 14
    AddTheme(TTitle, "TextColor3", "Text")
    TTitle.Size = UDim2.new(1, -75, 0, 20)
    TTitle.Position = UDim2.new(0, 22, 0, 6)
    TTitle.BackgroundTransparency = 1
    TTitle.TextXAlignment = Enum.TextXAlignment.Left
    TTitle.Parent = Canvas

    local TMsg = Instance.new("TextLabel")
    TMsg.Text = text
    TMsg.Font = Enum.Font.GothamMedium
    TMsg.TextSize = 12
    AddTheme(TMsg, "TextColor3", "SubText")
    TMsg.Size = UDim2.new(1, -75, 0, 20)
    TMsg.Position = UDim2.new(0, 22, 0, 24)
    TMsg.BackgroundTransparency = 1
    TMsg.TextXAlignment = Enum.TextXAlignment.Left
    TMsg.Parent = Canvas

    local Icon = Instance.new("ImageLabel")
    Icon.Size = UDim2.new(0, 28, 0, 28) 
    Icon.AnchorPoint = Vector2.new(1, 0.5)
    Icon.Position = UDim2.new(1, -12, 0.5, -2) 
    Icon.BackgroundTransparency = 1
    Icon.Image = defaultIcon
    Icon.Parent = Canvas

    local TimeBarBg = Instance.new("Frame")
    TimeBarBg.Size = UDim2.new(1, 0, 0, 1) 
    TimeBarBg.Position = UDim2.new(0, 0, 1, -1)
    TimeBarBg.BackgroundTransparency = 1
    TimeBarBg.BorderSizePixel = 0
    TimeBarBg.Parent = Canvas

    local TimeBar = Instance.new("Frame")
    TimeBar.Size = UDim2.new(1, 0, 1, 0)
    AddTheme(TimeBar, "BackgroundColor3", "Accent")
    TimeBar.BorderSizePixel = 0
    TimeBar.Parent = TimeBarBg
    
    local BarGradient = Instance.new("UIGradient")
    BarGradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.7, 0),
        NumberSequenceKeypoint.new(1, 1) 
    })
    BarGradient.Parent = TimeBar

    TBT(Canvas, 0.4, {Position = UDim2.new(0, 0, 0, 0), GroupTransparency = 0}, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    TBT(TimeBar, duration, {Size = UDim2.new(0, 0, 1, 0)}, Enum.EasingStyle.Linear)

    local isClosed = false
    local function Dismiss()
        if isClosed then return end
        isClosed = true
        
       local out = TBT(Canvas, 0.3, {Position = UDim2.new(0, 15, 0, 0), GroupTransparency = 1}, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        out:Play()
        out.Completed:Wait()
        Container:Destroy()
    end

    task.spawn(function()
        task.wait(duration)
        Dismiss()
    end)
end

function Library:ShowScreenStatus(text, duration)
    duration = duration or 3
    local ScreenGui = PlayerGui:FindFirstChild("DuskShine_Mega")
    if not ScreenGui then return end
    
    local old = ScreenGui:FindFirstChild("ScreenStatusFrame")
    if old then old:Destroy() end

    local Frame = Instance.new("Frame")
    Frame.Name = "ScreenStatusFrame"
    Frame.Size = UDim2.new(0, 0, 0, 40)
    Frame.AutomaticSize = Enum.AutomaticSize.X
    Frame.Position = UDim2.new(0.5, 0, 0.85, 20) 
    Frame.AnchorPoint = Vector2.new(0.5, 0.5)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 1000
    Frame.Parent = ScreenGui

    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 8)

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = CurrentTheme.Accent or Color3.fromRGB(170, 85, 255)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 1

    local Lbl = Instance.new("TextLabel", Frame)
    Lbl.Size = UDim2.new(1, 0, 1, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255) -- ЧИСТО БЕЛЫЙ ЦВЕТ
    Lbl.TextTransparency = 1
    Lbl.Font = Enum.Font.GothamBlack
    Lbl.TextSize = 16
    Lbl.RichText = true
    Lbl.Text = text
    
    -- Тень самого текста
    local TextStroke = Instance.new("UIStroke", Lbl)
    TextStroke.Color = Color3.fromRGB(0, 0, 0)
    TextStroke.Thickness = 1.2
    TextStroke.Transparency = 1

    local Pad = Instance.new("UIPadding", Frame)
    Pad.PaddingLeft = UDim.new(0, 20)
    Pad.PaddingRight = UDim.new(0, 20)

    local ts = game:GetService("TweenService")
    ts:Create(Frame, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0.85, 0), BackgroundTransparency = 0.15}):Play()
    ts:Create(Stroke, TweenInfo.new(0.5), {Transparency = 0}):Play()
    ts:Create(Lbl, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    ts:Create(TextStroke, TweenInfo.new(0.5), {Transparency = 0.3}):Play()

    task.spawn(function()
        task.wait(duration)
        if Frame and Frame.Parent then
            local t1 = ts:Create(Frame, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(0.5, 0, 0.85, 20), BackgroundTransparency = 1})
            ts:Create(Stroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
            ts:Create(Lbl, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
            ts:Create(TextStroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
            t1:Play()
            t1.Completed:Wait()
            Frame:Destroy()
        end
    end)
end

local function CreateRipple(Parent)
    Parent.ClipsDescendants = true
    
    local Ripple = Instance.new("Frame")
    Ripple.Name = "Ripple"
    Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ripple.BackgroundTransparency = 0.8
    Ripple.ZIndex = 10
    
    local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
    local AbsolutePosition = Parent.AbsolutePosition
    local MouseX = Mouse.X - AbsolutePosition.X
    local MouseY = Mouse.Y - AbsolutePosition.Y
    
    Ripple.Position = UDim2.new(0, MouseX, 0, MouseY)
    Ripple.Size = UDim2.new(0, 0, 0, 0)
    Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
    
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color3.fromRGB(255, 255, 255)
    UIStroke.Transparency = 0.8
    UIStroke.Thickness = 1
    UIStroke.Parent = Ripple
    
    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(1, 0)
    UICorner.Parent = Ripple
    
    Ripple.Parent = Parent
    
    local TweenService = game:GetService("TweenService")
    local TargetSize = math.max(Parent.AbsoluteSize.X, Parent.AbsoluteSize.Y) * 2.5
    
    local Tween = TweenService:Create(Ripple, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, TargetSize, 0, TargetSize),
        BackgroundTransparency = 1
    })
    
    TBT(UIStroke, 0.6, {Transparency = 1})
    
    Tween:Play()
    Tween.Completed:Connect(function()
        Ripple:Destroy()
    end)
end

function Library:CreateTab(Window, Name, IconId)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -4, 1, -15) 
    Page.Position = UDim2.new(0, 0, 0, 5)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 2 
    Page.ScrollBarImageTransparency = 0.2
    Page.BottomImage = ""
    Page.TopImage = ""
    AddTheme(Page, "ScrollBarImageColor3", "SubText")
    Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.Parent = Window.Pages
    
    local Layout = Instance.new("UIListLayout"); Layout.Padding = UDim.new(0, 12); Layout.SortOrder = Enum.SortOrder.LayoutOrder; Layout.Parent = Page
    local Pad = Instance.new("UIPadding"); Pad.PaddingTop = UDim.new(0, 10); Pad.PaddingLeft = UDim.new(0, 25); Pad.PaddingRight = UDim.new(0, 25); Pad.PaddingBottom = UDim.new(0, 15); Pad.Parent = Page

    local Btn = Instance.new("ImageButton")
    Btn.Size = UDim2.new(0, 32, 0, 32)
    Btn.BackgroundTransparency = 1
    Btn.Image = ""
    Btn.AutoButtonColor = false
    Btn:SetAttribute("Active", false)
    Btn.Parent = Window.Tabs

    local TabGlow = Instance.new("Frame")
    TabGlow.Name = "TabGlow"
    TabGlow.Size = UDim2.new(1.5, 0, 1, 10) 
    TabGlow.Position = UDim2.new(0, -10, 0.5, 0)
    TabGlow.AnchorPoint = Vector2.new(0, 0.5)
    TabGlow.BackgroundTransparency = 1
    TabGlow.BorderSizePixel = 0
    AddTheme(TabGlow, "BackgroundColor3", "Accent")
    TabGlow.ZIndex = 0
    TabGlow.Parent = Btn
    Instance.new("UICorner", TabGlow).CornerRadius = UDim.new(0, 8)
    
    local GlowGrad = Instance.new("UIGradient")
    GlowGrad.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.3), 
        NumberSequenceKeypoint.new(1, 1)  
    }
    GlowGrad.Rotation = 0 
    GlowGrad.Parent = TabGlow

    local TabIcon = Instance.new("ImageLabel")
    TabIcon.Name = "TabIcon"
    TabIcon.Size = UDim2.new(1, 0, 1, 0)
    TabIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
    TabIcon.AnchorPoint = Vector2.new(0.5, 0.5)
    TabIcon.BackgroundTransparency = 1
    TabIcon.Image = "rbxassetid://" .. IconId
    AddTheme(TabIcon, "ImageColor3", "SubText")
    TabIcon.ZIndex = 2
    TabIcon.Parent = Btn

    local Ind = Instance.new("Frame")
    Ind.Name = "Indicator"
    Ind.Size = UDim2.new(0, 4, 0.5, 0)
    Ind.Position = UDim2.new(0, -10, 0.5, 0)
    Ind.AnchorPoint = Vector2.new(0, 0.5)
    AddTheme(Ind, "BackgroundColor3", "Accent")
    Ind.BackgroundTransparency = 1
    Ind.Parent = Btn
    Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

    local Tooltip = Instance.new("TextLabel")
    Tooltip.Text = Name
    Tooltip.Size = UDim2.new(0, 0, 0, 22)
    Tooltip.AutomaticSize = Enum.AutomaticSize.X
    Tooltip.Position = UDim2.new(1, 15, 0.5, -11)
    Tooltip.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    Tooltip.TextColor3 = Color3.new(1, 1, 1)
    Tooltip.FontFace = MainFont
    Tooltip.TextSize = 12
    Tooltip.Visible = false
    Tooltip.ZIndex = 150
    Tooltip.Parent = Btn
    Instance.new("UICorner", Tooltip).CornerRadius = UDim.new(0, 4)
    Instance.new("UIPadding", Tooltip).PaddingLeft = UDim.new(0, 8); Instance.new("UIPadding", Tooltip).PaddingRight = UDim.new(0, 8)
    local TTStroke = Instance.new("UIStroke", Tooltip); AddTheme(TTStroke, "Color", "Stroke")
    
    Btn.MouseEnter:Connect(function() 
        Tooltip.Visible = true 
        if not Btn:GetAttribute("Active") then
            TweenService:Create(TabIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1.15, 0, 1.15, 0), ImageColor3 = CurrentTheme.Text}):Play()
            TweenService:Create(TabGlow, TweenInfo.new(0.3), {BackgroundTransparency = 0.6}):Play() 
        end
    end)
    
    Btn.MouseLeave:Connect(function() 
        Tooltip.Visible = false 
        if not Btn:GetAttribute("Active") then
            TweenService:Create(TabIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), ImageColor3 = CurrentTheme.SubText}):Play()
            TweenService:Create(TabGlow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        end
    end)

    Btn.MouseButton1Click:Connect(function()
        if Page.Visible then return end 

        if Window and Window.Pages and Window.Pages.Parent then
            for _, child in pairs(Window.Pages.Parent:GetChildren()) do
                if child.Name == "CustomOverlay" and child.Visible then
                    TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(1, 0, 0, 60)}):Play()
                    task.delay(0.2, function() child.Visible = false end)
                end
            end
        end

        if ProfilePage and ProfilePage.Visible then
            TweenService:Create(ProfilePage, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = UDim2.new(-0.1, 0, 0, 0)}):Play()
            task.delay(0.2, function() ProfilePage.Visible = false end)
        end

        for _, p in pairs(Window.Pages:GetChildren()) do 
            if (p:IsA("ScrollingFrame") or p:IsA("Frame")) and p.Visible then 
                p.Visible = false 
            end
        end

        for _, b in pairs(Window.Tabs:GetChildren()) do
            if b:IsA("ImageButton") and b ~= Btn then 
                b:SetAttribute("Active", false)
                local icon = b:FindFirstChild("TabIcon")
                local glow = b:FindFirstChild("TabGlow")
                local ind = b:FindFirstChild("Indicator")
                
                if icon then 
                    ThemeObjects[icon]["ImageColor3"] = "SubText" 
                    TweenService:Create(icon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 1, 0), ImageColor3 = CurrentTheme.SubText}):Play() 
                end
                if glow then TweenService:Create(glow, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play() end
                if ind then TweenService:Create(ind, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play() end
            end
        end

        Btn:SetAttribute("Active", true)
        Page.Visible = true
        Page.Position = UDim2.new(0, 0, 0, 25) 
        TweenService:Create(Page, TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 5)}):Play()

        ThemeObjects[TabIcon]["ImageColor3"] = "Accent" 
        TweenService:Create(TabIcon, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1.15, 0, 1.15, 0), ImageColor3 = CurrentTheme.Accent}):Play()
        TweenService:Create(TabGlow, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play() 
        TweenService:Create(Ind, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
    end)

    if #Window.Tabs:GetChildren() == 2 then
        Btn:SetAttribute("Active", true)
        Page.Visible = true
        TabIcon.ImageColor3 = CurrentTheme.Accent
        TabIcon.Size = UDim2.new(1.15, 0, 1.15, 0)
        TabGlow.BackgroundTransparency = 0
        Ind.BackgroundTransparency = 0
    end

    local ElementCount = 0
    local CurrentGrid = nil
    local Funcs = {}

    function Funcs:CreateBigTitle(text)
        CurrentGrid = nil
        ElementCount = ElementCount + 1 
        
        local S = Instance.new("TextLabel")
        S.LayoutOrder = ElementCount 
        S.Text = text
        S.Size = UDim2.new(1, 0, 0, 45) -- Сделал чуть выше, чтобы влез крупный шрифт
        S.BackgroundTransparency = 1
        AddTheme(S, "TextColor3", "Accent")
        S.Font = Enum.Font.GothamBlack
        S.TextSize = 22
        S.TextXAlignment = Enum.TextXAlignment.Left
        S.TextYAlignment = Enum.TextYAlignment.Bottom
        S.Parent = Page
        
        -- Выравниваем точно так же, как в CreateSection
        Instance.new("UIPadding", S).PaddingTop = UDim.new(0, 10)
    end

    function Funcs:CreateSection(text)
        CurrentGrid = nil
        ElementCount = ElementCount + 1 
        local S = Instance.new("TextLabel")
        S.LayoutOrder = ElementCount 
        S.Text = text
        S.Size = UDim2.new(1, 0, 0, 35)
        S.BackgroundTransparency = 1
        AddTheme(S, "TextColor3", "SubText")
        S.FontFace = MainFont
        S.TextSize = 13
        S.TextXAlignment = Enum.TextXAlignment.Left
        S.Parent = Page
        Instance.new("UIPadding", S).PaddingTop = UDim.new(0, 15)
    end

    function Funcs:CreateText(text, iconStr)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount
        F.Size = UDim2.new(1, 0, 0, 0)
        F.AutomaticSize = Enum.AutomaticSize.Y
        F.BackgroundTransparency = 1
        F.Parent = Page
        
        local Layout = Instance.new("UIListLayout", F)
        Layout.FillDirection = Enum.FillDirection.Horizontal
        Layout.VerticalAlignment = Enum.VerticalAlignment.Center
        Layout.Padding = UDim.new(0, 12)
        Layout.SortOrder = Enum.SortOrder.LayoutOrder
        
        local Pad = Instance.new("UIPadding", F)
        Pad.PaddingTop = UDim.new(0, 6)
        Pad.PaddingBottom = UDim.new(0, 6)

        local hasIcon = (iconStr ~= nil and iconStr ~= "")
        
        if hasIcon then
            local Icon = Instance.new("ImageLabel")
            Icon.LayoutOrder = 1
            Icon.Size = UDim2.new(0, 26, 0, 26)
            Icon.BackgroundTransparency = 1
            Icon.Parent = F
            
            if iconStr == "avatar" then
                Icon.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"
                Instance.new("UICorner", Icon).CornerRadius = UDim.new(1, 0)
                local str = Instance.new("UIStroke", Icon); AddTheme(str, "Color", "Stroke")
                
                -- Поддержка Anonymous Mode
                local A_Letter = Instance.new("TextLabel", Icon)
                A_Letter.Size = UDim2.new(1, 0, 1, 0); A_Letter.BackgroundTransparency = 1
                A_Letter.Text = "A"; A_Letter.Font = Enum.Font.GothamBold; A_Letter.TextSize = 14
                AddTheme(A_Letter, "TextColor3", "Accent")
                A_Letter.Visible = getgenv().AnonymousMode == true
                
                if getgenv().AnonymousMode then 
                    Icon.ImageTransparency = 1; Icon.BackgroundColor3 = Color3.new(0,0,0); Icon.BackgroundTransparency = 0 
                end
                table.insert(Library.AnonItems.Avatars, {ImageObj = Icon, Letter = A_Letter})
            else
                Icon.Image = iconStr
                AddTheme(Icon, "ImageColor3", "Accent")
            end
        end
        
        local T = Instance.new("TextLabel")
        T.LayoutOrder = 2
        T.Size = UDim2.new(1, hasIcon and -38 or 0, 0, 0)
        T.AutomaticSize = Enum.AutomaticSize.Y
        T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "Text")
        T.FontFace = MainFont
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.TextYAlignment = Enum.TextYAlignment.Center
        T.TextWrapped = true
        T.RichText = true 
        T.Parent = F

        if iconStr == "avatar" then
        local formatStr = text:gsub(LocalPlayer.DisplayName, "%%s")
            table.insert(Library.AnonItems.Names, {Obj = T, Format = formatStr})
            local nameToUse = getgenv().AnonymousMode and "Hidden User" or LocalPlayer.DisplayName
            T.Text = string.format(formatStr, nameToUse)
        else
            T.Text = text
        end
        
        return T
    end

    function Funcs:CreateToggle(title, desc, default, callback, settingsCallback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1 
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount 
        F.Size = UDim2.new(1, 0, 0, 70)
        AddTheme(F, "BackgroundColor3", "Section")
        F.Parent = Page
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
        local Str = Instance.new("UIStroke"); AddTheme(Str, "Color", "Stroke"); Str.Thickness = 1; Str.Parent = F

        local T = Instance.new("TextLabel")
        T.Text = title; T.Size = UDim2.new(1, -70, 0, 20); T.Position = UDim2.new(0, 20, 0, 15); T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "Text")
        T.FontFace = MainFont; T.TextSize = 16; T.TextXAlignment = Enum.TextXAlignment.Left; T.Parent = F

        local D = Instance.new("TextLabel")
        D.Text = desc; D.Size = UDim2.new(1, -90, 0, 15); D.Position = UDim2.new(0, 20, 0, 38); D.BackgroundTransparency = 1
        AddTheme(D, "TextColor3", "SubText")
        D.FontFace = MainFont; D.TextSize = 13; D.TextXAlignment = Enum.TextXAlignment.Left; D.Parent = F

        local Sw = Instance.new("TextButton")
        Sw.Text = ""; Sw.Size = UDim2.new(0, 48, 0, 26); Sw.AnchorPoint = Vector2.new(1, 0.5); Sw.Position = UDim2.new(1, -20, 0.5, 0)
        AddTheme(Sw, "BackgroundColor3", default and "Accent" or "ToggleOff")
        Sw.Parent = F; Instance.new("UICorner", Sw).CornerRadius = UDim.new(1,0)

        local Kn = Instance.new("Frame")
        Kn.Size = UDim2.new(0, 20, 0, 20); Kn.AnchorPoint = Vector2.new(0, 0.5)
        local OnP = UDim2.new(1, -23, 0.5, 0); local OffP = UDim2.new(0, 3, 0.5, 0)
        Kn.Position = default and OnP or OffP
        AddTheme(Kn, "BackgroundColor3", "Knob")
        Kn.Parent = Sw; Instance.new("UICorner", Kn).CornerRadius = UDim.new(1,0)
        
        if settingsCallback then
            local Gear = Instance.new("ImageButton")
            Gear.Size = UDim2.new(0, 20, 0, 20)
            Gear.AnchorPoint = Vector2.new(1, 0.5)
            Gear.Position = UDim2.new(1, -80, 0.5, 0)
            Gear.BackgroundTransparency = 1
            Gear.Image = "rbxassetid://7734053495"
            AddTheme(Gear, "ImageColor3", "SubText")
            Gear.Parent = F
            
            Gear.MouseButton1Click:Connect(function()
                if CreateRipple then CreateRipple(Gear) end
                pcall(settingsCallback)
            end)
        end

        local on = default
        
        local function SetState(newState)
            if on == newState then return end
            on = newState
            ThemeObjects[Sw]["BackgroundColor3"] = on and "Accent" or "ToggleOff"
            local tPos = on and OnP or OffP
            local tCol = on and CurrentTheme.Accent or CurrentTheme.ToggleOff
            TweenService:Create(Sw, TweenInfo.new(0.25), {BackgroundColor3 = tCol}):Play()
            TweenService:Create(Kn, TweenInfo.new(0.25), {Position = tPos}):Play()
        end

        Sw.MouseButton1Click:Connect(function()
            SetState(not on)
            pcall(callback, on)
        end)
        
        local function SetTitle(newTitle)
            T.Text = newTitle
        end
        
        return { SetState = SetState, SetTitle = SetTitle }
    end

    -- 4. BUTTON (Неоновый редизайн с акцентом по краям)
    function Funcs:CreateButton(text, callback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local B = Instance.new("TextButton")
        B.LayoutOrder = ElementCount
        B.Size = UDim2.new(1, 0, 0, 45)
        B.Text = text
        B.FontFace = MainFont
        B.TextSize = 14
        B.AutoButtonColor = false
        AddTheme(B, "BackgroundColor3", "Section")
        AddTheme(B, "TextColor3", "Text")
        B.Parent = Page
        
        Instance.new("UICorner", B).CornerRadius = UDim.new(0, 10)
        
        -- ФИКС: Указываем, что обводка должна быть только по рамке (не на тексте!)
        local Str = Instance.new("UIStroke")
        Str.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        AddTheme(Str, "Color", "Accent")
        Str.Thickness = 1.5
        Str.Transparency = 0.4
        Str.Parent = B
        
        local btnScale = Instance.new("UIScale", B)
        
        B.MouseEnter:Connect(function()
            TweenService:Create(Str, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0, Thickness = 2}):Play()
        end)
        
        B.MouseLeave:Connect(function()
            TweenService:Create(Str, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0.4, Thickness = 1.5}):Play()
        end)
        
        B.MouseButton1Click:Connect(function()
            -- Эффект "пружинистого" нажатия
            local t1 = TweenService:Create(btnScale, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Scale = 0.96})
            t1:Play()
            t1.Completed:Connect(function() 
                TweenService:Create(btnScale, TweenInfo.new(0.2, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1}):Play() 
            end)
            
            if CreateRipple then CreateRipple(B) end
            pcall(callback)
        end)
        
        return B
    end

    -- 4.5 DUAL TILE SELECTOR (Выбор из двух вариантов плитками)
    function Funcs:CreateDualTile(title, opt1, opt2, default, callback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount
        F.Size = UDim2.new(1, 0, 0, 85)
        F.BackgroundTransparency = 1
        F.Parent = Page

        local T = Instance.new("TextLabel")
        T.Text = title
        T.Size = UDim2.new(1, 0, 0, 20)
        T.Position = UDim2.new(0, 5, 0, 5)
        T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "SubText")
        T.FontFace = MainFont
        T.TextSize = 13
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = F

        local TileContainer = Instance.new("Frame")
        TileContainer.Size = UDim2.new(1, 0, 0, 50)
        TileContainer.Position = UDim2.new(0, 0, 0, 30)
        TileContainer.BackgroundTransparency = 1
        TileContainer.Parent = F
        
        local List = Instance.new("UIListLayout")
        List.FillDirection = Enum.FillDirection.Horizontal
        List.Padding = UDim.new(0.04, 0)
        List.Parent = TileContainer

        local activeOpt = default

        local function createTile(text)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0.48, 0, 1, 0)
            Btn.Text = text
            Btn.FontFace = MainFont
            Btn.TextSize = 14
            Btn.AutoButtonColor = false
            AddTheme(Btn, "BackgroundColor3", "Section")
            Btn.Parent = TileContainer
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
            
            local Str = Instance.new("UIStroke")
            Str.Thickness = 2
            Str.Parent = Btn
            
            local function updateVis()
                ThemeObjects[Btn] = ThemeObjects[Btn] or {}
                ThemeObjects[Str] = ThemeObjects[Str] or {}

                if activeOpt == text then
                    ThemeObjects[Btn]["BackgroundColor3"] = "Accent"
                    ThemeObjects[Btn]["TextColor3"] = "Background"
                    ThemeObjects[Str]["Color"] = "Accent"
                    
                    TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Accent}):Play()
                    TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.Background}):Play()
                    TweenService:Create(Str, TweenInfo.new(0.2), {Transparency = 1}):Play()
                else
                    ThemeObjects[Btn]["BackgroundColor3"] = "Section"
                    ThemeObjects[Btn]["TextColor3"] = "Text"
                    ThemeObjects[Str]["Color"] = "Stroke"
                    
                    TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = CurrentTheme.Section}):Play()
                    TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.Text}):Play()
                    TweenService:Create(Str, TweenInfo.new(0.2), {Transparency = 0, Color = CurrentTheme.Stroke}):Play()
                end
            end

            Btn.MouseButton1Click:Connect(function()
                if CreateRipple then CreateRipple(Btn) end
                activeOpt = text
                pcall(callback, text)
            end)

            return updateVis
        end

        local upd1 = createTile(opt1)
        local upd2 = createTile(opt2)

        local function MasterUpdate()
            upd1(); upd2()
        end
        MasterUpdate()

        local realCb = callback
        callback = function(val)
            MasterUpdate()
            realCb(val)
        end
    end

    function Funcs:CreateToggleWithModes(title, desc, default, mode1, mode2, defaultMode, callback, modeCallback, settingsCallback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1 
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount 
        F.Size = UDim2.new(1, 0, 0, 70)
        AddTheme(F, "BackgroundColor3", "Section")
        F.BackgroundTransparency = 0.2 
        F.Parent = Page
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 12)
        local Str = Instance.new("UIStroke"); AddTheme(Str, "Color", "Stroke"); Str.Thickness = 1.5; Str.Transparency = 0.6; Str.Parent = F

        local T = Instance.new("TextLabel")
        T.Text = title; T.Size = UDim2.new(1, -165, 0, 20); T.Position = UDim2.new(0, 20, 0, 15); T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "Text")
        T.FontFace = MainFont; T.TextSize = 16; T.TextXAlignment = Enum.TextXAlignment.Left; T.Parent = F

        local D = Instance.new("TextLabel")
        D.Text = desc; D.Size = UDim2.new(1, -165, 0, 15); D.Position = UDim2.new(0, 20, 0, 38); D.BackgroundTransparency = 1
        AddTheme(D, "TextColor3", "SubText")
        D.FontFace = MainFont; D.TextSize = 13; D.TextXAlignment = Enum.TextXAlignment.Left; D.Parent = F

        local Sw = Instance.new("TextButton")
        Sw.Text = ""; Sw.Size = UDim2.new(0, 48, 0, 26); Sw.AnchorPoint = Vector2.new(1, 0.5); Sw.Position = UDim2.new(1, -20, 0.5, 0)
        AddTheme(Sw, "BackgroundColor3", default and "Accent" or "ToggleOff")
        Sw.Parent = F; Instance.new("UICorner", Sw).CornerRadius = UDim.new(1,0)

        local Kn = Instance.new("Frame")
        Kn.Size = UDim2.new(0, 20, 0, 20); Kn.AnchorPoint = Vector2.new(0, 0.5)
        local OnP = UDim2.new(1, -23, 0.5, 0); local OffP = UDim2.new(0, 3, 0.5, 0)
        Kn.Position = default and OnP or OffP
        AddTheme(Kn, "BackgroundColor3", "Knob")
        Kn.Parent = Sw; Instance.new("UICorner", Kn).CornerRadius = UDim.new(1,0)

        if settingsCallback then
            local Gear = Instance.new("ImageButton")
            Gear.Size = UDim2.new(0, 22, 0, 22)
            Gear.AnchorPoint = Vector2.new(1, 0.5)
            Gear.Position = UDim2.new(1, -145, 0.5, 0)
            Gear.BackgroundTransparency = 1
            Gear.Image = "rbxassetid://7734053495"
            AddTheme(Gear, "ImageColor3", "SubText")
            Gear.Parent = F
            
            Gear.MouseButton1Click:Connect(function()
                if CreateRipple then CreateRipple(Gear) end
                pcall(settingsCallback)
            end)
        end

        local activeMode = defaultMode

        local function CreateModeBtn(text, xPos, modeValue)
            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(0, 26, 0, 26)
            Btn.AnchorPoint = Vector2.new(1, 0.5)
            Btn.Position = UDim2.new(1, xPos, 0.5, 0)
            Btn.Text = text
            Btn.FontFace = MainFont
            Btn.TextSize = 13
            Btn.AutoButtonColor = false
            AddTheme(Btn, "BackgroundColor3", "Sidebar")
            Btn.BackgroundTransparency = 0.3
            Btn.Parent = F
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
            
            local BtnStr = Instance.new("UIStroke")
            BtnStr.Thickness = 1
            BtnStr.Parent = Btn
            
            local function UpdateVisual()
                if activeMode == modeValue then
                    TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.Accent}):Play()
                    TweenService:Create(BtnStr, TweenInfo.new(0.2), {Color = CurrentTheme.Accent, Transparency = 0}):Play()
                else
                    TweenService:Create(Btn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.SubText}):Play()
                    TweenService:Create(BtnStr, TweenInfo.new(0.2), {Color = CurrentTheme.Stroke, Transparency = 0.5}):Play()
                end
            end
            
            Btn.MouseButton1Click:Connect(function()
                if activeMode ~= modeValue then
                    activeMode = modeValue
                    local t1 = TweenService:Create(Btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(0, 22, 0, 22)})
                    local t2 = TweenService:Create(Btn, TweenInfo.new(0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {Size = UDim2.new(0, 26, 0, 26)})
                    t1:Play(); t1.Completed:Wait(); t2:Play()
                    pcall(modeCallback, activeMode)
                end
            end)
            return UpdateVisual
        end

        local update1 = CreateModeBtn(mode1.Text, -80, mode1.Value) 
        local update2 = CreateModeBtn(mode2.Text, -110, mode2.Value) 

        local function UpdateAllVisuals() update1(); update2() end
        UpdateAllVisuals()

        local realModeCallback = modeCallback
        modeCallback = function(val) UpdateAllVisuals(); realModeCallback(val) end

        local on = default
        local function SetState(newState)
            if on == newState then return end
            on = newState
            ThemeObjects[Sw]["BackgroundColor3"] = on and "Accent" or "ToggleOff"
            local tPos = on and OnP or OffP
            local tCol = on and CurrentTheme.Accent or CurrentTheme.ToggleOff
            TweenService:Create(Sw, TweenInfo.new(0.25), {BackgroundColor3 = tCol}):Play()
            TweenService:Create(Kn, TweenInfo.new(0.25), {Position = tPos}):Play()
        end

        Sw.MouseButton1Click:Connect(function() SetState(not on); pcall(callback, on) end)
        return { SetState = SetState }
    end
    
    -- 5. LIST (Выпадающий список)
    function Funcs:CreateList(title, items, arg3, arg4)
        local defaultVal = type(arg3) == "string" and arg3 or nil
        local callback = type(arg3) == "function" and arg3 or arg4
        
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local Frame = Instance.new("Frame")
        Frame.LayoutOrder = ElementCount
        Frame.Size = UDim2.new(1, 0, 0, 45)
        Frame.ClipsDescendants = true
        AddTheme(Frame, "BackgroundColor3", "Section")
        Frame.Parent = Page
        
        Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
        local Str = Instance.new("UIStroke"); AddTheme(Str, "Color", "Stroke"); Str.Thickness = 1; Str.Parent = Frame
        
        local Header = Instance.new("TextButton")
        Header.Size = UDim2.new(1, 0, 0, 45)
        Header.BackgroundTransparency = 1
        Header.Text = ""
        Header.Parent = Frame
        
        local T = Instance.new("TextLabel")
        T.Text = title .. (defaultVal and (": " .. defaultVal) or "")
        T.Size = UDim2.new(1, -40, 0, 45)
        T.Position = UDim2.new(0, 15, 0, 0)
        T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "Text")
        T.FontFace = MainFont
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = Header
        
        local Arrow = Instance.new("ImageLabel")
        Arrow.Size = UDim2.new(0, 20, 0, 20); Arrow.AnchorPoint = Vector2.new(1, 0.5); Arrow.Position = UDim2.new(1, -15, 0.5, 0)
        Arrow.BackgroundTransparency = 1; Arrow.Image = "rbxassetid://6034818372"
        AddTheme(Arrow, "ImageColor3", "SubText"); Arrow.Parent = Header

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 30)
    SearchBox.Position = UDim2.new(0, 10, 0, 50)
    SearchBox.PlaceholderText = "Search in list..."
    SearchBox.Text = ""
    SearchBox.Visible = false 
    AddTheme(SearchBox, "BackgroundColor3", "Sidebar")
    AddTheme(SearchBox, "TextColor3", "Text")
    AddTheme(SearchBox, "PlaceholderColor3", "SubText")
    SearchBox.FontFace = MainFont; SearchBox.TextSize = 13
    SearchBox.Parent = Frame
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

    local ItemContainer = Instance.new("ScrollingFrame")
    ItemContainer.Size = UDim2.new(1, 0, 0, 150)
    ItemContainer.Position = UDim2.new(0, 0, 0, 85)
    ItemContainer.BackgroundTransparency = 1
    ItemContainer.ScrollBarThickness = 2
    ItemContainer.Visible = false
    ItemContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ItemContainer.Parent = Frame
    
    local IList = Instance.new("UIListLayout"); IList.Padding = UDim.new(0, 2); IList.Parent = ItemContainer
    
    IList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ItemContainer.CanvasSize = UDim2.new(0, 0, 0, IList.AbsoluteContentSize.Y)
    end)
    
    local function populate(filter)
        for _, c in pairs(ItemContainer:GetChildren()) do 
            if c:IsA("TextButton") then c:Destroy() end 
        end
        
        local filterText = string.lower(filter or "")
        for _, item in ipairs(items or {}) do
            if filterText == "" or string.find(string.lower(item), filterText) then
                local IB = Instance.new("TextButton")
                IB.Size = UDim2.new(1, 0, 0, 35); IB.BackgroundTransparency = 1
                IB.Text = "  " .. item; IB.FontFace = MainFont; IB.TextSize = 13
                IB.TextXAlignment = Enum.TextXAlignment.Left; AddTheme(IB, "TextColor3", "SubText")
                IB.Parent = ItemContainer
                
                IB.MouseButton1Click:Connect(function()
                    T.Text = title .. ": " .. item
                    pcall(callback, item)
                end)
            end
        end
    end

        local isOpen = false
        Header.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            local targetHeight = isOpen and 250 or 45
            
            if isOpen then
                SearchBox.Text = "" 
                populate("") 
            end
            
            SearchBox.Visible = isOpen
            ItemContainer.Visible = isOpen
            
            TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
            TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = isOpen and 180 or 0}):Play()
        end)

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            populate(SearchBox.Text)
        end)

        return { 
            SetTitle = function(newTitle) T.Text = title .. ": " .. newTitle end,
            Refresh = function(newItems)
                items = newItems
                populate(SearchBox.Text) 
            end
        }
end
-- ==========================================
-- 5.1 MULTI-LIST (Мультивыборный список)
-- ==========================================
local TweenService = game:GetService("TweenService") -- Обязательно убедись, что сервис подключен

function Funcs:CreateMultiList(title, items, callback)
    items = items or {} -- ЖЕЛЕЗОБЕТОННАЯ ЗАЩИТА ОТ NIL
    
    CurrentGrid = nil
    -- Защита на случай, если ElementCount не определен глобально
    ElementCount = (ElementCount or 0) + 1 
    
    local selected = {} 
    
    local Frame = Instance.new("Frame")
    Frame.LayoutOrder = ElementCount
    Frame.Size = UDim2.new(1, 0, 0, 45)
    Frame.ClipsDescendants = true
    AddTheme(Frame, "BackgroundColor3", "Section")
    Frame.Parent = Page -- Page должен быть передан или доступен глобально
    
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 10)
    local Str = Instance.new("UIStroke")
    AddTheme(Str, "Color", "Stroke"); Str.Thickness = 1; Str.Parent = Frame
    
    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.Parent = Frame
    
    local T = Instance.new("TextLabel")
    T.Text = title .. ": [0]"
    T.Size = UDim2.new(1, -40, 0, 45)
    T.Position = UDim2.new(0, 15, 0, 0)
    T.BackgroundTransparency = 1
    AddTheme(T, "TextColor3", "Text")
    T.FontFace = MainFont
    T.TextSize = 14
    T.TextXAlignment = Enum.TextXAlignment.Left
    T.Parent = Header
    
    local Arrow = Instance.new("ImageLabel")
    Arrow.Size = UDim2.new(0, 20, 0, 20)
    Arrow.AnchorPoint = Vector2.new(1, 0.5)
    Arrow.Position = UDim2.new(1, -15, 0.5, 0)
    Arrow.BackgroundTransparency = 1; Arrow.Image = "rbxassetid://6034818372"
    AddTheme(Arrow, "ImageColor3", "SubText"); Arrow.Parent = Header

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(1, -20, 0, 30)
    SearchBox.Position = UDim2.new(0, 10, 0, 50)
    SearchBox.PlaceholderText = "Search in list..."
    SearchBox.Text = ""
    SearchBox.Visible = false 
    AddTheme(SearchBox, "BackgroundColor3", "Sidebar")
    AddTheme(SearchBox, "TextColor3", "Text")
    AddTheme(SearchBox, "PlaceholderColor3", "SubText")
    SearchBox.FontFace = MainFont; SearchBox.TextSize = 13
    SearchBox.Parent = Frame
    Instance.new("UICorner", SearchBox).CornerRadius = UDim.new(0, 6)

    local ItemContainer = Instance.new("ScrollingFrame")
    ItemContainer.Size = UDim2.new(1, 0, 0, 150)
    ItemContainer.Position = UDim2.new(0, 0, 0, 85)
    ItemContainer.BackgroundTransparency = 1
    ItemContainer.ScrollBarThickness = 2
    ItemContainer.Visible = false
    ItemContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    ItemContainer.Parent = Frame
    
    local IList = Instance.new("UIListLayout"); IList.Padding = UDim.new(0, 2); IList.Parent = ItemContainer
    
    IList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        ItemContainer.CanvasSize = UDim2.new(0, 0, 0, IList.AbsoluteContentSize.Y)
    end)
    
    local function populate(filter)
        -- Очищаем только при поиске или первом открытии
        for _, c in pairs(ItemContainer:GetChildren()) do 
            if c:IsA("TextButton") then c:Destroy() end 
        end
        
        local filterText = string.lower(filter or "")
        for _, item in ipairs(items) do 
            if filterText == "" or string.find(string.lower(item), filterText) then
                local isSelected = table.find(selected, item) ~= nil
                
                local IB = Instance.new("TextButton")
                IB.Size = UDim2.new(1, 0, 0, 35); IB.BackgroundTransparency = 1
                
                IB.Text = (isSelected and "  [✓] " or "  [ ] ") .. item
                IB.FontFace = MainFont; IB.TextSize = 13
                IB.TextXAlignment = Enum.TextXAlignment.Left
                
                if isSelected then
                    AddTheme(IB, "TextColor3", "Text")
                else
                    AddTheme(IB, "TextColor3", "SubText")
                end
                IB.Parent = ItemContainer
                
                -- ИСПРАВЛЕНИЕ: Обновляем только состояние этой кнопки, не перерисовывая весь гуи
                IB.MouseButton1Click:Connect(function()
                    local idx = table.find(selected, item)
                    if idx then
                        table.remove(selected, idx)
                        isSelected = false
                    else
                        table.insert(selected, item)
                        isSelected = true
                    end
                    
                    -- Обновляем визуал самой кнопки напрямую
                    IB.Text = (isSelected and "  [✓] " or "  [ ] ") .. item
                    if isSelected then
                        AddTheme(IB, "TextColor3", "Text")
                    else
                        AddTheme(IB, "TextColor3", "SubText")
                    end
                    
                    T.Text = title .. ": [" .. #selected .. "]"
                    
                    -- Вызываем коллбэк с обновленной таблицей
                    if callback then
                        pcall(callback, selected)
                    end
                end)
            end
        end
    end

    local isOpen = false
    Header.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local targetHeight = isOpen and 250 or 45
        
        if isOpen then
            SearchBox.Text = "" 
            populate("") 
        end
        
        SearchBox.Visible = isOpen
        ItemContainer.Visible = isOpen
        
        TweenService:Create(Frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, targetHeight)}):Play()
        TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = isOpen and 180 or 0}):Play()
    end)

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        populate(SearchBox.Text)
    end)

    return { 
        ClearSelection = function()
            selected = {}
            T.Text = title .. ": [0]"
            populate(SearchBox.Text)
            if callback then pcall(callback, selected) end
        end,
        Refresh = function(newItems)
            items = newItems or {}
            populate(SearchBox.Text) 
        end
    }
end    -- 6. FLAT (Вариант: Картинка на весь фон)
    function Funcs:CreateFlat(text, iconId, arg3, arg4)
        local callback = type(arg4) == "function" and arg4 or arg3
        if not CurrentGrid then
            ElementCount = ElementCount + 1
            CurrentGrid = Instance.new("Frame")
            CurrentGrid.Name = "GridContainer"
            CurrentGrid.LayoutOrder = ElementCount
            CurrentGrid.Size = UDim2.new(1, 0, 0, 0)
            CurrentGrid.AutomaticSize = Enum.AutomaticSize.Y
            CurrentGrid.BackgroundTransparency = 1
            CurrentGrid.Parent = Page
            
            local Grid = Instance.new("UIGridLayout")
            Grid.CellSize = UDim2.new(0.48, 0, 0, 125)
            Grid.CellPadding = UDim2.new(0.04, 0, 0, 18)
            Grid.SortOrder = Enum.SortOrder.LayoutOrder
            Grid.Parent = CurrentGrid
        end

        local Tile = Instance.new("TextButton")
        Tile.Text = ""
        Tile.AutoButtonColor = false
        AddTheme(Tile, "BackgroundColor3", "Section")
        Tile.Parent = CurrentGrid
        Tile.ClipsDescendants = false
        Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 14)

        local RippleContainer = Instance.new("Frame")
        RippleContainer.Name = "RippleContainer"
        RippleContainer.Size = UDim2.new(1, 0, 1, 0)
        RippleContainer.BackgroundTransparency = 1
        RippleContainer.ClipsDescendants = true
        RippleContainer.ZIndex = 10
        RippleContainer.Parent = Tile
        Instance.new("UICorner", RippleContainer).CornerRadius = UDim.new(0, 14)
        
        local AccentLine = Instance.new("Frame")
        AccentLine.Name = "NeonLine"
        AccentLine.Size = UDim2.new(0.6, 0, 0, 3)
        AccentLine.Position = UDim2.new(0.5, 0, 0, -8)
        AccentLine.AnchorPoint = Vector2.new(0.5, 1)
        AccentLine.BorderSizePixel = 0
        AccentLine.ZIndex = 5
        AddTheme(AccentLine, "BackgroundColor3", "Accent")
        AccentLine.Parent = Tile
        Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(1, 0)

        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(1, 0, 1, 0)
        Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
        Icon.AnchorPoint = Vector2.new(0.5, 0.5)
        Icon.BackgroundTransparency = 1
        Icon.ZIndex = 1
        Icon.ScaleType = Enum.ScaleType.Crop
        Icon.Image = "rbxassetid://" .. (iconId or "18957829775")
        Icon.ImageColor3 = Color3.fromRGB(180, 180, 180)
        Icon.Parent = Tile
        Instance.new("UICorner", Icon).CornerRadius = UDim.new(0, 14)

        local GradFrame = Instance.new("Frame")
        GradFrame.Size = UDim2.new(1, 0, 0.6, 0)
        GradFrame.Position = UDim2.new(0, 0, 1, 0)
        GradFrame.AnchorPoint = Vector2.new(0, 1)
        GradFrame.BackgroundTransparency = 1
        GradFrame.ZIndex = 2
        GradFrame.Parent = Tile
        
        local Grad = Instance.new("UIGradient")
        Grad.Rotation = 90
        Grad.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 1),
            NumberSequenceKeypoint.new(1, 0.1)
        })
        Grad.Color = ColorSequence.new(Color3.new(0,0,0))
        Grad.Parent = GradFrame

        local Label = Instance.new("TextLabel")
        Label.Text = text:upper()
        Label.Size = UDim2.new(1, -15, 0, 35)
        Label.Position = UDim2.new(0.5, 0, 1, -2) 
        Label.AnchorPoint = Vector2.new(0.5, 1)
        Label.BackgroundTransparency = 1
        Label.TextColor3 = Color3.new(1, 1, 1)
        Label.Font = Enum.Font.GothamBold
        Label.TextSize = 18 
        Label.ZIndex = 3
        Label.Parent = Tile
        
        local TextStroke = Instance.new("UIStroke")
        TextStroke.Thickness = 1.5
        TextStroke.Transparency = 0.4
        TextStroke.Parent = Label

        Tile.MouseEnter:Connect(function()
            TweenService:Create(Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.new(1, 1, 1), Size = UDim2.new(1.08, 0, 1.08, 0)}):Play()
            TweenService:Create(AccentLine, TweenInfo.new(0.3), {Size = UDim2.new(0.8, 0, 0, 4)}):Play()
        end)
        Tile.MouseLeave:Connect(function()
            TweenService:Create(Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(180, 180, 180), Size = UDim2.new(1, 0, 1, 0)}):Play()
            TweenService:Create(AccentLine, TweenInfo.new(0.3), {Size = UDim2.new(0.6, 0, 0, 3)}):Play()
        end)

        Tile.MouseButton1Click:Connect(function()
            CreateRipple(RippleContainer)
            if type(callback) == "function" then
                pcall(callback)
            end
        end)
    end

    function Funcs:CreateCopyLink(text, url)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local Btn = Instance.new("TextButton")
        Btn.LayoutOrder = ElementCount
        Btn.Size = UDim2.new(1, 0, 0, 45)
        Btn.Text = ""
        Btn.AutoButtonColor = false
        AddTheme(Btn, "BackgroundColor3", "Section")
        Btn.Parent = Page
        
        Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
        local Str = Instance.new("UIStroke"); AddTheme(Str, "Color", "Stroke"); Str.Thickness = 1; Str.Parent = Btn
        
        local Icon = Instance.new("ImageLabel")
        Icon.Size = UDim2.new(0, 22, 0, 22)
        Icon.Position = UDim2.new(0, 12, 0.5, 0)
        Icon.AnchorPoint = Vector2.new(0, 0.5)
        Icon.BackgroundTransparency = 1
        Icon.Image = "rbxassetid://99625725727957"
        AddTheme(Icon, "ImageColor3", "SubText")
        Icon.Parent = Btn
        
        local Label = Instance.new("TextLabel")
        Label.Text = text
        Label.Size = UDim2.new(1, -50, 1, 0)
        Label.Position = UDim2.new(0, 45, 0, 0)
        Label.BackgroundTransparency = 1
        AddTheme(Label, "TextColor3", "Text")
        Label.FontFace = MainFont
        Label.TextSize = 14
        Label.TextXAlignment = Enum.TextXAlignment.Left
        Label.Parent = Btn

        Btn.MouseEnter:Connect(function()
            TweenService:Create(Str, TweenInfo.new(0.2), {Color = CurrentTheme.Accent}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {ImageColor3 = CurrentTheme.Accent, Size = UDim2.new(0, 26, 0, 26)}):Play()
            TweenService:Create(Label, TweenInfo.new(0.2), {Position = UDim2.new(0, 50, 0, 0)}):Play()
        end)
        
        Btn.MouseLeave:Connect(function()
            TweenService:Create(Str, TweenInfo.new(0.2), {Color = CurrentTheme.Stroke}):Play()
            TweenService:Create(Icon, TweenInfo.new(0.2), {ImageColor3 = CurrentTheme.SubText, Size = UDim2.new(0, 22, 0, 22)}):Play()
            TweenService:Create(Label, TweenInfo.new(0.2), {Position = UDim2.new(0, 45, 0, 0)}):Play()
        end)
        
        Btn.MouseButton1Click:Connect(function()
            if CreateRipple then CreateRipple(Btn) end 
            if setclipboard then setclipboard(url) end
            
            local oldText = Label.Text
            Label.Text = "Copied! ✅"
            Label.TextColor3 = Color3.fromRGB(46, 204, 113)
            
            task.delay(1.5, function()
                Label.Text = oldText
                AddTheme(Label, "TextColor3", "Text") 
            end)
        end)
    end

    function Funcs:CreateSlider(title, min, max, default, callback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount
        F.Size = UDim2.new(1, 0, 0, 60)
        AddTheme(F, "BackgroundColor3", "Section")
        F.Parent = Page
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
        
        local T = Instance.new("TextLabel")
        T.Text = title
        T.Size = UDim2.new(1, -30, 0, 20)
        T.Position = UDim2.new(0, 15, 0, 10)
        T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "Text")
        T.FontFace = MainFont
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = F
        
        local ValText = Instance.new("TextLabel")
        ValText.Text = tostring(default)
        ValText.Size = UDim2.new(0, 50, 0, 20)
        ValText.Position = UDim2.new(1, -65, 0, 10)
        ValText.BackgroundTransparency = 1
        AddTheme(ValText, "TextColor3", "SubText")
        ValText.FontFace = MainFont
        ValText.TextSize = 14
        ValText.Parent = F

        local SliderBG = Instance.new("Frame")
        SliderBG.Size = UDim2.new(1, -30, 0, 6)
        SliderBG.Position = UDim2.new(0, 15, 0, 40)
        AddTheme(SliderBG, "BackgroundColor3", "Sidebar")
        SliderBG.Parent = F
        Instance.new("UICorner", SliderBG).CornerRadius = UDim.new(1, 0)
        
        local SliderFill = Instance.new("Frame")
        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        AddTheme(SliderFill, "BackgroundColor3", "Accent")
        SliderFill.Parent = SliderBG
        Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(1, 0)
        
        local Trigger = Instance.new("TextButton")
        Trigger.Size = UDim2.new(1, 0, 1, 0)
        Trigger.BackgroundTransparency = 1
        Trigger.Text = ""
        Trigger.Parent = SliderBG
        
        local dragging = false
        
        local function Update(input)
            local pos = UDim2.new(math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1), 0, 1, 0)
            SliderFill.Size = pos
            
            local val = math.floor(min + ((max - min) * pos.X.Scale))
            ValText.Text = tostring(val)
            pcall(callback, val)
        end
        
        Trigger.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                Update(input)
            end
        end)
        
        table.insert(getgenv().DS_Connections, UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))

        table.insert(getgenv().DS_Connections, UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                Update(input)
            end
        end))
    end

    function Funcs:CreateInput(title, placeholder, arg3, arg4)
        local defaultText = type(arg3) == "string" and arg3 or ""
        local callback = type(arg3) == "function" and arg3 or arg4
        
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount
        F.Size = UDim2.new(1, 0, 0, 60)
        AddTheme(F, "BackgroundColor3", "Section")
        F.Parent = Page
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
        
        local T = Instance.new("TextLabel")
        T.Text = title
        T.Size = UDim2.new(0.4, 0, 1, 0)
        T.Position = UDim2.new(0, 15, 0, 0)
        T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "Text")
        T.FontFace = MainFont
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = F
        
        local BoxBG = Instance.new("Frame")
        BoxBG.Size = UDim2.new(0.5, 0, 0, 34)
        BoxBG.AnchorPoint = Vector2.new(1, 0.5)
        BoxBG.Position = UDim2.new(1, -15, 0.5, 0)
        AddTheme(BoxBG, "BackgroundColor3", "Sidebar")
        BoxBG.Parent = F
        Instance.new("UICorner", BoxBG).CornerRadius = UDim.new(0, 8)
        
        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, -20, 1, 0)
        Box.Position = UDim2.new(0, 10, 0, 0)
        Box.BackgroundTransparency = 1
        Box.PlaceholderText = placeholder
        Box.Text = defaultText
        AddTheme(Box, "TextColor3", "Text")
        AddTheme(Box, "PlaceholderColor3", "SubText")
        Box.FontFace = MainFont
        Box.TextSize = 13
        Box.Parent = BoxBG
        
        Box.FocusLost:Connect(function(enter)
            if enter then pcall(callback, Box.Text) end
        end)
    end

    -- 7. COLOR PICKER (Новая функция)
    function Funcs:CreateColorPicker(title, default, callback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount
        F.Size = UDim2.new(1, 0, 0, 70)
        AddTheme(F, "BackgroundColor3", "Section")
        F.Parent = Page
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
        
        local T = Instance.new("TextLabel")
        T.Text = title
        T.Size = UDim2.new(1, -70, 0, 20)
        T.Position = UDim2.new(0, 15, 0, 10)
        T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "Text")
        T.FontFace = MainFont
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = F

        local ColorPreview = Instance.new("Frame")
        ColorPreview.Size = UDim2.new(0, 40, 0, 20)
        ColorPreview.Position = UDim2.new(1, -55, 0, 10)
        ColorPreview.BackgroundColor3 = default or Color3.new(1, 1, 1)
        ColorPreview.Parent = F
        Instance.new("UICorner", ColorPreview).CornerRadius = UDim.new(0, 6)

        local Bar = Instance.new("ImageButton")
        Bar.Size = UDim2.new(1, -30, 0, 15)
        Bar.Position = UDim2.new(0, 15, 0, 40)
        Bar.BackgroundColor3 = Color3.new(1,1,1)
        Bar.AutoButtonColor = false
        Bar.Parent = F
        Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 4)
        
        local Grad = Instance.new("UIGradient")
        Grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0))
        }
        Grad.Parent = Bar

        local Selector = Instance.new("Frame")
        Selector.Size = UDim2.new(0, 4, 1, 4)
        Selector.Position = UDim2.new(0, 0, 0.5, 0)
        Selector.AnchorPoint = Vector2.new(0.5, 0.5)
        Selector.BackgroundColor3 = Color3.new(1,1,1)
        Selector.BorderColor3 = Color3.new(0,0,0)
        Selector.BorderSizePixel = 1
        Selector.Parent = Bar

        local dragging = false
        
        local function UpdateColor(input)
            local r = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
            Selector.Position = UDim2.new(r, 0, 0.5, 0)
            local col = Color3.fromHSV(r, 1, 1)
            ColorPreview.BackgroundColor3 = col
            pcall(callback, col)
        end

        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                UpdateColor(input)
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then 
                dragging = false 
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                UpdateColor(input)
            end
        end)
    end

    -- 8. KEYBIND (Кнопка бинда)
    function Funcs:CreateKeybind(title, default, callback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount
        F.Size = UDim2.new(1, 0, 0, 60)
        AddTheme(F, "BackgroundColor3", "Section")
        F.Parent = Page
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 10)
        
        local T = Instance.new("TextLabel")
        T.Text = title
        T.Size = UDim2.new(1, -100, 0, 20)
        T.Position = UDim2.new(0, 15, 0.5, -10)
        T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "Text")
        T.FontFace = MainFont
        T.TextSize = 14
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = F

        local BindBtn = Instance.new("TextButton")
        BindBtn.Size = UDim2.new(0, 80, 0, 34)
        BindBtn.AnchorPoint = Vector2.new(1, 0.5)
        BindBtn.Position = UDim2.new(1, -15, 0.5, 0)
        AddTheme(BindBtn, "BackgroundColor3", "Sidebar")
        AddTheme(BindBtn, "TextColor3", "SubText")
        BindBtn.FontFace = MainFont
        BindBtn.TextSize = 13
        BindBtn.AutoButtonColor = false
        BindBtn.Text = default and default.Name or "None"
        BindBtn.Parent = F
        Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 8)
        
        local Stroke = Instance.new("UIStroke")
        AddTheme(Stroke, "Color", "Stroke")
        Stroke.Thickness = 1
        Stroke.Parent = BindBtn

        local currentKey = default
        local listening = false
        local connection

        BindBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            BindBtn.Text = "..."
            TweenService:Create(BindBtn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.Accent}):Play()
            
            connection = UserInputService.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    if input.KeyCode == Enum.KeyCode.Escape then
                        currentKey = nil
                        BindBtn.Text = "None"
                    else
                        currentKey = input.KeyCode
                        BindBtn.Text = input.KeyCode.Name
                    end
                    
                    listening = false
                    TweenService:Create(BindBtn, TweenInfo.new(0.2), {TextColor3 = CurrentTheme.SubText}):Play()
                    pcall(callback, currentKey)
                    
                    if connection then connection:Disconnect() end
                elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                end
            end)
        end)
    end
    
    -- 9. SHOP GRID (Flat UI Edition)
    function Funcs:CreateShopGrid(items, callback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local Container = Instance.new("Frame")
        Container.LayoutOrder = ElementCount
        Container.Size = UDim2.new(1, 0, 0, 0)
        Container.AutomaticSize = Enum.AutomaticSize.Y
        Container.BackgroundTransparency = 1
        Container.Parent = Page
        
        local Grid = Instance.new("UIGridLayout")
        Grid.CellSize = UDim2.new(0.48, 0, 0, 130) 
        Grid.CellPadding = UDim2.new(0.04, 0, 0, 18)
        Grid.SortOrder = Enum.SortOrder.LayoutOrder
        Grid.Parent = Container

        for _, item in ipairs(items) do
            local Tile = Instance.new("TextButton")
            Tile.Text = ""
            Tile.AutoButtonColor = false
            AddTheme(Tile, "BackgroundColor3", "Section")
            Tile.Parent = Container
            Tile.ClipsDescendants = false 
            Instance.new("UICorner", Tile).CornerRadius = UDim.new(0, 14)

            local RippleContainer = Instance.new("Frame")
            RippleContainer.Name = "RippleContainer"
            RippleContainer.Size = UDim2.new(1, 0, 1, 0)
            RippleContainer.BackgroundTransparency = 1
            RippleContainer.ClipsDescendants = true
            RippleContainer.ZIndex = 10
            RippleContainer.Parent = Tile
            Instance.new("UICorner", RippleContainer).CornerRadius = UDim.new(0, 14)
            
            local AccentLine = Instance.new("Frame")
            AccentLine.Name = "NeonLine"
            AccentLine.Size = UDim2.new(0.6, 0, 0, 3)
            AccentLine.Position = UDim2.new(0.5, 0, 0, -8)
            AccentLine.AnchorPoint = Vector2.new(0.5, 1)
            AccentLine.BorderSizePixel = 0
            AccentLine.ZIndex = 5
            AddTheme(AccentLine, "BackgroundColor3", "Accent")
            AccentLine.Parent = Tile
            Instance.new("UICorner", AccentLine).CornerRadius = UDim.new(1, 0)

            local Icon = Instance.new("ImageLabel")
            Icon.Size = UDim2.new(0, 70, 0, 70)
            Icon.Position = UDim2.new(0.5, 0, 0, 15)
            Icon.AnchorPoint = Vector2.new(0.5, 0)
            Icon.BackgroundTransparency = 1
            Icon.ZIndex = 1
            Icon.ScaleType = Enum.ScaleType.Fit
            Icon.Image = item.Image or "rbxassetid://0"
            Icon.ImageColor3 = Color3.fromRGB(220, 220, 220)
            Icon.Parent = Tile

            local GradFrame = Instance.new("Frame")
            GradFrame.Size = UDim2.new(1, 0, 0.7, 0)
            GradFrame.Position = UDim2.new(0, 0, 1, 0)
            GradFrame.AnchorPoint = Vector2.new(0, 1)
            GradFrame.BackgroundTransparency = 1
            GradFrame.ZIndex = 2
            GradFrame.Parent = Tile
            
            local Grad = Instance.new("UIGradient")
            Grad.Rotation = 90
            Grad.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 1),
                NumberSequenceKeypoint.new(1, 0.1)
            })
            Grad.Color = ColorSequence.new(Color3.new(0,0,0))
            Grad.Parent = GradFrame

            local NameLbl = Instance.new("TextLabel")
            NameLbl.Text = item.Name:upper()
            NameLbl.Size = UDim2.new(1, -10, 0, 20)
            NameLbl.Position = UDim2.new(0.5, 0, 1, -5) 
            NameLbl.AnchorPoint = Vector2.new(0.5, 1)
            NameLbl.BackgroundTransparency = 1
            NameLbl.TextColor3 = Color3.new(1, 1, 1)
            NameLbl.Font = Enum.Font.GothamBold
            NameLbl.TextSize = 13 
            NameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            NameLbl.ZIndex = 3
            NameLbl.Parent = Tile
            
            local NameStroke = Instance.new("UIStroke")
            NameStroke.Thickness = 1.5
            NameStroke.Transparency = 0.4
            NameStroke.Parent = NameLbl

            local PriceLbl = Instance.new("TextLabel")
            PriceLbl.Text = item.Price
            PriceLbl.Size = UDim2.new(1, -10, 0, 15)
            PriceLbl.Position = UDim2.new(0.5, 0, 1, -22)
            PriceLbl.AnchorPoint = Vector2.new(0.5, 1)
            PriceLbl.BackgroundTransparency = 1
            
            if item.Price == "FREE" then
                PriceLbl.TextColor3 = Color3.fromRGB(46, 204, 113)
            else
                AddTheme(PriceLbl, "TextColor3", "Accent")
            end
            PriceLbl.Font = Enum.Font.GothamBlack
            PriceLbl.TextSize = 12
            PriceLbl.ZIndex = 3
            PriceLbl.Parent = Tile

            local PriceStroke = Instance.new("UIStroke")
            PriceStroke.Thickness = 1
            PriceStroke.Transparency = 0.5
            PriceStroke.Parent = PriceLbl

            if item.Value and item.Value.vip_only then
                local VipLbl = Instance.new("TextLabel")
                VipLbl.Text = "(Only for VIP)"
                VipLbl.Size = UDim2.new(1, -10, 0, 12)
                VipLbl.Position = UDim2.new(0.5, 0, 1, -38)
                VipLbl.AnchorPoint = Vector2.new(0.5, 1)
                VipLbl.BackgroundTransparency = 1
                VipLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
                VipLbl.Font = Enum.Font.GothamBold
                VipLbl.TextSize = 10
                VipLbl.ZIndex = 3
                VipLbl.Parent = Tile
                
                local VipStroke = Instance.new("UIStroke")
                VipStroke.Thickness = 1
                VipStroke.Transparency = 0.5
                VipStroke.Parent = VipLbl
            end

            local Scale = Instance.new("UIScale", Tile)
            
            Tile.MouseEnter:Connect(function()
                TweenService:Create(Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.new(1, 1, 1), Size = UDim2.new(0, 80, 0, 80)}):Play() 
                TweenService:Create(AccentLine, TweenInfo.new(0.3), {Size = UDim2.new(0.8, 0, 0, 4)}):Play()
            end)
            
            Tile.MouseLeave:Connect(function()
                TweenService:Create(Icon, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {ImageColor3 = Color3.fromRGB(220, 220, 220), Size = UDim2.new(0, 70, 0, 70)}):Play()
                TweenService:Create(AccentLine, TweenInfo.new(0.3), {Size = UDim2.new(0.6, 0, 0, 3)}):Play()
            end)

            Tile.MouseButton1Down:Connect(function() 
                TweenService:Create(Scale, TweenInfo.new(0.1), {Scale = 0.95}):Play() 
            end)
            
            Tile.MouseButton1Click:Connect(function()
                TweenService:Create(Scale, TweenInfo.new(0.15, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out), {Scale = 1}):Play()
                if CreateRipple then CreateRipple(RippleContainer) end
                pcall(callback, item.Value or item.Name) 
            end)
        end
    end

    -- 10. COUNT INPUT (Ввод количества с галочкой)
    function Funcs:CreateCountInput(default, callback)
        CurrentGrid = nil
        ElementCount = ElementCount + 1
        
        local F = Instance.new("Frame")
        F.LayoutOrder = ElementCount
        F.Size = UDim2.new(1, 0, 0, 50)
        AddTheme(F, "BackgroundColor3", "Section")
        F.Parent = Page
        Instance.new("UICorner", F).CornerRadius = UDim.new(0, 8)
        
        local T = Instance.new("TextLabel")
        T.Text = "Count / Amount:"
        T.Size = UDim2.new(0, 100, 1, 0)
        T.Position = UDim2.new(0, 15, 0, 0)
        T.BackgroundTransparency = 1
        AddTheme(T, "TextColor3", "SubText")
        T.FontFace = MainFont
        T.TextSize = 13
        T.TextXAlignment = Enum.TextXAlignment.Left
        T.Parent = F

        local InputBG = Instance.new("Frame")
        InputBG.Size = UDim2.new(0, 80, 0, 30)
        InputBG.AnchorPoint = Vector2.new(0, 0.5)
        InputBG.Position = UDim2.new(0, 130, 0.5, 0)
        AddTheme(InputBG, "BackgroundColor3", "Sidebar")
        InputBG.Parent = F
        Instance.new("UICorner", InputBG).CornerRadius = UDim.new(0, 6)

        local Box = Instance.new("TextBox")
        Box.Size = UDim2.new(1, 0, 1, 0)
        Box.BackgroundTransparency = 1
        Box.Text = tostring(default)
        AddTheme(Box, "TextColor3", "Text")
        Box.FontFace = MainFont
        Box.TextSize = 14
        Box.Parent = InputBG

        local ConfirmBtn = Instance.new("TextButton")
        ConfirmBtn.Size = UDim2.new(0, 30, 0, 30)
        ConfirmBtn.AnchorPoint = Vector2.new(0, 0.5)
        ConfirmBtn.Position = UDim2.new(0, 220, 0.5, 0)
        ConfirmBtn.BackgroundColor3 = Color3.fromRGB(46, 204, 113)
        ConfirmBtn.Text = "✓"
        ConfirmBtn.TextColor3 = Color3.new(1,1,1)
        ConfirmBtn.Font = Enum.Font.GothamBold
        ConfirmBtn.TextSize = 18
        ConfirmBtn.Parent = F
        Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 6)

        local function UpdateVal()
            local num = tonumber(Box.Text)
            if num then
                pcall(callback, num)

                if Library.Notify then
                    Library:Notify("Settings Updated", "Buy count set to: " .. num, 2)
                end

                local oldCol = ConfirmBtn.BackgroundColor3
                ConfirmBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ConfirmBtn.TextColor3 = Color3.fromRGB(46, 204, 113)
                task.wait(0.1)
                ConfirmBtn.BackgroundColor3 = oldCol
                ConfirmBtn.TextColor3 = Color3.new(1,1,1)
            else
                Box.Text = "1"
            end
        end

        ConfirmBtn.MouseButton1Click:Connect(UpdateVal)
        Box.FocusLost:Connect(UpdateVal)
    end

    return Funcs
end

return Library


