-- modernized 14/09/2020

-- Coolio module stuff
print("FPS system by blackshibe. Build by tonyredgraveX (massive0of, voyager0001)")
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





function handler:changeView()
	if not self.equipped then return end
	
	if fpOn.Value==false then

		self.invisible=false
		fpOn.Value=true


		self.hide=false
		local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = self.cOffsetStart }):Play()

	elseif fpOn.Value==true then
		self.invisible=true

		fpOn.Value=false

		self.hide=true
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
		self.viewmodel.rootPart.CFrame = CFrame.new(0, -100, 0)

	end
end





function handler:equip(wepName)

	-- Explained how this works earlier. we can store variables too!
	-- if the weapon is disabled, or equipped, remove it instead
	
	--if self.disabled then return end
	if self.equipping then return end
	if self.equipped then self:remove() end
	if self.reloading then return end
	if self.modeChanging then return end
	MyMouse.Icon = "http://www.roblox.com/asset/?id=18662154"
	--MyPlayer.CameraMode=Enum.CameraMode.LockFirstPerson
	--self.secAim=false
	self.name=wepName
	self.invisible=true
	-- get weapon from storage
	self.equipping=true
	
	equipped.Value=true
	self.Laser=false
	--userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	local weapon = ReplicatedStorage.weapons:FindFirstChild(wepName) -- do not cloen 
	if not weapon then return end -- if the weapon exists, clone it, else, stop
	weapon = weapon:Clone()

       --[[
	
	 	Make a viewmodel (easily accessible with weapon.viewmodel too!) 
		and throw everything in the weapon straight inside of it. This makes animation hierarchy work.
		
	--]]
	
	
	self.viewmodel = ReplicatedStorage.viewmodel:Clone()
	
	for _, v in pairs(weapon:GetChildren()) do
		v.Parent = self.viewmodel
		if v:IsA("BasePart") then
			--phy:SetPartCollisionGroup(v, "viewmodel")
			v.CanCollide = false
			v.CastShadow = false
		end
		--if v:IsA("BasePart") and v.name~="weaponRootPart" and v.name~="rootPart" and  v.name~="reticle" and game.StarterPlayer.fpOn.Value==false then
			
		--	v.Transparency= 1
		--	self.viewmodel["Left Arm"].Transparency=1
		--	self.viewmodel["Right Arm"].Transparency=1
		--end
		if v.name=="origin" then
			for _, w in pairs(v:GetChildren()) do
				w.Parent=v
			end
		end
		if v.Name=="Front Rail"  or v.Name=="receiver" then
			v.CanCollide =true
		end
		--if v.name=="reticle" and game.StarterPlayer.fpOn.Value==false then
		--	v:FindFirstChildWhichIsA("Decal").Transparency=1
		--end
	end		
	
	self.viewmodel.receiver.weaponHold:Destroy()
	self.viewmodel.receiver.backweld:Destroy()
	for  _, v in pairs(self.viewmodel:GetDescendants()) do
		if v:IsA("BasePart") then
			phy:SetPartCollisionGroup(v, "viewmodel")
		end

	end
	-- Time for automatic rigging and some basic properties
	self.camera = workspace.CurrentCamera
	self.camera.FieldOfView=70
	self.FOV=self.camera.FieldOfView
	self.character = MyPlayer.Character
	if self.character:FindFirstChild("Pants")~=nil then
		self.Pants=self.character.Pants:Clone()
		self.Pants.Parent=self.viewmodel
	end
	if self.character:FindFirstChild("Shirt")~=nil then
		self.Shirt=self.character.Shirt:Clone()
		self.Shirt.Parent=self.viewmodel
	end	
	if self.character:FindFirstChild("Body Colors")~=nil then
		self["Body Colors"]=self.character["Body Colors"]:Clone()
		self["Body Colors"].Parent=self.viewmodel
	end
	
	
	-- Throw the viewmodel under the map. It will go back to the camera the next render frame once we get to moving it.
	self.viewmodel.rootPart.CFrame = CFrame.new(0, -100, 0)
	if fpOn.Value==false then
		self.hide=true
		self.cOffsetStart=2
		local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
	else
		self.hide=false
		self.cOffsetStart=0
		local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
	end
	-- We're making the gun bound to the viewmodel's rootpart, and making the arms move along with the viewmodel using hierarchy.
	
	
	
	self.viewmodel.rootPart.weapon.Part1 = self.viewmodel.weaponRootPart
	self.viewmodel["Left Arm"].leftHand.Part0 = self.viewmodel.weaponRootPart
	self.viewmodel["Right Arm"].rightHand.Part0 = self.viewmodel.weaponRootPart
	-- I legit forgot to do this in the first code revision.
	self.viewmodel.Parent = workspace.Camera
	
	

	self.settings = require(self.viewmodel.settings)--AAAAAAAAAAAAAAAAAAAHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH

	
	if self.loadedAnimations.idle ~= nil then
		self.loadedAnimations.idle:Stop()
	end
	if self.loadedAnimations.reload ~= nil then
		self.loadedAnimations.reload:Stop()
	end
	if self.loadedAnimations.fire ~= nil then
		self.loadedAnimations.fire:Stop()
	end
	if self.loadedAnimations.serverIdle ~= nil then
		self.loadedAnimations.serverIdle:Stop()
	end
	if self.loadedAnimations.serverAim ~= nil then
		self.loadedAnimations.idle:Stop()
	end
	if self.loadedAnimations.serverAimFire ~= nil then
		self.loadedAnimations.reload:Stop()
	end
	if self.loadedAnimations.serverIdleFire ~= nil then
		self.loadedAnimations.fire:Stop()
	end
	if self.loadedAnimations.serverReload ~= nil then
		self.loadedAnimations.serverIdle:Stop()
	end
	if self.loadedAnimations.left ~= nil then
		self.loadedAnimations.left:Stop()
	end
	if self.loadedAnimations.right ~= nil then
		self.loadedAnimations.right:Stop()
	end
	if self.loadedAnimations.aimAnim ~= nil then
		self.loadedAnimations.aimAnim:Stop()
	end
	
	if self.loadedAnimations.run~=nil then
		self.loadedAnimations.run:Stop()
	end
	
	
	
	
	self.loadedAnimations.idle = self.viewmodel.Humanoid:LoadAnimation(self.settings.animations.viewmodel.idle)
	self.loadedAnimations.reload = self.viewmodel.Humanoid:LoadAnimation(self.settings.animations.viewmodel.reload)
	self.loadedAnimations.fire = self.viewmodel.Humanoid:LoadAnimation(self.settings.animations.viewmodel.fire)
	self.loadedAnimations.serverIdle = self.character.Humanoid:LoadAnimation(self.settings.animations.player.idle)
	self.loadedAnimations.serverAim = self.character.Humanoid:LoadAnimation(self.settings.animations.player.aim)
	self.loadedAnimations.serverAimFire = self.character.Humanoid:LoadAnimation(self.settings.animations.player.aimFire)
	self.loadedAnimations.serverIdleFire = self.character.Humanoid:LoadAnimation(self.settings.animations.player.idleFire)
	self.loadedAnimations.serverReload = self.character.Humanoid:LoadAnimation(self.settings.animations.player.reload)
	self.loadedAnimations.left=self.character.Humanoid:LoadAnimation(script.Left)
	self.loadedAnimations.right=self.character.Humanoid:LoadAnimation(script.Right)
	self.loadedAnimations.aimAnim=self.character.Humanoid:LoadAnimation(script.aim)
	self.loadedAnimations.holster=self.character.Humanoid:LoadAnimation(script.holster)
	self.crouchToStand=self.character.Humanoid:LoadAnimation(script.crouchToStand)
	self.standToCrouch=self.character.Humanoid:LoadAnimation(script.standToCrouch)
	self.crouchLoop=self.character.Humanoid:LoadAnimation(script.crouchLoop)
	self.crouchWalk=self.character.Humanoid:LoadAnimation(script.crouchWalk)
	self.proneLoop=self.character.Humanoid:LoadAnimation(script.proneLoop)
	self.proneMoveLoop=self.character.Humanoid:LoadAnimation(script.proneMoveLoop)
	
	
	self.crouchToStand.Looped=false
	self.standToCrouch.Looped=false
	self.crouchLoop.Looped=true
	self.crouchWalk.Looped=true
	
	
	self.proneLoop.Looped=true
	self.proneMoveLoop.Looped=true
	self.proneLoop.Priority=Enum.AnimationPriority.Action
	self.proneMoveLoop.Priority=Enum.AnimationPriority.Action
	
	self.crouchToStand.Priority=Enum.AnimationPriority.Action
	self.standToCrouch.Priority=Enum.AnimationPriority.Action
	self.crouchLoop.Priority=Enum.AnimationPriority.Action
	self.crouchWalk.Priority=Enum.AnimationPriority.Action
	
	
	self.loadedAnimations.holster.Looped=true
	self.loadedAnimations.left.Looped=false
	self.loadedAnimations.left.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.right.Looped=false
	self.loadedAnimations.right.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.aimAnim.Looped=true
	self.loadedAnimations.aimAnim.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.holster.Priority=Enum.AnimationPriority.Action
	
	self.loadedAnimations.idle.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.reload.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.fire.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.serverIdle.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.serverAim.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.serverAimFire.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.serverIdleFire.Priority=Enum.AnimationPriority.Action
	self.loadedAnimations.serverReload.Priority=Enum.AnimationPriority.Action
	
	self.loadedAnimations.idle.Looped=true
	self.loadedAnimations.idle:Play()
	self.loadedAnimations.serverIdle.Looped=true
	self.loadedAnimations.serverIdle:Play()	
	self.loadedAnimations.serverReload.Looped=false
	self.loadedAnimations.serverAim.Looped=true
	self.loadedAnimations.reload.Looped=false

	-- set ammo, either current or default filled
	self.wepName = wepName
	self.ammo[wepName] = self.ammo[wepName] or (self.settings.firing.magCapacity)
	self.spareAmmo[wepName]=self.spareAmmo[wepName] or (self.settings.firing.spareAmmo)
	self.spareMag[wepName]=self.spareMag[wepName] or (self.settings.firing.spareMag)

	local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(self.lerpValues.equip, tweeningInformation, { Value = 0 }):Play()		

	--[[
		Real life example:
			
		self.loadedAnimations.idle = self.viewmodel.Humanoid:LoadAnimation(self.settings.anims.viewmodel.idle)
		self.loadedAnimations.idle:Play()
	
		self.tweenLerp("equip","In")
		self.playSound("draw")
		
	--]]

	-- coroutine'd because server requests are far from instant
	coroutine.wrap(function()

		-- if server say no, then so does the client
		local pass = ReplicatedStorage.weaponRemotes.equip:InvokeServer(wepName)
		if not pass then self:remove() end		
	end)()

	self.curWeapon = wepName
	self.equipped = true -- Yay! our gun is ready.
	equipped.Value=true
	
	
	self.equipping=false
	WeaponGui =self.viewmodel.WeaponHud:Clone()
	if WeaponGui and MyPlayer then
		WeaponGui.Parent = MyPlayer.PlayerGui
	end
	WeaponGui.AmmoHud.ClipAmmo.Text=self.ammo[self.curWeapon]
	WeaponGui.AmmoHud.TotalAmmo.Text=self.spareAmmo[self.curWeapon]
	
	WeaponGui.GunHUD.ammo.Size=UDim2.new((1.25/self.settings.firing.magCapacity)*self.ammo[self.curWeapon], 0, 0.025, 0)
	WeaponGui.GunHUD.magCount.Text=self.spareMag[self.curWeapon]
	WeaponGui.GunHUD.magCap.Text=self.settings.firing.magCapacity
	
	if self.settings.firing.autoEnabled then
		WeaponGui.GunHUD.Mode.Text="Auto"
		self.fireMode="auto"
	elseif self.settings.firing.semiEnabled then
		self.fireMode="semi"
		WeaponGui.GunHUD.Mode.Text="Semi"
	end
	--userInputService.MouseBehavior = Enum.MouseBehavior.Default
	--userInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
	--wait(1)
	
	if self.settings.firing.weaponType=="shotgun" or self.settings.firing.weaponType=="grenade" then
		
		for _, v in pairs(script.reload:GetDescendants()) do
			--print(v)
			--if v:IsA("KeyframeMarker")  then

			--	print(v, v.Parent)
			--end
			if v:IsA("KeyframeMarker")  and v.Name=="first" then
				self.first=v.Parent
				
			end
			if v:IsA("KeyframeMarker")  and v.Name=="second" then
				self.second=v.Parent
				
			end
			if v:IsA("KeyframeMarker")  and v.Name=="last" then
				self.last=v.Parent
				
			end
		end
	end
	
	
	if self.character:FindFirstChild(self.wepName)==nil then
		repeat wait() until self.character:FindFirstChild(self.wepName)~=nil
	end
	local sound= self.character[self.wepName].receiver.equip:Clone()
	sound.Parent=workspace.Camera
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 5)
	
	
	
	for _, v in pairs(script.left:GetDescendants()) do
		--print(v)
		--if v:IsA("KeyframeMarker")  then

		--	print(v, v.Parent)
		--end
		if v:IsA("KeyframeMarker")  and v.Name=="loopStart" then
			self.leftLoopStart=v.Parent

		end
		if v:IsA("KeyframeMarker")  and v.Name=="loopStop" then
			self.leftLoopStop=v.Parent

		end
	end
	for _, v in pairs(script.right:GetDescendants()) do
		--print(v)
		--if v:IsA("KeyframeMarker")  then

		--	print(v, v.Parent)
		--end
		if v:IsA("KeyframeMarker")  and v.Name=="loopStart" then
			self.rightLoopStart=v.Parent

		end
		if v:IsA("KeyframeMarker")  and v.Name=="loopStop" then
			self.rightLoopStop=v.Parent

		end
	end
	for _, v in pairs(self.viewmodel.receiver.barrel:GetChildren()) do
		if v.Name == "flash" then
			if self.settings.firing.color then
				v.Color=ColorSequence.new(self.settings.firing.color.Color)
			end
		elseif v.Name == "lightFlash" then
			if self.settings.firing.color then
				v.Color=self.settings.firing.color.Color
			end
		end
	end		
	for _, v in pairs(self.character[wepName].receiver.barrel:GetChildren()) do
		if v.Name == "flash" then
			if self.settings.firing.color then
				v.Color=ColorSequence.new(self.settings.firing.color.Color)
			end
		elseif v.Name == "lightFlash" then
			if self.settings.firing.color then
				v.Color=self.settings.firing.color.Color
			end
		end
	end	
	--self.viewmodel:FindFirstChild("Front Rail").Touched:Connect(function(part)
	--	self.touched=true
	--end)
	--self.viewmodel:FindFirstChild("Front Rail").TouchEnded:Connect(function(part)
	--	self.touched=false
	--end)
