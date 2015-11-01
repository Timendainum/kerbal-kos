// output warning if running script on incorrect ship

declare parameter name.
if ship:vesselname <> name { 
    print "WARNING! This script maybe incompatible.".
    print "Designed to work with '" + name + "'".
    print "         Current ship '" + ship:vesselname + "'".
    print "Press Ctrl-C within 5s to abort".
    print "-------------------------------------------------".
    wait 5.
}
