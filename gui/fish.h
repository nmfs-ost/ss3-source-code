#ifndef FISH_H
#define FISH_H

#include <QObject>

class Fish : public QObject
{
    Q_OBJECT
public:
    explicit Fish(QObject *parent = 0);

signals:

public slots:

};

#endif // FISH_H
