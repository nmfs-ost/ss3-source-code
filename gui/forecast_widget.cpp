#include "forecast_widget.h"
#include "ui_forecast_widget.h"

#include <QMessageBox>

#include "metadata.h"
#include "errorfloatdialog.h"

forecast_widget::forecast_widget(ss_model *m_data, QWidget *parent) :
    QWidget(parent),
    ui(new Ui::forecast_widget)
{
    ui->setupUi(this);
    ui->label_fcast_loops_3->setVisible(false);
    ui->spinBox_fcast_loops_3->setVisible(false);
//    ui->horizontalSpacer_fcast_loops_3->
    ui->label_fcast_loops_4->setVisible(false);
    ui->spinBox_fcast_loops_4->setVisible(false);
    ui->label_fcast_loops_5->setVisible(false);
    ui->spinBox_fcast_loops_5->setVisible(false);

    model_data = m_data;
    ss_forecast *fcast = model_data->forecast;

    allocGrpFracts = new tableview();
    allocGrpFracts->setParent(this);
    ui->horizontalLayout_group_fractions->addWidget(allocGrpFracts);

    connect (ui->checkBox_benchmarks, SIGNAL(toggled(bool)), fcast, SLOT(set_benchmarks(bool)));
    connect (ui->comboBox_MSY_options, SIGNAL(currentIndexChanged(int)), fcast, SLOT(set_combo_box_MSY(int)));
    connect (ui->lineEdit_SPR_target, SIGNAL(editingFinished()), SLOT(set_spr_target()));
    connect (ui->lineEdit_biomass_target, SIGNAL(editingFinished()), SLOT(set_biomass_target()));
    connect (ui->spinBox_bmark_bio_beg, SIGNAL(valueChanged(int)), SLOT(set_bmark_bio_begin(int)));
    connect (ui->spinBox_bmark_bio_end, SIGNAL(valueChanged(int)), SLOT(set_bmark_bio_end(int)));
    connect (ui->spinBox_bmark_sel_beg, SIGNAL(valueChanged(int)), SLOT(set_bmark_sel_begin(int)));
    connect (ui->spinBox_bmark_sel_end, SIGNAL(valueChanged(int)), SLOT(set_bmark_sel_end(int)));
    connect (ui->spinBox_bmark_relf_beg, SIGNAL(valueChanged(int)), SLOT(set_bmark_relf_begin(int)));
    connect (ui->spinBox_bmark_relf_end, SIGNAL(valueChanged(int)), SLOT(set_bmark_relf_end(int)));

    connect (ui->comboBox_bmark_relF_basis, SIGNAL(currentIndexChanged(int)), fcast, SLOT(set_combo_box_relf_basis(int)));
    connect (ui->comboBox_fcast_options, SIGNAL(currentIndexChanged(int)), fcast, SLOT(set_combo_box_forecast(int)));
    connect (ui->spinBox_fcast_yr_num, SIGNAL(valueChanged(int)), fcast, SLOT(set_num_forecast_years(int)));
    connect (ui->lineEdit_F_scalar, SIGNAL(editingFinished()), SLOT(set_F_scalar()));
    connect (ui->spinBox_fcast_sel_beg, SIGNAL(valueChanged(int)), SLOT(set_fcast_sel_begin(int)));
    connect (ui->spinBox_fcast_sel_end, SIGNAL(valueChanged(int)), SLOT(set_fcast_sel_end(int)));
    connect (ui->spinBox_fcast_relf_beg, SIGNAL(valueChanged(int)), SLOT(set_fcast_relf_begin(int)));
    connect (ui->spinBox_fcast_relf_end, SIGNAL(valueChanged(int)), SLOT(set_fcast_relf_end(int)));

    connect (ui->comboBox_control_rule, SIGNAL(currentIndexChanged(int)), fcast, SLOT(set_combo_box_forecast(int)));
    connect (ui->lineEdit_ctl_rule_const_F, SIGNAL(editingFinished()), SLOT(set_cr_biomass_const_f()));
    connect (ui->lineEdit_ctl_rule_no_F, SIGNAL(editingFinished()), SLOT(set_cr_biomass_no_f()));
    connect (ui->lineEdit_ctl_tgt_as_fraction, SIGNAL(editingFinished()), SLOT(set_cr_target()));

    connect (ui->spinBox_num_forecast_loops, SIGNAL(valueChanged(int)), fcast, SLOT(set_num_forecast_loops(int)));
    connect (ui->spinBox_first_loop, SIGNAL(valueChanged(int)), fcast, SLOT(set_forecast_loop_recruitment(int)));
/*    connect (ui->spinBox_fcast_loops_3, SIGNAL(valueChanged(int)), fcast, SLOT(set_forecast_loop_ctl3(int)));
    connect (ui->spinBox_fcast_loops_4, SIGNAL(valueChanged(int)), fcast, SLOT(set_forecast_loop_ctl4(int)));
    connect (ui->spinBox_fcast_loops_5, SIGNAL(valueChanged(int)), fcast, SLOT(set_forecast_loop_ctl5(int)));*/

    connect (ui->spinBox_first_caps_yr, SIGNAL(valueChanged(int)), fcast, SLOT(set_caps_alloc_st_year(int)));
    connect (ui->lineEdit_log_sd, SIGNAL(editingFinished()), SLOT(set_log_catch_std_dev()));
    connect (ui->groupBox_rebuilder, SIGNAL(toggled(bool)), fcast, SLOT(set_rebuilder(bool)));
    connect (ui->spinBox_rebuilder_ydecl, SIGNAL(valueChanged(int)), SLOT(set_rebuilder_first_year(int)));
    connect (ui->spinBox_rebuilder_yinit, SIGNAL(valueChanged(int)), SLOT(set_rebuilder_curr_year(int)));

    connect (ui->comboBox_relF, SIGNAL(currentIndexChanged(int)), SLOT(set_combo_box_relf_basis(int)));

    connect (ui->comboBox_tuning_basis, SIGNAL(currentIndexChanged(int)), fcast, SLOT(set_combo_box_catch_tuning(int)));

    connect (ui->comboBox_input_catch_basis, SIGNAL(currentIndexChanged(int)), SLOT(set_combo_box_fixed_catch(int)));

    if (fcast->num_catch_values() > 0)
    {
        ui->scrollArea_seas_relf->setVisible(true);
        ui->label_input_seas_relf->setVisible(true);
/*        for (int i = 0; i < fcast->num_catch_values(); i++)
        {
    //        ui->checkBox_fixed_catch->setChecked(true);
            QLineEdit *qle = new QLineEdit(this);
            ssObservation *obs = model_data->forecast->fixed_catch_value(i);
            edit_fixed_catch_list.append(qle);
//            connect (qle, SIGNAL(textChanged(QString)), SLOT(set_fixed_catch_text(obs, QString)));
            qle->setText(fixed_catch_text(i));
        }*/
    }

    connect (ui->lineEdit_alloc_assignments, SIGNAL(editingFinished()), SLOT(alloc_group_assign_changed()));

    connect (ui->spinBox_fcast_levels, SIGNAL(valueChanged(int)), fcast, SLOT(set_num_catch_levels(int)));
    connect (ui->comboBox_input_catch_basis, SIGNAL(currentIndexChanged(int)), fcast, SLOT(set_combo_box_catch_input(int)));

    connect (ui->lineEdit_max_catch_fleet, SIGNAL(editingFinished()), SLOT(change_max_catch_fleet()));
    connect (ui->lineEdit_max_catch_area, SIGNAL(editingFinished()), SLOT(change_max_catch_area()));

    refresh();
    ui->tabWidget->setCurrentIndex(0);
}

