--// Angell Bypass - Interface
--// Coloque como LocalScript em StarterPlayerScripts

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local playerGui = player:WaitForChild("PlayerGui")

local function buildPanel(userName, keyExpiry)
local oldGui = playerGui:FindFirstChild("AngellBypass")
if oldGui then
	oldGui:Destroy()
end

--// Estado do ESP
local espEnabled = false
local namesEnabled = false
local distanceEnabled = false
local espMaxDistance = 250
local healthEnabled = false
local healthTextEnabled = false
local linesEnabled = false
local lineOrigin = "Top"
local npcESPEnabled = false
local skeletonEnabled = false
local cornerBoxEnabled = false
local boxColor = Color3.fromRGB(255, 255, 255)
local healthColor = Color3.fromRGB(80, 255, 120)
local lineColor = Color3.fromRGB(255, 255, 255)
local skeletonColor = Color3.fromRGB(255, 255, 255)
local textColor = Color3.fromRGB(255, 255, 255)
local visibleCheckEnabled = false
local visibleESPColor = Color3.fromRGB(80, 255, 120)
local hiddenESPColor = Color3.fromRGB(255, 80, 80)
local espLineThickness = 1
local espHealthThickness = 3
local espSkeletonThickness = 2
local healthPosition = "Side"
local healthOffset = Vector2.new(0, 0)
local refreshPreview = function() end
local spinbotEnabled = false
local spinKeyCode = Enum.KeyCode.G
local capturingSpinKeybind = false
local spinKeybindButton = nil
local spinToggleButton = nil
local togglePanel = function() end
local menuKeyCode = Enum.KeyCode.Insert
local capturingMenuKeybind = false
local menuKeybindButton = nil
local spinbotSpeed = 180
local cameraFOV = 70
local cameraFOVEnabled = false
local screenStretchEnabled = false
local screenStretchFOV = 100
local defaultCameraFOV = 70
local speedEnabled = false
local fpsCounterEnabled = false
local fpsFrameCount = 0
local fpsElapsed = 0
local walkSpeedValue = 16
local originalWalkSpeed = nil
local speedPropertyConnection = nil
local flyEnabled = false
local flySpeed = 80
local flyKeys = {}
local flyVelocity = nil
local flyGyro = nil
local dashEnabled = false
local dashSpeed = 90
local dashKeyCode = Enum.KeyCode.Q
local capturingDashKeybind = false
local dashKeybindButton = nil
local dashToggleButton = nil
local dashToggleStroke = nil
local lastDashTime = 0
local vividColorsEnabled = false
local vividColorEffect = nil
local watermarkEnabled = false
local streamProofEnabled = false
local colorPalette = {
	Color3.fromRGB(0, 0, 0),
	Color3.fromRGB(255, 255, 255),
	Color3.fromRGB(255, 80, 80),
	Color3.fromRGB(80, 170, 255),
	Color3.fromRGB(80, 255, 140),
	Color3.fromRGB(255, 220, 70),
	Color3.fromRGB(190, 100, 255),
}

local function applyWalkSpeed()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		if speedPropertyConnection then
			speedPropertyConnection:Disconnect()
			speedPropertyConnection = nil
		end
		if speedEnabled then
			if originalWalkSpeed == nil then originalWalkSpeed = humanoid.WalkSpeed end
			local desiredSpeed = math.clamp(walkSpeedValue, 8, 2000)
			humanoid.WalkSpeed = desiredSpeed
			speedPropertyConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
				if speedEnabled and humanoid.Parent and math.abs(humanoid.WalkSpeed - desiredSpeed) > 0.1 then
					humanoid.WalkSpeed = desiredSpeed
				end
			end)
		else
			humanoid.WalkSpeed = originalWalkSpeed or 16
			originalWalkSpeed = nil
		end
	end
end

local function stopFly()
	flyEnabled = false
	if flyVelocity then flyVelocity:Destroy() flyVelocity = nil end
	if flyGyro then flyGyro:Destroy() flyGyro = nil end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if root then root.AssemblyLinearVelocity = Vector3.zero end
end

local function startFly()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	stopFly()
	flyEnabled = true
	flyVelocity = Instance.new("BodyVelocity")
	flyVelocity.MaxForce = Vector3.new(100000, 100000, 100000)
	flyVelocity.P = 10000
	flyVelocity.Velocity = Vector3.zero
	flyVelocity.Parent = root
	flyGyro = Instance.new("BodyGyro")
	flyGyro.MaxTorque = Vector3.new(100000, 100000, 100000)
	flyGyro.P = 10000
	flyGyro.CFrame = root.CFrame
	flyGyro.Parent = root
	return true
end

local function updateFly()
	if not flyEnabled or not flyVelocity or not flyVelocity.Parent then return end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not camera then
		stopFly()
		return
	end
	local direction = Vector3.zero
	if flyKeys[Enum.KeyCode.W] then direction += camera.CFrame.LookVector end
	if flyKeys[Enum.KeyCode.S] then direction -= camera.CFrame.LookVector end
	if flyKeys[Enum.KeyCode.D] then direction += camera.CFrame.RightVector end
	if flyKeys[Enum.KeyCode.A] then direction -= camera.CFrame.RightVector end
	if flyKeys[Enum.KeyCode.Space] then direction += Vector3.yAxis end
	if flyKeys[Enum.KeyCode.LeftControl] then direction -= Vector3.yAxis end
	if direction.Magnitude > 0 then direction = direction.Unit * flySpeed end
	flyVelocity.Velocity = direction
	if flyGyro then flyGyro.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector) end
end

local function performDash()
	if not dashEnabled or os.clock() - lastDashTime < 0.65 then return end
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not humanoid or humanoid.Health <= 0 or not root then return end

	local direction = humanoid.MoveDirection
	direction = Vector3.new(direction.X, 0, direction.Z)
	if direction.Magnitude < 0.05 then
		local currentCamera = workspace.CurrentCamera
		local look = currentCamera and currentCamera.CFrame.LookVector or root.CFrame.LookVector
		direction = Vector3.new(look.X, 0, look.Z)
	end
	if direction.Magnitude < 0.05 then return end

	lastDashTime = os.clock()
	direction = direction.Unit
	local verticalSpeed = root.AssemblyLinearVelocity.Y
	local speed = math.clamp(dashSpeed, 20, 180)
	root.AssemblyLinearVelocity = Vector3.new(direction.X * speed, verticalSpeed, direction.Z * speed)
end

local function setVividColors(enabled)
	if enabled then
		if not vividColorEffect or not vividColorEffect.Parent then
			vividColorEffect = Lighting:FindFirstChild("AngellBypassVividColors")
			if not vividColorEffect then
				vividColorEffect = Instance.new("ColorCorrectionEffect")
				vividColorEffect.Name = "AngellBypassVividColors"
				vividColorEffect.Parent = Lighting
			end
		end
		vividColorEffect.Saturation = 0.45
		vividColorEffect.Contrast = 0.12
		vividColorEffect.Brightness = 0.03
		vividColorEffect.TintColor = Color3.fromRGB(255, 250, 245)
	else
		if vividColorEffect then
			vividColorEffect:Destroy()
			vividColorEffect = nil
		end
		local oldEffect = Lighting:FindFirstChild("AngellBypassVividColors")
		if oldEffect then oldEffect:Destroy() end
	end
end


--// Estado do aimbot
local aimbotEnabled = false
local targetNPCs = true
local showFOV = false
local fovRadius = 100
local smoothing = 5
local aimMode = "Legit"
local aimTargetMode = "Head"
local wallCheck = false
local ignoreDeadTargets = true
local aimInputType = Enum.UserInputType.MouseButton2
local aimKeyCode = Enum.KeyCode.Unknown
local aiming = false
local lockedTarget = nil
local friendPlayers = {}
local capturingKeybind = false
local keybindButton = nil

--// Cores: somente preto, branco e tons de cinza
local BG = Color3.fromRGB(0, 0, 0)
local PANEL = Color3.fromRGB(0, 0, 0)
local PANEL2 = Color3.fromRGB(32, 32, 32)
local ACCENT = Color3.fromRGB(245, 245, 245)
local WHITE = Color3.fromRGB(245, 245, 245)
local BLACK = Color3.fromRGB(8, 8, 8)
local GRAY = Color3.fromRGB(155, 155, 155)

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "AngellBypass"
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = playerGui

local fpsCounterLabel = Instance.new("TextLabel")
fpsCounterLabel.Name = "FPSCounter"
fpsCounterLabel.Size = UDim2.fromOffset(92, 26)
fpsCounterLabel.Position = UDim2.fromOffset(10, 10)
fpsCounterLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fpsCounterLabel.BackgroundTransparency = 0.25
fpsCounterLabel.BorderSizePixel = 0
fpsCounterLabel.Text = "FPS: --"
fpsCounterLabel.TextColor3 = WHITE
fpsCounterLabel.TextSize = 13
fpsCounterLabel.Font = Enum.Font.GothamBold
fpsCounterLabel.Visible = false
fpsCounterLabel.ZIndex = 100
fpsCounterLabel.Parent = gui
local fpsCounterCorner = Instance.new("UICorner")
fpsCounterCorner.CornerRadius = UDim.new(0, 5)
fpsCounterCorner.Parent = fpsCounterLabel
fpsCounterLabel.Active = true
local fpsDragging = false
local fpsDragStart
local fpsStartPosition
fpsCounterLabel.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		fpsDragging = true
		fpsDragStart = input.Position
		fpsStartPosition = fpsCounterLabel.Position
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		fpsDragging = false
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if fpsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		local delta = input.Position - fpsDragStart
		fpsCounterLabel.Position = UDim2.fromOffset(
			fpsStartPosition.X.Offset + delta.X,
			fpsStartPosition.Y.Offset + delta.Y
		)
	end
end)

local main
local panelOpen = true
local panelTerminated = false
local particleLayer = nil
local particleRecords = {}
local particleRandom = Random.new()
local originalMouseBehavior = UserInputService.MouseBehavior
local originalMouseIconEnabled = UserInputService.MouseIconEnabled

--// Círculo do FOV na tela
local fovCircle = Instance.new("Frame")
fovCircle.Name = "AimbotFOV"
fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
fovCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
fovCircle.BackgroundTransparency = 1
fovCircle.BorderSizePixel = 0
fovCircle.Active = false
fovCircle.ZIndex = 20
fovCircle.Parent = gui

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1, 0)
fovCorner.Parent = fovCircle

local fovStroke = Instance.new("UIStroke")
fovStroke.Color = WHITE
fovStroke.Thickness = 1
fovStroke.Transparency = 0.15
fovStroke.Parent = fovCircle

--// Aimbot por câmera: seleciona o alvo mais próximo do centro da tela
local candidateCache = {}
local lastCandidateScan = 0
local npcCache = {}
local lastNPCScan = 0
local lastESPRefresh = 0
-- Atualizar a projeção 30 vezes por segundo evita trabalho excessivo por frame.
local espRefreshInterval = 1 / 60
local refreshESP

local function getHumanoid(model)
	if not model then return nil end
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if humanoid then return humanoid end
	local nested = model:FindFirstChild("Humanoid", true)
	return nested and nested:IsA("Humanoid") and nested or nil
end

local function findBodyPart(model, names)
	if not model then return nil end
	for _, name in ipairs(names) do
		local part = model:FindFirstChild(name, true)
		if part and part:IsA("BasePart") then return part end
	end
	return nil
end

local function isHumanoidDead(humanoid)
	return not humanoid
		or humanoid.Health <= 0
		or humanoid:GetState() == Enum.HumanoidStateType.Dead
end

local function getHumanoidForPart(part)
	local model = part and part:FindFirstAncestorOfClass("Model")
	while model do
		local humanoid = getHumanoid(model)
		if humanoid then return model, humanoid end
		local parent = model.Parent
		if parent and parent:IsA("Model") then
			model = parent
		else
			model = parent and parent:FindFirstAncestorOfClass("Model")
		end
	end
	return nil, nil
end

local function getOwningPlayer(model)
	if not model then return nil end
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player and target.Character
			and (model == target.Character or model:IsDescendantOf(target.Character)) then
			return target
		end
	end
	return nil
end

local function isAimModelEnabled(model)
	local owner = getOwningPlayer(model)
	if owner then return not friendPlayers[owner.UserId] end
	return targetNPCs
end

local function isValidCharacter(model)
	if not model or not model:IsA("Model") or model == player.Character then return false end
	local humanoid = getHumanoid(model)
	local head = findBodyPart(model, {"Head", "UpperTorso", "HumanoidRootPart", "Torso"})
	return humanoid ~= nil and humanoid.Health > 0 and head ~= nil
end

local function isAimTargetValid(model)
	if not model or not model:IsA("Model") or model == player.Character then return false end
	local humanoid = getHumanoid(model)
	local head = findBodyPart(model, {"Head", "UpperTorso", "HumanoidRootPart", "Torso"})
	if not humanoid or not head then return false end
	return not ignoreDeadTargets or not isHumanoidDead(humanoid)
end

local function getCandidates()
	local now = os.clock()
	if now - lastCandidateScan < 0.15 then return candidateCache end
	lastCandidateScan = now

	local list = {}
	local known = {}
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			local character = target.Character
			if character then known[character] = true end
			if not friendPlayers[target.UserId] and isAimTargetValid(character) then
				table.insert(list, character)
			end
		end
	end

	-- Varre Humanoids reais; um NPC inválido não pode interromper o aimbot.
	if npcESPEnabled or targetNPCs then
		if lastNPCScan == 0 or now - lastNPCScan >= 1 then
			lastNPCScan = now
			local scanned = {}
			local seenHumanoids = {}
			for _, object in ipairs(workspace:GetDescendants()) do
				if object:IsA("Humanoid") and not seenHumanoids[object] then
					seenHumanoids[object] = true
					local ok, npc = pcall(function()
						local ancestor = object.Parent
						while ancestor and ancestor ~= workspace do
							if ancestor:IsA("Model") and isAimTargetValid(ancestor) then
								return ancestor
							end
							ancestor = ancestor.Parent
						end
						return nil
					end)
					if ok and npc and not known[npc] and not getOwningPlayer(npc) then
						scanned[npc] = true
					end
				end
			end
			npcCache = {}
			for npc in pairs(scanned) do table.insert(npcCache, npc) end
		end
		if targetNPCs then
			for _, npc in ipairs(npcCache) do
				local ok, valid = pcall(isAimTargetValid, npc)
				if ok and valid and not getOwningPlayer(npc) then table.insert(list, npc) end
			end
		end
	end

	candidateCache = list
	return candidateCache
end

local function hasLineOfSight(part)
	if not wallCheck then return true end
	local origin = camera.CFrame.Position
	local direction = part.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}
	params.IgnoreWater = true
	local result = workspace:Raycast(origin, direction, params)
	if not result then return true end
	local targetModel = getHumanoidForPart(part)
	return targetModel ~= nil and result.Instance:IsDescendantOf(targetModel)
end

local function hasVisualLineOfSight(character)
	if not character or not camera then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = {player.Character}
	params.IgnoreWater = true
	params.RespectCanCollide = true
	for _, partName in ipairs({"Head", "UpperTorso", "Torso", "HumanoidRootPart"}) do
		local part = character:FindFirstChild(partName)
		if part and part:IsA("BasePart") then
			local result = workspace:Raycast(camera.CFrame.Position, part.Position - camera.CFrame.Position, params)
			if result == nil or result.Instance:IsDescendantOf(character) then
				return true
			end
		end
	end
	return false
end

local function getAimPart(model)
	local head = findBodyPart(model, {"Head"})
	local chest = findBodyPart(model, {"UpperTorso", "Torso", "HumanoidRootPart"})
	if aimTargetMode == "Chest" then return chest or head end
	if aimTargetMode == "Nearest" then
		local nearestPart
		local nearestDistance = math.huge
		local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		for _, part in ipairs({head, chest}) do
			if part then
				local position, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen and position.Z > 0 then
					local distance = (Vector2.new(position.X, position.Y) - center).Magnitude
					if distance < nearestDistance then nearestDistance, nearestPart = distance, part end
				end
			end
		end
		return nearestPart or head or chest
	end
	return head or chest
end

