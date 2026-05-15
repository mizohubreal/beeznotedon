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
            if fps >= 50 then color = Color3.fromRGB(0, 255, 100)
            elseif fps >= 30 then color = Color3.fromRGB(255, 165, 0)
            else color = Color3.fromRGB(255, 60, 60) end
            fpsLabel.TextColor3 = color
            fpsLabel.Text = "FPS: " .. fps
            task.wait(0.5)
        end
    end)

    -- ===== NOTE + JOBID UI =====
    local Players2 = game:GetService("Players")
    local player2 = Players2.LocalPlayer
    local playerGui2 = player2:WaitForChild("PlayerGui")
    local RunService2 = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local TeleportService = game:GetService("TeleportService")

    local fileName = "note_save.txt"
    if isfile and isfile(fileName) then
        getgenv().SavedText = readfile(fileName)
    else
        getgenv().SavedText = ""
    end

    -- ===== SIZE & COLOR CONFIG =====
    local sizeConfig = {
        ["Bình thường"] = {w = 400, h = 220},
        ["Trung bình"]  = {w = 320, h = 185},
        ["Nhỏ"]         = {w = 240, h = 155},
    }
    local currentSizeKey = "Bình thường"

    local themeColors = {
        ["Vàng"]   = Color3.fromRGB(255, 215, 0),
        ["Xanh lá"]= Color3.fromRGB(80, 220, 120),
        ["Xanh dương"]= Color3.fromRGB(60, 160, 255),
        ["Đỏ"]     = Color3.fromRGB(255, 80, 80),
        ["Tím"]    = Color3.fromRGB(180, 80, 255),
        ["Trắng"]  = Color3.fromRGB(255, 255, 255),
        ["Cam"]    = Color3.fromRGB(255, 140, 0),
        ["Hồng"]   = Color3.fromRGB(255, 100, 200),
    }
    local currentThemeKey = "Vàng"
    local currentThemeColor = themeColors[currentThemeKey]

    local gui = Instance.new("ScreenGui", playerGui2)
    gui.Name = "BangdonUI"
    gui.ResetOnSpawn = false

    local cfg = sizeConfig[currentSizeKey]
    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0, cfg.w, 0, cfg.h)
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
    MainStroke.Color = currentThemeColor

    local mainGrad = Instance.new("UIGradient", MainStroke)
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, currentThemeColor),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, currentThemeColor)
    })

    local titleBar = Instance.new("Frame", main)
    titleBar.Size = UDim2.new(1, 0, 0, 35)
    titleBar.BackgroundColor3 = currentThemeColor
    titleBar.BackgroundTransparency = 0.8
    titleBar.BorderSizePixel = 0
    Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)

    local titleText = Instance.new("TextLabel", titleBar)
    titleText.Size = UDim2.new(1, -20, 1, 0)
    titleText.Position = UDim2.new(0, 14, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "BeeZ Notes"
    titleText.TextColor3 = currentThemeColor
    titleText.Font = Enum.Font.GothamBold
    titleText.TextSize = 16
    titleText.TextXAlignment = Enum.TextXAlignment.Left

    -- ===== APPLY THEME FUNCTION =====
    local function applyTheme(color)
        currentThemeColor = color
        MainStroke.Color = color
        mainGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, color),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255,255,255)),
            ColorSequenceKeypoint.new(1, color)
        })
        titleBar.BackgroundColor3 = color
        titleText.TextColor3 = color
    end

    -- ===== APPLY SIZE FUNCTION =====
    local function applySize(key)
        currentSizeKey = key
        local c = sizeConfig[key]
        TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, c.w, 0, c.h)
        }):Play()
    end

    -- TABS
    local bar = Instance.new("Frame", main)
    bar.Size = UDim2.new(1, 0, 0, 28)
    bar.Position = UDim2.new(0, 0, 0, 35)
    bar.BackgroundTransparency = 1

    -- 5 tabs: Note / Status / Setting / Job ID / UI
    local tabs = {"Note", "Status", "Setting", "Job ID", "UI"}
    local pages = {}
    local buttons = {}

    local container = Instance.new("Frame", main)
    container.Size = UDim2.new(1, -20, 1, -75)
    container.Position = UDim2.new(0, 10, 0, 63)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true

    for i, v in ipairs(tabs) do
        local b = Instance.new("TextButton", bar)
        b.Size = UDim2.new(1/#tabs, 0, 1, 0)
        b.Position = UDim2.new((i-1)/#tabs, 0, 0, 0)
        b.Text = v
        b.BackgroundTransparency = 1
        b.TextColor3 = Color3.fromRGB(180, 180, 180)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 10

        local p = Instance.new("ScrollingFrame", container)
        p.Size = UDim2.new(1, 0, 1, 0)
        p.Visible = false
        p.BackgroundTransparency = 1
        p.ScrollBarThickness = 2
        p.ScrollBarImageColor3 = Color3.fromRGB(255, 215, 0)
        p.CanvasSize = UDim2.new(0, 0, 0, 0)

        buttons[i] = b
        pages[i] = p
    end

    -- ===== PAGE 1: NOTE =====
    local statusStates = {
        {text = "🔴 Chưa cày",    color = Color3.fromRGB(200, 50, 50)},
        {text = "🟡 Đang cày",    color = Color3.fromRGB(220, 160, 0)},
        {text = "🟢 Hoàn thành",  color = Color3.fromRGB(50, 190, 80)},
    }
    local currentStatus = 1

    local statusBtn = Instance.new("TextButton", pages[1])
    statusBtn.Size = UDim2.new(1, 0, 0, 26)
    statusBtn.Position = UDim2.new(0, 0, 0, 0)
    statusBtn.BackgroundColor3 = statusStates[1].color
    statusBtn.Text = statusStates[1].text
    statusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusBtn.Font = Enum.Font.GothamBold
    statusBtn.TextSize = 12
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
    nameLabel.Text = "👤 " .. player2.Name
    nameLabel.TextColor3 = Color3.new(1, 1, 1)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 13

    local input = Instance.new("TextBox", pages[1])
    input.Position = UDim2.new(0, 0, 0, 54)
    input.Size = UDim2.new(1, 0, 0, 120)
    input.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    input.BackgroundTransparency = 0.5
    input.PlaceholderText = "GHI CHÚ VÀO ĐÂY..."
    input.Text = getgenv().SavedText
    input.TextColor3 = Color3.new(1, 1, 1)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 13
    input.ClearTextOnFocus = false
    input.TextWrapped = true
    input.MultiLine = true
    input.TextXAlignment = Enum.TextXAlignment.Left
    input.TextYAlignment = Enum.TextYAlignment.Top
    input.BorderSizePixel = 0
    Instance.new("UICorner", input).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", input).Color = Color3.fromRGB(255, 215, 0)

    input.FocusLost:Connect(function()
        getgenv().SavedText = input.Text
        if writefile then writefile(fileName, input.Text) end
    end)

    pages[1].CanvasSize = UDim2.new(0, 0, 0, 180)

    -- ===== PAGE 2: STATUS =====
    local statusLbl = Instance.new("TextLabel", pages[2])
    statusLbl.Size = UDim2.new(1, 0, 0, 80)
    statusLbl.BackgroundTransparency = 1
    statusLbl.TextColor3 = Color3.new(1, 1, 1)
    statusLbl.Font = Enum.Font.GothamBold
    statusLbl.TextSize = 13
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left

    RunService2.RenderStepped:Connect(function()
        statusLbl.Text = "PlaceId: " .. game.PlaceId ..
            "\nPlayers: " .. #Players2:GetPlayers() ..
            "\nJobId: " .. string.sub(game.JobId, 1, 24) .. "..."
        nameLabel.Text = "👤 " .. player2.Name
    end)

    -- ===== PAGE 3: SETTING =====
    local settingLbl = Instance.new("TextLabel", pages[3])
    settingLbl.Size = UDim2.new(1, 0, 0, 22)
    settingLbl.BackgroundTransparency = 1
    settingLbl.Text = "💾 Auto Save: FILE"
    settingLbl.TextColor3 = Color3.fromRGB(120, 255, 120)
    settingLbl.Font = Enum.Font.GothamBold
    settingLbl.TextSize = 13
    settingLbl.TextXAlignment = Enum.TextXAlignment.Left

    local copyJob3 = Instance.new("TextButton", pages[3])
    copyJob3.Size = UDim2.new(1, 0, 0, 28)
    copyJob3.Position = UDim2.new(0, 0, 0, 26)
    copyJob3.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    copyJob3.Text = "📋 Copy JobId"
    copyJob3.TextColor3 = Color3.fromRGB(255, 215, 0)
    copyJob3.Font = Enum.Font.GothamBold
    copyJob3.TextSize = 12
    copyJob3.BorderSizePixel = 0
    Instance.new("UICorner", copyJob3).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", copyJob3).Color = Color3.fromRGB(255, 215, 0)

    copyJob3.MouseButton1Click:Connect(function()
        setclipboard(game.JobId)
        copyJob3.Text = "✅ Copied!"
        task.wait(2)
        copyJob3.Text = "📋 Copy JobId"
    end)

    pages[3].CanvasSize = UDim2.new(0, 0, 0, 60)

    -- ===== PAGE 4: JOB ID =====
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
    JobIdInput.BackgroundTransparency = 0.5
    JobIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    JobIdInput.PlaceholderText = " Dán JobId vào đây..."
    JobIdInput.Text = ""
    JobIdInput.Font = Enum.Font.Gotham
    JobIdInput.TextSize = 11
    JobIdInput.ClearTextOnFocus = false
    JobIdInput.BorderSizePixel = 0
    Instance.new("UICorner", JobIdInput).CornerRadius = UDim.new(0, 6)
    local jStroke = Instance.new("UIStroke", JobIdInput)
    jStroke.Color = Color3.fromRGB(255, 215, 0)

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

    local CopyBtn4 = Instance.new("TextButton", pages[4])
    CopyBtn4.Size = UDim2.new(0.48, 0, 0, 28)
    CopyBtn4.Position = UDim2.new(0.52, 0, 0, 54)
    CopyBtn4.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
    CopyBtn4.BackgroundTransparency = 0.2
    CopyBtn4.TextColor3 = Color3.fromRGB(0, 0, 0)
    CopyBtn4.Text = "Copy JobId"
    CopyBtn4.Font = Enum.Font.GothamBold
    CopyBtn4.TextSize = 11
    CopyBtn4.BorderSizePixel = 0
    Instance.new("UICorner", CopyBtn4).CornerRadius = UDim.new(0, 6)

    JoinBtn.MouseButton1Click:Connect(function()
        local id = JobIdInput.Text
        if id ~= "" and id ~= game.JobId then
            JoinBtn.Text = "Đang chuyển..."
            pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, id, player2)
            end)
            task.wait(3)
            JoinBtn.Text = "Join Server"
        end
    end)

    CopyBtn4.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(game.JobId)
            CopyBtn4.Text = "✅ Copied!"
            task.wait(1.5)
            CopyBtn4.Text = "Copy JobId"
        end
    end)

    pages[4].CanvasSize = UDim2.new(0, 0, 0, 90)

    -- ===== PAGE 5: UI (Kích cỡ + Màu sắc) =====
    -- SECTION: Kích cỡ
    local sizeTitle = Instance.new("TextLabel", pages[5])
    sizeTitle.Size = UDim2.new(1, 0, 0, 20)
    sizeTitle.Position = UDim2.new(0, 0, 0, 0)
    sizeTitle.BackgroundTransparency = 1
    sizeTitle.Text = "📐 Kích cỡ UI Note"
    sizeTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    sizeTitle.Font = Enum.Font.GothamBold
    sizeTitle.TextSize = 12
    sizeTitle.TextXAlignment = Enum.TextXAlignment.Left

    local sizeKeys = {"Bình thường", "Trung bình", "Nhỏ"}
    local sizeIcons = {"📦", "📋", "🔹"}

    for i, key in ipairs(sizeKeys) do
        local btn = Instance.new("TextButton", pages[5])
        btn.Size = UDim2.new(1/3, -3, 0, 28)
        btn.Position = UDim2.new((i-1)/3, i==1 and 0 or 2, 0, 22)
        btn.Text = sizeIcons[i] .. " " .. key
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 10
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

        local function refreshSizeBtns()
            for j, k in ipairs(sizeKeys) do
                -- will be set below
            end
        end

        local szStr = Instance.new("UIStroke", btn)

        local function updateSizeBtn()
            if currentSizeKey == key then
                btn.BackgroundColor3 = currentThemeColor
                btn.BackgroundTransparency = 0.1
                btn.TextColor3 = Color3.fromRGB(0, 0, 0)
                szStr.Color = currentThemeColor
            else
                btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                btn.BackgroundTransparency = 0.3
                btn.TextColor3 = Color3.fromRGB(200, 200, 200)
                szStr.Color = Color3.fromRGB(80, 80, 80)
            end
        end

        updateSizeBtn()

        btn.MouseButton1Click:Connect(function()
            applySize(key)
            -- refresh all size buttons
            for _, child in ipairs(pages[5]:GetChildren()) do
                if child:IsA("TextButton") and child:FindFirstChildOfClass("UIStroke") then
                    -- handled by their own connections
                end
            end
            updateSizeBtn()
        end)
    end

    -- Divider
    local div = Instance.new("Frame", pages[5])
    div.Size = UDim2.new(1, 0, 0, 1)
    div.Position = UDim2.new(0, 0, 0, 56)
    div.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
    div.BorderSizePixel = 0

    -- SECTION: Màu sắc
    local colorTitle = Instance.new("TextLabel", pages[5])
    colorTitle.Size = UDim2.new(1, 0, 0, 18)
    colorTitle.Position = UDim2.new(0, 0, 0, 62)
    colorTitle.BackgroundTransparency = 1
    colorTitle.Text = "🎨 Màu sắc UI"
    colorTitle.TextColor3 = Color3.fromRGB(255, 215, 0)
    colorTitle.Font = Enum.Font.GothamBold
    colorTitle.TextSize = 12
    colorTitle.TextXAlignment = Enum.TextXAlignment.Left

    local colorOrder = {"Vàng","Xanh lá","Xanh dương","Đỏ","Tím","Trắng","Cam","Hồng"}
    local colorBtns = {}

    for i, cKey in ipairs(colorOrder) do
        local col = themeColors[cKey]
        local row = math.ceil(i / 4)
        local col_idx = (i - 1) % 4

        local btn = Instance.new("TextButton", pages[5])
        btn.Size = UDim2.new(0.23, 0, 0, 26)
        btn.Position = UDim2.new(col_idx * 0.25, col_idx > 0 and 2 or 0, 0, 84 + (row-1)*30)
        btn.BackgroundColor3 = col
        btn.BackgroundTransparency = 0.1
        btn.Text = cKey
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 9
        btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local cStr = Instance.new("UIStroke", btn)
        cStr.Thickness = 2
        cStr.Color = currentThemeKey == cKey and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0)
        cStr.Transparency = currentThemeKey == cKey and 0 or 0.7

        colorBtns[cKey] = {btn = btn, str = cStr}

        btn.MouseButton1Click:Connect(function()
            -- reset all
            for _, v in pairs(colorBtns) do
                v.str.Color = Color3.fromRGB(0,0,0)
                v.str.Transparency = 0.7
            end
            -- highlight selected
            cStr.Color = Color3.fromRGB(255,255,255)
            cStr.Transparency = 0
            currentThemeKey = cKey
            applyTheme(col)
            -- update size buttons stroke
        end)
    end

    -- Indicator màu hiện tại
    local currentColorLbl = Instance.new("TextLabel", pages[5])
    currentColorLbl.Size = UDim2.new(1, 0, 0, 18)
    currentColorLbl.Position = UDim2.new(0, 0, 0, 148)
    currentColorLbl.BackgroundTransparency = 1
    currentColorLbl.Font = Enum.Font.Gotham
    currentColorLbl.TextSize = 10
    currentColorLbl.TextXAlignment = Enum.TextXAlignment.Left

    task.spawn(function()
        while gui.Parent do
            currentColorLbl.Text = "Màu hiện tại: " .. currentThemeKey
            currentColorLbl.TextColor3 = currentThemeColor
            task.wait(0.3)
        end
    end)

    pages[5].CanvasSize = UDim2.new(0, 0, 0, 170)

    -- ===== SWITCH TAB =====
    local function switch(i)
        for k, v in ipairs(pages) do
            v.Visible = false
            buttons[k].TextColor3 = Color3.fromRGB(180, 180, 180)
        end
        pages[i].Visible = true
        buttons[i].TextColor3 = currentThemeColor
    end

    for i, b in ipairs(buttons) do
        b.MouseButton1Click:Connect(function() switch(i) end)
    end
    switch(1)

    -- Tab highlight update khi đổi màu
    task.spawn(function()
        while gui.Parent do
            for i, b in ipairs(buttons) do
                if pages[i].Visible then
                    b.TextColor3 = currentThemeColor
                end
            end
            MainStroke.Color = currentThemeColor
            titleText.TextColor3 = currentThemeColor
            titleBar.BackgroundColor3 = currentThemeColor
            task.wait(0.2)
        end
    end)

    -- ===== TOGGLE BUTTON =====
    local toggle = Instance.new("TextButton", gui)
    toggle.Size = UDim2.new(0, 60, 0, 60)
    toggle.Position = UDim2.new(1, -80, 1, -80)
    toggle.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    toggle.BackgroundTransparency = 0.3
    toggle.Text = ""
    toggle.BorderSizePixel = 0
    toggle.ClipsDescendants = true
    Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 9999)

    local toggleStroke = Instance.new("UIStroke", toggle)
    toggleStroke.Color = Color3.fromRGB(255, 215, 0)
    toggleStroke.Thickness = 2

    local toggleIcon = Instance.new("ImageLabel", toggle)
    toggleIcon.Size = UDim2.new(1, 0, 1, 0)
    toggleIcon.BackgroundTransparency = 1
    toggleIcon.Image = "rbxassetid://135314302105271"
    toggleIcon.ScaleType = Enum.ScaleType.Fit

    local UIS2 = game:GetService("UserInputService")
    local dragging2, startPos2, startFramePos2 = false, nil, nil
    local dragMoved = false

    toggle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging2 = true
            dragMoved = false
            startPos2 = inp.Position
            startFramePos2 = toggle.Position
        end
    end)

    UIS2.InputChanged:Connect(function(inp)
        if dragging2 and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = inp.Position - startPos2
            if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then dragMoved = true end
            toggle.Position = UDim2.new(
                startFramePos2.X.Scale, startFramePos2.X.Offset + delta.X,
                startFramePos2.Y.Scale, startFramePos2.Y.Offset + delta.Y
            )
        end
    end)

    UIS2.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging2 = false
        end
    end)

    -- Toggle stroke color with theme
    task.spawn(function()
        while gui.Parent do
            toggleStroke.Color = currentThemeColor
            task.wait(0.3)
        end
    end)

    local visible = true
    toggle.MouseButton1Click:Connect(function()
        if not dragMoved then
            visible = not visible
            main.Visible = visible
        end
    end)

    -- ===== FPS + PING LABEL =====
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
            if ok then smoothPing2 = smoothPing2 + (raw - smoothPing2) * 0.05 end
            hue2 = (hue2 + 0.02) % 1
            statsLabel.TextColor3 = Color3.fromHSV(hue2, 1, 1)
            statsLabel.Text = "FPS: " .. fps2 .. "\nPing: " .. math.floor(smoothPing2) .. " ms"
            task.wait(0.5)
        end
    end)

    -- ===== BLOX FRUITS AUTO LOAD =====
    local BloxFruits_IDs = {
        [27539155] = true, [2753915549] = true, [85211729168715] = true,
        [4442272187] = true, [4442272183] = true, [79091703265657] = true,
        [7449423635] = true, [100117331123089] = true
    }
    local MainScriptLink = "https://raw.githubusercontent.com/leduccuong01091987-collab/Chanbomayde/refs/heads/main/notify.lua"

    if BloxFruits_IDs[game.PlaceId] then
        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet(MainScriptLink))()
            end)
            if not ok then warn("Lỗi load script: " .. tostring(err)) end
        end)
    end
end

task.spawn(doFixLag)
