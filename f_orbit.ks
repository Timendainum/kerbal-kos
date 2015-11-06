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
// setInclination(id)
// Attempts to adjust the inclination of the current orbit to the desired angle
// Always performs burn at apoapsis for most efficient burn. It may be wise to
// break the full adjustment into smaller bits, or consider raising apoapsis
// to save fuel.
// ----------------------------------------------------------------------------
function setInclination {
	declare parameter id. // inclination desired

	// nodeEta needs to not be using apoapsis for change point, this needs to be at an or dn.
	// which I cannot compute at this time.

	// gather infos
	local nodeEta to eta:apoapsis.					// ETA to burn node
	local ApTime to nodeEta + time:seconds.			// Apoapsis time
	local o to orbitat(ship, ApTime).				// ship orbit
	local ii to o:inclination.						// initial inclination
	local e to o:eccentricity.						// eccentricity
	local w to o:argumentofperiapsis.				// argument of periapsis
	local f to o:trueanomaly. 						// true anomoly at ETA
	local oP to o:period.							// orbit period
	local n to calcMeanMotion(oP).					// mean motion calclation
	local a to o:semimajoraxis.						// semi major axis.
	local di to ii - id.							// difference in inclination
	if di < -180 {
		set di to di + 360.
	}

	print "T+" + round(missiontime) + " di: " + di.

	local top to 2 * sin(di/2) * sqrt(1 - e*e) * cos(w + f) * n * a.
	local bottom to 1 + e * cos(f).
	local dV to top / bottom.

	print "T+" + round(missiontime) + " Result dV: " + dV.
	// TODO: Burn Direction is not worked out yet, I shoulld be burning normal
	// at the ascending node and anti-normal at decending to raise the inclination.
	// Opposite to lower it.
	local nd to node(ApTime, 0, dV, 0).
	add nd.
	executeNode(nd).
}



  function eta_true_anom {
    declare local parameter tgt_lng.
    // convert the positon from reference to deg from PE (which is the true anomaly)
    LOCAL ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
    local angle to mod((720 + tgt_lng - ship_ref),360).
    local node_true_anom to OBT:TRUEANOMALY + angle.
    local node_eta to 0.
    local ecc to OBT:ECCENTRICITY.
if ecc < 0.001 {
        set node_eta to SHIP:OBT:PERIOD * ((mod(tgt_lng - ship_ref + 360,360))) / 360.
} else {

        local eccentric_anomaly to arccos((ecc+cos(node_true_anom))/(1+  ecc* cos(node_true_anom))).
        local mean_anom to (eccentric_anomaly - ((180 / (constant():pi)) * (ecc * sin(eccentric_anomaly)))).

       // time from periapsis to point
        local time_2_anom to  SHIP:OBT:PERIOD * mean_anom /360.

        local my_time_in_orbit to ((OBT:MEANANOMALYATEPOCH)*OBT:PERIOD /360).
        set node_eta to mod(OBT:PERIOD + time_2_anom - my_time_in_orbit,OBT:PERIOD) .
     }
    return node_eta.
}

 function set_inc_lan {
    DECLARE PARAMETER incl_t.
    DECLARE PARAMETER lan_t.
    print " ".
    local incl_i to SHIP:OBT:INCLINATION.
    local lan_i to SHIP:OBT:LAN. 

// setup the vectors to highest latitude; Transform spherical to cubic coordinates.
    local Va to V(sin(incl_i)*cos(lan_i+90),sin(incl_i)*sin(lan_i+90),cos(incl_i)).
    local Vb to V(sin(incl_t)*cos(lan_t+90),sin(incl_t)*sin(lan_t+90),cos(incl_t)).
// important to use the reverse order
    local Vc to VCRS(Vb,Va).

    local dv_factor to 1.
    //compute burn_point and set to the range of [0,360]
    local node_lng to mod(arctan2(Vc:Y,Vc:X)+360,360).

    local ship_ref to mod(obt:lan+obt:argumentofperiapsis+obt:trueanomaly,360).
    ´local ship_2_node to mod((720 + node_lng - ship_ref),360).
//  print "ship_2_node:   " + round (ship_2_node,1).
    if ship_2_node > 180 {
        print "Switching to DN".
        set node_lng to mod(node_lng + 180,360).
    }       

    local angle_to_lan to abs(180 + node_lng - OBT:LAN).
 // print "angle_to_lan:   " + round (angle_to_lan,1).  
    // we are at the DN side, dV be reverse.    
    if  angle_to_lan > 90 {
        print "Switching burn direction".
        set dv_factor to -1.
    }



    //local angle to mod((720 + node_lng - ship_ref),360).
    //local node_true_anom to mod(OBT:TRUEANOMALY + angle,360).

    //local ecc to OBT:ECCENTRICITY.
    //local my_radius to OBT:SEMIMAJORAXIS * (( 1 - ecc^2)/ (1 + ecc*cos(node_true_anom)) ).
    //local my_speed to sqrt(SHIP:BODY:MU * ((2/my_radius) - (1/OBT:SEMIMAJORAXIS)) ).
    //print "my_speed:   " + my_speed.      LOCAL node_eta to eta_true_anom(node_lng).

local node_eta to eta_true_anom(node_lng).
    local my_speed to VELOCITYAT(SHIP, time+node_eta):ORBIT:MAG.   
    local d_inc to arccos (vdot(Vb,Va) ).
    print "Delta incl: " + round(d_inc,2).
    local dvtgt to dv_factor* (2 * (my_speed) * SIN(d_inc/2)).

    print "inc_Burn dV: " + round(dvtgt,2).
    print "Node LNG: " + round(node_lng,1).
    print "inc_Burn ETA: " + round(node_eta,2). 

    // Create a blank node
    LOCAL inc_node TO NODE(node_eta, 0, 0, 0).
    // we need to split our dV to normal and prograde
    SET inc_node:NORMAL TO dvtgt * cos(d_inc/2).
    // always burn retrograde
    SET inc_node:PROGRADE TO 0 - abs(dvtgt * sin(d_inc/2)).
    SET inc_node:ETA TO node_eta.

    ADD inc_node.

}