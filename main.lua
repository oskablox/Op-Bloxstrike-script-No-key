main.lua--[[ 
    Oskachaets V22 | Safety First
    Fixes: Anti-Cheat Kicks, Bypassed Head Expander, Screen-Sync Finalized
]]

task.wait(1)

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Oskachaets V22 | LEGIT",
   LoadingTitle = "Patching Security Flaws...",
   LoadingSubtitle = "Bypass Protocols Active",
   ConfigurationSaving = { Enabled = false }
})

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Settings = {
    Aimbot = false,
    AimbotKey = Enum.UserInputType.MouseButton2,
    AimbotMode = "Hold",
    AimbotLocked = false,
    SilentAim = false,
    SilentTarget = "Head",
    Smoothing = 5,
    FOV = 100,
    EnemyESP = false,
    -- LEGIT HITBOX SETTINGS
    HitboxEnabled = false,
    HitboxSize = 2.5, 
}

-- FOV Circle
local Circle = Drawing.new("Circle")
Circle.Color = Color3.fromRGB(255, 255, 255)
Circle.Thickness = 1
Circle.Transparency = 0.5
Circle.Visible = true

-- TARGET & TEAM LOGIC
local function IsEnemy(Player)
    if not Player.Team or not LocalPlayer.Team then return true end
    return Player.Team ~= LocalPlayer.Team
end

local function GetTarget()
    local Closest = nil
    local MaxDist = Settings.FOV
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, Player in pairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and IsEnemy(Player) then
            local Head = Player.Character:FindFirstChild(Settings.SilentTarget) or Player.Character:FindFirstChild("Head")
            local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
            
            if Head and Hum and Hum.Health > 0 then
                local ScreenPos, OnScreen = Camera:WorldToViewportPoint(Head.Position)
                if OnScreen then
                    local Dist = (Vector2.new(ScreenPos.X, ScreenPos.Y) - ScreenCenter).Magnitude
                    if Dist < MaxDist then
                        Closest = Head
                        MaxDist = Dist
                    end
                end
            end
        end
    end
    return Closest
end

-- UI TABS
local Main = Window:CreateTab("Main & Legit", 4483362458)

Main:CreateSection("Safe Head Expander")
Main:CreateToggle({
    Name = "Legit Expander (Bypassed)", 
    CurrentValue = false, 
    Callback = function(v) Settings.HitboxEnabled = v end
})
Main:CreateSlider({
    Name = "Safe Size", 
    Range = {1, 4}, -- Strictly limited to prevent kicks
    Increment = 0.1, 
    CurrentValue = 2.5, 
    Callback = function(v) Settings.HitboxSize = v end
})

Main:CreateSection("Aimbot & Targeting")
Main:CreateToggle({Name = "Aimbot Switch", CurrentValue = false, Callback = function(v) Settings.Aimbot = v end})
Main:CreateDropdown({Name = "Mode", Options = {"Hold", "Toggle"}, CurrentOption = "Hold", Callback = function(v) Settings.AimbotMode = v end})
Main:CreateKeybind({Name = "Aimbot Key", CurrentKeybind = "MouseButton2", Callback = function(v) Settings.AimbotKey = v end})

Main:CreateSection("Silent Aim")
Main:CreateToggle({Name = "Silent Aim (Bullet TP)", CurrentValue = false, Callback = function(v) Settings.SilentAim = v end})
Main:CreateDropdown({Name = "Preferred Bone", Options = {"Head", "HumanoidRootPart"}, CurrentOption = "Head", Callback = function(v) Settings.SilentTarget = v end})

Main:CreateSection("Visuals (Private)")
Main:CreateToggle({Name = "Enemy ESP", CurrentValue = false, Callback = function(v) Settings.EnemyESP = v end})
Main:CreateSlider({Name = "FOV Circle", Range = {30, 800}, Increment = 5, CurrentValue = 100, Callback = function(v) Settings.FOV = v end})

