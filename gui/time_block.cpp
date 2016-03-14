#include "time_block.h"

#include <QStringList>

TimeBlock::TimeBlock()
{
    begin = end = 0;
}

void TimeBlock::fromText(QString txt)
{
    QStringList ql = txt.split(' ', QString::SkipEmptyParts);
    begin = ql.at(0).toInt();
    end = ql.at(1).toInt();
}

QString TimeBlock::toText()
{
    QString txt (QString("%1 %2 ").arg(
                     QString::number(begin),
                     QString::number(end)));
    return txt;
}

