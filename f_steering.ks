// ----------------------------------------------------------------------------
// f_steering
// steering related functions
// requires:
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

// ----------------------------------------------------------------------------
// Turn To Sun. make sure solar panels are exposed
// ----------------------------------------------------------------------------
function turnToSun {
	print "T+" + round(missiontime) + " Turning ship to sun.".
	local dir to R(-90,0,0).
	lock steering to dir.
	local tolerance to 0.01.
	wait until abs(sin(dir:pitch) - sin(facing:pitch)) < tolerance and abs(sin(dir:yaw) - sin(facing:yaw)) < tolerance.
}
