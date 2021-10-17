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
