// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------
// Node management functions
// ----------------------------------------------------------------------------
// ----------------------------------------------------------------------------


// ----------------------------------------------------------------------------
// cleanNodes()
// ----------------------------------------------------------------------------
function cleanNodes {
    local fNode to node(TIME:SECONDS + 9999999999999, 0, 0, 1).
    add fNode.
    local nd to nextnode.
    until nd = fNode {
        set nd to nextnode.
        remove nd.
        wait 0.1.
    }
    remove fNode.
}

// ----------------------------------------------------------------------------
// anyNodes()
// this isn't working consistently
// ----------------------------------------------------------------------------
function anyNodes {
    local result to False.
    local fNode to node(TIME:SECONDS + 999999999999, 0, 0, 1).
    add fNode.
    wait 0.1.
    local nd to nextnode.
    until nd = fNode {
        set result to True.
        set nd to nextnode.
    }
    remove fNode.
    return result.
}

// ----------------------------------------------------------------------------
// executeNode(nd)
// ----------------------------------------------------------------------------
function executeNode {
    // ----------------------------------------------------------------------------
    // arguments
    parameter nd.

    // ----------------------------------------------------------------------------
    // output node info
    print "T+" + round(missiontime) + " Node apoapsis: " + round(nd:orbit:apoapsis/1000,2) + "km, periapsis: " + round(nd:orbit:periapsis/1000,2) + "km".
    print "T+" + round(missiontime) + " Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

    if nd:eta < timeout {
        print "T+" + round(missiontime) + " Node in: " + round(nd:eta) + ". This is too soon to execute, aborting.".
        remove nd.
        return.
    }

    // ----------------------------------------------------------------------------
    local maxAcceleration to ship:maxthrust/ship:mass.
    local burnDuration to nd:deltav:mag/maxAcceleration.
    print "T+" + round(missiontime) + " Max acc: " + round(maxAcceleration) + "m/s^2, Burn duration: " + round(burnDuration) + "s".

    // ----------------------------------------------------------------------------
    // warp to node
    warpFor(nd:eta - burnDuration/2 - 60).

    // turn ship to burn direction
    print "T+" + round(missiontime) + " Turning ship to burn direction.".
    sas off.
    rcs off.

    // points to node, keeping roll the same.
    local np to lookdirup(nd:deltav, ship:facing:topvector). 
    lock steering to np.

    // now we need to wait until the burn vector and ship's facing are aligned
    wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.

    // warp until ready to burn
    warpFor(nd:eta - burnDuration/2).

    // Begin burn
    print "T+" + round(missiontime) + " burn start " + round(nd:eta) + "s before node.".
    local throttleSetting to 0.
    lock throttle to throttleSetting.

    //control  burn
    local done to False.
    local once to True.
    local dv0 to nd:deltav.
    until done {
    	// recalculate acceleration as we burn off fuel
        set maxAcceleration to ship:maxthrust/ship:mass.
    	
    	// set throttle up
        set throttleSetting to min(nd:deltav:mag/maxAcceleration, 1).
    	
    	// output a message once when we begin throttling down
        if once and throttleSetting < 1 {
            print "T+" + round(missiontime) + " Throttling down, remain dv " + round(nd:deltav:mag) + "m/s, fuel:" + round(stage:liquidfuel).
            set once to False.
        }
    	
    	// output message if we overshoot the burn and cut the throttle
        if vdot(dv0, nd:deltav) < 0 {
            print "T+" + round(missiontime) + " End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0.
            break.
        }
    	
    	// slow down nice and easy
        if nd:deltav:mag < 0.1 {
            print "T+" + round(missiontime) + " Finalizing, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            wait until vdot(dv0, nd:deltav) < 0.5.
            lock throttle to 0.
            print "T+" + round(missiontime) + " End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            set done to True.
        }
    }

    // let go of steering
    unlock steering.

    // output results
    print "T+" + round(missiontime) + " Apoapsis: " + round(apoapsis/1000,2) + "km, periapsis: " + round(periapsis/1000,2) + "km".
    print "T+" + round(missiontime) + " Fuel after burn: " + round(stage:liquidfuel).

    // wait a sec then delete the node
    wait 1.
    print "T+" + round(missiontime) + "Removing node".
    remove nd.
}
