#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "metadata.h"
#include "dialog_about_gui.h"
#include "dialog_about.h"
#include "dialog_about_admb.h"
#include "dialog_about_nft.h"
#include "dialog_run.h"
#include "documentdialog.h"


#include <QFileDialog>
#include <QMessageBox>
#include <QProcess>
#include <QDesktopServices>
#include <QUrl>
#include <QSettings>


MainWindow::MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::MainWindow)
{
#ifdef DEBUG
    QMessageBox::information(this, "Information - program flow", "Start main window widget set up.");
#endif
    // set up the ui
    ui->setupUi(this);
    setWindowTitle(tr(app_name));
    setWindowIcon(QIcon(":icons/StockSynth_icon_128.png"));

    readSettings();

    // set up information dock widget
    QFont title_font ("Tw Cen MT Condensed", 28, 4);
    title_font.setFamily("Arial");
    title_font.setBold(true);
    title_font.setPointSize(14);
    ui-> label_ss_ver->setFont(title_font);
    ui->label_ss_ver->setText(tr(app_name) + " " + getAppVersion());
    title_font.setPointSize(11);
    ui->label_gui_ver->setFont(title_font);
    ui->label_gui_ver->setText(tr("For use with Stock Synthesis ") + getAppAppliesTo());

    connect (ui->pushButton_about_gui, SIGNAL(clicked()), SLOT(helpGUI()));
    connect (ui->pushButton_about_ss, SIGNAL(clicked()), SLOT(helpSS()));
    connect (ui->pushButton_about_ftb, SIGNAL(clicked()), SLOT(helpNFT()));
    connect (ui->pushButton_about_admb, SIGNAL(clicked()), SLOT(helpADMB()));
    connect (ui->pushButton_about_qt, SIGNAL(clicked()), SLOT(helpQt()));
    connect (ui->actionTitle_Window, SIGNAL(toggled(bool)), ui->dockWidget_help, SLOT(setVisible(bool)));
    connect (ui->dockWidget_help, SIGNAL(visibilityChanged(bool)), ui->actionTitle_Window, SLOT(setChecked(bool)));
#ifdef DEBUG
    QMessageBox::information(this, "Information - program flow", "Help window set up finished.");
#endif

    // set up the default model
    model_one = new ss_model(this);
#ifdef DEBUG
    QMessageBox::information(this, "Information - program flow", "Model data set up finished.");
#endif

    // furnish the ui with the default model
    files = new file_widget (model_one, this);
    data = new data_widget(model_one, this);
    forecast = new forecast_widget(model_one, this);
    fleets = new fleet_widget(model_one, this);
    population = new population_widget(model_one, this);
#ifdef DEBUG
    QMessageBox::information(this, "Information - program flow", "Widget set up finished.");
#endif

    connect (files, SIGNAL(save_data_file()), SLOT(saveDataFile()));
    connect (files, SIGNAL(choose_data_file()),SLOT(openDataFile()));
    connect (files, SIGNAL(save_control_file()), SLOT(saveControlFile()));
    connect (files, SIGNAL(choose_control_file()), SLOT(openControlFile()));

    connect (ui->action_New, SIGNAL(triggered()), SLOT(createNewDirectory()));
    connect (ui->action_Open, SIGNAL(triggered()), SLOT(openDirectory()));
    connect (ui->action_Save_data, SIGNAL(triggered()), SLOT(saveFiles()));
    connect (ui->action_Exit, SIGNAL(triggered()), SLOT(close()));

    connect (ui->actionAbout_SS_GUI, SIGNAL(triggered()), SLOT(helpGUI()));
    connect (ui->action_About, SIGNAL(triggered()), SLOT(helpSS()));
    connect (ui->action_About_NFT, SIGNAL(triggered()), SLOT(helpNFT()));
    connect (ui->action_User_Manual, SIGNAL(triggered()), SLOT(show_manual()));
    connect (ui->action_Using_SS, SIGNAL(triggered()), SLOT(show_using()));
    connect (ui->action_About_ADMB, SIGNAL(triggered()), SLOT(helpADMB()));
    connect (ui->action_About_Qt, SIGNAL(triggered()), SLOT(helpQt()));

    connect (ui->action_Files, SIGNAL(triggered()), SLOT (showFiles()));
    connect (ui->action_Model_Data, SIGNAL(triggered()), SLOT(showModel()));
    connect (ui->action_Forecast, SIGNAL(triggered()), SLOT(showForecast()));
    connect (ui->action_Fleets, SIGNAL(triggered()), SLOT(showFisheries()));
    connect (ui->action_Populations, SIGNAL(triggered()), SLOT(showPopulations()));

    connect (ui->action_IncreaseFont, SIGNAL(triggered()), SLOT(increase_font()));
    connect (ui->action_DecreaseFont, SIGNAL(triggered()), SLOT(decrease_font()));

    connect (ui->action_Run_Stock_Synthesis, SIGNAL(triggered()), SLOT(run()));

    connect (ui->action_Locate_SS, SIGNAL(triggered()), SLOT(locateDirectory()));
    connect (ui->actionLocate_SS_executable, SIGNAL(triggered()), SLOT(locateExecutable()));
    connect (ui->actionLocate_documents, SIGNAL(triggered()), SLOT(locateDocuments()));
    connect (ui->actionSelect_default_directory, SIGNAL(triggered()), SLOT(locateDirectory()));

    connect (data, SIGNAL(showLengthObs()), SLOT(showLengthObs()));
    connect (data, SIGNAL(showAgeObs()), SLOT(showAgeObs()));
    connect (data, SIGNAL(showSAAObs()), SLOT(showMeanSAAObs()));
    connect (data, SIGNAL(showGenObs(int)), SLOT(showGenSizeObs(int)));
    connect (data, SIGNAL(showMorphObs()), SLOT(showMorphObs()));
    connect (data, SIGNAL(showRecapObs()), SLOT(showRecapObs()));

    ui->stackedWidget->setCurrentIndex(FILES);
    ui->stackedWidget->currentWidget()->layout()->addWidget(files);
    ui->stackedWidget->setCurrentIndex(MODEL);
    ui->stackedWidget->currentWidget()->layout()->addWidget(data);
    ui->stackedWidget->setCurrentIndex(FORECAST);
    ui->stackedWidget->currentWidget()->layout()->addWidget(forecast);
    ui->stackedWidget->setCurrentIndex(FLEETS);
    ui->stackedWidget->currentWidget()->layout()->addWidget(fleets);
    ui->stackedWidget->setCurrentIndex(POPULATION);
    ui->stackedWidget->currentWidget()->layout()->addWidget(population);
    showFiles();

    main_font = QFont("Arial", 12);
}