local function getClosestTarget()
	camera = workspace.CurrentCamera
	if not camera then return nil end
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	local closestPart
	local closestDistance = math.max(fovRadius, 1)

	for _, model in ipairs(getCandidates()) do
		local ok, part, distance = pcall(function()
			if not isAimTargetValid(model) then return nil end
			local candidate = getAimPart(model)
			if not candidate or not candidate:IsDescendantOf(workspace) then return nil end
			local position, onScreen = camera:WorldToViewportPoint(candidate.Position)
			if not onScreen or position.Z <= 0 or not hasLineOfSight(candidate) then return nil end
			local screenDistance = (Vector2.new(position.X, position.Y) - center).Magnitude
			return candidate, screenDistance
		end)
		if ok and part and distance and distance <= closestDistance then
			closestDistance = distance
			closestPart = part
		end
	end
	return closestPart
end

local function updateAim(deltaTime)
	if not aimbotEnabled or not aiming then
		lockedTarget = nil
		return
	end

	camera = workspace.CurrentCamera
	if not camera then return end

	local targetPart = lockedTarget
	if targetPart then
		local targetModel, targetHumanoid
		local validPart = targetPart:IsA("BasePart") and targetPart:IsDescendantOf(workspace)
		if validPart then targetModel, targetHumanoid = getHumanoidForPart(targetPart) end
		local invalid = not validPart or not targetHumanoid
		if not invalid and ignoreDeadTargets and isHumanoidDead(targetHumanoid) then invalid = true end
		if not invalid and not isAimModelEnabled(targetModel) then invalid = true end
		if not invalid then
			local screenPosition, onScreen = camera:WorldToViewportPoint(targetPart.Position)
			local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
			local distance = (Vector2.new(screenPosition.X, screenPosition.Y) - center).Magnitude
			if not onScreen or screenPosition.Z <= 0 or distance > fovRadius or not hasLineOfSight(targetPart) then
				invalid = true
			end
		end
		if invalid then
			lockedTarget = nil
			targetPart = nil
		end
	end

	if not targetPart then
		targetPart = getClosestTarget()
		lockedTarget = targetPart
	end
	if not targetPart or not targetPart:IsA("BasePart") or not targetPart:IsDescendantOf(workspace) then return end

	local cameraPosition = camera.CFrame.Position
	local targetPosition = targetPart.Position
	if aimMode == "Legit" then
		local leadTime = math.clamp((targetPosition - cameraPosition).Magnitude / 2500, 0, 0.045)
		targetPosition += targetPart.AssemblyLinearVelocity * leadTime
	end

	local desired = CFrame.new(cameraPosition, targetPosition)
	if aimMode == "Rage" or smoothing <= 0 then
		camera.CFrame = desired
		return
	end

	local dt = math.clamp(deltaTime or (1 / 60), 1 / 240, 0.1)
	local responseTime = 0.004 + math.clamp(smoothing, 0, 150) * 0.0015
	local alpha = math.clamp(1 - math.exp(-dt / responseTime), 0.04, 0.72)
	local screenTarget = camera:WorldToViewportPoint(targetPosition)
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	if (Vector2.new(screenTarget.X, screenTarget.Y) - center).Magnitude < 2 then return end

	local newCFrame = camera.CFrame:Lerp(desired, alpha)
	if newCFrame.LookVector:Dot(targetPosition - cameraPosition) > 0 then camera.CFrame = newCFrame end
end

local function isAimInput(input)
	if input.UserInputType ~= aimInputType then
		return false
	end
	if aimInputType == Enum.UserInputType.Keyboard then
		return input.KeyCode == aimKeyCode
	end
	return true
end

local function getAimKeyName()
	if aimInputType == Enum.UserInputType.MouseButton1 then
		return "Mouse 1"
	elseif aimInputType == Enum.UserInputType.MouseButton2 then
		return "Mouse 2"
	elseif aimInputType == Enum.UserInputType.Keyboard then
		return aimKeyCode.Name
	end
	return "Tecla"
end

