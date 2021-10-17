local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("weaponRemotes")
local weapons = ReplicatedStorage:WaitForChild("weapons")
local GetMouseFollowFunction = ReplicatedStorage.GetMouseFollowFunction
local wepParent="UpperTorso"
local wepHold="RightHand" 
local sprintValue=26
local jogValue=18
local walkValue=13
local baseValue=13
local crouchValue=8
local proneValue=4
local jump=7.2
local phy=game:GetService("PhysicsService")
phy:CreateCollisionGroup("player")
phy:CreateCollisionGroup("viewmodel")
phy:CollisionGroupSetCollidable("player", "viewmodel", false)
--local PhysicsService = game:GetService("PhysicsService")
---- Create two collision groups
--PhysicsService:CreateCollisionGroup("Obstacles")
--PhysicsService:CreateCollisionGroup("GreenObjects")
--PhysicsService:CollisionGroupSetCollidable("GreenObjects", "Obstacles", false)

-- ayyYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY[...]
local players = {} -- table for keeping track of weapons
local defaultWeapons = {
	[1]="ar15";
	
}
-- feel free to separate this
-- this is the amount of ammo each gun gets spare
local magazineCount = 5

-- each time the player spawns, they get a new weapon slot:
remotes:WaitForChild("new").OnServerInvoke = function(player)

	if not player.Character then return end

	-- we create a new table for the player
	players[player.UserId] = {}
	local weaponTable = players[player.UserId]

	-- some stuff for later
	weaponTable.magData = {}
	weaponTable.weapons = {}
	weaponTable.loadedAnimations = {}

	-- add each available weapon
	for index, weaponName in pairs(defaultWeapons) do 

		-- clone gun
		local weapon = weapons[weaponName]:Clone()
		local weaponSettings = require(weapon.settings)

		-- index gun
		weaponTable.weapons[weaponName] = { weapon = weapon; settings = weaponSettings }

		-- not used in the tutorial
		-- save gun magazines
		weaponTable.magData[index] = { current = weaponSettings.firing.magCapacity; spare = weaponSettings.firing.magCapacity * magazineCount  }
		--  holster goon
		

	end
	

	-- we give the client the gun list

	return defaultWeapons, weaponTable.magData
end


remotes:WaitForChild("add").OnServerEvent:Connect(function(player, index)
	
	local weaponName=defaultWeapons[index]
	local weapon = weapons[weaponName]:Clone()
	local weaponSettings = require(weapon.settings)

	-- index gun
	
	
	
	--hide(weapon)
	weapon.Parent = player.Character
	weapon.receiver.weaponHold.Part1=weapon.receiver
	weapon.receiver.backweld.Part1=weapon.receiver
	weapon.receiver.backweld.Part0 = player.Character[wepParent]
	weapon.receiver.backweld.C1=weaponSettings.firing.cframe
	
	for i, v in pairs(weapon:GetDescendants()) do
		if v:IsA("BasePart") then
			phy:SetPartCollisionGroup(v, "player")
		end

	end
			
end)

remotes:WaitForChild("rmove").OnServerEvent:Connect(function(player, index)
	
	local weaponName=defaultWeapons[index]
	if player.Character:FindFirstChild(weaponName)~=nil then
		player.Character:FindFirstChild(weaponName):Destroy()
	end

end)