forecast_widget::~forecast_widget()
{
    delete ui;
}

void forecast_widget::reset()
{
    ui->checkBox_benchmarks->setChecked(true);
    ui->comboBox_MSY_options->setCurrentIndex(1);
    ui->lineEdit_SPR_target->setText("0.4");
    ui->lineEdit_biomass_target->setText("0.2");
    ui->spinBox_bmark_bio_beg->setValue(0);
    ui->spinBox_bmark_bio_end->setValue(0);
    ui->spinBox_bmark_sel_beg->setValue(0);
    ui->spinBox_bmark_sel_end->setValue(0);
    ui->spinBox_bmark_relf_beg->setValue(0);
    ui->spinBox_bmark_relf_end->setValue(0);
    ui->comboBox_bmark_relF_basis->setCurrentIndex(0);
    ui->comboBox_fcast_options->setCurrentIndex(1);
    ui->spinBox_fcast_yr_num->setValue(4);
    ui->lineEdit_F_scalar->setText("0.2");
    ui->spinBox_fcast_sel_beg->setValue(0);
    ui->spinBox_fcast_sel_end->setValue(0);
    ui->spinBox_fcast_relf_beg->setValue(0);
    ui->spinBox_fcast_relf_end->setValue(0);
    ui->comboBox_control_rule->setCurrentIndex(0);
    ui->lineEdit_ctl_rule_const_F->setText("0.4");
    ui->lineEdit_ctl_rule_no_F->setText("0.1");
    ui->spinBox_num_forecast_loops->setValue(3);
    ui->spinBox_first_loop->setValue(3);
    ui->spinBox_fcast_loops_3->setValue(0);
    ui->spinBox_fcast_loops_4->setValue(0);
    ui->spinBox_fcast_loops_5->setValue(0);
    ui->spinBox_first_caps_yr->setValue(-1);
    ui->lineEdit_log_sd->setText("0.0");
    ui->spinBox_rebuilder_yinit->setValue(-1);
    ui->spinBox_rebuilder_ydecl->setValue(-1);
    ui->comboBox_relF->setCurrentIndex(0);
    ui->comboBox_input_catch_basis->setCurrentIndex(0);
    ui->lineEdit_max_catch_fleet->setText("-1");
    ui->lineEdit_max_catch_area->setText("-1");
}

