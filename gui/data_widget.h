#ifndef DATA_WIDGET_H
#define DATA_WIDGET_H

#include <QWidget>
#include "model.h"

#include "input_file.h"
#include "tablemodel.h"
#include "tableview.h"
#include "mbweightdelegate.h"
#include "composition.h"

namespace Ui {
class data_widget;
}

class data_widget : public QWidget
{
    Q_OBJECT
    
public:
    explicit data_widget(ss_model *model, QWidget *parent = 0);
    ~data_widget();
    
    QStringList fleet_names;
    QStringList survey_names;
    QStringList area_names;
    


public slots:
    void set_model (ss_model *m_data = 0);
    void reset();
    void refresh();

    void changeMaxSeason (int num);
    void changeSeason (int seas);
    void setMoPerSeason ();
    void changeMoPerSeason (QString txt);
    void changeSpawnSeason (int seas);
//    QString get_mo_per_seas ();
    void setFRptUnits(int val);
    void setNumSdYears(int val);
    void changeNumGenders (int val);

//    void setMBWTObs(int numBins);
//    void changeMBWTObs(int numBins);
    void setLengthCompMethod(int method);
    void changeLengthCompMethod(int method);
    void setLengthBins(int numBins);
    void changeLengthBins(int numBins);
    void changeLengthCombine(int gen);
    void changeLengthCompress();
    void changeLengthAdd ();
    void setAgeCompMethod (int method);
    void changeAgeCompMethod (int method);
    void setAgeBins (int numBins);
    void changeAgeBins(int numBins);
    void setAgeError (int numDefs);
    void changeAgeError(int numDefs);
    void changeAgeCombine (int gen);
    void setGenCompMethod(int method);
    void changeGenCompMethod(int method);
    void changeGenBins(int numBins);
    void changeGenUnits(int units);
    void changeGenScale(int scale);
    void changeGenMinComp();
    void showGenObs();
    void setDoMorphs(bool flag);
    void changeDoMorphs(bool flag);
    void changeMorphs(int num);
    void changeMorphMincomp ();
    void setDoTags(bool flag);
    void changeDoTags(bool flag);
    void changeBlockPattern(int num);
    void setBlockPattern (int num);

    void changeJitter();
    void changeConvergence();
    void changeDepDenom();

signals:
    void showLengthObs();
    void showAgeObs();
    void showSAAObs();
    void showGenObs(int index);
    void showMorphObs();
    void showRecapObs();

private slots:
    void changeTotalYears();
    void numSdYearsChanged(QWidget *qw);

private:
    Ui::data_widget *ui;
    tableview *sdYearsView;
    spinBoxDelegate *sdYearsDelegate;

    ss_model *model_data;

    tableview *mbweightview;
    mbweightdelegate *mbweightedit;

    tableview *lengthBins;
    spinBoxDelegate *lBinsDelegate;

//    tableview *lengthObs;

    tableview *ageBins;
    spinBoxDelegate *aBinsDelegate;

    tableview *ageError;

    compositionGeneral *current_gen_comp;
    tableview *genBins;

    tableview *tagGroups;

    tableview *envVariables;

    tableview *timeBlocks;
    tableview *lambdaView;

    tableview *addSdSpecification;
    tableview *addSdBinList;

    int StartYear;
    int EndYear;
    int SeasonsPerYear;
    int SpawningSeasons;
    int numFleets;
    int numSurveys;
    int numAreas;
    QString filename;
    QList<int> monthsPerSeason;
    int setTotalMonths();

};

#endif // DATA_WIDGET_H