end

function handler:remove()
	self.removing=true
	
	self.cOffsetStart=0
	local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
	TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
	if self.reloading and self.beforeAmmo~=nil then 
		self.ammo[self.wepName]=self.beforeAmmo
		WeaponGui.AmmoHud.ClipAmmo.Text=self.ammo[self.wepName]
	end
	if self.equipping then return end
	if not self.character then return end
	if self.firing then self:fire(false) end
	if self.aiming then self:aim(false) end
	if self.modeChanging then return end
	
	self.camera.FieldOfView=70
	
	WeaponGui:Destroy()
	WeaponGui=nil
	MyMouse.Icon=previousMouse
	laserBreak=true
	equipped.Value=false
	if reloadSound then
		reloadSound:Stop()
		
	end

	local tweeningInformation = TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
	TweenService:Create(self.lerpValues.equip, tweeningInformation, { Value = 1 }):Play()
	
	self.loadedAnimations.left:Stop()
	self.loadedAnimations.right:Stop()
	self.loadedAnimations.aimAnim:Stop()
	self.loadedAnimations.serverAim:Stop()
	self.loadedAnimations.serverAimFire:Stop()
	self.loadedAnimations.serverIdleFire:Stop()
	self.loadedAnimations.serverReload:Stop()
	self.loadedAnimations.serverIdle:Stop()
	self.loadedAnimations.holster:Stop()
	self.proneLoop:Stop()
	self.proneMoveLoop:Stop()
	self.crouchWalk:Stop()
	self.crouchLoop:Stop()
	
	wait(.6) --wait until the tween finished so the gun lowers itself smoothly
	self.disabled = true
	
	self.loadedAnimations.idle:Stop()
	self.loadedAnimations.fire:Stop()
	self.loadedAnimations.reload:Stop()
	if self.viewmodel then
		self.viewmodel:Destroy()
		self.viewmodel = nil
	end
	MyPlayer.CameraMode=Enum.CameraMode.Classic
	self.reloading = false	
	self.equipped = false -- Nay! We can't do anything with the gun now.
	
	self.curWeapon = nil

	coroutine.wrap(function()
		-- cough
		ReplicatedStorage.weaponRemotes.unequip:InvokeServer()
	end)()

	MyPlayer.CameraMode=Enum.CameraMode.Classic
	game.Players.LocalPlayer.Character.Humanoid.AutoRotate=true
	self.disabled = false
	self.removing=false
end


function playAnimationForDuration(animationTrack, duration)
	local speed = animationTrack.Length / duration
	animationTrack:Play()
	animationTrack:AdjustSpeed(speed)
	
	
end

