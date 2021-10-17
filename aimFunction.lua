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
