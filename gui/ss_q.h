#ifndef SS_Q_H
#define SS_Q_H

#include <QList>

#include "method_setup.h"
#include "short_parameter.h"

class ss_Q
{
public:
    ss_Q(int n_fisheries, int n_surveys);
    ~ss_Q();

    void setYears (int f_yr, int num);

    int num_fleets;
    int num_methods;
    int first_year;
    int num_years;

    QList<method_setup *> setup;
    QList<shortParameter *> params;

};

#endif // SS_Q_H
