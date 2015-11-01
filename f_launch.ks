// ----------------------------------------------------------------------------
// x_ltoa(orbitAltitude)
// launch to orbit from atmospehere to orbitAltitude
// requires:
//      i_bodyProperties
//      f_orbit
//      f_warp
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// launchToOrbitAtmo(orbitAltitude, orbitInclination)
// ----------------------------------------------------------------------------
function launchToOrbitAtmo {
    // ------------------------------------------------------------------------
    // arguments
    declare parameter orbitAltitude.
    declare parameter orbitInclination.

    clearscreen.
    print "Launch to orbit: " + time:calendar + ", " + time:clock.
    print "Desired orbit: " + orbitAltitude + "m at " + orbitInclination + " degrees".


    // prelaunch --------------------------------------------------------------
    print "Prelaunch sequence executing...".
    local tset to 1.
    lock throttle to tset. 
    lock steering to up + R(0, 0, -180).
    local lazData to LAZcalc_init(orbitAltitude, orbitInclination).

    print "T-1 to launch...". 

    // altitude triggers
    local arramp to alt:radar + 25.               // ramp altitude

    when alt:radar > arramp then {
        print "T+" + round(missiontime) + " Liftoff.".
    }

    when alt:radar > gt0 and alt:radar > arramp then {
        print "T+" + round(missiontime) + " Beginning gravity turn.". 
    }

    // launch ---------------------------------------------------------------------
    wait 1.
    print "T+" + round(missiontime) + " Ignition.".
    stage. 

    // atmo accent ----------------------------------------------------------------
    local pitch to 0.

    until altitude > ha or apoapsis > orbitAltitude {
        local ar to alt:radar.
        local heading to 90.

        // perform gravity turn between gt0 and gt1
        if ar > gt0 and ar < gt1 {
            set pitch to max( 5, 90 * (1 - ALT:RADAR / 50000)).
            set heading to LAZcalc(lazData).
            lock steering to heading(heading, pitch).
            print "heading: " + round(heading) + "  " at (20,31).
            print "pitch: " + round(pitch) + "  " at (20,33).
        }

        // face orbital prograde after gravity turn
        if ar > gt1 {
            lock steering to prograde.
        }

        // throttle control

        // dynamic pressure q
        local vsm to velocity:surface:mag.
        local exp to -altitude/sh.
        local ad to ad0 * euler^exp.    // atmospheric density
        local q to 0.5 * ad * vsm^2.
        print "q: " + round(q)  + "  " at (20,34).
        
        // calculate target velocity
        local vl to maxq*0.9.
        local vh to maxq*1.1.
        local tset to 0.
        if q < vl { set tset to 1. }
        if q > vl and q < vh { set tset to (vh-q)/(vh-vl). }
        if q > vh { set tset to 0. }
        
        // Output status
        print "stage#: " + stage:number + "    " at (0, 31).
        print "solidFuel: " + stage:solidfuel + "    " at (0,32).
        print "liquidFuel: " + stage:liquidfuel + "    " at (20,32).
        print "alt:radar: " + round(ar) + "    " at (0,33). 
        print "throttle: " + round(tset,2) + "     " at (0,34).
        print "apoapis: " + round(apoapsis/1000) at (0,35).
        print "periapis: " + round(periapsis/1000) at (20,35).
        
        // loop pause
        wait 0.1.
    }

    // clear out status
    print "                   " at (0,31).
    print "                   " at (0,32).
    print "                   " at (0,33).
    print "                   " at (20,33).
    print "                   " at (20,34).


    // circularize ----------------------------------------------------------------
    set tset to 0.

    // wait until out of atmo to prep for burn
    if altitude < ha {
        print "T+" + round(missiontime) + " Waiting to leave atmosphere".
        lock steering to prograde.
        // thrust to compensate atmospheric drag losses
        until altitude > ha {
            // calculate target velocity
            if apoapsis >= orbitAltitude { set tset to 0. }
            if apoapsis < orbitAltitude { set tset to (orbitAltitude-apoapsis)/(orbitAltitude*0.01). }
            
            print "stage#: " + stage:number + "  " at (0, 31).
            print "solidFuel: " + stage:solidfuel + "  " at (0,32).
            print "liquidFuel: " + stage:liquidfuel + "  " at (20,32).
            print "throttle: " + round(tset,2) + "    " at (0,34).
            print "apoapis: " + round(apoapsis/1000,2) at (0,35).
            print "periapis: " + round(periapsis/1000,2) at (20,35).
            wait 0.1.
        }
    }

    print "                                        " at (0,31).
    print "                                        " at (0,32).
    print "                                        " at (0,33).
    print "                                        " at (0,34).
    print "                                        " at (0,35).
    lock throttle to 0.

    // call setPeriapsis() to circurlize orbit
    setPeriapsis(orbitAltitude).
}



