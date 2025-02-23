local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local ESP = false

-- Erstellt ein BillboardGui, das über dem Kopf des Spielers angezeigt wird
-- und durch Wände sichtbar bleibt.
local function createStatsGui(player)
    if not player.Character or not player.Character:FindFirstChild("Head") then
        return
    end
    
    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "StatsGui"
    billboardGui.Adornee = player.Character.Head
    billboardGui.Size = UDim2.new(0, 100, 0, 50)
    billboardGui.StudsOffset = Vector3.new(0, 4, 0)
    billboardGui.AlwaysOnTop = true -- Macht die Anzeige immer sichtbar
    billboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboardGui.Parent = player.Character

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextScaled = true
    textLabel.TextStrokeTransparency = 0.8
    textLabel.Parent = billboardGui

    -- Aktualisiert in jedem Frame die Health und die Distanz
    local updateConnection
    updateConnection = RunService.RenderStepped:Connect(function()
        if not player.Character then return end
        local humanoid = player.Character:FindFirstChild("Humanoid")
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local localHRP = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if humanoid and hrp and localHRP then
            local health = humanoid.Health
            local distance = math.floor((localHRP.Position - hrp.Position).Magnitude)
            textLabel.Text = "Health: " .. tostring(health) .. " | Dist: " .. tostring(distance)
        end
    end)
    
    return textLabel
end

-- Aktiviert oder deaktiviert das ESP (Highlight & StatsGui) für einen Spieler
local function EspActivate(player)
    if player.Character then
        local existingEsp = player.Character:FindFirstChild("Highlight")
        local existingStatsGui = player.Character:FindFirstChild("StatsGui")
        
        if not ESP then
            if existingEsp then existingEsp:Destroy() end
            if existingStatsGui then existingStatsGui:Destroy() end
            return
        end

        if existingEsp then existingEsp:Destroy() end
        if existingStatsGui then existingStatsGui:Destroy() end
        
        local highlight = Instance.new("Highlight")
        highlight.Parent = player.Character
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.FillTransparency = 0.2 -- Noch besser sichtbar durch Wände
        highlight.OutlineTransparency = 0
        
        if player.Team and Players.LocalPlayer.Team then
            if player.Team == Players.LocalPlayer.Team then
                highlight.FillColor = Color3.new(0, 1, 0) -- Grün für Teamkameraden
            else
                highlight.FillColor = Color3.new(1, 0, 0) -- Rot für Gegner
            end
        else
            highlight.FillColor = Color3.new(1, 1, 0) -- Gelb für teamlose Spieler
        end
        
        highlight.OutlineColor = Color3.new(1, 1, 1)

        createStatsGui(player)
    end
end

-- Umschalten des ESPs
local function toggleEsp()
    ESP = not ESP
    for _, player in pairs(Players:GetPlayers()) do
        EspActivate(player)
    end
end

-- Initial für alle bereits vorhandenen Spieler
for _, player in pairs(Players:GetPlayers()) do
    EspActivate(player)
    player.CharacterAdded:Connect(function() 
        wait(0.1) -- Kleiner Delay, damit der Character vollständig geladen ist
        EspActivate(player)
    end)
    player:GetPropertyChangedSignal("Team"):Connect(function() 
        EspActivate(player)
    end)
end

-- Für neu beitretende Spieler
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function() 
        wait(0.1)
        EspActivate(player)
    end)
    player:GetPropertyChangedSignal("Team"):Connect(function() 
        EspActivate(player)
    end)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.E then
        toggleEsp()
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "Flame",
    Text = "ESP Loaded! Drücke 'E', um ESP umzuschalten.",
    Duration = 2
})
