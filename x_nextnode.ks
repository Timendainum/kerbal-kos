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
run f_navigate.
run f_warp.

local nd to nextnode.
executeNode(nd).	