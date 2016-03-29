#include "dialog_yearlyvalues.h"
#include "ui_dialog_yearlyvalues.h"

Dialog_YearlyValues::Dialog_YearlyValues(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_YearlyValues)
{
    ui->setupUi(this);
}

Dialog_YearlyValues::~Dialog_YearlyValues()
{
    delete ui;
}
