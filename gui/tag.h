#ifndef TAG_H
#define TAG_H

#include "long_parameter.h"

class tag
{
public:
    tag();
	
    longParameter getFirst() const;
    void setFirst(const longParameter &value);
    longParameter getLast() const;
    void setLast(const longParameter &value);

private:
    longParameter first;
    longParameter last;
};

#endif // TAG_H