void forecast_widget::set_model(ss_model *m_data)
{
//    ss_model *old_model = model_data;
//    model_data = m_data;
//    delete old_model;

    refresh ();
}

void forecast_widget::refresh()
{
    QString txt("");
    ss_forecast *fcast = model_data->forecast;

    ui->checkBox_benchmarks->setChecked(fcast->benchmarks() == 1);
    set_combo_box(ui->comboBox_MSY_options, fcast->MSY());
    ui->lineEdit_SPR_target->setText(QString::number(fcast->spr_target()));
    ui->lineEdit_biomass_target->setText(QString::number(fcast->biomass_target()));
    ui->spinBox_bmark_bio_beg->setValue(fcast->benchmark_year(0));
    set_bmark_bio_begin(fcast->benchmark_year(0));
    ui->spinBox_bmark_bio_end->setValue(fcast->benchmark_year(1));
    set_bmark_bio_end(fcast->benchmark_year(1));
    ui->spinBox_bmark_sel_beg->setValue(fcast->benchmark_year(2));
    set_bmark_sel_begin(fcast->benchmark_year(2));
    ui->spinBox_bmark_sel_end->setValue(fcast->benchmark_year(3));
    set_bmark_sel_end(fcast->benchmark_year(3));
    ui->spinBox_bmark_relf_beg->setValue(fcast->benchmark_year(4));
    set_bmark_relf_begin(fcast->benchmark_year(4));
    ui->spinBox_bmark_relf_end->setValue(fcast->benchmark_year(5));
    set_bmark_relf_end(fcast->benchmark_year(5));

    set_combo_box(ui->comboBox_bmark_relF_basis, fcast->benchmark_rel_f());
    set_combo_box(ui->comboBox_fcast_options, fcast->forecast());
    ui->spinBox_fcast_yr_num->setValue(fcast->num_forecast_years());
    ui->lineEdit_F_scalar->setText(QString::number(fcast->f_scalar()));
    ui->spinBox_fcast_sel_beg->setValue(fcast->forecast_year(0));
    set_fcast_sel_begin(fcast->forecast_year(0));
    ui->spinBox_fcast_sel_end->setValue(fcast->forecast_year(1));
    set_fcast_sel_end(fcast->forecast_year(1));
    ui->spinBox_fcast_relf_beg->setValue(fcast->forecast_year(2));
    set_fcast_relf_begin(fcast->forecast_year(2));
    ui->spinBox_fcast_relf_end->setValue(fcast->forecast_year(3));
    set_fcast_relf_end(fcast->forecast_year(3));

    set_combo_box(ui->comboBox_control_rule, fcast->cr_method());
    ui->lineEdit_ctl_rule_const_F->setText(QString::number(fcast->cr_biomass_const_f()));
    ui->lineEdit_ctl_rule_no_F->setText(QString::number(fcast->cr_biomass_no_f()));
    ui->lineEdit_ctl_tgt_as_fraction->setText(QString::number(fcast->cr_target()));

    ui->spinBox_num_forecast_loops->setValue(fcast->num_forecast_loops());
    ui->spinBox_first_loop->setValue(fcast->forecast_loop_recruitment());
    ui->spinBox_fcast_loops_3->setValue(fcast->forecast_loop_ctl3());
    ui->spinBox_fcast_loops_4->setValue(fcast->forecast_loop_ctl4());
    ui->spinBox_fcast_loops_5->setValue(fcast->forecast_loop_ctl5());

    ui->spinBox_first_caps_yr->setValue(fcast->caps_alloc_st_year());
    ui->lineEdit_log_sd->setText(QString::number(fcast->log_catch_std_dev()));
    ui->groupBox_rebuilder->setChecked(fcast->rebuilder());
    ui->spinBox_rebuilder_ydecl->setValue(fcast->rebuilder_first_year());
    ui->spinBox_rebuilder_yinit->setValue(fcast->rebuilder_curr_year());

    ui->scrollArea_seas_relf->setVisible(false);
    ui->label_input_seas_relf->setVisible(false);
    set_combo_box(ui->comboBox_relF, fcast->fleet_rel_f());


    set_combo_box(ui->comboBox_tuning_basis, fcast->catch_tuning_basis());
    set_max_catch_fleet();
    set_max_catch_area();

    set_allocation_groups();
    set_allocation_group_assign();
    allocGrpFracts->setModel(fcast->getAllocFractModel());
    allocGrpFracts->resizeColumnsToContents();

    ui->scrollArea_fixed_catch->setVisible(false);
    ui->label_input_fixed_catch->setVisible(false);

    ui->spinBox_fcast_levels->setValue(fcast->num_catch_levels());
    set_combo_box(ui->comboBox_input_catch_basis, fcast->input_catch_basis());


    ui->tabWidget->setCurrentIndex(0);
}

