#ifndef SELECTIVITY_H
#define SELECTIVITY_H

#include <QString>
#include <QList>

#include "method_setup.h"
#include "long_parameter.h"
#include "selex_equation.h"
#include "parametermodel.h"

class selectivity
{
public:
    selectivity (int method = 0);
    ~selectivity();

    void setPattern (int value);
    int getPattern () {return pattern;}
    void setDiscard (int value) {discard = value;}
    int getDiscard () {return discard;}
    void setMale (int value) {male = value;}
    int getMale () {return male;}
    void setSpecial (int value) {special = value;}
    int getSpecial () {return special;}
    void setNumAges(int ages) {numAges = ages;}
    void setSetup(QString text);
    void setSetup(QStringList strList);
    QString getSetupText ();

    void setParameter (int index, QString text);
    void setParameter (int index, QStringList strList);
    QString getParameterText (int index);
    int getNumParameters();
    void setNumParameters (int num);
    parametermodel *getParameterModel() {return parameters;}

    int getNumEnvLink();
    void setEnvLinkParameter(int index, QStringList strList);
    QString getEnvLinkParameter (int index);
    parametermodel *getEnvLinkParamModel () {return envLinkParameters;}

    int getNumUseDev();
    void setDevErrParameter(int index, QStringList strList);
    QString getDevErrParameter (int index);
    parametermodel *getDevErrParamModel () {return devErrParameters;}
    void setDevRhoParameter(int index, QStringList strList);
    QString getDevRhoParameter (int index);
    parametermodel *getDevRhoParamModel () {return devRhoParameters;}

    int getNumUseBlock();
    void setBlockParameter(int index, QStringList strList);
    QString getBlockParameter (int index);
    parametermodel *getBlockParamModel () {return blockParameters;}


    double operator()() {return evaluate();}
    double evaluate();

    void setMethod (int method);

protected:
    void setEquation (int method);

    int pattern;
    int discard;
    int male;
    int special;

    int numAges;

    parametermodel *parameters;

    parametermodel *envLinkParameters;
    parametermodel *blockParameters;
    parametermodel *devErrParameters;
    parametermodel *devRhoParameters;

    double evaluate(int f, float m);

    selex_equation *equation;

};

#endif // SELECTIVITY_H
