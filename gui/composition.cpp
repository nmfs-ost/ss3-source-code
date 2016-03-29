#include "composition.h"

composition::composition(QObject *parent)
 : QObject (parent)
{
    binsModel = new tablemodel(this);
    binsModel->setColumnCount(0);
    binsModel->setRowCount(1);
    binsModel->setRowHeader(0, QString(""));

    altBinsModel = new tablemodel(this);

    reset();
}

composition::~composition()
{
    delete binsModel;
    delete altBinsModel;
}

void composition::reset()
{
    altBinsModel->setRowCount(0);
    altBinsModel->setColumnCount(0);

    i_method = 0;
    i_bin_width = 0;
    i_bin_max = 0;
    i_bin_min = 0;

    i_num_obs = 0;
}

void composition::setAltBinMethod (int method)
{
    i_method = method;
    switch (method)
    {
    case 1:
        altBinsModel->setRowCount(0);
        altBinsModel->setColumnCount(0);
        break;
    case 2:
    case 3:
        altBinsModel->setRowCount(1);
        altBinsModel->setColumnCount(0);
        binsModel->setRowCount(1);
        binsModel->setRowHeader(0, QString(""));
        break;
    }
}

int composition::generateAltBins ()
{
    QStringList bins;
    int num, bin;
    if (i_method == 2)
    {
        num = (i_bin_max - i_bin_min) / i_bin_width + 1;
        for (bin = i_bin_min; bin <= i_bin_max; bin += i_bin_width)
        {
            bins.append(QString::number(bin));
        }
        altBinsModel->setColumnCount(bins.count());
        setAltBins(bins);
    }
    return num;
}


compositionLength::compositionLength(QObject *parent)
    : composition(parent)
{
    binsModel->setColumnCount(0);
    binsModel->setRowCount(1);
    binsModel->setRowHeader(0, "");
}

void compositionLength::setNumberBins(int num)
{
    binsModel->setColumnCount(num);
}

compositionAge::compositionAge(QObject *parent)
    : composition(parent)
{
    i_num_error_defs = 0;
    i_num_saa_obs = 0;
    binsModel->setColumnCount(0);
    binsModel->setRowCount(1);
    binsModel->setRowHeader(0, "");

    saaModel = new tablemodel(this);
//    saaModel->

    errorModel = new tablemodel(this);
    errorModel->setColumnCount(10);
    errorModel->setRowCount(0);
    errorModel->setRowHeader(0,"");

    useParameters = false;
    errorParam = new parametermodel(this);
    errorParam->setColumnCount(7);
    errorParam->setRowCount(1);
}

compositionAge::~compositionAge()
{
    reset();

    delete saaModel;
    delete errorModel;
    delete errorParam;
}

void compositionAge::reset()
{
    composition::reset();

    saaModel->reset();
    errorModel->reset();

    while (error_defs.count() > 0)
    {
        error_vector *evct = error_defs.takeFirst();
        delete evct;
    }
    i_num_error_defs = 0;

    while (o_saa_obs_list.count() > 0)
    {
        ssObservation *obs = o_saa_obs_list.takeFirst();
        delete obs;
    }
    i_num_saa_obs = 0;

    useParameters = false;
    errorParam->reset();

}

void compositionAge::setNumberBins(int num)
{
    int obsCount, saaCount;
    QStringList saaHeader;
    binsModel->setColumnCount(num);

    saaHeader << "Year" << "Month" << "Gen" << "Part" << "AgeErr" << "Ignore";
    for (int i = 0; i < num; i++)
        saaHeader.append(QString("F%1").arg(i+1));
    for (int i = 0; i < num; i++)
        saaHeader.append(QString("M%1").arg(i+1));
    for (int i = 0; i < num; i++)
        saaHeader.append(QString("FS%1").arg(i+1));
    for (int i = 0; i < num; i++)
        saaHeader.append(QString("MS%1").arg(i+1));
    saaCount = 7 + (4 * num);
    saaModel->setColumnCount(saaHeader.count());
    saaModel->setHeader(saaHeader);
}

void compositionAge::set_number_ages(int num)
{
    int actAges (num + 1);
    QStringList errheader;
    errorModel->setColumnCount(actAges);
    for (int i = 0; i < actAges; i++)
    {
        errheader.append(QString("Age%1").arg(i));
    }
    errorModel->setHeader(errheader);
}

void compositionAge::set_num_error_defs(int num)
{
    i_num_error_defs = num;
    errorModel->setRowCount(num * 2);
    for (int i = 0; i < errorModel->rowCount(); i++)
    {
        int def = (i / 2) + 1;
        errorModel->setRowHeader(i, QString("mean %1").arg(QString::number(def)));
        i++;
        errorModel->setRowHeader(i, QString("stdv %1").arg(QString::number(def)));
    }
}

void compositionAge::set_error_def_ages (int index, QStringList ages)
{
    errorModel->setRowData(index * 2, ages);
}

void compositionAge::set_error_def (int index, QStringList errs)
{
    errorModel->setRowData(index * 2 + 1, errs);
}

QStringList compositionAge::get_error_ages (int index)
{
    return errorModel->getRowData(index * 2);
}

QStringList compositionAge::get_error_def(int index)
{
    return errorModel->getRowData(index * 2 + 1);
}

bool compositionAge::getUseParameters()
{
    useParameters = false;
    for (int i = 0; i < i_num_error_defs; i++)
    {
        int index = i * 2 + 1;
        float val = errorModel->getRowData(index).at(0).toFloat();
        if(val < 0)
            useParameters = true;
    }
    return useParameters;
}



compositionMorph::compositionMorph(QObject *parent)
 : composition(parent)
{
}

void compositionMorph::setNumberMorphs(int num)
{
    binsModel->setColumnCount(num);
}


compositionGeneral::compositionGeneral(QObject *parent)
  : composition(parent)
{
    reset();
}

compositionGeneral::~compositionGeneral()
{
    reset();
}

void compositionGeneral::reset()
{
    composition::reset();
    i_scale = 0;
    i_units = 0;
}

void compositionGeneral::setNumberBins(int num)
{
    binsModel->setColumnCount(num);
}
