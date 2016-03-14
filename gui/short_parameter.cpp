#include "short_parameter.h"

#include <QStringList>

shortParameter::shortParameter()
{
    clear();
}

shortParameter& shortParameter::copy(const shortParameter &rhs)
{
    lo = rhs.getLo();
    hi = rhs.getHi();
    init = rhs.getInit();
    prior = rhs.getPrior();
    pr_type = rhs.getPriorType();
    sd = rhs.getSd();
    phase = rhs.getPhase();
}

void shortParameter::clear()
{
    lo = 0;
    hi = 0;
    init = 0;
    prior = 0;
    pr_type = 0;
    sd = 0;
    phase = 0;
    sp_text = QString("");
}

int shortParameter::getPhase() const
{
    return phase;
}

void shortParameter::setPhase(int value)
{
    phase = value;
}

float shortParameter::getSd() const
{
    return sd;
}

void shortParameter::setSd(float value)
{
    sd = value;
}

int shortParameter::getPriorType() const
{
    return pr_type;
}

void shortParameter::setPriorType(int value)
{
    pr_type = value;
}

float shortParameter::getPrior() const
{
    return prior;
}

void shortParameter::setPrior(float value)
{
    prior = value;
}

float shortParameter::getInit() const
{
    return init;
}

void shortParameter::setInit(float value)
{
    init = value;
}

float shortParameter::getHi() const
{
    return hi;
}

void shortParameter::setHi(float value)
{
    hi = value;
}

float shortParameter::getLo() const
{
    return lo;
}

void shortParameter::setLo(float value)
{
    lo = value;
}


QString shortParameter::toText()
{
    sp_text.clear();
    //    QString txt = QString("");
    QString s_lo = QString::number(lo);
    QString s_hi = QString::number(hi);
    QString s_init = QString::number(init);
    QString s_prior = QString::number(prior);
    QString s_pr_type = QString::number(pr_type);
    QString s_sd = QString::number(sd);
    QString s_phase = QString::number(phase);
    sp_text.append(QString (" %1 %2 %3 %4 %5 %6 %7").arg(
            s_lo, s_hi, s_init, s_prior, s_pr_type, s_sd, s_phase));
    return sp_text;
}

void shortParameter::fromText(QString line)
{
    QStringList items = line.split(' ', QString::SkipEmptyParts);
    lo = items.at(0).toFloat();
    hi = items.at(1).toFloat();
    init = items.at(2).toFloat();
    prior = items.at(3).toFloat();
    pr_type = items.at(4).toInt();
    sd = items.at(5).toFloat();
    phase = items.at(6).toInt();
}
