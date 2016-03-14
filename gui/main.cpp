#include "mainwindow.h"
#include "metadata.h"

#include <QApplication>
#include <QMessageBox>

int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    a.setApplicationName(getAppName());
    a.setApplicationVersion(getAppVersion());
    a.setWindowIcon (QIcon(":/ss_icon.ico"));
    a.setStyle("macintosh");
    MainWindow w;
    if (argc > 1)
    {
        QString fname (a.arguments().at(1));
        w.openDirectory(fname);
    }
    w.show();
    
    return a.exec();
}
