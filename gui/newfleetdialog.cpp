#include "newfleetdialog.h"
#include "ui_newfleetdialog.h"

NewFleetDialog::NewFleetDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::NewFleetDialog)
{
    ui->setupUi(this);
}

NewFleetDialog::~NewFleetDialog()
{
    delete ui;
}
