--from GodAimAkira https://www.godaimakira.com/post/monitor-distance-match-en/
function mmm(ratio, sens, firstFOV, secondFOV) 
  fov0=firstFOV* 0.5 * math.pi / 180
  fov1 = secondFOV * 0.5 * math.pi / 180
  cm360_1=100
  alpha0 = math.atan(ratio * math.tan(fov0))
  alpha1 = math.atan(ratio * math.tan(fov1))
  cm360_2 = cm360_1 * alpha0 / alpha1
  newSens=sens*(cm360_2/100)
end
