#include <QMessageBox>
#include <QFileDialog>

#include <cmath>
#include <cstdio>
using namespace std;


#include "file_info_dialog.h"
//#include "metadata.h"
#include "fleet.h"
#include "block_pattern.h"
#include "growth.h"
//#include "data_widget.h"
#include "file_widget.h"
#include "fileIO32.h"
#include "fileIO33.h"
#include "ui_file_widget.h"

file_widget::file_widget(ss_model *mod, QWidget *parent) :
    QWidget(parent),
    ui(new Ui::file_widget)
{
    ui->setupUi(this);

//    TODO: This is for debugging only, make sure to change them before building release.
    {
    bool check = false;
    ui->label_version->setVisible(check);
    ui->doubleSpinBox_version->setVisible(check);
    }

    starterFile = new ss_file(STARTER_FILE, this);
    forecastFile = new ss_file(FORECAST_FILE, this);
    dataFile = new ss_file(DATA_FILE, this);
    controlFile = new ss_file(CONTROL_FILE, this);
    runNumberFile = new ss_file(RUN_NUMBER_FILE, this);
    parameterFile = new ss_file(PARAMETER_FILE, this);
    profileFile = new ss_file(PROFILE_VAL_FILE, this);
    userDataFile = NULL;

    model_info = mod;

    setVersion(3.30, false);  // default version 3.3.0.

//    connect (ui->lineEdit_starter_file, SIGNAL(textChanged(QString)), SIGNAL(starter_file_changed(QString)));
//    connect (ui->lineEdit_forecast_file, SIGNAL(textChanged(QString)), SIGNAL(forecast_file_changed(QString)));

    connect (ui->toolButton_file_read, SIGNAL(clicked()), SLOT(read_files()));
    connect (ui->toolButton_control_file_new, SIGNAL(clicked()), SIGNAL(choose_control_file()));
    connect (ui->toolButton_control_file_save_as, SIGNAL(clicked()), SIGNAL(save_control_file()));
    connect (ui->toolButton_data_file_new, SIGNAL(clicked()), SIGNAL(choose_data_file()));
    connect (ui->toolButton_data_file_save_as, SIGNAL(clicked()), SIGNAL(save_data_file()));

    connect (ui->pushButton_starter_file, SIGNAL(clicked()), SLOT(show_starter_file_info()));
    connect (ui->pushButton_fcast_file, SIGNAL(clicked()), SLOT(show_forecast_file_info()));
    connect (ui->pushButton_data_file, SIGNAL(clicked()), SLOT(show_data_file_info()));
    connect (ui->pushButton_control_file, SIGNAL(clicked()), SLOT(show_control_file_info()));
    connect (ui->pushButton_par_file, SIGNAL(clicked()), SLOT(show_param_file_info()));
    connect (ui->pushButton_pro_file, SIGNAL(clicked()), SLOT(show_prof_file_info()));

//    connect (ui->checkBox_parm_trace, SIGNAL(toggled(bool)), SLOT(parm_trace_changed(bool)));
    connect (ui->checkBox_parm_trace, SIGNAL(toggled(bool)), ui->comboBox_parm_trace_iter, SLOT(setVisible(bool)));
    connect (ui->checkBox_parm_trace, SIGNAL(toggled(bool)), ui->comboBox_parm_trace_param, SLOT(setVisible(bool)));

    connect (ui->checkBox_cumrpt_fits, SIGNAL(toggled(bool)), SLOT(cumrpt_fits_changed(bool)));
    connect (ui->checkBox_cumrpt_like, SIGNAL(toggled(bool)), SLOT(cumrpt_like_changed(bool)));

    ui->spinBox_datafiles->setMinimum(1);
    ui->spinBox_datafiles->setMaximum(10);

    connect (ui->checkBox_par_file, SIGNAL(toggled(bool)), SLOT(set_par_file(bool)));
    connect (ui->checkBox_pro_file, SIGNAL(toggled(bool)), SLOT(set_pro_file(bool)));
    connect (ui->pushButton_runnum_file, SIGNAL(clicked()), SLOT(reset_run_num()));

//    connect (ui->doubleSpinBox_version, SIGNAL(valueChanged(double)), SLOT(setVersion(double)));
    ui->label_version->setVisible(false);
    ui->doubleSpinBox_version->setVisible(false);

    set_par_file(false);
    set_pro_file(false);


    parm_trace_changed(false);
    show_input_files();
//    ui->tabWidget->setCurrentIndex(0);
    error = new QFile(this);

    current_dir = QDir (qApp->applicationDirPath());
    data_file_name = QString (DATA_FILE);
    control_file_name = QString (CONTROL_FILE);
    set_default_file_names (current_dir.absolutePath(), false);
}

