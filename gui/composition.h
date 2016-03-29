#ifndef COMPOSITION_H
#define COMPOSITION_H

//#include "ss_observation.h"
#include "error_vector.h"
#include "tablemodel.h"
#include "parametermodel.h"

/** This is a set of data about a certain
 * aspect of a fish population. There are separate objects for age,
 * length, and a generalized size composition.
 * It includes a description of the data bins and observations.
 */

class composition : public QObject
{
public:
    composition(QObject *parent = 0);
    ~composition();
    void reset ();

    tablemodel *getBinsModel() {return binsModel;}

    void setNumber (int num) {i_method = num;}
    int getNumber () {return i_method;}
    void setNumberBins (int num) {binsModel->setColumnCount(num);}
    int getNumberBins () {return binsModel->columnCount();}
    void setBin (int index, QString data) {binsModel->setRowData(index, data);}
    void setBin (int index, float value) {binsModel->setRowData (index, QString::number(value));}
    void setBins (QStringList data) {binsModel->setRowData(0, data);}
    float getBin (int index) {return binsModel->getRowData(0).at(index).toFloat();}
    QStringList getBins () {return binsModel->getRowData(0);}

    tablemodel *getAltBinsModel() {return altBinsModel;}

    void setAltBinMethod (int method);
    int getAltBinMethod () {return i_method;}
    void setAltBinWidth (int width) {i_bin_width = width;}
    int getAltBinWidth () {return i_bin_width;}
    void setAltBinMin (int min) {i_bin_min = min;}
    int getAltBinMin () {return i_bin_min;}
    void setAltBinMax (int max) {i_bin_max = max;}
    int getAltBinMax () {return i_bin_max;}
    int generateAltBins ();

    void setNumberAltBins (int num) {altBinsModel->setColumnCount(num);}
    int getNumberAltBins () {return altBinsModel->columnCount();}
    void setAltBins (QStringList data) {altBinsModel->setRowData(0, data);}
    float getAltBin (int index) {return altBinsModel->getRowData(0).at(index).toFloat();}
    QStringList getAltBins () {return altBinsModel->getRowData(0);}

    void setNumberObs (int obs) {i_num_obs = obs;}
    int getNumberObs () {return i_num_obs;}

protected:
    tablemodel *binsModel;
    tablemodel *altBinsModel;

    int i_method;
    int i_bin_width;
    int i_bin_min;
    int i_bin_max;

    int i_num_obs;
};

/** The length composition extends the basic one by adding two
 * float variables: compress_tails and add_to_compression. */
class compositionLength : public composition
{
public:
    compositionLength (QObject *parent = 0);

    void setNumberBins(int num);

};

/** The age composition adds size-at-age observations and an error vector. */
class compositionAge : public composition
{
public:
    compositionAge (QObject *parent = 0);
    ~compositionAge ();

    void reset();

    tablemodel *getErrorModel() {return errorModel;}
    tablemodel *getSaaModel() {return saaModel;}

    void setNumberBins (int num);
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

    void setErrorParam (int index, QStringList data) {errorParam->setRowData(index, data);}
    QStringList getErrorParam (int index) {return errorParam->getRowData(index);}
    parametermodel *getErrorParameters() {return errorParam;}

private:
    tablemodel *errorModel;
    tablemodel *saaModel;

    int i_num_error_defs;
    QList<error_vector *> error_defs;

    int i_num_saa_obs;
    QList<ssObservation *> o_saa_obs_list;

    bool useParameters;
    parametermodel *errorParam;

};

class compositionMorph : public composition
{
public:
    compositionMorph (QObject *parent = 0);
    ~compositionMorph () {}

    void setNumberMorphs (int num);
    int getNumberMorphs () {return getNumberBins();}

};

class compositionGeneral : public composition
{
public:
    compositionGeneral (QObject * parent = 0);
    ~compositionGeneral ();

    void reset();

    void setNumberBins(int num);
    void setUnits(int units) {i_units = units;}
    int getUnits () {return i_units;}
    void setScale (int scale) {i_scale = scale;}
    int getScale () {return i_scale;}

private:
    int i_scale;
    int i_units;
};

#endif // COMPOSITION_H
