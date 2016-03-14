#include "observation_widget.h"
#include "ui_observation_widget.h"

observation_widget::observation_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::observation_widget)
{
    ui->setupUi(this);
}

observation_widget::~observation_widget()
{
    delete ui;
}

void observation_widget::setText(QString)
{

}

QString observation_widget::text()
{
    QString txt;
    txt = QString(QString(" %1").arg(
                      QString::number(ui->spinBox_year->value())));
    return txt;
}
