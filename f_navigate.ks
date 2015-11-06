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
// getETATrueAnomaly(tgt_lng)
// returns the eta to the true anomaly of the specified longitude
// This should make it possible to find any point on an orbit based on 
// longitude
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
