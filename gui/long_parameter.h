#ifndef LONG_PARAMETER_H
#define LONG_PARAMETER_H

#include <QStringList>

class longParameter
{
public:
    longParameter();
//    longParameter (longParameter &rhs);

    QString toText();
    void fromText(QString line);

//    longParameter copy (longParameter &rhs) ;
//    longParameter operator = (longParameter &rhs) const ;

    int getBlockType() const;
    void setBlockType(int value);
    int getUseBlock() const;
    void setUseBlock(int value);
    float getDevStdDev() const;
    void setDevStdDev(float value);
    int getDevMaxYear() const;
    void setDevMaxYear(int value);
    int getDevMinYear() const;
    void setDevMinYear(int value);
    int getUseDev() const;
    void setUseDev(int value);
    float getEnvVaraible() const;
    void setEnvVariable(float value);
    int getPhase() const;
    void setPhase(int value);
    float getSd() const;
    void setSd(float value);
    int getPriorType() const;
    void setPriorType(int value);
    float getPrior() const;
    void setPrior(float value);
    float getInit() const;
    void setInit(float value);
    float getHi() const;
    void setHi(float value);
    float getLo() const;
    void setLo(float value);

private:
    float lo;
    float hi;
    float init;
    float prior;
    int   prType;
    float sd;
    int   phase;
    float envVar;
    int   useDev;
    int   devMinyr;
    int   devMaxyr;
    float devStddev;
    int   useBlock;
    int   blockType;

    QString lpText;

};

#endif // LONG_PARAMETER_H
