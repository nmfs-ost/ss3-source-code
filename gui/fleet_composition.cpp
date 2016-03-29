#include "fleet_composition.h"

fleet_composition::fleet_composition(QObject *parent)
 : QObject (parent)
{
    i_method = 0;
    f_mincomp = 0;      // compress tails of composition until obs prop is > than this
    f_addtocomp = .0001;// constant added to obs and expected prop

    i_bin_combine = 0;  // combine males and females at this bin and lower
    i_compress_bins = 0;// accumulate upper tail by this number of bins
    i_error = 0;        //  0=multinomial, 1=dirichlet
    i_err_param = 0;    // parm number if error = 1

    obsModel = new tablemodel(this);
    obsHeader << "Year" << "Month" << "Gender" << "Part" << "NSamp" ;
    obsModel->setColumnCount(obsHeader.count());
    obsModel->setHeader(obsHeader);
}

fleet_composition::~fleet_composition()
{
    delete obsModel;
}

void fleet_composition::setNumberBins(int num, int gen)
{
    int obsCount;
    obsCount = obsHeader.count() + (gen * num);
    obsModel->setColumnCount(obsCount);
}

void fleet_composition::setObservation(int index, QStringList data)
{
    if (index >= obsModel->rowCount())
        obsModel->setRowCount(index + 1);
    obsModel->setRowData(index, data);
}


fleet_comp_length::fleet_comp_length(QObject *parent)
    : fleet_composition(parent)
{
    obsModel->setColumnCount(7);
    obsHeader.clear();
    obsHeader << "Year" << "Month" << "Gender" << "Part" << "NSamp" ;
    obsModel->setHeader(obsHeader);
    obsModel->setRowCount(0);
}

void fleet_comp_length::setNumberBins(int num, int gen)
{
    int obsCount;
    QStringList header(obsHeader);
    for (int i = 0; i < num; i++)
        header.append(QString("F%1").arg(i+1));
    if (gen == 2)
    for (int i = 0; i < num; i++)
        header.append(QString("M%1").arg(i+1));
    obsCount = 5 + (gen * num);
    obsModel->setColumnCount(header.count());
    obsModel->setHeader(header);
}

fleet_comp_age::fleet_comp_age(QObject *parent)
    : fleet_composition(parent)
{
    f_addtocomp = .0000001;
    i_num_error_defs = 0;
    i_num_saa_obs = 0;
    obsHeader.clear();
    obsHeader << "Year" << "Month" << "Gen" << "Part" << "AgeErr" << "Lbin_lo" << "Lbin_hi" << "NSamp";
    obsModel->setColumnCount(obsHeader.count());
    obsModel->setHeader(obsHeader);
    obsModel->setRowCount(0);

    saaModel = new tablemodel(this);
//    saaModel->

    errorModel = new tablemodel(this);
    errorModel->setColumnCount(10);
    errorModel->setRowCount(0);
    errorModel->setRowHeader(0,"");

    useParameters = false;
}

fleet_comp_age::~fleet_comp_age()
{
    while (o_saa_obs_list.count() > 0)
    {
        ssObservation *obs = o_saa_obs_list.takeFirst();
        delete obs;
    }
}

void fleet_comp_age::setNumberBins(int num, int gen)
{
    int obsCount, saaCount;
    QStringList header(obsHeader);
    QStringList saaHeader;
    for (int i = 0; i < num; i++)
        header.append(QString("F%1").arg(i+1));
    if (gen == 2)
    for (int i = 0; i < num; i++)
        header.append(QString("M%1").arg(i+1));
    obsCount = header.count() + (gen * num);
    obsModel->setColumnCount(header.count());
    obsModel->setHeader(header);

    saaHeader << "Year" << "Month" << "Gen" << "Part" << "AgeErr" << "Ignore";
    for (int i = 0; i < num; i++)
        saaHeader.append(QString("F%1").arg(i+1));
    if (gen == 2)
    for (int i = 0; i < num; i++)
        saaHeader.append(QString("M%1").arg(i+1));
    for (int i = 0; i < num; i++)
        saaHeader.append(QString("FS%1").arg(i+1));
    if (gen == 2)
    for (int i = 0; i < num; i++)
        saaHeader.append(QString("MS%1").arg(i+1));
    saaCount = 6 + (gen * 2 * num);
    saaModel->setColumnCount(saaHeader.count());
    saaModel->setHeader(saaHeader);
}

void fleet_comp_age::set_number_ages(int num)
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

void fleet_comp_age::set_num_error_defs(int num)
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

void fleet_comp_age::set_error_def_ages (int index, QStringList ages)
{
    errorModel->setRowData(index * 2, ages);
}

void fleet_comp_age::set_error_def (int index, QStringList errs)
{
    errorModel->setRowData(index * 2 + 1, errs);
}

QStringList fleet_comp_age::get_error_ages (int index)
{
    return errorModel->getRowData(index * i_num_error_defs);
}

QStringList fleet_comp_age::get_error_def(int index)
{
    return errorModel->getRowData(index * 2 + 1);
}

bool fleet_comp_age::getUseParameters()
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

/*
error_vector *age_composition::age_error(int index)
{
    error_vector *evct = 0;
    if (index >= 0 && index < error_defs.count())
        evct = error_defs.at(index);
    return evct;
}*/


fleet_comp_morph::fleet_comp_morph(QObject *parent)
 : fleet_composition(parent)
{
    obsHeader.clear();
    obsHeader << "Year" << "Month" << "Part" << "NSamp" ;
    obsModel->setColumnCount(obsHeader.count());
    obsModel->setHeader(obsHeader);
}

void fleet_comp_morph::setNumberMorphs(int num)
{
    QStringList header(obsHeader);
    for (int i = 0; i < num; i++)
        header.append(QString("Mph%1").arg(i+1));
    obsModel->setColumnCount(header.count());
    obsModel->setHeader(header);
}


fleet_comp_general::fleet_comp_general(QObject *parent)
  : fleet_composition(parent)
{
    obsHeader.clear();
    obsHeader << "Method" << "Year" << "Month" << "Gender" << "Part" << "NSamp" ;
    obsModel->setColumnCount(obsHeader.count());
    obsModel->setHeader(obsHeader);

}

void fleet_comp_general::setNumberBins(int num, int gen)
{
    QStringList header(obsHeader);
    for (int i = 0; i < num; i++)
        header.append(QString("F%1").arg(i+1));
    if (gen == 2)
    for (int i = 0; i < num; i++)
        header.append(QString("M%1").arg(i+1));
    obsModel->setHeader(header);
    obsModel->setColumnCount(header.count());
}
