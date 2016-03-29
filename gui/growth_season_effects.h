#ifndef GROWTH_SEASON_EFFECTS_H
#define GROWTH_SEASON_EFFECTS_H

#include <QList>

#include "short_parameter.h"
#include "parametermodel.h"

class GrowthSeasonalEffects
{
public:
    GrowthSeasonalEffects();
    GrowthSeasonalEffects(const GrowthSeasonalEffects &other);
    ~GrowthSeasonalEffects();

    void setEffects (QStringList qlst);
    QStringList getEffects () const;

    float getFemaleWtLen1() const;
    void setFemaleWtLen1(float value);

    float getFemaleWtLen2() const;
    void setFemaleWtLen2(float value);

    float getMaleWtLen1() const;
    void setMaleWtLen1(float value);

    float getMaleWtLen2() const;
    void setMaleWtLen2(float value);

    float getMat1() const;
    void setMat1(float value);

    float getMat2() const;
    void setMat2(float value);

    float getFec1() const;
    void setFec1(float value);

    float getFec2() const;
    void setFec2(float value);

    float getL1() const;
    void setL1(float value);

    float getK() const;
    void setK(float value);

    QStringList getParameter (int index) const;
    void setParameter (int i, QStringList datalist);
    void setParameter (int i, QString str);
    tablemodel *getEffectsModel() {return effects;}
    tablemodel *getParamsModel() {return paramtable;}

    int getNumParams() const;
    void setNumParams(int value);

    void clear ();

    GrowthSeasonalEffects& copy (const GrowthSeasonalEffects &other);
    GrowthSeasonalEffects& operator = (const GrowthSeasonalEffects &other);

private:

    float FemaleWtLen1;
    float FemaleWtLen2;
    float MaleWtLen1;
    float MaleWtLen2;
    float mat1;
    float mat2;
    float fec1;
    float fec2;
    float l1;
    float k;

    tablemodel *effects;
    QStringList effHeader;
    parametermodel *paramtable;
/*    int numParams;
    QList<shortParameter *> params;*/
};

#endif // GROWTH_SEASON_EFFECTS_H
