#ifndef Q_H
#define Q_H

#include <QString>
#include <QList>

#include "method_setup.h"
#include "short_parameter.h"
#include "parametermodel.h"

class q_ratio
{
public:
    q_ratio();
    ~q_ratio();

    void reset();
    q_ratio *copy (q_ratio *rhs);

    void setup(QStringList values);
    QString getSetup();

    int getDoPower() const;
    void setDoPower(int value);

    int getDoEnvLink() const;
    void setDoEnvLink(int value);

    int getDoExtraSD() const;
    void setDoExtraSD(int value);

    int getType() const;
    void setType(int value);

    int getOffset() const;
    void setOffset(int value);

    QString getPower() const;
    void setPower(QStringList values);

    QString getVariable() const;
    void setVariable(QStringList values);

    QString getExtra() const;
    void setExtra(QStringList values);

    QString getBase() const;
    void setBase(QStringList values);

    void setNumParams (int num);
    int getNumParams();
    void setParameter (int index, QStringList values);
    void setParameter (int index, QString text);
    QStringList getParameter(int index);

    parametermodel *getModel() {return params;}

private:
    parametermodel *params;
    int doPower;
    int powerIndex;
    int doEnvVar;
    int EnvIndex;
    int doExtraSD;
    int ExtraIndex;
    int type;
    int typeIndex;
    int offset;
    bool doOffset;
};

#endif // Q_H
