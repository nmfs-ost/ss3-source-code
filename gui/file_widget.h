#ifndef FILE_WIDGET_H
#define FILE_WIDGET_H

#include <QWidget>
#include <QDir>

#include "input_file.h"
#include "model.h"
#include "composition.h"
#include "tableview.h"
#include "catchdelegate.h"

// standard input file names
#define STARTER_FILE      "starter.ss"
#define FORECAST_FILE     "forecast.ss"
#define PARAMETER_FILE    "ss3.par"
#define PROFILE_VAL_FILE  "ProfileValues.ss"
#define RUN_NUMBER_FILE   "runnumber.ss"
// default input file names
#define DATA_FILE         "datafile.dat"
#define CONTROL_FILE      "controlfile.ctl"

// standard output file names
#define CHECKUP_FILE      "checkup.sso"
#define COMP_REPORT_FILE  "CompReport.sso"
#define COVAR_FILE        "covar.sso"
#define CUM_REPORT_FILE   "CumReport.sso"
#define DERIVED_POST_FILE "derived_posteriors.sso"
#define ECHOED_INPUT_FILE "echoinput.sso"
#define FCAST_REPORT_FILE "ForecastReport.sso"
#define PARAM_TRACE_FILE  "ParmTrace.sso"
#define POST_VECTOR_FILE  "posterior_vectors.sso"
#define POSTERIORS_FILE   "posteriors.sso"
#define REBUILD_FILE      "rebuild.sso"
#define REPORT_FILE       "Report.sso"
#define SIS_OUTPUT_FILE   "SIS_table.sso"
#define SS_WARNING_FILE   "warning.sso"

#define ERROR_FILE        "/ss_error.txt"

namespace Ui {
class file_widget;
}

class file_widget : public QWidget
{
    Q_OBJECT

public:
//    file_widget(QWidget *parent = 0);
    explicit file_widget (ss_model *mod = 0, QWidget *parent = 0);
    ~file_widget();

    void reset();
    QString writeDatafileComment();

private:
    Ui::file_widget *ui;

    ss_model *model_info;
    QDir current_dir;
    QString current_dir_name;

    ss_file *starterFile;
    ss_file *dataFile;
    ss_file *forecastFile;
    ss_file *controlFile;
    ss_file *runNumberFile;
    ss_file *parameterFile;
    ss_file *profileFile;
    ss_file *userDataFile;

    QString control_file_name;
    QString data_file_name;

    float datafile_version;
    QFile *error;

    Fleet *getActiveFleet (int index, Fleet::FleetType type);

public slots:
    void set_starter_file (QString fname, bool keep = false);
    QString starter_file();
    void set_forecast_file (QString fname, bool keep = false);
    QString forecast_file ();
    void set_control_file (QString fname, bool keep = false);
    QString control_file ();
    void set_data_file (QString fname, bool keep = false);
    QString data_file ();
    QString param_file ();
    QString profile_file ();
    QString run_num_file ();

    ss_model *this_model() {return model_info;}

    void setVersion(double ver, bool flag = true);

    void increase_font();
    void decrease_font();

    void set_default_file_names (QString dir, bool keep = false);
    void new_directory (QString dir, bool keep = false);
    bool read_files(ss_model *model_inf = NULL);

    void read_comments (ss_file *file);
    void write_comments (ss_file *file);

    bool read_starter_file(QString filename = QString(""));
//    int read_m_data_file (QString filename = QString(""));
//    int read_forecast_file (QString filename = QString(""));
//    int read_control_file (QString filename = QString(""));
//    int read_params_file (QString filename = QString(""));
//    int read_u_data_file (QString filename = QString(""));
    int read_run_num_file (QString filename = QString(""));
//    int read_profile_file (QString filename = QString(""));

    void write_files ();

    void write_starter_file (QString filename = QString(""));
//    void write_m_data_file (QString filename = QString(""));
//    void write_forecast_file (QString filename = QString(""));
//    void write_control_file (QString filename = QString(""));
//    void write_params_file (QString filename = QString(""));
//    void write_u_data_file (QString filename = QString(""));
    void write_run_num_file (QString filename = QString(""));
//    void write_profile_file (QString filename = QString(""));

    void print_files ();

    void set_par_file (bool flag);
    void set_par_file (QString fname, bool keep = false);
    void set_pro_file (bool flag);
    void set_pro_file (QString fname, bool keep = false);
    void set_parmtr_write(int flag = 0);
    int get_parmtr_write ();
    void set_cumrpt_write(int flag = 0);
    int get_cumrpt_write ();

    void show_input_files ();
    void show_output_files ();

signals:
    void directory_changed (QString dirname);
    void starter_file_changed (QString fname);
    void forecast_file_changed (QString fname);
    void control_file_changed (QString fname);
    void data_file_changed (QString fname);
    void choose_control_file();
    void save_control_file();
    void choose_data_file();
    void save_data_file();


private slots:
    float get_version_number(QString token);

    void parm_trace_changed(bool flag);
    void cumrpt_fits_changed(bool flag);
    void cumrpt_like_changed(bool flag);

    void show_file_info (ss_file *file);
    void show_starter_file_info () {show_file_info (starterFile);}
    void show_forecast_file_info () {show_file_info (forecastFile);}
    void show_data_file_info () {show_file_info (dataFile);}
    void show_control_file_info () {show_file_info (controlFile);}
    void show_param_file_info () {show_file_info (parameterFile);}
    void show_prof_file_info () {show_file_info (profileFile);}

//    ssObservation* read_environ_var_observation (ss_file *model_dat);

//    int write_environ_var_observation (ssObservation *obs);

    void reset_run_num ();

    bool error_no_file (ss_file *file);
    void error_unreadable (QString fname);
    void error_problem (ss_file *file);
};

#endif // FILE_WIDGET_H
