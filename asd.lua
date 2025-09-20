
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local ESPEnabled = false
local ESPNameEnabled = true 
local connections = {}

local function addESP(character)
	if not character then return end
	if not character:FindFirstChildOfClass("Humanoid") then return end 

	if not character:FindFirstChild("ESPHighlight") then
		local highlight = Instance.new("Highlight")
		highlight.Name = "ESPHighlight"
		highlight.FillColor = Color3.fromRGB(0, 255, 0)
		highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
		highlight.FillTransparency = 0.5
		highlight.OutlineTransparency = 0
		highlight.Parent = character
	end

	if not character:FindFirstChild("ESPBillboard") then
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "ESPBillboard"
		billboard.AlwaysOnTop = true
		billboard.Size = UDim2.new(0, 200, 0, 50)
		billboard.StudsOffset = Vector3.new(0, 3, 0)
		billboard.Enabled = ESPNameEnabled
		billboard.Parent = character:FindFirstChild("Head") or character:FindFirstChildWhichIsA("BasePart")

		local textLabel = Instance.new("TextLabel")
		textLabel.Size = UDim2.new(1, 0, 1, 0)
		textLabel.BackgroundTransparency = 1
		textLabel.TextStrokeTransparency = 0.5
		textLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
		textLabel.Font = Enum.Font.SourceSansBold
		textLabel.TextScaled = false
		textLabel.TextSize = 20
		textLabel.Name = "ESPText"
		textLabel.Parent = billboard

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local function updateText()
			local name = character.Name
			local health = math.floor(humanoid.Health)
			textLabel.Text = name .. " | " .. health
		end

		updateText()

		table.insert(connections, humanoid.HealthChanged:Connect(updateText))
	end
end

local function removeAllESP()
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") then
			if obj:FindFirstChild("ESPHighlight") then
				obj.ESPHighlight:Destroy()
			end
			if obj:FindFirstChild("ESPBillboard") then
				obj.ESPBillboard:Destroy()
			end
		end
	end
end

function ESPOn()
	if ESPEnabled then return end
	ESPEnabled = true


	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			addESP(player.Character)
			table.insert(connections, player.CharacterAdded:Connect(addESP))
		end
	end

	table.insert(connections, Players.PlayerAdded:Connect(function(player)
		if player ~= LocalPlayer then
			table.insert(connections, player.CharacterAdded:Connect(addESP))
		end
	end))


	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
			addESP(obj)
		end
	end

	table.insert(connections, Workspace.DescendantAdded:Connect(function(obj)
		if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
			addESP(obj)
		end
	end))
end


function ESPOff()
	if not ESPEnabled then return end
	ESPEnabled = false

	removeAllESP()

	for _, conn in ipairs(connections) do
		if conn.Connected then
			conn:Disconnect()
		end
	end
	connections = {}
end


function ESPNameOn()
	ESPNameEnabled = true
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BillboardGui") and obj.Name == "ESPBillboard" then
			obj.Enabled = true
		end
	end
end


function ESPNameOff()
	ESPNameEnabled = false
	for _, obj in ipairs(Workspace:GetDescendants()) do
		if obj:IsA("BillboardGui") and obj.Name == "ESPBillboard" then
			obj.Enabled = false
		end
	end
end


local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 190)
frame.Position = UDim2.new(0.5, -125, 0.5, -95)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.Active = true
frame.Draggable = true 
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
title.Text = "ESP By Haviksai"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame
local function createSwitch(name, posY, onCode, offCode)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.8, 0, 0, 30)
	button.Position = UDim2.new(0.1, 0, 0, posY)
	button.Text = name .. " [OFF]"
	button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	button.TextColor3 = Color3.new(1, 1, 1)
	button.Font = Enum.Font.SourceSans
	button.TextSize = 18
	button.Parent = frame

	local state = false
	button.MouseButton1Click:Connect(function()
		state = not state
		if state then
			button.Text = name .. " [ON]"
			button.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
			onCode()
		else
			button.Text = name .. " [OFF]"
			button.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
			offCode()
		end
	end)
end

createSwitch("ESP", 40, ESPOn, ESPOff)
createSwitch("ESP Name/HP", 80, ESPNameOn, ESPNameOff)



