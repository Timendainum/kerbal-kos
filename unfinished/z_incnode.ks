declare parameter tgtbody.
// create an inclination node
print "T+" + round(missiontime) + " Inclination maneuver, orbiting " + body:name.
// compensate for moon frame of reference
if body:name = "Kerbin" {
    set vtgt to tgtbody:velocity.
} else {
    set vtgt to -1 * tgtbody:body:velocity.
}
// calculate angular momentums
set pm to tgtbody:position-tgtbody:body:position.
set amm to vcrs(pm, vtgt).  
set ps to ship:position-body:position.
set ams0 to vcrs(ps, ship:velocity:orbit).
set ams1 to ams0:mag*amm:normalized.
// inclination between angular momentums
set inc to vang(ams0,ams1).
print "T+" + round(missiontime) + " Inclination " + round(inc,1) + "'".
if inc > 90 {
    print "T+" + round(missiontime) + " WARNING! Vessel and " + tgtbody:name + " orbit opposite sense.".
}
// calculate steering vector
set amp to vcrs(ams0,ams1):normalized.   // perpendicular to angular momentums; points to node
set amdelta to ams1 - ams0.
// set dir to vcrs(amdelta, amp):normalized.
// lock steering to R(0,0,0)*dir.
// calculate angle to maneuver and eta
set amp2ps to vang(amp, ps).             // angle between node and ship position
set side to vdot(amp,velocity:orbit).    // positive when orbiting towards node, negative away
if side > 0 {
    set aburn to amp2ps.
} else {
    set aburn to 360-amp2ps.
}
set smas to ps:mag.                       
set ops to 2*pi*sqrt(smas^3/mu).         // ship orbital period
set eta to aburn/360*ops.
print "T+" + round(missiontime) + " orbital angle to maneuver: " + round(aburn).
print "T+" + round(missiontime) + " orbit: " + round(ops) + "s, burn in " + round(eta) + "s".
// calculate maneuver deltav
set dv to amdelta:mag/ps:mag.            // math: dL = r x m dv, with r & dv perpendicular: dL/(r m) = dv, amdelta = dL/m
print "T+" + round(missiontime) + " Inclination burn deltav: " + round(dv) + "m/s".
set nd to node(time:seconds + eta, 0, -dv*cos(inc/2), -dv*sin(inc/2)).
add nd.
print "T+" + round(missiontime) + " Node created.".
