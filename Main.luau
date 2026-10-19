local str = [[

queue_on_teleport("Teleported = true "..readfile("ChachedSkibiDefense"))

if game.PlaceId ~= 14279724900 then delfile("TDM/SkibiDefense/settings.ini") return end

if not Teleported then
	if isfile("TDM/SkibiDefense/settings.ini") then
		delfile("TDM/SkibiDefense/settings.ini")
	end
end

local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local TDMRunId = HttpService:GenerateGUID(true)
local LocalPlayer = Players.LocalPlayer

AlrLoaded1 = AlrLoaded1 or {}
AlrLoaded = AlrLoaded or {}

Connections = {}

local function GetUrl(Url)
	local sc
	if not AlrLoaded1[Url] then
		sc = game:HttpGet(Url)
		AlrLoaded1[Url] = sc
	else
		sc = AlrLoaded1[Url]
	end
	return sc
end

local function GetApi(Url)
	local sc
	if not AlrLoaded1[Url] then
		sc = game:HttpGet(Url)
		AlrLoaded1[Url] = sc
	else
		sc = AlrLoaded1[Url]
	end

	if not AlrLoaded[Url] then
		AlrLoaded[Url] = loadstring(sc)()
	end

	return AlrLoaded[Url]
end

local getcallbackmember = getcallbackmember or getcallbackvalue
if not getcallbackmember then
	StarterGui:SetCore("SendNotification",{
		Title = "TDM",
		Text = "注入器不支持",
	})
	return
end

if not game:IsLoaded() then
	game.Loaded:Wait()
end



local Starlight = loadstring(GetUrl("https://raw.githubusercontent.com/qian-cheng-awa/Tools/refs/heads/main/Starlight.luau"))()
local v,gameinfo = pcall(function()
	return MarketplaceService:GetProductInfo(game.PlaceId)
end)
if not v then
	gameinfo = {
		IconImageAssetId = 109251559,
		Name = "TDM",
	}
end

local Window = Starlight:CreateWindow({
	Name = "TDM V4.0",
	Subtitle = gameinfo.Name.." | "..tostring(game.PlaceId),
	Icon = gameinfo.IconImageAssetId,

	LoadingSettings = {
		Title = "TDM V4",
		Subtitle = "By Obi_xieO",
	},

	FileSettings = {
		ConfigFolder = "TDMStarlight"
	},
	InterfaceAdvertisingPrompts = false,
})

local Game = RS:WaitForChild("Game")
local Chapter = RS:FindFirstChild("Chapter")
local RunTime = Game.Clock

local SkibiDefenseFolder = "TDM/SkibiDefense/"
local SettingPATH = `{SkibiDefenseFolder}settings.ini`

local function get(name, default)
	if isfile(SettingPATH) then
		for line in readfile(SettingPATH):gmatch("[^\r\n]+") do
			local k, v = line:match("^(.-)=(.*)$")
			if k == name then return v end
		end
	end
	return default
end

local function set(name, value)
	local t, found = {}, false
	if isfile(SettingPATH) then
		for line in readfile(SettingPATH):gmatch("[^\r\n]+") do
			local k, v = line:match("^(.-)=(.*)$")
			if k then
				if k == name then v = tostring(value); found = true end
				t[#t + 1] = k .. "=" .. v
			end
		end
	end
	if not found then t[#t + 1] = name .. "=" .. tostring(value) end
	writefile(SettingPATH, table.concat(t, "\n"))
end

local function ChangeSpeed(Speed)
	Game.Speed.Change:FireServer(Speed)
end

local function GetServerRunTime()
	return RunTime.Value+LocalPlayer.GetNetworkPing(LocalPlayer)
end

local function GetChapter()
	return Chapter.Value
end

local function Replay()
	RS.Event.ReplayCore:FireServer()
end

local function Ready()
	RS.GAME_START.readyButton:FireServer(true)
end

local TabSection = Window:CreateTabSection("Skibi Defense")
local MainTab = TabSection:CreateTab({
	Name = "挂机",
	Columns = 1,
})
local Tab = MainTab:CreateGroupbox({
	Name = "",
	Column = 1,
})

local Recording = false
local RecordAutoSkip = false
local RecordFileName = GetChapter()
local SavedCurrentCfg = {get("CurrentCFG",nil)}
local CurrentCfg = SavedCurrentCfg[1]
local FILE = {
	AutoSkip = {},
	WaveSkip = {},
}


local NeedLog = {
	[RS.Event.UpgradeTower] = function(args)
		local TowerGUID = args[1]
		if FILE[TowerGUID] then
			table.insert(FILE[TowerGUID].Upgrade,GetServerRunTime())
		end
	end,
	[RS.Event.RemoveTower] = function(args)
		local TowerGUID = args[1]
		if FILE[TowerGUID] then
			FILE[TowerGUID].SellTick = GetServerRunTime()
		end
	end,
	[RS.Event.ChangeTowerTargetMode] = function(args)
		local TowerGUID = args[1]
		if FILE[TowerGUID] then
			table.insert(FILE[TowerGUID].TargetMode,GetServerRunTime())
		end
	end,
	[RS.BoostSelect] = function(args)
		local TowerGUID = args[1]
		local TargetGUID = args[2]
		if TowerGUID and TargetGUID and FILE[TowerGUID] and FILE[TargetGUID] then
			table.insert(FILE[TowerGUID].BoostSelect,{
				Name = TargetGUID,
				Tick = GetServerRunTime()
			})
		end
	end,
	[RS.Event.PencilCloneRequest] = function(args)
		local TowerGUID = args[1]
		local TargetGUID = args[2]
		local CFrame = args[3]
		if TowerGUID and TargetGUID and FILE[tostring(TowerGUID)] and FILE[tostring(TargetGUID)] then
			table.insert(FILE[TowerGUID].PencilCloneRequest,{
				Name = TargetGUID,
				Tick = GetServerRunTime(),
				CFrame = tostring(CFrame.Position),
			})
		end
	end,
	[RS.Event.DrillMoveRequest] = function(args)
		local TowerGUID = args[1]
		local CFrame = args[2]
		if TowerGUID and CFrame and FILE[TowerGUID] then
			table.insert(FILE[TowerGUID].DrillMoveRequest,{
				Tick = GetServerRunTime(),
				CFrame = tostring(CFrame.Position),
			})
		end
	end,
	[RS.Event.waveSkip] = function(args)
		table.insert(FILE.WaveSkip,GetServerRunTime())
	end,
	[RS.TowerScript.spawnTowerAbility] = function(args)
		local TowerGUID = args[1]
		local AbilityName = args[2]
		if TowerGUID and AbilityName and FILE[TowerGUID] then
			table.insert(FILE[TowerGUID].Ability,{
				Tick = GetServerRunTime(),
				Name = AbilityName,
			})
		end
	end,
}


local IsA =  game.IsA


local OldNameCall
Tab:CreateToggle({
	Name = "录制",
	CurrentValue = Recording,
	Callback = function(Value)
		if Value then
			FILE = {
				AutoSkip = {},
				WaveSkip = {},
			}
			
			if not OldNameCall then
				OldNameCall = hookmetamethod(game,"__namecall",newcclosure(function(...)
					local method = getnamecallmethod()
					local remote = cloneref(...)
					if not checkcaller() and Recording and typeof(remote) == "Instance" then
						if method then
							local args = {select(2,...)}
							if (method == "FireServer" and IsA(remote,"RemoteEvent")) or (method == "InvokeServer" and IsA(remote,"RemoteFunction")) then
								for Event,Function in NeedLog do
									if Event == (...) then
										Function(args)
									end
								end
							end
						end
					end

					return OldNameCall(...)
				end))
			end
		end
		Recording = Value
	end    
})


Tab:CreateToggle({
	Name = "自动跳过（不要用游戏里的）",
	CurrentValue = RecordAutoSkip,
	Callback = function(Value)
		RecordAutoSkip = Value

		if Recording then
			table.insert(FILE.AutoSkip,{
				Tick = GetServerRunTime(),
				Value = Value
			})
		end
	end    
})

Tab:CreateInput({
	Name = "输入配置名字 ->",
	CurrentValue = RecordFileName,
	PlaceholderText = "输入文字",
	RemoveTextAfterFocusLost = false,
	Callback = function(Text)
		RecordFileName = Text
	end,
})

local Files
local function GetFiles()
	if not isfolder(`{SkibiDefenseFolder}{GetChapter()}`) then
		makefolder(`{SkibiDefenseFolder}{GetChapter()}`)
	end

	local Folder = listfiles(`{SkibiDefenseFolder}{GetChapter()}`)
	for i,v in pairs(Folder) do
		Folder[i] = string.sub(v,#(`{SkibiDefenseFolder}{GetChapter()}`)+1)
	end

	return Folder
end

Tab:CreateButton({
	Name = "保存配置文件",
	Callback = function()
		writefile(`{SkibiDefenseFolder}{GetChapter()}/{RecordFileName}.SDRC`,HttpService:JSONEncode(FILE))

		Files:Set({Options = GetFiles()})
	end,
})

Files = Tab:CreateDropdown({
	Options = GetFiles(),
	Required = true,
	MultipleOptions = false,
	CurrentOption = SavedCurrentCfg,
	Placeholder = "None Selected",
	Name = "选择文件",
	Callback = function(Options)
		CurrentCfg = Options[1]
	end,
})


local Running = get("Running","false")
local AutoSkipRunning = false

Tab:CreateToggle({
	Name = "开始运行",
	CurrentValue = Running == "true",
	Callback = function(Value)
		set("Running",tostring(Value))

		if not Value then
			Running = nil
		elseif CurrentCfg then
			local Runtick = tick()
			Running = Runtick

			set("CurrentCFG",CurrentCfg)

			local Cfg = readfile(`{SkibiDefenseFolder}{GetChapter()}/{CurrentCfg}`)
			local File = HttpService:JSONDecode(Cfg)

			local conn
			conn = function(dt)
				if Running ~= Runtick then
					for i = #Connections, 1, -1 do
						if Connections[i] == conn then table.remove(Connections, i) break end
					end
					return
				end

				for i,v in File do
					if i == "AutoSkip" then
						for i,v in v do
							if v.Tick < GetServerRunTime() then
								AutoSkipRunning = v.Value
								RS.Event.waveSkip:FireServer(true)
								File.AutoSkip[i] = nil
							end
						end
					elseif i == "WaveSkip" then
						for i,v in v do
							if v < GetServerRunTime() then
								RS.Event.waveSkip:FireServer(true)
								File.WaveSkip[i] = nil
							end
						end
					else
						if v.Tick < GetServerRunTime() then
							if not v.Spawned then
								v.Spawned = true
								local Position = string.split(v.CFrame,",")

								RS.Event.placeTower:FireServer(
									v.Name,
									CFrame.new(
										tonumber(Position[1]),
										tonumber(Position[2]),
										tonumber(Position[3])
									)
								)
							end

							if v.SellTick and v.SellTick < GetServerRunTime() then
								RS.Event.RemoveTower:FireServer(v.ID)
								v.SellTick = nil
							end

							for i,t in v.Upgrade do
								if t < GetServerRunTime() then
									RS.Event.UpgradeTower:FireServer(v.ID)
									v.Upgrade[i] = nil
								end
							end

							for i,t in v.TargetMode do
								if t < GetServerRunTime() then
									RS.Event.ChangeTowerTargetMode:FireServer(v.ID)
									v.TargetMode[i] = nil
								end
							end

							for i,t in v.Ability do
								if t.Tick < GetServerRunTime() then
									RS.TowerScript.spawnTowerAbility:InvokeServer(v.ID,t.Name)
									v.Ability[i] = nil
								end
							end

							for i,t in v.BoostSelect do
								if t.Tick < GetServerRunTime() then
									RS.BoostSelect:FireServer(v.ID,t.Name)
									v.BoostSelect[i] = nil
								end
							end

							for i,t in v.PencilCloneRequest do
								if t.Tick < GetServerRunTime() then
									local Position = string.split(t.CFrame,",")

									RS.Event.PencilCloneRequest:FireServer(
										v.ID,
										t.Name,
										CFrame.new(
											tonumber(Position[1]),
											tonumber(Position[2]),
											tonumber(Position[3])
										)
									)
									
									v.PencilCloneRequest[i] = nil
								end
							end

							for i,t in v.DrillMoveRequest do
								if t.Tick < GetServerRunTime() then
									local Position = string.split(t.CFrame,",")

									RS.Event.DrillMoveRequest:FireServer(
										v.ID,
										CFrame.new(
											tonumber(Position[1]),
											tonumber(Position[2]),
											tonumber(Position[3])
										)
									)
									
									v.DrillMoveRequest[i] = nil
								end
							end
						end
					end
				end
			end
			table.insert(Connections, conn)
		end
	end    
})

local SavedCurrentSpeed = {get("CurrentSpeed","1")}
local Speed = SavedCurrentSpeed[1]

Tab:CreateDropdown({
	Options = {
		"1",
		"1.25",
		"1.5",
		"1.75",
		"2",
		"2.25",
		"2.5",
		"3",
		"4",
		"5",
		"6",
		"7",
	},
	Required = true,
	MultipleOptions = false,
	CurrentOption = SavedCurrentSpeed,
	Placeholder = "None Selected",
	Name = "倍速",
	Callback = function(Options)
		Speed = Options[1]
		set("CurrentSpeed",Options[1])
	end,
})

local LockSpeed = get("LockSpeed","false")

Tab:CreateToggle({
	Name = "锁定倍速",
	CurrentValue = LockSpeed == "true",
	Callback = function(Value)
		set("LockSpeed",tostring(Value))
		LockSpeed = Value
	end    
})
local autounfreeze = get("autounfreeze","false")
Tab:CreateToggle({
	Name = "自动解冻塔",
	CurrentValue = autounfreeze == "true",
	Callback = function(Value)
		autounfreeze = Value
		set("autounfreeze",tostring(Value))
	end    
})


local lastSpeedSend = 0

local function RegistTower(TowerName,TowerCFrame,TowerGUID)
	FILE[tostring(TowerGUID)] = {
		Name = tostring(TowerName),
		CFrame = tostring(TowerCFrame.Position),
		ID = tostring(TowerGUID),
		Upgrade = {},
		TargetMode = {},
		Ability = {},
		Tick = RunTime.Value-LocalPlayer:GetNetworkPing(),
		BoostSelect = {},
		DrillMoveRequest = {},
		PencilCloneRequest = {},
	}
end

local function UnfreezeAllTowers()
	local folder = workspace:FindFirstChild("Scripted")
	folder = folder and folder:FindFirstChild("TowerData")
	if not folder then return 0 end

	local count = 0
	for _, towerData in ipairs(folder:GetChildren()) do
		local guid = towerData.Name
		local model = game.CollectionService:GetTagged("inavail" .. guid)[1]
		if model and model:GetAttribute("Freeze") == true then
			game.ReplicatedStorage.UnfreezeRequest:FireServer(model.Name)
			count += 1
		end
	end
	return count
end

RS.Event.placeTower.OnClientEvent:Connect(function(Player,TowerName,TowerCFrame,TowerGUID)
	if Player == LocalPlayer then
		RegistTower(TowerName,TowerCFrame,TowerGUID)
	end
end)

RS.Event.waveSkip.OnClientEvent:Connect(function()
	if AutoSkipRunning or RecordAutoSkip then
		RS.Event.waveSkip:FireServer(true)
	end
end)

local OldGameEnd;OldGameEnd = hookfunction(getcallbackmember(RS.gameEnded,"OnClientInvoke"),function(Infos,...)
	Replay()

	return OldGameEnd(Infos,...)
end)

table.insert(Connections,function(dt)
	if Running and LocalPlayer.PlayerGui.StartUI.Enabled and LocalPlayer.PlayerGui.StartUI.Frame.Visible then
		Ready()
	end

	if autounfreeze then
		UnfreezeAllTowers()
	end


	if LockSpeed and Game.Speed.Value ~= tonumber(Speed) and os.clock() - lastSpeedSend > 1 then
		lastSpeedSend = os.clock()
		ChangeSpeed(tonumber(Speed))
	end
end)

if not GlobalTDMRunid then
	GlobalTDMRunid = TDMRunId

	RunService.PreSimulation:Connect(function(dt)
		for i,v in Connections do
			task.spawn(function()
				v(dt)
			end)
		end
	end)
end

]]

writefile("ChachedSkibiDefense",str)

loadstring(readfile("ChachedSkibiDefense"))()