MainWindow::~MainWindow()
{
    delete files;
    delete data;
    delete forecast;
    delete fleets;
    delete population;
    delete model_one;
    delete ui;
}

void MainWindow::closeEvent(QCloseEvent *event)
{
    writeSettings();
    event->accept();
}

void MainWindow::writeSettings()
{
    QSettings settings(app_copyright_org, app_name);

    settings.beginGroup("MainWindow");
    settings.setValue("size", size());
    settings.setValue("pos", pos());
    settings.setValue("defaultDir", default_dir);
    settings.setValue("executable", ss_executable);
    settings.endGroup();
    settings.beginGroup ("HelpWindow");
    settings.setValue("size", ui->dockWidget_help->size());
    settings.setValue("pos", ui->dockWidget_help->pos());
    settings.setValue("visible", ui->dockWidget_help->isVisible());
    settings.endGroup();
}

void MainWindow::readSettings()
{
    QSettings settings(app_copyright_org, app_name);
    QString dir (qApp->applicationDirPath());
    QString exe (dir + "/ss3.exe");
    settings.beginGroup("MainWindow");
    resize(settings.value("size", QSize(700, 600)).toSize());
    move(settings.value("pos", QPoint(200, 200)).toPoint());
    default_dir = settings.value("defaultDir", dir).toString();
    current_dir = default_dir;
    ss_executable = settings.value("executable", exe).toString();
    settings.endGroup();
    settings.beginGroup("HelpWindow");
    ui->dockWidget_help->resize(settings.value("size").toSize());
    ui->dockWidget_help->move(settings.value("pos", QPoint(300,300)).toPoint());
    ui->dockWidget_help->setVisible(settings.value("visible", true).toBool());
    settings.endGroup();
}

void MainWindow::createNewDirectory()
{
    int btn =
    QMessageBox::question(this, tr("Select New Directory"),
             tr("This will over-write any duplicate files in the selected directory.\nDo you wish to continue?"),
                          QMessageBox::Yes, QMessageBox::No);
    if (btn == QMessageBox::Yes)
    {
        QString newdir(QFileDialog::getExistingDirectory(this, tr("Select New Directory"),
                                    current_dir, QFileDialog::ShowDirsOnly));
        if (!newdir.isEmpty() && newdir != current_dir)
        {
            current_dir = newdir;
            files->new_directory(current_dir, true);
            saveFiles();
        }
    }
}

