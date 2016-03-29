#ifndef DIALOG_RUN_H
#define DIALOG_RUN_H

#include <QDialog>
#include <QPushButton>
#include <QSpacerItem>
#include <QPlainTextEdit>
#include <QLayout>
#include <QFile>
#include <QDir>
#include <QProcess>
#include <QMessageBox>


#include "dialog_view.h"
#include "dialog_fileview.h"
#include "console_redir.h"

#define BUFFER_SIZE 256


namespace Ui {
class Dialog_run;
}

class Dialog_run : public QDialog
{
    Q_OBJECT

public:
    explicit Dialog_run(QWidget *parent = 0);
    ~Dialog_run();

public slots:
    void runSS();
    void startRun();
    void pauseRun();
    void stopRun();
    void rejected();
    void runStarted();
    void runCompleted(int code);

    void setDir(QString dir);
    void setExe(QString exe);

    void stdOutput();
    void stdError();
    void outputLine();

    void showWarnFile();

    void onProcessStarted();
    void onProcessStdOutWrite(QString szOutput);
    void onProcessStdErrWrite(QString szOutput);
    void onProcessTerminate();

signals:
    void complete();
    void canceled();

private:
    Ui::Dialog_run *ui;
    Dialog_fileView *warnview;

    QVBoxLayout *layout;
    QPlainTextEdit *out;
    QPushButton *done;
    QHBoxLayout *buttons;

    int fixedPosition;
    QProcess *stocksynth;
    QString output;
    bool running;

    void setUiEnabled(bool flag);
    void finishOutput();

};

#endif // DIALOG_RUN_H
