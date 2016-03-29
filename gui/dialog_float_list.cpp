#include "dialog_float_list.h"
#include "ui_dialog_float_list.h"

Dialog_float_list::Dialog_float_list(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_float_list)
{
    ui->setupUi(this);
}

Dialog_float_list::~Dialog_float_list()
{
    delete ui;
}
