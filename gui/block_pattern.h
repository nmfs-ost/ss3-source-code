#ifndef BLOCK_PATTERNS_H
#define BLOCK_PATTERNS_H

#include <QList>
#include <QStringList>

#include "long_parameter.h"
#include "short_parameter.h"
#include "tablemodel.h"

class BlockPattern
{
public:
    BlockPattern();
    ~BlockPattern();

    int getNumBlocks() const;
    void setNumBlocks(int value);

//    TimeBlock *getBlock(int index) const;
    tablemodel *getBlocks ();
    QStringList getBlock(int index) const;
    QString getBlockText(int index) const;
    void setBlock(int index, QStringList data);
    void setBlock(int index, const QString str);
    int getBlockBegin(int index) {return getBlock(index).at(0).toInt();}
    int getBlockEnd(int index) {return getBlock(index).at(1).toInt();}

    void setUseParameter (longParameter parm);
    longParameter getUseParameter ();

    bool getCustomFlag() const {return customFlag;}
    void setCustomFlag(bool value) {customFlag = value;}

    void set_custom_use (int flag) {customFlag = (flag != 0? 1: 0);}
    int use_custom () {return (customFlag? 1: 0);}
    void addCustomUsePattern (shortParameter parm);
    void addCustomUsePattern (QString txt);
    void setCustomUsePattern (int blk, QString txt);
    shortParameter getUseCustomPattern (int blk);

private:
    int numBlocks;
//    QList <TimeBlock *> Blocks;
    QStringList blockHeader;
    tablemodel *blocks;

    longParameter useBlockPattern;

    bool customFlag;
    QList<shortParameter> parameters;
};

#endif // BLOCK_PATTERNS_H
