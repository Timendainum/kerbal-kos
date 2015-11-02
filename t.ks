// ----------------------------------------------------------------------------
// mission script
// ----------------------------------------------------------------------------
// includes
run i_bodyproperties.
run f_navigate.
run f_orbit.

// ----------------------------------------------------------------------------
clearscreen.
setInclination(25.0).


//local sma to ship:obt:semimajoraxis.
//local alt to ship:altitude + rb.

//print "alt: " + alt.
//print "sma: " + sma.

//print getVelocityByRA(alt, sma).