#include "ss_mortality.h"
#include "parametermodel.h"
#include "fileIOgeneral.h"

ss_mortality::ss_mortality(int n_fisheries, int n_surveys)
{
    QStringList pheader;
    pheader << "fleet" << "year" << "seas" << "F" << "se" << "phase" ;
    parameterTable = new parametermodel();
    parameterTable->setColumnCount(6);
    parameterTable->setHeader(pheader);
    parameterTable->setRowCount(0);
    initialParams = new parametermodel();
    initialParams->setColumnCount(7);
    initialParams->setRowCount(0);
//    numFisheries = 0;
    setNumFisheries(n_fisheries);
    numSurveys = n_surveys;
    bparkF = 0.3;
    bparkYr = -2001;
    method = 3;
    maxF = 2.9;
    startF = 0;
    phase = 0;
    numInputs = 0;
    numTuningIters = 4;
}

void ss_mortality::reset()
{
    setNumFisheries(1);
    numSurveys = 0;
    bparkF = 0.3;
    bparkYr = -2001;
    method = 3;
    maxF = 2.9;
    startF = 0;
    phase = 0;
    numInputs = 0;
    numTuningIters = 4;
    setNumInputs(0);
}

void ss_mortality::setYears(int f_year, int num)
{
    numYears = f_year;
    if (num < numYears)
        numYears = num;
    else
        numYears = (num - numYears) + 1;
}

void ss_mortality::fromFile(ss_file *file, int num)
{
    QString token('#');
    QStringList tokenlist;
    int i, temp_int, num_lines;
    float temp_float;

    bparkF = file->next_value().toFloat();
    bparkYr = file->next_value().toInt();
    method = file->next_value().toInt();
    maxF = file->next_value().toFloat();
    startF = 0;
    phase = 0;
    numInputs = 0;
    numTuningIters = 0;
    switch (method)
    {
    case 2:
        startF = file->next_value().toInt();
        phase = file->next_value().toInt();
        numInputs = file->next_value().toInt();
        break;
    case 3:
        numTuningIters = file->next_value().toInt();
        break;
    }

    tokenlist.clear();
    if (numInputs > 0)
    {
        for (int i = 0; i < 6; i++)
        {
            tokenlist.append(file->next_value());
        }
        parameterTable->setRowData(0, tokenlist);
    }
    else
    {
        parameterTable->setRowCount(0);
    }

    initialParams->setRowCount(0);
    for (i = 0; i < num; i++)
    {
        tokenlist = readShortParameter(file);
        initialParams->setRowData(i, tokenlist);
    }

}

QString ss_mortality::toText()
{
    int i, j, tmp;

    QStringList tokenlist;
    m_text.clear();

    m_text.append("#Fishing Mortality info " );
    m_text.append(QString ("%1 # F ballpark for tuning early phases" ).arg(
                       QString::number(bparkF)));
    m_text.append(QString ("%1 # F ballpark year (neg value to disable)" ).arg(
                       QString::number(bparkYr)));
    m_text.append(QString ("%1 # F_Method: 1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)" ).arg(
                       QString::number(method)));
    m_text.append(QString ("%1 # max F or harvest rate, depends on F_Method" ).arg(
                       QString::number(maxF)));
    m_text.append("# no additional F input needed for Fmethod 1" );
    m_text.append("# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read" );
    m_text.append("# if Fmethod=3; read N iterations for tuning for Fmethod 3" );
    switch (method)
    {
    case 1:
        break;
    case 2:
        m_text.append(QString ("%1 # overall start F value" ).arg(
                           QString::number(startF)));
        m_text.append(QString ("%1 # overall phase" ).arg(
                           QString::number(phase)));
        m_text.append(QString ("%1 # N detailed inputs" ).arg(
                           QString::number(numInputs)));
        break;
    case 3:
        m_text.append(QString ("%1 # N iterations for tuning Fin hybrid method (recommend 3 to 7)" ).arg(
                           QString::number(numTuningIters)));
    }

    tmp = parameterTable->rowCount();
    for (i = 0; i < tmp; i++)
    {
        tokenlist = parameterTable->getRowData(i);
        for (int j = 0; j < tokenlist.count(); j++)
        {
            m_text.append(QString(" %1").arg(tokenlist.at(j)));
        }
        m_text.append(" # " );
    }
    tmp = initialParams->rowCount();
    m_text.append(QString("#\n#_initial_F_params; count = %1" ).arg (QString::number(tmp)));
    m_text.append("#_LO HI INIT PRIOR PR_TYPE SD PHASE" );

    for (i = 0; i < tmp; i++)
    {
        tokenlist = initialParams->getRowData(i);
        for (j = 0; j < tokenlist.count(); j++)
        {
            m_text.append(QString(" %1").arg(tokenlist.at(j)));
        }
        m_text.append(QString(" # InitF_%1 " ).arg( QString::number(i+1)));
    }
    m_text.append("# " );

    return m_text;
}
int ss_mortality::getNumTuningIters() const
{
    return numTuningIters;
}

void ss_mortality::setNumTuningIters(int value)
{
    numTuningIters = value;
}
/*int ss_mortality::getNumInputs() const
{
    return numInputs;
}

void ss_mortality::setNumInputs(int value)
{
    numInputs = value;
}
int ss_mortality::getFirstYear() const
{
    return firstYear;
}*/

void ss_mortality::setStartYear(int value)
{
    firstYear = value;
}
/*int ss_mortality::getNumYears() const
{
    return numYears;
}*/

void ss_mortality::setNumYears(int value)
{
    numYears = value;
}
/*int ss_mortality::getNumFisheries() const
{
    return numFisheries;
}*/

/*void ss_mortality::setNumFisheries(int value)
{
    parameterTable->setRowCount(value);
    while (value > numFisheries)
    {
        shortParameter *sp = new shortParameter();
        initialParams.append(sp);
        numFisheries++;
    }
    while (value > numFisheries)
    {
        shortParameter *sp = initialParams.takeLast();
        delete sp;
        numFisheries--;
    }
}*/
/*int ss_mortality::getNumSurveys() const
{
    return numSurveys;
}*/

void ss_mortality::setNumSurveys(int value)
{
    numSurveys = value;
}
float ss_mortality::getBparkF() const
{
    return bparkF;
}

void ss_mortality::setBparkF(float value)
{
    bparkF = value;
}
int ss_mortality::getBparkYr() const
{
    return bparkYr;
}

void ss_mortality::setBparkYr(int value)
{
    bparkYr = value;
}
int ss_mortality::getMethod() const
{
    return method;
}

void ss_mortality::setMethod(int value)
{
    method = value;
}
float ss_mortality::getMaxF() const
{
    return maxF;
}

void ss_mortality::setMaxF(float value)
{
    maxF = value;
}
float ss_mortality::getStartF() const
{
    return startF;
}

void ss_mortality::setStartF(float value)
{
    startF = value;
}
int ss_mortality::getPhase() const
{
    return phase;
}

void ss_mortality::setPhase(int value)
{
    phase = value;
}










