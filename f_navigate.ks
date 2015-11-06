// ----------------------------------------------------------------------------
// execute maneuver node
// compiled from the docs on github with a few tweaks
// and bits stolen from other places
// requires:
//      f_warp
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// helper functions
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

function clampHeading {
    declare parameter heading.

    local result to 0.
    
    if heading > 360 {
        set result to heading - 360.
    } else if heading < 0 {
        set result to heading + 360.
    } else {
        set result to heading.
    }

    return heading.
}

// ----------------------------------------------------------------------------
// getOppositeLongitude
// returns the the opposite longitude
// ----------------------------------------------------------------------------
function getETAToLongitude {
    declare parameter l.

    if l < 0 {
        return l + 180.
    } else {
        return l - 180.
    }
}

// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Info and calculation functions
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// getSOI(bd)
// returns the distance from the body that it's SOI is
// ----------------------------------------------------------------------------
function getSOI {
    declare parameter bd.
    // parameter type: body
    local sma to (bd:apoapsis + 2*bd:body:radius + bd:periapsis)/2.
    
    print "T+" + round(missiontime) + " SOI for " + bd:name + ": " + round(soi/1000) + "km".

    return sma*(bd:mu/bd:body:mu)^0.4.
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
    declare parameter r.    // orbital altitude, we will add body radius
    declare parameter a.    // semi-major axis

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
    declare parameter oP.       // orbit period
    return 2 * pi / oP.         // mean motion calclation
}

// ----------------------------------------------------------------------------
// getVectorToANDN(targetNormal, orbitalNormal)
// Returns vector 
// ----------------------------------------------------------------------------
function getVectorToANDN {
    declare parameter targetNormal.     // normal vector of the target orbit
    declare parameter orbitNormal.   // normal vector of ship orbit
    return vcrs(targetNormal, orbitalNormal):normalized.
}

// ----------------------------------------------------------------------------
// getOrbitNormal(orbital)
// Get Orbit Normal Vecotor for orbiting object
// ----------------------------------------------------------------------------
function getOrbitNormal {
    declare parameter orbital.
    // orbital normal vector (the cross product of R and orbital-V) 
    return vcrs(orbital:position-orbital:body:position, orbital:velocity:orbit).
}

// ----------------------------------------------------------------------------
// getEccentricityVector(v, r)
// returns eccentricity vector based on given v and r
// generally v = ship:obt:velocity
// generally r - ship:obt:position
// ----------------------------------------------------------------------------
function getEccentricityVector {
    declare parameter v.    // velocity vector
    declare parameter r.    // position vector
    
    // precalcs
    local h to r * v.   // specific angular momentum vector

    // calcs
    local part1 to v * h / mu.  // mu is gravitational parameter
    local part2 to r / r:mag.

    return part1 - part2.
}

// ----------------------------------------------------------------------------
// getTrueAnomaly(e, v, r)
// returns the true anomaly based on eccentricity vector
// ----------------------------------------------------------------------------
function getETAToLongitude {
    declare parameter e.    // eccentricity vector
    declare parameter v.    // velocity vector
    declare parameter r.    // position vector

    local top to e * r.
    local bottom to e:mag * r:mag.
    local ta to arccos(top / bottom).

    if (r * v) < 0 {
        set ta to 2 * pi - ta.
    }

    return ta.
}

// ----------------------------------------------------------------------------
// getEccentricAnomaly(e, ta)
// returns 
// ----------------------------------------------------------------------------
function getETAToLongitude {
    declare parameter e.    // orbit eccentricity
    declare parameter ta.   // true anomaly

    // precals
    local top to e + cos(ta).
    local bottom to 1 + e * cos(ta).

    local cosE to top / bottom.

    local top1 to sqrt(1 - e*e) * sin(ta).
    local bottom1 to 1 + e * cos(ta).

    local sinE to top1 / bottom1.

    // How to solve for E?
    // M = E - e * sinE
    // E = M + e * sinE
    return.
}


// ----------------------------------------------------------------------------
//
// ----------------------------------------------------------------------------
function getETATrueAnomaly {
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
