// ----------------------------------------------------------------------------
// x_nextnode
// executes the next node
// requires:
//      f_navigate
//      f_warp
// ----------------------------------------------------------------------------
@LAZYGLOBAL OFF.
// ----------------------------------------------------------------------------
// arguments

// ----------------------------------------------------------------------------
// includes
run f_helper.
run f_navigate.
run f_node.
run f_orbit.
run f_warp.

local nd to nextnode.
executeNode(nd).	
