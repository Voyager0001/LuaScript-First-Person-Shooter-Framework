local fastcastHandler = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Properties
-- babababa unknown require
local fastcast = require(ReplicatedStorage.modules.fastCastRedux)
local random = Random.new()

-- create a caster, basically the gun
local mainCaster = fastcast.new()
local bullets = {}
local ContentProvider = game:GetService("ContentProvider")
local sparksHandler=require(ReplicatedStorage.modules.sparksHandler)
local isLaser=nil
local LaserOrigin=nil
local lastDirection=nil
local replicated
local repChar
local t=1 


--local KnockBack=nil


function createGrenade(origin, directionCF)
	local directionOffset=Properties.firing.directionOffset
	local velocity=Properties.firing.velocity
	local shell = ReplicatedStorage.grenade:Clone()
	shell.Position= origin
	--shell.Size = Vector3.new(1,1,1)
	--shell.BrickColor = BrickColor.new(226)
	shell.Parent = game.Workspace.fastCast
	shell.Position= origin
	shell.CanCollide = true
	shell.Transparency = 0
	shell.Name = "bullet"
	shell.Velocity = (directionCF * CFrame.fromOrientation(directionOffset[math.random(1,10)], directionOffset[math.random(1,10)], random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector*velocity
	--shell.RotVelocity = Vector3.new(0,200,0)

	--PhysicsService:SetPartCollisionGroup(shell, "Obstacles")
	local debounce=true
	shell.Touched:Connect(function(part)
		if part.Parent:FindFirstChild("Humanoid")~=nil and part.Parent~=game.Players.LocalPlayer.Character and part.Parent~=workspace.Camera:FindFirstChild("viewmodel") and part.Name~="bullet" and part.Name~="Start" and part.Name~="receiver" then
			if not replicated and debounce then
				debounce=false
				ReplicatedStorage.weaponRemotes.hit:FireServer(nil, nil, shell.Position)
			end
			
			shell:Destroy()
		end
	end)
	wait(Properties.firing.stopTime)
	shell.Velocity=(directionCF * CFrame.fromOrientation(directionOffset[math.random(1,10)], directionOffset[math.random(1,10)], random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector*0
	wait(Properties.firing.explodeTime)
	if not replicated and debounce then
		ReplicatedStorage.weaponRemotes.hit:FireServer(nil, nil, shell.Position)
	end
	shell:Destroy()
	

	--local shellmesh = Instance.new("SpecialMesh")
	--shellmesh.Scale = Vector3.new(.15,.4,.15)
	--shellmesh.Parent = shell
end




-- standard rayUpdated function; feel free to touch the code, just not the existing 2 lines
function rayUpdated(_, segmentOrigin, segmentDirection, length, bullet)
	if bullet==nil then return end
	local BulletLength = bullet.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	bullet.CFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection) * CFrame.new(0, 0, -(length - BulletLength))
	lastDirection=segmentDirection

end

-- Destroy the bullet, ask server to deal damage etc.
function rayHit(hitPart, hitPoint, normal, material, bullet)
	if bullet then bullet:Destroy()end
	
	if not hitPart then return end

	-- algorithm for finding damage parts
	-- still doesn't work for accessories
	
	--if not Properties then return end
	--if not Properties.firing then return end
	
	
	if Properties.firing.weaponType=="rocket" then
		ReplicatedStorage.weaponRemotes.hit:FireServer(nil, nil,  hitPoint)
		
	elseif isLaser==true then
		
		LaserOrigin.BeamEndAttachment.WorldCFrame = CFrame.new(hitPoint)
		LaserOrigin.Beam.Enabled = true
		LaserOrigin.BeamEndAttachment.BurnEffect.Enabled = true	
	
	else
		
		local model = hitPart:FindFirstAncestorOfClass("Model")

		-- if model exists and has a humanoid inside
		if model and model:FindFirstChildOfClass("Humanoid") then
			
			-- first child of the model in the hierarchy that has a humanoid class
			local humanoid = model:FindFirstChildOfClass("Humanoid")
			-- headshot = is hitPart a Head or an attachment with a HatAttachment inside?
			local headshot = hitPart.Name == "Head" or hitPart:FindFirstChild("HatAttachment")

			
			-- do NOT do this in a real game; it's awful game security and I will come to your house for tea if you do
			ReplicatedStorage.weaponRemotes.hit:FireServer(humanoid, hitPart, nil)
			local sound= script.hit:Clone()
			sound.Parent=workspace.CurrentCamera
			sound:Play()
			game:GetService("Debris"):AddItem(sound, sound.TimeLength)
			--if humanoid:GetState() ~= Enum.HumanoidStateType.Physics and humanoid.Health-Properties.firing.damage<=0 then --Properties.firing.weaponType=="shotgun"
			--	local TotalForce = 500
			--	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				
			--	--hitPart.Velocity=lastDirection*TotalForce
				
			--	local KnockBack = Instance.new("BodyForce")
			--	KnockBack.Parent = hitPart
			--	KnockBack.Force = lastDirection*TotalForce
				
			--	wait(3)
			--	KnockBack:Destroy()
			--end

			
		else
			--local e=Instance.new("Explosion", game.Workspace)
			--e.Position=hitPoint
			--e.BlastRadius=10
			
			sparksHandler:fire(hitPoint, normal, replicated, repChar, hitPart)
			
			
			
			-- hit effects like sparks
		end
	end
	
end

--- fires a bullet
function fastcastHandler:fire(origin: Vector3, direction: Vector3, properties, isReplicated, repCharacter)
	replicated=isReplicated
	
	local rawOrigin	= origin
	local rawDirection = direction
	
	
	
	Properties=properties
	
	-- if the propertie aren't already required just require them
	if type(properties) ~= "table" then 
		properties = require(properties)
		
	end
	local gravity=properties.firing.bulletGravity
	local directionalCFrame = CFrame.new(Vector3.new(), direction)			
	direction = (directionalCFrame * CFrame.fromOrientation(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector			
	
	if properties.firing.weaponType=="grenade" then
		
		isRocket=true
		local i=0
		while i<properties.firing.noOfPellets do
			spawn(function()
				createGrenade(rawOrigin, directionalCFrame)
			end)
			i=i+1
		end
		
		
		
		
		
		
		
		
		
	elseif properties.firing.weaponType=="rocket" then
		
		
		
		bullet = ReplicatedStorage.rocket:Clone()
		bullet.CFrame = CFrame.new(origin, origin + direction)
		bullet.Parent = workspace.fastCast
		bullet.Name="bullet"
		bullet.Loop.Playing=true
		--bullet.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 2)
	elseif properties.firing.weaponType=="rainbow" then
		
		
		bullet = ReplicatedStorage.Beam:Clone()
		bullet.CFrame = CFrame.new(origin, origin + direction)
		bullet.Parent = workspace.fastCast
		bullet.Name="bullet"
	elseif properties.firing.weaponType=="shotgun" or properties.firing.weaponType=="shotgun1" then	
		--local i=1
		--bulletTable={}
		--isRocket=false
		--gravity=ReplicatedStorage.bulletGravity.Value
		--while i<=9 do
		--	local bullet1 = ReplicatedStorage.bullet:Clone()
		--	bullet1.CFrame = CFrame.new(origin, origin + direction)
		--	bullet1.Parent = workspace.fastCast
		--	bullet1.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
		--	bulletTable[i]=bullet1
		--	i+=1
		--end
		
		directionOffset=properties.firing.directionOffset
		
		bullet1 = ReplicatedStorage.bullet:Clone()
		bullet1.CFrame = CFrame.new(origin, origin + direction)
		bullet1.Parent = workspace.fastCast
		bullet1.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
		bullet2 = ReplicatedStorage.bullet:Clone()
		bullet2.CFrame = CFrame.new(origin, origin + direction)
		bullet2.Parent = workspace.fastCast
		bullet2.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
		bullet3 = ReplicatedStorage.bullet:Clone()
		bullet3.CFrame = CFrame.new(origin, origin + direction)
		bullet3.Parent = workspace.fastCast
		bullet3.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
		bullet4 = ReplicatedStorage.bullet:Clone()
		bullet4.CFrame = CFrame.new(origin, origin + direction)
		bullet4.Parent = workspace.fastCast
		bullet4.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
		bullet5 = ReplicatedStorage.bullet:Clone()
		bullet5.CFrame = CFrame.new(origin, origin + direction)
		bullet5.Parent = workspace.fastCast
		bullet5.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
		bullet6 = ReplicatedStorage.bullet:Clone()
		bullet6.CFrame = CFrame.new(origin, origin + direction)
		bullet6.Parent = workspace.fastCast
		bullet6.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
		
	
	elseif properties.firing.weaponType=="laser" then
		
		
		bullet = ReplicatedStorage.bullet:Clone()
		bullet.CFrame = CFrame.new(origin, origin + direction)
		bullet.Parent = workspace.fastCast
		bullet.Transparency=1
		bullet.Trail.Enabled=false
		bullet.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
	else
		
		
		
		
		bullet = ReplicatedStorage.bullet:Clone()
		bullet.CFrame = CFrame.new(origin, origin + direction)
		bullet.Parent = workspace.fastCast
		bullet.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
		if properties.firing.color then
			bullet.BrickColor=properties.firing.color
			bullet.Trail.Color=ColorSequence.new(bullet.Color)
				
				
		end
		if t==4 then
			bullet.Trail.Enabled=true
		end
	end
	
	
	
	-- useful with the server security i made, almost useless in this fps demo
	local id = math.random(-100000,100000)
	local idValue = Instance.new("NumberValue")
	idValue.Name = "id"
	idValue.Value = id
	idValue.Parent = bullet

	bullets[id] = {
		properties = properties;
		replicated = isReplicated;
	}
	
	-- if not replicated shooting then replicate
	if not isReplicated then 
		ReplicatedStorage.weaponRemotes.fire:FireServer(rawOrigin, rawDirection, id)
	end
	repChar=repCharacter
	-- Custom list; blacklist humanoidrootparts too if your Players can croiuch and prone
	local customList = {}
	customList[#customList+1] = repCharacter
	customList[#customList+1] = workspace.Camera
	customList[#customList+1] = Players.LocalPlayer.Character
	
	
	-- fire the caster
	if properties.firing.weaponType=="shotgun" or properties.firing.weaponType=="shotgun1" then
		--local i=1
		--while i<=9 do
			
		--	local direction1 = (directionalCFrame * CFrame.fromOrientation(1.2, 1, random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector
		--	mainCaster:FireWithBlacklist(origin, direction1 * properties.firing.range, properties.firing.velocity, customList, bulletTable[i], true, Vector3.new(0, gravity, 0))
		--	i+=1
		--end	
		local direction1 = (directionalCFrame * CFrame.fromOrientation(directionOffset[math.random(1,10)], directionOffset[math.random(1,10)], random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector
		mainCaster:FireWithBlacklist(origin, direction1 * properties.firing.range, properties.firing.velocity, customList, bullet1, true, Vector3.new(0, gravity, 0))
		direction1 = (directionalCFrame * CFrame.fromOrientation(directionOffset[math.random(1,10)], directionOffset[math.random(1,10)], random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector
		mainCaster:FireWithBlacklist(origin, direction1 * properties.firing.range, properties.firing.velocity, customList, bullet2, true, Vector3.new(0, gravity, 0))
		direction1 = (directionalCFrame * CFrame.fromOrientation(directionOffset[math.random(1,10)], directionOffset[math.random(1,10)], random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector
		mainCaster:FireWithBlacklist(origin, direction1 * properties.firing.range, properties.firing.velocity, customList, bullet3, true, Vector3.new(0, gravity, 0))
		direction1 = (directionalCFrame * CFrame.fromOrientation(directionOffset[math.random(1,10)], directionOffset[math.random(1,10)], random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector
		mainCaster:FireWithBlacklist(origin, direction1 * properties.firing.range, properties.firing.velocity, customList, bullet4, true, Vector3.new(0, gravity, 0))
		direction1 = (directionalCFrame * CFrame.fromOrientation(directionOffset[math.random(1,10)], directionOffset[math.random(1,10)], random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector
		mainCaster:FireWithBlacklist(origin, direction1 * properties.firing.range, properties.firing.velocity, customList, bullet5, true, Vector3.new(0, gravity, 0))
		direction1 = (directionalCFrame * CFrame.fromOrientation(directionOffset[math.random(1,10)], directionOffset[math.random(1,10)], random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector
		mainCaster:FireWithBlacklist(origin, direction1 * properties.firing.range, properties.firing.velocity, customList, bullet6, true, Vector3.new(0, gravity, 0))
	elseif isLaser==true or properties.firing.weaponType=="laser" then
		
		mainCaster:FireWithBlacklist(origin, direction * properties.firing.range, properties.firing.velocity*100, customList, bullet, true, Vector3.new(0, gravity, 0))
	elseif 	properties.firing.weaponType=="grenade" then
		
	else
		
		mainCaster:FireWithBlacklist(origin, direction * properties.firing.range, properties.firing.velocity, customList, bullet, true, Vector3.new(0, gravity, 0))		
	end
	if t>=4 then 
		t=0
	else
		t+=1
	end		
end 

mainCaster.RayHit:Connect(rayHit)
mainCaster.LengthChanged:Connect(rayUpdated)

return fastcastHandler
