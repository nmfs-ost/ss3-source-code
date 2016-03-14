#ifndef POPULATION_H
#define POPULATION_H

#include <QWidget>

//#include "area.h"
#include "parametermodel.h"
#include "ss_observation.h"
#include "composition.h"
#include "growth.h"
#include "ss_recruitment.h"
#include "ss_mortality.h"
#include "ss_movement.h"
#include "ss_fecundity.h"

class population : public QObject
{
    Q_OBJECT
public:
    population(QWidget *parent = 0);
    ~population ();

    void reset();

    tablemodel *meanBwtModel;


public slots:
    void setStartYear (int yr);
    void setTotalYears (int yrs);
    void setNumAges (int ages);
    void set_gender (int gender) {i_gender = gender;}
    int gender () {return i_gender;}
    void set_mean_bwt_df (int deg_free) {i_mean_bwt_deg_freedom = deg_free;}
    int mean_bwt_df () {return i_mean_bwt_deg_freedom;}
    void set_mean_body_wt_count (int count) {i_mean_bwt_count = count; meanBwtModel->setRowCount(count);}
    int mean_bwt_count () {return meanBwtModel->rowCount();}
    void setMeanBwt (int index, QStringList values) {meanBwtModel->setRowData(index, values);}
    QStringList getMeanBwt (int index) {return meanBwtModel->getRowData(index);}


    void readSeasonalEffects(ss_file *input);
    QString writeSeasonalEffects();

    float get_frac_female() const;
    void set_frac_female(float value);

    spawn_recruit *SR() {return pop_recruitment;}
    ss_movement *Move() {return pop_movement;}
    ss_fecundity *Fec() {return pop_fecundity;}
    ss_growth * Grow() {return pop_growth;}
    ss_mortality *M () {return pop_mortality;}

    int getFemwtlen1() const;
    void setFemwtlen1(int value);
    int getFemwtlen2() const;
    void setFemwtlen2(int value);
    int getMat1() const;
    void setMat1(int value);
    int getMat2() const;
    void setMat2(int value);
    int getFec1() const;
    void setFec1(int value);
    int getFec2() const;
    void setFec2(int value);
    int getMalewtlen1() const;
    void setMalewtlen1(int value);
    int getMalewtlen2() const;
    void setMalewtlen2(int value);
    int getL1() const;
    void setL1(int value);
    int getK() const;
    void setK(int value);
    void setNumSeasParams ();
    int getNumSeasParams () {return seasparamtable->rowCount();}
    void addSeasParam (QStringList data) {setSeasParam(seasparamtable->rowCount(), data);}
    void setSeasParam (int index, QStringList data);
    QStringList getSeasParam (int index);
    parametermodel *getSeasonalParams() {return seasparamtable;}

signals:

private:
    spawn_recruit *pop_recruitment;
    ss_movement *pop_movement;
    ss_fecundity *pop_fecundity;
    ss_growth *pop_growth;
    ss_mortality *pop_mortality;

    float f_frac_female;

    int i_gender;
    int i_mean_bwt_deg_freedom;
    int i_mean_bwt_count;

    int femwtlen1, femwtlen2, mat1, mat2, fec1, fec2;
    int malewtlen1, malewtlen2, L1, K;

    int iNumYears;
    int iStartYear;
    int iNumAges;

    parametermodel *seasparamtable;

};

#endif // POPULATION_H
