-- ULTRA FIX LAG + LOADING UI
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ===== LOADING UI =====
local loadGui = Instance.new("ScreenGui", playerGui)
loadGui.Name = "BeeZLoading"
loadGui.ResetOnSpawn = false

local frame = Instance.new("Frame", loadGui)
frame.Size = UDim2.new(0, 300, 0, 120)
frame.Position = UDim2.new(0.5, -150, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Thickness = 2

local gradient = Instance.new("UIGradient", stroke)
gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0)),
})

local titleLabel = Instance.new("TextLabel", frame)
titleLabel.Size = UDim2.new(1, 0, 0, 35)
titleLabel.Position = UDim2.new(0, 0, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "⚡ BeeZ Fix Lag"
titleLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20

local statusLabel = Instance.new("TextLabel", frame)
statusLabel.Size = UDim2.new(1, 0, 0, 20)
statusLabel.Position = UDim2.new(0, 0, 0, 40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Đang khởi động..."
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 13

local barBg = Instance.new("Frame", frame)
barBg.Size = UDim2.new(0.85, 0, 0, 10)
barBg.Position = UDim2.new(0.075, 0, 0, 68)
barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
barBg.BorderSizePixel = 0
Instance.new("UICorner", barBg).CornerRadius = UDim.new(1, 0)

local barFill = Instance.new("Frame", barBg)
barFill.Size = UDim2.new(0, 0, 1, 0)
barFill.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
barFill.BorderSizePixel = 0
Instance.new("UICorner", barFill).CornerRadius = UDim.new(1, 0)

local pctLabel = Instance.new("TextLabel", frame)
pctLabel.Size = UDim2.new(1, 0, 0, 20)
pctLabel.Position = UDim2.new(0, 0, 0, 90)
pctLabel.BackgroundTransparency = 1
pctLabel.Text = "0%"
pctLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
pctLabel.Font = Enum.Font.GothamBold
pctLabel.TextSize = 13

task.spawn(function()
    local r = 0
    while loadGui.Parent do
        r = (r + 3) % 360
        gradient.Rotation = r
        task.wait(0.01)
    end
end)

-- ===== FIX LAG =====
local function doFixLag()
    statusLabel.Text = "Đang xử lý Lighting..."
    task.wait(0.1)

    Lighting.GlobalShadows = false
    Lighting.FogEnd = 100000
    Lighting.FogStart = 100000
    Lighting.Brightness = 2
    Lighting.Ambient = Color3.fromRGB(178, 178, 178)
    Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
    Lighting.ShadowSoftness = 0

    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere")
        or v:IsA("BloomEffect") or v:IsA("BlurEffect")
        or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect")
        or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end

    statusLabel.Text = "Đang xóa Texture & Effect..."
    task.wait(0.1)

    local function ultraClean(obj)
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
        or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
        or obj:IsA("SelectionBox") or obj:IsA("SelectionSphere")
        or obj:IsA("SurfaceAppearance") then
            pcall(function() obj:Destroy() end)
            return
        end
        if obj:IsA("Texture") or obj:IsA("Decal") then
            pcall(function() obj:Destroy() end)
            return
        end
        if obj:IsA("BasePart") then
            pcall(function()
                obj.CastShadow = false
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end)
            return
        end
        if obj:IsA("SpecialMesh") then
            pcall(function() obj.TextureId = "" end)
            return
        end
    end

    local descendants = workspace:GetDescendants()
    local total = #descendants

    for i, obj in ipairs(descendants) do
        ultraClean(obj)
        if i % 500 == 0 then
            local pct = math.floor(i / total * 100)
            barFill.Size = UDim2.new(pct / 100, 0, 1, 0)
            pctLabel.Text = pct .. "%"
            task.wait()
        end
    end

    barFill.Size = UDim2.new(1, 0, 1, 0)
    pctLabel.Text = "100%"

    workspace.DescendantAdded:Connect(function(obj)
        task.defer(function() ultraClean(obj) end)
    end)

    statusLabel.Text = "✅ Hoàn tất!"
    task.wait(0.5)

    local tween = TweenService:Create(frame, TweenInfo.new(0.4), {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 300, 0, 0)
    })
    TweenService:Create(titleLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(statusLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(pctLabel, TweenInfo.new(0.4), {TextTransparency = 1}):Play()
    TweenService:Create(stroke, TweenInfo.new(0.4), {Transparency = 1}):Play()
    tween:Play()
    tween.Completed:Wait()
    loadGui:Destroy()

    -- ===== FPS UI =====
    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "FPS_UI"
    screenGui.ResetOnSpawn = false

    local fpsFrame = Instance.new("Frame", screenGui)
    fpsFrame.Size = UDim2.new(0, 90, 0, 28)
    fpsFrame.Position = UDim2.new(0, 10, 0, 10)
    fpsFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fpsFrame.BackgroundTransparency = 0.3
    fpsFrame.Active = true
    fpsFrame.Draggable = true
    Instance.new("UICorner", fpsFrame).CornerRadius = UDim.new(0, 6)
    local fpsStroke = Instance.new("UIStroke", fpsFrame)
    fpsStroke.Color = Color3.fromRGB(255, 215, 0)
    fpsStroke.Thickness = 1.5

    local fpsLabel = Instance.new("TextLabel", fpsFrame)
    fpsLabel.Size = UDim2.new(1, 0, 1, 0)
    fpsLabel.BackgroundTransparency = 1
    fpsLabel.Font = Enum.Font.GothamBold
    fpsLabel.TextSize = 13

    local frameList = {}
    RunService.RenderStepped:Connect(function(dt)
        table.insert(frameList, dt)
        if #frameList > 30 then table.remove(frameList, 1) end
    end)

    task.spawn(function()
        while true do
            local sum = 0
            for _, v in ipairs(frameList) do sum += v end
            local fps = #frameList > 0 and math.floor(1 / (sum / #frameList)) or 0
            local color
            if fps >= 50 then
                color = Color3.fromRGB(0, 255, 100)
            elseif fps >= 30 then
                color = Color3.fromRGB(255, 165, 0)
            else
                color = Color3.fromRGB(255, 60, 60)
            end
            fpsLabel.TextColor3 = color
            fpsLabel.Text = "FPS: " .. fps
            task.wait(0.5)
        end
    end)

    -- ===== LOAD NOTE + JOBJID UI =====
    local Players2 = game:GetService("Players")
    local player2 = Players2.LocalPlayer
    local playerGui2 = player2:WaitForChild("PlayerGui")
    local RunService2 = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local UIS = game:GetService("UserInputService")
    local MarketplaceService = game:GetService("MarketplaceService")
    local TeleportService = game:GetService("TeleportService")

    local fileName = "note_save.txt"
    if isfile and isfile(fileName) then
        getgenv().SavedText = readfile(fileName)
    else
        getgenv().SavedText = ""
    end

    local function getGameName()
        local name = "Unknown Game"
        pcall(function()
            name = MarketplaceService:GetProductInfo(game.PlaceId).Name
        end)
        return name
    end

    local Images = {}
    pcall(function() Images = require(script.Parent.id) end)

    local gui = Instance.new("ScreenGui", playerGui2)
    gui.Name = "BangdonUI"

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, 400, 0, 180)
    main.Position = UDim2.new(0.5, 0, 0.4, 0)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    main.BackgroundTransparency = 0.4
    main.Active = true
    main.Draggable = true
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

    local MainStroke = Instance.new("UIStroke", main)
    MainStroke.Thickness = 2
    MainStroke.Transparency = 0.1
    MainStroke.Color = Color3.fromRGB(255, 215, 0)

    local mainGrad = Instance.new("UIGradient", MainStroke)
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0))
    })

    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    titleBar.BackgroundTransparency = 0.8
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local logo = Instance.new("ImageLabel", titleBar)
    logo.Size = UDim2.new(0, 24, 0, 24)
    logo.Position = UDim2.new(0, 10, 0.5, -12)
    logo.BackgroundTransparency = 1
    logo.Image = Images["activity"] or ""
    logo.ImageColor3 = Color3.fromRGB(255, 215, 0)

    local titleText = Instance.new("TextLabel", titleBar)
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 40, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "BeeZ Notes"
    titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left

    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(1, 0, 0, 30)
    bar.Position = UDim2.new(0, 0, 0, 35)
    bar.BackgroundTransparency = 1

    local tabs = {"Note", "Status", "Setting", "Job ID"}
    local tabIcons = {"book", "activity", "settings", "activity"}
    local pages = {}
    local buttons = {}

    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -20, 1, -80)
    container.Position = UDim2.new(0, 10, 0, 65)
    container.BackgroundTransparency = 1

    for i, v in ipairs(tabs) do
        local b = Instance.new("TextButton", bar)
        b.Size = UDim2.new(1/4, 0, 1, 0)
        b.Position = UDim2.new((i-1)/4, 0, 0, 0)
        b.Text = v
        b.BackgroundTransparency = 1
        b.TextColor3 = Color3.fromRGB(180, 180, 180)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11

        local icon = Instance.new("ImageLabel", b)
        icon.Size = UDim2.new(0, 14, 0, 14)
        icon.Position = UDim2.new(0.5, -35, 0.5, -7)
        icon.BackgroundTransparency = 1
        icon.Image = Images[tabIcons[i]] or ""
        icon.ImageColor3 = Color3.fromRGB(180, 180, 180)

        local p = Instance.new("Frame", container)
        p.Size = UDim2.new(1, 0, 1, 0)
        p.Visible = false
        p.BackgroundTransparency = 1

        buttons[i] = b
        pages[i] = p
    end

    -- PAGE 1: NOTE
    local statusStates = {
        {text = "Trạng thái: Chưa cày",   color = Color3.fromRGB(200, 50, 50)},
        {text = "Trạng thái: Đang cày",   color = Color3.fromRGB(220, 160, 0)},
        {text = "Trạng thái: Hoàn thành", color = Color3.fromRGB(50, 190, 80)},
    }
    local currentStatus = 1

    local statusBtn = Instance.new("TextButton", pages[1])
    statusBtn.Size = UDim2.new(1, 0, 0, 26)
    statusBtn.Position = UDim2.new(0, 0, 0, 0)
    statusBtn.BackgroundColor3 = statusStates[1].color
    statusBtn.Text = statusStates[1].text
    statusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusBtn.Font = Enum.Font.GothamBold
    statusBtn.TextSize = 13
    statusBtn.BorderSizePixel = 0
    Instance.new("UICorner", statusBtn).CornerRadius = UDim.new(0, 8)

    statusBtn.MouseButton1Click:Connect(function()
        currentStatus = (currentStatus % #statusStates) + 1
        statusBtn.BackgroundColor3 = statusStates[currentStatus].color
        statusBtn.Text = statusStates[currentStatus].text
    end)

    local nameLabel = Instance.new("TextLabel", pages[1])
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.Position = UDim2.new(0, 0, 0, 30)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "👤 Tên : " .. player2.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14

    local input = Instance.new("TextBox", pages[1])
    input.Position = UDim2.new(0, 0, 0, 52)
    input.Size = UDim2.new(1, 0, 1, -52)
    input.BackgroundTransparency = 1
    input.PlaceholderText = "GHI DON VAO DAY"
    input.Text = getgenv().SavedText
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 14
    input.ClearTextOnFocus = false
    input.TextWrapped = true
    input.MultiLine = true

    input.FocusLost:Connect(function()
        getgenv().SavedText = input.Text
        if writefile then writefile(fileName, input.Text) end
    end)

    -- PAGE 2: STATUS
    local statusLbl = Instance.new("TextLabel", pages[2])
    statusLbl.Size = UDim2.new(1, 0, 1, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.TextColor3 = Color3.new(1, 1, 1)
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextSize = 14

    RunService2.RenderStepped:Connect(function()
        statusLbl.Text = "PlaceId: " .. game.PlaceId ..
            "\nPlayers: " .. #Players2:GetPlayers() ..
            "\nJobId: " .. game.JobId
        nameLabel.Text = "👤 Tên : " .. player2.Name
    end)

    -- PAGE 3: SETTING
    local setting = Instance.new("TextLabel", pages[3])
    setting.Size = UDim2.new(1, 0, 0.5, 0)
    setting.BackgroundTransparency = 1
    setting.Text = "💾 Auto Save: FILE"
    setting.TextColor3 = Color3.fromRGB(120, 255, 120)
    setting.Font = Enum.Font.GothamBold
    setting.TextSize = 14

    local copyJob = Instance.new("TextButton", pages[3])
    copyJob.Size = UDim2.new(0, 150, 0, 30)
    copyJob.Position = UDim2.new(0.5, -75, 0.6, 0)
    copyJob.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    copyJob.Text = "📋 Copy JobId"
    copyJob.TextColor3 = Color3.fromRGB(255, 215, 0)
    copyJob.Font = Enum.Font.GothamBold
    copyJob.TextSize = 14
    copyJob.BorderSizePixel = 0
    Instance.new("UICorner", copyJob).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", copyJob).Color = Color3.fromRGB(255, 215, 0)

    copyJob.MouseButton1Click:Connect(function()
        setclipboard(game.JobId)
        copyJob.Text = "✅ Copied!"
        task.wait(2)
        copyJob.Text = "📋 Copy JobId"
    end)

    -- PAGE 4: JOB ID
    local jobTitle = Instance.new("TextLabel", pages[4])
    jobTitle.Size = UDim2.new(1, 0, 0, 20)
    jobTitle.BackgroundTransparency = 1
    jobTitle.Text = "🔗 Join Server by JobId"
    jobTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    jobTitle.Font = Enum.Font.GothamBold
    jobTitle.TextSize = 12

    local JobIdInput = Instance.new("TextBox", pages[4])
    JobIdInput.Size = UDim2.new(1, 0, 0, 28)
    JobIdInput.Position = UDim2.new(0, 0, 0, 22)
    JobIdInput.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    JobIdInput.BackgroundTransparency = 0.6
    JobIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    JobIdInput.PlaceholderText = " Dán JobId vào đây..."
    JobIdInput.Text = ""
    JobIdInput.Font = Enum.Font.Gotham
    JobIdInput.TextSize = 11
    JobIdInput.ClearTextOnFocus = false
    JobIdInput.BorderSizePixel = 0
    Instance.new("UICorner", JobIdInput).CornerRadius = UDim.new(0, 6)
    local jobIdStroke = Instance.new("UIStroke", JobIdInput)
    jobIdStroke.Color = Color3.fromRGB(255, 215, 0)
    jobIdStroke.Thickness = 1

    local JoinBtn = Instance.new("TextButton", pages[4])
    JoinBtn.Size = UDim2.new(0.48, 0, 0, 28)
    JoinBtn.Position = UDim2.new(0, 0, 0, 54)
    JoinBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    JoinBtn.BackgroundTransparency = 0.2
    JoinBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    JoinBtn.Text = "Join Server"
    JoinBtn.Font = Enum.Font.GothamBold
    JoinBtn.TextSize = 11
    JoinBtn.BorderSizePixel = 0
    Instance.new("UICorner", JoinBtn).CornerRadius = UDim.new(0, 6)

    local CopyBtn = Instance.new("TextButton", pages[4])
    CopyBtn.Size = UDim2.new(0.48, 0, 0, 28)
    CopyBtn.Position = UDim2.new(0.52, 0, 0, 54)
    CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    CopyBtn.BackgroundTransparency = 0.2
    CopyBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    CopyBtn.Text = "Copy JobId"
    CopyBtn.Font = Enum.Font.GothamBold
    CopyBtn.TextSize = 11
    CopyBtn.BorderSizePixel = 0
    Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 6)

    JoinBtn.MouseButton1Click:Connect(function()
        local targetJobId = JobIdInput.Text
        if targetJobId ~= "" and targetJobId ~= game.JobId then
            JoinBtn.Text = "Đang chuyển..."
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, targetJobId, player2)
            end)
            task.wait(3)
            JoinBtn.Text = "Join Server"
        end
    end)

    CopyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(game.JobId)
            CopyBtn.Text = "Đã Copy!"
            task.wait(1.5)
            CopyBtn.Text = "Copy JobId"
        end
    end)

    -- SWITCH TAB
    local function switch(i)
        for k, v in ipairs(pages) do
            v.Visible = false
            buttons[k].TextColor3 = Color3.fromRGB(200, 200, 200)
            if buttons[k]:FindFirstChildOfClass("ImageLabel") then
                buttons[k]:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(180, 180, 180)
            end
        end
        pages[i].Visible = true
        buttons[i].TextColor3 = Color3.fromRGB(255, 215, 0)
        if buttons[i]:FindFirstChildOfClass("ImageLabel") then
            buttons[i]:FindFirstChildOfClass("ImageLabel").ImageColor3 = Color3.fromRGB(255, 215, 0)
        end
    end

    for i, b in ipairs(buttons) do
        b.MouseButton1Click:Connect(function() switch(i) end)
    end
    switch(1)

    -- TOGGLE
    local toggle = Instance.new("TextButton", gui)
    toggle.Size = UDim2.new(0, 60, 0, 60)
    toggle.Position = UDim2.new(1, -80, 1, -80)
    toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(1, 0)
    local toggleStroke = Instance.new("UIStroke", toggle)
    toggleStroke.Color = Color3.fromRGB(255, 215, 0)
    toggleStroke.Thickness = 2

    local toggleIcon = Instance.new("ImageLabel", toggle)
    toggleIcon.Size = UDim2.new(0, 40, 0, 40)
    toggleIcon.Position = UDim2.new(0.5, -20, 0.5, -20)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Image = Images["activity"] or ""
    toggleIcon.ImageColor3 = Color3.fromRGB(0, 0, 0)

    local dragging2 = false
    local startPos2, startFramePos2

    toggle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging2 = true
            startPos2 = i.Position
            startFramePos2 = toggle.Position
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if dragging2 and i.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = i.Position - startPos2
            toggle.Position = UDim2.new(
                startFramePos2.X.Scale,
                startFramePos2.X.Offset + delta.X,
                startFramePos2.Y.Scale,
                startFramePos2.Y.Offset + delta.Y
            )
        end
    end)

    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging2 = false
        end
    end)

    local visible = true
    toggle.MouseButton1Click:Connect(function()
        visible = not visible
        main.Visible = visible
    end)

    -- FPS + PING LABEL
    local statsLabel = Instance.new("TextLabel", gui)
    statsLabel.Position = UDim2.new(0, 10, 0, 60)
    statsLabel.Size = UDim2.new(0, 150, 0, 50)
    statsLabel.BackgroundTransparency = 1
    statsLabel.Font = Enum.Font.GothamBold
    statsLabel.TextSize = 16

    local frames2 = {}
    local smoothPing2 = 0
    local fps2 = 60
    local hue2 = 0

    RunService2.RenderStepped:Connect(function(dt)
        table.insert(frames2, dt)
        if #frames2 > 50 then table.remove(frames2, 1) end
    end)

    task.spawn(function()
        while true do
            local sum = 0
            for _, v in ipairs(frames2) do sum += v end
            if #frames2 > 0 then fps2 = math.floor(1 / (sum / #frames2)) end
            local ok, raw = pcall(function()
                return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            end)
            if ok then
                smoothPing2 = smoothPing2 + (raw - smoothPing2) * 0.05
            end
            hue2 = (hue2 + 0.02) % 1
            statsLabel.TextColor3 = Color3.fromHSV(hue2, 1, 1)
            statsLabel.Text = "FPS: " .. fps2 .. "\nPing: " .. math.floor(smoothPing2) .. " ms"
            task.wait(0.5)
        end
    end)

    local BloxFruits_IDs = {
        [27539155] = true, [2753915549] = true, [85211729168715] = true,
        [4442272187] = true, [4442272183] = true, [79091703265657] = true,
        [7449423635] = true, [100117331123089] = true
    }

    local MainScriptLink = "https://raw.githubusercontent.com/leduccuong01091987-collab/Chanbomayde/refs/heads/main/notify.lua"

    if BloxFruits_IDs[game.PlaceId] then
        print("Blox Fruits Detected! Loading main script...")
        task.spawn(function()
            local success, err = pcall(function()
                loadstring(game:HttpGet(MainScriptLink))()
            end)
            if not success then
                warn("Loi khi load script: " .. tostring(err))
            end
        end)
    end
end

task.spawn(doFixLag)
