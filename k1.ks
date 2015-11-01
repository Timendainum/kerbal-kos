// ----------------------------------------------------------------------------
// mission script
// ----------------------------------------------------------------------------
// includes
run i_bodyProperties.
run f_equipment.
run f_info.
run f_orbit.
run f_steering.
run f_warp.
// ----------------------------------------------------------------------------
clearscreen.


// ----------------------------------------------------------------------------
// configuration variables
set finalOrb to 100000.

// ----------------------------------------------------------------------------
// staging control
if status = "PRELAUNCH" 
{

	// staging
	when status <> "PRELAUNCH" and stage:solidfuel < 0.1 and stage:number = 3 then
	{
		print "T+" + round(missiontime) + " Booster staging 3.". 
		stage.
	}
	
	when status <> "PRELAUNCH" and stage:liquidfuel < 0.1 and stage:number = 2 then
	{
		print "T+" + round(missiontime) + " Staging 2.". 
		stage.
	}

	when status <> "PRELAUNCH" and stage:liquidfuel < 0.1 and stage:number = 1 then
	{
		print "T+" + round(missiontime) + " Staging 1.". 
		stage.
	}

	// deploy orbital items
	when alt:radar > ha then {
		deployFairings().
	}

	when alt:radar > ha + 1000 then {
		// deploy a1 antennas
    	print "Deploying orbital antenna.".
    	SET antennaList to SHIP:PARTSDUBBED("a1").
        FOR antenna IN antennaList {
            
            //Opens each antenna
            antenna:GETMODULE("ModuleRTAntenna"):DOACTION("Activate", TRUE).
            
        }.

        // deploy solar panels
        print "Deploying solar panels.".
        PANELS ON.
	}

	// execute launch script
    run z_ltoa(finalOrb).
}

turnToSun().

print "Mission script complete.".