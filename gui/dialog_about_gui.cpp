#include "dialog_about_gui.h"
#include "ui_dialog_about_gui.h"
#include "metadata.h"

Dialog_about_gui::Dialog_about_gui(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_about_gui)
{
    QFont qf("Arial", 14);
    ui->setupUi(this);

    ui->label_app->setText(getAppName());
    ui->label_app->setFont(qf);
    qf.setPointSize(12);
    ui->label_ver->setText(QString("%1 %2").arg(tr("Version"), getAppVersion()));
    ui->label_ver->setFont(qf);
    ui->label_appliesTo->setText(QString("For use with Stock Synthesis version %1").arg(getAppAppliesTo()));
    ui->label_appliesTo->setFont(qf);
    ui->label_copyright->setText(QString("copyright %1 by %2").arg(getAppCopyright(), getAppOrg()));

    qf.setPointSize(10);
    QString txt("This interface will let the user read and examine data files for Stock Synthesis, ");
    txt.append(QString("run the SS3.exe program, and check for errors.\n\n"));
    txt.append(QString("The interface was designed and programmed by Neal Schindler using the following tools:\n"));
    txt.append(QString("    Qt ver 4.8.5 graphics libraries,\n"));
    txt.append(QString("    Qt Creator (a cross platform IDE), and\n"));
//    txt.append(QString("    Inno Setup (for Windows installer),\n"));
//    txt.append(QString("    Doxygen (for documentation), and\n"));
    txt.append(QString("    MinGW 4.4 (GCC for Windows)."));
    ui->textEdit->setText(txt);
    ui->textEdit->setFont(qf);

    connect (ui->toolButton_aboutSS, SIGNAL(clicked()), SIGNAL(showAboutSS()));
    connect (ui->toolButton_aboutQt, SIGNAL(clicked()), SIGNAL(showAboutQt()));
    connect (ui->pushButton_ok, SIGNAL(clicked()), SLOT(close()));
}

Dialog_about_gui::~Dialog_about_gui()
{
    delete ui;
}
