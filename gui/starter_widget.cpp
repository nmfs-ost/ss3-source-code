#include "starter_widget.h"
#include "ui_starter_widget.h"

#include "metadata.h"

#include <QFileDialog>
#include <QMessageBox>

starter_widget::starter_widget(QWidget *parent) :
    QWidget (parent),
    ui(new Ui::starter_widget)
{
    QFont title_font ("Arial", 20, 4);
    ui->setupUi(this);

    in_file = NULL;
    out_file = NULL;

    title_font.setBold(true);
    ui->label_toolbox->setFont(title_font);
    title_font.setBold(false);
    title_font.setPointSize(18);
    ui->label_app_name->setFont(title_font);
    title_font.setPointSize(14);
    ui->label_app_version->setFont(title_font);

    connect (ui->lineEdit_starter_file, SIGNAL(textChanged(QString)), SIGNAL(starter_file_changed(QString)));
    connect (ui->lineEdit_forecast_file, SIGNAL(textChanged(QString)), SIGNAL(forecast_file_changed(QString)));
    connect (ui->pushButton_control_file, SIGNAL(clicked()), SIGNAL(choose_control_file()));
    connect (ui->pushButton_data_file, SIGNAL(clicked()), SIGNAL(choose_data_file()));

    ui->comboBox_detail_level->addItem("0 - only ADMB outputs");
    ui->comboBox_detail_level->addItem("1 - brief diplay for each iteration");
    ui->comboBox_detail_level->addItem("2 - fuller display");

    ui->comboBox_parm_trace_iter->addItem("Good iter");
    ui->comboBox_parm_trace_iter->addItem("Every iter");
    ui->comboBox_parm_trace_param->addItem("Active params");
    ui->comboBox_parm_trace_param->addItem("All params");
    connect (ui->checkBox_parm_trace, SIGNAL(toggled(bool)), SLOT(parm_trace_changed(bool)));
    connect (ui->checkBox_cumrpt_fits, SIGNAL(toggled(bool)), SLOT(cumrpt_fits_changed(bool)));

    ui->spinBox_datafiles->setMinimum(1);
    ui->spinBox_datafiles->setMaximum(10);

    ui->spinBox_set_phase->setMinimum(1);
    ui->spinBox_set_phase->setMaximum(15);

    ui->spinBox_MC_burn->setMinimum(1);
    ui->spinBox_MC_burn->setMaximum(12);
    ui->spinBox_MC_thin->setMinimum(1);
    ui->spinBox_MC_thin->setMaximum(5);

    ui->doubleSpinBox_jitter->setDecimals(4);
    ui->doubleSpinBox_jitter->setMinimum(.0);
    ui->doubleSpinBox_jitter->setMaximum(.9999);

    ui->spinBox_minyear_bio_sd->setMinimum(-5);
    ui->spinBox_minyear_bio_sd->setMaximum(2020);
    ui->spinBox_maxyear_bio_sd->setMinimum(-5);
    ui->spinBox_maxyear_bio_sd->setMaximum(2025);

    ui->spinBox_sd_years->setMaximum(10);

    ui->doubleSpinBox_convergence->setDecimals(4);
    ui->doubleSpinBox_convergence->setMinimum(.0001);
    ui->doubleSpinBox_convergence->setMaximum(.9999);

    ui->spinBox_retrospect_yr->setMinimum(-10);
    ui->spinBox_retrospect_yr->setMaximum(0);

    ui->spinBox_min_age->setMinimum(1);
    ui->spinBox_min_age->setMaximum(5);

    ui->comboBox_depletion->addItem("0 - Skip");
    ui->comboBox_depletion->addItem("1 - rel X*B0");
    ui->comboBox_depletion->addItem("2 - rel X*Bmsy");
    ui->comboBox_depletion->addItem("3 - rel X*B_styr");

    ui->doubleSpinBox_depol_denom->setDecimals(3);
    ui->doubleSpinBox_depol_denom->setMinimum(.001);
    ui->doubleSpinBox_depol_denom->setMaximum(1.000);

    ui->comboBox_SPR_basis->addItem("0 - Skip");
    ui->comboBox_SPR_basis->addItem("1 - (1-SPR)/(1-SPR_tgt)");
    ui->comboBox_SPR_basis->addItem("2 - (1-SPR)/(1-SPR_MSY)");
    ui->comboBox_SPR_basis->addItem("3 - (1-SPR)/(1-SPR_Btarget)");
    ui->comboBox_SPR_basis->addItem("4 - Raw SPR");

    ui->comboBox_F_units->addItem("0 - Skip");
    ui->comboBox_F_units->addItem("1 - exploitation(Bio)");
    ui->comboBox_F_units->addItem("2 - exploitation(Num)");
    ui->comboBox_F_units->addItem("3 - sum(Frates)");
    ui->comboBox_F_units->addItem("4 - true F for range of ages");

    ui->comboBox_F_basis->addItem("0 - raw");
    ui->comboBox_F_basis->addItem("1 - F/Fspr");
    ui->comboBox_F_basis->addItem("2 - F/Fmsy");
    ui->comboBox_F_basis->addItem("3 - F/Fbtgt");

    parm_trace_changed(false);
    ui->tabWidget->setCurrentIndex(0);
}

