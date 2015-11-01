// ----------------------------------------------------------------------------
// i_bodyProperties
// set celestial body properties
// requires:
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

global euler to 2.718281828.
global pi to 3.1415926535.
global b to body:name.
global mu to 0.     // gravitational parameter, mu = G mass
global rb to 0.     // radius of body [m]
global bsoi to 0.   // sphere of influence [m]
global ad0 to 0.    // atmospheric density at msl [kg/m^3]
global sh to 0.     // scale height (atmosphere) [m]
global ha to 0.     // atmospheric height [m]
global lorb to 0.   // low orbit altitude [m]
global gt0 to 0.    // grafity turn start
global gt1 to 0.    // gravity furn end
global maxq to 0.   // max dynamic pressure q
global soi to 0.    // radius of body sphere of influence

if b = "Kerbin" {
    set mu to 3.5316000*10^12.
    set rb to 600000.
    set soi to 84159286.
    set ad0 to 1.2230948554874.
    set sh to 5000.
    set ha to 69077.
    set lorb to 70000.
	
	// trajectory parameters
    set gt0 to 10000.
    set gt1 to 50000.
    set maxq to 7000.
}

if b = "Mun" {
    set mu to 6.5138398*10^10.
    set rb to 200000.
    set soi to 2429559.
    set ad0 to 0.
    set lorb to 14000. 
}

if b = "Minmus" {
    set mu to 1.7658000*10^9.
    set rb to 60000.
    set soi to 2247428.
    set ad0 to 0.
    set lorb to 10000. 
}

if mu = 0 {
    print "T+" + round(missiontime) + " WARNING: no body properties for " + b + "!".
}

if mu > 0 {
    print "T+" + round(missiontime) + " Loaded body properties for " + b.
}

// fix NaN and Infinity push on stack errors, https://github.com/KSP-KOS/KOS/issues/152
set config:safe to False.