void forecast_widget::set_combo_box(QComboBox *cbox, int value)
{
    QString entry, val(QString::number(value));
    int i;
    for (i = 0; i < cbox->count(); i++)
    {
        cbox->setCurrentIndex(i);
        entry = cbox->currentText();
        if (entry.contains (val))
            break;
    }
    if (i == cbox->maxCount())
        cbox->setCurrentIndex(0);
}

void forecast_widget::set_spr_target()
{
    QString value(ui->lineEdit_SPR_target->text());
    double spr = checkdoublevalue(value);
    model_data->forecast->set_spr_target(spr);
    ui->lineEdit_SPR_target->setText(QString::number(spr));
}

void forecast_widget::set_biomass_target()
{
    QString value(ui->lineEdit_biomass_target->text());
    double bmt = checkdoublevalue(value);
    model_data->forecast->set_biomass_target(bmt);
    ui->lineEdit_biomass_target->setText(QString::number(bmt));
}

void forecast_widget::set_F_scalar()
{
    QString value(ui->lineEdit_F_scalar->text());
    double fsc = checkdoublevalue(value);
    model_data->forecast->set_f_scalar(fsc);
    ui->lineEdit_F_scalar->setText(QString::number(fsc));
}

void forecast_widget::set_cr_biomass_const_f()
{
    QString value(ui->lineEdit_ctl_rule_const_F->text());
    double val = checkdoublevalue(value);
    model_data->forecast->set_cr_biomass_const_f(val);
    ui->lineEdit_ctl_rule_const_F->setText(QString::number(val));
}
void forecast_widget::set_cr_biomass_no_f()
{
    QString value(ui->lineEdit_ctl_rule_no_F->text());
    double val = checkdoublevalue(value);
    model_data->forecast->set_cr_biomass_no_f(val);
    ui->lineEdit_ctl_rule_no_F->setText(QString::number(val));

}
void forecast_widget::set_cr_target()
{
    QString value(ui->lineEdit_ctl_tgt_as_fraction->text());
    double val = checkdoublevalue(value);
    model_data->forecast->set_cr_target(val);
    ui->lineEdit_ctl_tgt_as_fraction->setText(QString::number(val));

}

void forecast_widget::set_log_catch_std_dev()
{
    QString value(ui->lineEdit_log_sd->text());
    double val = checkdoublevalue(value);
    model_data->forecast->set_log_catch_std_dev(val);
    ui->lineEdit_log_sd->setText(QString::number(val));

}

