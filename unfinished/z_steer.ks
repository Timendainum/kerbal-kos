declare parameter dir.
set tolerance to 0.03.
print "T+" + round(missiontime) + " Turning ship to " + dir + ".".
sas off.
rcs off.
lock steering to dir.
wait until abs(sin(dir:pitch) - sin(facing:pitch)) < tolerance and abs(sin(dir:yaw) - sin(facing:yaw)) < tolerance and abs(sin(dir:roll) - sin(facing:roll)) < tolerance.
// print "T+" + round(missiontime) + " Done.".
