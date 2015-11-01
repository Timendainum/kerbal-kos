// ----------------------------------------------------------------------------
// mission script
// ----------------------------------------------------------------------------
// includes
run i_bodyproperties.
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

	local radarAltitude to 0.
	lock radarAltitude to alt:radar.

	// deploy orbital items
	when radarAltitude > ha then {
		deployFairings().
	}

	when radarAltitude > ha + 1000 then {
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
    run x_ltoa(finalOrb, 0).
}

turnToSun().

set throttle to 0.

SAS on.

print "Mission script complete.".