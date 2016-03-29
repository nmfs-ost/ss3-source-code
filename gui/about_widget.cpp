#include "about_widget.h"
#include "ui_about_widget.h"

about_widget::about_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::about_widget)
{
    ui->setupUi(this);
}

about_widget::~about_widget()
{
    delete ui;
}
