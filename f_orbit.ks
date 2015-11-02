// ----------------------------------------------------------------------------
// f_orbit
// orbit changing related functions
// requires:
// 		i_bodyProperties
//		f_navigate
// 		x_executeNode
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

// ----------------------------------------------------------------------------
// setApoapsis(alt)
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
	executeNode(nd).
}

// ----------------------------------------------------------------------------
// setPeriapsis(alt)
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
	executeNode(nd).
}


// ----------------------------------------------------------------------------
// setInclination
// ----------------------------------------------------------------------------
function setInclinationX {
	// ------------------------------------------------------------------------
	// arguments
	declare parameter inclination.
	//declare parameter longAscNode.

	// declarations
	local orbit to ship:obt.
	local currentInclination to orbit:inclination.
	//You can get the True Anomaly, Eccentricity, Semi-Major Axis, Mean Anomaly,
	// and Orbital Period from kOS. Then you will need these two pieces of information	
	local orbitalPeriod to orbit:period.					// P: Orbital Period
	local meanAnomalyCurrent to orbit:MEANANOMALYATEPOCH.	// M: Mean Anomaly (Current)
	local eccentricity to orbit:ECCENTRICITY.				// e: Eccentricity
	local trueAnomoly to orbit:TRUEANOMALY.					// theta: True Anomaly
	local semiMajorAxis to orbit:semimajoraxis.				// a: Semi-Major Axis

	// precalulations
	local deltaInclination to currentInclination - inclination.
	if deltaInclination < -180 {
		set deltaInclination to deltaInclination + 360.
	}

	// output starting parameters
	print "T+" + round(missiontime) + " Inclination maneuver, orbiting " + body:name.
	print "T+" + round(missiontime) + " New inclination: " + inclination.
	//print "T+" + round(missiontime) + " New longitude of ascending node: " + longAscNode.
	print "T+" + round(missiontime) + " Current inclination: " + currentInclination.
	print "T+" + round(missiontime) + " Orbital Period: " + orbitalPeriod.
	print "T+" + round(missiontime) + " Mean Anomaly: " + meanAnomalyCurrent.
	print "T+" + round(missiontime) + " Ecentricity: " + eccentricity.
	print "T+" + round(missiontime) + " Semi-major Axis: " + semiMajorAxis.

	// ------------------------------------------------------------------------
	// calculate when to burn, this should be done at the long of the asc node
	// or the ascending or decending node

	// determine mean anomoly
	// To find the time to each of these nodes you will determine if the True Anomaly falls within these two categories.
	// if theta > 270 (remember max is 360, then resets to 0) AND theta < 90 { Use M1}
	// if theta > 90 AND theta < 270 { Use M2 }
	local meanAnomoly to 0.
	if trueAnomoly > 270 {
		// M1 = Mean Anomaly of First Node (wether its ascending or descending depends on inclination) = pi/2 - e
		set meanAnomoly to pi/2 - eccentricity.
	} else {
		// M2 = Mean Anomaly of Second Node (this will be the opposite of the first node) = 3*pi/2 - e
		set meanAnomoly to 3 * pi / 2 - eccentricity.
	}

	print "T+" + round(missiontime) + " Mean Anomaly: " + meanAnomoly.

	// ------------------------------------------------------------------------
	// determine eta - you use this formula to figure out the time:
	local meanNotion to 2 * pi / orbitalPeriod.		// n : Mean Notion = 2*pi/P

	print "T+" + round(missiontime) + " Mean Notion: " + meanNotion.

	//t = Time to Next Node = (Mx - M)/n (Mx is either M1 or M2 depending on where you are on the orbit)
	local nodeETA to (meanAnomoly - meanAnomalyCurrent) / meanNotion.
	
	print "T+" + round(missiontime) + " Node ETA: " + nodeETA.

	// get velocity vector at ETA time

	// ------------------------------------------------------------------------
	// calculate delta v need to change inclination
	local deltav to 2 * shipVelocity * sin(deltaInclination/2).

	print "T+" + round(missiontime) + " dV: " + deltav.

	// create node
	local nd to node(time:seconds + nodeETA, deltav:x, deltav:y, deltav:z).
	add nd.

	// TODO: execute node
}


// ----------------------------------------------------------------------------
// setInclination(id)
// Attempts to adjust the inclination of the current orbit to the desired angle
// Always performs burn at apoapsis for most efficient burn. It may be wise to
// break the full adjustment into smaller bits, or consider raising apoapsis
// to save fuel.
// ----------------------------------------------------------------------------
function setInclination {
	declare parameter id. // inclination desired

	// gather infos
	local ApEta to eta:apoapsis.					// ETA Apoapsis
	local ApTime to ApEta + time:seconds.			// Apoapsis time
	local o to orbitat(ship, ApTime).				// ship orbit
	local ii to o:inclination.						// initial inclination
	local e to o:eccentricity.						// eccentricity
	local w to o:argumentofperiapsis.				// argument of periapsis
	local f to o:trueanomaly. 						// true anomoly at ETA
	local oP to o:period.							// orbit period
	local n to calcMeanMotion(oP).					// mean motion calclation
	local a to o:semimajoraxis.						// semi major axis.
	local di to ii - id.
	if di < -180 {
		set di to di + 360.
	}

	print "T+" + round(missiontime) + " di: " + di.	// difference in inclination

	local top to 2 * sin(di/2) * sqrt(1 - e*e) * cos(w + f) * n * a.
	local bottom to 1 + e * cos(f).
	local dV to top / bottom.

	print "T+" + round(missiontime) + " Result dV: " + dV.
	//local nd to node(ApTime, 0, dV, 0).
	//add nd.
	// executeNode(nd).
}

// ----------------------------------------------------------------------------
// getETAToLongitude
// returns the eta in the current orbit to a speicifc longitude
// ----------------------------------------------------------------------------
function getETAToLongitude {
	// prediction functions will help here
	// http://ksp-kos.github.io/KOS_DOC/commands/prediction.html
}


// ----------------------------------------------------------------------------
// getSpeedByRA(r,a)
// returns orbit velocity given orbital altitude and semi-major axis
// Give altitude above sea level, function will add body radius
// ----------------------------------------------------------------------------
function getSpeedByRA {
	// orbital altitude, we will add body radius
	declare parameter r.
	// semi-major axis
	declare parameter a.

	local r1 to r + rb.

	// calculate and return value
	return sqrt(mu * ( (2/r1) - (1/a) )).
}


// ----------------------------------------------------------------------------
// calcOrbitBTDeltaVDiff(dVi,dVf)
// For more complicated maneuvers which may involve a combination of change
// in inclination and orbital radius, the amount of delta v is the vector
// difference between the velocity vectors of the initial orbit and the desired
// orbit at the transfer point.
// ----------------------------------------------------------------------------
function calcOrbitBTDeltaVDiff {
	return dV1 - dVf.
}

// ----------------------------------------------------------------------------
// calcMeanMotion(oP)
// Returns mean motion (n) based on given orbital period.
// ----------------------------------------------------------------------------
function calcMeanMotion {
	declare parameter oP.		// orbit period
	return 2 * pi / oP.			// mean motion calclation
}

