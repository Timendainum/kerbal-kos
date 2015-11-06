// ----------------------------------------------------------------------------
// f_equipment
// equipment related functions
// requires:
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.

// ----------------------------------------------------------------------------
// globals
// ----------------------------------------------------------------------------
global antennasOpen to false.

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

//=====Chutes Util=====
//by space_is_hard

function getChutes {
	//List that we'll store all of the parachute parts in
	local chuteList TO LIST().

	//Gets all of the parts on the craft
	local partList to SHIP:PARTS.

	//Goes over the part list we just made
	FOR item IN partList {
	    
	    //Gets all of the modules of the part we're going over; local variable that gets
	    //dumped every time the FOR loop is finished
	    LOCAL moduleList TO item:MODULES.
	    
	    //Goes over moduleList to find the parachute module
	    FOR module IN moduleList {
	    
	        //Checks the name of the module, and stores the part being gone over if the
	        //parachute module shows up
	        IF module = "ModuleParachute" {
	        
	            //Stores the part in the chuteList
	            chuteList:ADD(item).
	            
	        }.
	        
	    }.
	    
	}.

	return chuteList.
}

FUNCTION deployChutesIfReady {
    declare parameter chuteList.

    //Determines whether we're in atmosphere, and below 10km, and descending
    IF SHIP:ALTITUDE < BODY:ATM:HEIGHT 
        AND SHIP:ALTITUDE < 10000
        AND SHIP:VERTICALSPEED < -1 {
        
        //Goes over the chute list
        FOR chute IN chuteList {
            
            //Checks to see if the chute is already deployed
            IF chute:GETMODULE("ModuleParachute"):HASEVENT("Deploy Chute") {
                
                //Checks to see if the chute is safe to deploy
                IF chute:GETMODULE("ModuleParachute"):GETFIELD("Safe To Deploy?") = "Safe" {
                    
                    //Deploy/arm this chute that has shown up as safe and ready
                    //to deploy
                    chute:GETMODULE("ModuleParachute"):DOACTION("Deploy", TRUE).
                    
                    //Inform the user that we did so
                    hudtext("Chute Utility: Safe to deploy; Arming parachute", 3, 2, 30, YELLOW, FALSE).
                    
                }.
            
            }.
            
        }.
        
    }.
    
}.



//=====RT Antenna Util=====
//by space_is_hard

function getAntennaList 
{
	local antennaList TO LIST().

	//Goes over all of the modules on the entire ship, and lists the ones named
	//"ModuleRTAntenna" in a list called "RTmodule". This should produce a list of all of the
	//RemoteTech antenna modules
	FOR RTmodule IN SHIP:MODULESNAMED("ModuleRTAntenna") 
	{
	    //Checks to see if the part that the antenna module is attached to *also* contains
	    //an animation module
	    IF RTmodule:PART:MODULES:CONTAINS("ModuleAnimateGeneric") 
	    {
	        //If so, it adds that part to the antenna list
	        antennaList:ADD(RTmodule:PART).
	    }.
	}.
	return antennaList.
}

FUNCTION checkAntennas 
{    //TODO: Implement same landed check as panel util
	parameter antennaList.
    
    //Only performs the checks within if the antennas aren't already open
    IF NOT antennasOpen {
        
        //Checks if we're out of the atmosphere
        IF SHIP:ALTITUDE > BODY:ATM:HEIGHT {
            
            //Goes over our previously-built antenna list
            FOR antenna IN antennaList {
                
                //Opens each antenna
                antenna:GETMODULE("ModuleRTAntenna"):DOACTION("Activate", TRUE).
                
            }.
            
            //Changes the variable so we can track the status of the panels
            SET antennasOpen TO TRUE.
            
            //Informs the user that we're taking action
            HUDTEXT("RT Antenna Utility: Leaving Atmosphere; Opening Antennas", 3, 2, 30, YELLOW, FALSE).
        }.
        
        //Checks if we're landed and stationary
        IF SHIP:STATUS = "Landed" AND SHIP:VELOCITY:SURFACE:MAG < 0.1 {
            
            //Goes over our previously-built antenna list
            FOR antenna IN antennaList {
                
                //Opens each antenna
                antenna:GETMODULE("ModuleRTAntenna"):DOACTION("Activate", TRUE).
                
            }.
            
            //Changes the variable so we can track the status
            SET antennasOpen TO TRUE.
            
            //Informs the user that we're taking action
            HUDTEXT("RT Antenna Utility: Landed and Stationary; Opening Antennas", 3, 2, 30, YELLOW, FALSE).
            
        }.
        
    //Only performs the checks within if the antennas are already open
    } ELSE IF antennasOpen {
        
        //Checks to see if we're in the atmosphere; doesn't close the antennas if we're
        //stationary to prevent it and the stationary check from fighting for control of
        //the antennas.
        IF SHIP:ALTITUDE < BODY:ATM:HEIGHT 
            AND SHIP:VELOCITY:SURFACE:MAG >= 0.1 {
            
            //Goes over our previously-built antenna list
            FOR antenna IN antennaList {
                
                //Closes the antenna
                antenna:GETMODULE("ModuleRTAntenna"):DOACTION("Deactivate", TRUE).
                
            }.
            
            //Changes the variable so we can track the status of the antennas
            SET antennasOpen TO FALSE.
            
            //Informs the user why we're taking action based on which situation we're in
            IF SHIP:STATUS = "Landed" {
                
                //If we're landed, we're probably starting to move from a standstill
                HUDTEXT("RT Antenna Utility: Landed and moving; Closing Antennas", 3, 2, 30, YELLOW, FALSE).
                
            } ELSE {
                
                //If we're not landed, we're probably re-entering
                HUDTEXT("RT Antenna Utility: Entering Atmosphere; Closing Antennas", 3, 2, 30, YELLOW, FALSE).
                PRINT "Closing Antennas".
                
            }.
            
        }.
    
    }.
    
}.