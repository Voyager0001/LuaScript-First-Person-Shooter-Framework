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
