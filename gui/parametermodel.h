#ifndef PARAMETERMODEL_H
#define PARAMETERMODEL_H

#include "tablemodel.h"

#include <QStringList>

class parametermodel : public tablemodel
{
public:
    parametermodel(QObject *parent = 0);
    ~parametermodel();

    bool envLink (int index);
    bool useBlock (int index);
    bool useDev (int index);

private:
    QStringList header;
};

#endif // PARAMETERMODEL_H