void file_widget::reset()
{
    set_par_file(false);
    ui->comboBox_detail_level->setCurrentIndex(1);
    ui->checkBox_report->setChecked(true);
    ui->checkBox_checkup->setChecked(false);
    set_parmtr_write(0);
    set_cumrpt_write(1);
    set_pro_file(false);
    ui->spinBox_datafiles->setValue(0);

//    setVersion(3.2);
//    ui->checkBox_prior_likelihood->setChecked(true);
}

file_widget::~file_widget()
{
    error->close();
    delete error;
    delete starterFile;
    delete dataFile;
    delete forecastFile;
    delete controlFile;
    delete runNumberFile;
    delete parameterFile;
    delete profileFile;
    delete userDataFile;

    delete ui;
}

void file_widget::setVersion(double ver, bool flag)
{
    datafile_version = ver + .000001;
    if (datafile_version < 3.30)
    {
        model_info->setReadMonths(false);
        ui->label_version_33_note->setVisible(false);
        ui->label_version_32_note->setVisible(true);
    }
    else
    {
        model_info->setReadMonths(true);
        ui->label_version_33_note->setVisible(true);
        ui->label_version_32_note->setVisible(false);
    }
    if (!flag)
    {
        ui->label_version_32_note->setVisible(false);
        ui->label_version_33_note->setVisible(false);
    }
}

void file_widget::show_input_files()
{
    ui->tabWidget->setCurrentIndex (0);
}

void file_widget::show_output_files()
{
    ui->tabWidget->setCurrentIndex (1);
}

void file_widget::set_starter_file(QString fname, bool keep)
{
    ui->label_starter_file->setText(fname);
    current_dir_name = current_dir.absoluteFilePath(fname);
    current_dir.cd(current_dir_name);
    current_dir_name = current_dir.absolutePath();

    if (starterFile == NULL)
    {
        starterFile = new ss_file(fname);
    }
    else if (starterFile->fileName().compare(fname, Qt::CaseSensitive))
    {
        starterFile->setFileName(fname);
    }
    if (starterFile->exists() && starterFile->isReadable())
        read_starter_file(fname);
}


QString file_widget::starter_file()
{
    return ui->label_starter_file->text();
}

void file_widget::set_forecast_file(QString fname, bool keep)
{
    ui->label_fcast_file->setText(fname);

    if (forecastFile == NULL)
    {
        forecastFile = new ss_file(fname);
    }
    else if (forecastFile->fileName().compare(fname, Qt::CaseSensitive))
    {
        forecastFile->setFileName(fname);
/*        QStringList comments = forecast->comments;
        delete forecast;
        forecast = new ss_file (fname, this);
        if (keep)
        for (int i = 0; i < comments.count(); i++)
            forecast->comments.append(comments.at(i));*/
    }
}

QString file_widget::forecast_file ()
{
//    return ui->lineEdit_forecast_file->text();
    return ui->label_fcast_file->text();
}

void file_widget::set_control_file(QString fname, bool keep)
{
//    ui->lineEdit_control_file->setText(filename);
//    QStringList commnts;
    if (controlFile == NULL)
    {
        controlFile = new ss_file(fname);
    }
    else if (controlFile->fileName().compare(fname, Qt::CaseSensitive))
    {
        controlFile->setFileName(fname);
/*        QStringList comments = control->comments;
        delete control;
        control = new ss_file (fname, this);
        if (keep)
        for (int i = 0; i < comments.count(); i++)
            control->comments.append(comments.at(i));*/
    }

    if (fname.contains('/'))
        control_file_name = fname.section('/', -1, -1);
    else
        control_file_name = fname.section('\\', -1, -1);
    ui->label_control_file->setText(fname);
}

QString file_widget::control_file()
{
//    return ui->lineEdit_control_file->text();
    return ui->label_control_file->text();
}