function handler:reload()
	
	if self.firing then self:fire(false) end
	if self.equipping then return end
	if self.aiming then self:aim(false) end
	if self.reloading then return end
	if not self.equipped then return end
	if self.modeChanging then return end
	if self.spareAmmo[self.curWeapon]<1 then return end
	if self.spareMag[self.curWeapon]<1 then return end
	if self.ammo[self.wepName] >= self.settings.firing.magCapacity then return end
	reloadSound= self.character[self.wepName].receiver.reload:Clone()
	reloadSound.Parent=Camera
	self:run(false)
	reloadSound:Play()
	game:GetService("Debris"):AddItem(reloadSound, 5)
	
	
	self.camera.FieldOfView=self.FOV
	self.reloading = true
	self.beforeAmmo=self.ammo[self.wepName]
	


	-- we can use keyframe reached here, i will use length instead. waiting for the animation to finish will yield infinitely


	local debounce=false
	if self.settings.firing.weaponType=="rocket" then
		self.viewmodel.rocket.Transparency=0
	end

	if self.settings.firing.weaponType=="shotgun" or self.settings.firing.weaponType=="grenade" then


		self.loadedAnimations.reload:Play()
		self.loadedAnimations.serverReload:Play()
		
		if self.settings.firing.weaponType=="rocket" then
			self.viewmodel.rocket.Transparency=0
			self.character[self.wepName].rocket.Transparency=0
		end

		self.ammo[self.wepName]=self.ammo[self.wepName]+1
		self.spareAmmo[self.curWeapon]=self.spareAmmo[self.curWeapon]-1
		WeaponGui.AmmoHud.ClipAmmo.Text=self.ammo[self.curWeapon]
		WeaponGui.AmmoHud.TotalAmmo.Text=self.spareAmmo[self.curWeapon]
		local Time1=self.last.Time
		local Time2=self.first.Time
		if debounce==false then
			debounce=true
			self.loadedAnimations.reload:GetMarkerReachedSignal("first"):Connect(function(paramString)
				if debounce==false then return end
				
				if self.ammo[self.wepName]==self.settings.firing.magCapacity then
					self.loadedAnimations.reload.TimePosition=Time1	
					self.reloading = false
					debounce=false

				end
				if self.cancelReload then
					self.loadedAnimations.reload:Stop()
					self.reloading = false
					debounce=false
				end

			end)
			self.loadedAnimations.reload:GetMarkerReachedSignal("second"):Connect(function(paramString)
				if debounce==false then return end
				

				if self.ammo[self.wepName]~=self.settings.firing.magCapacity then
					self.ammo[self.wepName]=self.ammo[self.wepName]+1
					self.spareAmmo[self.curWeapon]=self.spareAmmo[self.curWeapon]-1
					WeaponGui.AmmoHud.ClipAmmo.Text=self.ammo[self.curWeapon]
					WeaponGui.AmmoHud.TotalAmmo.Text=self.spareAmmo[self.curWeapon]
					
					self.loadedAnimations.reload.TimePosition=Time2
				end

				if self.ammo[self.wepName]==self.settings.firing.magCapacity then
					self.loadedAnimations.reload.TimePosition=Time1	
					debounce=false
					self.reloading = false
				end

				if self.cancelReload then
					self.loadedAnimations.reload:Stop()
					self.reloading = false
					debounce=false

				end
			end)
		end
		--self.loadedAnimations.reload:GetMarkerReachedSignal("first"):Connect(function(paramString)
		--	local Time2=self.first.Time
		--	self.ammo[self.wepName]=self.ammo[self.wepName]+1
		--	while self.ammo[self.wepName]<=self.settings.firing.magCapacity do
		--		self.loadedAnimations.reload:GetMarkerReachedSignal("second"):Connect(function(paramString)
		--			self.loadedAnimations.reload.TimePosition=Time2
		--			self.ammo[self.wepName]=self.ammo[self.wepName]+1
		--		end)
		--	end
		--	self.loadedAnimations.reload.TimePosition=Time1	
		--end)
	else
		
		if self.wepName=="DBX-P" then
			playAnimationForDuration(self.loadedAnimations.reload, self.loadedAnimations.reload.Length+1)
			playAnimationForDuration(self.loadedAnimations.serverReload, self.loadedAnimations.serverReload.Length+2)
			
		else
			self.loadedAnimations.reload:Play()
			self.loadedAnimations.serverReload:Play()
		end
		
		--local roundsNeeded=self.settings.firing.magCapacity-self.ammo[self.wepName]
		--if roundsNeeded<=self.spareAmmo[self.curWeapon] then
		--	self.ammo[self.wepName]+=roundsNeeded
		--	self.spareAmmo[self.curWeapon]-=roundsNeeded
		--elseif self.spareAmmo[self.curWeapon]==0 then

		--else
		--	self.ammo[self.wepName]+=self.spareAmmo[self.curWeapon]
		--	self.spareAmmo[self.curWeapon]=0
		--end
		if self.spareMag[self.curWeapon]>0  then
			self.ammo[self.wepName]=self.settings.firing.magCapacity
			self.spareMag[self.curWeapon]-=1
		end
		WeaponGui.AmmoHud.ClipAmmo.Text=self.ammo[self.curWeapon]
		WeaponGui.AmmoHud.TotalAmmo.Text=self.spareAmmo[self.curWeapon]
		WeaponGui.GunHUD.magCount.Text=self.spareMag[self.curWeapon]
		WeaponGui.GunHUD.ammo.Size=UDim2.new((1.25/self.settings.firing.magCapacity)*self.ammo[self.curWeapon], 0, 0.025, 0)
		if self.wepName=="DBX-P" then
			wait(self.loadedAnimations.reload.Length+1)
		else
			wait(self.loadedAnimations.reload.Length)
		end
		
		self.reloading = false
	end


end

function handler:leanLeft(leaningLeft)
	if self.rightDebounce then return end
	self:run(false)
	if leaningLeft==false then
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.leanValue, tweeningInformation, { Value = math.rad(0) }):Play()
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
		self.leftDebounce=leaningLeft
	end
	--print("eh")
	if self.leftDebounce==true then return end
	if self.reloading then return end
	if not self.equipped then return end
	if self.modeChanging then return end
	
	if leaningLeft==true then
		self.loadedAnimations.left:Play()
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.leanValue, tweeningInformation, { Value = math.rad(35) }):Play()
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = -2 }):Play()
		self.leftDebounce=true
	end
	local debounce=false
	
	--if game.StarterPlayer.fpOn.Value==true then
	--	if leaningLeft then
	--		--self.character.Humanoid.CameraOffset=Vector3.new(0,0,5)
	--		--workspace.Camera.CameraSubject=self.character.Head
	--		workspace.CurrentCamera:SetRoll(math.rad(45))
	--	else
	--		--self.character.Humanoid.CameraOffset=Vector3.new(0,0,0)
	--		--workspace.Camera.CameraSubject=self.character.Humanoid
	--		workspace.CurrentCamera:SetRoll(math.rad(-45))
	--	end
	--end
	
	local a=self.loadedAnimations.left:GetMarkerReachedSignal("loopStop"):Connect(function(paramString)
		if self.leftDebounce==true then
			--print("why")
			self.loadedAnimations.left.TimePosition=self.leftLoopStart.Time
		else
			if debounce==false then
				debounce=true
				--print("why2")
				self.loadedAnimations.left.TimePosition=self.leftLoopStop.Time+.1
				if a then a:Disconnect() a=nil end
			end
		end
		
		
	end)
	
	
	
end

function handler:leanRight(leaningRight)
	if self.leftDebounce then return end
	self:run(false)
	if leaningRight==false then
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.leanValue, tweeningInformation, { Value = math.rad(0) }):Play()
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
		self.rightDebounce=leaningRight
	end
	--print("eh")
	if self.rightDebounce==true then return end
	if self.reloading then return end
	if not self.equipped then return end
	if self.modeChanging then return end

	if leaningRight==true then
		self.loadedAnimations.right:Play()
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.leanValue, tweeningInformation, { Value = math.rad(-35) }):Play()
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.cOffsetValue, tweeningInformation, { Value = 2 }):Play()
		self.rightDebounce=true
	end
	local debounce=false
	
	--if game.StarterPlayer.fpOn.Value==true then
	--	if leaningRight then
	--		--self.character.Humanoid.CameraOffset=Vector3.new(0,0,5)
	--		--workspace.Camera.CameraSubject=self.character.Head
	--		--workspace.CurrentCamera.CameraType=Enum.CameraType.Scriptable
	--		--workspace.CurrentCamera:SetRoll(math.rad(-45))
	--		local currentCFrame = workspace.CurrentCamera.CFrame
	--		local rollCFrame = CFrame.Angles(0, 0, 45)
	--		workspace.CurrentCamera.CFrame = currentCFrame * rollCFrame
	--	else
	--		--self.character.Humanoid.CameraOffset=Vector3.new(0,0,0)
	--		--workspace.Camera.CameraSubject=self.character.Humanoid
	--		--workspace.CurrentCamera:SetRoll(math.rad(45))
	--		--workspace.CurrentCamera.CameraType=Enum.CameraType.Fixed
	--		--workspace.Camera.CameraSubject=self.character.Humanoid
	--		local currentCFrame = workspace.CurrentCamera.CFrame
	--		local rollCFrame = CFrame.Angles(0, 0, -45)
	--		workspace.CurrentCamera.CFrame = currentCFrame * rollCFrame
	--	end
	--end
	

	local a=self.loadedAnimations.right:GetMarkerReachedSignal("loopStop"):Connect(function(paramString)
		if self.rightDebounce==true then
			--print("why")
			self.loadedAnimations.right.TimePosition=self.rightLoopStart.Time
		else
			if debounce==false then
				debounce=true
				--print("why2")
				self.loadedAnimations.right.TimePosition=self.rightLoopStop.Time+.1
				if a then a:Disconnect() a=nil end
			end
		end


	end)