starter_widget::~starter_widget()
{
    delete ui;
    delete in_file;
    delete out_file;
}

QString starter_widget::end_of_file()
{
    return ui->label_end_value->text();
}

bool starter_widget::param_file()
{
    return ui->checkBox_parameter_file->isChecked();
}

void starter_widget::set_starter_file(QString fname)
{
    filename = fname;
    ui->lineEdit_starter_file->setText(fname);
}

QString starter_widget::starter_file()
{
    return ui->lineEdit_starter_file->text();
}

void starter_widget::set_forecast_file(QString filename)
{
    ui->lineEdit_forecast_file->setText(filename);
}

QString starter_widget::forecast_file ()
{
    return ui->lineEdit_forecast_file->text();
}

void starter_widget::set_control_file(QString filename)
{
    ui->lineEdit_control_file->setText(filename);
}

QString starter_widget::control_file()
{
    return ui->lineEdit_control_file->text();
}

void starter_widget::set_data_file(QString filename)
{
    ui->lineEdit_data_file->setText(filename);
}

QString starter_widget::data_file()
{
    return ui->lineEdit_data_file->text();
}

void starter_widget::parm_trace_changed(bool flag)
{
    if (flag)
    {
        ui->comboBox_parm_trace_iter->show();
        ui->comboBox_parm_trace_param->show();
    }
    else
    {
        ui->comboBox_parm_trace_iter->hide();
        ui->comboBox_parm_trace_param->hide();
    }
}

void starter_widget::cumrpt_fits_changed(bool flag)
{
    if (flag)
        ui->checkBox_cumrpt_like->setChecked(true);
}

void starter_widget::read_file (QString fname)
{
    if (in_file->fileName() != fname)
    {
    if (!fname.isEmpty())
        set_starter_file(fname);

    if (!ui->lineEdit_starter_file->text().isEmpty())
    {
        if (in_file == NULL)
            in_file = new input_file(ui->lineEdit_starter_file->text());
        in_file->open(QIODevice::ReadOnly);
        read_data();
        in_file->close();
    }
    }
}

void starter_widget::write_file (QString fname)
{
    if (!fname.isEmpty())
        set_starter_file(fname);

    out_file->setFileName(ui->lineEdit_starter_file->text());
    out_file->open(QIODevice::WriteOnly);
    write_data();
    out_file->close();
}

