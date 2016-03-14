#ifndef LENGTH_OBSERVATION_H
#define LENGTH_OBSERVATION_H

#include <QList>
#include "ss_observation.h"

class length_observation
{
public:
    length_observation();

    void set_bin_method (int bin_m) {i_bin_method = bin_m;}
    int bin_method () {return i_bin_method;}
    void set_bin_width (int bin_w) {i_bin_width = bin_w;}
    int bin_width () {return i_bin_width;}
    void set_min_size (int min) {i_min_size = min;}
    int min_size () {return i_min_size;}
    void set_max_size (int max) {i_max_size = max;}
    int max_size () {return i_max_size;}
    void set_comp_tail (int c_tail) {i_comp_tail = c_tail;}
    int comp_tail () {return i_comp_tail;}
    void set_add_to_comp (double add_c) {d_add_comp = add_c;}
    double add_to_comp () {return d_add_comp;}
    void set_gender_method (int gen_m) {i_combine_genders = gen_m;}
    int gender_method () {return i_combine_genders;}
    void set_num_bins (int n_bins);
    void set_bin_value (int index, int value) {i_bins[index] = value;}
    int bin_value (int index) {return i_bins[index];}
    int num_bins () {return i_bins.count();}
    void set_num_observations (int n_obs);
//    void set_observation (int index, int year, int season, int fleet, int gen, int part, int n_samp);
//    void set_observation_data (int index, int bin_no, int value);
    int num_observations () {return obs_data.count();}
    ssObservation *observ (int index);
    void add_observation (QString txt);

private:
    tablemodel *observations;
    QStringList observationHeader;
};

#endif // LENGTH_OBSERVATION_H
