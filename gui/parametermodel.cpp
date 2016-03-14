#include "parametermodel.h"

parametermodel::parametermodel(QObject *parent)
    : tablemodel(parent)
{
    setColumnCount(14);
    header << "Lo" << "Hi" << "Init" << "Prior" << "P_type" << "P_sd" << "Phase";
    header << "Env" << "Use_Dev" << "Dev_min" << "Dev_max" << "Dev_sd" << "Use_Blk" << "B_type";
    setHeader(header);
    setRowCount(0);
}

parametermodel::~parametermodel()
{
    header.clear();
}

bool parametermodel::envLink(int index)
{
    bool flag = false;
    if (index < rowCount())
        if (getRowData(index).at(7).toInt() > 0)
            flag = true;
    return (flag);
}

bool parametermodel::useBlock(int index)
{
    bool flag = false;
    if (index < rowCount())
        if (getRowData(index).at(12).toInt() > 0)
            flag = true;
    return (flag);
}

bool parametermodel::useDev(int index)
{
    bool flag = false;
    if (index < rowCount())
        if (getRowData(index).at(8).toInt() > 0)
            flag = true;
    return (flag);
}

