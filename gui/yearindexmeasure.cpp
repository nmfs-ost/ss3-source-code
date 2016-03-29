#include "yearindexmeasure.h"

yearIndexMeasure::yearIndexMeasure()
{
    yr = 0;
    ind = 0;
    val = -1.0;
}

yearIndexMeasure::yearIndexMeasure(const yearIndexMeasure &rhs)
{
    copy(rhs);
}

yearIndexMeasure::yearIndexMeasure(int year, int index, double value)
{
    setValue(year, index, value);
}

int yearIndexMeasure::getYear() const
{
    return yr;
}

int yearIndexMeasure::getIndex() const
{
    return ind;
}

double yearIndexMeasure::getValue() const
{
    return val;
}

void yearIndexMeasure::setValue(double value)
{
    val = value;
}

void yearIndexMeasure::setValue(int year, int index, double value)
{
    yr = year;
    ind = index;
    val = value;
}


void yearIndexMeasure::copy(const yearIndexMeasure &rhs)
{
    yr = rhs.getYear();
    ind = rhs.getIndex();
    val = rhs.getValue();
}

bool yearIndexMeasure::equals(const yearIndexMeasure &rhs)
{
    if (yr != rhs.getYear())
        return false;
    if (ind != rhs.getIndex())
        return false;
    if (val != rhs.getValue())
        return false;
    return true;
}

bool yearIndexMeasure::lt(const yearIndexMeasure &rhs)
{
    if (yr < rhs.getYear())
        return true;
    if (ind < rhs.getIndex())
        return true;
    if (val < rhs.getValue())
        return true;
    return false;
}

bool yearIndexMeasure::gt(const yearIndexMeasure &rhs)
{
    if (yr > rhs.getYear())
        return true;
    if (ind > rhs.getIndex())
        return true;
    if (val > rhs.getValue())
        return true;
    return false;
}

yearIndexMeasure *getYearIndexMeasure(QList<yearIndexMeasure*> &yimList, int year, int index)
{
    yearIndexMeasure *yim, *newyim = NULL;
    for (int i = 0; i < yimList.count(); i++)
    {
        yim = yimList.at(i);
        if (yim->getYear() == year &&
                yim->getIndex() == index)
        {
//            delete yim;
            newyim = yim;
//            yim->setValue(yimList.at(i).getValue());
            break;
        }
    }
    if (yim != newyim)
    {
        newyim = new yearIndexMeasure(year, index, -1.0);
        yimList.append(newyim);
    }
    return newyim;
}

