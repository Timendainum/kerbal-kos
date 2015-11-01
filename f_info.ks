// ----------------------------------------------------------------------------
// f_info
// infomation gathering functions
// requires:
// 		i_bodyProperties
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

// ----------------------------------------------------------------------------
// getSOI 
// sets a variable called "soi" to the distance from the body that it's SOI is
// ----------------------------------------------------------------------------
function getSOI {
	declare parameter bd.
	// parameter type: body
	local sma to (bd:apoapsis + 2*bd:body:radius + bd:periapsis)/2.
	global gSOI to sma*(bd:mu/bd:body:mu)^0.4.
	print "T+" + round(missiontime) + " SOI for " + bd:name + ": " + round(soi/1000) + "km".
}
