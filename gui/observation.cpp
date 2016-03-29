#include "observation.h"

#include <QStringList>

observation::observation(int size)
{
    set_size(size);
}

void observation::set_size(int size)
{
    ml_data.clear();
    fm_data.clear();
    for (int i = 0; i < size; i++)
    {
        ml_data.append(0.0);
        fm_data.append(0.0);
    }
}

void observation::set_fixed_catch_text(QString line)
{
    QStringList slist = line.split(' ', QString::SkipEmptyParts);
    set_year (slist.at(0).toInt());
    set_season (slist.at(1).toInt());
    set_fleet (slist.at(2).toInt());
    set_data (slist.at(3).toFloat());
}

QString observation::fixed_catch_text()
{
    QString txt("");

    txt.append (QString(" %1 %2 %3 %4").arg (
                    QString::number(year()),
                    QString::number(season()),
                    QString::number(fleet()),
                    QString::number(data())));
    return txt;
}
