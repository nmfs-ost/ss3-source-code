#include "dialoginputfiles.h"
#include "ui_dialoginputfiles.h"

DialogInputFiles::DialogInputFiles(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::DialogInputFiles)
{
    ui->setupUi(this);
}

DialogInputFiles::~DialogInputFiles()
{
    delete ui;
}