void file_widget::set_data_file(QString fname, bool keep)
{
//    QStringList commnts;
    if (dataFile == NULL)
    {
        dataFile = new ss_file(fname);\
    }
    else if (dataFile->fileName().compare(fname, Qt::CaseSensitive))
    {
        dataFile->setFileName(fname);
/*        QStringList comments = model_data_file->comments;
        delete model_data_file;
        model_data_file = new ss_file (fname, this);
        if (keep)
        for (int i = 0; i < comments.count(); i++)
            model_data_file->comments.append(comments.at(i));*/
    }
    if (fname.contains('/'))
        data_file_name = fname.section('/', -1, -1);
    else
        data_file_name = fname.section('\\', -1, -1);
//    ui->lineEdit_data_file->setText(filename);
    ui->label_data_file->setText(fname);
}

QString file_widget::data_file()
{
    return ui->label_data_file->text();
}


QString file_widget::run_num_file()
{
    return QString("RunNumber.SS");
}

void file_widget::set_par_file(bool flag)
{
    ui->checkBox_par_file->setChecked(flag);
    ui->label_parameter_file->setVisible(flag);
    ui->pushButton_par_file->setVisible(flag);
}

QString file_widget::param_file()
{
    return ui->label_parameter_file->text();
}

void file_widget::set_par_file(QString fname, bool keep)
{
    QStringList commnts;
    if (fname.isEmpty())
    {
        set_par_file(false);
    }
    else
    {
        if (parameterFile == NULL)
        {
            parameterFile = new ss_file(fname);
        }
        else if (fname != parameterFile->fileName())
        {
            parameterFile->setFileName(fname);
        }
        ui->label_parameter_file->setText(fname);
        set_par_file(true);
    }
}

QString file_widget::profile_file()
{
    return ui->label_profile_file->text();
}

void file_widget::set_pro_file(bool flag)
{
    ui->checkBox_pro_file->setChecked(flag);
    ui->label_profile_file->setVisible(flag);
    ui->pushButton_pro_file->setVisible(flag);
}

void file_widget::set_pro_file(QString fname, bool keep)
{
    QStringList commnts;
    if (fname.isEmpty())
    {
        set_pro_file(false);
    }
    else
    {
        if (profileFile == NULL)
        {
            profileFile = new ss_file(fname);
        }
        else if (fname != profileFile->fileName())
        {
            profileFile->setFileName(fname);
        }
        ui->label_profile_file->setText(fname);
        set_pro_file(true);
    }
}

float file_widget::get_version_number(QString token)
{
    bool okay;
    float ver = token.toFloat(&okay);
    if (!okay)
    {
        QStringList nums = token.split('.', QString::SkipEmptyParts);
        ver = nums.at(0).toFloat();
        ver += nums.at(1).toFloat()/10.0;
    }
    return ver + .0000005;
}

void file_widget::parm_trace_changed(bool flag)
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

void file_widget::cumrpt_fits_changed(bool flag)
{
    if (flag)
        ui->checkBox_cumrpt_like->setChecked(flag);
}

void file_widget::cumrpt_like_changed(bool flag)
{
    if (!flag)
        ui->checkBox_cumrpt_fits->setChecked(flag);
}

void file_widget::increase_font ()
{
    QString f_fam = font().family();
    int f_size = font().pointSize();
    if (f_size < 24)
    {
        f_size += 2;
        setFont(QFont(f_fam, f_size));
    }
}

void file_widget::decrease_font()
{
    QString f_fam = font().family();
    int f_size = font().pointSize();
    if (f_size > 12)
    {
        f_size -= 2;
        setFont(QFont(f_fam, f_size));
    }
}

void file_widget::set_default_file_names(QString dir, bool keep)
{
    // standard input file names
    set_starter_file(QString("%1/%2").arg(dir, QString(STARTER_FILE)), keep);
    set_forecast_file(QString("%1/%2").arg(dir, QString(FORECAST_FILE)), keep);
    set_data_file(QString("%1/%2").arg(dir, QString(data_file_name)), keep);
    set_control_file(QString("%1/%2").arg(dir, QString(control_file_name)), keep);
    set_par_file(QString("%1/%2").arg(dir, QString(PARAMETER_FILE)));
    set_pro_file(QString("%1/%2").arg(dir, QString(PROFILE_VAL_FILE)));

    ui->label_comp_report_file->setText(QString("%1/%2").arg(dir, QString(COMP_REPORT_FILE)));
    ui->label_cum_report_file->setText(QString("%1/%2").arg(dir, QString(CUM_REPORT_FILE)));
    ui->label_fcast_report_file->setText(QString("%1/%2").arg(dir, QString(FCAST_REPORT_FILE)));
    ui->label_report_file->setText(QString("%1/%2").arg(dir, QString(REPORT_FILE)));

    // reset defaults
    set_par_file(false);
    set_pro_file(false);

    parm_trace_changed(false);
    show_input_files();
    // our plucky error file
    error->close();
    error->setFileName(QString("%1/%2").arg(dir, QString(ERROR_FILE)));
    error->open(QIODevice::WriteOnly);
}

