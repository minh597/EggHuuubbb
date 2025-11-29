local EggHub = getgenv().EggHub or {}
local config = {
    autoskip = EggHub.autoskip,
    SellAllTower = EggHub.SellAllTower,
    AtWave = EggHub.AtWave,
    autoCommander = EggHub.autoCommander,
    difficulty = EggHub.Difficulty,
    map = EggHub.Map,
    replay = EggHub.Replay,
    macroURL = EggHub.MacroUrl
}

local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TeleportService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local RF = RS:WaitForChild("RemoteFunction")
local RE = RS:WaitForChild("RemoteEvent")
local vu = game:GetService("VirtualUser")


player.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)


local skipFlag = false
local function skipVoting()
    task.spawn(function()
        while skipFlag do
            pcall(function() RF:InvokeServer("Voting","Skip") end)
            task.wait(1)
        end
    end)
end

local function firstSkip()
    skipFlag = true
    skipVoting()
    task.delay(5,function() skipFlag=false end)
end


task.spawn(function()
    repeat task.wait() until game:IsLoaded()
    if workspace:FindFirstChild("Elevators") then
        RF:InvokeServer("Multiplayer","v2:start",{count=1, mode="survival", difficulty=config.difficulty})
    else
        task.wait(10)
        RF:InvokeServer("LobbyVoting","Override",config.map)
        RE:FireServer("LobbyVoting","Vote",config.map,Vector3.new(14.947,9.6,55.556))
        RE:FireServer("LobbyVoting","Ready")
        task.wait(7)
        RF:InvokeServer("Voting","Skip")
    end
end)


local gui = player.PlayerGui
local towerFolder = workspace:WaitForChild("Towers")
local reactGame = gui:WaitForChild("ReactGameTopGameDisplay")
local cashLabel = gui:WaitForChild("ReactUniversalHotbar").Frame.values.cash.amount
local waveContainer = reactGame.Frame.wave.container
local timeContainer = reactGame.Frame.waveTimer.container
local gameOverGui = gui:WaitForChild("ReactGameNewRewards").Frame.gameOver


local function getCash()
    local txt = (cashLabel.Text or ""):gsub("[^%d]","")
    return tonumber(txt) or 0
end

local function waitForCash(amt)
    while getCash() < amt do task.wait(0.5) end
end

local function getWave()
    local txt = waveContainer.value.Text or "0"
    local n = tonumber(txt:match("^(%d+)"))
    return n or 0
end

local function getTimeSec()
    local txt = timeContainer.value.Text or "0:00"
    local m,s = txt:match("^(%d+):(%d+)")
    return ((tonumber(m) or 0)*60)+(tonumber(s) or 0)
end

local function findTower(x,y,z)
    local pos = Vector3.new(x,y,z)
    for _,t in ipairs(towerFolder:GetChildren()) do
        if t:IsA("Model") and t.PrimaryPart and (t.PrimaryPart.Position-pos).Magnitude <= 1 then
            return t
        end
    end
end

local function waitForTower(x,y,z,timeout)
    timeout = timeout or 10
    local start = tick()
    while tick()-start < timeout do
        local t = findTower(x,y,z)
        if t then return t end
        task.wait(0.2)
    end
    return nil
end

local function parseWaveTime(str)
    if not str then return nil, nil end
    if str:match("^/(%d+)$") then
        return nil, tonumber(str:match("^/(%d+)$"))
    end
    local w,t = str:match("^(%d+)/(.+)$")
    if not w then return nil, nil end
    local wave = tonumber(w)
    local m,s = t:match("^(%d+)'(%d+)$")
    if m then return wave, tonumber(m)*60+tonumber(s) end
    m,s = t:match("^(%d+):(%d+)$")
    if m then return wave, tonumber(m)*60+tonumber(s) end
    return wave, tonumber(t)
end

local function waitForWaveTimeAsync(waveTarget, secTarget)
    while true do
        local currentWave = getWave()
        local currentTime = getTimeSec()
        local waveOK = (not waveTarget) or (currentWave >= waveTarget)
        local timeOK = (currentTime <= secTarget)
        if waveOK and timeOK then break end
        if waveTarget and currentWave > waveTarget + 5 then break end
        task.wait(0.1)
    end
end


local function place(x,y,z,name,cost)
    waitForCash(cost)
    pcall(function() RF:InvokeServer("Troops","Pl\208\176ce",{Rotation=CFrame.new(),Position=Vector3.new(x,y,z)},name) end)
    task.wait(0.5)
end

local function upgrade(x,y,z,path,cost)
    waitForCash(cost)
    task.wait(0.2)
    local t = findTower(x,y,z)
    if t then pcall(function() RF:InvokeServer("Troops","Upgrade","Set",{Troop=t,Path=path}) end) end
    task.wait(0.5)
end

local function sell(x,y,z)
    local t = findTower(x,y,z)
    if t then pcall(function() RF:InvokeServer("Troops","Se\108\108",{Troop=t}) end) end
    task.wait(0.5)
