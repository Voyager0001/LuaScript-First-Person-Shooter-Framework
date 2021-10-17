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
