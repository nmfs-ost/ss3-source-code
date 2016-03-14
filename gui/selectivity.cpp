#include "selectivity.h"
#include "selex_equation.h"

selectivity::selectivity(int method)
{
    pattern = 0;
    discard = 0;
    male = 0;
    special = 0;

    numAges = 0;
    equation = NULL;
    parameters = new parametermodel();

    envLinkParameters = new parametermodel();
    envLinkParameters->setColumnCount(7);
    devErrParameters = new parametermodel();
    devErrParameters->setColumnCount(7);
    devRhoParameters = new parametermodel();
    devRhoParameters->setColumnCount(7);
    blockParameters = new parametermodel();
    blockParameters->setColumnCount(7);

    setMethod(method);
}

selectivity::~selectivity()
{
    delete equation;
    delete parameters;

}

void selectivity::setSetup(QString text)
{
    QStringList strList(text.split(' '));
    setSetup(strList);
}
void selectivity::setSetup(QStringList strList)
{
    pattern = strList.at(0).toInt();
    discard = strList.at(1).toInt();
    male = strList.at(2).toInt();
    special = strList.at(3).toInt();
}

QString selectivity::getSetupText()
{
    QString text("");
    text.append(QString(" %1 %2 %3 %4").arg(
                    QString::number(pattern),
                    QString::number(discard),
                    QString::number(male),
                    QString::number(special)));
    return text;
}

void selectivity::setMethod(int method)
{
    if (equation != NULL)
        delete equation;
    equation = NULL;

    if (method == pattern)
    {
        switch (method)
        {
        case 0: // selectivity = 1 for all
        case 10:
            setNumParameters(0);
            equation = new none();
            break;
        case 1:  // Simple logistic with 2 parameters
        case 12:
            setNumParameters(2);
            equation = new simple_logistic();
            break;
        case 2:  // discontinued
            setPattern(8);
            break;
        case 3:  // discontinued
            setPattern(0);
            break;
        case 4:  // discontinued
            setPattern(30);
            break;
        case 5:
            setNumParameters(2);
            equation = new mirror_range();
            break;
        case 6:
            setNumParameters(2 + special);
            equation = new linear_segments();
            break;
        case 7:
            setPattern(8);
            break;
        case 8:
        case 18:
            setNumParameters(8);
            equation = new double_logistic();
            break;
        case 9:
        case 19:
            setNumParameters(6);
            equation = new simple_double_logistic();
            break;
        case 11:
            setNumParameters(2);
            equation = new constant_for_range();
            break;
        case 13:
            setNumParameters(8);
            equation = new double_logistic();
            break;
        case 14:
            setNumParameters(numAges+1);
            equation = new each_age();
            break;
        case 15:
            setNumParameters(0);
            equation = new mirror();
            break;
        case 16:
            setNumParameters(2);
            equation = new coleraine();
            break;
        case 17:
            setNumParameters(numAges+1);
            equation = new random_walk();
            break;
        case 20:
        case 23:
        case 24:
            setNumParameters(6);
            equation = new double_normal_plateau_ends();
            break;
        case 22:
            setNumParameters(4);
            equation = new double_normal_plateau();
            break;
        case 25:
        case 26:
            setNumParameters(3);
            equation = new exponent_logistic();
            break;
        case 27:
            setNumParameters(3 + (2 * special));
            equation = new cubic_spline();
            break;
        case 30:  // equal to spawning biomass
        case 31:  // equal to exp(recruitment dev)
        case 32:  // equal to exp(rec dev) * spawn biomass
        case 33:  // expected survey abund = age 0 recruitment
        case 34:  // spawning biomass depletion (B/B0)
            setNumParameters(0);
            equation = new none();
            break;
        default:
            setPattern(0);
        }
    }
    else
    {
        setPattern (method);
    }
}



void selectivity::setPattern(int value)
{
    pattern = value;
    setMethod(value);
}

