#ifndef AGE_ERROR_H
#define AGE_ERROR_H

#include <QList>

class age_error
{
public:
    age_error(int n = 0);

    void set_size (int n);
    int size() {return means.count();}
    void set_mean (int index, float mn) {means[index] = mn;}
    float mean (int index) {return means[index];}
    void set_std_dev (int index, float std_dv) {std_devs[index] = std_dv;}
    float std_dev (int index) {return std_devs[index];}

private:
    QList<float> means;
    QList<float> std_devs;
};

#endif // AGE_ERROR_H
