// Iterates over a list of all parts with the stock fairings module
FOR module IN SHIP:MODULESNAMED("ModuleProceduralFairing") { // Stock and KW Fairings
    // and deploys them
    module:DOEVENT("deploy").
}.