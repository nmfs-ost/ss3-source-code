#ifndef TIME_BLOCK_H
#define TIME_BLOCK_H

#include <QString>

class TimeBlock
{
public:
    TimeBlock();

    void setBegin (int bg) {begin = bg;}
    int getBegin () {return begin;}
    void setEnd (int en) {end = en;}
    int getEnd () {return end;}

    QString toText();
    void fromText(QString txt);

private:
    int begin;
    int end;
};

#endif // TIME_BLOCK_H
