#ifndef YEARINDEXMEASURE_H
#define YEARINDEXMEASURE_H

#include <QList>

class yearIndexMeasure
{
public:
    yearIndexMeasure();
    yearIndexMeasure(const yearIndexMeasure &rhs);
    yearIndexMeasure(int year, int index, double value);

    int getYear() const;
    int getIndex() const;
    double getValue() const;
    void setValue(double value);
    void setValue(int year, int index, double value);

    yearIndexMeasure& operator = (const yearIndexMeasure &rhs) {copy (rhs); return *this;}
    bool operator == (const yearIndexMeasure &rhs) {return equals (rhs);}
    bool operator != (const yearIndexMeasure & rhs) {return !equals (rhs);}
    bool operator < (const yearIndexMeasure & rhs) {return lt(rhs);}
    bool operator <= (const yearIndexMeasure & rhs) {return lt(rhs) || equals(rhs);}
    bool operator > (const yearIndexMeasure & rhs) {return gt(rhs);}
    bool operator >= (const yearIndexMeasure & rhs) {return gt(rhs) || equals(rhs);}

private:
    int yr;
    int ind;
    double val;

    void copy(const yearIndexMeasure &rhs);
    bool equals (const yearIndexMeasure &rhs);
    bool lt(const yearIndexMeasure &rhs);
    bool gt(const yearIndexMeasure &rhs);
};

yearIndexMeasure *getYearIndexMeasure (QList<yearIndexMeasure *> &yimList, int year, int index);

#endif // YEARINDEXMEASURE_H
