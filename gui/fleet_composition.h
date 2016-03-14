#ifndef FLEET_COMPOSITION_H
#define FLEET_COMPOSITION_H

#include "ss_observation.h"
#include "tablemodel.h"

/** This is a set of data about a certain
 * aspect of a fish population which are fleet specific.
 * There are separate classes for age,
 * length, morphology (stock), and a generalized size composition.
 *
 */

class fleet_composition : public QObject
{
public:
    fleet_composition(QObject *parent = 0);
    ~fleet_composition();

    void setNumber (int num) {i_method = num;}
    int getNumber () {return i_method;}

    void setMinTailComp (float min_c) {f_mincomp = min_c;}
    float getMinTailComp () {return f_mincomp;}
    void setAddToData (float add) {f_addtocomp = add;}
    float getAddToData () {return f_addtocomp;}
    void setCombineGenders(int bin) {i_bin_combine = bin;}
    int getCombineGenders () {return i_bin_combine;}
    void setCompressBins (int val) {i_compress_bins = val;}
    int getCompressBins () {return i_compress_bins;}
    void setErrorType (int val) {i_error = val;}
    int getErrorType () {return i_error;}
    void setErrorParam (int val) {i_err_param = val;}
    int getErrorParam () {return i_err_param;}

    void setNumberBins (int num, int gen);
    int getObsLength() {return obsModel->columnCount();}
    void setNumberObs (int num) {obsModel->setRowCount(num);}//{i_num_obs = num;}
    int getNumberObs () {return obsModel->rowCount();}
    void addObservation (QStringList data) {setObservation(getNumberObs(), data);}
    void setObservation (int index, QStringList data);
    QStringList getObservation (int index) {return obsModel->getRowData(index);}//o_obs_list.at(index);}
    tablemodel *getObsTable () {return obsModel;}

protected:
    int i_method;

    float f_mincomp;   // compress tails of composition until obs prop is > than this
    float f_addtocomp; // constant added to obs and expected prop

    int i_bin_combine; // combine males and females at this bin and lower
    int i_compress_bins; // accumulate upper tail by this number of bins
    int i_error;       //  0=multinomial, 1=dirichlet
    int i_err_param;   // parm number if error = 1

    tablemodel *obsModel;
    QStringList obsHeader;

};

/** The length composition extends the basic one by adding two
 * float variables: compress_tails and add_to_compression. */
class fleet_comp_length : public fleet_composition
{
public:
    fleet_comp_length (QObject *parent = 0);

    void setNumberBins(int num, int gen);

};

/** The age composition adds size-at-age observations and an error vector. */
class fleet_comp_age : public fleet_composition
{
public:
    fleet_comp_age (QObject *parent = 0);
    ~fleet_comp_age ();

    tablemodel *getErrorModel() {return errorModel;}
    tablemodel *getSaaModel() {return saaModel;}

    void setNumberBins (int num, int gen);
    void set_number_ages (int num);
    void set_num_error_defs (int num);
    int number_error_defs () {return i_num_error_defs;}
    void set_error_def_ages (int index, QStringList ages);
    void set_error_def (int index, QStringList errs);
    QStringList get_error_ages (int index);
    QStringList get_error_def(int index);

    bool getUseParameters ();
//    void add_error_def (error_vector *ev) {error_defs.append (ev);}
//    error_vector * error_def (int index) {return error_defs.at(index);}

    void set_number_saa_observations (int num) {i_num_saa_obs = num;}
    int number_saa_observations () {return o_saa_obs_list.count();}
    void add_saa_observation (class ssObservation *obs) {o_saa_obs_list.append (obs);}
    ssObservation * saa_observation (int index) {return o_saa_obs_list.at(index);}

private:
    tablemodel *errorModel;
    tablemodel *saaModel;

    int i_num_error_defs;
//    QList<error_vector *> error_defs;

    int i_num_saa_obs;
    QList<ssObservation *> o_saa_obs_list;

    bool useParameters;

};

class fleet_comp_morph : public fleet_composition
{
public:
    fleet_comp_morph (QObject *parent = 0);

    void setNumberMorphs (int num);

};

class fleet_comp_general : public fleet_composition
{
public:
    fleet_comp_general (QObject * parent = 0);

    void setNumberBins(int num, int gen);
};

#endif // FLEET_COMPOSITION_H
