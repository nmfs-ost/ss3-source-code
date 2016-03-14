#include "tag.h"

tag::tag()
{
    first = longParameter();
    last = longParameter();
}

longParameter tag::getLast() const
{
    return last;
}

void tag::setLast(const longParameter &value)
{
    last = value;
}

longParameter tag::getFirst() const
{
    return first;
}

void tag::setFirst(const longParameter &value)
{
    first = value;
}

