#By https://www.godaimakira.com/post/monitor-distance-match-en/
import math
ratio=.20
firstFOV=103.027251
secondFOV=29.442317
fov0=firstFOV* 0.5 * math.pi / 180
fov1 = secondFOV * 0.5 * math.pi / 180
cm360_1=11.298*2.54
alpha0 = math.atan(ratio * math.tan(fov0))
alpha1 = math.atan(ratio * math.tan(fov1))
cm360_2 = cm360_1 * alpha0 / alpha1
print("new Inch360", cm360_2/2.54)
