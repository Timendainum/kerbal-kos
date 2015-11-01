// launch to orbit (w/ atmosphere)

print "Launch to orbit: " + time:calendar + ", " + time:clock.

// prelaunch ------------------------------------------------------------------
print "Prelaunch sequence executing...".
set tset to 1.
lock throttle to tset. 
lock steering to up + R(0, 0, -180).

print "T-1 to launch...". 

// altitude triggers
set arramp to alt:radar + 25.               // ramp altitude

when alt:radar > arramp then {
    print "T+" + round(missiontime) + " Liftoff.".
}

when alt:radar > gt0 then {
    print "T+" + round(missiontime) + " Beginning gravity turn.". 
}

// launch ---------------------------------------------------------------------
wait 1.
print "T+" + round(missiontime) + " Ignition.".
stage. 

// atmo accent ----------------------------------------------------------------
set pitch to 0.

until altitude > ha or apoapsis > lorb {
    set ar to alt:radar.
    
    // perform gravity turn between gt0 and gt1
    if ar > gt0 and ar < gt1 {
        set arr to (ar - gt0) / (gt1 - gt0).
        set pda to (cos(arr * 180) + 1) / 2.
        set pitch to pitch1 * ( pda - 1 ).
        lock steering to up + R(0, pitch, -180).
        print "pitch: " + round(90+pitch) + "  " at (20,33).
    }

    // face orbital prograde after gravity turn
    if ar > gt1 {
        lock steering to up + R(0, pitch, -180).
    }

    // throttle control

    // dynamic pressure q
    set vsm to velocity:surface:mag.
    set exp to -altitude/sh.
    set ad to ad0 * euler^exp.    // atmospheric density
    set q to 0.5 * ad * vsm^2.
    print "q: " + round(q)  + "  " at (20,34).
    
    // calculate target velocity
    set vl to maxq*0.9.
    set vh to maxq*1.1.
    if q < vl { set tset to 1. }
    if q > vl and q < vh { set tset to (vh-q)/(vh-vl). }
    if q > vh { set tset to 0. }
    
    // Output status

    print "alt:radar: " + round(ar) + "  " at (0,33). 
    print "throttle: " + round(tset,2) + "   " at (0,34).
    print "apoapis: " + round(apoapsis/1000) at (0,35).
    print "periapis: " + round(periapsis/1000) at (20,35).
    
    // loop pause
    wait 0.1.
}

// clear out status
print "                   " at (0,33).
print "                   " at (20,33).
print "                   " at (20,34).


// circularize ----------------------------------------------------------------
set tset to 0.

// wait until out of atmo to prep for burn
if altitude < ha {
    print "T+" + round(missiontime) + " Waiting to leave atmosphere".
    lock steering to up + R(0, pitch, 0).       // roll for orbital orientation
    // thrust to compensate atmospheric drag losses
    until altitude > ha {
        // calculate target velocity
        if apoapsis >= lorb { set tset to 0. }
        if apoapsis < lorb { set tset to (lorb-apoapsis)/(lorb*0.01). }
        print "throttle: " + round(tset,2) + "    " at (0,34).
        print "apoapis: " + round(apoapsis/1000,2) at (0,35).
        print "periapis: " + round(periapsis/1000,2) at (20,35).
        wait 0.1.
    }
}

print "                                        " at (0,33).
print "                                        " at (0,34).
print "                                        " at (0,35).
lock throttle to 0.

// aponode works only in vacuum as it uses ship v to calc apoapsis velocity
run z_aponode(lorb).
run z_exenode.
