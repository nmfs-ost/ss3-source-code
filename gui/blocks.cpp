#include "blocks.h"

blocks::blocks(QObject *parent) :
    QObject(parent)
{
    clear();
}

blocks::~blocks()
{
    clear();
}

void blocks::clear()
{
    i_num_patterns = 0;
    patterns.append(BlockPattern());
    patterns.clear();

    custom_flag = false;
    param_blocks.append(shortParameter());
    param_blocks.clear();
}

void blocks::set_num_patterns (int num)
{
    i_num_patterns = num;
    for (int i = 0; i < num; i++)
    {
        BlockPattern bp;
        patterns.append (bp);
    }
}

int blocks::num_patterns ()
{
    return i_num_patterns;
}

void blocks::set_num_blocks_pattern (int pat, int num)
{
    if (pat >= 0 && pat < i_num_patterns)
    {
        patterns[pat].setNumBlocks(num);
    }
}

int blocks::num_blocks_pattern (int pat)
{
    return patterns.at(pat).getNumBlocks();

}

void blocks::add_pattern (BlockPattern pat)
{
    patterns.append(pat);
}


void blocks::add_pattern (QString text)
{
    BlockPattern bp;
    bp.fromText (text);
    patterns.append(bp);
}

void blocks::modify_pattern (int index, QString text)
{
    BlockPattern bp = patterns[index];
    bp.fromText (text);
}

QString blocks::pattern_to_text (int index)
{
    QString text = patterns[index].toText();
}

void blocks::delete_pattern (int index)
{
    patterns.takeAt(index);
}

void blocks::set_block_begin (int pat, int blk, int yr)
{
    patterns[pat].getBlock(blk)->setBegin(yr);
}

void blocks::set_block_end (int pat, int blk, int yr)
{
    patterns[pat].getBlock(blk)->setEnd(yr);
}

int blocks::block_begin (int pat, int blk)
{
    int yr = patterns.at(pat).getBlock(blk)->getBegin();
    return yr;
}

int blocks::block_end (int pat, int blk)
{
    int yr = patterns.at(pat).getBlock(blk)->getEnd();
    return yr;
}


void blocks::add_use (longParameter parm)
{
    use_block_pattern = parm;
}

longParameter blocks::use_pattern ()
{
    return use_block_pattern;
}

void blocks::add_custom_use_pattern (shortParameter parm)
{
    param_blocks.append(parm);
}

void blocks::add_custom_use_pattern(QString txt)
{
    shortParameter sp;
    sp.fromText(txt);
    param_blocks.append(sp);
}

void blocks::set_custom_use_pattern (int pat, int blk, QString txt)
{
    int index = 0;
    if (pat >= 0 && pat < i_num_patterns)
    {
        for (int i = 0; i < pat; i++)
            index += patterns.at(i).getNumBlocks();

        BlockPattern bp = patterns.at(pat);
        if (blk >= 0 && blk < bp.getNumBlocks())
        {
            index += blk;
            param_blocks[index].fromText(txt);
        }
    }
}

shortParameter blocks::use_custom_pattern (int pat, int blk)
{
    shortParameter sp;
    int index = 0;

    if (pat >= 0 && pat < i_num_patterns)
    {
        for (int i = 0; i < pat; i++)
            index += patterns.at(i).getNumBlocks();

        BlockPattern bp = patterns.at(pat);
        if (blk >= 0 && blk < bp.getNumBlocks())
        {
            index += blk;
            sp = param_blocks.at(index);
        }
    }
    return sp;
}
bool blocks::getCustomFlag() const
{
    return custom_flag;
}

void blocks::setCustomFlag(bool value)
{
    custom_flag = value;
}

