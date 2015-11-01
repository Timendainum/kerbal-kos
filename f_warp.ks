// ----------------------------------------------------------------------------
// f_warp
// warp related functions
// requires:
// 		f_info
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

// ----------------------------------------------------------------------------
// warpFor(dt)
// warps for specified number of seconds
// ----------------------------------------------------------------------------
function warpFor {
	declare parameter dt.
	// warp    (0:1) (1:5) (2:10) (3:50) (4:100) (5:1000) (6:10000) (7:100000)
	// min alt        atmo   atmo   atmo    120k     240k      480k       600k
	// time:seconds also works before takeoff! Unlike missiontime.
	local t1 to time:seconds + dt.
	if dt < 0 {
	    print "T+" + round(missiontime) + " Warning: wait time " + round(dt) + " is in the past.".
	}
	local oldwp to 0.
	local oldwarp to warp.
	until time:seconds >= t1 {
	    local rt to t1 - time:seconds.       // remaining time
	    local wp to 0.
	    if rt > 5      { set wp to 1. }
	    if rt > 10     { set wp to 2. }
	    if rt > 50     { set wp to 3. }
	    if rt > 100    { set wp to 4. }
	    if rt > 1000   { set wp to 5. }
	    if rt > 10000  { set wp to 6. }
	    if rt > 100000 { set wp to 7. }
	    if wp <> oldwp or warp <> wp {
	        local warp to wp.
	        wait 0.1.
	        if wp <> oldwp or warp <> oldwarp {
	            print "T+" + round(missiontime) + " Warp " + warp + "/" + wp + ", remaining wait " + round(rt) + "s".
	        }
	        set oldwp to wp.
	        set oldwarp to warp.
	    }
	    wait 0.1.
	}
}

// ----------------------------------------------------------------------------
// warpToDay()
// warp to daytime
// ----------------------------------------------------------------------------
function warpToDay {
	// wait for day, i.e. until dawn
	// prerequisite: on the ground
	local ps to V(0,0,0) - body:position.
	local pk to Sun:position - body:position.
	local daynight to vdot(ps, pk).                // positive day , negative night
	local eastwest to vdot(pk, velocity:orbit).    // positive when orbiting towards Sun, negative away
	local atgt to 90.
	if daynight < 0 {
		local adawn to 0.
	    print "Waiting for sunrise.".
	    local a to vang(ps, pk).
	    set atgt to 90.
	    if eastwest > 0 {
	        set adawn to a - atgt.
	    } else {
	        set adawn to 360 - atgt - a.
	    }
	    local rp to 2 * pi * ps:mag / velocity:orbit:mag. // rotational period
	    local dt to rp/360*adawn.
	    warpFor(dt).
	} else {
	    print "Skipping warp to day because it is already day.".
	}
}

// ----------------------------------------------------------------------------
// warpToDistance(refbody, dist)
// warp to distance relative to refbody
// ----------------------------------------------------------------------------
function warpToDistance {
	declare parameter refbody, dist.
	// warp until crossing distance 
	// warp    (0:1) (1:5) (2:10) (3:50) (4:100) (5:1000) (6:10000) (7:100000)
	// min alt        atmo   atmo   atmo    120k     240k      480k       600k
	print "T+" + round(missiontime) + " Waiting to crossing " + round(dist/1000) + "km of " + refbody:name.
	print "T+" + round(missiontime) + " Wait start: " + time:calendar + ", " + time:clock.
	local done to 0.
	local dist0 to refbody:position:mag.
	local dir to 0.
	if dist0 > dist {
	    set dir to -1.
	    when refbody:position:mag < dist then {
	        print "T+" + round(missiontime) + " Closer than " + round(dist/1000) + "km".
	        set done to 1.
	    }
	} else {
	    set dir to +1.
	    when refbody:position:mag > dist then {
	        print "T+" + round(missiontime) + " Farther than " + round(dist/1000) + "km".
	        set done to 1.
	    }
	}
	local wp to 0.
	local oldwp to 0.
	local oldwarp to warp.
	local dist0 to refbody:position:mag.
	local td0 to missiontime.
	until done {
	    set wp0 to warp.
	    set wf to 1.
	    if wp0 = 1 { set wf to 5. }
	    if wp0 = 2 { set wf to 10. }
	    if wp0 = 3 { set wf to 50. }
	    if wp0 = 4 { set wf to 100. }
	    if wp0 = 5 { set wf to 1000. }
	    if wp0 = 6 { set wf to 10000. }
	    if wp0 = 7 { set wf to 100000. }
	    if missiontime > td0 + wf/4 {
	        // calculate radial velocity
	        local dist1 to refbody:position:mag.
	        local td1 to missiontime.
	        local vr to (dist1 - dist0) / (td1 - td0).   // radial velocity, vr > 0 is out
	        local rt to (dist - dist1) / vr.             // remaining time to soi
	        // print "dr: " + round((dist1-dist0)/1000) + ", dt: " + round(td1-td0) + ", vr: " + round(vr) + ", rt: " + round(rt).
	        local wp to 0.
	        if rt > 5      { set wp to 1. }
	        if rt > 10     { set wp to 2. }
	        if rt > 50     { set wp to 3. }
	        if rt > 100    { set wp to 4. }
	        if rt > 1000   { set wp to 5. }
	        if rt > 10000  { set wp to 6. }
	        if rt > 100000 { set wp to 7. }
	        if wp0 <> wp {
	            set warp to wp.
	            wait 0.1.
	        }
	        set dist0 to refbody:position:mag.
	        set td0 to missiontime.
	    }
	    if wp <> oldwp or warp <> oldwarp {
	        local pctsoi to refbody:position:mag/dist.
	        set oldwp to wp.
	        set oldwarp to warp.
	        print "T+" + round(missiontime) + " Warp " + oldwarp + "/" + wp + ", at " + round(pctsoi*100) + "% soi, remaining: " + round(rt/60) + "min".
	    }
	    wait 0.1.
	}
	set warp to 0.
	// set dt to time:seconds - t0.
	print "T+" + round(missiontime) + " Wait end: " + time:calendar + ", " + time:clock.
}

// ----------------------------------------------------------------------------
// warpToInSOI(tgtbody)
// warps until in the SOI of tgtbody, re-runs i_bodyProperties when in SOI
function warpToInSOI {
	declare parameter tgtbody.
	// warp until leaving bodies' soi
	local soiflag to False.
	getSOI(tgtbody).
	when body:name = tgtbody:name then {
	    print "T+" + round(missiontime) + " Entered SOI of " + body:name.
	    set soiflag to True.
	}
	warpToDistance(tgtbody, gSOI).
	wait until soiflag.
	wait 1.
	run i_bodyProperties.
	wait 1.
}

// ----------------------------------------------------------------------------
// warpToOutSOI(tgtbody)
// warps until out of SOI of tgtbody
// ----------------------------------------------------------------------------
function warpToOutSOI {
	declare parameter refbody, tgtbody.
	// warp until leaving bodies' soi
	local soiflag to False.
	getSOI(refbody).
	when body:name = tgtbody:name then {
	    print "T+" + round(missiontime) + " Entered SOI of " + body:name.
	    set soiflag to True.
	}
	warpToDistance(refbody, gSOI).
	wait until soiflag.
	wait 1.
}