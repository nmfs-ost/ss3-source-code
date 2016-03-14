#ifndef FLEET_WIDGET_H
#define FLEET_WIDGET_H

#include <QWidget>
#include <QFont>

#include "model.h"
#include "fleet.h"
#include "tableview.h"
#include "catchdelegate.h"
#include "abundancedelegate.h"

namespace Ui {
class fleet_widget;
}

class fleet_widget : public QWidget
{
    Q_OBJECT

public:
    explicit fleet_widget(ss_model *m_data, QWidget *parent = 0);
    ~fleet_widget();

public slots:
    void edit_name ();
    void setActive (bool flag);
    void reset ();
    void refresh();
    void set_model (ss_model *model);
    void set_current_fleet (int index);
    void set_fleet_type (int type);
    void set_type_fleet (Fleet::FleetType ft);
    void nextFleet();
    void prevFleet();
    void create_new_fleet();
    void duplicate_current_fleet();
    void delete_current_fleet();
    void new_fleet (QString name = QString(""));
    void duplicate_fleet (int index);
    void delete_fleet (int index);

    void showLengthObs();
    void changeLengthMinTailComp();
    void changeLengthAddToData();
    void showAgeObs();
    void changeAgeMinTailComp();
    void changeAgeAddToData();
    void showMeanSAAObs();
    void showGenSizeObs(int index);
    void setGenMethodTotal(int num);
    void changeGenMethodTotal(int num);
    void setGenMethodNum(int num);
    void changeGenMethodNum(int num);
    void setGenNumObs(int num);
    void changeGenNumObs(int num);
    void showMorphObs();
    void showRecapObs();

    void changeSelexSizePattern(int pat);
    void showSelexSizeInfo();
    void changeSelexAgePattern(int pat);
    void showSelexAgeInfo();

private:

    Ui::fleet_widget *ui;
    QFont titleFont;

    ss_model *model_data;
    Fleet * current_fleet;
    int totalFleets;

    tableview *catchview;
    catchdelegate *catchedit;

    tableview *abundview;
    abundancedelegate *abundedit;

    tableview *discardview;
    abundancedelegate *discardedit;

    tableview *mbwtView;
    tableview *lenCompView;
    tableview *ageCompView;
    tableview *saaObsView;
    int cur_gen_obs;
    tableview *genObsView;
    tableview *morphObsView;
    tableview *recapObsView;

    tableview *qParamsView;
    tableview *sizeSelexParamsView;
    tableview *ageSelexParamsView;
    tableview *lambdaView;

    void refreshFleetNames();
    void connectFleet ();
    void disconnectFleet ();
};

#endif // FLEET_WIDGET_H