end

function handler:modeChange()

	if self.firing then self:fire(false) end
	if self.equipping then return end
	if self.aiming then self:aim(false) end
	if self.reloading then return end
	if not self.equipped then return end
	if self.modeChanging then return end
	
	if self.fireMode=="auto" and self.settings.firing.burstEnabled then
		self.modeChanging = true
		self.fireMode="burst"
		WeaponGui.GunHUD.Mode.Text="Burst"
		wait(.5)
		self.modeChanging = false
	elseif self.fireMode=="auto" and self.settings.firing.semiEnabled then
		self.modeChanging = true
		self.fireMode="semi"
		WeaponGui.GunHUD.Mode.Text="Semi"
		wait(.5)
		self.modeChanging = false
	elseif self.fireMode=="burst" and self.settings.firing.semiEnabled then
		self.modeChanging = true
		self.fireMode="semi"
		WeaponGui.GunHUD.Mode.Text="Semi"
		wait(.5)
		self.modeChanging = false
	elseif self.fireMode=="burst" and self.settings.firing.autoEnabled then
		self.modeChanging = true
		self.fireMode="auto"
		WeaponGui.GunHUD.Mode.Text="Auto"
		wait(.5)
		self.modeChanging = false
	elseif self.fireMode=="semi" and self.settings.firing.autoEnabled then
		self.modeChanging = true
		self.fireMode="auto"
		WeaponGui.GunHUD.Mode.Text="Auto"

		wait(.5)
		self.modeChanging = false
	elseif self.fireMode=="semi" and self.settings.firing.burstEnabled then
		self.modeChanging = true
		self.fireMode="burst"
		WeaponGui.GunHUD.Mode.Text="Burst"

		wait(.5)
		self.modeChanging = false
	end


end

function handler:createBullet(part)
	local shell = part.Parent.shell:Clone()
	shell.CFrame = part.CFrame * CFrame.fromEulerAnglesXYZ(1.5,0,0)
	--shell.Size = Vector3.new(1,1,1)
	--shell.BrickColor = BrickColor.new(226)
	shell.Parent = game.Workspace
	shell.CFrame = part.CFrame
	shell.CanCollide = true
	shell.Transparency = 0
	shell.BottomSurface = 0
	shell.TopSurface = 0
	shell.Name = "Shell"
	shell.Velocity = part.CFrame.lookVector * 35 + Vector3.new(math.random(-10,10),20,math.random(-10,20))
	shell.RotVelocity = Vector3.new(0,200,0)

	--PhysicsService:SetPartCollisionGroup(shell, "Obstacles")
	game:GetService("Debris"):AddItem(shell, 30)
	
	--local shellmesh = Instance.new("SpecialMesh")
	--shellmesh.Scale = Vector3.new(.15,.4,.15)
	--shellmesh.Parent = shell
end





function handler:holster()
	if not self.equipped then return end
	if self.reloading then return end
	if self.equipping then return end
	if not self.character then return end
	if self.firing then self:fire(false) end
	if self.aiming then self:aim(false) end
	if self.modeChanging then return end
	if not self.holstering then
		
		self.character.Humanoid.CameraOffset=Vector3.new(0,0,0)
		
		self.holstering=true
		self.loadedAnimations.holster:Play()
		
		
		
		
		self.disabled=true
		
		MyMouse.Icon=previousMouse
		equipped.Value=false
		
		WeaponGui.Enabled=false
		
		uis.MouseBehavior = Enum.MouseBehavior.Default
		
	else
		if fpOn.Value==false then
			self.character.Humanoid.CameraOffset=Vector3.new(2,0,0)
		end
		self.loadedAnimations.holster:Stop()
		self.holstering=false
		equipped.Value=true
		MyMouse.Icon = "http://www.roblox.com/asset/?id=18662154"
		self.disabled=false
		WeaponGui.Enabled=true
	end
end


