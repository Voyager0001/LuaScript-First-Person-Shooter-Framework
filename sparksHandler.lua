local fastcastHandler = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Properties
-- babababa unknown require
local fastcast = require(ReplicatedStorage.modules.fastCastRedux)
local Thread = require(ReplicatedStorage.modules.Thread)
local random = Random.new()

-- create a caster, basically the gun
local mainCaster = fastcast.new()
local bullets = {}
local ContentProvider = game:GetService("ContentProvider")


local lastDirection=nil
local replicated
local properties=require(script.settings)

--local KnockBack=nil

-- standard rayUpdated function; feel free to touch the code, just not the existing 2 lines
function rayUpdated(_, segmentOrigin, segmentDirection, length, bullet)
	
	local BulletLength = bullet.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	bullet.CFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection) * CFrame.new(0, 0, -(length - BulletLength))
	lastDirection=segmentDirection

end

-- Destroy the bullet, ask server to deal damage etc.
function rayHit(hitPart, hitPoint, normal, material, bullet)
	if bullet then bullet:Destroy()end
end

local function numLerp(A, B, Alpha)
	return A + (B - A) * Alpha
end

function bullethole(part, surfaceCF, Time)
	local Hole = Instance.new("Part")
	Hole.Name = "BulletHole"
	Hole.Transparency = 1
	Hole.Anchored = true
	Hole.CanCollide = false
	Hole.FormFactor = "Custom"
	Hole.Size = Vector3.new(1, 1, 0.2)
	Hole.TopSurface = 0
	Hole.BottomSurface = 0
	local Mesh = Instance.new("BlockMesh")
	Mesh.Offset = Vector3.new(0, 0, 0)
	Mesh.Scale = Vector3.new(0.5, 0.5, 0)
	Mesh.Parent = Hole
	local Decal = Instance.new("Decal")
	Decal.Face = Enum.NormalId.Front
	Decal.Texture = "rbxassetid://2078626"
	--print(Decal.Texture)
	local hitPartColor =  part.Color or Color3.fromRGB(255, 255, 255)
	if part and part:IsA("Terrain") then
		hitPartColor = workspace.Terrain:GetMaterialColor(Enum.Material.Sand)
	end
		
	Decal.Color3 = hitPartColor
	
	Decal.Parent = Hole
	Hole.Parent = workspace.CurrentCamera
	Hole.CFrame = surfaceCF * CFrame.Angles(0, 0, math.random(0, 360))
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = Hole
	weld.Part1 = part
	weld.Parent = Hole
	Hole.Anchored = false
	
	local attachment=Instance.new("Attachment", Hole)
	
	
	for i, v in pairs(script:GetChildren()) do
		if v.Name=="smoke" then
			local a=v:Clone()
			a.Parent=attachment
		end
	end
	for i, v in pairs(attachment:GetChildren()) do
		if v.Name=="smoke" then
			v.Enabled=true
		end
	end
	wait()
	for i, v in pairs(attachment:GetChildren()) do
		if v.Name=="smoke" then
			v.Enabled=false
		end
	end
	
	
	Thread:Delay(Time, function()
		if Time > 0 then
			local t0 = tick()
			while true do
				local Alpha = math.min((tick() - t0) / Time, 1)
				Decal.Transparency = numLerp(0, 1, Alpha)
				if Alpha == 1 then break end
				game:GetService("RunService").Heartbeat:Wait()
			end
			Hole:Destroy()
		else
			Hole:Destroy()
		end
	end)
end


--- fires a bullet
function fastcastHandler:fire(origin: Vector3, direction: Vector3, isReplicated, repCharacter, part)
	
	local i=1
	
	local surfaceCF = CFrame.new(origin, origin + direction)
	bullethole(part, surfaceCF, properties.firing.bulletHoleTime)
	
	while i<=properties.firing.noOfSparks do
		replicated=isReplicated

		local rawOrigin	= origin
		local rawDirection = direction
		

		local gravity=properties.firing.bulletGravity
		local directionalCFrame = CFrame.new(Vector3.new(), direction)			
		direction = (directionalCFrame * CFrame.fromOrientation(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector			





		local bullet = script.bullet:Clone()
		bullet.CFrame = CFrame.new(origin, origin + direction)
		bullet.Parent = workspace.fastCast
		bullet.Size = Vector3.new(0.1, 0.1, .1)
		
		bullet.BrickColor=part.BrickColor
		bullet.Material=part.Material
		bullet.Trail.Color=ColorSequence.new(bullet.Color)
		





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

		-- Custom list; blacklist humanoidrootparts too if your Players can crouch and prone
		local customList = {}
		customList[#customList+1] = repCharacter
		customList[#customList+1] = workspace.Camera
		customList[#customList+1] = Players.LocalPlayer.Character


		-- fire the caster
		

		local direction1 = (directionalCFrame * CFrame.fromOrientation(math.random(-100,100)*.01,math.random(-100,100)*.01, random:NextNumber(0, math.pi * 2))*CFrame.fromOrientation(0, 0, 0)).LookVector --
		mainCaster:FireWithBlacklist(origin, direction1 * properties.firing.range, properties.firing.velocity, customList, bullet, true, Vector3.new(0, properties.firing.bulletGravity, 0))

		i+=1
	end
	
						
end 



mainCaster.RayHit:Connect(rayHit)
mainCaster.LengthChanged:Connect(rayUpdated)

return fastcastHandler
