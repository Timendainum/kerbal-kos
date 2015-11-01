clearscreen.

// sets up some standard variables
run z_bodyprops.

// staging control
if status = "PRELAUNCH" 
{

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

    run z_ltoa.
}

