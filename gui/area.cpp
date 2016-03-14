#include "area.h"

Area::Area(QObject *parent) :
    QObject(parent)
{
}
QString *Area::getName() const
{
    return name;
}

void Area::setName(QString *value)
{
    name = value;
}

