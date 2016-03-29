#include "dialog_run.h"
#include "ui_dialog_run.h"
#include "dialog_view.h"
#include "dialog_fileview.h"

#include <QProcess>
#include <QDebug>

Dialog_run::Dialog_run(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_run)
{
    ui->setupUi(this);
    ui->pushButton_pause->setVisible(false);
    ui->plainTextEdit_output->setCenterOnScroll(true);

    warnview = new Dialog_fileView(this);//("Warning.sso", this);
    warnview->hide();

    connect (ui->pushButton_run, SIGNAL(clicked()), SLOT(startRun()));
    connect (ui->pushButton_pause, SIGNAL(clicked()), SLOT(pauseRun()));
    connect (ui->pushButton_stop, SIGNAL(clicked()), SLOT(stopRun()));
    connect (ui->pushButton_cancel, SIGNAL(clicked()), SLOT(rejected()));
    connect (ui->pushButton_showWarn, SIGNAL(clicked()), SLOT(showWarnFile()));

    stocksynth = new QProcess(this);
    connect (stocksynth, SIGNAL(started()), SLOT(runStarted()));
    connect (stocksynth, SIGNAL(readyReadStandardOutput()), SLOT(stdOutput()));
    connect (stocksynth, SIGNAL(readyReadStandardError()), SLOT(stdError()));
    connect (stocksynth, SIGNAL(finished(int)), SLOT(runCompleted(int)));

    ui->pushButton_run->setEnabled(true);
    ui->pushButton_pause->setEnabled(false);
    ui->pushButton_stop->setEnabled(false);
}

Dialog_run::~Dialog_run()
{
    delete ui;
    delete stocksynth;
}

void Dialog_run::showWarnFile()
{
    warnview->viewFile("warning.sso");
    warnview->show();
}

void Dialog_run::runSS()
{
    QString ss3(ui->label_executable->text());
    QString opts(ui->lineEdit_options->text());
    QString line;
    QStringList arguments;

    QString cmd("cmd.exe /k");

    line = QString (QString("%1 %2\n").arg(ss3, opts));
    ui->plainTextEdit_output->appendPlainText(line);
    // run command in box
//    arguments = line.split(' ');
//    stocksynth->start(cmd);//, arguments);
//    stocksynth->write(line);
//    stocksynth->closeWriteChannel();
    arguments = opts.split(' ', QString::SkipEmptyParts);
    stocksynth->start(line, QIODevice::ReadOnly);
}

void Dialog_run::runStarted()
{
    ui->pushButton_pause->setEnabled(true);
    ui->pushButton_stop->setEnabled(true);
    setUiEnabled(false);
    running = true;
}

void Dialog_run::finishOutput()
{
    running = false;
}

void Dialog_run::runCompleted(int code)
{
    QString message;

    while (stocksynth->canReadLine())
    {
        output = stocksynth->readLine(BUFFER_SIZE);
        ui->plainTextEdit_output->appendPlainText(output.left(output.indexOf('\n')));
    }

    setUiEnabled(true);
    if (code)
    {
        QProcess::ProcessError err = stocksynth->error();
        switch (err)
        {
        case QProcess::FailedToStart:
            message = QString ("Stock Synthesis failed to start\n");
            break;
        case QProcess::Crashed:
            message = QString ("Stock Synthesis crashed.\n");
            break;
        case QProcess::Timedout:
            message = QString ("Stock Synthesis timed out.\n");
            break;
        case QProcess::ReadError:
            message = QString ("Error reading output from Stock Synthesis.\n");
            break;
        case QProcess::UnknownError:
        default:
            message = QString ("Unknown error running Stock Synthesis.\n");
        }
    }
    else
    {
        message = QString("Stock Synthesis executed with no errors.\n");
    }
    ui->plainTextEdit_error->insertPlainText(message);
    ui->plainTextEdit_error->scroll(0,1);

    ui->pushButton_run->setEnabled(true);
    ui->pushButton_pause->setEnabled(false);
    ui->pushButton_stop->setEnabled(false);
}

void Dialog_run::startRun()
{
    ui->pushButton_run->setEnabled(false);
    ui->pushButton_pause->setEnabled(true);
    ui->pushButton_stop->setEnabled(true);
    runSS();
}

void Dialog_run::pauseRun()
{
    stocksynth->write("\0x18");
    ui->pushButton_run->setEnabled(true);
    ui->pushButton_pause->setEnabled(false);
    ui->pushButton_stop->setEnabled(true);
}

void Dialog_run::stopRun()
{
    stocksynth->kill();
    ui->pushButton_run->setEnabled(true);
    ui->pushButton_pause->setEnabled(false);
    ui->pushButton_stop->setEnabled(false);
}

void Dialog_run::rejected()
{
    reject();
}

void Dialog_run::setDir(QString dir)
{
    QString warnfile(dir + QChar('/') + QString("Warning.sso"));
    stocksynth->setWorkingDirectory(dir);
    ui->label_directory->setText(dir);
}

void Dialog_run::setExe(QString exe)
{
    ui->label_executable->setText(exe);
}

void Dialog_run::stdOutput()
{
    while (stocksynth->canReadLine())
    {
        output = stocksynth->readLine(BUFFER_SIZE);
        ui->plainTextEdit_output->appendPlainText(output.left(output.indexOf('\n')-1));
    }
}

void Dialog_run::stdError()
{
    QString message = stocksynth->readAllStandardError();
    ui->plainTextEdit_error->insertPlainText(message);
}

void Dialog_run::setUiEnabled(bool flag)
{
    ui->pushButton_cancel->setEnabled(flag);
    ui->pushButton_showWarn->setEnabled(flag);
    ui->lineEdit_options->setEnabled(flag);
}

void Dialog_run::outputLine()
{
    QString line(stocksynth->readLine(BUFFER_SIZE));
    ui->plainTextEdit_output->appendPlainText(line.left(line.indexOf('\n')-1));
}

void Dialog_run::onProcessStarted()
{
    setUiEnabled(false);
}

void Dialog_run::onProcessStdOutWrite(QString szOutput)
{
#ifdef Q_OS_WIN32
    QString content;

    if (fixedPosition != 0) {
        content = szOutput.right(szOutput.count() - szOutput.indexOf('\n') - 1);
    } else {
        content = szOutput;
    }

    if (content.startsWith("\f\r\n")) {
        ui->plainTextEdit_output->clear();
        ui->plainTextEdit_output->insertPlainText(content.right(content.count() - 3));
    } else {
        ui->plainTextEdit_output->insertPlainText(content);
    }
#else
    insertPlainText(szOutput);
#endif
    fixedPosition = ui->plainTextEdit_output->textCursor().position();
}

void Dialog_run::onProcessStdErrWrite(QString szOutput)
{
    ui->plainTextEdit_output->appendPlainText(szOutput);
    fixedPosition = ui->plainTextEdit_output->textCursor().position();
}

void Dialog_run::onProcessTerminate()
{
    setUiEnabled(true);
}