--// ESP funcional para os outros jogadores
local ESP_PREFIX = "AngellBypassESP"
for _, object in ipairs(workspace:GetChildren()) do
	if object.Name:sub(1, #ESP_PREFIX) == ESP_PREFIX and object.Name:sub(-3) == "Hat" then
		object:Destroy()
	end
end

local function getESPId(target)
	if target:IsA("Player") then
		return tostring(target.UserId)
	end
	return target:GetDebugId()
end

local function setScreenLine(line, fromPoint, toPoint, color, thickness)
	local delta = toPoint - fromPoint
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Position = UDim2.fromOffset((fromPoint.X + toPoint.X) / 2, (fromPoint.Y + toPoint.Y) / 2)
	line.Size = UDim2.fromOffset(math.max(delta.Magnitude, 1), thickness or 1)
	line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
	line.BackgroundColor3 = color or WHITE
	line.BorderSizePixel = 0
	line.Visible = true
end

--// Retangulo na tela que envolve exatamente o boneco (usado pelo Corner Box e pela vida)
local SCREEN_BODY_PARTS = {
	Head = true, HumanoidRootPart = true, Torso = true,
	UpperTorso = true, LowerTorso = true,
	["Left Arm"] = true, ["Right Arm"] = true,
	["Left Leg"] = true, ["Right Leg"] = true,
	LeftUpperArm = true, LeftLowerArm = true, LeftHand = true,
	RightUpperArm = true, RightLowerArm = true, RightHand = true,
	LeftUpperLeg = true, LeftLowerLeg = true, LeftFoot = true,
	RightUpperLeg = true, RightLowerLeg = true, RightFoot = true,
}

local function getScreenBounds(character)
	local centerPart = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Head")
	if not centerPart then return nil end
	local centerScreen = camera:WorldToViewportPoint(centerPart.Position)
	if centerScreen.Z <= 0 then return nil end

	local minX, minY = math.huge, math.huge
	local maxX, maxY = -math.huge, -math.huge
	local validCorners = 0

	for _, part in ipairs(character:GetChildren()) do
		if part:IsA("BasePart") and SCREEN_BODY_PARTS[part.Name] then
			local halfSize = part.Size * 0.5
			for signX = -1, 1, 2 do
				for signY = -1, 1, 2 do
					for signZ = -1, 1, 2 do
						local worldCorner = (part.CFrame * CFrame.new(
							halfSize.X * signX, halfSize.Y * signY, halfSize.Z * signZ
						)).Position
						local screenCorner = camera:WorldToViewportPoint(worldCorner)
						if screenCorner.Z > 0 then
							validCorners += 1
							minX = math.min(minX, screenCorner.X)
							minY = math.min(minY, screenCorner.Y)
							maxX = math.max(maxX, screenCorner.X)
							maxY = math.max(maxY, screenCorner.Y)
						end
					end
				end
			end
		end
	end

	if validCorners == 0 or maxX < minX or maxY < minY then return nil end
	local viewport = camera.ViewportSize
	if maxX < 0 or minX > viewport.X or maxY < 0 or minY > viewport.Y then return nil end
	minX = math.clamp(minX, 0, viewport.X)
	maxX = math.clamp(maxX, 0, viewport.X)
	minY = math.clamp(minY, 0, viewport.Y)
	maxY = math.clamp(maxY, 0, viewport.Y)
	if maxX - minX < 2 or maxY - minY < 2 then return nil end
	return minX, minY, maxX, maxY
end

--// Corner Box desenhado na tela: segue o tamanho real do boneco em qualquer distancia
local function updateCornerBox(id, minX, minY, maxX, maxY)
	local containerName = ESP_PREFIX .. id .. "CornerBox"
	local container = gui:FindFirstChild(containerName)

	if not cornerBoxEnabled then
		if container then
			container:Destroy()
		end
		return
	end

	if not minX then
		if container then
			container.Visible = false
		end
		return
	end

	if not container then
		container = Instance.new("Frame")
		container.Name = containerName
		container.Size = UDim2.fromScale(1, 1)
		container.Position = UDim2.fromOffset(0, 0)
		container.BackgroundTransparency = 1
		container.BorderSizePixel = 0
		container.ClipsDescendants = false
		container.Active = false
		container.ZIndex = 4
		container.Parent = gui

			for index = 1, 8 do
				local segment = Instance.new("Frame")
				segment.Name = "Corner" .. index
				segment.BorderSizePixel = 0
				segment.ZIndex = 4
				segment.Parent = container
				local segmentCorner = Instance.new("UICorner")
				segmentCorner.CornerRadius = UDim.new(1, 0)
				segmentCorner.Parent = segment
			end
	end

	container.Visible = true

	local width = maxX - minX
	local height = maxY - minY
		local thickness = espLineThickness
	local horizontalLength = math.clamp(width * 0.22, 5, 34)
	local verticalLength = math.clamp(height * 0.22, 5, 50)
	local rightX = maxX - thickness
	local bottomY = maxY - thickness
	local topRightX = maxX - horizontalLength
	local bottomLeftY = maxY - verticalLength

	local layout = {
		{minX, minY, horizontalLength, thickness},
		{minX, minY, thickness, verticalLength},
		{topRightX, minY, horizontalLength, thickness},
		{rightX, minY, thickness, verticalLength},
		{minX, bottomY, horizontalLength, thickness},
		{minX, bottomLeftY, thickness, verticalLength},
		{topRightX, bottomY, horizontalLength, thickness},
		{rightX, bottomLeftY, thickness, verticalLength},
	}

	for index, data in ipairs(layout) do
		local segment = container:FindFirstChild("Corner" .. index)
		if segment then
			segment.Position = UDim2.fromOffset(data[1], data[2])
			segment.Size = UDim2.fromOffset(data[3], data[4])
			segment.BackgroundColor3 = boxColor
		end
	end
end

--// Barra de vida em tela: acompanha o boneco (nao cresce quando o alvo esta longe)
local function findHealthNumber(container, names)
	if not container then return nil end
	for _, name in ipairs(names) do
		local attribute = container:GetAttribute(name)
		if typeof(attribute) == "number" then return attribute end
		local valueObject = container:FindFirstChild(name)
		if valueObject and (valueObject:IsA("NumberValue") or valueObject:IsA("IntValue")) then
			return valueObject.Value
		end
	end
	return nil
end

local function getESPHealth(character, humanoid)
	local health = math.max(humanoid.Health, 0)
	local maxHealth = math.max(humanoid.MaxHealth, 1)
	local sources = {character, humanoid}
	local stats = character:FindFirstChild("Stats")
	if stats then table.insert(sources, stats) end

	local customHealth
	local customMaxHealth
	for _, source in ipairs(sources) do
		customHealth = customHealth or findHealthNumber(source, {"CurrentHealth", "Health", "HP", "CurrentHP", "HealthValue", "HitPoints"})
		customMaxHealth = customMaxHealth or findHealthNumber(source, {"MaxHealth", "MaxHP", "MaxHp", "MaxHitPoints"})
	end

	if customHealth ~= nil then
		local candidateMax = math.max(customMaxHealth or maxHealth, 1)
		local humanoidRatio = health / maxHealth
		local customRatio = math.clamp(customHealth / candidateMax, 0, 1)
		-- Se o jogo mantem a vida do Humanoid cheia, usa o valor customizado menor.
		if customRatio < humanoidRatio then
			health = customHealth
			maxHealth = candidateMax
		end
	end

	return math.clamp(health, 0, maxHealth), maxHealth
end

local function updateHealthBar(id, currentHealth, maxHealth, minX, minY, maxX, maxY)
	local barName = ESP_PREFIX .. id .. "Health"
	local container = gui:FindFirstChild(barName)

	if not healthEnabled then
		if container then container:Destroy() end
		return
	end
	if not currentHealth or not maxHealth or maxHealth <= 0 or not minX then
		if container then container.Visible = false end
		return
	end

	if not container then
		container = Instance.new("Frame")
		container.Name = barName
		container.BackgroundColor3 = BLACK
			container.BorderSizePixel = 1
			container.BorderColor3 = WHITE
			container.ZIndex = 5
			container.Parent = gui
			local healthCorner = Instance.new("UICorner")
			healthCorner.CornerRadius = UDim.new(0, 3)
			healthCorner.Parent = container
			local healthStroke = Instance.new("UIStroke")
			healthStroke.Color = Color3.fromRGB(10, 10, 12)
			healthStroke.Transparency = 0.15
			healthStroke.Thickness = 1
			healthStroke.Parent = container
			local fill = Instance.new("Frame")
		fill.Name = "HealthFill"
		fill.BorderSizePixel = 0
			fill.ZIndex = 5
			fill.Parent = container
			local fillCorner = Instance.new("UICorner")
			fillCorner.CornerRadius = UDim.new(0, 2)
			fillCorner.Parent = fill
	end

	container.Visible = true
	local width = maxX - minX
	local height = maxY - minY
	local percent = math.clamp(currentHealth / math.max(maxHealth, 1), 0, 1)
	local fill = container:FindFirstChild("HealthFill")
		if healthPosition == "Top" then
			container.Size = UDim2.fromOffset(math.max(width, 8), espHealthThickness)
		container.Position = UDim2.fromOffset(minX + healthOffset.X, minY - 7 + healthOffset.Y)
		fill.AnchorPoint = Vector2.new(0, 0)
		fill.Position = UDim2.fromScale(0, 0)
		fill.Size = UDim2.fromScale(percent, 1)
		elseif healthPosition == "Bottom" then
			container.Size = UDim2.fromOffset(math.max(width, 8), espHealthThickness)
		container.Position = UDim2.fromOffset(minX + healthOffset.X, maxY + 4 + healthOffset.Y)
		fill.AnchorPoint = Vector2.new(0, 0)
		fill.Position = UDim2.fromScale(0, 0)
		fill.Size = UDim2.fromScale(percent, 1)
	else
			container.Size = UDim2.fromOffset(espHealthThickness, math.max(height, 8))
		container.Position = UDim2.fromOffset(minX - 6 + healthOffset.X, minY + healthOffset.Y)
		fill.AnchorPoint = Vector2.new(0, 1)
		fill.Position = UDim2.fromScale(0, 1)
		fill.Size = UDim2.fromScale(1, percent)
	end
	fill.BackgroundColor3 = healthColor
end

local function updateSkeleton(target, character, id)
	local skeletonName = ESP_PREFIX .. id .. "Skeleton"
	local skeleton = gui:FindFirstChild(skeletonName)
	if not skeleton then
		skeleton = Instance.new("Frame")
		skeleton.Name = skeletonName
		skeleton.Size = UDim2.fromScale(1, 1)
		skeleton.BackgroundTransparency = 1
		skeleton.BorderSizePixel = 0
			skeleton.ClipsDescendants = false
			skeleton.Active = false
			skeleton.Position = UDim2.fromOffset(0, 0)
			skeleton.ZIndex = 2
			skeleton.Parent = gui
		end
		for _, child in ipairs(skeleton:GetChildren()) do
			if child:IsA("GuiObject") then
				child.Visible = false
			end
		end

		local connections = {
			-- R15: cabeça, tronco, braços articulados e pernas articuladas.
			{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
			{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
			{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
			{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
			{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
			-- R6: estrutura simples no estilo do exemplo enviado.
			{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
			{"Torso", "Left Leg"}, {"Torso", "Right Leg"}
		}

		local index = 0
		local function getPart(name)
			return character:FindFirstChild(name) or character:FindFirstChild(name, true)
		end
		for _, pair in ipairs(connections) do
			local first = getPart(pair[1])
			local second = getPart(pair[2])
			if first and second and first:IsA("BasePart") and second:IsA("BasePart") then
			local from, fromVisible = camera:WorldToViewportPoint(first.Position)
			local to, toVisible = camera:WorldToViewportPoint(second.Position)
			index += 1
			local line = skeleton:FindFirstChild("Bone" .. index)
			if not line then
				line = Instance.new("Frame")
					line.Name = "Bone" .. index
					line.ZIndex = 3
					line.Parent = skeleton
					local lineCorner = Instance.new("UICorner")
					lineCorner.CornerRadius = UDim.new(1, 0)
					lineCorner.Parent = line
			end
			line.Visible = fromVisible and toVisible and from.Z > 0 and to.Z > 0
				if line.Visible then
						setScreenLine(line, Vector2.new(from.X, from.Y), Vector2.new(to.X, to.Y), skeletonColor, espSkeletonThickness)
				end
			end
		end

		for _, child in ipairs(skeleton:GetChildren()) do
			local number = tonumber(child.Name:match("Bone(%d+)"))
			if number and number > index then
				child:Destroy()
			end
		end
end

local function removeESP(target)
	local character = target:IsA("Player") and target.Character or target

	local id = getESPId(target)
	for _, suffix in ipairs({"", "Line", "Skeleton", "Health"}) do
		local object = gui:FindFirstChild(ESP_PREFIX .. id .. suffix)
			if object then
				object:Destroy()
			end
		end
	for index = 1, 8 do
		local corner = gui:FindFirstChild(ESP_PREFIX .. id .. "Corner" .. index)
		if corner then corner:Destroy() end
	end
	local cornerBox = gui:FindFirstChild(ESP_PREFIX .. id .. "CornerBox")
	if cornerBox then cornerBox:Destroy() end
	local hat = workspace:FindFirstChild(ESP_PREFIX .. id .. "Hat")
	if hat then hat:Destroy() end
	end

local function updateESP(target)
	local character = target:IsA("Player") and target.Character or target
	if target == player or not character or not character.Parent or not isValidCharacter(character) or not espEnabled then
		removeESP(target)
		return
	end

	local head = getAimPart(character)
	local root = character:FindFirstChild("HumanoidRootPart") or head
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not head or not root or not humanoid then
		removeESP(target)
		return
	end

	local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if localRoot and (localRoot.Position - root.Position).Magnitude > espMaxDistance then
		removeESP(target)
		return
	end

	local espColor = visibleCheckEnabled and (hasVisualLineOfSight(character) and visibleESPColor or hiddenESPColor)
		or nil
	local oldBoxColor, oldTextColor = boxColor, textColor
	local oldLineColor, oldSkeletonColor = lineColor, skeletonColor
	if espColor then
		boxColor = espColor
		textColor = espColor
		lineColor = espColor
		skeletonColor = espColor
	end

	local id = getESPId(target)
	local bMinX, bMinY, bMaxX, bMaxY = getScreenBounds(character)
	local currentHealth, maxHealth = getESPHealth(character, humanoid)
	updateCornerBox(id, bMinX, bMinY, bMaxX, bMaxY)
	updateHealthBar(id, currentHealth, maxHealth, bMinX, bMinY, bMaxX, bMaxY)

	local billboardName = ESP_PREFIX .. id
	local hasBillboard = namesEnabled or distanceEnabled or healthTextEnabled
	local billboard = gui:FindFirstChild(billboardName)

	if not hasBillboard then
		if billboard then billboard:Destroy() end
	else
		if billboard and not billboard:IsA("TextLabel") then
			billboard:Destroy()
			billboard = nil
		end
		if not billboard then
			billboard = Instance.new("TextLabel")
			billboard.Name = billboardName
				billboard.Size = UDim2.fromOffset(200, 22)
				billboard.AnchorPoint = Vector2.new(0.5, 1)
				billboard.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
				billboard.BackgroundTransparency = 0.28
				billboard.BorderSizePixel = 0
				billboard.TextStrokeColor3 = BLACK
				billboard.TextStrokeTransparency = 0.35
				billboard.TextSize = 13
				billboard.Font = Enum.Font.GothamBold
				billboard.TextXAlignment = Enum.TextXAlignment.Center
				billboard.ZIndex = 6
				billboard.Parent = gui
				local billboardCorner = Instance.new("UICorner")
				billboardCorner.CornerRadius = UDim.new(0, 6)
				billboardCorner.Parent = billboard
				local billboardStroke = Instance.new("UIStroke")
				billboardStroke.Color = Color3.fromRGB(70, 70, 80)
				billboardStroke.Transparency = 0.35
				billboardStroke.Thickness = 1
				billboardStroke.Parent = billboard
		end

		local parts = {}
		if namesEnabled then
			table.insert(parts, target:IsA("Player") and (target.DisplayName or target.Name) or character.Name)
		end
		if healthTextEnabled then
			table.insert(parts, "HP " .. math.floor(currentHealth) .. "/" .. math.floor(maxHealth))
		end
		if distanceEnabled then
			local localRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if localRoot then
				table.insert(parts, tostring(math.floor((localRoot.Position - root.Position).Magnitude)) .. " studs")
			end
		end
		billboard.TextColor3 = textColor
		billboard.Text = table.concat(parts, " | ")
		billboard.Visible = bMinX ~= nil
		if bMinX then
			billboard.Position = UDim2.fromOffset((bMinX + bMaxX) / 2, math.max(22, bMinY - 3))
		end
	end

		local skeletonObject = gui:FindFirstChild(ESP_PREFIX .. id .. "Skeleton")
	if skeletonEnabled then
		updateSkeleton(target, character, id)
	elseif skeletonObject then
		skeletonObject:Destroy()
	end

	local lineName = ESP_PREFIX .. id .. "Line"
	local line = gui:FindFirstChild(lineName)
	if linesEnabled then
		if not line then
			line = Instance.new("Frame")
			line.Name = lineName
			line.AnchorPoint = Vector2.new(0.5, 0.5)
			line.Size = UDim2.fromOffset(1, 2)
				line.BackgroundColor3 = WHITE
				line.BorderSizePixel = 0
				line.ZIndex = 1
				line.Parent = gui
				local lineCorner = Instance.new("UICorner")
				lineCorner.CornerRadius = UDim.new(1, 0)
				lineCorner.Parent = line
		end
			local screenPosition, onScreen = camera:WorldToViewportPoint(head.Position)
		local viewport = camera.ViewportSize
			local startPoint = lineOrigin == "Top"
				and Vector2.new(viewport.X / 2, 0)
				or Vector2.new(viewport.X / 2, viewport.Y)
		local endPoint = Vector2.new(screenPosition.X, screenPosition.Y)
		local delta = endPoint - startPoint
		line.Visible = onScreen and screenPosition.Z > 0
		if line.Visible then
			line.BackgroundColor3 = lineColor
			line.Position = UDim2.fromOffset((startPoint.X + endPoint.X) / 2, (startPoint.Y + endPoint.Y) / 2)
				line.Size = UDim2.fromOffset(math.max(delta.Magnitude, 1), espLineThickness)
			line.Rotation = math.deg(math.atan2(delta.Y, delta.X))
		end
	elseif line then
		line:Destroy()
	end

	boxColor = oldBoxColor
	textColor = oldTextColor
	lineColor = oldLineColor
	skeletonColor = oldSkeletonColor
end

local function safeUpdateESP(target)
	local ok, err = pcall(updateESP, target)
	if not ok then
		warn("AngellBypass ESP: alvo ignorado após erro: " .. tostring(err))
	end
end

refreshESP = function()
	if npcESPEnabled then
		getCandidates()
	end
	local known = {}
	local activeNames = {}
	for _, target in ipairs(Players:GetPlayers()) do
		if target ~= player then
			if target.Character then
				known[target.Character] = true
			end
			if not friendPlayers[target.UserId] and target.Character then
					if isValidCharacter(target.Character) then
						local id = getESPId(target)
						activeNames[ESP_PREFIX .. id] = true
						activeNames[ESP_PREFIX .. id .. "Line"] = true
						activeNames[ESP_PREFIX .. id .. "Skeleton"] = true
								activeNames[ESP_PREFIX .. id .. "Health"] = true
								activeNames[ESP_PREFIX .. id .. "CornerBox"] = true
						end
					safeUpdateESP(target)
				end
			end
	end
	if npcESPEnabled then
		for _, object in ipairs(npcCache) do
				if isAimTargetValid(object) and not known[object] then
					local id = getESPId(object)
					activeNames[ESP_PREFIX .. id] = true
					activeNames[ESP_PREFIX .. id .. "Line"] = true
					activeNames[ESP_PREFIX .. id .. "Skeleton"] = true
							activeNames[ESP_PREFIX .. id .. "Health"] = true
							activeNames[ESP_PREFIX .. id .. "CornerBox"] = true
					safeUpdateESP(object)
			end
		end
	end
	for _, object in ipairs(gui:GetChildren()) do
		if object.Name:sub(1, #ESP_PREFIX) == ESP_PREFIX and not activeNames[object.Name] then
			object:Destroy()
		end
	end
	for _, object in ipairs(workspace:GetChildren()) do
		if object.Name:sub(1, #ESP_PREFIX) == ESP_PREFIX and object.Name:sub(-3) == "Hat" and not activeNames[object.Name] then
			object:Destroy()
		end
	end
end

local function watchPlayer(target)
	local function watchCharacter(character)
		local humanoid = character:FindFirstChildOfClass("Humanoid") or character:WaitForChild("Humanoid", 3)
		if humanoid then
			humanoid.Died:Connect(function()
				removeESP(target)
				if lockedTarget and lockedTarget:IsDescendantOf(character) then
					lockedTarget = nil
				end
			end)
		end
	end
	if target.Character then
		watchCharacter(target.Character)
	end
	target.CharacterAdded:Connect(function(character)
		watchCharacter(character)
		task.wait(0.2)
		safeUpdateESP(target)
	end)
end

for _, target in ipairs(Players:GetPlayers()) do
	if target ~= player then
		watchPlayer(target)
	end
end

Players.PlayerAdded:Connect(watchPlayer)
Players.PlayerRemoving:Connect(removeESP)

player.CharacterAdded:Connect(function(character)
	originalWalkSpeed = nil
	if speedPropertyConnection then
		speedPropertyConnection:Disconnect()
		speedPropertyConnection = nil
	end
	local humanoid = character:WaitForChild("Humanoid", 5)
	if humanoid then
		applyWalkSpeed()
	end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if flyEnabled and not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
		flyKeys[input.KeyCode] = true
	end
	if panelTerminated then
		return
	end

	if capturingMenuKeybind then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Escape then
				capturingMenuKeybind = false
				if menuKeybindButton then menuKeybindButton.Text = "Menu: " .. menuKeyCode.Name end
				return
			end
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				menuKeyCode = input.KeyCode
				capturingMenuKeybind = false
				if menuKeybindButton then menuKeybindButton.Text = "Menu: " .. menuKeyCode.Name end
				return
			end
		end
		return
	end

	if capturingSpinKeybind then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Insert then return end
			if input.KeyCode == Enum.KeyCode.Escape then
				capturingSpinKeybind = false
				if spinKeybindButton then spinKeybindButton.Text = "Giro: " .. spinKeyCode.Name end
				return
			end
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				spinKeyCode = input.KeyCode
				capturingSpinKeybind = false
				if spinKeybindButton then spinKeybindButton.Text = "Giro: " .. spinKeyCode.Name end
				return
			end
		end
		return
	end

	if capturingDashKeybind then
		if input.UserInputType == Enum.UserInputType.Keyboard then
			if input.KeyCode == Enum.KeyCode.Insert then return end
			if input.KeyCode == Enum.KeyCode.Escape then
				capturingDashKeybind = false
				if dashKeybindButton then dashKeybindButton.Text = "Dash: " .. dashKeyCode.Name end
				return
			end
			if input.KeyCode ~= Enum.KeyCode.Unknown then
				dashKeyCode = input.KeyCode
				capturingDashKeybind = false
				if dashKeybindButton then dashKeybindButton.Text = "Dash: " .. dashKeyCode.Name end
				return
			end
		end
		return
	end

	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == menuKeyCode and not capturingKeybind then
		if streamProofEnabled then
			streamProofEnabled = false
			gui.Enabled = true
			panelOpen = false
			togglePanel()
		else
			togglePanel()
		end
		return
	end

	if capturingKeybind then
		if input.KeyCode == Enum.KeyCode.Insert then
			return
		end

		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
			aimInputType = Enum.UserInputType.Keyboard
			aimKeyCode = input.KeyCode
			capturingKeybind = false
		elseif input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.MouseButton2 then
			aimInputType = input.UserInputType
			aimKeyCode = Enum.KeyCode.Unknown
			capturingKeybind = false
		end
		if keybindButton then
			keybindButton.Text = "Keybind: " .. getAimKeyName()
		end
		return
	end

	if not gameProcessed and dashEnabled
		and input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == dashKeyCode then
		performDash()
		return
	end

	if not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == spinKeyCode then
		spinbotEnabled = not spinbotEnabled
		if spinToggleButton and spinToggleButton.Parent then
			spinToggleButton.BackgroundColor3 = spinbotEnabled and ACCENT or PANEL2
			spinToggleButton.Text = spinbotEnabled and "✓" or ""
		end
		return
	end

		-- O clique pode ser marcado como processado pelo jogo; ainda assim
		-- deve iniciar o aimbot quando o usuário estiver usando o keybind configurado.
		if isAimInput(input) then
			aiming = true
		end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard then
		flyKeys[input.KeyCode] = nil
	end
	if isAimInput(input) then
		aiming = false
	end
end)

		RunService.RenderStepped:Connect(function(deltaTime)
			if panelTerminated then
				return
			end

			fpsCounterLabel.Visible = fpsCounterEnabled
			fpsElapsed += deltaTime
			fpsFrameCount += 1
			if fpsElapsed >= 0.5 then
				fpsCounterLabel.Text = string.format("FPS: %d", math.floor(fpsFrameCount / fpsElapsed + 0.5))
				fpsElapsed = 0
				fpsFrameCount = 0
			end

			camera = workspace.CurrentCamera
			if not camera then
				return
			end
			camera.FieldOfView = screenStretchEnabled
				and screenStretchFOV
				or (cameraFOVEnabled and math.clamp(cameraFOV, 40, 100) or defaultCameraFOV)
			-- O Rage altera a câmera instantaneamente; atualize a mira antes do ESP
			-- para que caixa, linha e skeleton usem a mesma projeção neste frame.
				local aimOK, aimError = pcall(updateAim, deltaTime)
				if not aimOK then
					warn("AngellBypass Aimbot: atualização recuperada após erro: " .. tostring(aimError))
					lockedTarget = nil
				end
			local now = os.clock()
				local currentESPInterval = espRefreshInterval
				if espEnabled and now - lastESPRefresh >= currentESPInterval then
					lastESPRefresh = now
					local espOK, espError = pcall(refreshESP)
					if not espOK then
						warn("AngellBypass ESP: atualização recuperada após erro: " .. tostring(espError))
					end
				end
				local viewport = camera.ViewportSize
			fovCircle.Position = UDim2.fromOffset(viewport.X / 2, viewport.Y / 2)
			fovCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
				fovCircle.Visible = showFOV

			if particleLayer and main and main.Visible then
				local step = math.min(deltaTime, 0.05)
				local panelSize = main.AbsoluteSize
				for _, particle in ipairs(particleRecords) do
					particle.y += particle.speed * step
					particle.x += particle.drift * step
					particle.x = math.clamp(particle.x, 0, math.max(panelSize.X - particle.size, 0))
					if particle.y > panelSize.Y + particle.size then
						particle.y = -particle.size
						particle.x = particleRandom:NextNumber(0, math.max(panelSize.X - particle.size, 0))
					end
					particle.object.Position = UDim2.fromOffset(particle.x, particle.y)
				end
			end

				updateFly()

				if spinbotEnabled then
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then
					root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinbotSpeed * 3) * deltaTime, 0)
				end
			end
		end)

--// Janela principal
main = Instance.new("Frame")
main.Name = "MainPanel"
main.Size = UDim2.fromOffset(620, 400)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.BackgroundColor3 = BG
main.BackgroundTransparency = 1
main.BorderSizePixel = 0
main.Visible = false
main.Parent = gui

local panelScale = Instance.new("UIScale")
panelScale.Scale = 0.92
panelScale.Parent = main

particleLayer = Instance.new("Frame")
particleLayer.Name = "PanelParticles"
particleLayer.Size = UDim2.fromScale(1, 1)
particleLayer.BackgroundTransparency = 1
particleLayer.BorderSizePixel = 0
particleLayer.ClipsDescendants = true
particleLayer.Active = false
particleLayer.ZIndex = 1
particleLayer.Parent = main

for _ = 1, 12 do
	local size = particleRandom:NextInteger(2, 4)
	local dot = Instance.new("Frame")
	dot.Name = "FallingDot"
	dot.Size = UDim2.fromOffset(size, size)
	dot.Position = UDim2.fromOffset(
		particleRandom:NextNumber(0, 616),
		particleRandom:NextNumber(0, 396)
	)
	dot.BackgroundColor3 = WHITE
	dot.BackgroundTransparency = particleRandom:NextNumber(0.25, 0.55)
	dot.BorderSizePixel = 0
	dot.Active = false
	dot.ZIndex = 1
	dot.Parent = particleLayer
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = dot
	table.insert(particleRecords, {
		object = dot,
		x = dot.Position.X.Offset,
		y = dot.Position.Y.Offset,
		size = size,
		speed = particleRandom:NextNumber(28, 66),
		drift = particleRandom:NextNumber(-7, 7),
	})
end

local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 11)
	corner.Parent = main
	main.ClipsDescendants = true

local panelStroke = Instance.new("UIStroke")
panelStroke.Color = ACCENT
panelStroke.Transparency = 0.72
panelStroke.Thickness = 1
panelStroke.Parent = main

--// Barra superior
local top = Instance.new("Frame")
top.ZIndex = 2
top.Size = UDim2.new(1, 0, 0, 50)
top.BackgroundColor3 = PANEL
top.BorderSizePixel = 0
top.Parent = main

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 8)
topCorner.Parent = top

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -300, 1, 0)
title.Position = UDim2.fromOffset(15, 0)
title.BackgroundTransparency = 1
title.Text = "Angell Bypass"
title.TextColor3 = WHITE
title.TextSize = 22
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = top

local function formatKeyTime(expiry)
	local timestamp = tonumber(expiry)
	if not timestamp then
		return "Não informado"
	elseif timestamp <= 0 then
		return "Expirada"
	end
	local remaining = timestamp - os.time()
	if remaining <= 0 then
		return "Expirada"
	end
	local days = math.floor(remaining / 86400)
	local hours = math.floor((remaining % 86400) / 3600)
	local minutes = math.floor((remaining % 3600) / 60)
	local seconds = math.floor(remaining % 60)
	return string.format("%dd %02dh %02dm %02ds", days, hours, minutes, seconds)
end

local userInfo = Instance.new("TextLabel")
userInfo.Name = "UserKeyInfo"
userInfo.Size = UDim2.fromOffset(275, 22)
userInfo.Position = UDim2.new(1, -285, 0, 2)
userInfo.BackgroundTransparency = 1
userInfo.Text = "User: Angell Bypass"
userInfo.TextColor3 = WHITE
userInfo.TextSize = 13
userInfo.Font = Enum.Font.GothamBold
userInfo.TextXAlignment = Enum.TextXAlignment.Right
userInfo.TextYAlignment = Enum.TextYAlignment.Center
userInfo.TextTruncate = Enum.TextTruncate.AtEnd
userInfo.Parent = top

local timeInfo = Instance.new("TextLabel")
timeInfo.Name = "KeyTimeInfo"
timeInfo.Size = UDim2.fromOffset(275, 22)
timeInfo.Position = UDim2.new(1, -285, 0, 25)
timeInfo.BackgroundTransparency = 1
timeInfo.TextColor3 = Color3.fromRGB(155, 155, 165)
timeInfo.TextSize = 13
timeInfo.Font = Enum.Font.GothamBold
timeInfo.TextXAlignment = Enum.TextXAlignment.Right
timeInfo.TextYAlignment = Enum.TextYAlignment.Center
timeInfo.Parent = top

local function updateKeyInfo()
	userInfo.Text = "User: Angell Bypass"
	timeInfo.Text = "Tempo restante: " .. formatKeyTime(keyExpiry)
end

task.spawn(function()
	while userInfo.Parent do
		updateKeyInfo()
		local expiryTimestamp = tonumber(keyExpiry)
		if expiryTimestamp and os.time() >= expiryTimestamp then
			timeInfo.Text = "Tempo restante: Expirada"
			task.wait(0.1)
			pcall(function()
				player:Kick("Sua key expirou.")
			end)
			return
		end
		task.wait(1)
	end
end)
updateKeyInfo()

local panelScaleTween = nil
local panelFadeTween = nil
local panelAnimationId = 0

local function setPanelVisible(visible)
	if panelScaleTween then panelScaleTween:Cancel() end
	if panelFadeTween then panelFadeTween:Cancel() end
	panelAnimationId += 1
	local animationId = panelAnimationId
	panelOpen = visible

	if visible then
		gui.Enabled = true
		if not main.Visible then
			main.Visible = true
			panelScale.Scale = 0.92
			main.BackgroundTransparency = 0.35
		end
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		UserInputService.MouseIconEnabled = true
		local info = TweenInfo.new(0.72, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		panelScaleTween = TweenService:Create(panelScale, info, {Scale = 1})
		panelFadeTween = TweenService:Create(main, info, {BackgroundTransparency = 0})
		panelScaleTween:Play()
			panelFadeTween:Play()
		else
			-- O painel fechado deve devolver o controle do mouse ao jogador.
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			UserInputService.MouseIconEnabled = true
		if not main.Visible then return end
		local info = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
		panelScaleTween = TweenService:Create(panelScale, info, {Scale = 0.92})
		panelFadeTween = TweenService:Create(main, info, {BackgroundTransparency = 0.35})
		local closingTween = panelScaleTween
		closingTween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed
				and animationId == panelAnimationId and not panelOpen then
				main.Visible = false
				main.BackgroundTransparency = 0
			end
		end)
		panelScaleTween:Play()
		panelFadeTween:Play()
	end
end

togglePanel = function()
	if not gui.Enabled then
		gui.Enabled = true
	end
	setPanelVisible(not panelOpen)
end

local function disableAllFeatures()
		aimbotEnabled = false
		aiming = false
		lockedTarget = nil
		targetNPCs = false
		wallCheck = false
		espEnabled = false
	namesEnabled = false
	distanceEnabled = false
	healthEnabled = false
	healthTextEnabled = false
	linesEnabled = false
	skeletonEnabled = false
	cornerBoxEnabled = false
		spinbotEnabled = false
		showFOV = false
			npcESPEnabled = false
			visibleCheckEnabled = false
	for userId in pairs(friendPlayers) do
		friendPlayers[userId] = nil
	end
	lastCandidateScan = 0
	candidateCache = {}
	lockedTarget = nil
	if spinToggleButton and spinToggleButton.Parent then
		spinToggleButton.BackgroundColor3 = PANEL2
		spinToggleButton.Text = ""
	end
		speedEnabled = false
		dashEnabled = false
		capturingDashKeybind = false
		if dashToggleButton and dashToggleButton.Parent then
			dashToggleButton.BackgroundColor3 = PANEL2
			dashToggleButton.Text = ""
		end
		if dashToggleStroke and dashToggleStroke.Parent then
			dashToggleStroke.Color = Color3.fromRGB(75, 75, 82)
			dashToggleStroke.Transparency = 0.25
		end
		stopFly()
		fpsCounterEnabled = false
			fpsCounterLabel.Visible = false
			vividColorsEnabled = false
			setVividColors(false)
			watermarkEnabled = false
			streamProofEnabled = false
			gui.Enabled = true
		cameraFOVEnabled = false
	screenStretchEnabled = false
	if camera then
		camera.FieldOfView = defaultCameraFOV
	end
	applyWalkSpeed()
	fovCircle.Visible = false
	refreshESP()
end

--// Arrastar a janela
local dragging = false
local dragStart
local startPos

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then

		dragging = true
		dragStart = input.Position
		startPos = main.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and (
		input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
	) then

		local delta = input.Position - dragStart

		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--// Sidebar
local sidebar = Instance.new("Frame")
sidebar.ZIndex = 2
sidebar.Size = UDim2.fromOffset(130, 350)
sidebar.Position = UDim2.fromOffset(5, 50)
sidebar.BackgroundColor3 = PANEL
sidebar.BorderSizePixel = 0
sidebar.Parent = main

	local tabs = {
		{"◉", "Aimbot"},
			{"◉", "Visuals"},
				{"◆", "Cores"},
				{"●", "Player"},
				{"♙", "Amigos"},
				{"◇", "Misc"}
		}

local contentViewport = Instance.new("ScrollingFrame")
contentViewport.Name = "TabContentScroll"
contentViewport.ZIndex = 2
contentViewport.Size = UDim2.new(1, -145, 1, -60)
contentViewport.Position = UDim2.fromOffset(140, 60)
contentViewport.BackgroundTransparency = 1
contentViewport.BorderSizePixel = 0
contentViewport.ScrollBarThickness = 5
contentViewport.ScrollBarImageColor3 = GRAY
contentViewport.ScrollingDirection = Enum.ScrollingDirection.Y
contentViewport.CanvasSize = UDim2.fromOffset(0, 390)
contentViewport.Parent = main

local content = Instance.new("CanvasGroup")
content.Name = "TabContent"
content.ZIndex = 2
content.Size = UDim2.new(1, -8, 0, 390)
content.Position = UDim2.fromOffset(0, 0)
content.BackgroundTransparency = 1
content.Parent = contentViewport
local tabContentTween = nil

local currentTab = "Aimbot"
local activeChoiceMenu = nil

local function clearContent()
	activeChoiceMenu = nil
	for _, obj in ipairs(content:GetChildren()) do
		obj:Destroy()
	end
end

local function createLabel(text, pos, size)
	local label = Instance.new("TextLabel")
	label.Size = size or UDim2.fromOffset(150, 25)
	label.Position = pos
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = WHITE
	label.TextSize = 14
	label.Font = Enum.Font.Gotham
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = content
	return label
end

local function createCheckbox(text, pos, default, onChanged, large)
	local labelWidth = large and 210 or 120
	local label = createLabel(text, pos + UDim2.fromOffset(large and 34 or 28, 0), UDim2.fromOffset(labelWidth, large and 32 or 25))
	label.TextSize = large and 18 or 15

	local boxSize = large and 26 or 20
	local box = Instance.new("TextButton")
	box.Size = UDim2.fromOffset(boxSize, boxSize)
	box.Position = pos + UDim2.fromOffset(0, large and 3 or 2)
	box.BackgroundColor3 = default and ACCENT or PANEL2
	box.BorderSizePixel = 0
	box.Text = default and "✓" or ""
	box.TextColor3 = BLACK
	box.TextSize = large and 19 or 16
	box.Font = Enum.Font.GothamBold
	box.AutoButtonColor = false
	box.Parent = content

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = box
	local stroke = Instance.new("UIStroke")
	stroke.Color = default and ACCENT or Color3.fromRGB(75, 75, 82)
	stroke.Transparency = default and 0.05 or 0.25
	stroke.Thickness = 1
	stroke.Parent = box

	local enabled = default
	box.MouseButton1Click:Connect(function()
			enabled = not enabled
			box.BackgroundColor3 = enabled and ACCENT or PANEL2
			box.Text = enabled and "✓" or ""
			stroke.Color = enabled and ACCENT or Color3.fromRGB(75, 75, 82)
			stroke.Transparency = enabled and 0.05 or 0.25
			if onChanged then onChanged(enabled) end
	end)
	box.MouseEnter:Connect(function()
		if not enabled then box.BackgroundColor3 = Color3.fromRGB(52, 52, 60) end
	end)
	box.MouseLeave:Connect(function()
		box.BackgroundColor3 = enabled and ACCENT or PANEL2
	end)
	return box
end

local function createColorButton(pos, initialColor, onChanged)
	local button = Instance.new("TextButton")
	button.Name = "ESPColorPicker"
	button.Size = UDim2.fromOffset(30, 22)
	button.Position = pos + UDim2.fromOffset(135, 2)
	button.BackgroundColor3 = PANEL2
	button.BorderSizePixel = 0
	button.Text = "●"
	button.TextColor3 = initialColor
	button.TextSize = 17
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Parent = content

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button
	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = GRAY
	buttonStroke.Thickness = 1
	buttonStroke.Parent = button

	local popup = Instance.new("Frame")
	popup.Name = "ColorPalette"
	popup.Size = UDim2.fromOffset(#colorPalette * 25 + 8, 32)
	popup.Position = pos + UDim2.fromOffset(168, -3)
	popup.BackgroundColor3 = PANEL
	popup.BorderSizePixel = 0
	popup.Visible = false
	popup.ZIndex = 50
	popup.Parent = content
	local popupCorner = Instance.new("UICorner")
	popupCorner.CornerRadius = UDim.new(0, 6)
	popupCorner.Parent = popup
	local popupStroke = Instance.new("UIStroke")
	popupStroke.Color = GRAY
	popupStroke.Thickness = 1
	popupStroke.Parent = popup

	for index, color in ipairs(colorPalette) do
		local swatch = Instance.new("TextButton")
		swatch.Size = UDim2.fromOffset(20, 20)
		swatch.Position = UDim2.fromOffset(4 + (index - 1) * 25, 6)
		swatch.BackgroundColor3 = color
		swatch.BorderSizePixel = 0
		swatch.Text = ""
		swatch.ZIndex = 51
		swatch.Parent = popup
		local swatchCorner = Instance.new("UICorner")
		swatchCorner.CornerRadius = UDim.new(1, 0)
		swatchCorner.Parent = swatch
		swatch.MouseButton1Click:Connect(function()
			button.TextColor3 = color
			popup.Visible = false
			if onChanged then onChanged(color) end
		end)
	end

	button.MouseButton1Click:Connect(function()
		popup.Visible = not popup.Visible
	end)
	return button
end

local function createSlider(text, pos, min, max, default, onChanged, large)
	local label = createLabel(text, pos, UDim2.fromOffset(large and 175 or 150, large and 26 or 25))
	if large then label.TextSize = 15 end

	local valueOffset = large and 195 or 160
	local valueLabel = createLabel(
		tostring(default),
		pos + UDim2.fromOffset(valueOffset, 0),
		UDim2.fromOffset(large and 45 or 40, large and 26 or 25)
	)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	if large then valueLabel.TextSize = 14 end

	local bar = Instance.new("Frame")
	bar.Size = UDim2.fromOffset(large and 190 or 160, large and 8 or 7)
	bar.Position = pos + UDim2.fromOffset(0, large and 32 or 28)
	bar.BackgroundColor3 = PANEL2
	bar.BorderSizePixel = 0
	bar.Parent = content
	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(1, 0)
	barCorner.Parent = bar
	local barStroke = Instance.new("UIStroke")
	barStroke.Color = Color3.fromRGB(75, 75, 82)
	barStroke.Transparency = 0.2
	barStroke.Thickness = 1
	barStroke.Parent = bar

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = ACCENT
	fill.BorderSizePixel = 0
	fill.Parent = bar
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = fill
	local thumb = Instance.new("Frame")
	thumb.Name = "SliderThumb"
	thumb.Size = UDim2.fromOffset(12, 12)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	thumb.BackgroundColor3 = WHITE
	thumb.BorderSizePixel = 0
	thumb.ZIndex = 3
	thumb.Parent = bar
	local thumbCorner = Instance.new("UICorner")
	thumbCorner.CornerRadius = UDim.new(1, 0)
	thumbCorner.Parent = thumb

	local draggingSlider = false
	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = false
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local x = math.clamp(input.Position.X - bar.AbsolutePosition.X, 0, bar.AbsoluteSize.X)
			local percent = x / bar.AbsoluteSize.X
			local value = math.floor((min + ((max - min) * percent)) * 10) / 10
				fill.Size = UDim2.new(percent, 0, 1, 0)
				thumb.Position = UDim2.new(percent, 0, 0.5, 0)
			valueLabel.Text = tostring(value)
			if onChanged then onChanged(value) end
		end
	end)
end

local function createKeybindButton(pos)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(130, 26)
	button.Position = pos
	button.BackgroundColor3 = PANEL2
	button.BorderSizePixel = 1
	button.BorderColor3 = ACCENT
	button.Text = "Keybind: " .. getAimKeyName()
	button.TextColor3 = WHITE
	button.TextSize = 10
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Parent = content

	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 7)
	buttonCorner.Parent = button
	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = ACCENT
	buttonStroke.Transparency = 0.35
	buttonStroke.Thickness = 1
	buttonStroke.Parent = button

	button.MouseButton1Click:Connect(function()
		capturingKeybind = true
		button.Text = "Pressione uma tecla..."
	end)

	keybindButton = button
	return button
end

local function createMenuKeybindButton(pos)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(150, 26)
	button.Position = pos
	button.BackgroundColor3 = PANEL2
	button.BorderSizePixel = 1
	button.BorderColor3 = ACCENT
	button.Text = "Menu: " .. menuKeyCode.Name
	button.TextColor3 = WHITE
	button.TextSize = 11
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Parent = content
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 6)
	buttonCorner.Parent = button
	button.MouseButton1Click:Connect(function()
		capturingMenuKeybind = true
		button.Text = "Pressione uma tecla..."
	end)
	menuKeybindButton = button
	return button
end

local function createSpinKeybindButton(pos)
	local button = Instance.new("TextButton")
	button.Size = UDim2.fromOffset(130, 26)
	button.Position = pos
	button.BackgroundColor3 = PANEL2
	button.BorderSizePixel = 1
	button.BorderColor3 = GRAY
	button.Text = "Giro: " .. spinKeyCode.Name
	button.TextColor3 = WHITE
	button.TextSize = 11
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Parent = content
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = button
	button.MouseButton1Click:Connect(function()
		capturingSpinKeybind = true
		button.Text = "Pressione uma tecla..."
	end)
	spinKeybindButton = button
	return button
end

local function createDashKeybindButton(pos)
	local button = Instance.new("TextButton")
	button.Name = "DashKeybind"
	button.Size = UDim2.fromOffset(130, 26)
	button.Position = pos
	button.BackgroundColor3 = PANEL2
	button.BorderSizePixel = 1
	button.BorderColor3 = GRAY
	button.Text = "Dash: " .. dashKeyCode.Name
	button.TextColor3 = WHITE
	button.TextSize = 11
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.Parent = content
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 5)
	corner.Parent = button
	button.MouseButton1Click:Connect(function()
		capturingDashKeybind = true
		button.Text = "Pressione uma tecla..."
	end)
	dashKeybindButton = button
	return button
end

local function createChoiceDropdown(title, pos, choices, selectedValue, labels, onChanged)
	local width = 180
	local rowHeight = 34
	local expandedHeight = #choices * rowHeight + 10
	local titleLabel = createLabel(title, pos, UDim2.fromOffset(width, 20))
	titleLabel.TextSize = 12
	titleLabel.TextColor3 = GRAY
	titleLabel.Font = Enum.Font.GothamSemibold

	local button = Instance.new("TextButton")
	button.Name = "Dropdown_" .. title:gsub("%s+", "")
	button.Size = UDim2.fromOffset(width, 36)
	button.Position = pos + UDim2.fromOffset(0, 23)
	button.BackgroundColor3 = Color3.fromRGB(24, 26, 34)
	button.BorderSizePixel = 0
	button.Text = labels[selectedValue] or tostring(selectedValue)
	button.TextColor3 = WHITE
	button.TextSize = 12
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.Font = Enum.Font.GothamSemibold
	button.AutoButtonColor = false
	button.ZIndex = 15
	button.Parent = content
	local buttonPadding = Instance.new("UIPadding")
	buttonPadding.PaddingLeft = UDim.new(0, 12)
	buttonPadding.PaddingRight = UDim.new(0, 34)
	buttonPadding.Parent = button
	local buttonCorner = Instance.new("UICorner")
	buttonCorner.CornerRadius = UDim.new(0, 8)
	buttonCorner.Parent = button
	local buttonStroke = Instance.new("UIStroke")
	buttonStroke.Color = Color3.fromRGB(66, 75, 96)
	buttonStroke.Transparency = 0.18
	buttonStroke.Thickness = 1
	buttonStroke.Parent = button

	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.fromOffset(28, 30)
	arrow.Position = UDim2.new(1, -32, 0.5, -15)
	arrow.BackgroundTransparency = 1
	arrow.Text = "v"
	arrow.TextColor3 = ACCENT
	arrow.TextSize = 14
	arrow.Font = Enum.Font.GothamBold
	arrow.ZIndex = 16
	arrow.Parent = button

	local menu = Instance.new("Frame")
	menu.Name = "ChoiceMenu_" .. title:gsub("%s+", "")
	menu.Size = UDim2.fromOffset(width, 0)
	menu.Position = pos + UDim2.fromOffset(0, 62)
	menu.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
	menu.BackgroundTransparency = 1
	menu.BorderSizePixel = 0
	menu.ClipsDescendants = true
	menu.Visible = false
	menu.ZIndex = 30
	menu.Parent = content
	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 9)
	menuCorner.Parent = menu
	local menuStroke = Instance.new("UIStroke")
	menuStroke.Color = Color3.fromRGB(81, 96, 126)
	menuStroke.Transparency = 1
	menuStroke.Thickness = 1
	menuStroke.Parent = menu

	local choiceButtons = {}
	local choiceByButton = {}
	for index, choice in ipairs(choices) do
		local option = Instance.new("TextButton")
		option.Name = "Choice_" .. tostring(choice)
		option.Size = UDim2.new(1, -10, 0, 30)
		option.Position = UDim2.fromOffset(5, 5 + (index - 1) * rowHeight)
		option.BackgroundColor3 = choice == selectedValue and Color3.fromRGB(43, 55, 82) or Color3.fromRGB(18, 20, 28)
		option.BorderSizePixel = 0
		option.Text = (choice == selectedValue and "✓   " or "     ") .. (labels[choice] or tostring(choice))
		option.TextColor3 = choice == selectedValue and Color3.fromRGB(170, 200, 255) or WHITE
		option.TextSize = 12
		option.TextXAlignment = Enum.TextXAlignment.Left
		option.Font = choice == selectedValue and Enum.Font.GothamSemibold or Enum.Font.Gotham
		option.AutoButtonColor = false
		option.ZIndex = 31
		option.Parent = menu
		local optionPadding = Instance.new("UIPadding")
		optionPadding.PaddingLeft = UDim.new(0, 9)
		optionPadding.Parent = option
		local optionCorner = Instance.new("UICorner")
		optionCorner.CornerRadius = UDim.new(0, 6)
		optionCorner.Parent = option
		table.insert(choiceButtons, option)
		choiceByButton[option] = choice
		option.MouseEnter:Connect(function()
			if option.Name ~= "Choice_" .. tostring(selectedValue) then
				TweenService:Create(option, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(34, 39, 52)}):Play()
			end
		end)
		option.MouseLeave:Connect(function()
			local isSelected = option.Name == "Choice_" .. tostring(selectedValue)
			TweenService:Create(option, TweenInfo.new(0.1), {
				BackgroundColor3 = isSelected and Color3.fromRGB(43, 55, 82) or Color3.fromRGB(18, 20, 28)
			}):Play()
		end)
		option.MouseButton1Click:Connect(function()
			selectedValue = choice
			button.Text = labels[choice] or tostring(choice)
			for _, other in ipairs(choiceButtons) do
				local selected = other.Name == "Choice_" .. tostring(choice)
				other.Text = (selected and "✓   " or "     ") .. (labels[choiceByButton[other]] or tostring(choiceByButton[other]))
				other.BackgroundColor3 = selected and Color3.fromRGB(43, 55, 82) or Color3.fromRGB(18, 20, 28)
				other.TextColor3 = selected and Color3.fromRGB(170, 200, 255) or WHITE
				other.Font = selected and Enum.Font.GothamSemibold or Enum.Font.Gotham
			end
			if onChanged then onChanged(choice) end
			if activeChoiceMenu == menu then activeChoiceMenu = nil end
			arrow.Rotation = 0
			local closeTween = TweenService:Create(menu, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Size = UDim2.fromOffset(width, 0), BackgroundTransparency = 1
			})
			TweenService:Create(menuStroke, TweenInfo.new(0.12), {Transparency = 1}):Play()
			closeTween.Completed:Connect(function()
				if menu.Parent then menu.Visible = false end
			end)
			closeTween:Play()
		end)
	end

	local menuTween
	button.MouseButton1Click:Connect(function()
		if menuTween then menuTween:Cancel() end
		local opening = not menu.Visible or menu.Size.Y.Offset == 0
		if opening then
			if activeChoiceMenu and activeChoiceMenu ~= menu and activeChoiceMenu.Parent then
				activeChoiceMenu.Visible = false
			end
			activeChoiceMenu = menu
			menu.Visible = true
			menu.Size = UDim2.fromOffset(width, 0)
			menu.BackgroundTransparency = 1
			arrow.Rotation = 180
			menuTween = TweenService:Create(menu, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(width, expandedHeight), BackgroundTransparency = 0
			})
			TweenService:Create(menuStroke, TweenInfo.new(0.18), {Transparency = 0.18}):Play()
			menuTween:Play()
		else
			if activeChoiceMenu == menu then activeChoiceMenu = nil end
			arrow.Rotation = 0
			menuTween = TweenService:Create(menu, TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Size = UDim2.fromOffset(width, 0), BackgroundTransparency = 1
			})
			TweenService:Create(menuStroke, TweenInfo.new(0.12), {Transparency = 1}):Play()
			menuTween.Completed:Connect(function()
				if menu.Parent and menu.Size.Y.Offset == 0 then menu.Visible = false end
			end)
			menuTween:Play()
		end
	end)
	button.MouseEnter:Connect(function()
		TweenService:Create(buttonStroke, TweenInfo.new(0.12), {Color = ACCENT, Transparency = 0}):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(buttonStroke, TweenInfo.new(0.12), {Color = Color3.fromRGB(66, 75, 96), Transparency = 0.18}):Play()
	end)
	return button