void file_widget::new_directory(QString dir, bool keep)
{
    current_dir.cd(dir);
    current_dir_name = current_dir.absolutePath();
    ui->label_current_dir->setText(dir);
    set_default_file_names (dir, keep);
}

void file_widget::set_parmtr_write(int flag)
{
    switch (flag)
    {
    case 0:
        ui->checkBox_parm_trace->setChecked(false);
        break;
    case 1:
        ui->checkBox_parm_trace->setChecked(true);
        ui->comboBox_parm_trace_iter->setCurrentIndex(0);
        ui->comboBox_parm_trace_param->setCurrentIndex(0);
        break;
    case 2:
        ui->checkBox_parm_trace->setChecked(true);
        ui->comboBox_parm_trace_iter->setCurrentIndex(0);
        ui->comboBox_parm_trace_param->setCurrentIndex(1);
        break;
    case 3:
        ui->checkBox_parm_trace->setChecked(true);
        ui->comboBox_parm_trace_iter->setCurrentIndex(1);
        ui->comboBox_parm_trace_param->setCurrentIndex(1);
        break;
    case 4:
        ui->checkBox_parm_trace->setChecked(true);
        ui->comboBox_parm_trace_iter->setCurrentIndex(1);
        ui->comboBox_parm_trace_param->setCurrentIndex(0);
        break;
    }
}

int file_widget::get_parmtr_write()
{
    int flag, ret;

    flag = ui->checkBox_parm_trace->isChecked()? 1: 0;
    flag += ui->comboBox_parm_trace_iter->currentIndex() * 2;
    flag += ui->comboBox_parm_trace_param->currentIndex() * 4;

    switch (flag)
    {
    case 1:
        ret = 1;
        break;
    case 3:
        ret = 4;
        break;
    case 5:
        ret = 2;
        break;
    case 7:
        ret = 3;
        break;
    default:
        ret = 0;
    }
    return ret;
}

void file_widget::set_cumrpt_write(int flag)
{
    switch (flag)
    {
    case 0:
        ui->checkBox_cumrpt_like->setChecked(false);
        ui->checkBox_cumrpt_fits->setChecked(false);
        break;
    case 1:
        ui->checkBox_cumrpt_like->setChecked(true);
        ui->checkBox_cumrpt_fits->setChecked(false);
        break;
    case 2:
        ui->checkBox_cumrpt_like->setChecked(true);
        ui->checkBox_cumrpt_fits->setChecked(true);
        break;
    }
}

int file_widget::get_cumrpt_write()
{
    int ret = 0;
    if (ui->checkBox_cumrpt_like->isChecked())
        ret = 1;
    if (ui->checkBox_cumrpt_fits->isChecked())
        ret = 2;
    return ret;
}

bool file_widget::read_files(ss_model *model_inf)
{
    bool okay = true;
    if (model_inf == NULL)
    {
        if (model_info == NULL)
            return false;
        else
            model_inf = model_info;
    }
    model_info->reset();

    okay = read_starter_file();
    if (okay)
    {
        setVersion (datafile_version);
        if (datafile_version < 3.30)
        {
            read32_dataFile(dataFile, model_info);
            read32_forecastFile(forecastFile, model_info);
            read32_controlFile(controlFile, model_info);
            if (ui->checkBox_par_file->isChecked())
            {
                read32_parameterFile(parameterFile, model_info);
            }
            if (ui->checkBox_pro_file->isChecked())
            {
                read32_profileFile(profileFile, model_info);
            }
        }
        else if (datafile_version < 3.40)
        {
            read33_dataFile(dataFile, model_info);
            read33_forecastFile(forecastFile, model_info);
            read33_controlFile(controlFile, model_info);
            if (ui->checkBox_par_file->isChecked())
            {
                read33_parameterFile(parameterFile, model_info);
            }
            if (ui->checkBox_pro_file->isChecked())
            {
                read33_profileFile(profileFile, model_info);
            }
        }

        read_run_num_file(QString ("%1/%2").arg
                           (current_dir_name, QString(RUN_NUMBER_FILE)));
    }
    return okay;
}


