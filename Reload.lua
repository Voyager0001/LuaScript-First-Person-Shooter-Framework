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
