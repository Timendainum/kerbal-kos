// ----------------------------------------------------------------------------
// x_corbit(orbitAltitude, error)
// sets a circular orbit to the altitude specified within the specified error
// requires:
//      i_bodyProperties
//      f_orbit
//      f_warp
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.
// ----------------------------------------------------------------------------
// arguments
declare parameter orbitAltitude, error.

// ----------------------------------------------------------------------------
// includes
run i_bodyProperties.
run f_orbit.
run f_navigate.
run f_warp.

// ----------------------------------------------------------------------------
// set up error detection
local orbitEcError to 0.
local orbitApError to 0.
local orbitPeError to 0.
local done to False.
clearscreen.
print "T+" + round(missiontime) + " Setting orbit to " + orbitAltitude + "m".

local function getOrbitError {
	set orbitEcError to apoapsis - periapsis.
	set orbitApError to apoapsis - orbitAltitude.
	set orbitPeError to periapsis - orbitAltitude.
}

local function output {
	print "-------------------------------------------------".
	print "Desired orbit: " + orbitAltitude + "m".
	print "Allowed error: " + error + "m".
	print "orbitEcError: " + round(orbitEcError) + "m".
	print "orbitApError: " + round(orbitApError) + "m".
	print "orbitPeError: " + round(orbitPeError) + "m".
}

local function isDone {
	 if abs(orbitEcError) < error and abs(orbitApError) < error and abs(orbitPeError) < error {
	 	set done to True.
	 	print "Done".
	 } else {
	 	print "Not done".
	 }

}

// ----------------------------------------------------------------------------
// init correction loop
getOrbitError().

// ----------------------------------------------------------------------------
// correction loop
until done = True {
	getOrbitError().
	output().
	isDone().

	if done = False {
		if abs(orbitApError) > abs(orbitPeError) {
			print "Ap".
			setApoapsis(orbitAltitude).
		} else {
			print "Pe".
			setPeriapsis(orbitAltitude).
		}
	}
	wait 1.
}

print "T+" + round(missiontime) + " Orbit is within " + error + "m".