end

local function createLineOriginButtons(pos)
	local choices = {"Top", "Bottom"}
	for index, choice in ipairs(choices) do
		local button = Instance.new("TextButton")
		button.Name = "LineOrigin_" .. choice
		button.Size = UDim2.fromOffset(62, 22)
		button.Position = pos + UDim2.fromOffset((index - 1) * 66, 0)
		button.BackgroundColor3 = lineOrigin == choice and ACCENT or PANEL2
		button.BorderSizePixel = 0
		button.Text = choice == "Top" and "Topo" or "Baixo"
		button.TextColor3 = lineOrigin == choice and BLACK or WHITE
		button.TextSize = 10
		button.Font = Enum.Font.GothamBold
		button.AutoButtonColor = false
		button.Parent = content
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = button
		button.MouseButton1Click:Connect(function()
			lineOrigin = choice
			for _, other in ipairs(content:GetChildren()) do
				if other:IsA("TextButton") and other.Name:sub(1, 11) == "LineOrigin_" then
					local selected = other.Name == "LineOrigin_" .. choice
					other.BackgroundColor3 = selected and ACCENT or PANEL2
					other.TextColor3 = selected and BLACK or WHITE
				end
			end
			refreshPreview()
			refreshESP()
		end)
	end
end

local function createHealthPositionButtons(pos)
	local choices = {"Side", "Top", "Bottom"}
	for index, choice in ipairs(choices) do
		local button = Instance.new("TextButton")
		button.Name = "HealthPosition_" .. choice
			button.Size = UDim2.fromOffset(54, 26)
			button.Position = pos + UDim2.fromOffset((index - 1) * 56, 0)
		button.BackgroundColor3 = healthPosition == choice and ACCENT or PANEL2
		button.BorderSizePixel = 0
		button.Text = choice == "Side" and "Lado" or choice == "Top" and "Topo" or "Baixo"
		button.TextColor3 = healthPosition == choice and BLACK or WHITE
			button.TextSize = 10
		button.Font = Enum.Font.GothamBold
		button.AutoButtonColor = false
		button.Parent = content
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 4)
		corner.Parent = button
		button.MouseButton1Click:Connect(function()
			healthPosition = choice
			healthOffset = Vector2.new(0, 0)
			for _, other in ipairs(content:GetChildren()) do
				if other:IsA("TextButton") and other.Name:sub(1, 15) == "HealthPosition_" then
					local selected = other.Name == "HealthPosition_" .. choice
					other.BackgroundColor3 = selected and ACCENT or PANEL2
					other.TextColor3 = selected and BLACK or WHITE
				end
			end
			refreshPreview()
			refreshESP()
		end)
	end
