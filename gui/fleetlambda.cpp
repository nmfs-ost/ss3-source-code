#include "fleetlambda.h"


fleetLambda::fleetLambda()
{
    component = 0;
    phase = 1;
    lambda = 1.0;
    sizeFreq = 1;
}

fleetLambda::fleetLambda (int cmp, int phs, float lmb, int szfq)
{
    component = cmp;
    phase = phs;
    lambda = lmb;
    sizeFreq = szfq;
}

fleetLambda & fleetLambda::operator = (fleetLambda rhs)
{
    component = rhs.getComponent();
    phase = rhs.getPhase();
    lambda = rhs.getLambda();
    sizeFreq = rhs.getSizeFreq();

    return *this;
}

bool fleetLambda::operator == (fleetLambda rhs) const
{
    bool equal = false;
    if (rhs.getComponent() == component &&
            rhs.getPhase() == phase &&
            rhs.getLambda() == lambda &&
            rhs.getSizeFreq() == sizeFreq)
        equal = true;
    return equal;
}