remotes:WaitForChild("equip").OnServerInvoke = function(player, wepName)

	if players[player.UserId].currentWeapon then return end
	if not players[player.UserId].weapons then return end
	if not players[player.UserId].weapons[wepName] then return end
	if not player.Character then return end 
	local weaponTable = players[player.UserId]
	
	-- we mark the current gun
	weaponTable.currentWeapon = player.Character:FindFirstChild(wepName)
	if weaponTable.currentWeapon==nil then return false end
	player.gun.Value = weaponTable.currentWeapon

	--  unholster goon
	--unhide(weaponTable.currentWeapon)
	local weaponSettings = require(weaponTable.currentWeapon.settings)
	weaponTable.currentWeapon.Parent = player.Character
	weaponTable.currentWeapon.receiver.backweld.Part0 = nil
	

	-- equip gun
	weaponTable.currentWeapon.receiver.weaponHold.Part0 = player.Character[wepHold]
	
	
	weaponTable.loadedAnimations.serverIdle = player.Character.Humanoid:LoadAnimation(weaponTable.currentWeapon.settings.animations.player.serverIdle)
	weaponTable.loadedAnimations.serverIdle:Play()
	
	weaponTable.loadedAnimations.left=player.character.Humanoid:LoadAnimation(script.Left)
	weaponTable.loadedAnimations.right=player.character.Humanoid:LoadAnimation(script.Right)
	weaponTable.loadedAnimations.serverAimAnim=player.character.Humanoid:LoadAnimation(script.serverAim)
	weaponTable.loadedAnimations.holster=player.character.Humanoid:LoadAnimation(script.holster)
	weaponTable.loadedAnimations.crouchToStand=player.character.Humanoid:LoadAnimation(script.crouchToStand)
	weaponTable.loadedAnimations.standToCrouch=player.character.Humanoid:LoadAnimation(script.standToCrouch)
	weaponTable.loadedAnimations.crouchLoop=player.character.Humanoid:LoadAnimation(script.crouchLoop)
	weaponTable.loadedAnimations.crouchWalk=player.character.Humanoid:LoadAnimation(script.crouchWalk)
	weaponTable.loadedAnimations.proneLoop=player.character.Humanoid:LoadAnimation(script.proneLoop)
	weaponTable.loadedAnimations.proneMoveLoop=player.character.Humanoid:LoadAnimation(script.proneMoveLoop)
	
	
	weaponTable.loadedAnimations.crouchToStand.Looped=false
	weaponTable.loadedAnimations.standToCrouch.Looped=false
	weaponTable.loadedAnimations.crouchLoop.Looped=true
	weaponTable.loadedAnimations.crouchWalk.Looped=true


	weaponTable.loadedAnimations.proneLoop.Looped=true
	weaponTable.loadedAnimations.proneMoveLoop.Looped=true
	weaponTable.loadedAnimations.proneLoop.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.proneMoveLoop.Priority=Enum.AnimationPriority.Action

	weaponTable.loadedAnimations.crouchToStand.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.standToCrouch.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.crouchLoop.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.crouchWalk.Priority=Enum.AnimationPriority.Action


	weaponTable.loadedAnimations.holster.Looped=true
	weaponTable.loadedAnimations.left.Looped=false
	weaponTable.loadedAnimations.left.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.right.Looped=false
	weaponTable.loadedAnimations.right.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.serverAimAnim.Looped=true
	weaponTable.loadedAnimations.serverAimAnim.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.holster.Priority=Enum.AnimationPriority.Action

	
	weaponTable.loadedAnimations.serverIdle.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.serverAim.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.serverAimFire.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.serverIdleFire.Priority=Enum.AnimationPriority.Action
	weaponTable.loadedAnimations.serverReload.Priority=Enum.AnimationPriority.Action

	
	weaponTable.loadedAnimations.serverIdle.Looped=true
	weaponTable.loadedAnimations.serverIdle:Play()	
	weaponTable.loadedAnimations.serverReload.Looped=false
	weaponTable.loadedAnimations.serverAim.Looped=true
	weaponTable.loadedAnimations.reload.Looped=false
	
	

	-- yes client u can equip gun

	return true
end

-- aiiiiimingggggggggggggg
remotes:WaitForChild("aim").OnServerEvent:Connect(function(player, toaim)

	if not players[player.UserId].currentWeapon then return end
	if not player.Character then return end 
	local weaponTable = players[player.UserId]

	-- we mark this for firing animations
	weaponTable.Aiming = toaim

	-- load the aim animation
	if not weaponTable.loadedAnimations.serverAim then 

		weaponTable.loadedAnimations.serverAim = player.Character.Humanoid:LoadAnimation(weaponTable.currentWeapon.settings.animations.player.serverAim)
		weaponTable.loadedAnimations.serverAim.Looped=true
		weaponTable.loadedAnimations.serverAim.Priority=Enum.AnimationPriority.Movement
	end

	-- play or stop it
	if toaim then 

		weaponTable.loadedAnimations.serverAim:Play()

	else

		weaponTable.loadedAnimations.serverAim:Stop()

	end 

end)

