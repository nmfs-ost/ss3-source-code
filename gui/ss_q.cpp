#include "ss_q.h"

ss_Q::ss_Q(int n_fisheries, int n_surveys)
{
    num_fleets = 0;
    num_methods = 0;
    first_year = 0;
    num_years = 0;
}

ss_Q::~ss_Q()
{
    while (setup.count() > 0)
    {
        method_setup *m = setup.takeLast();
        delete m;
    }
    while (params.count() > 0)
    {
        shortParameter *p = params.takeLast();
        delete p;
    }
}
