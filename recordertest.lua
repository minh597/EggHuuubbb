local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local remoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
local gui = player:WaitForChild("PlayerGui")
local cashLabel = gui:WaitForChild("ReactUniversalHotbar"):WaitForChild("Frame"):WaitForChild("values"):WaitForChild("cash"):WaitForChild("amount")
local waveLabel = gui:WaitForChild("ReactGameTopGameDisplay"):WaitForChild("Frame"):WaitForChild("wave"):WaitForChild("container"):WaitForChild("value")
local timeLabel = gui:WaitForChild("ReactGameTopGameDisplay"):WaitForChild("Frame"):WaitForChild("waveTimer"):WaitForChild("container"):WaitForChild("value")

local function getCash()
    local rawText = cashLabel.Text or ""
    local cleaned = rawText:gsub("[^%d%-]", "")
    return tonumber(cleaned) or 0
end

local function getWave()
    local txt = waveLabel.Text or "0"
    return tonumber(txt:match("^(%d+)")) or 0
end

local function getTimeSec()
    local txt = timeLabel.Text or "0:00"
    local m,s = txt:match("^(%d+):(%d+)")
    return ((tonumber(m) or 0)*60) + (tonumber(s) or 0)
end

local function getWaveTimeStr()
    local w,t = getWave(), getTimeSec()
    local m,s = math.floor(t/60), t%60
    return m > 0 and string.format("%d/%d'%02d",w,m,s) or string.format("%d/%d",w,s)
end

local function isTableEmpty(tbl)
    if type(tbl) ~= "table" then return true end
    for _ in pairs(tbl) do return false end
    return true
end

local function getPos(tower)
    return (tower.PrimaryPart and tower.PrimaryPart.Position) or tower.Position
end

local actionLog = {}

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
Instance.new("UIStroke",MainFrame).Color = Color3.fromRGB(60,150,255)
Instance.new("UIStroke",MainFrame).Thickness = 2

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

local function updateWaveTimeDisplay()
    local w = getWave()
    local txt = timeLabel.Text or "0:00"
    WaveTimeLabel.Text = w.."/"..txt
end
waveLabel:GetPropertyChangedSignal("Text"):Connect(updateWaveTimeDisplay)
timeLabel:GetPropertyChangedSignal("Text"):Connect(updateWaveTimeDisplay)
task.spawn(function() while task.wait(0.5) do updateWaveTimeDisplay() end end)

local dragging, dragInput, dragStart, startPos
local function update(input)
    local delta = input.Position - dragStart
    MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState==Enum.UserInputState.End then dragging=false end
        end)
    end
end)
TitleBar.InputChanged:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
        dragInput=input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input==dragInput and dragging then update(input) end
end)

local isMinimized=false
MinimizeButton.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        ContentFrame.Visible=false; BottomBar.Visible=false; MainFrame.Size=UDim2.new(0,350,0,35)
        MinimizeButton.Text="+"
    else
        ContentFrame.Visible=true; BottomBar.Visible=true; MainFrame.Size=UDim2.new(0,350,0,225)
        MinimizeButton.Text="−"
    end
end)

local function addLog(text,color)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-8,0,20)
    lbl.BackgroundColor3 = Color3.fromRGB(30,35,40)
    lbl.BorderSizePixel = 0
    lbl.Text = "  "..text
    lbl.TextColor3 = color or Color3.new(1,1,1)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = LogFrame
    Instance.new("UICorner",lbl).CornerRadius = UDim.new(0,4)
    LogFrame.CanvasSize = UDim2.new(0,0,0,LogList.AbsoluteContentSize.Y)
    LogFrame.CanvasPosition = Vector2.new(0,LogFrame.CanvasSize.Y.Offset)
end

CopyButton.MouseButton1Click:Connect(function()
    if setclipboard then
        local t={}
        for _,v in ipairs(actionLog) do table.insert(t,v.raw or "") end
        setclipboard(table.concat(t,"\n"))
        CopyButton.Text="✓ Copied!"; task.wait(1.5); CopyButton.Text="📋  Copy Logs"
    end
end)

ClearButton.MouseButton1Click:Connect(function()
    actionLog={}
    for _,c in ipairs(LogFrame:GetChildren()) do
        if c:IsA("TextLabel") then c:Destroy() end
    end
    LogFrame.CanvasSize=UDim2.new(0,0,0,0)
end)

local mt = getrawmetatable(game)
local old = mt.__namecall
setreadonly(mt,false)