-- SAFE HITBOX LOOP (BYPASS VERSION)
task.spawn(function()
    while task.wait(1) do -- Slower update to avoid property-change flags
        if Settings.HitboxEnabled then
            for _, Player in pairs(Players:GetPlayers()) do
                if Player ~= LocalPlayer and Player.Character and IsEnemy(Player) then
                    local Head = Player.Character:FindFirstChild("Head")
                    if Head then
                        -- Safe sizing (Keeps it realistic enough for anti-cheat)
                        Head.Size = Vector3.new(Settings.HitboxSize, Settings.HitboxSize, Settings.HitboxSize)
                        Head.CanCollide = true -- MUST STAY TRUE TO AVOID KICK
                        Head.Transparency = 0.3 -- Subtle enough to see
                    end
                end
            end
        else
            -- Reset heads if disabled
            for _, Player in pairs(Players:GetPlayers()) do
                if Player.Character and Player.Character:FindFirstChild("Head") then
                    Player.Character.Head.Size = Vector3.new(1.1, 1.1, 1.1)
                    Player.Character.Head.Transparency = 0
                end
            end
        end
    end
end)

-- INPUT & RENDER SYNC
UserInputService.InputBegan:Connect(function(Input, Proc)
    if Proc then return end
    if (Input.UserInputType == Settings.AimbotKey or Input.KeyCode == Settings.AimbotKey) and Settings.AimbotMode == "Toggle" then
        Settings.AimbotLocked = not Settings.AimbotLocked
    end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local Method = getnamecallmethod()
    local Args = {...}
    if not checkcaller() and Settings.SilentAim and (Method == "Raycast" or Method == "FindPartOnRayWithIgnoreList") then
        local Target = GetTarget()
        if Target then
            if Method == "Raycast" then Args[2] = (Target.Position - Args[1]).Unit * 1000
            else Args[1] = Ray.new(Args[1].Origin, (Target.Position - Args[1].Origin).Unit * 1000) end
            return oldNamecall(self, unpack(Args))
        end
    end
    return oldNamecall(self, ...)
end)

-- ESP STABILITY
local ESP_Table = {}
local function CreateESP(Player)
    local Box = Drawing.new("Square")
    Box.Thickness = 1
    Box.Color = Color3.fromRGB(255, 0, 0)
    local Name = Drawing.new("Text")
    Name.Size = 13
    Name.Center = true
    Name.Outline = true
    ESP_Table[Player] = {Box = Box, Name = Name}
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then CreateESP(p) end end
Players.PlayerAdded:Connect(CreateESP)

RunService.RenderStepped:Connect(function()
    local ScreenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    Circle.Position = ScreenCenter
    Circle.Radius = Settings.FOV
    Circle.Visible = Settings.Aimbot

    local ShouldAim = false
    if Settings.Aimbot then
        if Settings.AimbotMode == "Hold" then
            ShouldAim = (tostring(Settings.AimbotKey):find("MouseButton") and UserInputService:IsMouseButtonPressed(Settings.AimbotKey)) or UserInputService:IsKeyDown(Settings.AimbotKey)
        else ShouldAim = Settings.AimbotLocked end
    end

    if ShouldAim then
        local Target = GetTarget()
        if Target then
            local Pos, OnScreen = Camera:WorldToViewportPoint(Target.Position)
            if OnScreen then
                mousemoverel((Pos.X - ScreenCenter.X)/Settings.Smoothing, (Pos.Y - ScreenCenter.Y)/Settings.Smoothing)
            end
        end
    end

    for Player, Visuals in pairs(ESP_Table) do
        local Char = Player.Character
        if Settings.EnemyESP and Char and Char:FindFirstChild("HumanoidRootPart") and IsEnemy(Player) then
            local Root = Char.HumanoidRootPart
            local Pos, OnScreen = Camera:WorldToViewportPoint(Root.Position)
            if OnScreen then
                local Top = Camera:WorldToViewportPoint(Root.Position + Vector3.new(0, 3.2, 0))
                local Bottom = Camera:WorldToViewportPoint(Root.Position - Vector3.new(0, 3.8, 0))
                local Height = math.abs(Top.Y - Bottom.Y)
                local Width = Height / 1.6
                Visuals.Box.Visible, Visuals.Name.Visible = true, true
                Visuals.Box.Size = Vector2.new(Width, Height)
                Visuals.Box.Position = Vector2.new(Pos.X - Width/2, Pos.Y - Height/2)
                Visuals.Name.Text = Player.Name
                Visuals.Name.Position = Vector2.new(Pos.X, Pos.Y - (Height/2) - 15)
            else Visuals.Box.Visible, Visuals.Name.Visible = false, false end
        else Visuals.Box.Visible, Visuals.Name.Visible = false, false end
    end
end)

Rayfield:Notify({Title = "Oskachaets V22 Legit", Content = "Safety Caps Applied. Max Head Size: 4.", Duration = 5})
