// ----------------------------------------------------------------------------
// mission script
// ----------------------------------------------------------------------------

clearscreen.
// ----------------------------------------------------------------------------
// includes
run i_bodyproperties.
run f_equipment.
run f_helper.
run f_launch.
run f_navigate.
run f_node.
run f_orbit.
run f_steering.
run f_warp.

// ----------------------------------------------------------------------------
// configuration variables
local initialOrbit to 80000.
local finalOrbit to 80000.
local orbitError to 1000.
local inclination to 0.0.
local antennaList to getAntennaList().
lock radarAltitude to alt:radar.

global offset to 0.
global timeout to 0.

// ----------------------------------------------------------------------------
// staging control
if status = "PRELAUNCH" 
{
	// staging
	printT("Configuring staging.").

	// stage 4
	when status <> "PRELAUNCH" and stage:solidfuel < 0.1 and stage:number = 4 then
	{
		set offset to stage:liquidfuel.
		printT(" Booster staging 4."). 
		stage.

		// stage 3
		if offset > 0
		{
			printT("Using offset: " + offset + " staging for stage 3.").
			when status <> "PRELAUNCH" and stage:liquidfuel < (0.1 + offset) and stage:number = 3 then
			{
				printT("Staging 3."). 
				stage.
			}
		} else {
			printT("Using normal staging for stage 3.").
			when status <> "PRELAUNCH" and stage:liquidfuel < 0.1 and stage:number = 3 then
			{
				printT("Staging 3."). 
				stage.
			}
		}
	}
	
	// stage 2
	when status <> "PRELAUNCH" and stage:liquidfuel < 0.1 and stage:number = 2 then
	{
		printT("Staging 2.").
		stage.
	}

	// deploy orbital items
	when radarAltitude > ha then
	{
		deployFairings().
	}

	when radarAltitude > ha + 1000 then 
	{
		// deploy a1l antennas
    	printT("Deploying antennas.").
    	checkAntennas(antennaList).

        // deploy solar panels
        printT("Deploying solar panels.").
        PANELS ON.
	}

	// execute launch script
	printT("Executing launch script.").
    launchToOrbitAtmo(initialOrbit, inclination).
}

printT("Raising orbit to 100k.").
set timeout to 30.
run x_corbit(finalOrbit, orbitError).

printT("Setting orbit mode.").
turnToSun().

set throttle to 0.
SAS on.

printT("Launch script complete.").
