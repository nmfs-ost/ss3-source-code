#include "length_observation.h"

length_observation::length_observation()
{
    observations = new tablemodel();
}

void length_observation::set_num_bins (int n_bins)
{
    i_num_bins = n_bins;
    for (int i = 0; i < i_num_bins; i++)
    {
        i_bins.append(0);
    }
}


void length_observation::set_num_observations (int n_obs)
{
    for (int i = 0; i < n_obs; i++)
    {
        ssObservation *obs = new ssObservation(i_num_bins);
        obs_data.append(obs);
    }
}


void length_observation::add_observation(QString txt)
{
    obs_data.append(txt);
}

ssObservation* length_observation::observ(int index)
{
    return obs_data.at(index);
}