function handler:fire(tofire)

	if self.reloading then return end
	if self.equipping then return end
	if self.disabled then return end
	if not self.equipped then return end
	if tofire and self.ammo[self.wepName] <= 0 then 
		local sound= self.viewmodel.receiver.empty:Clone()
		sound.Parent = self.character[self.wepName].receiver
		sound:Play()
		game:GetService("Debris"):AddItem(sound, 5)
		--self:reload()
		return 
	end 
	
	if self.firing and  tofire then return end 
	if not self.canFire and tofire then return end
	if self.modeChanging then return end
	if self.reloading then return end
	if self.atWallUp or self.atWallDown then return end
	
	
	if self.jog then
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 0 }):Play()
		a=tick()
	end
	

	-- this makes the loop stop running when set to false
	self.firing = tofire
	if not tofire then return end

	-- while lmb held down do
	self:run(false)
	local function fire()
		if self.ammo[self.wepName] <= 0 then return end

		-- origin, direction
		-- barrel because realism, camera.CFrame because uh accuracy and arcadeying 
		-- make sure the barrel is facing where the gun fires
		-- aaand make sure the gun is actually facing towards the cursor properly, players don't like offsets
		if self.settings.firing.weaponType=="rocket" then
			self.viewmodel.rocket.Transparency=1
			self.character[self.wepName].rocket.Transparency=1
		end
		local origin
		local direction
		if fpOn.Value==true then
			 origin = self.viewmodel.receiver.barrel.WorldPosition
			if self.aiming then
				
				--local length = 500
				--local unitRay = Camera:ScreenPointToRay(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
				--local ray = Ray.new(unitRay.Origin, unitRay.Direction * length) unitRay.Direction * length
				direction = self.viewmodel.receiver.barrel.WorldCFrame.LookVector
			else
				direction = self.viewmodel.receiver.barrel.WorldCFrame.LookVector
				--direction = (MyMouse.Hit.p -origin).unit			
			end
			
		elseif fpOn.Value==false then
			origin = self.character[self.name].receiver.barrel.WorldPosition
			direction = (MyMouse.Hit.p -origin).unit
		end

		-- inconsistent :(
		fastcastHandler:fire(origin, direction, self.settings)
		
		self.loadedAnimations.fire:Play()
		if self.aiming then
			self.loadedAnimations.serverAimFire:Play()
		else
			self.loadedAnimations.serverIdleFire:Play()
		end
		
		-- It's better to replicate the change to other clients and play it there with the same code as here instead of using SoundService.RespectFilteringEnabled = false

		local sound= self.viewmodel.receiver.pewpew:Clone()
		if self.character:FindFirstChild(self.wepName)==nil then
			repeat wait() until self.character:FindFirstChild(self.wepName)~=nil
		end
		sound.Parent = self.character[self.wepName].receiver 
		sound:Play()

		-- replace? i've heard bad things about debris service
		game:GetService("Debris"):AddItem(sound, 5)
		
		self.recoveryTime=self.settings.firing.recoveryTime
		self.recoil=self.settings.firing.recoilTable[math.random(1, #self.settings.firing.recoilTable)]
		self.springs.fire:shove( self.recoil * self.deltaTime * 60)
		
		
		-- Muzzle flash. This is why we left it invisible and enabled.
		coroutine.wrap(function()		

			-- could be optimized a lot
			-- flash flashes inside the barrel, and smoke smokes for a short time



			if fpOn.Value==true and  (not (self.wepName=="ar15" and self.aiming) or self.secAim) then
				for _, v in pairs(self.viewmodel.receiver.barrel:GetChildren()) do
					if v.Name == "flash" then

						v.Transparency = NumberSequence.new(v.transparency.Value)
						--elseif v.Name == "flash2" then
						--	v.Enabled = true
					elseif v.Name == "smoke" then
						v.Enabled = true
					elseif v.Name == "lightFlash" then
						v.Enabled = true	
					end
				end	

				wait()

				for _, v in pairs(self.viewmodel.receiver.barrel:GetChildren()) do
					if v.Name == "flash" then
						v.Transparency = NumberSequence.new(1)
					elseif v.Name == "flash2" then
						v.Enabled = false
					elseif v.Name == "smoke" then
						v.Enabled = false
					elseif v.Name == "lightFlash" then
						v.Enabled = false
					end
				end
			elseif fpOn.Value==false then
				for _, v in pairs(self.character[self.name].receiver.barrel:GetChildren()) do
					if v.Name == "flash" then
						v.Transparency = NumberSequence.new(v.transparency.Value)
						--elseif v.Name == "flash2" then
						--	v.Enabled = true
					elseif v.Name == "smoke" then
						v.Enabled = true
					elseif v.Name == "lightFlash" then
						v.Enabled = true	
					end
				end	

				wait()

				for _, v in pairs(self.character[self.name].receiver.barrel:GetChildren()) do
					if v.Name == "flash" then
						v.Transparency = NumberSequence.new(1)
					elseif v.Name == "flash2" then
						v.Enabled = false
					elseif v.Name == "smoke" then
						v.Enabled = false
					elseif v.Name == "lightFlash" then
						v.Enabled = false
					end
				end
			end

		end)()		

		self.ammo[self.wepName] = self.ammo[self.wepName] - 1
		if WeaponGui:FindFirstChild("AmmoHud")~=nil then
			WeaponGui.AmmoHud.ClipAmmo.Text=self.ammo[self.curWeapon]
		end
		WeaponGui.GunHUD.ammo.Size=UDim2.new((1.25/self.settings.firing.magCapacity)*self.ammo[self.curWeapon], 0, 0.025, 0)
		
		
		if self.viewmodel:FindFirstChild("shell")~=nil then
			if fpOn.Value==true then
				if self.viewmodel:FindFirstChild("ejection port") then
					self:createBullet(self.viewmodel["ejection port"])
				elseif self.viewmodel:FindFirstChild("slide") then
					self:createBullet(self.viewmodel.slide)
				end

			elseif fpOn.Value==false then

				if self.character[self.name]:FindFirstChild("ejection port") then
					self:createBullet(self.character[self.name]["ejection port"])
				elseif self.character[self.name]:FindFirstChild("slide") then
					self:createBullet(self.viewmodel.slide)
				end
			end 

		end
		
		-- addition of deltatime here is a poor attempt at fixing the recoil being framerate based
		-- this doesn't happen in my own game, dunno why
		
		

		wait((60/self.RPM))

	end

	if self.fireMode=="auto" and self.settings.firing.autoEnabled then
		repeat
			self.canFire = false
			self.RPM=self.settings.firing.rpm
			fire()
			self.canFire = true
		until self.ammo[self.wepName] <= 0 or not self.firing	
	elseif self.fireMode=="semi" and self.settings.firing.semiEnabled then
		repeat
			self.canFire = false
			self.RPM=self.settings.firing.semiRPM
			fire()
			self.canFire = true
			self.firing=false
		until self.ammo[self.wepName] <= 0 or not self.firing
	elseif self.fireMode=="burst" and self.settings.firing.burstEnabled then
		for i=1, self.settings.firing.burstAmount,1 do
			self.canFire = false
			self.RPM=self.settings.firing.burstRPM
			fire()
			self.canFire = true
			self.firing=false
		end
		wait(self.settings.firing.burstCooldown)
	end


	if self.ammo[self.wepName] <= 0 then
		self.firing = false
	end
	

end





function handler:jogging()
	self.running=false
	local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
	TweenService:Create(self.lerpValues.run, tweeningInformation, { Value = 0 }):Play()	
	
	if self.jog then
		ReplicatedStorage.weaponRemotes.jog:FireServer(false)
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 0 }):Play()
		
	else
		ReplicatedStorage.weaponRemotes.jog:FireServer(true)
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 1 }):Play()
	end
	self.jog=not self.jog
	local tweeningInformation = TweenInfo.new(self.crouchToStand.Length, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
	TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
	self.crouching=false
	self.proneLoop:Stop()
	self.proneMoveLoop:Stop()
	self.crouchWalk:Stop()
	self.crouchLoop:Play()
end


function handler:run(running)
	
	--if self.running~=running then return end
	if self.reloading then return end
	
	self.running=running
	
	if running==true and gui.sprint.white.Size.X.Scale==0 then
		
	elseif running==true and gui.sprint.white.Size.X.Scale>0 then
		
		self:crouch(false)
		self:prone(false)
		d=tick()
		
		if whiteoff~=nil then
			whiteoff:Pause()
		end
		if backoff~=nil  then
			backoff:Pause()
		end
		
		
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.run, tweeningInformation, { Value = 1 }):Play()
		
		local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(gui.sprint.white, tweeningInformation, { BackgroundTransparency = 0}):Play()
		
		local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(gui.sprint.back, tweeningInformation, { BackgroundTransparency = .123}):Play()
		
		
		if runGUI2~=nil then
			runGUI2:Pause()
		end
		local tweeningInformation = TweenInfo.new(stamina, Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
		runGUI=TweenService:Create(gui.sprint.white, tweeningInformation, { Size = UDim2.new(0, 0,0.025, 0) })
		runGUI:Play()
		
		
		
		
		if self.crouchToStand~=nil then
			local tweeningInformation = TweenInfo.new(self.crouchToStand.Length, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
		end
		
		if WeaponGui~=nil then
			WeaponGui.MainFrame.Poses.crouch.Visible=false
			WeaponGui.MainFrame.Poses.prone.Visible=false
			WeaponGui.MainFrame.Poses.stand.Visible=true
		end
		self.state=0
		ReplicatedStorage.weaponRemotes.run:FireServer(true)
		--self.loadedAnimations.run:Play()
		
	elseif running==false then
		if self.crouching or self.proning then return end
		local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.run, tweeningInformation, { Value = 0 }):Play()	
		
		ReplicatedStorage.weaponRemotes.run:FireServer(false)
		--self.loadedAnimations.run:Stop()
		
		
		
		
		
		if runGUI~=nil then
			runGUI:Pause()
		end
		local tweeningInformation = TweenInfo.new(staminaRecovery, Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
		runGUI2=TweenService:Create(gui.sprint.white, tweeningInformation, { Size = UDim2.new(1.25, 0,0.025, 0) })
		runGUI2:Play()
		
		
		
	end
		
	
	
	
	
	
end

function handler:getDown()
	if self.state==0 then
		self:crouch(true)
		self.state=1
		WeaponGui.MainFrame.Poses.stand.Visible=false
		WeaponGui.MainFrame.Poses.crouch.Visible=true
	elseif self.state==1 then
		self:crouch(false)
		self:prone(true)
		self.state=2
		WeaponGui.MainFrame.Poses.prone.Visible=true
		WeaponGui.MainFrame.Poses.crouch.Visible=false
	end
end

function handler:getUp()
	if self.state==2 then
		self:prone(false)
		self:crouch(true)
		self.state=1
		WeaponGui.MainFrame.Poses.crouch.Visible=true
		WeaponGui.MainFrame.Poses.prone.Visible=false
	elseif self.state==1 then
		self:crouch(false)
		self.state=0
		WeaponGui.MainFrame.Poses.crouch.Visible=false
		WeaponGui.MainFrame.Poses.stand.Visible=true
	end
end

function handler:crouch(enabled)

	if self.disabled then return end
	if not self.equipped then return end
	
	local function crouchOn()
		if self.crouching==false and self.character.Humanoid.MoveDirection.Magnitude==0 then

			--self.crouchLoop:Stop()
			--self.crouchWalk:Stop()

			ReplicatedStorage.weaponRemotes.crouch:FireServer(true)
			self.crouching=true
			self.proning=false
			self.proneLoop:Stop()
			self.proneMoveLoop:Stop()
			self.standToCrouch:Play()
			if self.jog then
				local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 0 }):Play()
			end
			local tweeningInformation = TweenInfo.new(self.standToCrouch.Length, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.crouchValue }):Play()	
			local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.run, tweeningInformation, { Value = 0 }):Play()	
			self.running=false
			wait(self.standToCrouch.Length)
			self.crouchLoop:Play()




		elseif self.crouching==false and self.character.Humanoid.MoveDirection.Magnitude>0 then

			--self.crouchLoop:Stop()
			--self.crouchWalk:Stop()

			ReplicatedStorage.weaponRemotes.crouch:FireServer(true)
			self.crouching=true
			self.proning=false
			self.standToCrouch:Play()
			if self.jog then
				local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 0 }):Play()
			end
			local tweeningInformation = TweenInfo.new(self.standToCrouch.Length, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.crouchValue }):Play()
			local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.run, tweeningInformation, { Value = 0 }):Play()	
			self.running=false
			wait(self.standToCrouch.Length)
			self.proneLoop:Stop()
			self.proneMoveLoop:Stop()
			self.crouchWalk:Play()
		end
		
		self.character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function() 
		if self.crouching==true and self.character.Humanoid.MoveDirection.Magnitude>0 and not self.crouchDebounce then

			self.crouchDebounce=true
			self.crouchLoop:Stop()
			self.crouchWalk:Play()

		elseif self.crouching==true and self.character.Humanoid.MoveDirection.Magnitude==0 and self.crouchDebounce then

			self.crouchDebounce=false
			self.crouchWalk:Stop()
			self.crouchLoop:Play()

			--elseif self.crouching==false then
			--	print(6)
			--	self.crouchLoop:Stop()
			--	--self.crouchToStand:Play()
		else
			self.crouchWalk:Stop()
			self.crouchLoop:Stop()
		end

	end)	
		
	end
	local function crouchOff()
			ReplicatedStorage.weaponRemotes.crouch:FireServer(false)
			local tweeningInformation = TweenInfo.new(self.crouchToStand.Length, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
			self.crouching=false
			self.crouchLoop:Stop()
			self.crouchWalk:Stop()
			self.crouchToStand:Play()
			if self.jog then
				local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 1 }):Play()
			end
	end
	
	
	if enabled then
		crouchOn()
	else
		crouchOff()
	end

	
