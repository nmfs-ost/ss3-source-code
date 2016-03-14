#ifndef FORECAST_WIDGET_H
#define FORECAST_WIDGET_H

#include <QWidget>

#include "input_file.h"
#include "model.h"

namespace Ui {
class forecast_widget;
}

class forecast_widget : public QWidget
{
    Q_OBJECT
    
public:
    explicit forecast_widget(ss_model *m_data, QWidget *parent = 0);
    ~forecast_widget();

public slots:
    void set_model (ss_model * m_data);

//    void set_fixed_catch_text(ssObservation *obs, QString txt);
//    void set_fixed_catch_text (int i, QString txt);
//    QString fixed_catch_text (int i);

    void reset();
    void refresh();
    void set_spr_target();
    void set_biomass_target();
    void set_F_scalar();
    void set_bmark_bio_begin(int yr);
    void set_bmark_bio_end(int yr);
    void set_bmark_sel_begin(int yr);
    void set_bmark_sel_end (int yr);
    void set_bmark_relf_begin(int yr);
    void set_bmark_relf_end(int yr);
    void set_fcast_sel_begin(int yr);
    void set_fcast_sel_end (int yr);
    void set_fcast_relf_begin(int yr);
    void set_fcast_relf_end (int yr);
    void set_combo_box_relf_basis (int);
    void set_combo_box_fixed_catch (int);

    void set_cr_biomass_const_f();
    void set_cr_biomass_no_f();
    void set_cr_target();
    void set_log_catch_std_dev();
    void set_num_alloc_groups (int num);
    void set_allocation_groups();
    void set_allocation_group_assign();
    void alloc_group_assign_changed ();
    void set_allocation_group_fract();
    void alloc_group_fract_changed ();
    void set_rebuilder_first_year(int yr);
    void set_rebuilder_curr_year(int yr);

    void set_max_catch_fleet ();
    void change_max_catch_fleet ();
    void set_max_catch_area ();
    void change_max_catch_area ();

signals:
    
private:
    Ui::forecast_widget *ui;

    ss_model *model_data;

    void set_combo_box (QComboBox *cbox, int value);
    QList <QLineEdit *> edit_fixed_catch_list;

    tableview *allocGrpFracts;
};

#endif // FORECAST_WIDGET_H