end

local function createESPPreview(pos)
	local preview = Instance.new("Frame")
	preview.Name = "ESPPreview"
	preview.Size = UDim2.fromOffset(135, 245)
	preview.Position = pos
	preview.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	preview.BorderSizePixel = 0
	preview.Parent = content
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = preview
	local stroke = Instance.new("UIStroke")
	stroke.Color = GRAY
	stroke.Transparency = 0.25
	stroke.Parent = preview

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 24)
	title.BackgroundTransparency = 1
	title.Text = "ESP Preview"
	title.TextColor3 = WHITE
	title.TextSize = 12
	title.Font = Enum.Font.GothamBold
	title.Parent = preview

	local stage = Instance.new("Frame")
	stage.Size = UDim2.fromOffset(112, 145)
	stage.Position = UDim2.fromOffset(11, 31)
	stage.BackgroundTransparency = 1
	stage.Parent = preview

	local function makePart(size, position, color, radius, parent)
		local part = Instance.new("Frame")
		part.Size = size
		part.Position = position
		part.BackgroundColor3 = color
		part.BorderSizePixel = 0
		part.Parent = parent or stage
		if radius then
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, radius)
			c.Parent = part
		end
		return part
	end

	local skin = Color3.fromRGB(236, 184, 143)
	local shirt = Color3.fromRGB(55, 115, 205)
	local shirtLight = Color3.fromRGB(80, 145, 235)
	local pants = Color3.fromRGB(38, 48, 75)
	local shoe = Color3.fromRGB(25, 27, 35)
	local hair = Color3.fromRGB(35, 24, 22)

	-- Avatar blocky com proporções de personagem Roblox.
	makePart(UDim2.fromOffset(31, 39), UDim2.fromOffset(40, 52), shirt, 5)
	makePart(UDim2.fromOffset(31, 7), UDim2.fromOffset(40, 52), shirtLight, 3)
	makePart(UDim2.fromOffset(9, 6), UDim2.fromOffset(51, 46), skin, 2)
	makePart(UDim2.fromOffset(12, 39), UDim2.fromOffset(25, 53), shirt, 5)
	makePart(UDim2.fromOffset(12, 39), UDim2.fromOffset(74, 53), shirt, 5)
	makePart(UDim2.fromOffset(13, 39), UDim2.fromOffset(41, 88), pants, 4)
	makePart(UDim2.fromOffset(13, 39), UDim2.fromOffset(57, 88), pants, 4)
	makePart(UDim2.fromOffset(14, 7), UDim2.fromOffset(40, 125), shoe, 3)
	makePart(UDim2.fromOffset(14, 7), UDim2.fromOffset(56, 125), shoe, 3)

		local head = makePart(UDim2.fromOffset(29, 27), UDim2.fromOffset(41, 18), skin, 6)
		makePart(UDim2.fromOffset(31, 8), UDim2.fromOffset(40, 14), hair, 5)
						makePart(UDim2.fromOffset(7, 5), UDim2.fromOffset(43, 22), hair, 3)
	makePart(UDim2.fromOffset(3, 4), UDim2.fromOffset(48, 29), BLACK, 2)
	makePart(UDim2.fromOffset(3, 4), UDim2.fromOffset(59, 29), BLACK, 2)
	makePart(UDim2.fromOffset(7, 2), UDim2.fromOffset(52, 37), Color3.fromRGB(150, 65, 65), 1)

	local box = Instance.new("Frame")
	box.Size = UDim2.fromOffset(60, 119)
	box.Position = UDim2.fromOffset(26, 13)
	box.BackgroundTransparency = 1
	box.BorderSizePixel = 2
	box.BorderColor3 = boxColor
	box.ZIndex = 5
	box.Parent = stage
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.fromOffset(110, 18)
	nameLabel.Position = UDim2.fromOffset(1, -4)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = "Player"
	nameLabel.TextColor3 = textColor
	nameLabel.TextSize = 11
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.ZIndex = 6
	nameLabel.Parent = stage

	local healthBack = Instance.new("Frame")
	healthBack.Size = UDim2.fromOffset(4, 90)
	healthBack.Position = UDim2.fromOffset(18, 30)
	healthBack.BackgroundColor3 = BLACK
	healthBack.BorderSizePixel = 1
	healthBack.BorderColor3 = WHITE
	healthBack.ZIndex = 6
	healthBack.Parent = stage
	local healthFill = Instance.new("Frame")
	healthFill.Size = UDim2.fromScale(1, 0.78)
	healthFill.Position = UDim2.fromScale(0, 1)
	healthFill.AnchorPoint = Vector2.new(0, 1)
	healthFill.BackgroundColor3 = healthColor
	healthFill.BorderSizePixel = 0
	healthFill.Parent = healthBack

	local line = Instance.new("Frame")
	line.Size = UDim2.fromOffset(espLineThickness, 100)
	line.Position = lineOrigin == "Top" and UDim2.fromOffset(56, -15) or UDim2.fromOffset(56, 133)
	line.BackgroundColor3 = lineColor
	line.BorderSizePixel = 0
	line.ZIndex = 4
	line.Parent = stage
	local skeletonSegments = {}
	for _, data in ipairs({
		{UDim2.fromOffset(2, 30), UDim2.fromOffset(55, 39), 0},
		{UDim2.fromOffset(2, 28), UDim2.fromOffset(40, 56), -35},
		{UDim2.fromOffset(2, 28), UDim2.fromOffset(70, 56), 35},
		{UDim2.fromOffset(2, 34), UDim2.fromOffset(47, 85), -12},
		{UDim2.fromOffset(2, 34), UDim2.fromOffset(63, 85), 12},
	}) do
		local segment = makePart(data[1], data[2], skeletonColor, 1)
		segment.Rotation = data[3]
		segment.ZIndex = 5
		table.insert(skeletonSegments, segment)
	end

	local function updatePreview()
		if not preview.Parent then return end
			local hasPreviewFeature = namesEnabled or distanceEnabled or healthEnabled or healthTextEnabled or linesEnabled or skeletonEnabled or cornerBoxEnabled
			box.Visible = espEnabled and (cornerBoxEnabled or not hasPreviewFeature)
		local info = {}
		if namesEnabled then table.insert(info, "Player") end
		if distanceEnabled then table.insert(info, "120 studs") end
		if healthTextEnabled then table.insert(info, "HP 78/100") end
		nameLabel.Visible = espEnabled and #info > 0
		nameLabel.Text = table.concat(info, " | ")
		healthBack.Visible = espEnabled and healthEnabled
		line.Visible = espEnabled and linesEnabled
		for _, segment in ipairs(skeletonSegments) do
			segment.Visible = espEnabled and skeletonEnabled
			segment.BackgroundColor3 = skeletonColor
		end
		box.BorderColor3 = boxColor
		nameLabel.TextColor3 = textColor
		healthBack.Size = healthPosition == "Side" and UDim2.fromOffset(espHealthThickness, 90) or UDim2.fromOffset(4, 90)
		healthFill.BackgroundColor3 = healthColor
		line.BackgroundColor3 = lineColor
		line.Size = UDim2.fromOffset(espLineThickness, 100)
		line.Position = lineOrigin == "Top" and UDim2.fromOffset(56, -15) or UDim2.fromOffset(56, 133)
	end
	updatePreview()
	refreshPreview = updatePreview
	return updatePreview
