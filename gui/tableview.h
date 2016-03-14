#ifndef TABLEVIEW_H
#define TABLEVIEW_H

#include <QObject>
#include <QTableView>
#include <QKeyEvent>
#include <QMouseEvent>

#include "lineeditdelegate.h"

class tableview : public QTableView
{
public:
    tableview();

    void keyPressEvent(QKeyEvent *event);
    void mousePressEvent(QMouseEvent *event);

private:
    void copy();
    void paste();


};

#endif // TABLEVIEW_H