int starter_widget::read_data()
{
    QString token = in_file->get_next_token();
    QString temp_str;
    int temp_int = 0, param = 1;

    while (token.compare("EOF", Qt::CaseInsensitive) != 0 && param < 29)
    {
//        QMessageBox::information(this, "Current Token", QString("token from file %1 is %2").arg(ui->lineEdit_starter_file->text(), token));
        if (token.startsWith('#'))
            in_file->skip_line();
        else if (param == 1) // data file
        {
            temp_str = ui->lineEdit_starter_file->text().section('/', 0, -2);
            ui->lineEdit_data_file->setText (QString("%1/%2").arg(temp_str, token));
            param++;
        }
        else if (param == 2) // control file
        {
            temp_str = ui->lineEdit_starter_file->text().section('/', 0, -2);
            ui->lineEdit_control_file->setText (QString("%1/%2").arg(temp_str, token));
            param++;
        }
        else if (param == 3) // use ss3.par file for values (0,1)
        {
            temp_int = token.toInt();
            ui->checkBox_parameter_file->setChecked(temp_int);
            param++;
        }
        else if (param == 4) // run display detail (1, 2, 3)
        {
            temp_int = token.toInt();
            ui->comboBox_detail_level->setCurrentIndex(temp_int);
            param++;
        }
        else if (param == 5) // detailed age-structured reports in REPORT.SSO (0,1)
        {
            temp_int = token.toInt();
            ui->checkBox_report->setChecked(temp_int);
            param++;
        }
        else if (param == 6) // write detailed checkup.sso file (0,1)
        {
            temp_int = token.toInt();
            ui->checkBox_checkup->setChecked(temp_int);
            param++;
        }
        else if (param == 7) // write parm values to ParmTrace.sso (0=no,1=good,active; 2=good,all; 3=every_iter,all_parms; 4=every,active
        {
            temp_int = token.toInt();
            if (temp_int == 0)
                ui->checkBox_parm_trace->setChecked(false);
            else
            {
                if (temp_int < 3)
                    ui->comboBox_parm_trace_iter->setCurrentIndex(0);
                else
                    ui->comboBox_parm_trace_iter->setCurrentIndex(1);
                if (temp_int == 1 || temp_int == 4)
                    ui->comboBox_parm_trace_param->setCurrentIndex(0);
                else
                    ui->comboBox_parm_trace_param->setCurrentIndex(1);
            }
            param++;
        }
        else if (param == 8) // write to cumreport.sso (0=no,1=like&timeseries; 2=add survey fits)
        {
            temp_int = token.toInt();
            if (temp_int > 1)
            {
                ui->checkBox_cumrpt_like->setChecked(true);
                ui->checkBox_cumrpt_fits->setChecked(true);
            }
            else
            {
                ui->checkBox_cumrpt_like->setChecked(temp_int);
                ui->checkBox_cumrpt_fits->setChecked(false);
            }
            param++;
        }
        else if (param == 9) // Include prior_like for non-estimated parameters (0,1)
        {
            temp_int = token.toInt();
            ui->checkBox_prior_likelihood->setChecked(temp_int);
            param++;
        }
        else if (param == 10) // Use Soft Boundaries to aid convergence (0,1) (recommended)
        {
            temp_int = token.toInt();
            ui->checkBox_soft_bounds->setChecked(temp_int);
            param++;
        }
        else if (param == 11) // Number of datafiles to produce: 1st is input, 2nd is estimates, 3rd and higher are bootstrap
        {
            temp_int = token.toInt();
            ui->spinBox_datafiles->setValue(temp_int);
            param++;
        }
        else if (param == 12) // Turn off estimation for parameters entering after this phase
        {
            temp_int = token.toInt();
            ui->spinBox_set_phase->setValue(temp_int);
            param++;
        }
        else if (param == 13) // MCeval burn interval
        {
            temp_int = token.toInt();
            ui->spinBox_MC_burn->setValue(temp_int);
            param++;
        }
        else if (param == 14) //  MCeval thin interval
        {
            temp_int = token.toInt();
            ui->spinBox_MC_thin->setValue(temp_int);
            param++;
        }
        else if (param == 15) // jitter initial parm value by this fraction
        {
            ui->doubleSpinBox_jitter->setValue(token.toDouble());
            param++;
        }
        else if (param == 16) // min yr for sdreport outputs (-1 for styr)
        {
            temp_int = token.toInt();
            ui->spinBox_minyear_bio_sd->setValue(temp_int);
            param++;
        }
        else if (param == 17) // max yr for sdreport outputs (-1 for endyr; -2 for endyr+Nforecastyrs
        {
            temp_int = token.toInt();
            ui->spinBox_maxyear_bio_sd->setValue(temp_int);
            param++;
        }
        else if (param == 18) //  N individual STD years
        {
            temp_int = token.toInt();
            ui->spinBox_sd_years->setValue(temp_int);
            ui->lineEdit_list_sd_values->setText(" ");
            temp_str.clear();
            in_file->skip_line();
            token = in_file->get_next_token();
            for (int i = 0; i < temp_int; i++) // vector of year values
            {
                temp_str.append(QString("%1 ").arg(token));
            }
            ui->lineEdit_list_sd_values->setText(temp_str);
            param++;
        }
        else if (param == 19) // final convergence criteria (e.g. 1.0e-04)
        {
            ui->doubleSpinBox_convergence->setValue(token.toDouble());
            param++;
        }
        else if (param == 20) // retrospective year relative to end year (e.g. -4)
        {
            temp_int = token.toInt();
            ui->spinBox_retrospect_yr->setValue(temp_int);
            param++;
        }
        else if (param == 21) // min age for calc of summary biomass
        {
            temp_int = token.toInt();
            ui->spinBox_min_age->setValue(temp_int);
            param++;
        }
        else if (param == 22) // Depletion basis:  denom is: 0=skip; 1=rel X*B0; 2=rel X*Bmsy; 3=rel X*B_styr
        {
            temp_int = token.toInt();
            ui->comboBox_depletion->setCurrentIndex(temp_int);
            param++;
        }
        else if (param == 23) // Fraction (X) for Depletion denominator (e.g. 0.4)
        {
            ui->doubleSpinBox_depol_denom->setValue(token.toDouble());
            param++;
        }
        else if (param == 24) // SPR_report_basis:  0=skip; 1=(1-SPR)/(1-SPR_tgt); 2=(1-SPR)/(1-SPR_MSY); 3=(1-SPR)/(1-SPR_Btarget); 4=rawSPR
        {
            temp_int = token.toInt();
            ui->comboBox_SPR_basis->setCurrentIndex(temp_int);
            param++;
        }
        else if (param == 25) // F_report_units: 0=skip; 1=exploitation(Bio); 2=exploitation(Num); 3=sum(Frates); 4=true F for range of ages
        {
            temp_int = token.toInt();
            ui->comboBox_F_units->setCurrentIndex(temp_int);
            param++;
            // min and max age over which average F will be calculated with F_reporting=4
            in_file->skip_line();
            if (ui->comboBox_F_units->currentIndex() == 4)
            {
                token = in_file->get_next_token();
                temp_int = token.toInt();
                ui->spinBox_F_min_age->setValue(temp_int);
                token = in_file->get_next_token();
                temp_int = token.toInt();
                ui->spinBox_F_max_age->setValue(temp_int);
            }
            param++;
        }
        else if (param == 27) // F_report_basis: 0=raw; 1=F/Fspr; 2=F/Fmsy ; 3=F/Fbtgt
        {
            temp_int = token.toInt();
            ui->comboBox_F_basis->setCurrentIndex(temp_int);
            param++;
        }
        else if (param == 28) // check value for end of file
        {
            temp_int = token.toInt();
            ui->label_end_value->setText(token);
            param++;
        }

        if (temp_int == 999 || param > 28)
        {
            token = QString ("EOF");
        }
        else
        {
            in_file->skip_line();
            token = in_file->get_next_token();
        }
    }
    return (int)in_file->canReadLine();
}

