#ifndef ERROR_VECTOR_H
#define ERROR_VECTOR_H

#include <QList>

class error_vector
{
public:
    error_vector(int n = 0);

    void set_size (int n);
    int size() {return i_size;}
//    void add_mean (float mn) {means.append (mn);}
    void set_mean (int index, float mn) {means[index] = mn;}
    float mean (int index) {return means[index];}
//    void add_std_dev (float std_dv) {std_devs.append (std_dv);}
    void set_std_dev (int index, float std_dv) {std_devs[index] = std_dv;}
    float std_dev (int index) {return std_devs[index];}

private:
    int i_size;
    QList<float> means;
    QList<float> std_devs;
};

#endif // ERROR_VECTOR_H