end

local function showFeatureWarning(message, onAccept)
	local dialog = Instance.new("Frame")
	dialog.Name = "FlyWarningDialog"
	dialog.Size = UDim2.fromOffset(360, 170)
	dialog.Position = UDim2.new(0.5, -180, 0.5, -85)
	dialog.BackgroundColor3 = PANEL
	dialog.BorderSizePixel = 0
	dialog.ZIndex = 50
	dialog.Parent = gui
	local dialogCorner = Instance.new("UICorner")
	dialogCorner.CornerRadius = UDim.new(0, 8)
	dialogCorner.Parent = dialog
	local dialogStroke = Instance.new("UIStroke")
	dialogStroke.Color = Color3.fromRGB(255, 70, 70)
	dialogStroke.Thickness = 2
	dialogStroke.Parent = dialog
	local dialogText = Instance.new("TextLabel")
	dialogText.Size = UDim2.new(1, -24, 0, 85)
	dialogText.Position = UDim2.fromOffset(12, 12)
	dialogText.BackgroundTransparency = 1
	dialogText.Text = "Atenção\n" .. message
	dialogText.TextColor3 = WHITE
	dialogText.TextWrapped = true
	dialogText.TextSize = 14
	dialogText.Font = Enum.Font.GothamBold
	dialogText.ZIndex = 51
	dialogText.Parent = dialog
	local function dialogButton(text, x, accepted)
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(145, 32)
		button.Position = UDim2.fromOffset(x, 122)
		button.BackgroundColor3 = accepted and ACCENT or PANEL2
		button.BorderSizePixel = 0
		button.Text = text
		button.TextColor3 = accepted and BLACK or WHITE
		button.TextSize = 12
		button.Font = Enum.Font.GothamBold
		button.ZIndex = 51
		button.Parent = dialog
		button.MouseButton1Click:Connect(function()
			if accepted then onAccept() end
			dialog:Destroy()
		end)
	end
	dialogButton("Concordar", 18, true)
	dialogButton("Recusar", 197, false)
end

local function showTab(tabName)
	if tabContentTween then
		tabContentTween:Cancel()
	end
	currentTab = tabName
	local scrollableTab = tabName == "Aimbot" or tabName == "Visuals" or tabName == "Amigos" or tabName == "Player"
	contentViewport.ScrollingEnabled = scrollableTab
	contentViewport.ScrollBarThickness = scrollableTab and 5 or 0
	content.GroupTransparency = 1
	content.Position = UDim2.fromOffset(0, 0)
	contentViewport.CanvasPosition = Vector2.zero
	clearContent()

	if tabName == "Aimbot" then
			local aimTitle = createLabel("Aimbot", UDim2.fromOffset(0, 0), UDim2.fromOffset(140, 32))
			aimTitle.TextSize = 18
			aimTitle.Font = Enum.Font.GothamBold

			createCheckbox("Enable Aimbot", UDim2.fromOffset(0, 35), aimbotEnabled, function(enabled)
				aimbotEnabled = enabled
				if not enabled then
					aiming = false
					lockedTarget = nil
				else
					lastCandidateScan = 0
					candidateCache = {}
				end
			end)
		createCheckbox("Show FOV", UDim2.fromOffset(0, 65), showFOV, function(enabled)
			showFOV = enabled
		end)
			createCheckbox("Target NPCs", UDim2.fromOffset(0, 95), targetNPCs, function(enabled)
				targetNPCs = enabled
				lastCandidateScan = 0
				lastNPCScan = 0
				npcCache = {}
				candidateCache = {}
				lockedTarget = nil
			end)
			createCheckbox("Wall Check", UDim2.fromOffset(0, 125), wallCheck, function(enabled)
			wallCheck = enabled
		end)
		createCheckbox("Ignorar mortos", UDim2.fromOffset(0, 155), ignoreDeadTargets, function(enabled)
			ignoreDeadTargets = enabled
			lastCandidateScan = 0
			candidateCache = {}
			if ignoreDeadTargets and lockedTarget then
				local _, humanoid = getHumanoidForPart(lockedTarget)
				if humanoid and isHumanoidDead(humanoid) then lockedTarget = nil end
			end
		end)

			createChoiceDropdown("Modo", UDim2.fromOffset(190, 145), {"Legit", "Rage"}, aimMode, {
				Legit = "Legit",
				Rage = "Rege",
		}, function(choice)
			aimMode = choice
		end)
		createChoiceDropdown("Alvo da mira", UDim2.fromOffset(190, 210), {"Head", "Chest", "Nearest"}, aimTargetMode, {
			Head = "Cabeça",
			Chest = "Peito",
			Nearest = "Mais perto",
		}, function(choice)
			aimTargetMode = choice
		end)

		createLabel("Keybind", UDim2.fromOffset(190, 275)).TextSize = 15
		createKeybindButton(UDim2.fromOffset(190, 300))

			createSlider("FOV Radius", UDim2.fromOffset(190, 35), 1, 900, fovRadius, function(value)
			fovRadius = value
			fovCircle.Size = UDim2.fromOffset(fovRadius * 2, fovRadius * 2)
			end)
					createSlider("Smoothing", UDim2.fromOffset(190, 90), 0, 150, smoothing, function(value)
					smoothing = value
				end)

