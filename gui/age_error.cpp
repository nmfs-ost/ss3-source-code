#include "age_error.h"

age_error::age_error(int n)
{
    set_size(n);
}

void age_error::set_size (int n)
{
    means.clear();
    std_devs.clear();

    for (int i = 0; i < n; i++)
    {
        means.append (0.0);
        std_devs.append (0.0);
    }
}