void MainWindow::openDirectory(QString fname)
{
    QString title;
    QFileInfo start_file;
    bool repeat = true;
    title = QString ("Select Starter File");
    do
    {
        if (fname.isEmpty())
            fname = QFileDialog::getOpenFileName (this, tr(title.toAscii()),
                               current_dir, tr("Starter files (starter.ss)"));

        files->set_starter_file(fname);

        start_file = QFileInfo(files->starter_file());
        if (start_file.isReadable())
            repeat = false;
        else
        {
            int btn;
            repeat = true;
            fname.clear();
            title = QString("Invalid Starter File - Select File");
            btn = QMessageBox::question (this, tr("Unreadable file"),
                 tr("starter.ss is unreadable. Do you wish to select another file?"),
                  QMessageBox::Yes, QMessageBox::No);
            if (btn == QMessageBox::No)
                repeat = false;
        }
     }while (repeat);

    if (!files->starter_file().isEmpty())
    {
        current_dir = start_file.absolutePath();
        QDir::setCurrent(current_dir);
        files->new_directory(current_dir);
        readFiles();
    }
}

void MainWindow::openControlFile()
{
    QString fname (QFileDialog::getOpenFileName (this, tr("Select Control File"),
        current_dir, tr("ctl files (*.ctl);;SS files (*.ss);;all files (*.*)")));
    if (!fname.isEmpty())
    {
        files->set_control_file(fname);
        readFiles();
    }
}

void MainWindow::saveControlFile()
{
    QString fname = files->control_file();
    fname = QFileDialog::getSaveFileName(this, tr("Select Control File"),
            current_dir, tr("data files (*.ctl);;SS files (*.ss);;all files (*.*)"));
    if (!fname.isEmpty())
    {
        files->set_control_file(fname);
        saveFiles();
    }
}

void MainWindow::openDataFile()
{
    QString fname (QFileDialog::getOpenFileName (this, tr("Select Data File"),
        current_dir, tr("data files (*.dat);;SS files (*.ss);;all files (*.*)")));
    if (!fname.isEmpty())
    {
        files->set_data_file(fname);
        readFiles();
    }
}

void MainWindow::saveDataFile()
{
    QString fname = files->data_file();
    fname = QFileDialog::getSaveFileName(this, tr("Select Data File"),
            current_dir, tr("data files (*.dat);;SS files (*.ss);;all files (*.*)"));
    if (!fname.isEmpty())
    {
        files->set_data_file(fname);
        saveFiles();
    }
}

void MainWindow::readFiles()
{
    bool worked = true;
//    files->set_default_file_names(current_dir);
    model_one->reset();
    worked = files->read_files(model_one);
    if (worked)
    {
        data->refresh();
        forecast->refresh();
        fleets->refresh();
        population->refresh();
    }
    else
        close();
}

void MainWindow::saveFiles()
{
    files->write_files ();
}

void MainWindow::printFiles()
{
    files->print_files ();
}

void MainWindow::showFiles()
{
    set_checks_false();
    ui->stackedWidget->setCurrentIndex(FILES);
    ui->action_Files->setChecked(true);
    files->show_input_files();
}

void MainWindow::showModel()
{
    set_checks_false();
    ui->stackedWidget->setCurrentIndex(MODEL);
    ui->action_Model_Data->setChecked(true);

}

void MainWindow::showForecast()
{
    set_checks_false();
    ui->stackedWidget->setCurrentIndex(FORECAST);
    ui->action_Forecast->setChecked(true);
}

void MainWindow::showParameters()
{
    set_checks_false();
    ui->stackedWidget->setCurrentIndex(PARAMETERS);
    ui->action_View_parameter_list->setChecked(true);
}

void MainWindow::showPopulations()
{
    set_checks_false();
    ui->stackedWidget->setCurrentIndex(POPULATION);
    ui->action_Populations->setChecked(true);
}

void MainWindow::showSurveys()
{
    set_checks_false();
//    ui->stackedWidget->setCurrentIndex(SURVEYS);
    ui->action_Surveys->setChecked(true);
}

void MainWindow::showFisheries()
{
    set_checks_false();
    ui->stackedWidget->setCurrentIndex(FLEETS);
    ui->action_Fleets->setChecked(true);
}

