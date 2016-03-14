#include "q.h"

q_ratio::q_ratio()
{
    params = new parametermodel();
    params->setColumnCount(7);
    reset();
}

q_ratio::~q_ratio()
{
    reset();
    delete params;
}

void q_ratio::reset()
{
    params->setRowCount(0);
    doPower = 0;
    powerIndex = -1;
    doEnvVar = 0;
    EnvIndex = -1;
    doExtraSD = 0;
    ExtraIndex = -1;
    type = 0;
    typeIndex = -1;
    offset = 0;
    doOffset = false;
}

q_ratio *q_ratio::copy(q_ratio *rhs)
{

}

void q_ratio::setup(QStringList values)
{
    setDoPower(values.at(0).toInt());
    setDoEnvLink(values.at(1).toInt());
    setDoExtraSD(values.at(2).toInt());
    setType(values.at(3).toInt());
    if (values.count() > 4)
    {
        doOffset = true;
        setOffset(values.at(4).toInt());
    }
}

QString q_ratio::getSetup()
{
    QString txt("");
    txt.append(QString(" %1").arg(QString::number(doPower)));
    txt.append(QString(" %1").arg(QString::number(doEnvVar)));
    txt.append(QString(" %1").arg(QString::number(doExtraSD)));
    txt.append(QString(" %1").arg(QString::number(type)));
//    if (doOffset)
        txt.append(QString(" %1").arg(QString::number(offset)));
    return txt;
}

void q_ratio::setNumParams(int num)
{
    params->setRowCount(num);
}

int q_ratio::getNumParams()
{
    return params->rowCount();
}

void q_ratio::setParameter(int index, QStringList values)
{
    if (index < params->rowCount())
        params->setRowCount(index + 1);
    params->setRowData(index, values);
}

void q_ratio::setParameter(int index, QString text)
{
    QStringList values(text.split(' ', QString::SkipEmptyParts));
    setParameter (index, values);
}

QStringList q_ratio::getParameter(int index)
{
    return params->getRowData(index);
}

int q_ratio::getDoPower() const
{
    return doPower;
}

void q_ratio::setDoPower(int value)
{
    doPower = value;
    if (value == 1)
        powerIndex = 0;
    else
        powerIndex = -1;
    setDoEnvLink(doEnvVar);
}

int q_ratio::getDoEnvLink() const
{
    return doEnvVar;
}

void q_ratio::setDoEnvLink(int value)
{
    doEnvVar = value;
    if (value == 1)
        EnvIndex = powerIndex + 1;
    else
        EnvIndex = -1;
    setDoExtraSD(doExtraSD);
    setType(type);
}

int q_ratio::getDoExtraSD() const
{
    return doExtraSD;
}

void q_ratio::setDoExtraSD(int value)
{
    doExtraSD = value;
    if (value == 1)
    {
        ExtraIndex = (EnvIndex != -1)? EnvIndex + 1: powerIndex + 1;
    }
    else
        ExtraIndex = -1;
    setType(type);
}

int q_ratio::getType() const
{
    return type;
}

void q_ratio::setType(int value)
{
    type = value;
    if (type > 1)
    {
        typeIndex = powerIndex + 1;
        if (typeIndex == EnvIndex) typeIndex += 1;
        if (typeIndex == ExtraIndex) typeIndex += 1;
    }
    else
        typeIndex = -1;
}

int q_ratio::getOffset() const
{
    return offset;
}

void q_ratio::setOffset(int value)
{
    doOffset = value > 0;
    offset = value;
}

QString q_ratio::getPower() const
{
    QString txt("");
    if (powerIndex == 0)
    {
        QStringList values(params->getRowData(powerIndex));
        for (int j = 0; j < values.count(); j++)
            txt.append(QString(" %1").arg(values.at(j)));
    }
    return txt;
}

void q_ratio::setPower(QStringList values)
{
    if (powerIndex == 0)
        params->setRowData(powerIndex, values);
}

QString q_ratio::getVariable() const
{
    QString txt("");
    if (EnvIndex > -1)
    {
        QStringList values(params->getRowData(EnvIndex));
        for (int j = 0; j < values.count(); j++)
            txt.append(QString(" %1").arg(values.at(j)));
    }
    return txt;
}

void q_ratio::setVariable(QStringList values)
{
    if (EnvIndex > -1)
    {
        params->setRowData(EnvIndex, values);
    }
}

QString q_ratio::getExtra() const
{
    QString txt("");
    if (ExtraIndex > -1)
    {
        QStringList values(params->getRowData(ExtraIndex));
        for (int j = 0; j < values.count(); j++)
            txt.append(QString(" %1").arg(values.at(j)));
    }
    return txt;
}

void q_ratio::setExtra(QStringList values)
{
    if (ExtraIndex > -1)
    {
        params->setRowData(ExtraIndex, values);
    }
}

QString q_ratio::getBase() const
{
    QString txt("");
    if (typeIndex > -1)
    {
        QStringList values(params->getRowData(typeIndex));
        for (int j = 0; j < values.count(); j++)
            txt.append(QString(" %1").arg(values.at(j)));
    }
    return txt;
}

void q_ratio::setBase(QStringList values)
{
    if (typeIndex > -1)
    {
        params->setRowData(typeIndex, values);
    }
}