-- reverse of equipping lol
remotes:WaitForChild("unequip").OnServerInvoke = function(player)

	if not players[player.UserId].currentWeapon then return end
	if not player.Character then return end 
	local weaponTable = players[player.UserId] or player[player.UserId]:Wait()

	if weaponTable.loadedAnimations.serverIdle ~= nil then
		weaponTable.loadedAnimations.serverIdle:Stop()
	elseif weaponTable.loadedAnimations.serverIdleFire ~= nil then
		weaponTable.loadedAnimations.serverIdleFire:Stop()
	elseif weaponTable.loadedAnimations.serverAimFire ~= nil then
		weaponTable.loadedAnimations.serverAimFire:Stop()
	elseif weaponTable.loadedAnimations.serverAim ~= nil then
		weaponTable.loadedAnimations.serverAim:Stop()
	end
	weaponTable.loadedAnimations = {}

	-- holster gun and unequip gun
	-- if joint is alive, might need more protection if player falls off the baseplate
	if weaponTable.currentWeapon:FindFirstChild("receiver")~=nil then
		if weaponTable.currentWeapon.receiver:FindFirstChild("weaponHold")~=nil then
			local weaponSettings = require(weaponTable.currentWeapon.settings)

			weaponTable.currentWeapon.Parent = player.Character
			weaponTable.currentWeapon.receiver.backweld.Part0 =  player.Character[wepParent]

			weaponTable.currentWeapon.receiver.weaponHold.Part0 = nil
			--hide(weaponTable.currentWeapon)

		end
	else
		local weaponName=weaponTable.currentWeapon.Name
		if player.Character:FindFirstChild(weaponName)~=nil then
			player.Character:FindFirstChild(weaponName):Destroy()
		end
	end
	-- we mark the inexistence of the current gun
	weaponTable.currentWeapon = nil
	player.gun.Value = nil

	-- 
	return true

end



GetMouseFollowFunction.OnServerEvent:Connect(function(player,CameraSubject,PlayerMouseHit, NeckOriginC0, WaistOriginC0, RightOriginC0, LeftOriginC0)
	GetMouseFollowFunction:FireAllClients(player,CameraSubject,PlayerMouseHit, NeckOriginC0, WaistOriginC0, RightOriginC0, LeftOriginC0)
end)

-- pew
remotes:WaitForChild("fire").OnServerEvent:Connect(function(player, origin, direction)

	local weaponTable = players[player.UserId]
	if not weaponTable.currentWeapon then return end
	if not player.Character then return end 

	-- DO NOT do this without verification
	-- we replicate the changes to other clients
	remotes.fire:FireAllClients(player, origin, direction)

	if weaponTable.Aiming then 

		if not weaponTable.loadedAnimations.serverAimFire then 

			weaponTable.loadedAnimations.serverAimFire = player.Character.Humanoid:LoadAnimation(weaponTable.currentWeapon.settings.animations.player.serverAimFire)
			weaponTable.loadedAnimations.serverAimFire.Looped=false
		end	

		weaponTable.loadedAnimations.serverAimFire:Play()	
		if weaponTable.loadedAnimations.serverIdleFire then
			weaponTable.loadedAnimations.serverIdleFire:Stop()
		end	
	else

		if not weaponTable.loadedAnimations.serverIdleFire then 

			weaponTable.loadedAnimations.serverIdleFire = player.Character.Humanoid:LoadAnimation(weaponTable.currentWeapon.settings.animations.player.serverIdleFire)
		end	
		if weaponTable.loadedAnimations.serverAimFire then
			weaponTable.loadedAnimations.serverAimFire:Stop()
		end	
		weaponTable.loadedAnimations.serverIdleFire:Play()			

	end

end)

remotes:WaitForChild("laser").OnServerEvent:Connect(function(player, enabled)

	local weaponTable = players[player.UserId]
	if not weaponTable.currentWeapon then return end
	if not player.Character then return end 

	remotes.laser:FireAllClients(player, enabled)

	

end)

