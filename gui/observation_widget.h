#ifndef OBSERVATION_WIDGET_H
#define OBSERVATION_WIDGET_H

#include <QWidget>

#include "ss_observation.h"

namespace Ui {
class observation_widget;
}

class observation_widget : public QWidget
{
    Q_OBJECT

public:
    explicit observation_widget(QWidget *parent = 0);
    ~observation_widget();

public slots:
    void setText(QString);
    QString text();

    void set_observation(ssObservation *obs) {o_obs = obs;}
    ssObservation *get_observation() {return o_obs;}

signals:
    void dataChanged();

private:
    Ui::observation_widget *ui;

    ssObservation *o_obs;
};

#endif // OBSERVATION_WIDGET_H
