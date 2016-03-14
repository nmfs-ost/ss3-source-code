#include "block_pattern.h"

BlockPattern::BlockPattern()
{
    blocks = new tablemodel();
    blockHeader << "Begin" << "End";
    blocks->setHeader(blockHeader);
    setNumBlocks(0);

}

BlockPattern::~BlockPattern()
{
    delete blocks;
}

int BlockPattern::getNumBlocks() const
{
    return numBlocks;
}

tablemodel *BlockPattern::getBlocks()
{
    return blocks;
}

void BlockPattern::setNumBlocks(int value)
{
    blocks->setRowCount(value);
    numBlocks = blocks->rowCount();
}
QStringList BlockPattern::getBlock(int index) const
{
    return blocks->getRowData(index);
}

QString BlockPattern::getBlockText(int index) const
{
    QString txt;
    QStringList data = blocks->getRowData(index);
    for (int i = 0; i < data.count(); i++)
        txt.append(QString(" %1").arg(data.at(i)));
    return txt;
}

void BlockPattern::setBlock(int index, QStringList data)
{
    blocks->setRowData(index, data);
}

void BlockPattern::setBlock(int index, const QString str)
{
    QStringList data = str.split(' ', QString::SkipEmptyParts);
    if (index >= blocks->rowCount())
        blocks->setRowCount(index + 1);
    setBlock(index, data);
}


void BlockPattern::setUseParameter (longParameter parm)
{
    useBlockPattern = parm;
}

longParameter BlockPattern::getUseParameter()
{
    return useBlockPattern;
}

void BlockPattern::addCustomUsePattern (shortParameter parm)
{
    parameters.append(parm);
}

void BlockPattern::addCustomUsePattern(QString txt)
{
    shortParameter sp;
    sp.fromText(txt);
    parameters.append(sp);
}


shortParameter BlockPattern::getUseCustomPattern (int blk)
{
    shortParameter sp;

    if (blk > 0)
    {
        if (blk < parameters.count())
        {
            sp = parameters.at(blk);
        }
    }
    return sp;
}

