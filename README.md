# kerbal-kos
KOS Scripts for Kerbal

A set of misson scripts for Kerbal.
The idea is to expand and complete the start by Baloan and build a modular mission building kit.

Naming convention:

	f_ :   function: files that define functions
	i_ :    include: files to be included, usually sets up variables
	x_ : executable: files that can be executed directly

function files:

	f_equipment						: equipment related functions
	f_helper						: helper functions
	f_launch						: launch related functions
	f_navigate						: navigation helper functions
	f_node							: node management functions
	f_orbit							: orbital manouver functions
	f_steering						: steering related functions
	f_warp							: warping functions

include files:	
	i_bodyproperties				: sets up values for astronomical bodies

executable files:
	x_corbit(orbitAltitude, error)	: transfers craft into orbit specified
	x_dokp							: deorbit into Kerbin with parachutes
									  attempts to land near KSC
									  needs parameter of stageNumber
	x_nextnode						: executes the next node

	l								: example launch script


Source material and inspiration:
https://gist.github.com/KK4TEE/
The Misson Toolkit v3 by Baloan. http://kos.wikia.com/wiki/Mission_toolkit_v3
reddit.com/r/kos/
