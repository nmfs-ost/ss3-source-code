#ifndef SHORTPARAMETERTABLE_H
#define SHORTPARAMETERTABLE_H

#include <QWidget>
#include <QTableView>
#include <QStandardItemModel>
#include <QHeaderView>
#include <QStringList>

#include "doublespinboxdelegate.h"
#include "short_parameter.h"

class shortParameterTable : public QWidget
{
    Q_OBJECT

public:
    shortParameterTable(int rows);
    ~shortParameterTable();

public slots:
    void setTopHeader (QStringList titles);
    void hideTopHeader ();
    void setSideHeader (QStringList titles);

    void addParameter(int row, shortParameter *sp);
    void commitData (QWidget *item);
    void dataChanged (QModelIndex ind1, QModelIndex ind2);

signals:
    void parameterChanged (int row, shortParameter *sp);

private:
    QStandardItemModel model;
    QTableView table;
    doubleSpinBoxDelegate delegate;

    QList<shortParameter *> params;

};

#endif // SHORTPARAMETERTABLE_H
