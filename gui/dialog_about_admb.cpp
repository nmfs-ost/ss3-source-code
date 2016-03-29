#include "dialog_about_admb.h"
#include "ui_dialog_about_admb.h"

Dialog_About_ADMB::Dialog_About_ADMB(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_About_ADMB)
{
    ui->setupUi(this);
    connect (ui->pushButton_website, SIGNAL(clicked()), SLOT(goToWebpage()));
    connect (ui->pushButton_website, SIGNAL(clicked()), SLOT(close()));
}

Dialog_About_ADMB::~Dialog_About_ADMB()
{
    delete ui;
}

void Dialog_About_ADMB::goToWebpage()
{
    emit show_webpage("http://www.admb-project.org");
}
