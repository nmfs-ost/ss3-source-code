#include "file_info_widget.h"
#include "ui_file_info_widget.h"

file_info_widget::file_info_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::file_info_widget)
{
    ui->setupUi(this);
}

file_info_widget::~file_info_widget()
{
    delete ui;
}