void MainWindow::helpGUI()
{
    Dialog_about_gui *about = new Dialog_about_gui (this);
    QString title(QString("%1 %2").arg(
                      tr("About"), getAppName()));
    about->setWindowTitle(title);
    connect (about, SIGNAL(showAboutSS()), SLOT(helpSS()));
    connect (about, SIGNAL(showAboutQt()), SLOT(helpQt()));

    about->exec();
    delete about;
}

void MainWindow::helpSS()
{
    Dialog_about *about = new Dialog_about (this);
    QString title(QString("%1 %2").arg(
                      tr("About"), tr("Stock Synthesis")));
    about->setWindowTitle(title);
    connect (about, SIGNAL(show_manual()), SLOT(show_manual()));
    connect (about, SIGNAL(show_webpage(QString)), SLOT(show_webpage(QString)));

    about->exec();
    delete about;
}

void MainWindow::helpNFT()
{
    Dialog_About_NFT *about_NFT = new Dialog_About_NFT (this);
    QString title(tr("About NOAA Fisheries Toolbox"));
    about_NFT->setWindowTitle(title);
    connect (about_NFT, SIGNAL(show_webpage(QString)), SLOT(show_webpage(QString)));

    about_NFT->exec();
    delete about_NFT;
}

void MainWindow::helpADMB()
{
    Dialog_About_ADMB *about_admb = new Dialog_About_ADMB (this);
    QString title (tr("About ADMB"));
    about_admb->setWindowTitle(title);
    connect (about_admb, SIGNAL(show_webpage(QString)), SLOT(show_webpage(QString)));

    about_admb->exec();
    delete about_admb;
}

void MainWindow::helpQt()
{
    QMessageBox::aboutQt (this, tr("About the Qt toolkit"));
}

void MainWindow::showLengthObs()
{
    showFisheries();
    fleets->showLengthObs();
}

void MainWindow::showAgeObs()
{
    showFisheries();
    fleets->showAgeObs();
}

void MainWindow::showMeanSAAObs()
{
    showFisheries();
    fleets->showMeanSAAObs();
}

void MainWindow::showGenSizeObs(int index)
{
    showFisheries();
    fleets->showGenSizeObs(index);
}

void MainWindow::showMorphObs()
{
    showFisheries();
    fleets->showMorphObs();
}

void MainWindow::showRecapObs()
{
    showFisheries();
    fleets->showRecapObs();
}

void MainWindow::show_manual()
{
    QDir appdir (qApp->applicationDirPath());
    QStringList filter(QString("*.pdf"));
    QStringList files;
    QProcess *process = new QProcess (this);
    QString filename;
    QString command;
    QFileInfo qf;
    QSettings settings (app_copyright_org, app_name);
    settings.beginGroup("Documents");
    filename = settings.value("manual", QString("")).toString();

    if (filename.isEmpty())
    {
        // search application dir
        files.append(appdir.entryList(filter, QDir::Files, QDir::Name));
        for (int i = 0; i < files.count(); i++)
            if (files.at(i).startsWith("SS_User_Manual"))
                filename = files[i];
        filename.prepend(QString("%1/").arg(appdir.absolutePath()));
    }
    qf = QFileInfo(filename);

    if (!qf.exists())
    {
        // dialog asking to find
        QString msg (tr("The User Manual document was not found.\n"));
        msg.append  (tr("Would you like to find the document?"));
        QMessageBox::StandardButton btn = QMessageBox::information(this,
            tr("File Not Found"), msg, QMessageBox::Yes | QMessageBox::No);
        // file open dialog
        if (btn == QMessageBox::Yes)
        {
            filename = (QFileDialog::getOpenFileName (this, tr("Select File"),
                   qApp->applicationDirPath(), tr("documentation files (*.pdf)")));
        }
        qf = QFileInfo(filename);
    }

    // if okay file, show it in a pdf reader
    if (qf.exists())
    {
        settings.setValue("manual", filename);
        command = QString("cmd /k %1").arg(filename);
        process->start(command);
    }
    settings.endGroup();
}

