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