void file_widget::write_files()
{
    // only write ver 3.30 files
    setVersion(3.30, false);

    write_starter_file(ui->label_starter_file->text());
    if (datafile_version < 3.30)
    {
        write32_dataFile(dataFile, model_info);
        write32_forecastFile(forecastFile, model_info);
        write32_controlFile(controlFile, model_info);
        if (ui->checkBox_par_file->isChecked())
        {
            write32_parameterFile(parameterFile, model_info);
        }
        if (ui->checkBox_pro_file->isChecked())
        {
            reset_run_num();
            write32_profileFile(profileFile, model_info);
        }
    }
    else
    {
        write33_dataFile(dataFile, model_info);
        write33_forecastFile(forecastFile, model_info);
        write33_controlFile(controlFile, model_info);
        if (ui->checkBox_par_file->isChecked())
        {
            write33_parameterFile(parameterFile, model_info);
        }
        if (ui->checkBox_pro_file->isChecked())
        {
            reset_run_num();
            write33_profileFile(profileFile, model_info);
        }
    }

    write_run_num_file();
}

void file_widget::print_files()
{

}

void file_widget::read_comments(ss_file *in_file)
{
    QStringList cmts;
    QString line;
#ifdef DEBUG
    QString dbg_msg (QString("Reading file: %1 \n" ).arg(in_file->fileName()));
    error->write(dbg_msg.toAscii());
#endif
    cmts = in_file->read_comments();
    //in_file->comments.clear();
    line = in_file->read_line();
    while (line.startsWith("#C"))
    {
        error->write(line.toAscii());
        line.section('C', 1, -1);
        in_file->comments.append(line);
        line = in_file->read_line();
    }
}

void file_widget::write_comments(ss_file *out_file)
{
    QString line;
#ifdef DEBUG
    QString dbg_msg (QString("Writing file: %1 \n" ).arg(out_file->fileName()));
    error->writeline(dbg_msg);
#endif
    for (int i = 0; i < out_file->comments.count(); i++)
    {
        line = out_file->comments.at(i);
        error->write(line.toAscii());
        line.prepend("#C");
        out_file->writeline(line);
    }
}