remotes:WaitForChild("flashlight").OnServerEvent:Connect(function(player, enabled)

	local weaponTable = players[player.UserId]
	if not weaponTable.currentWeapon then return end
	if not player.Character then return end 

	remotes.flashlight:FireAllClients(player, enabled)



end)




-- player hit event
-- i will also point out here as well that this is a bad method since a *certain* human being decided to not read the client side of this
-- arsenal had a literal cheater takeover this summer because they didn't verify hit security, don't be like them 
-- https://pastebin.com/zLHzyzHq
remotes:WaitForChild("hit").OnServerEvent:Connect(function(player, humanoid, hitpart, hitPoint)

	if not players[player.UserId].currentWeapon then return end
	if not player.Character then return end 
	local wepSetting=require(weapons[players[player.UserId].currentWeapon.Name].settings)
	if hitpart.Name=="Head" then 
		--local prevHealth = humanoid.Health
		humanoid:TakeDamage(wepSetting.firing.head)
		--if humanoid.Health <= 0 and prevHealth > 0 then
		--	game.ReplicatedStorage.Events.KillFeed:FireAllClients(player,humanoid)
		--	local killer = Instance.new("ObjectValue",humanoid)
		--	killer.Name = "Killer"
		--	killer.Value = player
		--end
	elseif wepSetting.firing.weaponType=="rocket" then

		local ex = Instance.new("Explosion",game.Workspace)
		local sound=game.ReplicatedStorage.ExplosionSound:Clone()
		sound.Parent=ex
		sound:Play()
		ex.Position = hitPoint
		ex.BlastRadius = 3
	--elseif players[player.UserId].currentWeapon.settings.firing.weaponType=="taser" then
	--	humanoid:TakeDamage(players[player.UserId].currentWeapon.settings.firing.damage)
	--	 if humanoid:GetState() ~= Enum.HumanoidStateType.Physics then 
	--		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	--		wait(3)
	--		if humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
	--			humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	--		end
	--	end
	elseif  hitpart.Name=="LeftUpperArm" or hitpart.Name=="LeftLowerArm" or hitpart.Name=="LeftHand" or hitpart.Name=="RightUpperArm" or hitpart.Name=="RightLowerArm" or hitpart.Name=="RightHand" or hitpart.Name=="Right Arm" or hitpart.Name=="Left Arm" then
		
		local prevHealth = humanoid.Health
		humanoid:TakeDamage(wepSetting.firing.arm)
		--if humanoid.Health <= 0 and prevHealth > 0 then
		--	game.ReplicatedStorage.Events.KillFeed:FireAllClients(player,humanoid)
		--	local killer = Instance.new("ObjectValue",humanoid)
		--	killer.Name = "Killer"
		--	killer.Value = player
		--end
	elseif  hitpart.Name=="LeftUpperLeg" or hitpart.Name=="LeftLowerLeg" or hitpart.Name=="LeftFoot" or hitpart.Name=="RightUpperLeg" or hitpart.Name=="RightLowerLeg" or hitpart.Name=="RightFoot" or hitpart.Name=="Right Leg" or hitpart.Name=="Left Leg" then

		local prevHealth = humanoid.Health
		humanoid:TakeDamage(wepSetting.firing.leg)
		--if humanoid.Health <= 0 and prevHealth > 0 then
		--	game.ReplicatedStorage.Events.KillFeed:FireAllClients(player,humanoid)
		--	local killer = Instance.new("ObjectValue",humanoid)
		--	killer.Name = "Killer"
		--	killer.Value = player
	elseif  hitpart.Name=="UpperTorso" or  hitpart.Name=="LowerTorso" or  hitpart.Name=="Torso" or hitpart.Name=="HumanoidRootPart" then

		local prevHealth = humanoid.Health
		humanoid:TakeDamage(wepSetting.firing.torso)
		--if humanoid.Health <= 0 and prevHealth > 0 then
		--	game.ReplicatedStorage.Events.KillFeed:FireAllClients(player,humanoid)
		--	local killer = Instance.new("ObjectValue",humanoid)
		--	killer.Name = "Killer"
		--	killer.Value = player
	end 
end)