end


function handler:prone(enabled)
	
	if self.disabled then return end
	if not self.equipped then return end
	
	local function proneOn()
		if self.character.Humanoid.MoveDirection.Magnitude==0 then

			--self.crouchLoop:Stop()
			--self.crouchWalk:Stop()
			self.crouching=false
			if self.jog then
				local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 0 }):Play()
			end
			local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.run, tweeningInformation, { Value = 0 }):Play()	
			local tweeningInformation = TweenInfo.new(self.standToCrouch.Length, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.proneValue }):Play()
			ReplicatedStorage.weaponRemotes.prone:FireServer(true)
			self.proning=true

			self.proneLoop:Play()




		elseif self.character.Humanoid.MoveDirection.Magnitude>0 then

			if self.jog then
				local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 0 }):Play()
			end
			local tweeningInformation = TweenInfo.new(self.standToCrouch.Length, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.proneValue }):Play()
			local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.run, tweeningInformation, { Value = 0 }):Play()	
			ReplicatedStorage.weaponRemotes.prone:FireServer(true)
			self.proning=true
			self.proneMoveLoop:Play()
		end
	
		self.character.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function() 
			if self.proning==true and self.character.Humanoid.MoveDirection.Magnitude>0 and not self.proneDebounce then

				self.proneDebounce=true
				self.proneLoop:Stop()
				self.proneMoveLoop:Play()

			elseif self.crouching==true and self.character.Humanoid.MoveDirection.Magnitude==0 and self.crouchDebounce then

				self.proneDebounce=false
				self.proneMoveLoop:Stop()
				self.proneLoop:Play()

				--elseif self.crouching==false then
				--	print(6)
				--	self.crouchLoop:Stop()
				--	--self.crouchToStand:Play()
			end

		end)	
	end
	
	local function proneOff()
			if self.jog then
				local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 1 }):Play()
			end
			local tweeningInformation = TweenInfo.new(self.standToCrouch.Length, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
			ReplicatedStorage.weaponRemotes.prone:FireServer(false)
			self.proning=false
			self.proneLoop:Stop()
			self.proneMoveLoop:Stop()
	end
	
	if enabled then
		proneOn()
	else
		proneOff()
	end
	

	
end



function handler:jump()

	--if self.running~=running then return end
	self.running=false
	self.crouching=false
	self.proning=false
	local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
	TweenService:Create(self.cDownValue, tweeningInformation, { Value = self.cOffsetStart }):Play()
	local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
	TweenService:Create(self.lerpValues.run, tweeningInformation, { Value = 0 }):Play()	
	ReplicatedStorage.weaponRemotes.run:FireServer(false)
	if runGUI~=nil then
		runGUI:Pause()
	end
	local tweeningInformation = TweenInfo.new(self.settings.firing.staminaRecovery, Enum.EasingStyle.Linear,Enum.EasingDirection.Out)
	runGUI2=TweenService:Create(gui.sprint.white, tweeningInformation, { Size = UDim2.new(1.25, 0,0.025, 0) })
	runGUI2:Play()
	self.proneLoop:Stop()
	self.proneMoveLoop:Stop()
	self.crouchWalk:Stop()
	self.crouchLoop:Stop()
end


function handler:flashlight()
	if self.disabled then 
		return 
	end
	--if self.hide==true then return end
	if not self.equipped then return end
	if self.equipping then return end
	
	
	if self.viewmodel:FindFirstChild("flashlight")==nil then return end
	
	if self.light==true then
		self.light=false
		self.viewmodel.flashlight.Attachment.light.Enabled=false
		WeaponGui.GunHUD.Flash.Visible=false
		ReplicatedStorage.weaponRemotes.flashlight:FireServer(false)
	else
		self.light=true
		self.viewmodel.flashlight.Attachment.light.Enabled=true
		WeaponGui.GunHUD.Flash.Visible=true
		ReplicatedStorage.weaponRemotes.flashlight:FireServer(true)
	end
end

function handler:nightVision()
	if self.disabled then 
		return 
	end
	
	if not self.nv then
		
		--self.canAim=false
		--self:aim(false)
		--if self.Laser==true then self.viewmodel.laser.Beam.Enabled=false end
		WeaponGui.nv.Visible=true
		nightVision.Enabled=true
		self:changeNVAim()
	else
		
		--self.canAim=true
		--if self.Laser==true then self.viewmodel.laser.Beam.Enabled=true end
		nightVision.Enabled=false
		WeaponGui.nv.Visible=false
		self:changeNVAim()
	end
	self.nv=not self.nv
end


function handler:laser()
	if self.disabled then 
		return 
	end
	--if self.hide==true then return end
	if not self.equipped then return end
	if self.equipping then return end


	if self.viewmodel:FindFirstChild("laser")==nil then return end

	if self.Laser==true then
		self.Laser=false
		self.viewmodel.laser.Beam.Enabled=false
		self.viewmodel.laser.att1.laserPoint.Enabled=false
		WeaponGui.GunHUD.Laser.Visible=false
		ReplicatedStorage.weaponRemotes.laser:FireServer(false)
	else
		self.Laser=true
		
		self.viewmodel.laser.Beam.Enabled=true
			
		
		self.viewmodel.laser.att1.laserPoint.Enabled=true 
		WeaponGui.GunHUD.Laser.Visible=true
		ReplicatedStorage.weaponRemotes.laser:FireServer(true)
	end
end

function handler:walldown(walling)

	-- we'll be using this soon
	-- We used it! ha!

	-- add a TweenService variable at the top that references TweenService yourself, thanks

	if self.disabled then 

		return 
	end
	--if self.hide==true then return end
	if not self.equipped then return end
	if self.equipping then return end
	if self.modeChanging then return end
	if self.reloading then return end
	if self.atWallDown==walling then return end
	self.atWallDown = walling

	

	if walling  then

		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.down, tweeningInformation, { Value = 1 }):Play()


	else
		
		local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.down, tweeningInformation, { Value = 0 }):Play()		




	end

end

function handler:wallup(walling)

	-- we'll be using this soon
	-- We used it! ha!

	-- add a TweenService variable at the top that references TweenService yourself, thanks

	if self.disabled then 

		return 
	end
	--if self.hide==true then return end
	if not self.equipped then return end
	if self.equipping then return end
	if self.modeChanging then return end
	if self.reloading then return end
	if self.atWallUp==walling then return end
	self.atWallUp = walling
	
	

	if walling then

		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.up, tweeningInformation, { Value = 1 }):Play()
		

	else
		
		local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.up, tweeningInformation, { Value = 0 }):Play()		
		
		
	

	end

end