bool file_widget::read_starter_file (QString filename)
{
    bool okay = true;
    QString token;// = in_file->get_next_token();
    float temp_float;
    int temp_int = 0;

    if (filename.isEmpty())
    {
        filename = ui->label_starter_file->text();
    }
    if (starterFile != NULL)
        delete starterFile;

    starterFile = new ss_file (filename, this);
    if (!starterFile->exists())
        okay = error_no_file(starterFile);
    if (okay)
        okay = starterFile->open(QIODevice::ReadOnly);

    if(okay)
    {
        starterFile->seek(0);
        starterFile->read_comments();

        token = starterFile->next_value("data file");
        data_file_name = token;
        set_data_file(QString("%1/%2").arg(current_dir_name, token));
        token = starterFile->next_value("control file");
        control_file_name = token;
        set_control_file(QString("%1/%2").arg(current_dir_name, token));
        token = starterFile->next_value("ss3.par choice");
        temp_int = token.toInt();
        set_par_file(temp_int != 0);
    //    ui->checkBox_par_file->setChecked(temp_int);
        token = starterFile->next_value("run display detail");
        temp_int = token.toInt();
        ui->comboBox_detail_level->setCurrentIndex(temp_int);
        token = starterFile->next_value("detail choice in Report.sso");
        temp_int = token.toInt();
        ui->checkBox_report->setChecked(temp_int);
        token = starterFile->next_value("write EchoInput.sso choice");
        temp_int = token.toInt();
        ui->checkBox_checkup->setChecked(temp_int);
        token = starterFile->next_value("what to write to ParmTrace.sso");
        temp_int = token.toInt();
        set_parmtr_write(temp_int);

        token = starterFile->next_value("what to write to CumReport.sso");
        temp_int = token.toInt();
        set_cumrpt_write(temp_int);
        token = starterFile->next_value("prior likelihood");
        temp_int = token.toInt();
        model_info->set_prior_likelihood (temp_int);
    //    ui->checkBox_prior_likelihood->setChecked(temp_int);
        token = starterFile->next_value("soft bounds");
        temp_int = token.toInt();
        model_info->set_use_softbounds(temp_int);
        token = starterFile->next_value("number of datafiles");
        temp_int = token.toInt();
        ui->spinBox_datafiles->setValue(temp_int);
        token = starterFile->next_value("last estimation phase");
        temp_int = token.toInt();
        model_info->set_last_estim_phase(temp_int);
        token = starterFile->next_value("MC burn interval");
        temp_int = token.toInt();
        model_info->set_mc_burn(temp_int);
        token = starterFile->next_value("MC thin interval");
        temp_int = token.toInt();
        model_info->set_mc_thin(temp_int);
        token = starterFile->next_value("jitter value");
        model_info->set_jitter_param(token.toDouble());
        token = starterFile->next_value("min year for sd reports");
        temp_int = token.toInt();
        model_info->set_bio_sd_min_year(temp_int);
        token = starterFile->next_value("max year for sd reports");
        temp_int = token.toInt();
        model_info->set_bio_sd_max_year(temp_int);
        token = starterFile->next_value("N individual sd years");
        temp_int = token.toInt();
        model_info->set_num_std_years(temp_int);
        for (int i = 0; i < model_info->num_std_years(); i++) // vector of year values
        {
            token = starterFile->next_value("sd year");
            model_info->set_std_year(i, token);
        }
        starterFile->skip_line();
    //    token = starter->next_value("blank");
        token = starterFile->next_value("convergence criteria");
        temp_int = token.toInt();
        model_info->set_convergence_criteria(token.toDouble());
        token = starterFile->next_value("retrospective year");
        temp_int = token.toInt();
        model_info->set_retrospect_year(temp_int);
        token = starterFile->next_value("biomass min age for calc");
        temp_int = token.toInt();
        model_info->set_biomass_min_age(temp_int);
        token = starterFile->next_value("depletion basis");
        temp_int = token.toInt();
        model_info->set_depletion_basis(temp_int);
        token = starterFile->next_value("depletion denominator");
        model_info->set_depletion_denom(token.toDouble());
        token = starterFile->next_value("SPR report basis");
        temp_int = token.toInt();
        model_info->set_spr_basis(temp_int);
        token = starterFile->next_value("F report units");
        temp_int = token.toInt();
        model_info->set_f_units(temp_int);
        // min and max age over which average F will be calculated with F_reporting=4
        if (model_info->f_units() == 4)
        {
            token = starterFile->next_value("F min age");
            temp_int = token.toInt();
            model_info->set_f_min_age(temp_int);
            token = starterFile->next_value("F max age");
            temp_int = token.toInt();
            model_info->set_f_max_age(temp_int);
        }
        token = starterFile->next_value("F std basis");
        temp_int = token.toInt();
        model_info->set_f_basis(temp_int);


        token = starterFile->next_value("check value for end of file");
        temp_float = get_version_number(token);
        if (temp_float != END_OF_DATA)
            datafile_version = temp_float;
        else
            datafile_version = 3.2;
        datafile_version += 0.00000001;
        ui->doubleSpinBox_version->setValue(datafile_version);

        starterFile->close();
        return okay;
    }
    else
    {
        error_unreadable(starter_file());
    }
    return okay;
}

