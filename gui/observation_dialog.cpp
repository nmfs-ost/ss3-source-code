#include "observation_dialog.h"
#include "ui_observation_dialog.h"
#include "observation_widget.h"
#include "ss_observation.h"

observation_dialog::observation_dialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::observation_dialog)
{
    ui->setupUi(this);
    currentItem = -1;
    changed = false;
}

observation_dialog::~observation_dialog()
{
    delete ui;
}

void observation_dialog::setTitle(QString title)
{

}

void observation_dialog::addItem(QString item)
{

}

void observation_dialog::setItem(int index, QString item)
{

}

QString observation_dialog::getItem(int index)
{
    QString item = ui->listWidget->item(index)->text();
    return item;
}


QString observation_dialog::editItem(int index)
{
    QString item = ui->listWidget->item(index)->text();
    ssObservation * obs_data = new ssObservation();
    observation_widget *editor = new observation_widget(this);
    if (currentItem < 0)
    {
        currentItem = index;
        obs_data->fromText(item);
        editor->set_observation(obs_data);
        connect (editor, SIGNAL(dataChanged()), SIGNAL(dataChanged()));
        editor->show();
        if (changed)
        {
            item = obs_data->toText();
            ui->listWidget->item(index)->setText(item);
            changed = false;
        }
        currentItem = -1;
    }
    delete obs_data;
    delete editor;
    return item;
}


void observation_dialog::dataChanged()
{
    changed = true;
    emit itemChanged(currentItem);
}
