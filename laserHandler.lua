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
local properties=require(script.settings)
--local LCFrame=nil


-- standard rayUpdated function; feel free to touch the code, just not the existing 2 lines
function rayUpdated(_, segmentOrigin, segmentDirection, length, bullet)
	lastDirection=segmentDirection
	if bullet==nil then return end
	local BulletLength = bullet.Size.Z / 2 -- This is used to move the bullet to the right spot based on a CFrame offset
	bullet.CFrame = CFrame.new(segmentOrigin, segmentOrigin + segmentDirection) * CFrame.new(0, 0, -(length - BulletLength))
	

end

-- Destroy the bullet, ask server to deal damage etc.
function rayHit(hitPart, hitPoint, normal, material, bullet)
	if bullet then bullet:Destroy()end
	if LaserOrigin:FindFirstChild("att1")==nil and LaserOrigin:FindFirstChild("att0")==nil then return end
	if not hitPart  then LaserOrigin.att1.WorldCFrame=LaserOrigin.att0.WorldCFrame*CFrame.new(0,0,-200)  return end --LaserOrigin.att1.WorldPosition=LaserOrigin.att0.WorldCFrame.LookVector*100
	
	--LaserOrigin.att1.WorldPosition=hitPoint
	local distance=math.abs((hitPoint - LaserOrigin.att0.WorldPosition).Magnitude)-3
	--local s=Vector3.new(hitPoint.X, hitPoint.Y, hitPoint.Z)
	--print(distance, distance+3)
	LaserOrigin.att1.WorldCFrame=LaserOrigin.att0.WorldCFrame*CFrame.new(0,0,-distance)
	--LaserOrigin=nil
	
	--LCFrame=LaserOrigin.att1.WorldCFrame
	
	
end

--- fires a bullet
function fastcastHandler:fire(origin: Vector3, direction: Vector3, laserOrigin, isReplicated, repCharacter)
	replicated=isReplicated
	
	local rawOrigin	= origin
	local rawDirection = direction
	
	
	-- if the propertie aren't already required just require them
	if type(properties) ~= "table" then 
		properties = require(properties)
		
	end
	LaserOrigin=laserOrigin
	local gravity=0
	local directionalCFrame = CFrame.new(Vector3.new(), direction)			
	direction = (directionalCFrame * CFrame.fromOrientation(0, 0, random:NextNumber(0, math.pi * 2)) * CFrame.fromOrientation(0, 0, 0)).LookVector			
	
	
	
	--bullet = script.bullet:Clone()
	--bullet.CFrame = CFrame.new(origin, origin + direction)
	--bullet.Parent = workspace.fastCast
	--LaserOrigin.Beam.Attachment1=bullet.att1
	--bullet.Size = Vector3.new(0.05, 0.05, properties.firing.velocity / 200)
	
		
	
	
	
	
	-- useful with the server security i made, almost useless in this fps demo
	--local id = math.random(-100000,100000)
	--local idValue = Instance.new("NumberValue")
	--idValue.Name = "id"
	--idValue.Value = id
	--idValue.Parent = bullet

	--bullets[id] = {
	--	properties = properties;
	--	replicated = isReplicated;
	--}
	
	---- if not replicated shooting then replicate
	--if not isReplicated then 
	--	if  isLaser then
	--		ReplicatedStorage.weaponRemotes.fire:FireServer(rawOrigin, rawDirection, id, LaserOrigin)
	--	else
	--		ReplicatedStorage.weaponRemotes.fire:FireServer(rawOrigin, rawDirection, id)
	--	end
	--end
	--repChar=repCharacter
	-- Custom list; blacklist humanoidrootparts too if your Players can croiuch and prone
	local customList = {}
	customList[#customList+1] = repCharacter
	customList[#customList+1] = workspace.Camera
	customList[#customList+1] = Players.LocalPlayer.Character
	
	
		
	mainCaster:FireWithBlacklist(origin, direction * properties.firing.range, properties.firing.velocity, customList, nil, true, Vector3.new(0, gravity, 0))		
	
						
end 

mainCaster.RayHit:Connect(rayHit)
mainCaster.LengthChanged:Connect(rayUpdated)

return fastcastHandler