elseif tabName == "Visuals" then
			createLabel("Visuals", UDim2.fromOffset(0, 0))
			createCheckbox("ESP", UDim2.fromOffset(0, 40), espEnabled, function(enabled)
			espEnabled = enabled
			refreshESP()
			refreshPreview()
		end)
		createCheckbox("Names", UDim2.fromOffset(0, 70), namesEnabled, function(enabled)
			namesEnabled = enabled
			refreshESP()
			refreshPreview()
		end)
		createCheckbox("Distance", UDim2.fromOffset(0, 100), distanceEnabled, function(enabled)
			distanceEnabled = enabled
			refreshESP()
			refreshPreview()
		end)
		createCheckbox("Health", UDim2.fromOffset(0, 130), healthEnabled, function(enabled)
			healthEnabled = enabled
			refreshESP()
			refreshPreview()
		end)
				createCheckbox("Lines", UDim2.fromOffset(0, 160), linesEnabled, function(enabled)
				linesEnabled = enabled
				refreshESP()
				refreshPreview()
			end)
		createCheckbox("Skeleton", UDim2.fromOffset(0, 190), skeletonEnabled, function(enabled)
			skeletonEnabled = enabled
			refreshESP()
			refreshPreview()
		end)
				createCheckbox("Health Text", UDim2.fromOffset(0, 250), healthTextEnabled, function(enabled)
					healthTextEnabled = enabled
					local espOK, espError = pcall(refreshESP)
					if not espOK then
						warn("AngellBypass ESP: atualização recuperada após erro: " .. tostring(espError))
					end
				end)
			createCheckbox("Corner Box", UDim2.fromOffset(0, 280), cornerBoxEnabled, function(enabled)
				cornerBoxEnabled = enabled
				refreshESP()
				refreshPreview()
			end)
				createCheckbox("NPC ESP", UDim2.fromOffset(0, 220), npcESPEnabled, function(enabled)
					npcESPEnabled = enabled
				lastCandidateScan = 0
				lastNPCScan = 0
				npcCache = {}
				refreshESP()
					refreshPreview()
				end)
					createCheckbox("Visible Check", UDim2.fromOffset(0, 310), visibleCheckEnabled, function(enabled)
						visibleCheckEnabled = enabled
						refreshESP()
					end)
					createESPPreview(UDim2.fromOffset(295, 0))

			elseif tabName == "Cores" then
				local colorsTitle = createLabel("Cores do ESP", UDim2.fromOffset(0, 0), UDim2.fromOffset(190, 32))
				colorsTitle.TextSize = 18
				colorsTitle.Font = Enum.Font.GothamBold
				createLabel("Cores", UDim2.fromOffset(0, 30), UDim2.fromOffset(180, 22)).TextColor3 = GRAY
				for _, colorRow in ipairs({
					{"Texto", 65, textColor, function(color) textColor = color end},
					{"Vida", 105, healthColor, function(color) healthColor = color end},
					{"Linhas", 145, lineColor, function(color) lineColor = color end},
					{"Skeleton", 185, skeletonColor, function(color) skeletonColor = color end},
					{"Caixa", 225, boxColor, function(color) boxColor = color end},
				}) do
					createLabel(colorRow[1], UDim2.fromOffset(0, colorRow[2]), UDim2.fromOffset(110, 25)).TextSize = 15
					createColorButton(UDim2.fromOffset(0, colorRow[2]), colorRow[3], function(color)
						colorRow[4](color)
						refreshESP()
						refreshPreview()
					end)
				end

				createLabel("Configurações ESP", UDim2.fromOffset(220, 0), UDim2.fromOffset(180, 28)).TextSize = 16
				createLabel("Linha", UDim2.fromOffset(220, 40), UDim2.fromOffset(100, 22)).TextSize = 13
				createLineOriginButtons(UDim2.fromOffset(220, 62))
				createLabel("Vida", UDim2.fromOffset(220, 98), UDim2.fromOffset(100, 22)).TextSize = 13
				createHealthPositionButtons(UDim2.fromOffset(220, 120))
						createSlider("Max Distance", UDim2.fromOffset(220, 160), 50, 250, espMaxDistance, function(value)
							espMaxDistance = math.clamp(value, 50, 250)
						refreshESP()
					end)
					elseif tabName == "Player" then
				createLabel("Player", UDim2.fromOffset(0, 0))
				local speedToggle
				speedToggle = createCheckbox("Enable Speed", UDim2.fromOffset(0, 45), speedEnabled, function(enabled)
					if not enabled then
						speedEnabled = false
						applyWalkSpeed()
						return
					end
					speedEnabled = false
					speedToggle.BackgroundColor3 = PANEL2
					speedToggle.Text = ""
					local dialog = Instance.new("Frame")
					dialog.Name = "SpeedWarningDialog"
					dialog.Size = UDim2.fromOffset(360, 170)
					dialog.Position = UDim2.new(0.5, -180, 0.5, -85)
					dialog.BackgroundColor3 = PANEL
					dialog.BorderSizePixel = 0
					dialog.ZIndex = 50
					dialog.Parent = gui
					local dialogCorner = Instance.new("UICorner")
					dialogCorner.CornerRadius = UDim.new(0, 8)
					dialogCorner.Parent = dialog
					local dialogStroke = Instance.new("UIStroke")
					dialogStroke.Color = Color3.fromRGB(255, 70, 70)
					dialogStroke.Thickness = 2
					dialogStroke.Parent = dialog
					local dialogText = Instance.new("TextLabel")
					dialogText.Size = UDim2.new(1, -24, 0, 85)
					dialogText.Position = UDim2.fromOffset(12, 12)
					dialogText.BackgroundTransparency = 1
					dialogText.Text = "Atenção\nA velocidade personalizada pode causar punição ou banimento. Deseja continuar?"
					dialogText.TextColor3 = WHITE
					dialogText.TextWrapped = true
					dialogText.TextSize = 14
					dialogText.Font = Enum.Font.GothamBold
					dialogText.ZIndex = 51
					dialogText.Parent = dialog
					local function dialogButton(text, x, accepted)
						local button = Instance.new("TextButton")
						button.Size = UDim2.fromOffset(145, 32)
						button.Position = UDim2.fromOffset(x, 122)
						button.BackgroundColor3 = accepted and ACCENT or PANEL2
						button.BorderSizePixel = 0
						button.Text = text
						button.TextColor3 = accepted and BLACK or WHITE
						button.TextSize = 12
						button.Font = Enum.Font.GothamBold
						button.ZIndex = 51
						button.Parent = dialog
						button.MouseButton1Click:Connect(function()
							if accepted then
								speedEnabled = true
								speedToggle.BackgroundColor3 = ACCENT
								speedToggle.Text = "✓"
								applyWalkSpeed()
							end
							dialog:Destroy()
						end)
					end
					dialogButton("Concordar", 18, true)
					dialogButton("Recusar", 197, false)
				end)
							createSlider("Walk Speed", UDim2.fromOffset(230, 45), 8, 2000, walkSpeedValue, function(value)
								walkSpeedValue = value
								applyWalkSpeed()
							end)
						local flyToggle
						flyToggle = createCheckbox("Fly", UDim2.fromOffset(0, 90), flyEnabled, function(enabled)
							if not enabled then
								stopFly()
								return
							end
							flyToggle.BackgroundColor3 = PANEL2
							flyToggle.Text = ""
							showFeatureWarning("O Fly pode causar punição ou banimento. Deseja continuar?", function()
								if startFly() then
									flyToggle.BackgroundColor3 = ACCENT
									flyToggle.Text = "✓"
								else
									stopFly()
								end
							end)
						end)
						createSlider("Fly Speed", UDim2.fromOffset(230, 90), 10, 300, flySpeed, function(value)
							flySpeed = value
						end)
						createLabel("Dash", UDim2.fromOffset(28, 135), UDim2.fromOffset(120, 25)).TextSize = 15
						dashToggleButton = Instance.new("TextButton")
						dashToggleButton.Name = "DashToggle"
						dashToggleButton.Size = UDim2.fromOffset(20, 20)
						dashToggleButton.Position = UDim2.fromOffset(0, 137)
						dashToggleButton.BackgroundColor3 = PANEL2
						dashToggleButton.BorderSizePixel = 0
						dashToggleButton.Text = ""
						dashToggleButton.TextColor3 = BLACK
						dashToggleButton.TextSize = 16
						dashToggleButton.Font = Enum.Font.GothamBold
						dashToggleButton.AutoButtonColor = false
						dashToggleButton.Parent = content
						local dashCorner = Instance.new("UICorner")
						dashCorner.CornerRadius = UDim.new(0, 6)
						dashCorner.Parent = dashToggleButton
						dashToggleStroke = Instance.new("UIStroke")
						dashToggleStroke.Color = Color3.fromRGB(75, 75, 82)
						dashToggleStroke.Transparency = 0.25
						dashToggleStroke.Thickness = 1
						dashToggleStroke.Parent = dashToggleButton
						dashToggleButton.MouseButton1Click:Connect(function()
							if dashEnabled then
								dashEnabled = false
								dashToggleButton.BackgroundColor3 = PANEL2
								dashToggleButton.Text = ""
								dashToggleStroke.Color = Color3.fromRGB(75, 75, 82)
								dashToggleStroke.Transparency = 0.25
								return
							end
							showFeatureWarning("O Dash altera a movimentação do personagem e pode causar punição ou banimento. Deseja continuar?", function()
								dashEnabled = true
								if dashToggleButton and dashToggleButton.Parent then
									dashToggleButton.BackgroundColor3 = ACCENT
									dashToggleButton.Text = "✓"
									dashToggleStroke.Color = ACCENT
									dashToggleStroke.Transparency = 0
								end
							end)
						end)
						dashToggleButton.MouseEnter:Connect(function()
							if not dashEnabled then dashToggleButton.BackgroundColor3 = Color3.fromRGB(52, 52, 60) end
						end)
						dashToggleButton.MouseLeave:Connect(function()
							dashToggleButton.BackgroundColor3 = dashEnabled and ACCENT or PANEL2
						end)
						createSlider("Dash Speed", UDim2.fromOffset(230, 135), 20, 180, dashSpeed, function(value)
							dashSpeed = math.clamp(value, 20, 180)
						end)
						createLabel("Tecla do Dash", UDim2.fromOffset(0, 170)).TextSize = 12
						createDashKeybindButton(UDim2.fromOffset(0, 195))

						spinToggleButton = createCheckbox("Spinbot", UDim2.fromOffset(0, 235), spinbotEnabled, function(enabled)
							spinbotEnabled = enabled
						end)
						createSlider("Spin Speed", UDim2.fromOffset(230, 235), 10, 1000, spinbotSpeed, function(value)
							spinbotSpeed = value
						end)
						createLabel("Tecla do giro", UDim2.fromOffset(0, 270)).TextSize = 12
						createSpinKeybindButton(UDim2.fromOffset(0, 295))
					elseif tabName == "Amigos" then
						createLabel("Amigos", UDim2.fromOffset(0, 0), UDim2.fromOffset(220, 28))
						local friendsHint = createLabel(
							"Marque quem o aimbot deve ignorar",
							UDim2.fromOffset(0, 28),
							UDim2.fromOffset(300, 24)
						)
						friendsHint.TextColor3 = GRAY
						friendsHint.TextSize = 12

						local friendSearch = Instance.new("TextBox")
						friendSearch.Name = "FriendSearch"
						friendSearch.Size = UDim2.fromOffset(280, 26)
						friendSearch.Position = UDim2.fromOffset(0, 54)
						friendSearch.BackgroundColor3 = PANEL2
						friendSearch.BorderSizePixel = 0
						friendSearch.PlaceholderText = "Pesquisar nome do amigo..."
						friendSearch.Text = ""
						friendSearch.TextColor3 = WHITE
						friendSearch.PlaceholderColor3 = GRAY
						friendSearch.TextSize = 12
						friendSearch.Font = Enum.Font.Gotham
						friendSearch.ClearTextOnFocus = false
						friendSearch.Parent = content
						local friendSearchCorner = Instance.new("UICorner")
						friendSearchCorner.CornerRadius = UDim.new(0, 5)
						friendSearchCorner.Parent = friendSearch

						local friendList = Instance.new("ScrollingFrame")
						friendList.Name = "FriendList"
						friendList.Size = UDim2.fromOffset(320, 205)
						friendList.Position = UDim2.fromOffset(0, 88)
						friendList.BackgroundColor3 = PANEL
						friendList.BackgroundTransparency = 0.2
						friendList.BorderSizePixel = 0
						friendList.ScrollBarThickness = 4
						friendList.CanvasSize = UDim2.new(0, 0, 0, 0)
						friendList.AutomaticCanvasSize = Enum.AutomaticSize.Y
						friendList.Parent = content
						local friendListCorner = Instance.new("UICorner")
						friendListCorner.CornerRadius = UDim.new(0, 5)
						friendListCorner.Parent = friendList

						local friendIndex = 0
						local friendEntries = {}
						for _, target in ipairs(Players:GetPlayers()) do
							if target ~= player then
								friendIndex += 1
								local friendButton = Instance.new("TextButton")
								friendButton.Name = "Friend_" .. tostring(target.UserId)
								friendButton.Size = UDim2.new(1, -10, 0, 32)
								friendButton.Position = UDim2.fromOffset(5, (friendIndex - 1) * 36 + 5)
								friendButton.BackgroundColor3 = friendPlayers[target.UserId] and ACCENT or PANEL2
								friendButton.BorderSizePixel = 0
								friendButton.TextColor3 = friendPlayers[target.UserId] and BLACK or WHITE
								friendButton.TextSize = 12
								friendButton.Font = Enum.Font.GothamBold
								friendButton.TextXAlignment = Enum.TextXAlignment.Left
								friendButton.Text = (friendPlayers[target.UserId] and "✓  " or "□  ")
									.. target.DisplayName .. "  (@" .. target.Name .. ")"
								friendButton.Parent = friendList
								local friendCorner = Instance.new("UICorner")
								friendCorner.CornerRadius = UDim.new(0, 5)
								friendCorner.Parent = friendButton
								table.insert(friendEntries, {player = target, button = friendButton})

								friendButton.MouseButton1Click:Connect(function()
									local selected = not friendPlayers[target.UserId]
									friendPlayers[target.UserId] = selected or nil
									friendButton.BackgroundColor3 = selected and ACCENT or PANEL2
									friendButton.TextColor3 = selected and BLACK or WHITE
									friendButton.Text = (selected and "✓  " or "□  ")
										.. target.DisplayName .. "  (@" .. target.Name .. ")"
									lastCandidateScan = 0
									candidateCache = {}
									refreshESP()
									if selected and lockedTarget
										and target.Character
										and lockedTarget:IsDescendantOf(target.Character) then
										lockedTarget = nil
									end
								end)
							end
						end

						local function refreshFriendSearch()
							local query = string.lower(friendSearch.Text or "")
							local visibleIndex = 0
							for _, entry in ipairs(friendEntries) do
								local target = entry.player
								local searchable = string.lower(target.Name .. " " .. target.DisplayName)
								local visible = query == "" or searchable:find(query, 1, true) ~= nil
								entry.button.Visible = visible
								if visible then
									visibleIndex += 1
									entry.button.Position = UDim2.fromOffset(5, (visibleIndex - 1) * 36 + 5)
								end
							end
						end
						friendSearch:GetPropertyChangedSignal("Text"):Connect(refreshFriendSearch)
						refreshFriendSearch()

						if friendIndex == 0 then
							local emptyFriends = createLabel("Não há outros jogadores no servidor.", UDim2.fromOffset(0, 65))
							emptyFriends.TextColor3 = GRAY
						end

					elseif tabName == "Misc" then
					createLabel("Misc", UDim2.fromOffset(0, 0))
						createCheckbox("Watermark", UDim2.fromOffset(165, 40), watermarkEnabled, function(enabled)
							watermarkEnabled = enabled
						end)
							createCheckbox("Mostrar FPS", UDim2.fromOffset(165, 70), fpsCounterEnabled, function(enabled)
							fpsCounterEnabled = enabled
							fpsCounterLabel.Visible = enabled
							if enabled then
								fpsCounterLabel.Position = UDim2.fromOffset(10, 10)
							end
						end)
						createCheckbox("Cores vivas", UDim2.fromOffset(165, 105), vividColorsEnabled, function(enabled)
							vividColorsEnabled = enabled
							setVividColors(enabled)
						end)
					createCheckbox("Câmera hack", UDim2.fromOffset(165, 140), screenStretchEnabled, function(enabled)
						screenStretchEnabled = enabled
						if camera then
							camera.FieldOfView = enabled and screenStretchFOV or (cameraFOVEnabled and cameraFOV or defaultCameraFOV)
						end
					end)
							createSlider("Intensidade", UDim2.fromOffset(165, 175), 80, 400, screenStretchFOV, function(value)
									screenStretchFOV = math.clamp(value, 80, 400)
									if screenStretchEnabled and camera then
										camera.FieldOfView = screenStretchFOV
									end
								end)
							createCheckbox("Stream proof", UDim2.fromOffset(165, 215), streamProofEnabled, function(enabled)
								streamProofEnabled = enabled
								if enabled then
									gui.Enabled = false
								else
									gui.Enabled = true
								end
							end)
											createLabel("Keybind menu", UDim2.fromOffset(0, 40)).TextSize = 14
											createMenuKeybindButton(UDim2.fromOffset(0, 65))
									local resetPanelButton = Instance.new("TextButton")
					resetPanelButton.Name = "ResetPanelButton"
						resetPanelButton.Size = UDim2.fromOffset(140, 26)
						resetPanelButton.Position = UDim2.fromOffset(0, 105)
				resetPanelButton.BackgroundColor3 = PANEL2
				resetPanelButton.BorderSizePixel = 0
				resetPanelButton.Text = "Resetar painel"
				resetPanelButton.TextColor3 = WHITE
					resetPanelButton.TextSize = 12
				resetPanelButton.Font = Enum.Font.GothamBold
				resetPanelButton.Parent = content
				local resetPanelCorner = Instance.new("UICorner")
				resetPanelCorner.CornerRadius = UDim.new(0, 7)
				resetPanelCorner.Parent = resetPanelButton
					resetPanelButton.MouseButton1Click:Connect(function()
						panelTerminated = false
						disableAllFeatures()
						capturingKeybind = false
					dragging = false
					main.Position = UDim2.new(0.5, 0, 0.5, 0)
					for _, child in ipairs(gui:GetChildren()) do
						if child.Name == "SpeedWarningDialog" then child:Destroy() end
					end
					gui.Enabled = true
					setPanelVisible(true)
					for _, tabButton in ipairs(sidebar:GetChildren()) do
						if tabButton:IsA("TextButton") then
							local selected = tabButton.Name == "Tab_Aimbot"
							tabButton.BackgroundColor3 = selected and ACCENT or PANEL
							tabButton.TextColor3 = selected and BLACK or WHITE
						end
					end
					showTab("Aimbot")
				end)
				local resetPanelCornerStroke = Instance.new("UIStroke")
				resetPanelCornerStroke.Color = GRAY
				resetPanelCornerStroke.Thickness = 1
				resetPanelCornerStroke.Parent = resetPanelButton

					local closePanelButton = Instance.new("TextButton")
					closePanelButton.Name = "ClosePanelButton"
						closePanelButton.Size = UDim2.fromOffset(140, 28)
						closePanelButton.Position = UDim2.fromOffset(0, 145)
				closePanelButton.BackgroundColor3 = PANEL2
				closePanelButton.BorderSizePixel = 0
					closePanelButton.Text = "cleanner priv"
					closePanelButton.BackgroundColor3 = Color3.fromRGB(180, 35, 35)
					closePanelButton.TextColor3 = WHITE
					closePanelButton.TextSize = 13
				closePanelButton.Font = Enum.Font.GothamBold
				closePanelButton.AutoButtonColor = false
				closePanelButton.Parent = content

				local closePanelCorner = Instance.new("UICorner")
				closePanelCorner.CornerRadius = UDim.new(0, 7)
				closePanelCorner.Parent = closePanelButton
					local closePanelStroke = Instance.new("UIStroke")
					closePanelStroke.Color = Color3.fromRGB(255, 70, 70)
					closePanelStroke.Thickness = 1
					closePanelStroke.Parent = closePanelButton

				closePanelButton.MouseButton1Click:Connect(function()
					panelTerminated = true
					disableAllFeatures()
					setPanelVisible(false)
					task.delay(0.28, function()
						if panelTerminated and not panelOpen then
							gui.Enabled = false
						end
					end)
				end)

		end
	content.Position = UDim2.fromOffset(0, 0)
	tabContentTween = TweenService:Create(
		content,
		TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		{Position = UDim2.fromOffset(0, 0), GroupTransparency = 0}
	)
	tabContentTween:Play()

end

--// Criar abas
for i, data in ipairs(tabs) do
	local icon = data[1]
	local name = data[2]

	local button = Instance.new("TextButton")
		button.Name = "Tab_" .. name:gsub("%s+", "")
		button.Size = name == "Aimbot" and UDim2.fromOffset(122, 38) or UDim2.fromOffset(122, 32)
		button.Position = UDim2.fromOffset(5, 5 + ((i - 1) * 38))
	button.BackgroundColor3 = (name == "Aimbot") and ACCENT or PANEL
	button.BorderSizePixel = 0
	button.Text = "  " .. icon .. "  " .. name
	button.TextColor3 = (name == "Aimbot") and BLACK or WHITE
		button.TextSize = name == "Aimbot" and 15 or 12
		button.Font = name == "Aimbot" and Enum.Font.GothamBold or Enum.Font.Gotham
	button.TextXAlignment = Enum.TextXAlignment.Left
	button.AutoButtonColor = false
	button.Parent = sidebar
	local tabScale = Instance.new("UIScale")
	tabScale.Scale = 1
	tabScale.Parent = button
	local tabPressTween = nil
	local tabReleaseTween = nil

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 3)
	c.Parent = button

	button.MouseButton1Click:Connect(function()
		if tabPressTween then tabPressTween:Cancel() end
		if tabReleaseTween then tabReleaseTween:Cancel() end
		tabScale.Scale = 1
		tabPressTween = TweenService:Create(
			tabScale,
			TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{Scale = 0.95}
		)
		tabPressTween.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed and button.Parent then
				tabReleaseTween = TweenService:Create(
					tabScale,
					TweenInfo.new(0.16, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
					{Scale = 1}
				)
				tabReleaseTween:Play()
			end
		end)
		tabPressTween:Play()

		local colorInfo = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		for _, other in ipairs(sidebar:GetChildren()) do
			if other:IsA("TextButton") then
				local selected = other == button
				TweenService:Create(other, colorInfo, {
					BackgroundColor3 = selected and ACCENT or PANEL,
					TextColor3 = selected and BLACK or WHITE,
				}):Play()
			end
		end
		showTab(name)
	end)
end

	setPanelVisible(true)
	showTab("Aimbot")

end

--// Autenticação KeyAuth
local HttpService = game:GetService("HttpService")

local appName = "G09492301's Application"
local ownerId = "5T1ZrVeqg7"
local secretKey = "42700e279cdc6cf401ce76e7b7b78c60adb8be2f336e7080ccf3e84a13906038"

local function requestApi(data)
    local req = (syn and syn.request) or (http and http.request) or http_request or request
    if not req then return nil end
    local bodyData = "name=" .. HttpService:UrlEncode(appName)
        .. "&ownerid=" .. HttpService:UrlEncode(ownerId)
        .. "&secret=" .. HttpService:UrlEncode(secretKey)
    for key, value in pairs(data) do
        bodyData = bodyData .. "&" .. key .. "=" .. HttpService:UrlEncode(tostring(value))
    end
    local ok, response = pcall(function()
        return req({
            Url = "https://keyauth.win/api/1.2/",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/x-www-form-urlencoded" },
            Body = bodyData,
        })
    end)
    if ok and response and response.Body then
        local decoded, result = pcall(function()
            return HttpService:JSONDecode(response.Body)
        end)
        if decoded then return result end
    end
    return nil
end

-- Aceita somente true real ou a string "true".
-- Em Lua, a string "false" também é truthy e não pode liberar o painel.
local function isApiSuccess(response)
    if not response then return false end
    if response.success == true then return true end
    return type(response.success) == "string"
        and string.lower(response.success) == "true"
end

local function responseText(response)
    if not response then return "" end
    local values = { response.message, response.error, response.status }
    if response.info then
        table.insert(values, response.info.message)
        table.insert(values, response.info.status)
    end
    local result = {}
    for _, value in ipairs(values) do
        if value ~= nil then table.insert(result, tostring(value)) end
    end
    return string.lower(table.concat(result, " "))
end

local function isBanned(response)
    if not response then return false end
    local fields = { "banned", "isBanned", "ban", "is_banned" }
    for _, field in ipairs(fields) do
        if response[field] == true
            or (response[field] ~= nil and tostring(response[field]):lower() == "true") then
            return true
        end
    end
    if response.info then
        for _, field in ipairs(fields) do
            if response.info[field] == true
                or (response.info[field] ~= nil and tostring(response.info[field]):lower() == "true") then
                return true
            end
        end
    end
    local text = responseText(response)
    return text:find("ban", 1, true) ~= nil
        or text:find("suspens", 1, true) ~= nil
        or text:find("blacklist", 1, true) ~= nil
end

local function normalizeExpiryValue(rawExpiry)
	local value = tonumber(rawExpiry)
	if not value then return nil end

	local now = os.time()
	-- Timestamp Unix em milissegundos.
	if value >= 100000000000 then
		return math.floor(value / 1000)
	end
	-- Valores absolutos normais do KeyAuth são timestamps Unix em segundos.
	if value >= 1000000000 then
		return math.floor(value)
	end
	-- Algumas respostas podem trazer duração relativa: dias, segundos ou ms.
	if value <= 3650 then
		return now + math.floor(value * 86400)
	elseif value <= 315360000 then
		return now + math.floor(value)
	else
		return now + math.floor(value / 1000)
	end