void forecast_widget::set_allocation_groups()
{
    set_num_alloc_groups(model_data->forecast->num_alloc_groups());
}

void forecast_widget::set_num_alloc_groups(int num)
{
    if (num != ui->spinBox_num_alloc_groups->value())
    {
        ui->spinBox_num_alloc_groups->setValue(num);
        if (num > 0)
            ui->groupBox_alloc_groups->setChecked(true);
        else
            ui->groupBox_alloc_groups->setChecked(false);
    }
}

void forecast_widget::set_allocation_group_assign()
{
    int num = model_data->forecast->num_fleets();
    QString txt("");
    for (int i = 0; i < num; i++)
    {
        txt.append(QString("%1 ").arg(QString::number(model_data->forecast->alloc_group(i))));
    }
    ui->lineEdit_alloc_assignments->setText(txt);
}

void forecast_widget::alloc_group_assign_changed ()
{
    QString txt (ui->lineEdit_alloc_assignments->text());
    bool okay = true;
    int num = -1;
    QStringList ql(txt.split(' ', QString::SkipEmptyParts));

    if (ql.count() != model_data->num_fisheries())
    {

    }
//    ui->spinBox_num_alloc_groups->setValue(ql.count());

    for (int i = 0; i < ql.count(); i++)
    {
        int val = ql.at(i).toInt(&okay);
        if (!okay)
        {
            ErrorFloatDialog efd (this, "Error in values", "Not all integer values", ql.count(), false);
            efd.fromText(txt);
            efd.exec();
            txt = efd.toText();
            okay = true;
            ui->lineEdit_alloc_assignments->setText(txt);
            alloc_group_assign_changed();
            break;
        }
        else
        {
            model_data->forecast->set_alloc_group(i, val);
            if (val > num)
                num = val;
        }
    }
    if (num < 1)
    {
        ui->groupBox_alloc_groups->setChecked(false);
    }
    set_num_alloc_groups(num);
    model_data->forecast->set_num_alloc_groups(num);
}

void forecast_widget::set_allocation_group_fract()
{
/*    int num = model_data->forecast->num_alloc_groups();
    QString txt("");
    for (int i = 0; i < num; i++)
    {
        txt.append(QString("%1 ").arg(QString::number(model_data->forecast->alloc_fraction(0, i))));
    }
    ui->lineEdit_alloc_fractions->setText(txt);*/
}

void forecast_widget::alloc_group_fract_changed ()
{
/*    QString txt (ui->lineEdit_alloc_fractions->text());
    bool okay;
    QString err_title("Allocation Group Fractions Error"), err_msg;
    QStringList ql(txt.split(' ', QString::SkipEmptyParts));
    for (int i = 0; i < ql.count(); i++)
    {
        float val = ql.at(i).toFloat(&okay);
        if (!okay)
        {
            ErrorFloatDialog efd (this, "Error in values", "Not all float values", ql.count(), true);
            efd.setNumValues(ui->spinBox_num_alloc_groups->value());
            efd.fromText(txt);
            efd.setSumValue(1.0);
            efd.exec();
            txt = efd.toText();
            okay = true;
            ui->lineEdit_alloc_fractions->setText(txt);
            alloc_group_fract_changed();
            break;
        }
        else
        {
            model_data->forecast->set_alloc_fraction(0, i, val);
        }
    }*/
}

void forecast_widget::set_max_catch_fleet ()
{
    QString vals;
    for (int i = 0; i < model_data->num_fleets(); i++)
    {
        vals.append(QString(" %1").arg(QString::number(model_data->forecast->max_catch_fleet(i))));
    }
    ui->lineEdit_max_catch_fleet->setText(vals);
}

void forecast_widget::change_max_catch_fleet ()
{
    QString txt (ui->lineEdit_max_catch_fleet->text());
    QStringList vals(txt.split(' ', QString::SkipEmptyParts));
    for (int i = 0; i < vals.count(), i < model_data->num_fleets(); i++)
    {
        int val = checkintvalue(vals.at(i));
        model_data->forecast->set_max_catch_fleet(i, val);
    }
    set_max_catch_fleet();
}

void forecast_widget::set_max_catch_area ()
{
    QString vals;
    for (int i = 0; i < model_data->num_areas(); i++)
    {
        vals.append(QString(" %1").arg(QString::number(model_data->forecast->max_catch_area(i))));
    }
    ui->lineEdit_max_catch_area->setText(vals);
}

