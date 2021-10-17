local handler = {}
local fpsMT = {__index = handler}	
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local MyPlayer = Players.LocalPlayer
local MyMouse = MyPlayer:GetMouse()
local previousMouse=MyMouse.Icon
local uis = game:GetService("UserInputService")
local Camera = game.Workspace.CurrentCamera;
local phy = game:GetService("PhysicsService")
local fpOn=game.Players.LocalPlayer.PlayerScripts.fpOn
local equipped=game.Players.LocalPlayer.PlayerScripts.equipped
local nightVision=ReplicatedStorage.nightVision:Clone()
nightVision.Parent=game.Lighting
local sens=userInputService.MouseDeltaSensitivity
ReplicatedStorage:WaitForChild("modules")
ReplicatedStorage.modules:WaitForChild("fastCastHandler")
ReplicatedStorage.modules:WaitForChild("spring")
local fastcastHandler = require(ReplicatedStorage.modules.fastCastHandler)
local laserHandler = require(ReplicatedStorage.modules.laserHandler)
local spring = require(ReplicatedStorage.modules.spring)
local WeaponGui
local laserBreak
local runGUI
local runGUI2
local gui=game.Players.LocalPlayer.PlayerGui.sprint
local stamina=5
local staminaRecovery=4.5
local whiteoff
local backoff
local d

-- Functions i like using and you will probably too.
-- Bobbing!

local function getBobbing(addition, speed, modifier)
	return math.sin(tick()*addition*speed)*modifier
end



function handler.new(weapons)
	local self = {}

	self.loadedAnimations = {}
	self.springs = {}
	self.lerpValues = {}
	self.ammo = {} -- per weapon
	self.spareAmmo={}
	self.spareMag={}
	
	self.lerpValues.up=Instance.new("NumberValue")
	self.lerpValues.down=Instance.new("NumberValue")
	self.lerpValues.aim = Instance.new("NumberValue")
	self.lerpValues.run = Instance.new("NumberValue")
	self.lerpValues.jog = Instance.new("NumberValue")
	self.lerpValues.secAim= Instance.new("NumberValue")
	self.lerpValues.nvAim= Instance.new("NumberValue")
	self.lerpValues.equip = Instance.new("NumberValue") self.lerpValues.equip.Value = 1

	self.springs.walkCycle = spring.create();
	self.springs.sway = spring.create()
	self.springs.fire = spring.create()
	self.leftDebounce=false
	self.rightDebounce=false
	self.leftLeaning=false
	self.rightLeaning=false
	self.canFire = true
	self.loadedAnimations.idle = nil
	self.loadedAnimations.reload = nil
	self.loadedAnimations.fire = nil
	self.secAim=false
	self.atWallUp=false
	self.atWallDown=false
	self.light=false
	self.leanValue=Instance.new("NumberValue") self.leanValue.Value=math.rad(0)
	self.cOffsetValue=Instance.new("NumberValue")
	self.cDownValue=Instance.new("NumberValue")
	self.cOffsetStart=0
	self.running=false
	self.crouchValue=-2
	self.proneValue=-3.6
	self.crouching=false
	self.proning=false
	self.jog=false
	self.canAim=true
	
	self.nv=false
	self.state=0
	return setmetatable(self,fpsMT)
end

local fastcastHandler = {}

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Properties

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
