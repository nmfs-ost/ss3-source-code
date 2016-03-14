#include "ss_movement.h"
#include "parametermodel.h"

ss_movement::ss_movement(int n_fleets)
{
    movement_defs = new tablemodel();
    defHeader << "seas" << "GP" << "source_area" << "dest_area" << "minage" << "maxage";
    movement_defs->setColumnCount(defHeader.count());
    movement_defs->setHeader(defHeader);
    movement_defs->setRowCount(0);
    movement_parms = new parametermodel();
    movement_parms->setRowCount(0);
    num_fleets = n_fleets;
    first_year = 0;
    num_years = 0;
    numAreas = 0;
    method = 0;
}

ss_movement::~ss_movement()
{
    delete movement_defs;
    delete movement_parms;
}

void ss_movement::setYears(int f_yr, int num)
{
    first_year = f_yr;
    if (num < first_year)
        num_years = num;
    else
        num_years = (num - first_year) + 1;
}

QStringList ss_movement::getDefinition(int index)
{
    return movement_defs->getRowData(index);
}

void ss_movement::setDefinition(int index, QStringList valuelist)
{
    if (index >= movement_defs->rowCount())
        movement_defs->setRowCount(index + 1);
    movement_defs->setRowData(index, valuelist);
}

void ss_movement::setParameter(int index, QStringList valuelist)
{
    if (index >= movement_parms->rowCount())
        movement_parms->setRowCount(index + 1);
    movement_parms->setRowData(index, valuelist);
}

int ss_movement::getMethod() const
{
    return method;
}

void ss_movement::setMethod(int value)
{
    method = value;
}

int ss_movement::getNumAreas() const
{
    return numAreas;
}

void ss_movement::setNumAreas(int value)
{
    numAreas = value;
}

float ss_movement::getFirstAge() const
{
    return firstAge;
}

void ss_movement::setFirstAge(float value)
{
    firstAge = value;
}



