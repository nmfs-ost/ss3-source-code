#ifndef OBSERVATION_H
#define OBSERVATION_H

#include <QList>
#include <QString>

/**  This is a generalized holder of observational data. It includes vectors
 * for variable length data for both genders as well as sample sizes.
 * The data is indexed by year, season, and fleet.
  */

class observation
{
public:
    observation(int size = 0);

    void set_fixed_catch_text (QString line);
    QString fixed_catch_text ();

    /** the metadata */
    void set_size (int size);
    int size () {return fm_data.count();}
    void set_year (int year) {i_year = year;}
    int year () {return i_year;}
    void set_season (int season) {i_season = season;}
    int season () {return i_season;}
    void set_fleet (int fleet) {i_fleet = fleet;}
    int fleet () {return i_fleet;}
    void set_gender (int gender) {i_gender = gender;}
    int gender () {return i_gender;}
    void set_partition (int part) {i_partition = part;}
    int partition () {return i_partition;}
    void set_n_sample (int num_samp) {i_num_samples = num_samp;}
    int num_sample () {return i_num_samples;}
    void set_low_bin_low (int val) {i_low_bin_min = val;}
    int low_bin_low () {return i_low_bin_min;}
    void set_low_bin_hi (int val) {i_low_bin_max = val;}
    int low_bin_hi () {return i_low_bin_max;}
    void set_ageerr (int err_type) {i_age_err = err_type;}
    int ageerr () {return i_age_err;}

    /** the female data vector */
    void add_female_data_value (float val) {fm_data.append(val);}
    void set_female_data_value (int index, float val) {fm_data[index] = val;}
    int female_data_count () {return fm_data.count();}
    float female_data_value (int index) {return fm_data[index];}
    void add_female_sample_size (int val) {fm_sample_size.append(val);}
    void set_female_sample_size (int index, int val) {fm_sample_size[index] = val;}
    int female_sample_count () {return fm_sample_size.count();}
    int female_sample_size (int index) {return fm_sample_size[index];}

    /** the male data vector */
    void add_male_data_value (float val) {ml_data.append (val);}
    void set_male_data_value (int index, float val) {ml_data[index] = val;}
    int male_data_count () {return ml_data.count();}
    float male_data_value (int index) {return ml_data[index];}
    void add_male_sample_size (int val) {ml_sample_size.append(val);}
    void set_male_sample_size (int index, int val) {ml_sample_size[index] = val;}
    int male_sample_count () {return ml_sample_size.count();}
    int male_sample_size (int index) {return ml_sample_size[index];}

    /** Convenience functions */
    void add_data (float val) {add_female_data_value(val);}
    void set_data (float val) {set_female_data_value(0, val);}
    void set_data (int index, float val) {set_female_data_value(index, val);}
    int data_count () {return female_data_count();}
    float data(int index = 0) {return female_data_value(index);}
    void add_error (float err) {add_male_data_value(err);}
    void set_error (float err) {set_male_data_value(0, err);}
    void set_error (int index, float err) {set_male_data_value(index, err);}
    int error_count () {return male_data_count();}
    float error (int index = 0) {return male_data_value(index);}
    void set_ignore (int val) {set_n_sample(val);}
    int ignore () {return num_sample();}
    void set_var_number (int num) {set_fleet(num);}
    int var_number () {return fleet();}

private:
    int i_year;
    int i_season;
    int i_fleet;
    int i_gender;
    int i_partition;
    int i_num_samples;
    int i_low_bin_min;
    int i_low_bin_max;
    int i_age_err;

    QList<float> fm_data;
    QList<int> fm_sample_size;
    QList<float> ml_data;
    QList<int> ml_sample_size;

};

#endif // OBSERVATION_H
