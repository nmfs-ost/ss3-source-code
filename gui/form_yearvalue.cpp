#include "form_yearvalue.h"
#include "ui_form_yearvalue.h"

Form_YearValue::Form_YearValue(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::Form_YearValue)
{
    ui->setupUi(this);
}

Form_YearValue::~Form_YearValue()
{
    delete ui;
}