// ----------------------------------------------------------------------------
// These functions stolen from:
// https://raw.githubusercontent.com/KSP-KOS/KSLib/master/library/lib_lazcalc.ks
//This file is distributed under the terms of the MIT license, (c) the KSLib team
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
//=====LAUNCH AZIMUTH CALCULATOR=====
//~~LIB_LAZcalc.ks~~
//~~Version 2.1~~
//~~Created by space-is-hard~~
//~~Updated by TDW89~~
//To use: RUN LAZcalc.ks. SET data TO LAZcalc_init([desired circular orbit altitude in meters],[desired orbital inclination; negative if launching from descending node, positive otherwise]). Then loop SET myAzimuth TO LAZcalc(data).
// ----------------------------------------------------------------------------
FUNCTION LAZcalc_init {
    // ------------------------------------------------------------------------
    // arguments
    PARAMETER
        desiredAlt, //Altitude of desired target orbit (in *meters*)
        desiredInc. //Inclination of desired target orbit
    
    //We'll pull the latitude now so we aren't sampling it multiple times
    LOCAL launchLatitude IS SHIP:LATITUDE.
    
    LOCAL data IS LIST().   // A list is used to store information used by LAZcalc
    
    //Orbital altitude can't be less than sea level
    IF desiredAlt <= 0 {
        PRINT "Target altitude cannot be below sea level".
        SET launchAzimuth TO 1/0.       //Throws error
    }.
    
    //Determines whether we're trying to launch from the ascending or descending node
    LOCAL launchNode TO "Ascending".
    IF desiredInc < 0 {
        SET launchNode TO "Descending".
        
        //We'll make it positive for now and convert to southerly heading later
        SET desiredInc TO ABS(desiredInc).
    }.
    
    //Orbital inclination can't be less than launch latitude or greater than 180 - launch latitude
    IF ABS(launchLatitude) > desiredInc {
        SET desiredInc TO ABS(launchLatitude).
        HUDTEXT("Inclination impossible from current latitude, setting for lowest possible inclination.", 10, 2, 30, RED, FALSE).
    }.
    
    IF 180 - ABS(launchLatitude) < desiredInc {
        SET desiredInc TO 180 - ABS(launchLatitude).
        HUDTEXT("Inclination impossible from current latitude, setting for highest possible inclination.", 10, 2, 30, RED, FALSE).
    }.
    
    //Does all the one time calculations and stores them in a list to help reduce the overhead or continuously updating
    LOCAL equatorialVel IS (2 * CONSTANT():Pi * BODY:RADIUS) / BODY:ROTATIONPERIOD.
    LOCAL targetOrbVel IS SQRT(BODY:MU/ (BODY:RADIUS + desiredAlt)).
    data:ADD(desiredInc).       //[0]
    data:ADD(launchLatitude).   //[1]
    data:ADD(equatorialVel).    //[2]
    data:ADD(targetOrbVel).     //[3]
    data:ADD(launchNode).       //[4]
    RETURN data.
}.


// ----------------------------------------------------------------------------
// LAZcalc(data)
// returns heading for launch inclination
// ----------------------------------------------------------------------------
FUNCTION LAZcalc {
    PARAMETER
        data. //pointer to the list created by LAZcalc_init
    LOCAL inertialAzimuth IS ARCSIN(MAX(MIN(COS(data[0]) / COS(SHIP:LATITUDE), 1), -1)).
    LOCAL VXRot IS data[3] * SIN(inertialAzimuth) - data[2] * COS(data[1]).
    LOCAL VYRot IS data[3] * COS(inertialAzimuth).
    
    // This clamps the result to values between 0 and 360.
    LOCAL Azimuth IS MOD(ARCTAN2(VXRot, VYRot) + 360, 360).
    
    //Returns northerly azimuth if launching from the ascending node
    IF data[4] = "Ascending" {
        RETURN Azimuth.
        
    //Returns southerly azimuth if launching from the descending node
    } ELSE IF data[4] = "Descending" {
        IF Azimuth <= 90 {
            RETURN 180 - Azimuth.
            
        } ELSE IF Azimuth >= 270 {
            RETURN 540 - Azimuth.
            
        }.
    }.
}.