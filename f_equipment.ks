// ----------------------------------------------------------------------------
// f_equipment
// equipment related functions
// requires:
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

// ----------------------------------------------------------------------------
// deployFairings()
// Iterates over a list of all parts with the stock fairings module Stock and 
// KW Fairings and deploys them
// ----------------------------------------------------------------------------
function deployFairings {
	FOR module IN SHIP:MODULESNAMED("ModuleProceduralFairing") { 
	    module:DOEVENT("deploy").
	}.
}