end

local function isExpired(response)
	if not response then return true end
    local text = responseText(response)
    if text:find("expired", 1, true)
        or text:find("expirad", 1, true)
        or text:find("license has expired", 1, true) then
        return true
    end
    local subscriptions = response.info and response.info.subscriptions
    local subscription = subscriptions and subscriptions[1]
	local expiry = subscription and normalizeExpiryValue(subscription.expiry)
	return expiry ~= nil and expiry <= os.time()
end

local function getLicenseUser(response)
	local info = response and response.info
	local value = (info and (info.username or info.user or info.name))
		or (response and (response.username or response.user or response.name))
	if value == nil or type(value) == "table" then
		return "User"
	end
	return tostring(value)
end

local function getLicenseExpiry(response)
	local info = response and response.info
	local subscriptions = info and info.subscriptions
	local subscription = subscriptions and subscriptions[1]
	return normalizeExpiryValue(subscription and subscription.expiry)
		or normalizeExpiryValue(info and info.expiry)
		or normalizeExpiryValue(response and response.expiry)
end

local function errorMessage(response)
    if isBanned(response) then return "Esta key está banida no KeyAuth." end
    if isExpired(response) then return "Esta key expirou." end
    local text = responseText(response)
    if text:find("invalid", 1, true)
        or text:find("not found", 1, true)
        or text:find("não encontrada", 1, true)
        or text:find("unauthorized", 1, true) then
        return "Esta key não está cadastrada ou é inválida."
    end
    return tostring(response and response.message or "Não foi possível validar esta key.")
end

--// Tela de login refinada com partículas caindo ao fundo.
local previousLoginGui = playerGui:FindFirstChild("AngellBypassLogin")
if previousLoginGui then previousLoginGui:Destroy() end

local loginGui = Instance.new("ScreenGui")
loginGui.Name = "AngellBypassLogin"
loginGui.ResetOnSpawn = false
loginGui.IgnoreGuiInset = true
loginGui.DisplayOrder = 50
loginGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
loginGui.Parent = playerGui

local loginBackdrop = Instance.new("Frame")
loginBackdrop.Name = "Backdrop"
loginBackdrop.Size = UDim2.fromScale(1, 1)
loginBackdrop.BackgroundColor3 = Color3.fromRGB(5, 7, 12)
loginBackdrop.BackgroundTransparency = 0.16
loginBackdrop.BorderSizePixel = 0
loginBackdrop.ZIndex = 1
loginBackdrop.Parent = loginGui
local backdropGradient = Instance.new("UIGradient")
backdropGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 18, 32)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(5, 7, 12)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 10, 24)),
})
backdropGradient.Rotation = 35
backdropGradient.Parent = loginBackdrop

local loginParticles = Instance.new("Frame")
loginParticles.Name = "FallingParticles"
loginParticles.Size = UDim2.fromScale(1, 1)
loginParticles.BackgroundTransparency = 1
loginParticles.BorderSizePixel = 0
loginParticles.ClipsDescendants = true
loginParticles.Active = false
loginParticles.ZIndex = 2
loginParticles.Parent = loginGui

local loginRandom = Random.new()
local loginParticleRecords = {}
local initialCamera = workspace.CurrentCamera
local initialViewport = initialCamera and initialCamera.ViewportSize or Vector2.new(1280, 720)
for index = 1, 42 do
	local size = loginRandom:NextNumber(1.5, 4)
	local dot = Instance.new("Frame")
	dot.Name = "FallingDot" .. index
	dot.Size = UDim2.fromOffset(size, size)
	dot.Position = UDim2.fromOffset(
		loginRandom:NextNumber(0, initialViewport.X),
		loginRandom:NextNumber(-initialViewport.Y, initialViewport.Y)
	)
	dot.BackgroundColor3 = Color3.fromRGB(194, 215, 255)
	dot.BackgroundTransparency = loginRandom:NextNumber(0.28, 0.72)
	dot.BorderSizePixel = 0
	dot.Active = false
	dot.ZIndex = 2
	dot.Parent = loginParticles
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = dot
	table.insert(loginParticleRecords, {
		object = dot,
		x = dot.Position.X.Offset,
		y = dot.Position.Y.Offset,
		size = size,
		speed = loginRandom:NextNumber(16, 42),
		drift = loginRandom:NextNumber(-8, 8),
	})
end

local loginFrame = Instance.new("Frame")
loginFrame.Name = "LoginCard"
loginFrame.Size = UDim2.fromOffset(420, 292)
loginFrame.AnchorPoint = Vector2.new(0.5, 0.5)
loginFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
loginFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 25)
loginFrame.BackgroundTransparency = 0.04
loginFrame.BorderSizePixel = 0
loginFrame.ZIndex = 10
loginFrame.Parent = loginGui
loginFrame.Active = true
loginFrame.Draggable = true
local loginCorner = Instance.new("UICorner")
loginCorner.CornerRadius = UDim.new(0, 14)
loginCorner.Parent = loginFrame
local loginStroke = Instance.new("UIStroke")
loginStroke.Color = Color3.fromRGB(91, 112, 156)
loginStroke.Transparency = 0.32
loginStroke.Thickness = 1.2
loginStroke.Parent = loginFrame
local cardGradient = Instance.new("UIGradient")
cardGradient.Color = ColorSequence.new(Color3.fromRGB(23, 27, 38), Color3.fromRGB(12, 14, 20))
cardGradient.Rotation = 90
cardGradient.Parent = loginFrame

local topAccent = Instance.new("Frame")
topAccent.Name = "TopAccent"
topAccent.Size = UDim2.new(1, -2, 0, 3)
topAccent.Position = UDim2.fromOffset(1, 1)
topAccent.BackgroundColor3 = Color3.fromRGB(115, 166, 255)
topAccent.BorderSizePixel = 0
topAccent.ZIndex = 11
topAccent.Parent = loginFrame
local accentGradient = Instance.new("UIGradient")
accentGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 185, 255)),
	ColorSequenceKeypoint.new(0.55, Color3.fromRGB(133, 125, 255)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(82, 194, 221)),
})
accentGradient.Parent = topAccent

local logoBadge = Instance.new("Frame")
logoBadge.Size = UDim2.fromOffset(42, 42)
logoBadge.Position = UDim2.fromOffset(27, 25)
logoBadge.BackgroundColor3 = Color3.fromRGB(64, 104, 173)
logoBadge.BorderSizePixel = 0
logoBadge.ZIndex = 12
logoBadge.Parent = loginFrame
local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 12)
logoCorner.Parent = logoBadge
local logoGradient = Instance.new("UIGradient")
logoGradient.Color = ColorSequence.new(Color3.fromRGB(107, 164, 255), Color3.fromRGB(104, 91, 218))
logoGradient.Rotation = 45
logoGradient.Parent = logoBadge
local logoLetter = Instance.new("TextLabel")
logoLetter.Size = UDim2.fromScale(1, 1)
logoLetter.BackgroundTransparency = 1
logoLetter.Text = "A"
logoLetter.TextColor3 = Color3.fromRGB(255, 255, 255)
logoLetter.TextSize = 22
logoLetter.Font = Enum.Font.GothamBlack
logoLetter.ZIndex = 13
logoLetter.Parent = logoBadge

local loginTitle = Instance.new("TextLabel")
loginTitle.Size = UDim2.new(1, -105, 0, 30)
loginTitle.Position = UDim2.fromOffset(82, 24)
loginTitle.BackgroundTransparency = 1
loginTitle.Text = "ANGELL BYPASS"
loginTitle.TextColor3 = Color3.fromRGB(246, 248, 255)
loginTitle.TextSize = 20
loginTitle.Font = Enum.Font.GothamBold
loginTitle.TextXAlignment = Enum.TextXAlignment.Left
loginTitle.ZIndex = 12
loginTitle.Parent = loginFrame

local loginSubtitle = Instance.new("TextLabel")
loginSubtitle.Size = UDim2.new(1, -105, 0, 22)
loginSubtitle.Position = UDim2.fromOffset(83, 53)
loginSubtitle.BackgroundTransparency = 1
loginSubtitle.Text = "PAINEL DE ACESSO  /  LICENÇA"
loginSubtitle.TextColor3 = Color3.fromRGB(145, 155, 178)
loginSubtitle.TextSize = 10
loginSubtitle.Font = Enum.Font.GothamMedium
loginSubtitle.TextXAlignment = Enum.TextXAlignment.Left
loginSubtitle.ZIndex = 12
loginSubtitle.Parent = loginFrame

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(1, -60, 0, 18)
keyLabel.Position = UDim2.fromOffset(30, 91)
keyLabel.BackgroundTransparency = 1
keyLabel.Text = "CHAVE DE LICENÇA"
keyLabel.TextColor3 = Color3.fromRGB(182, 191, 211)
keyLabel.TextSize = 11
keyLabel.Font = Enum.Font.GothamBold
keyLabel.TextXAlignment = Enum.TextXAlignment.Left
keyLabel.ZIndex = 12
keyLabel.Parent = loginFrame

local keyBox = Instance.new("TextBox")
keyBox.Name = "LicenseKey"
keyBox.Size = UDim2.new(1, -60, 0, 46)
keyBox.Position = UDim2.fromOffset(30, 113)
keyBox.BackgroundColor3 = Color3.fromRGB(9, 11, 16)
keyBox.BorderSizePixel = 0
keyBox.PlaceholderText = "Cole sua key aqui..."
keyBox.PlaceholderColor3 = Color3.fromRGB(105, 115, 138)
keyBox.Text = ""
keyBox.ClearTextOnFocus = false
keyBox.TextColor3 = Color3.fromRGB(245, 247, 252)
keyBox.TextSize = 14
keyBox.Font = Enum.Font.Gotham
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.ZIndex = 12
keyBox.Parent = loginFrame
local keyPadding = Instance.new("UIPadding")
keyPadding.PaddingLeft = UDim.new(0, 14)
keyPadding.PaddingRight = UDim.new(0, 12)
keyPadding.Parent = keyBox
local keyCorner = Instance.new("UICorner")
keyCorner.CornerRadius = UDim.new(0, 8)
keyCorner.Parent = keyBox
local keyStroke = Instance.new("UIStroke")
keyStroke.Color = Color3.fromRGB(58, 67, 86)
keyStroke.Transparency = 0.2
keyStroke.Thickness = 1
keyStroke.Parent = keyBox
keyBox.Focused:Connect(function()
	TweenService:Create(keyStroke, TweenInfo.new(0.16), {Color = Color3.fromRGB(120, 164, 255), Transparency = 0}):Play()
end)
keyBox.FocusLost:Connect(function()
	TweenService:Create(keyStroke, TweenInfo.new(0.16), {Color = Color3.fromRGB(58, 67, 86), Transparency = 0.2}):Play()
end)

local loginStatus = Instance.new("TextLabel")
loginStatus.Name = "LoginStatus"
loginStatus.Size = UDim2.new(1, -60, 0, 22)
loginStatus.Position = UDim2.fromOffset(30, 166)
loginStatus.BackgroundTransparency = 1
loginStatus.Text = "Insira a chave gerada para continuar"
loginStatus.TextColor3 = Color3.fromRGB(151, 161, 182)
loginStatus.TextSize = 11
loginStatus.Font = Enum.Font.Gotham
loginStatus.TextXAlignment = Enum.TextXAlignment.Left
loginStatus.TextTruncate = Enum.TextTruncate.AtEnd
loginStatus.ZIndex = 12
loginStatus.Parent = loginFrame

local loginButton = Instance.new("TextButton")
loginButton.Name = "EnterButton"
loginButton.Size = UDim2.new(1, -60, 0, 43)
loginButton.Position = UDim2.fromOffset(30, 204)
loginButton.BackgroundColor3 = Color3.fromRGB(225, 233, 250)
loginButton.BorderSizePixel = 0
loginButton.Text = "ENTRAR"
loginButton.TextColor3 = Color3.fromRGB(15, 20, 31)
loginButton.TextSize = 13
loginButton.Font = Enum.Font.GothamBold
loginButton.AutoButtonColor = false
loginButton.ZIndex = 12
loginButton.Parent = loginFrame
local loginButtonCorner = Instance.new("UICorner")
loginButtonCorner.CornerRadius = UDim.new(0, 8)
loginButtonCorner.Parent = loginButton
local loginButtonGradient = Instance.new("UIGradient")
loginButtonGradient.Color = ColorSequence.new(Color3.fromRGB(245, 247, 255), Color3.fromRGB(184, 207, 245))
loginButtonGradient.Rotation = 90
loginButtonGradient.Parent = loginButton
loginButton.MouseEnter:Connect(function()
	TweenService:Create(loginButton, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(255, 255, 255)}):Play()
end)
loginButton.MouseLeave:Connect(function()
	TweenService:Create(loginButton, TweenInfo.new(0.14), {BackgroundColor3 = Color3.fromRGB(225, 233, 250)}):Play()
end)

local loginHint = Instance.new("TextLabel")
loginHint.Size = UDim2.new(1, -60, 0, 18)
loginHint.Position = UDim2.fromOffset(30, 258)
loginHint.BackgroundTransparency = 1
loginHint.Text = "Acesso protegido  •  Pressione INSERT para ocultar"
loginHint.TextColor3 = Color3.fromRGB(107, 117, 139)
loginHint.TextSize = 10
loginHint.Font = Enum.Font.Gotham
loginHint.TextXAlignment = Enum.TextXAlignment.Center
loginHint.ZIndex = 12
loginHint.Parent = loginFrame

local loginScale = Instance.new("UIScale")
loginScale.Scale = 0.94
loginScale.Parent = loginFrame
TweenService:Create(loginScale, TweenInfo.new(0.42, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Scale = 1}):Play()

local loginParticleConnection
loginParticleConnection = RunService.RenderStepped:Connect(function(deltaTime)
	if not loginGui.Parent then
		if loginParticleConnection then loginParticleConnection:Disconnect() end
		return
	end
	if not loginGui.Enabled then return end
	local currentCamera = workspace.CurrentCamera
	local viewport = currentCamera and currentCamera.ViewportSize or initialViewport
	local width, height = viewport.X, viewport.Y
	local step = math.min(deltaTime, 0.05)
	for _, particle in ipairs(loginParticleRecords) do
		particle.y += particle.speed * step
		particle.x += particle.drift * step
		particle.x = math.clamp(particle.x, 0, math.max(width - particle.size, 0))
		if particle.y > height + particle.size then
			particle.y = -particle.size
			particle.x = loginRandom:NextNumber(0, math.max(width - particle.size, 0))
		end
		particle.object.Position = UDim2.fromOffset(particle.x, particle.y)
	end
end)

local validating = false
UserInputService.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard
		and input.KeyCode == Enum.KeyCode.Insert
		and loginGui.Parent then
		loginGui.Enabled = not loginGui.Enabled
		if loginGui.Enabled then
			keyBox:CaptureFocus()
		end
	end
end)

loginButton.MouseButton1Click:Connect(function()
    if validating then return end
    local enteredKey = keyBox.Text:gsub("^%s*(.-)%s*$", "%1")
    if enteredKey == "" then
        loginStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
        loginStatus.Text = "Escreva uma chave primeiro!"
        return
    end

    validating = true
    loginButton.AutoButtonColor = false
    loginStatus.TextColor3 = Color3.fromRGB(255, 255, 255)
    loginStatus.Text = "A validar chave..."

    local initRes = requestApi({ type = "init", ver = "1.0" })
    if not isApiSuccess(initRes) then
        validating = false
        loginButton.AutoButtonColor = true
        loginStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
        loginStatus.Text = "Erro de conexão com KeyAuth"
        return
    end

    local loginRes = requestApi({
        type = "license",
        key = enteredKey,
        sessionid = initRes.sessionid,
        ver = "1.0",
    })

    if not isApiSuccess(loginRes) or isBanned(loginRes) or isExpired(loginRes) then
        validating = false
        loginButton.AutoButtonColor = true
        loginStatus.TextColor3 = Color3.fromRGB(255, 90, 90)
        loginStatus.Text = errorMessage(loginRes)
        return
    end

	if loginParticleConnection then
		loginParticleConnection:Disconnect()
		loginParticleConnection = nil
	end
	loginGui:Destroy()
	buildPanel(getLicenseUser(loginRes), getLicenseExpiry(loginRes))
end)
