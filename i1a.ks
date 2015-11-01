// mission script for I1a Ionization Detection Mission
clearscreen.

// sets up some standard variables
run z_bodyprops.

// configuration variables
set finalOrb to 100000.

// staging control
if status = "PRELAUNCH" 
{

	// staging
	when status <> "PRELAUNCH" and stage:solidfuel < 0.1 and stage:number = 4 then
	{
		print "T+" + round(missiontime) + " Booster staging 4.". 
		stage.
	}

	when status <> "PRELAUNCH" and stage:solidfuel < 0.1 and stage:number = 3 then
	{
		print "T+" + round(missiontime) + " Booster staging 3.". 
		stage.
	}
	
	when status <> "PRELAUNCH" and stage:liquidfuel < 360.1 and stage:number = 2 then
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
    	print "Exiting atmosphere...".

    	print "Ejecting fairing...".
		run z_deployfairings.

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
    run z_ltoa.
}

// transfer to higher orbit
print "Transfer to " + finalOrb + " orbit...".
run z_aponode(finalOrb).
run z_exenode.
run z_aponode(finalOrb).
run z_exenode.

print "Mission script complete.".