GetMouseFollowFunction.OnServerEvent:Connect(function(player,CameraSubject,PlayerMouseHit, NeckOriginC0, WaistOriginC0, RightOriginC0, LeftOriginC0)
	GetMouseFollowFunction:FireAllClients(player,CameraSubject,PlayerMouseHit, NeckOriginC0, WaistOriginC0, RightOriginC0, LeftOriginC0)
end)

-- for making a gun variable
Players.PlayerAdded:Connect(function(player)

	-- this method of adding values to the player on-added is much better than pasting the same code all over again.
	-- the gun variable is incredibly useful for keeping track of the gun inside other scripts, such as procedural animations w/ foot planting
	-- why did i mention that earlier? because I used to copy paste variables over and over in older games.
	local values = {
		{ name = "gun"; value = nil; type = "ObjectValue" };
	}

	-- table good c+p bad
	for _, v in pairs(values) do
		local value = Instance.new(v.type)
		value.Name = v.name
		value.Value = v.value
		value.Parent = player
	end

end)

remotes.run.OnServerEvent:Connect(function(player, run)
	if run then
		local tweeningInformation = TweenInfo.new(2, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		game:GetService("TweenService"):Create(player.Character.speed, tweeningInformation, { Value = sprintValue }):Play()
	else
		local tweeningInformation = TweenInfo.new(2, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		game:GetService("TweenService"):Create(player.Character.speed, tweeningInformation, { Value = baseValue }):Play()
	end
end)


remotes.crouch.OnServerEvent:Connect(function(player, crouch)
	if crouch then
		local tweeningInformation = TweenInfo.new(2, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		game:GetService("TweenService"):Create(player.Character.speed, tweeningInformation, { Value = crouchValue }):Play()
		--player.Character.Humanoid.JumpHeight=0
	else
		local tweeningInformation = TweenInfo.new(2, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		game:GetService("TweenService"):Create(player.Character.speed, tweeningInformation, { Value = baseValue }):Play()
		--player.Character.Humanoid.JumpHeight=jump
	end
end)

remotes.jog.OnServerEvent:Connect(function(player, jog)
	if jog then
		local tweeningInformation = TweenInfo.new(2, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		game:GetService("TweenService"):Create(player.Character.speed, tweeningInformation, { Value = jogValue }):Play()
		baseValue=jogValue
		--player.Character.Humanoid.JumpHeight=0
	else
		local tweeningInformation = TweenInfo.new(2, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		game:GetService("TweenService"):Create(player.Character.speed, tweeningInformation, { Value = walkValue }):Play()
		baseValue=walkValue
		--player.Character.Humanoid.JumpHeight=jump
	end
end)

remotes.prone.OnServerEvent:Connect(function(player, prone)
	if prone then
		local tweeningInformation = TweenInfo.new(2, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		game:GetService("TweenService"):Create(player.Character.speed, tweeningInformation, { Value = proneValue }):Play()
		--player.Character.Humanoid.JumpHeight=0
	else
		local tweeningInformation = TweenInfo.new(2, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		game:GetService("TweenService"):Create(player.Character.speed, tweeningInformation, { Value = baseValue }):Play()
		--player.Character.Humanoid.JumpHeight=jump
	end
end)


function hide(weapon)
	for i, v in pairs(weapon:GetChildren()) do
		if v:IsA("BasePart") and v.Name~="weaponRootPart"  then
			v.Transparency=1
		end
		if v.Name=="reticle" then
			if v:FindFirstChildWhichIsA("Decal")~=nil then
				v:FindFirstChildWhichIsA("Decal").Transparency=1
			end
		end
	end
end

function unhide(weapon)
	for i, v in pairs(weapon:GetChildren()) do
		if v:IsA("BasePart") and v.Name~="weaponRootPart"  then
			v.Transparency=0
		end
		if v.Name=="reticle" then
			if v:FindFirstChildWhichIsA("Decal")~=nil then
				v:FindFirstChildWhichIsA("Decal").Transparency=0
			end
		end
	end
end

remotes.equip1.OnServerEvent:Connect(function(player, i) 
	remotes.equip1:FireClient(player, i)
end)
remotes.unequip1.OnServerEvent:Connect(function(player) 
	remotes.unequip1:FireClient(player)
end)
