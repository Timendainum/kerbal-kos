// ----------------------------------------------------------------------------
// mission script
// ----------------------------------------------------------------------------
// includes
run i_bodyproperties.
run f_equipment.
run f_info.
run f_launch.
run f_navigate.
run f_orbit.
run f_steering.
run f_warp.
// ----------------------------------------------------------------------------
clearscreen.


// ----------------------------------------------------------------------------
// configuration variables
set finalOrb to 75000.

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
    	print "T+" + round(missiontime) + "Deploying orbital antenna.".
    	SET antennaList to SHIP:PARTSDUBBED("a1").
        FOR antenna IN antennaList {
            
            //Opens each antenna
            antenna:GETMODULE("ModuleRTAntenna"):DOACTION("Activate", TRUE).
            
        }.

        // deploy solar panels
        print "T+" + round(missiontime) + "Deploying solar panels.".
        PANELS ON.
	}

	// execute launch script
    launchToOrbitAtmo(finalOrb, 0).
}

print "T+" + round(missiontime) + "Raising orbit to 100k.".
run x_corbit(100000, 500).

print "T+" + round(missiontime) + "Setting orbit mode.".
turnToSun().

set throttle to 0.
SAS on.

print "Mission script complete.".