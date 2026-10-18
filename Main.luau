local str = [[

queue_on_teleport("Teleported = true "..readfile("ChachedSkibiDefense"))

if not Teleported then
	delfile("TDM/SkibiDefense/settings.ini")
end

local getcallbackmember = getcallbackmember or getcallbackvalue --aa7ef56020000007a66
local game = game --e56020c0400000062626e60
local GetService = game.GetService --cc28610400000022626e20
local StarterGui = GetService(game,"StarterGui") --fefe25b1000000076667b262c2b676b68682c3b24637674
local SetCore = StarterGui.SetCore --a0d66d07000000526175436e7664
if not getcallbackmember then
	SetCore(StarterGui,"SendNotification",{
		Title = "TDM",
		Text = "注入器不支持",
	})
end

local HttpService = game:GetService("HttpService") --dcd03070b00000071444d3c1265333a50535c
local RS = game:GetService("ReplicatedStorage") --a54cd101100000052767067292821376527133f2f79617465
local RunService = game:GetService("RunService") --e66d3130a0000005877665763747261616f
local Players = game:GetService("Players") --d77cb6160700000051686079647672
local MarketplaceService = game:GetService("MarketplaceService") --f79521a120000001f23222f2b323c246b692d1f233c32392137
local LocalPlayer = Players.LocalPlayer --f1d1d0b0000004d67626d6d506d6d786d73

AlrLoaded1 = AlrLoaded1 or {}
AlrLoaded = AlrLoaded or {}

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


GetApi("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua")

Connections = {}

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local TDMRunId = HttpService:GenerateGUID(true)

local Starlight = loadstring(GetUrl("https://raw.githubusercontent.com/qian-cheng-awa/Tools/refs/heads/main/Starlight.luau"))()

local sus,gameinfo = pcall(function()
	return MarketplaceService:GetProductInfo(game.PlaceId)
end)
if not sus then
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
if game.PlaceId == 14279724900 then
	local Game = RS:WaitForChild("Game") --e8e4853e0400000042626e60
	local Chapter = RS:FindFirstChild("Chapter") --b9864207000000426c6070756173
	local RunTime = Game.Clock --fa03e8440700000053716f54686964

	local SkibiDefenseFolder = "TDM/SkibiDefense/" --a714912000000012939262742696e6f647b69402128342720

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
	local RecordFileName = GetChapter()
	local FILE = {
		AutoSkip = {},
		WaveSkip = {},
	}

	Tab:CreateToggle({
		Name = "录制",
		CurrentValue = Recording,
		Callback = function(Value)
			if Value then
				FILE = {
					AutoSkip = {},
					WaveSkip = {},
				}
			end
			Recording = Value
		end    
	})

	local RecordAutoSkip = false

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
			Folder[i] = string.gsub(v,`{SkibiDefenseFolder}{GetChapter()}`,"",1)
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


	local SavedCurrentCFG = {get("CurrentCFG",nil)}
	local CurrentCfg = SavedCurrentCFG[1]
	Files = Tab:CreateDropdown({
		Options = GetFiles(),
		Required = true,
		MultipleOptions = false,
		CurrentOption = SavedCurrentCFG,
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
							if not v.Runned and v.Tick < GetServerRunTime() then
								v.Runned = true
								AutoSkipRunning = v.Value
								RS.Event.waveSkip:FireServer(true)
							end
						elseif i == "WaveSkip" then
							if not v.Runned and v.Tick < GetServerRunTime() then
								v.Runned = true
								RS.Event.waveSkip:FireServer(true)
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
									v.SellTick = nil
									RS.Event.RemoveTower:FireServer(v.ID)
								end

								for i,t in v.Upgrade do
									if t < GetServerRunTime() then
										table.remove(v.Upgrade,i)
										RS.Event.UpgradeTower:FireServer(v.ID)
									end
								end

								for i,t in v.TargetMode do
									if t < GetServerRunTime() then
										table.remove(v.TargetMode,i)
										RS.Event.ChangeTowerTargetMode:FireServer(v.ID)
									end
								end

								for _,t in v.Ability do
									if not t.Runned and t.Tick < GetServerRunTime() then
										t.Runned = true
										RS.TowerScript.spawnTowerAbility:InvokeServer(v.ID,t.Name)
									end
								end

								for _,t in v.BoostSelect do
									if not t.Runned and t.Tick < GetServerRunTime() then
										t.Runned = true
										RS.BoostSelect:FireServer(v.ID,t.Name)
									end
								end

								for _,t in v.PencilCloneRequest do
									if not t.Runned and t.Tick < GetServerRunTime() then
										t.Runned = true
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
									end
								end

								for _,t in v.DrillMoveRequest do
									if not t.Runned and t.Tick < GetServerRunTime() then
										t.Runned = true
										local Position = string.split(t.CFrame,",")

										RS.Event.DrillMoveRequest:FireServer(
											v.ID,
											CFrame.new(
												tonumber(Position[1]),
												tonumber(Position[2]),
												tonumber(Position[3])
											)
										)
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
	

	local function RegistTower(TowerName,TowerCFrame,TowerGUID)
		FILE[tostring(TowerGUID)] = {
			Name = tostring(TowerName),
			CFrame = tostring(TowerCFrame.Position),
			ID = tostring(TowerGUID),
			Upgrade = {},
			TargetMode = {},
			Ability = {},
			Tick = GetServerRunTime(),
			BoostSelect = {},
			PencilCloneRequest = {},
		} --:: FileFormat
	end

	RS.Event.placeTower.OnClientEvent:Connect(function(Player,TowerName,TowerCFrame,TowerGUID,MaybeStats,IDKAbilityboolean)
		if Player == LocalPlayer then
			RegistTower(TowerName,TowerCFrame,TowerGUID)
		end
	end)

	RS.Event.waveSkip.OnClientEvent:Connect(function(p36, p37)
		if AutoSkipRunning or RecordAutoSkip then
			RS.Event.waveSkip:FireServer(true)
		end
	end)

	local IsA =  game.IsA

	local function Match(a,b)
		if a == b then
			return true
		end
	end

	for _,v in getconnections(LocalPlayer.PlayerGui:WaitForChild("autoskip").auto.MouseButton1Click) do
		if v.Function and rawget(getfenv(v.Function),"script") == RS.UIDisplay then
			local Enabled = getupvalue(v.Function,1)

			if Enabled then
				OriginalAutoSkip = Enabled
				table.insert(FILE.AutoSkip,{
					Tick = GetServerRunTime(),
					Value = Enabled
				})
			end

			local Old
			Old = hookfunction(v.Function,function()
				Old()
				if Recording then
					local Enabled = getupvalue(Old,1)
					OriginalAutoSkip = Enabled
					table.insert(FILE.AutoSkip,{
						Tick = GetServerRunTime(),
						Value = Enabled
					})
				end
			end)
		end
	end
	
	
	
	local OldNameCall
	OldNameCall = hookmetamethod(game,"__namecall",newcclosure(function(...)
		local method = string.lower(getnamecallmethod() or "")
		if not checkcaller() and Recording and typeof(...) == "Instance" then
			if method then
				
				local self = (...)
				local args = {select(2,...)}
				
				if method == "fireserver" and IsA(self,"RemoteEvent") then
					if Match(RS.Event.UpgradeTower,self) then
						local TowerGUID = args[1]

						task.spawn(function()
							if FILE[TowerGUID] then
								table.insert(FILE[TowerGUID].Upgrade,GetServerRunTime())
							end
						end)
					elseif Match(RS.Event.RemoveTower,self) then
						local TowerGUID = args[1]
						if FILE[TowerGUID] then
							FILE[TowerGUID].SellTick = GetServerRunTime()
						end
					elseif Match(RS.Event.ChangeTowerTargetMode,self) then
						local TowerGUID = args[1]
						if FILE[TowerGUID] then
							table.insert(FILE[TowerGUID].TargetMode,GetServerRunTime())
						end
					elseif Match(RS.BoostSelect,self) then
						local Tower1GUID = args[1]
						local Tower2GUID = args[2]

						if Tower1GUID and Tower2GUID and FILE[Tower1GUID] and FILE[Tower2GUID] then
							table.insert(FILE[Tower1GUID].BoostSelect,{
								Name = Tower2GUID,
								Tick = GetServerRunTime()
							})
						end
					elseif Match(RS.Event.PencilCloneRequest,self) then
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
					elseif Match(RS.Event.DrillMoveRequest,self) then
						local TowerGUID = args[1]
						local CFrame = args[2]

						if TowerGUID and CFrame and FILE[TowerGUID] then
							table.insert(FILE[TowerGUID].DrillMoveRequest,{
								Tick = GetServerRunTime(),
								CFrame = tostring(CFrame.Position),
							})
						end
					elseif Match(RS.Event.waveSkip,self) then
						table.insert(FILE.WaveSkip,{
							Tick = GetServerRunTime(),
						})
					end
				elseif method == "invokeserver" and IsA(self,"RemoteFunction") then
					if Match(RS.TowerScript.spawnTowerAbility,self) then
						local TowerGUID = args[1]
						local AbilityName = args[2]

						if TowerGUID and AbilityName and FILE[TowerGUID] then
							table.insert(FILE[TowerGUID].Ability,{
								Tick = GetServerRunTime(),
								Name = AbilityName,
							})
						end
					end
				end
			end
		end

		return OldNameCall(...)
	end))

	local GameEndedInvoke = getcallbackmember(game.ReplicatedStorage.gameEnded,"OnClientInvoke")

	local OldGameEnd
	OldGameEnd = hookfunction(GameEndedInvoke,function(Infos,...)
		Replay()

		return OldGameEnd(Infos,...)
	end)

	local lastSpeedSend = 0
	
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
	
	table.insert(Connections,function(dt)
		if LocalPlayer.PlayerGui.StartUI.Enabled and LocalPlayer.PlayerGui.StartUI.Frame.Visible then
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
elseif isfile("TDM/SkibiDefense/settings.ini") then
	delfile("TDM/SkibiDefense/settings.ini")
end

if not GlobalTDMRunid then
	GlobalTDMRunid = TDMRunId

	RunService.PreSimulation:Connect(function(dt)
		for i,v in Connections do
			v(dt)
		end
	end)
end
]]

writefile("ChachedSkibiDefense",str)

loadstring(readfile("ChachedSkibiDefense"))()