end

local function SetTower(x,y,z,val,name)
    local t = findTower(x,y,z)
    if t then pcall(function() RF:InvokeServer("Troops","Option","Set",{Value=val,Name=name,Troop=t}) end) end
    task.wait(0.5)
end

local function SetTarget(x,y,z,mode)
    local t = findTower(x,y,z)
    if t then pcall(function() RF:InvokeServer("Troops","Target","Set",{Target=mode or "Random",Troop=t}) end) end
    task.wait(0.5)
end

local function sellAllTowers()
    for _,t in ipairs(towerFolder:GetChildren()) do
        pcall(function() RF:InvokeServer("Troops","Se\108\108",{Troop=t}) end)
        task.wait(0.1)
    end
end


local function ability(x,y,z,name,wt)
    local execute = function()
        local t = findTower(x,y,z)
        if t then
            pcall(function() RF:InvokeServer("Troops","Abilities","Activate",{Troop=t,Data={},Name=name}) end)
        end
    end
    if wt then
        local wave,sec = parseWaveTime(wt)
        if sec then waitForWaveTimeAsync(wave,sec) end
    end
    execute()
end

local function Ability1(x,y,z,pathName,dx,dy,dz,pointToEnd,name,wt)
    if wt then
        local wave,sec = parseWaveTime(wt)
        if sec then waitForWaveTimeAsync(wave,sec) end
    end
    local t = findTower(x,y,z)
    if t then
        local pos = Vector3.new(x,y,z)
        local dir = Vector3.new(dx,dy,dz)
        pcall(function() RF:InvokeServer("Troops","Abilities","Activate",{Troop=t,Data={directionCFrame=CFrame.new(pos,dir),pathName=pathName,pointToEnd=pointToEnd},Name=name}) end)
    end
    task.wait(0.5)
end

local function Ability2(x,y,z,tx,ty,tz,name,wt)
    if wt then
        local wave,sec = parseWaveTime(wt)
        if sec then waitForWaveTimeAsync(wave,sec) end
    end
    local t = findTower(x,y,z)
    if t then
        pcall(function() RF:InvokeServer("Troops","Abilities","Activate",{Troop=t,Data={position=Vector3.new(tx,ty,tz)},Name=name}) end)
    end
    task.wait(0.5)
end

local function Ability3(x,y,z,cx,cy,cz,nx,ny,nz,name,wt)
    if wt then
        local wave,sec = parseWaveTime(wt)
        if sec then waitForWaveTimeAsync(wave,sec) end
    end
    local t = findTower(x,y,z)
    local c = findTower(cx,cy,cz)
    if t and c then
        pcall(function() RF:InvokeServer("Troops","Abilities","Activate",{Troop=t,Data={towerToClone=c,towerPosition=Vector3.new(nx,ny,nz)},Name=name}) end)
        waitForTower(nx,ny,nz,10)
    end
    task.wait(0.5)
end


local macroLoaded=false
local function setupWaveListener()
    for _,l in ipairs(waveContainer:GetDescendants()) do
        if l:IsA("TextLabel") then
            l:GetPropertyChangedSignal("Text"):Connect(function()
                local w=getWave()
                if w==1 and not macroLoaded and config.macroURL then
                    macroLoaded=true
                    pcall(function() loadstring(game:HttpGet(config.macroURL))() end)
                end
                if config.SellAllTower and config.AtWave>0 and w==config.AtWave then
                    sellAllTowers()
                end
            end)
            return true
        end
    end
end

if not setupWaveListener() then
    waveContainer.ChildAdded:Connect(function() task.wait(0.5) setupWaveListener() end)
end


gameOverGui:GetPropertyChangedSignal("Visible"):Connect(function()
    if gameOverGui.Visible then
        macroLoaded=false
        task.wait(config.replay and 2 or 3)
        if config.replay then firstSkip() else TS:Teleport(game.PlaceId,player) end
    end
end)


if config.autoskip then
    task.spawn(function()
        while task.wait(1) do pcall(function() RF:InvokeServer("Voting","Skip") end) end
    end)
end


if config.autoCommander then
    task.spawn(function()
        local ok,vim=pcall(function() return game:GetService("VirtualInputManager") end)
        if ok and vim and vim.SendKeyEvent then
            while task.wait(10) do
                pcall(function()
                    vim:SendKeyEvent(true,Enum.KeyCode.F,false,game)
                    task.wait(0.00001)
                    vim:SendKeyEvent(false,Enum.KeyCode.F,false,game)
                end)
            end
        end
    end)
end


getgenv().place=place
getgenv().upgrade=upgrade
getgenv().sell=sell
getgenv().SetTower=SetTower
getgenv().SetTarget=SetTarget
getgenv().ability=ability
getgenv().Ability1=Ability1
getgenv().Ability2=Ability2
getgenv().Ability3=Ability3
