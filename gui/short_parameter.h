#ifndef SHORT_PARAMETER_H
#define SHORT_PARAMETER_H

#include <QStringList>

class shortParameter
{
public:
    shortParameter();

    shortParameter &copy(const shortParameter &rhs);
    QString toText();
    void fromText(QString line);
    void clear();
//    shortParameter &operator = (const shortParameter &rhs) {copy (rhs);}

    float getLo() const;
    void setLo(float value);
    float getHi() const;
    void setHi(float value);
    float getInit() const;
    void setInit(float value);
    float getPrior() const;
    void setPrior(float value);
    int getPriorType() const;
    void setPriorType(int value);
    float getSd() const;
    void setSd(float value);
    int getPhase() const;
    void setPhase(int value);

private:
    float lo;
    float hi;
    float init;
    float prior;
    int   pr_type;
    float sd;
    int   phase;

    QString sp_text;

};

#endif // SHORT_PARAMETER_H