void forecast_widget::change_max_catch_area ()
{
    QString txt (ui->lineEdit_max_catch_area->text());
    QStringList vals(txt.split(' ', QString::SkipEmptyParts));
    for (int i = 0; i < vals.count(), i < model_data->num_areas(); i++)
    {
        int val = checkintvalue(vals.at(i));
        model_data->forecast->set_max_catch_area(i, val);
    }
    set_max_catch_area();
}


void forecast_widget::set_combo_box_relf_basis (int val)
{
    model_data->forecast->set_combo_box_fleet_relf(val);
    if (val == 1)
    {
        ui->scrollArea_seas_relf->setVisible(true);
        ui->label_input_seas_relf->setVisible(true);
//        ui->lineEdit_seas_relf->setVisible(true);
//        ui->lineEdit_alloc_assignments->setText(model_data->forecast->seas_fleet_rel_f(0,0));
    }
    else
    {
        ui->scrollArea_seas_relf->setVisible(false);
        ui->label_input_seas_relf->setVisible(false);
//        ui->lineEdit_seas_relf->setVisible(false);
    }
}

void forecast_widget::set_combo_box_fixed_catch(int value)
{
    model_data->forecast->set_combo_box_catch_input(value);
    ui->scrollArea_fixed_catch->setVisible(value);
    ui->label_fixed_catch->setVisible(value);
}

void forecast_widget::set_bmark_bio_begin(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_benchmark_bio_beg(year);
    year = model_data->refyearvalue(yr);
    ui->label_bmark_bio_beg_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_bmark_bio_end(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_benchmark_bio_end(year);
    year = model_data->refyearvalue(yr);
    ui->label_bmark_bio_end_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_bmark_sel_begin(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_benchmark_sel_beg(year);
    year = model_data->refyearvalue(yr);
    ui->label_bmark_sel_beg_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_bmark_sel_end(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_benchmark_sel_end(year);
    year = model_data->refyearvalue(yr);
    ui->label_bmark_sel_end_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_bmark_relf_begin(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_benchmark_relf_beg(year);
    year = model_data->refyearvalue(yr);
    ui->label_bmark_relf_beg_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_bmark_relf_end(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_benchmark_relf_end(year);
    year = model_data->refyearvalue(yr);
    ui->label_bmark_relf_end_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_fcast_sel_begin(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_forecast_sel_beg(year);
    year = model_data->refyearvalue(yr);
    ui->label_fcast_sel_beg_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_fcast_sel_end(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_forecast_sel_end(year);
    year = model_data->refyearvalue(yr);
    ui->label_fcast_sel_end_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_fcast_relf_begin(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_forecast_relf_beg(year);
    year = model_data->refyearvalue(yr);
    ui->label_fcast_relf_beg_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_fcast_relf_end(int yr)
{
    int year = model_data->checkyearvalue(yr);
    model_data->forecast->set_forecast_relf_end(yr);
    year = model_data->refyearvalue(yr);
    ui->label_fcast_relf_end_yr_ref->setText (QString::number(year));
}

void forecast_widget::set_rebuilder_first_year(int yr)
{
    int year = yr;
    if (yr == -1)
    {
        year = 1999;
    }
    else if (yr < model_data->start_year())
    {
        yr = model_data->start_year();
        ui->spinBox_rebuilder_ydecl->setValue(yr);
        return;
    }
    else if (yr > model_data->end_year())
    {
        yr = model_data->end_year();
        ui->spinBox_rebuilder_ydecl->setValue(yr);
        return;
    }
    model_data->forecast->set_rebuilder_first_year(yr);
    ui->label_rebuilder_ydecl->setText(QString::number(year));
}

void forecast_widget::set_rebuilder_curr_year(int yr)
{
    int year = yr;
    if (yr == -1)
    {
        year = model_data->end_year() + 1;
    }
    else if (yr < model_data->start_year())
    {
        yr = model_data->start_year();
        ui->spinBox_rebuilder_yinit->setValue(yr);
        return;
    }
    else if (yr > (model_data->end_year() + 1))
    {
        yr = model_data->end_year() + 1;
        ui->spinBox_rebuilder_yinit->setValue(yr);
        return;
    }
    model_data->forecast->set_rebuilder_curr_year(yr);
    ui->label_rebuilder_yinit->setText(QString::number(year));
}

