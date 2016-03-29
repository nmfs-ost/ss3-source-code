#include "choose_year_widget.h"
#include "ui_choose_year_widget.h"

choose_year_widget::choose_year_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::choose_year_widget)
{
    ui->setupUi(this);
}

choose_year_widget::~choose_year_widget()
{
    delete ui;
}
