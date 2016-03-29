#include "console_redir.h"

console_redir::console_redir(QWidget *parent)
{
    process = NULL;
}

console_redir::~console_redir()
{
    TerminateChildProcess();
}

bool console_redir::StartChildProcess(bool bShowChildWindow)
{
    process = new QProcess();
    process->setProcessChannelMode(QProcess::MergedChannels);

    connect(process, SIGNAL(readyReadStandardError()), SLOT(readyReadStandardError()));
    connect(process, SIGNAL(readyReadStandardOutput()), SLOT(readyReadStandardOutput()));
#ifdef Q_OS_WIN32
    process->start("cmd.exe");
#else
    process->start("sh");
    process->write("pwd\n");
#endif
    return true;
}

bool console_redir::IsChildRunning() const
{
    return (process != NULL);
}

void console_redir::TerminateChildProcess()
{
    if (IsChildRunning())
    {
        process->close();
        delete process;
        process = NULL;
    }
}

// Thread to monitoring the child process.

int console_redir::ProcessThread()
{
    return 0;
}

// Function that writes to the child stdin.

void console_redir::WriteChildStdIn(QString szInput)
{
    process->write(szInput.toAscii().constData(), szInput.count());
#ifdef Q_OS_UNIX
    process->write("pwd\n");
#else
    process->write("\n");
#endif
}

void console_redir::execute(QString &program, QStringList &arguments)
{
    if (!IsChildRunning())
        StartChildProcess();
    process->execute(program, arguments);
}

// Functions that get output and send back to calling routine
 void console_redir::readyReadStandardOutput()
 {
     QString str = process->readAllStandardOutput();

     emit OnChildStdOutWrite(str);
 }

 void console_redir::readyReadStandardError()
 {
     emit OnChildStdErrWrite(QString(process->readAllStandardError()));
 }


