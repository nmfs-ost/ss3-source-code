#include "data_input_dialog.h"
#include "ui_data_input_dialog.h"

data_input_dialog::data_input_dialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::data_input_dialog)
{
    ui->setupUi(this);
}

data_input_dialog::~data_input_dialog()
{
    delete ui;
}
