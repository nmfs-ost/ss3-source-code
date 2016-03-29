#ifndef SD_REPORTING_H
#define SD_REPORTING_H

#include "long_parameter.h"
#include "tablemodel.h"
#include <QStringList>

class sd_reporting
{
public:
    sd_reporting();
    ~sd_reporting();

    void setActive (bool flag);
    void setActive (int value);
    bool getActive () {return reporting;}

    void setSpecs (QStringList data);
    QStringList getSpecs ();
    tablemodel *getSpecModel() {return specs;}

    void setNumBins (int num);
    int getNumSelexBins();
    void setSelexBins (QStringList data);
    QStringList getSelexBins ();
    int getNumGrowthBins();
    void setGrowthBins (QStringList data);
    QStringList getGrowthBins ();
    int getNumNatAgeBins();
    void setNatAgeBins (QStringList data);
    QStringList getNatAgeBins ();
    tablemodel *getBinModel() {return bins;}


private:
    bool reporting;
    tablemodel *specs;
    tablemodel *bins;

    QStringList specsHeader;
    longParameter vector_selex_bins;
    longParameter vector_growth_ages;
    longParameter vector_nat_ages;

};

#endif // SD_REPORTING_H
