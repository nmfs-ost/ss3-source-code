#ifndef GROWTH_MORPH_H
#define GROWTH_MORPH_H

#include <QList>
#include "long_parameter.h"
#include "parametermodel.h"

class growth_morph
{
public:
    growth_morph();
//    growth_morph(growth_morph &rhs);

    void set_param (int index, longParameter par) {morph_params[index] = par;}
    void set_param (int index, QString s_par) {morph_params[index].fromText (s_par);}
    longParameter get_param (int index) {return morph_params[index];}
    void set_morph_within_ratio (int index) {morph_within_ratio = index;}
    int get_morph_within_ratio () {return morph_within_ratio;}
    void set_morph_distribution (longParameter dist) {morph_dist = dist;}
    void set_morph_distribution (QString s_dist) {morph_dist.fromText(s_dist);}
    longParameter get_morph_distribution () {return morph_dist;}

//    growth_morph operator = (growth_morph &rhs);

protected:
    longParameter morph_params[6];
    int morph_within_ratio;
    longParameter morph_dist;

//    growth_morph copy (growth_morph &rhs);


};

#endif // GROWTH_MORPH_H
