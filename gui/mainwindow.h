#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QMessageBox>
#include <QString>
#include <QDir>

#include "file_widget.h"
#include "data_widget.h"
#include "forecast_widget.h"
#include "fleet_widget.h"

#include "population_widget.h"
#include "model.h"

#define DEBUG 1

#undef DEBUG

namespace Ui {
class MainWindow;
}


class MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit MainWindow(QWidget *parent = 0);
    ~MainWindow();

    void closeEvent(QCloseEvent *event);
    void readSettings();
    void writeSettings();

    void read_starter_file(ss_file *ifile, ss_model *modl);
    void read_forecast_file();
    void read_control_file();
    void read_data_file();
    void read_param_file();
    void read_profile_file();

    void writeForecastFile();
    void writeStarterFile();
    void writeControlFile();
    void writeDataFile();
    void writeParamFile();
    void writeProfileFile();

    
public slots:
    void createNewDirectory();
    void openDirectory(QString fname = QString(""));
    void openControlFile();
    void saveControlFile();
    void openDataFile();
    void saveDataFile();
    void readFiles ();
    void saveFiles ();
    void printFiles();
    void helpGUI();
    void helpSS();
    void helpNFT();
    void helpADMB();
    void helpQt();
    void run();

    void change_data_file (QString fname);
    void change_control_file (QString fname);

    void showLengthObs();
    void showAgeObs();
    void showMeanSAAObs();
    void showGenSizeObs(int index);
    void showMorphObs();
    void showRecapObs();

    void show_manual ();
    void show_using ();
    void show_webpage (QString pg);
    void locateDirectory ();
    void locateDocuments ();
    void locateExecutable ();
    QString findFile (QString title, QString filters);

signals:

private:
    Ui::MainWindow *ui;

    ss_model *model_one;
    file_widget *files;
    data_widget *data;
    forecast_widget *forecast;
    fleet_widget *fleets;
    population_widget *population;

    void set_checks_false();

    enum {
        FILES = 0,
        MODEL,
        FORECAST,
        PARAMETERS,
        POPULATION,
        FLEETS
    };

//    QDir current_dir;
    QFont main_font;

//    starter_widget *starter_info;
//    forecast_widget *forecast_info;
//    control_widget *control_info;
//    data_widget *data_info;

    QString current_dir;
    QString starter_file;
    QString control_file;
    QString forecast_file;
    QString data_file;
    QString parameter_file;
    QString profile_file;
    QString run_num_file;

    QString ss_executable;
    QString default_dir;

private slots:
    void showFiles();
    void showModel();
    void showForecast();
    void showParameters();
    void showPopulations();
    void showFisheries();
    void showSurveys();

    int ask_missing_file(QString fn);
    void set_start_age_rept(bool flag);
    void set_start_use_values(int flag);
    void increase_font();
    void decrease_font();

//    void read_runnumber();
};

#endif // MAINWINDOW_H
