#include "error_vector.h"

error_vector::error_vector(int n)
{
    i_size = 0;
    set_size(n);
}

void error_vector::set_size (int n)
{
    i_size = n;
    means.clear();
    std_devs.clear();

    for (int i = 0; i < i_size; i++)
    {
        means.append (0.0);
        std_devs.append (0.0);
    }
}