mt.__namecall = newcclosure(function(self,...)
    local method=getnamecallmethod()
    local args={...}

    -- PLACE
    if type(args[3])=="table" and args[3].Position and args[4] then
        local pos=args[3].Position
        local txt=string.format('place(%.3f,%.3f,%.3f,"%s",%d)',pos.X,pos.Y,pos.Z,tostring(args[4]),getCash())
        table.insert(actionLog,{type="place",pos={pos.X,pos.Y,pos.Z},name=tostring(args[4]),cash=getCash(),raw=txt})
        addLog(txt,Color3.fromRGB(100,255,100))
        return old(self,...)
    end

    -- UPGRADE
    if args[1]=="Troops" and args[2]=="Upgrade" and typeof(args[4])=="table" then
        local tower=args[4].Troop
        local res=old(self,...)
        if tower and tower.Parent then
            local p=getPos(tower)
            local pathName = tostring(args[4].Path or "Unknown"):gsub('"','')
            local txt=string.format('upgrade(%.3f,%.3f,%.3f,%s,%d)',p.X,p.Y,p.Z,pathName,getCash())
            table.insert(actionLog,{type="upgrade",pos={p.X,p.Y,p.Z},path=pathName,cash=getCash(),raw=txt})
            addLog(txt,Color3.fromRGB(100,200,255))
        end
        return res
    end

    -- SELL
    if args[1]=="Troops" and args[2]=="Sell" and typeof(args[3])=="table" then
        local tower=args[3].Troop
        if tower and tower.Parent then
            local success,pos=pcall(function() return getPos(tower) end)
            if success and pos then
                local txt=string.format('sell(%.3f,%.3f,%.3f)',pos.X,pos.Y,pos.Z)
                table.insert(actionLog,{type="sell",pos={pos.X,pos.Y,pos.Z},raw=txt})
                addLog(txt,Color3.fromRGB(255,100,100))
            end
        end
        return old(self,...)
    end

    -- ABILITY
    if args[1]=="Troops" and args[2]=="Abilities" and args[3]=="Activate" and typeof(args[4])=="table" then
        local tower = args[4].Troop
        local data = args[4].Data
        local name = tostring(args[4].Name or "")
        local wt = getWaveTimeStr()
        local res = old(self,...)
        if tower and tower.Parent then
            local p = getPos(tower)
            if not data or isTableEmpty(data) then
                local txt = string.format('ability(%.3f,%.3f,%.3f,"%s","%s")',p.X,p.Y,p.Z,name,wt)
                table.insert(actionLog,{type="ability_simple",pos={p.X,p.Y,p.Z},name=name,raw=txt})
                addLog(txt,Color3.fromRGB(200,200,50))
            else
                if data.directionCFrame and data.pathName then
                    local dir = data.directionCFrame.Position + data.directionCFrame.LookVector
                    local txt = string.format('Ability1(%.3f,%.3f,%.3f,%s,%.3f,%.3f,%.3f,%s,"%s","%s")',p.X,p.Y,p.Z,data.pathName,dir.X,dir.Y,dir.Z,tostring(data.pointToEnd),name,wt)
                    table.insert(actionLog,{type="ability1",pos={p.X,p.Y,p.Z},name=name,raw=txt})
                    addLog(txt,Color3.fromRGB(255,100,150))
                elseif data.position then
                    local tpos = data.position
                    local txt = string.format('Ability2(%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,"%s","%s")',p.X,p.Y,p.Z,tpos.X,tpos.Y,tpos.Z,name,wt)
                    table.insert(actionLog,{type="ability2",pos={p.X,p.Y,p.Z},name=name,raw=txt})
                    addLog(txt,Color3.fromRGB(150,100,255))
                elseif data.towerToClone and data.towerPosition then
                    local cpos = getPos(data.towerToClone)
                    local rpos = data.towerPosition
                    local txt = string.format('Ability3(%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,%.3f,"%s","%s")',p.X,p.Y,p.Z,cpos.X,cpos.Y,cpos.Z,rpos.X,rpos.Y,rpos.Z,name,wt)
                    table.insert(actionLog,{type="ability3",pos={p.X,p.Y,p.Z},name=name,raw=txt})
                    addLog(txt,Color3.fromRGB(100,255,200))
                end
            end
        end
        return res
    end

    return old(self,...)
end)

setreadonly(mt,true)

addLog("✓ Call me daddy for more script", Color3.fromRGB(100,255,100))