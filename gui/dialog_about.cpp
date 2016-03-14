#include <QProcess>

#include "dialog_about.h"
#include "ui_dialog_about.h"
#include "metadata.h"

Dialog_about::Dialog_about(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_about)
{
    QFont qf("Arial", 14);
    ui->setupUi(this);
    ui->label_app->setText ("Stock Synthesis");
    ui->label_app->setFont(qf);
    qf.setPointSize(12);
    ui->label_ver->setText (QString ("%1 %2").arg(tr("Version"), getAppAppliesTo()));
    ui->label_ver->setFont(qf);
    ui->label_copyright->setText (" ");
//            (tr("copyright ") + getAppCopyright()
//             + tr(" by ") + getAppOrg());

    connect (ui->pushButton_ok, SIGNAL(clicked()), SLOT(close()));
    connect (ui->pushButton_manual, SIGNAL(clicked()), SIGNAL(show_manual()));
    connect (ui->pushButton_manual, SIGNAL(clicked()), SLOT(close()));
    connect (ui->pushButton_website, SIGNAL(clicked()), SLOT(goToWebsite()));
    connect (ui->pushButton_website, SIGNAL(clicked()), SLOT(close()));
}

Dialog_about::~Dialog_about()
{
    delete ui;
}

void Dialog_about::goToWebsite()
{
    emit show_webpage("http://nft.nefsc.noaa.gov/SS3.html");
}