void MainWindow::show_using()
{
    QDir appdir (qApp->applicationDirPath());
    QStringList filter(QString("*.pdf"));
    QStringList files;
    QProcess *process = new QProcess (this);
    QString filename;
    QString command;
    QFileInfo qf;
    QSettings settings (app_copyright_org, app_name);
    settings.beginGroup("Documents");
    filename = settings.value("technical", QString("")).toString();

    if (filename.isEmpty())
    {
        // search application dir
        files.append(appdir.entryList(filter, QDir::Files, QDir::Name));
        for (int i = 0; i < files.count(); i++)
            if (files.at(i).startsWith("SS_technical"))
                filename = files[i];
        filename.prepend(QString("%1/").arg(appdir.absolutePath()));
    }
    qf = QFileInfo(filename);

    if (!qf.exists())
    {
        // dialog asking to find
        QString msg (tr("The Technical Description document was not found.\n"));
        msg.append  (tr("Would you like to find the document?"));
        QMessageBox::StandardButton btn = QMessageBox::information(this,
            tr("File Not Found"), msg, QMessageBox::Yes | QMessageBox::No);
        // file open dialog
        if (btn == QMessageBox::Yes)
        {
            filename = (QFileDialog::getOpenFileName (this, tr("Select File"),
                appdir.absolutePath(), tr("documentation files (*.pdf)")));
        }
        qf = QFileInfo(filename);
    }

    // if okay file, show it in a pdf reader
    if (qf.exists())
    {
        settings.setValue("technical", filename);
        command = QString("cmd /k %1").arg(filename);
        process->start(command);
    }
    settings.endGroup();
}

void MainWindow::show_webpage(QString pg)
{
    QDesktopServices web;
    web.openUrl(QUrl(pg));
}

void MainWindow::run()
{
    Dialog_run drun(this);
    drun.setDir(current_dir);
    drun.setExe(ss_executable);
    drun.exec();

}

void MainWindow::locateDirectory()
{
    QSettings settings (app_copyright_org, app_name);
    QString newdir(QFileDialog::getExistingDirectory(this, tr("Select New Directory"),
                                current_dir, QFileDialog::ShowDirsOnly));
    if (!newdir.isEmpty())
        default_dir = newdir;
    settings.beginGroup("MainWindow");
    settings.setValue ("defaultDir", default_dir);
    settings.endGroup();
}

void MainWindow::locateDocuments()
{
    QSettings settings (app_copyright_org, app_name);
    documentDialog dd (this);
    dd.exec();
}

void MainWindow::locateExecutable()
{
    // locate ss??.exe
    QSettings settings (app_copyright_org, app_name);
    QString filename (findFile ("Executable", "applications (*.exe)"));
    if (!filename.isEmpty())
        ss_executable = filename;
    settings.beginGroup("MainWindow");
    settings.setValue("executable", filename);
    settings.endGroup();
}

QString MainWindow::findFile(QString title, QString filters)
{
    QString filename ("");
    QString str (QString ("Select %1 File").arg(title));

    filename = (QFileDialog::getOpenFileName (this, tr(str.toAscii()),
        current_dir, tr(filters.toAscii())));

    return filename;
}


void MainWindow::change_control_file(QString fname)
{
}

void MainWindow::change_data_file(QString fname)
{
    if (data_file.compare(fname) != 0)
    {
        data_file = fname;
    }
}

void MainWindow::writeDataFile()
{
}

void MainWindow::writeParamFile()
{

}

void MainWindow::writeProfileFile()
{

}

void MainWindow::set_start_age_rept(bool flag)
{
}

void MainWindow::set_start_use_values(int flag)
{
}

int MainWindow::ask_missing_file(QString fn)
{
    QMessageBox mbox (this);
    int btn;
    QString query("Starter.ss file is not found in this directory or is not readable. \n");
    query.append("Do you wish to create a new one?");
    mbox.setWindowTitle("Missing File");
    mbox.setText(query);
    mbox.setStandardButtons(QMessageBox::Yes |
                            QMessageBox::No |
                            QMessageBox::Cancel);
    btn = mbox.exec();
    return btn;
}

void MainWindow::increase_font ()
{
    int f_size = main_font.pointSize();
    if (f_size < 24)
    {
        f_size += 2;
        main_font.setPointSize(f_size);
        setFont(main_font);
    }
}

void MainWindow::decrease_font()
{
    int f_size = main_font.pointSize();
    if (f_size > 12)
    {
        f_size -= 2;
        main_font.setPointSize(f_size);
        setFont(main_font);
    }
}
/*
void MainWindow::read_runnumber()
{
    files->read_run_num_file();
}*/

void MainWindow::set_checks_false()
{
    ui->action_Files->setChecked(false);
    ui->action_Model_Data->setChecked(false);
    ui->action_Observed_data->setChecked(false);
    ui->action_Forecast->setChecked(false);
    ui->action_Fleets->setChecked(false);
    ui->action_Surveys->setChecked(false);
    ui->action_Populations->setChecked(false);
}
