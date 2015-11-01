// Kerbal automated mission challenge
clearscreen.
run checkvessel("Minmus Lander 1b").
copy prep to 1.
toggle gear.      // BUG: KSP requires to toggle gear initially as nop
run bodyprops.
run warpday.
if status = "PRELAUNCH" {
    when status <> "PRELAUNCH" and stage:solidfuel < 0.1 then { 
        print "T+" + round(missiontime) + " Booster separation.". 
        stage. 
    }    
    // event handler for staging
    set trg2 to 0.
    when status <> "PRELAUNCH" and stage:liquidfuel < 0.1 then { 
        if stage:liquidfuel > 0 {
            print "T+" + round(missiontime) + " WARNING! remaining liquidfuel: " + stage:liquidfuel. 
        }
        print "T+" + round(missiontime) + " Stage 1 separation.". 
        stage. 
        set trg2 to missiontime + 1.
    }
    when trg2 > 0 and missiontime > trg2 then {
        print "T+" + round(missiontime) + " Stage 2 ignition.". 
        stage. 
    }
    run ltoa.
}
if abs(apoapsis-periapsis) > 500 {
    print "T+" + round(missiontime) + " Apo-/periapsis differ " + round(abs(apoapsis-periapsis)) + "m, circularising.".
    run aponode(apoapsis).
    run exenode.
    print "T+" + round(missiontime) + " Apo-/periapsis differ after burn " + round(abs(apoapsis-periapsis)) + "m.".
}
run incnode(Minmus).
run exenode.
run hohnode(Minmus).
run exenode.
run tts.
run warpinsoi(Minmus).
run bodyprops.
// injection
run perinode(rb/2).     // assumes rb/2 < periapsis, otherwise follow-up maneuvers will fail
run exenode.
// circularise
run bodyprops.
run perinode(rb/2). 
run exenode.
run landnode(lorb/2).
run exenode.
// staging handlers
when stage:liquidfuel < 0.1 or periapsis < -0.75*rb then { 
    print "T+" + round(missiontime) + " Throttling idle for staging.". 
    lock throttle to 0.
    set trg1 to missiontime + 0.5.
}
set trg1 to 0.
when trg1 > 0 and missiontime > trg1 then {
    print "T+" + round(missiontime) + " Stage separation.". 
    if stage:liquidfuel > 0 {
        print "T+" + round(missiontime) + " WARNING! remaining liquidfuel: " + stage:liquidfuel. 
    }
    stage. 
    set trg2 to missiontime + 2.
}
set trg2 to 0.
when trg2 > 0 and missiontime > trg2 then {
    print "T+" + round(missiontime) + " Lander ignition.". 
    stage.
    set tset to 0.
    lock throttle to tset.
}
run landv(1.5).
