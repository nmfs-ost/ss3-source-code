#include "sd_reporting.h"

sd_reporting::sd_reporting()
{
    specs = new tablemodel();
    specs->setColumnCount(9);
    specsHeader << "sel type" << "len/age" << "year" << "N sel bins";
    specsHeader << "Gr Pat" << "N Gr ages";
    specsHeader << "NatAge_area" << "NatAge_yr" << "N Natages";
    specs->setHeader(specsHeader);

    bins = new tablemodel();
    bins->setRowCount(3);
    bins->setRowHeader(0, QString("Selex std bins"));
    bins->setRowHeader(1, QString("Growth std bins"));
    bins->setRowHeader(2, QString("NatAge std bins"));
}

sd_reporting::~sd_reporting()
{
    delete specs;
    delete bins;
}

void sd_reporting::setActive(bool flag)
{
    reporting = flag;
    if (reporting)
    {
        specs->setRowCount(1);
        setNumBins(3);
    }
    else
    {
        specs->setRowCount(0);
        setNumBins(0);
    }

}

void sd_reporting::setActive(int value)
{
    setActive((value != 0)? true: false);
}

void sd_reporting::setSpecs (QStringList data)
{
    specs->setRowData(0, data);
    int binscount = getNumSelexBins();
    int temp = getNumGrowthBins();
    if (binscount < temp)
        binscount = temp;
    temp = getNumNatAgeBins();
    if (binscount < temp)
        binscount = temp;
    setNumBins(binscount);
}

QStringList sd_reporting::getSpecs ()
{
    return specs->getRowData(0);
}

void sd_reporting::setNumBins (int num)
{
    bins->setColumnCount(num);
}

int sd_reporting::getNumSelexBins()
{
    QStringList spc = specs->getRowData(0);
    int num = spc.at(3).toInt();
    return num;
}

void sd_reporting::setSelexBins (QStringList data)
{
    bins->setRowData(0, data);
}

QStringList sd_reporting::getSelexBins ()
{
    return bins->getRowData(0);
}

int sd_reporting::getNumGrowthBins()
{
    QStringList spc = specs->getRowData(0);
    int num = spc.at(5).toInt();
    return num;
}

void sd_reporting::setGrowthBins (QStringList data)
{
    bins->setRowData(1, data);
}

QStringList sd_reporting::getGrowthBins ()
{
    return bins->getRowData(1);
}

int sd_reporting::getNumNatAgeBins()
{
    QStringList spc = specs->getRowData(0);
    int num = spc.at(8).toInt();
    return num;
}

void sd_reporting::setNatAgeBins (QStringList data)
{
    bins->setRowData(2, data);
}

QStringList sd_reporting::getNatAgeBins ()
{
    return bins->getRowData(2);
}
