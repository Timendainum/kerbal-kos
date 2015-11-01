// ----------------------------------------------------------------------------
// f_orbit
// orbit changing related functions
// requires:
// 		i_bodyProperties
// 		x_executeNode
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

// ----------------------------------------------------------------------------
// setApoapsis
// This function adjusts the periapsis to specified altitude
// ----------------------------------------------------------------------------
function setApoapsis {
	declare parameter alt.

	// output manouver parameters
	print "T+" + round(missiontime) + " Set apoapsis maneuver, orbiting " + body:name.
	print "T+" + round(missiontime) + " New apoapsis " + alt + "m".
	print "T+" + round(missiontime) + " Current apoapsis: " + round(apoapsis/1000) + "km".
	print "T+" + round(missiontime) + " Curent periapsis: " + round(periapsis/1000) + "km -> " + round (alt/1000) + "km".

	// output manouver parameters
	local vom to velocity:orbit:mag.  				// actual velocity
	local r to rb + altitude.         				// actual distance to body
	local ra to rb + periapsis.        				// radius in periapsis
	local va to sqrt( vom^2 + 2*mu*(1/ra - 1/r) ). 	// velocity in periapsis
	local a to (periapsis + 2*rb + apoapsis)/2. 		// semi major axis present orbit

	// future orbit properties
	local r2 to rb + periapsis.    					// distance after burn at periapsis
	local a2 to (alt + 2*rb + periapsis)/2. 			// semi major axis target orbit
	local v2 to sqrt( vom^2 + (mu * (2/r2 - 2/r + 1/a - 1/a2 ) ) ).

	// setup node 
	local deltav to v2 - va.
	print "T+" + round(missiontime) + " Periapsis burn: " + round(va) + ", dv:" + round(deltav) + " -> " + round(v2) + "m/s".
	local nd to node(time:seconds + eta:periapsis, 0, 0, deltav).
	add nd.
	print "T+" + round(missiontime) + " Node created.".
	run x_executenode.
}

// ----------------------------------------------------------------------------
// setPeriapsis
// This function adjusts the periapsis to specified altitude
// ----------------------------------------------------------------------------
function setPeriapsis {
	declare parameter alt.

	// output manouver parameters
	print "T+" + round(missiontime) + " Set periapsis maneuver, orbiting " + body:name.
	print "T+" + round(missiontime) + " New periapsis " + alt + "m".
	print "T+" + round(missiontime) + " Current apoapsis: " + round(apoapsis/1000) + "km".
	print "T+" + round(missiontime) + " Curent periapsis: " + round(periapsis/1000) + "km -> " + round (alt/1000) + "km".

	// present orbit properties
	local vom to velocity:orbit:mag.  				// actual velocity
	local r to rb + altitude.         				// actual distance to body
	local ra to rb + apoapsis.        				// radius in apoapsis
	local va to sqrt( vom^2 + 2*mu*(1/ra - 1/r) ).	// velocity in apoapsis
	local a to (periapsis + 2*rb + apoapsis)/2. 	// semi major axis present orbit

	// future orbit properties
	local r2 to rb + apoapsis.    					// distance after burn at apoapsis
	local a2 to (alt + 2*rb + apoapsis)/2. 			// semi major axis target orbit
	local v2 to sqrt( vom^2 + (mu * (2/r2 - 2/r + 1/a - 1/a2 ) ) ).

	// setup node 
	local deltav to v2 - va.
	print "T+" + round(missiontime) + " Apoapsis burn: " + round(va) + ", dv:" + round(deltav) + " -> " + round(v2) + "m/s".

	local nd to node(time:seconds + eta:apoapsis, 0, 0, deltav).
	add nd.

	print "T+" + round(missiontime) + " Node created.".
	run x_executenode.
}
