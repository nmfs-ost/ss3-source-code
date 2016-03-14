#ifndef METHOD_SETUP_H
#define METHOD_SETUP_H
#include <QStringList>

#include "tablemodel.h"

class method_setup
{
public:
    method_setup();
    ~method_setup();

    int getA() const;
    void setA(int value);
    int getPattern() const {return getA();}
    void setPattern(int value) {setA(value);}
    int getDoPower() const {return getA();}
    void setDoPower(int value) {setA(value);}

    int getB() const;
    void setB(int value);
    int getDiscard() const {return getB();}
    void setDiscard(int value) {setB(value);}
    int getDoEnvLink() const {return getB();}
    void setDoEnvLink(int value) {setB(value);}

    int getC() const;
    void setC(int value);
    int getMale() const {return getC();}
    void setMale(int value) {setC(value);}
    int getDoExtraSd() const {return getC();}
    void setDoExtraSd(int value) {setC(value);}

    int getD() const;
    void setD(int value);
    int getSpecial() const {return getD();}
    void setSpecial(int value) {setD(value);}
    int getQType() const {return getD();}
    void setQType(int value) {setD(value);}

    void fromText(QString text);
    void fromText(QStringList textlist);
    QString toText();

    QStringList getHeader() const;
    void setHeader(const QStringList &value);

    tablemodel *getSetupModel();

private:
    tablemodel *setup;
    QStringList header;
    int A;
    int B;
    int C;
    int D;
};

#endif // METHOD_SETUP_H
