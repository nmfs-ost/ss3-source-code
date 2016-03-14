#include "long_parameter.h"

#include <QStringList>

longParameter::longParameter()
{
    lo = 0;
    hi = 0;
    init = 0;
    prior = 0;
    prType = 0;
    sd = 0;
    phase = 0;
    envVar = 0;
    useDev = 0;
    devMinyr = 0;
    devMaxyr = 0;
    devStddev = 0;
    useBlock = 0;
    blockType = 0;
}
/*
longParameter::longParameter (longParameter rhs)
{
    copy (rhs);
}

longParameter longParameter::operator = (const longParameter rhs)
{
    return copy (rhs);
}

longParameter longParameter::copy(longParameter rhs)
{
    lo = rhs.getLo();
    hi = rhs.getHi();
    init = rhs.getInit();
    prior = rhs.getPrior();
    prType = rhs.getPriorType();
    sd = rhs.getSd();
    phase = rhs.getPhase();
    envVar = rhs.getEnvVaraible();
    useDev = rhs.getUseDev();
    devMinyr = rhs.getDevMinYear();
    devMaxyr = rhs.getDevMaxYear();
    devStddev = rhs.getDevStdDev();
    useBlock = rhs.getUseBlock();
    blockType = rhs.getBlockType();

    return *this;
}*/

float longParameter::getLo() const
{
    return lo;
}

void longParameter::setLo(float value)
{
    lo = value;
}

float longParameter::getHi() const
{
    return hi;
}

void longParameter::setHi(float value)
{
    hi = value;
}

float longParameter::getInit() const
{
    return init;
}

void longParameter::setInit(float value)
{
    init = value;
}

float longParameter::getPrior() const
{
    return prior;
}

void longParameter::setPrior(float value)
{
    prior = value;
}

int longParameter::getPriorType() const
{
    return prType;
}

void longParameter::setPriorType(int value)
{
    prType = value;
}

float longParameter::getSd() const
{
    return sd;
}

void longParameter::setSd(float value)
{
    sd = value;
}

int longParameter::getPhase() const
{
    return phase;
}

void longParameter::setPhase(int value)
{
    phase = value;
}

float longParameter::getEnvVaraible() const
{
    return envVar;
}

void longParameter::setEnvVariable(float value)
{
    envVar = value;
}

int longParameter::getUseDev() const
{
    return useDev;
}

void longParameter::setUseDev(int value)
{
    useDev = value;
}

int longParameter::getDevMinYear() const
{
    return devMinyr;
}

void longParameter::setDevMinYear(int value)
{
    devMinyr = value;
}

int longParameter::getDevMaxYear() const
{
    return devMaxyr;
}

void longParameter::setDevMaxYear(int value)
{
    devMaxyr = value;
}

float longParameter::getDevStdDev() const
{
    return devStddev;
}

void longParameter::setDevStdDev(float value)
{
    devStddev = value;
}

int longParameter::getUseBlock() const
{
    return useBlock;
}

void longParameter::setUseBlock(int value)
{
    useBlock = value;
}

int longParameter::getBlockType() const
{
    return blockType;
}

void longParameter::setBlockType(int value)
{
    blockType = value;
}


QString longParameter::toText()
{
    lpText.clear();
    QString txt = QString("");
    QString s_lo = QString::number(lo);
    QString s_hi = QString::number(hi);
    QString s_init = QString::number(init);
    QString s_prior = QString::number(prior);
    QString s_pr_type = QString::number(prType);
    QString s_sd = QString::number(sd);
    QString s_phase = QString::number(phase);
    QString s_env_var = QString::number(envVar);
    QString s_use_dev = QString::number(useDev);
    QString s_dev_minyr = QString::number(devMinyr);
    QString s_dev_maxyr = QString::number(devMaxyr);
    QString s_dev_stddev = QString::number(devStddev);
    QString s_use_block = QString::number(useBlock);
    QString s_blck_type = QString::number(blockType);
    lpText.append(QString (" %1 %2 %3 %4 %5 %6 %7").arg(
            s_lo, s_hi, s_init, s_prior, s_pr_type, s_sd, s_phase));
    lpText.append(QString(" %1 %2 %3 %4 %5 %6 %7").arg(
            s_env_var, s_use_dev, s_dev_minyr, s_dev_maxyr, s_dev_stddev,
                       s_use_block, s_blck_type));
    return lpText;
}

void longParameter::fromText(QString line)
{
    QStringList items = line.split(' ', QString::SkipEmptyParts);
    lo = items.at(0).toFloat();
    hi = items.at(1).toFloat();
    init = items.at(2).toFloat();
    prior = items.at(3).toFloat();
    prType = items.at(4).toInt();
    sd = items.at(5).toFloat();
    phase = items.at(6).toInt();
    envVar = items.at(7).toFloat();
    useDev = items.at(8).toFloat();
    devMinyr = items.at(9).toInt();
    devMaxyr = items.at(10).toInt();
    devStddev = items.at(11).toFloat();
    useBlock = items.at(12).toInt();
    blockType = items.at(13).toInt();
}