void file_widget::write_starter_file (QString filename)
{
    QString line("");
    int temp_int = 0, chars = 0;

    if (filename.isEmpty())
        filename = ui->label_starter_file->text();

    if (!starterFile)
        starterFile = new ss_file (filename, this);
    else if (starterFile->fileName().compare(filename, Qt::CaseSensitive))
    {
        starterFile->setFileName(filename);
    }

    if(starterFile->open(QIODevice::WriteOnly))
    {
        chars += write_version_comment(starterFile);

        starterFile->write_comments();//write_comments(starter);

        line = QString (QString ("%1" ).arg(data_file_name));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1" ).arg(control_file_name));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # 0=use init values in control file; 1=use ss3.par" ).arg
                        (ui->checkBox_par_file->isChecked()?"1":"0"));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # run display detail (0,1,2)" ).arg
                        (QString::number(ui->comboBox_detail_level->currentIndex())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # detailed age-structured reports in REPORT.SSO (0,1)" ).arg
                        (ui->checkBox_report->isChecked()?"1":"0"));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # write detailed checkup.sso file (0,1)" ).arg
                        (ui->checkBox_checkup->isChecked()?"1":"0"));
        chars += starterFile->writeline (line);
        temp_int = 0;
    /*    if (ui->checkBox_parm_trace->isChecked())
        {
            int iter = ui->comboBox_parm_trace_iter->currentIndex();
            int parm = ui->comboBox_parm_trace_param->currentIndex();
            temp_int = (iter == 0)? ((parm == 0)? 1: 2) : ((parm == 0)? 4: 3);
        }*/
        temp_int = get_parmtr_write();
        line = QString (QString ("%1 # write parm values to ParmTrace.sso (0=no,1=good,active; 2=good,all; 3=every_iter,all_parms; 4=every,active)" ).arg
                        (QString::number(temp_int)));
        chars += starterFile->writeline (line);
        temp_int = get_cumrpt_write();
        line = QString (QString ("%1 # write to cumreport.sso (0=no,1=like&timeseries; 2=add survey fits)" ).arg
                        (QString::number(temp_int)));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # Include prior_like for non-estimated parameters (0,1)" ).arg
                        (model_info->prior_likelihood()?"1":"0"));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # Use Soft Boundaries to aid convergence (0,1) (recommended)" ).arg
                        (model_info->use_softbounds()?"1":"0"));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # Number of datafiles to produce: 1st is input, 2nd is estimates, 3rd and higher are bootstrap" ).arg
                        (QString::number(ui->spinBox_datafiles->value())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # Turn off estimation for parameters entering after this phase" ).arg
                        (QString::number(model_info->last_estim_phase())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # MCeval burn interval" ).arg
                        (QString::number(model_info->mc_burn())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # MCeval thin interval" ).arg
                        (QString::number(model_info->mc_thin())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # jitter initial parm value by this fraction" ).arg
                        (QString::number(model_info->jitter_param())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # min yr for sdreport outputs (-1 for styr)" ).arg
                        (QString::number(model_info->bio_sd_min_year())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # max yr for sdreport outputs (-1 for endyr; -2 for endyr+Nforecastyrs)" ).arg
                        (QString::number(model_info->bio_sd_max_year())));
        chars += starterFile->writeline (line);
        temp_int = model_info->num_std_years();
        line = QString (QString ("%1 # N individual STD years" ).arg
                        (QString::number(temp_int)));
        chars += starterFile->writeline (line);
        line = QString("#vector of year values " );
        line.append(model_info->get_std_years_text());
/*        for (int i = 0; i < model_info->num_std_years(); i++)
        {
            line.append(QString("%1 ").arg(QString::number(model_info->std_year(i))));
        }*/
        line.append('\n');
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # final convergence criteria (e.g. 1.0e-04)" ).arg
                        (QString::number(model_info->convergence_criteria())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # retrospective year relative to end year (e.g. -4)" ).arg
                        (QString::number(model_info->retrospect_year())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # min age for calc of summary biomass" ).arg
                        (QString::number(model_info->biomass_min_age())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # Depletion basis:  denom is: 0=skip; 1=rel X*B0; 2=rel X*Bmsy; 3=rel X*B_styr" ).arg
                        (QString::number(model_info->depletion_basis())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # Fraction (X) for Depletion denominator (e.g. 0.4)" ).arg
                        (QString::number(model_info->depletion_denom())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # SPR_report_basis:  0=skip; 1=(1-SPR)/(1-SPR_tgt); 2=(1-SPR)/(1-SPR_MSY); 3=(1-SPR)/(1-SPR_Btarget); 4=rawSPR" ).arg
                        (QString::number(model_info->spr_basis())));
        chars += starterFile->writeline (line);
        temp_int = model_info->f_units();
        line = QString (QString ("%1 # F_report_units: 0=skip; 1=exploitation(Bio); 2=exploitation(Num); 3=sum(Frates); 4=true F for range of ages" ).arg
                        (QString::number(temp_int)));
        chars += starterFile->writeline (line);
        line.clear();
        if (temp_int < 4)
        {
            line = QString ("#COND");
        }
        line.append(QString(" %1 %2 # min and max age over which average F will be calculated if F_report_units=4" ).arg
                    (QString::number(model_info->f_min_age()),
                     QString::number(model_info->f_max_age())));
        chars += starterFile->writeline (line);
        line = QString (QString ("%1 # F_report_basis: 0=raw; 1=F/Fspr; 2=F/Fmsy ; 3=F/Fbtgt" ).arg
                        (QString::number(model_info->f_basis())));
        chars += starterFile->writeline (line);

        if (datafile_version < 3.30)
            line = QString::number(END_OF_DATA);
        else
            line = QString::number(datafile_version, 'g');
        line.append(" # check value for end of file or version number" );
        chars += starterFile->writeline (line);

        starterFile->close();
    }
}


int file_widget::read_run_num_file (QString filename)
{
//    QString filename (ui->lineEdit_runnum_file->text());
    QString token;
//    float temp_float;
    int temp_int = 0;

    if (filename.isEmpty())
        filename = QString(QString("%1/%2").arg(current_dir_name, RUN_NUMBER_FILE));

    if (runNumberFile != NULL)
        delete runNumberFile;
    runNumberFile = new ss_file (filename, this);

    if(runNumberFile->open(QIODevice::ReadOnly))
    {
        token = runNumberFile->next_value();
        temp_int = token.toInt();
        model_info->set_run_number (temp_int);
        ui->label_run_num_val->setText(QString(" %1 ").arg(token));
    }
    runNumberFile->close();
    return 1;
}

void file_widget::reset_run_num()
{
    model_info->set_run_number(0);
    write_run_num_file();
    ui->label_run_num_val->setText(QString::number(0));
}

void file_widget::write_run_num_file (QString filename)
{
    int temp_int;
    QString line;
    if (filename.isEmpty())
        filename = QString("%1/%2").arg(current_dir_name, RUN_NUMBER_FILE);

    if (runNumberFile == NULL)
        runNumberFile = new ss_file (filename, this);
    else
        runNumberFile->setFileName(filename);

    if(runNumberFile->open(QIODevice::WriteOnly))
    {
        temp_int = model_info->run_number();
        line.append(QString("%1" ).arg(QString::number(temp_int)));
        runNumberFile->writeline(line);
    }
    runNumberFile->close();
}


void file_widget::show_file_info(ss_file *file)
{
    if (file != NULL)
    {
        file_info_dialog(file).exec();
    }
}

bool file_widget::error_no_file(ss_file *file)
{
    bool okay = true;
    QString fname;
    QString msg(QString("File %1 does not exist.\n").arg(file->fileName()));
    msg = tr(msg.toAscii());
    error->write(msg.toAscii()) ;
    msg.append(tr(" Do you want to select a new file?"));
    int btn = QMessageBox::critical((QWidget*)parent(), tr("File Read Error"), msg, QMessageBox::Cancel | QMessageBox::Ok);
    if (btn == QMessageBox::Ok)
    {
        fname = QFileDialog::getOpenFileName (this, tr("Select File"),
                           current_dir_name, tr("Stock Synthesis files (*.ss);;all files (*.*)"));
        file->setFileName(fname);
        if (file->exists())
            okay = true;
        else
            okay = false;
    }
    else
    {
        okay = false;
    }
    return okay;
}

void file_widget::error_unreadable(QString fname)
{
    QString msg (QString("File %1 is unreadable.\n").arg(fname));
    msg = tr(msg.toAscii());
    error->write (msg.toAscii()) ;
    QMessageBox::critical((QWidget*)parent(), tr("File Read Error"), msg, QMessageBox::Cancel | QMessageBox::Ok);
}

void file_widget::error_problem(ss_file *file)
{
    QString msg (QString("Problem in reading file %1, line %2.\n").arg(file->fileName(), QString::number(file->getLineNum())));
    msg = tr(msg.toAscii());
    error->write (msg.toAscii()) ;
    QMessageBox::critical((QWidget*)parent(), tr("File Read Error"), msg, QMessageBox::Cancel | QMessageBox::Ok);
}

QString file_widget::writeDatafileComment()
{
    QString line;
    line = QString (QString ("# File written by GUI for SS version %1x" ).arg (
                        QString::number(datafile_version, 'g', 3)));

    return line;
}

