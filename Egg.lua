local gui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = gui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0,350,0,225)
MainFrame.Position = UDim2.new(0.5,-175,0.5,-112)
MainFrame.BackgroundColor3 = Color3.fromRGB(30,35,40)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

Instance.new("UICorner",MainFrame).CornerRadius = UDim.new(0,8)
local stroke = Instance.new("UIStroke",MainFrame)
stroke.Color = Color3.fromRGB(60,150,255)
stroke.Thickness = 2

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1,0,0,35)
TitleBar.BackgroundColor3 = Color3.fromRGB(25,30,35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame
Instance.new("UICorner",TitleBar).CornerRadius = UDim.new(0,8)

local IconLabel = Instance.new("ImageLabel")
IconLabel.Size = UDim2.new(0,24,0,24)
IconLabel.Position = UDim2.new(0,6,0,5.5)
IconLabel.BackgroundTransparency = 1
IconLabel.Image = "rbxassetid://131892820187785"
IconLabel.ScaleType = Enum.ScaleType.Fit
IconLabel.Parent = TitleBar

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1,-100,1,0)
TitleText.Position = UDim2.new(0,35,0,0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "EggHub Logger"
TitleText.TextColor3 = Color3.new(1,1,1)
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 14
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0,28,0,28)
MinimizeButton.Position = UDim2.new(1,-32,0,3.5)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(40,45,50)
MinimizeButton.TextColor3 = Color3.new(1,1,1)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 16
MinimizeButton.Text = "−"
MinimizeButton.Parent = TitleBar
Instance.new("UICorner",MinimizeButton).CornerRadius = UDim.new(0,6)

local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1,-12,1,-85)
ContentFrame.Position = UDim2.new(0,6,0,40)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20,25,30)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame
Instance.new("UICorner",ContentFrame).CornerRadius = UDim.new(0,6)

local LogFrame = Instance.new("ScrollingFrame")
LogFrame.Size = UDim2.new(1,-8,1,-8)
LogFrame.Position = UDim2.new(0,4,0,4)
LogFrame.BackgroundTransparency = 1
LogFrame.BorderSizePixel = 0
LogFrame.ScrollBarThickness = 4
LogFrame.ScrollBarImageColor3 = Color3.fromRGB(60,150,255)
LogFrame.Parent = ContentFrame

local LogList = Instance.new("UIListLayout")
LogList.Padding = UDim.new(0,2)
LogList.Parent = LogFrame

local BottomBar = Instance.new("Frame")
BottomBar.Size = UDim2.new(1,0,0,40)
BottomBar.Position = UDim2.new(0,0,1,-40)
BottomBar.BackgroundColor3 = Color3.fromRGB(25,30,35)
BottomBar.BorderSizePixel = 0
BottomBar.Parent = MainFrame
Instance.new("UICorner",BottomBar).CornerRadius = UDim.new(0,8)

local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(0,160,0,28)
CopyButton.Position = UDim2.new(0,6,0.5,-14)
CopyButton.BackgroundColor3 = Color3.fromRGB(60,150,255)
CopyButton.TextColor3 = Color3.new(1,1,1)
CopyButton.Font = Enum.Font.GothamBold
CopyButton.TextSize = 12
CopyButton.Text = "📋  Copy Logs"
CopyButton.Parent = BottomBar
Instance.new("UICorner",CopyButton).CornerRadius = UDim.new(0,6)

local ClearButton = Instance.new("TextButton")
ClearButton.Size = UDim2.new(0,60,0,28)
ClearButton.Position = UDim2.new(0,172,0.5,-14)
ClearButton.BackgroundColor3 = Color3.fromRGB(200,60,60)
ClearButton.TextColor3 = Color3.new(1,1,1)
ClearButton.Font = Enum.Font.GothamBold
ClearButton.TextSize = 12
ClearButton.Text = "🗑️"
ClearButton.Parent = BottomBar
Instance.new("UICorner",ClearButton).CornerRadius = UDim.new(0,6)

local WaveTimeFrame = Instance.new("Frame")
WaveTimeFrame.Size = UDim2.new(0,100,0,28)
WaveTimeFrame.Position = UDim2.new(1,-106,0.5,-14)
WaveTimeFrame.BackgroundColor3 = Color3.fromRGB(40,45,50)
WaveTimeFrame.BorderSizePixel = 0
WaveTimeFrame.Parent = BottomBar
Instance.new("UICorner",WaveTimeFrame).CornerRadius = UDim.new(0,6)

local WaveTimeLabel = Instance.new("TextLabel")
WaveTimeLabel.Size = UDim2.new(1,0,1,0)
WaveTimeLabel.BackgroundTransparency = 1
WaveTimeLabel.Text = "0/0:00"
WaveTimeLabel.TextColor3 = Color3.fromRGB(100,255,100)
WaveTimeLabel.Font = Enum.Font.Code
WaveTimeLabel.TextSize = 14
WaveTimeLabel.Parent = WaveTimeFrame

-- Dragging
local dragging, dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

TitleBar.InputBegan:Connect(function(input)
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

TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        update(input)
    end
end)

-- Minimize
local isMinimized = false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible = false
        BottomBar.Visible = false
        MainFrame.Size = UDim2.new(0,350,0,35)
        MinimizeButton.Text = "+"
    else
        ContentFrame.Visible = true
        BottomBar.Visible = true
        MainFrame.Size = UDim2.new(0,350,0,225)
        MinimizeButton.Text = "−"
    end
end)

-- Export to _G
_G.EggHubLogger = {
    LogFrame = LogFrame,
    LogList = LogList,
    WaveTimeLabel = WaveTimeLabel,
    CopyButton = CopyButton,
    ClearButton = ClearButton,
    ActionLog = {}
}

return _G.EggHubLogger