int starter_widget::write_data ()
{
    QString line("");
    int temp_int = 0, chars = 0;
    line = QString ("# %1\n").arg(QString(app_version));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1\n").arg(ui->lineEdit_data_file->text()));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1\n").arg(ui->lineEdit_control_file->text()));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # 0=use init values in control file; 1=use ss3.par\n").arg
                    (ui->checkBox_parameter_file->isChecked()?"1":"0"));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # run display detail (0,1,2)\n").arg
                    (QString::number(ui->comboBox_detail_level->currentIndex())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # detailed age-structured reports in REPORT.SSO (0,1)\n").arg
                    (ui->checkBox_report->isChecked()?"1":"0"));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # write detailed checkup.sso file (0,1)\n").arg
                    (ui->checkBox_checkup->isChecked()?"1":"0"));
    chars += out_file->write (line.toAscii());
    temp_int = 0;
    if (ui->checkBox_parm_trace->isChecked())
    {
        int iter = ui->comboBox_parm_trace_iter->currentIndex();
        int parm = ui->comboBox_parm_trace_param->currentIndex();
        temp_int = (iter == 0)? ((parm == 0)? 1: 2) : ((parm == 0)? 4: 3);
    }
    line = QString (QString ("%1 # write parm values to ParmTrace.sso (0=no,1=good,active; 2=good,all; 3=every_iter,all_parms; 4=every,active)\n").arg
                    (QString::number(temp_int)));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # write to cumreport.sso (0=no,1=like&timeseries; 2=add survey fits)\n").arg
                    (ui->checkBox_cumrpt_fits->isChecked()?"2":ui->checkBox_cumrpt_like->isChecked()?"1":"0"));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # Include prior_like for non-estimated parameters (0,1)\n").arg
                    (ui->checkBox_prior_likelihood->isChecked()?"1":"0"));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # Use Soft Boundaries to aid convergence (0,1) (recommended)\n").arg
                    (ui->checkBox_soft_bounds->isChecked()?"1":"0"));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # Number of datafiles to produce: 1st is input, 2nd is estimates, 3rd and higher are bootstrap\n").arg
                    (QString::number(ui->spinBox_datafiles->value())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # Turn off estimation for parameters entering after this phase\n").arg
                    (QString::number(ui->spinBox_set_phase->value())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # MCeval burn interval\n").arg
                    (QString::number(ui->spinBox_MC_burn->value())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # MCeval thin interval\n").arg
                    (QString::number(ui->spinBox_MC_thin->value())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # jitter initial parm value by this fraction\n").arg
                    (QString::number(ui->doubleSpinBox_jitter->value(), 'f', 3)));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # min yr for sdreport outputs (-1 for styr)\n").arg
                    (QString::number(ui->spinBox_minyear_bio_sd->value())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # max yr for sdreport outputs (-1 for endyr; -2 for endyr+Nforecastyrs\n").arg
                    (QString::number(ui->spinBox_maxyear_bio_sd->value())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # N individual STD years\n").arg
                    (QString::number(ui->spinBox_sd_years->value())));
    line.append(QString("# vector of year values \n%1 \n").arg(ui->lineEdit_list_sd_values->text()));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # final convergence criteria (e.g. 1.0e-04)\n").arg
                    (QString::number(ui->doubleSpinBox_convergence->value(), 'f', 4)));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # retrospective year relative to end year (e.g. -4)\n").arg
                    (QString::number(ui->spinBox_retrospect_yr->value())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # min age for calc of summary biomass\n").arg
                    (QString::number(ui->spinBox_min_age->value())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # Depletion basis:  denom is: 0=skip; 1=rel X*B0; 2=rel X*Bmsy; 3=rel X*B_styr\n").arg
                    (QString::number(ui->comboBox_depletion->currentIndex())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # Fraction (X) for Depletion denominator (e.g. 0.4)\n").arg
                    (QString::number(ui->doubleSpinBox_depol_denom->value(), 'f', 4)));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # SPR_report_basis:  0=skip; 1=(1-SPR)/(1-SPR_tgt); 2=(1-SPR)/(1-SPR_MSY); 3=(1-SPR)/(1-SPR_Btarget); 4=rawSPR\n").arg
                    (QString::number(ui->comboBox_SPR_basis->currentIndex())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # F_report_units: 0=skip; 1=exploitation(Bio); 2=exploitation(Num); 3=sum(Frates); 4=true F for range of ages\n").arg
                    (QString::number(ui->comboBox_F_units->currentIndex())));
    chars += out_file->write (line.toAscii());
    line = QString ("#COND 10 15 # min and max age over which average F will be calculated with F_reporting=4\n");
    if (ui->comboBox_F_units->currentIndex() == 4)
    {
        line.append(QString ("%1 %2 ").arg (QString::number(ui->spinBox_F_min_age->value()),
                                            QString::number(ui->spinBox_F_max_age->value())));
    }
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # F_report_basis: 0=raw; 1=F/Fspr; 2=F/Fmsy ; 3=F/Fbtgt\n").arg
                    (QString::number(ui->comboBox_F_basis->currentIndex())));
    chars += out_file->write (line.toAscii());
    line = QString (QString ("%1 # check value for end of file\n").arg
                    (ui->label_end_value->text()));
    chars += out_file->write (line.toAscii());
    return chars;
}