function handler:changeNVAim()
	if not self.equipped then return end
	if self.reloading then return end
	if self.equipping then return end
	if not self.character then return end
	if self.firing then self:fire(false) end
	--if self.aiming then self:aim(false) end
	if self.modeChanging then return end

	if not self.nv then

		if self.aiming then
			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier2 }):Play()

			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.nvAim, tweeningInformation, { Value = 1 }):Play()

			local zoom=TweenInfo.new(
				1, -- Time
				Enum.EasingStyle.Quart, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
				--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
				--false, -- Reverses (tween will not reverse once reaching it's goal)
				--0 -- DelayTime
			)
			TweenService:Create(workspace.CurrentCamera, zoom, { FieldOfView = self.FOV - self.settings.firing.adsRange2 }):Play()
			--wait(.5)
			self:scope(false)
		end
		

	else
		if self.aiming and not self.secAim then

			local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.nvAim, tweeningInformation, { Value = 0 }):Play()

			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier1 }):Play()

			local zoom=TweenInfo.new(
				1, -- Time
				Enum.EasingStyle.Quart, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
				--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
				--false, -- Reverses (tween will not reverse once reaching it's goal)
				--0 -- DelayTime
			)
			TweenService:Create(workspace.CurrentCamera, zoom, { FieldOfView = self.FOV - (self.settings.firing.adsRange) }):Play()
			--wait(.1)

			wait(.2)
			self:scope(true)
			
		elseif self.aiming and  self.secAim then
			local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.nvAim, tweeningInformation, { Value = 0 }):Play()

			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier2 }):Play()

			local zoom=TweenInfo.new(
				1, -- Time
				Enum.EasingStyle.Quart, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
				--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
				--false, -- Reverses (tween will not reverse once reaching it's goal)
				--0 -- DelayTime
			)
			TweenService:Create(workspace.CurrentCamera, zoom, { FieldOfView = self.FOV - (self.settings.firing.adsRange2) }):Play()
			--wait(.1)

			--wait(.2)
			--self:scope(true)

		end

		



	end
end

function handler:changeAim()
	if not self.equipped then return end
	if self.reloading then return end
	if self.equipping then return end
	if not self.character then return end
	if self.firing then self:fire(false) end
	--if self.aiming then self:aim(false) end
	if self.modeChanging then return end

	if not self.secAim then

		if self.aiming then
			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier2 }):Play()

			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.secAim, tweeningInformation, { Value = 1 }):Play()

			local zoom=TweenInfo.new(
				1, -- Time
				Enum.EasingStyle.Quart, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
				--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
				--false, -- Reverses (tween will not reverse once reaching it's goal)
				--0 -- DelayTime
			)
			TweenService:Create(workspace.CurrentCamera, zoom, { FieldOfView = self.FOV - self.settings.firing.adsRange2 }):Play()
			--wait(.5)
			self:scope(false)
		end
		self.secAim=true

	else
		if self.aiming then

			local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.secAim, tweeningInformation, { Value = 0 }):Play()

			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier1 }):Play()

			local zoom=TweenInfo.new(
				1, -- Time
				Enum.EasingStyle.Quart, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
				--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
				--false, -- Reverses (tween will not reverse once reaching it's goal)
				--0 -- DelayTime
			)
			TweenService:Create(workspace.CurrentCamera, zoom, { FieldOfView = self.FOV - (self.settings.firing.adsRange) }):Play()
			--wait(.1)

			wait(.2)
			if not self.nv then
				self:scope(true)
			end
			

		end

		self.secAim=false



	end
end

function handler:scope(enabled)
	if enabled then
		if self.wepName=="ar15" then
			self.viewmodel["primary glass"].Transparency=1
			self.viewmodel["secondary glass"].Transparency=1
			self.viewmodel["primary scope"].Transparency=1
			self.viewmodel["secondary sight"].Transparency=1
			self.viewmodel["secondary reticle"].Transparency=1
			self.viewmodel["flash base"].Transparency=1
			self.viewmodel["flashlight"].Transparency=1
			self.viewmodel["laser"].Transparency=1
			self.viewmodel["laser base"].Transparency=1
			self.viewmodel["laser base 2"].Transparency=1
			self.viewmodel["reload thingy"].Transparency=1
			self.viewmodel["Details"].Transparency=1
			self.viewmodel.receiver.Transparency=1
			self.viewmodel["Front Rail"].Transparency=1
			self.viewmodel.grip.Transparency=1
			self.viewmodel["ejection port"].Transparency=1

			if WeaponGui:FindFirstChild("Scope")~=nil then
				WeaponGui.Scope.Visible=true
			end



		end
	else
		if self.wepName=="ar15" then

			self.viewmodel["primary scope"].Transparency=0
			self.viewmodel["primary glass"].Transparency=.75
			self.viewmodel["secondary sight"].Transparency=0
			self.viewmodel["secondary glass"].Transparency=.75
			self.viewmodel["secondary reticle"].Transparency=0
			self.viewmodel["flash base"].Transparency=0
			self.viewmodel["flashlight"].Transparency=0
			self.viewmodel["laser"].Transparency=0
			self.viewmodel["laser base"].Transparency=0
			self.viewmodel["laser base 2"].Transparency=0
			self.viewmodel["Details"].Transparency=0
			self.viewmodel["reload thingy"].Transparency=0
			self.viewmodel["ejection port"].Transparency=0
			self.viewmodel.receiver.Transparency=0
			self.viewmodel["Front Rail"].Transparency=0
			self.viewmodel.grip.Transparency=0
			if WeaponGui:FindFirstChild("Scope")~=nil then
				WeaponGui.Scope.Visible=false

			end

		end
	end
end

function handler:aim(toaim)

	-- we'll be using this soon
	-- We used it! ha!

	-- add a TweenService variable at the top that references TweenService yourself, thanks

	if self.disabled or self.removing then 
		
		return 
	end
	
	--if self.hide==true then return end
	if not self.equipped then return end
	if self.equipping then return end
	if self.modeChanging then return end
	if self.reloading then return end
	self.aiming = toaim
	
	self:run(false)
	
	ReplicatedStorage.weaponRemotes.aim:FireServer(toaim)

	-- This is an easy to make approach

	if toaim and not (self.atWallUp or self.atWallDown)  and not self.disabled and self.canAim  then
		
		--MyPlayer.CameraMode=Enum.CameraMode.LockFirstPerson
		-- customize speed at will.
		self.loadedAnimations.serverAim:Play()
		self.loadedAnimations.aimAnim:Play()
		if WeaponGui:FindFirstChild("Crosshair")~=nil and self.hide==false then
			WeaponGui.Crosshair.Visible=false
		end
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.aim, tweeningInformation, { Value = 1 }):Play()
		
		
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier1 }):Play()
		
		
		if self.nv then
			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.nvAim, tweeningInformation, { Value = 1 }):Play()
			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier2 }):Play()
			local zoom=TweenInfo.new(
				1, -- Time
				Enum.EasingStyle.Quart, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
				--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
				--false, -- Reverses (tween will not reverse once reaching it's goal)
				--0 -- DelayTime
			)
			TweenService:Create(workspace.CurrentCamera, zoom, { FieldOfView = self.FOV - self.settings.firing.adsRange2 }):Play()
		elseif self.secAim then
			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.secAim, tweeningInformation, { Value = 1 }):Play()
			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier2 }):Play()
			local zoom=TweenInfo.new(
				1, -- Time
				Enum.EasingStyle.Quart, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
				--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
				--false, -- Reverses (tween will not reverse once reaching it's goal)
				--0 -- DelayTime
			)
			TweenService:Create(workspace.CurrentCamera, zoom, { FieldOfView = self.FOV - self.settings.firing.adsRange2 }):Play()
		else
			local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(self.lerpValues.secAim, tweeningInformation, { Value = 0 }):Play()
			local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
			TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens/self.settings.firing.aimSlowDownMultiplier2 }):Play()
			local zoom=TweenInfo.new(
				1, -- Time
				Enum.EasingStyle.Quart, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
				--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
				--false, -- Reverses (tween will not reverse once reaching it's goal)
				--0 -- DelayTime
			)
			TweenService:Create(workspace.CurrentCamera, zoom, { FieldOfView = self.FOV - (self.settings.firing.adsRange) }):Play()
			wait(.5)
			self:scope(true)
			
		end
		
		
		

	else
		--MyPlayer.CameraMode=Enum.CameraMode.Classic
		if WeaponGui:FindFirstChild("Crosshair")~=nil  then
			WeaponGui.Crosshair.Visible=true
		end
		self.loadedAnimations.serverAim:Stop()
		self.loadedAnimations.aimAnim:Stop()
		
		
		
		local tweeningInformation = TweenInfo.new(0.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		
		
		
		TweenService:Create(self.lerpValues.aim, tweeningInformation, { Value = 0 }):Play()		
		
		local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.secAim, tweeningInformation, { Value = 0 }):Play()
		
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(self.lerpValues.nvAim, tweeningInformation, { Value = 0 }):Play()
		
		local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
		TweenService:Create(userInputService, tweeningInformation, { MouseDeltaSensitivity = sens }):Play()
		local zoom=TweenInfo.new(
			1, -- Time
			Enum.EasingStyle.Quart, -- EasingStyle
			Enum.EasingDirection.Out -- EasingDirection
			--1, -- RepeatCount (when less than zero the tween will loop indefinitely)
			--false, -- Reverses (tween will not reverse once reaching it's goal)
			--0 -- DelayTime
		)
		TweenService:Create(workspace.CurrentCamera, zoom, {FieldOfView = self.FOV}):Play()
		wait(.1)
		self:scope(false)
		
	end

end

function handler:update(deltaTime)
	
	
	

	
	
	if self.viewmodel and self.character:FindFirstChild('HumanoidRootPart')~=nil then
		self.deltaTime = deltaTime
		--self.character:FindFirstChild("HumanoidRootPart")
		-- IF we have a gun right now. We're checking the viewmodel instead for "reasons".

		self.character.Humanoid.CameraOffset=Vector3.new(self.cOffsetValue.Value,self.cDownValue.Value,0)


		local currentCFrame = workspace.CurrentCamera.CFrame
		local rollCFrame = CFrame.Angles(0, 0, self.leanValue.Value)
		workspace.CurrentCamera.CFrame = currentCFrame * rollCFrame
		
		
		
		if self.disabled then 
			self.viewmodel.rootPart.CFrame = CFrame.new(0, -100, 0)
			return
		end
		
		if self.character.Humanoid.Jump==true then
			self:jump()
		end
		
		local isfirstperson = (self.character.HumanoidRootPart.CFrame.Position - Camera.CFrame.Position).Magnitude < 3; -- Determine wether we are in first person
		if isfirstperson==true then
			if fpOn.Value==false and equipped.Value==true then
				self.cOffsetStart=0
				self:changeView()
			end
			
			
			
		elseif isfirstperson==false then
			if fpOn.Value==true and equipped.Value==true then
				self.cOffsetStart=2
				self:changeView()
			end
		end
		
		
		
		if WeaponGui then
			if WeaponGui:FindFirstChild("Crosshair") then
				WeaponGui.Crosshair.Position = UDim2.new(0, (MyMouse.X), 0, (MyMouse.Y))
			end 
		end
		
		if self.disabled==true then
			--self.character.Humanoid.CameraOffset=Vector3.new(0,0,0)
		end
		local part=MyMouse.Hit
		if part==nil then
			self:wall(false)
		else
			
			local distance=(self.character.HumanoidRootPart.Position-part.Position).Magnitude
			
			if distance<=5 and (MyMouse.Target.Parent==workspace or MyMouse.Target.Parent:IsA("Model"))  and workspace.CurrentCamera.CFrame.LookVector.Y>=0 then
				
				self:wallup(true)
				self:walldown(false)
				
			elseif distance<=4 and (MyMouse.Target.Parent==workspace or MyMouse.Target.Parent:IsA("Model")) and MyMouse.Target.Parent~=Camera and  workspace.CurrentCamera.CFrame.LookVector.Y<0 then
				self:wallup(false)
				self:walldown(true)
				
			else
				if MyMouse.Target~=nil then
					if MyMouse.Target.Parent~=nil then
						if MyMouse.Target.Parent==self.viewmodel then

						else
							self:wallup(false)
							self:walldown(false)
						end
					else
						self:wallup(false)
						self:walldown(false)
					end
				end
				
	
				
				
				
			end
		end
		
		if self.jog and  a~=nil and self.firing==false then
			if tick()-a>1 then
				local tweeningInformation = TweenInfo.new(1, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				TweenService:Create(self.lerpValues.jog, tweeningInformation, { Value = 1 }):Play()
			end
		end
		
		-- for animations
		-- breaks for some people? idk
		
		local animatorCFrameDifference = self.lastReceiverRelativity or CFrame.new() * self.viewmodel.camera.CFrame:ToObjectSpace(self.viewmodel.rootPart.CFrame):Inverse()
		local x,y,z = animatorCFrameDifference:ToOrientation()
		workspace.Camera.CFrame = workspace.Camera.CFrame * CFrame.Angles(x, y, z)
		self.lastReceiverRelativity = self.viewmodel.camera.CFrame:ToObjectSpace(self.viewmodel.rootPart.CFrame)

		-- get velocity for walkCycle
		local velocity = self.character.HumanoidRootPart.Velocity

		-- you can add priorities here! for example, equip offset for procedural equipping would be below aimOffset to overwrite it when removing the gun.
		-- here, aim overwrites idle.
		
		
		local idleOffset = self.viewmodel.offsets.idle.Value
		
		local jogOffset = idleOffset:lerp(self.viewmodel.offsets.jog.Value, self.lerpValues.jog.Value)
		 
		local downOffset = jogOffset:lerp(self.viewmodel.offsets.down.Value, self.lerpValues.down.Value)
		
		
		local upOffset = downOffset:lerp(self.viewmodel.offsets.up.Value, self.lerpValues.up.Value)
	
		
		
		
		
		local runOffset = upOffset:lerp(self.viewmodel.offsets.run.Value, self.lerpValues.run.Value)
		
		local aimOffset = runOffset:lerp(self.viewmodel.offsets.aim.Value, self.lerpValues.aim.Value)
		
		local aim2Offset = aimOffset:lerp(self.viewmodel.offsets.secAim.Value, self.lerpValues.secAim.Value)
		
		local nvOffset = aim2Offset:lerp(self.viewmodel.offsets.nvAim.Value, self.lerpValues.nvAim.Value)
		
		local equipOffset = nvOffset:lerp(self.viewmodel.offsets.equip.Value, self.lerpValues.equip.Value)

		-- it'll be final for a reason. You saw!
		local finalOffset = equipOffset

		-- Let's get some mouse movement!
		local mouseDelta = game:GetService("UserInputService"):GetMouseDelta()
		if self.aiming then mouseDelta *= 0.1 end
		self.springs.sway:shove(Vector3.new(mouseDelta.X / 200, mouseDelta.Y / 200)) --not sure if this needs deltaTime filtering

		-- speed can be dependent on a value changed when you're running, or standing still, or aiming, etc.
		-- this makes the bobble faster.
		local speed = 1.5
		-- modifier can be dependent on a value changed when you're aiming, or standing still, etc.
		-- this makes the bobble do more. or something.
		local modifier = 0.07
		--print(self.touched)
		if self.jogging then speed = 1.7 end
		
		if self.running then modifier = 0.2 speed = 2 end
		
		if self.aiming then modifier = 0.0 end
		
		

		-- See? Bobbing! contruct a vector3 with getBobbing.
		local movementSway = Vector3.new(getBobbing(10, speed, modifier), getBobbing(5, speed, modifier),getBobbing(5, speed, modifier))

		-- if velocity is 0, then so will the walk cycle
		self.springs.walkCycle:shove((movementSway / 25) * deltaTime * 60 * velocity.Magnitude)

		-- Sway! Yay!
		local sway = self.springs.sway:update(deltaTime)
		local walkCycle = self.springs.walkCycle:update(deltaTime)
		local recoil = self.springs.fire:update(deltaTime)

		-- RecoillllL!!!!!
		spawn(function() 
			self.camera.CFrame = self.camera.CFrame * CFrame.Angles(recoil.x,recoil.y,recoil.z)
			wait(self.recoveryTime)
			self.camera.CFrame = self.camera.CFrame * CFrame.Angles(-recoil.x,-recoil.y,-recoil.z)
		end)
		
		
		
		
		
		if self.proning then
			local rX, rY, rZ = Camera.CFrame:ToOrientation()

			local lim = math.clamp(math.deg(rX), 0, 20)

			Camera.CFrame = CFrame.new(Camera.CFrame.p) * CFrame.fromOrientation(math.rad(lim), rY, rZ)
		end

		--ToWorldSpace basically means rootpart.CFrame = camera CFrame but offset by xxx while taking rotation into account. I don't know. You'll see how it works soon enough.
		if self.hide~=true then
			self.viewmodel.rootPart.CFrame = self.camera.CFrame:ToWorldSpace(finalOffset)
			self.viewmodel.rootPart.CFrame = self.viewmodel.rootPart.CFrame:ToWorldSpace(CFrame.new(walkCycle.x / 4, walkCycle.y / 2, 0))

			-- Rotate our rootpart based on sway
			self.viewmodel.rootPart.CFrame = self.viewmodel.rootPart.CFrame * CFrame.Angles(0, -sway.x, sway.y)
			self.viewmodel.rootPart.CFrame = self.viewmodel.rootPart.CFrame * CFrame.Angles(0, walkCycle.y / 2, walkCycle.x / 5)
		end
		
		if self.viewmodel:FindFirstChild("laser") then
			local lorigin=self.viewmodel.laser.att0
			local origin = lorigin.WorldPosition
			local direction = lorigin.WorldCFrame.LookVector
			laserHandler:fire(origin, direction, lorigin.Parent)
		end
		
		

	end
	
	if gui.sprint.white.Size.X.Scale==0 then
		self:run(false)
	elseif gui.sprint.white.Size.X.Scale==1.25 and self.running==false then
		
			
		if d then
			if tick()-d>=1 then
				local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				whiteoff=TweenService:Create(gui.sprint.white, tweeningInformation, { BackgroundTransparency = 1})
				whiteoff:Play()

				local tweeningInformation = TweenInfo.new(.5, Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
				backoff=TweenService:Create(gui.sprint.back, tweeningInformation, { BackgroundTransparency = 1})
				backoff:Play()
				d=nil
			end
		end
		

	end
	
	
end




return handler
