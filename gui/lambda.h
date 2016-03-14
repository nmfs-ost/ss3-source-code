#ifndef LAMBDA_H
#define LAMBDA_H

#include <QList>
#include "lambda_change.h"

class lambda
{
public:
    lambda();

    void set_max_phase (int val) {max_phase = val;}
    int get_max_phase () {return max_phase;}
    void set_sd_offset (float val) {sd_offset = val;}
    float get_sd_offset () {return sd_offset;}
    void set_num_changes (int val) {num_changes = val;}
    int get_num_changes () {return num_changes;}

    int max_phase;
    float sd_offset;
    int num_changes;
    QList <lambda_change *> changes;
};

#endif // LAMBDA_H
