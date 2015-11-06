// ----------------------------------------------------------------------------
// x_dokp
// Deorbit to Kerbin with Parachutes
// ----------------------------------------------------------------------------
declare parameter doStage. 	// this is to auto deploy a service module boolean


global timeout to 30.

// ----------------------------------------------------------------------------
// includes
// ----------------------------------------------------------------------------
run i_bodyproperties.
run f_equipment.
run f_helper.

// ----------------------------------------------------------------------------
// main
// ----------------------------------------------------------------------------

clearscreen.
printT("Execute DeOrbit to Kerbin with Parachutes.").

execute().

printT("Executing DeOrbit to Kerbin with Parachutes has ended.").

// ----------------------------------------------------------------------------
// execute function
// ----------------------------------------------------------------------------
local function execute {
	
	// ------------------------------------------------------------------------
	// declare vars
	local s to ship.
	local lock o to s:obt.
	local lock sLatLong to s:geoposition.
	local lock tHeight to sLatLong:terrainheight.
	local lock alt to max(0.1, altitude - tHeight).
	local deorbitBurnLNG to -169.5.
	local chuteList to getChutes().
	local antennaList to getAntennaList().
	lock impactTime to alt / -VERTICALSPEED.

	// ------------------------------------------------------------------------
	// safety checks
	if abs(o:eccentricity) > 2 {
		printT("Eccentricity to high to deorbit.").
		return.
	}

	// ------------------------------------------------------------------------
	// circuilarize to lorb
	run x_corbit(lorb + 1000, 500).


	// pre deorbit settings
	local runmode to 10.
	local t to 0.
	local lock throttle to t.
	lock steering to retrograde.
	sas off.
	rcs off.
	clearscreen.

	// ------------------------------------------------------------------------
	// run loop
	until runmode = 0 {

		// runmode 10 - wait for burn
		if runmode = 10 {
			set t to 0.
			if (s:altitude > lorb) and (sLatLong:LNG < deorbitBurnLNG - 10 or sLatLong:LNG > deorbitBurnLNG + 1) {
            	if WARP = 0 {        // If we are not time warping
                	wait 1.         //Wait to make sure the ship is stable
                	SET WARP TO 3. //Be really careful about warping
                }
            } else {
				SET WARP to 0.
				set runmode to 20.
            }
		}

		// runmode 20 - deorbit burn
		if runmode = 20 
		{
			if sLatLong:LNG > deorbitBurnLNG and sLatLong:LNG < deorbitBurnLNG + 2 
			{
				set t to 0.5. 
			}
			if PERIAPSIS < 0 
			{
				//Burn until the periapsis is below 0
				set t to 0.
				wait 1.
				if doStage = true 
				{
					stage.		//jettison service module
					wait 5.		// and wait for it to clear.
				}
				panels off.
				set runmode to 30.
			}
		}

		// runmode 30 - coast into atmo
		if runmode = 30 {
			set t to 0.
			lock STEERING to velocity:surface * -1.	//Point retrograde relative to surface velocity
			deployChutesIfReady(chuteList).
			checkAntennas(antennaList).
		}

		local finalT to t.
	    lock throttle to finalT.	//Write our planned throttle to the physical throttle 

	    //Print data to screen.
	    print "     RUNMODE: " + runmode + "  " at (0,27).
	    print "    ALTITUDE: " + round(SHIP:ALTITUDE) + "    " at (0,28).
	    print "    APOAPSIS: " + round(SHIP:APOAPSIS) + "    " at (0,29).
	    print "   PERIAPSIS: " + round(SHIP:PERIAPSIS) + "    " at (0,30).
	    print "   ETA to AP: " + round(ETA:APOAPSIS) + "    " at (0,31).
	    print "   ETA to Pe: " + round(ETA:PERIAPSIS) + "    " at (0,32).
	    print " Impact Time: " + round(impacttime,1) + "    " at (0,33).
	    print "         LAT: " + round(sLatLong:LAT,3) + "    " at (0,34).
    	print "         LNG: " + round(sLatLong:LNG,3) + "    " at (0,35).
	}

}