#ifndef POPULATION_WIDGET_H
#define POPULATION_WIDGET_H

#include <QWidget>

#include "model.h"
#include "ss_mortality.h"
#include "ss_recruitment.h"
#include "growth.h"
#include "ss_fecundity.h"


namespace Ui {
class population_widget;
}

class population_widget : public QWidget
{
    Q_OBJECT

public:
    explicit population_widget(ss_model * m_data, QWidget *parent = 0);
    ~population_widget();

public slots:
    void set_model (ss_model *model);
    void reset();
    void refresh();

    void changeGrowthPattern(int num);

    int getFecundityOption ();
    void setFecundityOption (int opt);
    int getFecundityOffsetOption ();
    void setFecundityOffsetOption(int opt);
    int getFecundityAdjustment ();
    void setFecundityAdjustment(int opt);

    void setMaturityOpt(int opt);
    int getMaturityOpt();

    void changeMortOption (int opt);
    void changeNumGrowthPat(int num);
    void changeNumSubMorph(int num);
    void setGrowthModel(int opt);
    void changeGrowthModel(int opt);
    int getGrowthModel();

    void setSpawnRecrSpec (int spec);
    void setRecrArea (int value);
    void changeRecrArea ();
    int getRecrArea ();
    void setRecrDistParam (int method);
    void changeRecrDistParam (int method);
    int getRecrDistParam ();

    void changeFMortMethod (int opt);
    void changeFMortBpark ();
    void changeFMortBparkYr (int yr);
    void changeFMortMaxF ();
    void changeFMortStartF ();
    void changeFMortPhase (int phs);
    void changeFMortNumInput (int num);
    void changeFMortNumIters (int num);

private slots:
    void changeFractionFemale();
    void changeHermaph(bool flag);
    void changeHermaphSeas(int seas);
    void changeHermaphMales(int opt);
    void changeMaturityOpt(int opt);
    void changeFecundityOption(int opt);
    void changeFecundityOffsetOption(int opt);
    void changeFecundityAdjustment(int opt);
    void changeFirstMatureAge();

    void changeSeasParams();
    void changeRecNumAssigns(int num);
    void changeRecAssignInteract (bool flag);
    void changeSpawnRecrSpec(int num);

    void changeMoveNumDefs(int value);
    void changeMoveFirstAge();

private:
    Ui::population_widget *ui;

    tableview *fecundParamsView;
    tableview *hermaphParamsView;
    tableview *growthParamsView;
    tableview *seasonParamsView;
    tableview *assignmentView;
    tableview *recruitParamsView;
    tableview *recruitDevsView;
    tableview *recruitFullParamsView;
    tableview *mortBreakPtsView;
    tableview *mortAgesView;
    tableview *mortParamsView;
    tableview *mortInputsView;
    tableview *mortInitialParamsView;

    tableview *moveDefsView;

    ss_model *model_data;
    population *pop;
};

#endif // POPULATION_WIDGET_H