int selectivity::getNumParameters()
{
    return parameters->rowCount();
}

void selectivity::setNumParameters(int num)
{
    parameters->setRowCount(num);
    envLinkParameters->setRowCount(num);
    devErrParameters->setRowCount(num);
    devRhoParameters->setRowCount(num);
    blockParameters->setRowCount(num);
}

void selectivity::setParameter(int index, QString text)
{
    QStringList strList (text.split(' '));
    setParameter(index, strList);
/*    longParameter *lp = NULL;
    if (index > 0 && index < mParams.count())
    {
        lp = mParams.at(index);
        lp->fromText(text);
    }*/
}

void selectivity::setParameter(int index, QStringList strList)
{
    parameters->setRowData(index, strList);
}
/*
longParameter * selectivity::getParameter(int index)
{
    longParameter *lp = NULL;
    if (index >= 0 && index < mParams.count())
    {
        lp = mParams.at(index);
    }

    return lp;
}*/

QString selectivity::getParameterText(int index)
{
//    longParameter *lp = NULL;
    QString text("");
    QStringList strList(parameters->getRowData(index));
    for (int i = 0; i < strList.count(); i++)
        text.append(QString(" %1").arg(strList.at(i)));
/*    if (index > 0 && index < mParams.count())
    {
        lp = mParams.at(index);
        text = lp->toText();
    }
*/
    return text;
}

int selectivity::getNumEnvLink()
{
    int num = 0;
    QStringList data;
    for (int i = 0; i < parameters->rowCount(); i++)
    {
        num += parameters->envLink(i)? 1: 0;
    }
    return num;
}

void selectivity::setEnvLinkParameter(int index, QStringList strList)
{
    envLinkParameters->setRowData(index, strList);
}

QString selectivity::getEnvLinkParameter (int index)
{
    QStringList data = envLinkParameters->getRowData(index);
    QString text (data.at(0));
    for (int i = 1; i < data.count(); i++)
        text.append(QString(" %1").arg(data.at(i)));
    return text;
}

int selectivity::getNumUseDev()
{
    int num = 0;
    QStringList data;
    for (int i = 0; i < parameters->rowCount(); i++)
    {
        num += parameters->useDev(i)? 1: 0;
    }
    return num;
}

void selectivity::setDevErrParameter(int index, QStringList strList)
{
    devErrParameters->setRowData(index, strList);
}

QString selectivity::getDevErrParameter (int index)
{
    QStringList data = devErrParameters->getRowData(index);
    QString text (data.at(0));
    for (int i = 1; i < data.count(); i++)
        text.append(QString(" %1").arg(data.at(i)));
    return text;
}

void selectivity::setDevRhoParameter(int index, QStringList strList)
{
    devRhoParameters->setRowData(index, strList);
}

QString selectivity::getDevRhoParameter (int index)
{
    QStringList data = devRhoParameters->getRowData(index);
    QString text (data.at(0));
    for (int i = 1; i < data.count(); i++)
        text.append(QString(" %1").arg(data.at(i)));
    return text;
}

int selectivity::getNumUseBlock()
{
    int num = 0;
    QStringList data;
    for (int i = 0; i < parameters->rowCount(); i++)
    {
        num += parameters->useBlock(i)? 1: 0;
    }
    return num;
}

void selectivity::setBlockParameter(int index, QStringList strList)
{
    blockParameters->setRowData(index, strList);
}

QString selectivity::getBlockParameter (int index)
{
    QStringList data = blockParameters->getRowData(index);
    QString text (data.at(0));
    for (int i = 1; i < data.count(); i++)
        text.append(QString(" %1").arg(data.at(i)));
    return text;
}

double selectivity::evaluate()
{
    double val;
    return val;
}

double selectivity::evaluate(int f, float m)
{
    double val;
    if (equation == NULL)
        val = 0.0;
    else
        val = equation->evaluate();
    return val;
}

