#ifndef CONSOLE_REDIR_H
#define CONSOLE_REDIR_H

#define BUFFER_SIZE 256

#include <QString>
#include <QProcess>
#include <QObject>


class console_redir : public QObject
{
    Q_OBJECT
public:
    console_redir(QWidget *parent = 0);
    ~console_redir();

public slots:
    bool StartChildProcess(bool bShowChildWindow = FALSE);
    bool IsChildRunning() const;
    void TerminateChildProcess();
    void WriteChildStdIn(QString szInput);
    void execute(QString &program, QStringList &arguments);

protected:

    QProcess *process;

    int ProcessThread();

private slots:
    void readyReadStandardOutput();
    void readyReadStandardError();

signals:
    void OnChildStarted();
    void OnChildStdOutWrite(QString szOutput);
    void OnChildStdErrWrite(QString szOutput);
    void OnChildTerminate();
};

#endif // CONSOLE_REDIR_H
