//------------------------------------------------------
// execute maneuver node
// compiled from the docs on github with a few tweaks
// and bits stolen from other places

// Find the next node
set nd to nextnode.

// output node info
print "T+" + round(missiontime) + " Node apoapsis: " + round(nd:orbit:apoapsis/1000,2) + "km, periapsis: " + round(nd:orbit:periapsis/1000,2) + "km".
print "T+" + round(missiontime) + " Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).


set maxAcceleration to ship:maxthrust/ship:mass.
set burnDuration to nd:deltav:mag/maxAcceleration.
print "T+" + round(missiontime) + " Max acc: " + round(maxAcceleration) + "m/s^2, Burn duration: " + round(burnDuration) + "s".

// warp to node
run z_warpfor(nd:eta - burnDuration/2 - 60).

// turn ship to burn direction
print "T+" + round(missiontime) + " Turning ship to burn direction.".
sas off.
rcs off.

// points to node, keeping roll the same.
set np to lookdirup(nd:deltav, ship:facing:topvector). 
lock steering to np.

// now we need to wait until the burn vector and ship's facing are aligned
wait until abs(np:pitch - facing:pitch) < 0.15 and abs(np:yaw - facing:yaw) < 0.15.

// warp until ready to burn
run z_warpfor(nd:eta - burnDuration/2).

// Begin burn
print "T+" + round(missiontime) + " burn start " + round(nd:eta) + "s before node.".
set throttleSetting to 0.
lock throttle to throttleSetting.

//control  burn
set done to False.
set once to True.
set dv0 to nd:deltav.
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
print "Removing node".
remove nd.
