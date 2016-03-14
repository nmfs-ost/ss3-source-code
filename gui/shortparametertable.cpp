#include "shortparametertable.h"

shortParameterTable::shortParameterTable(int rows)
{
    model = QStandardItemModel (rows, 7, this);
    table = QTableView (this);
    delegate = doubleSpinBoxDelegate (this);

    model.setHeaderData(1, Qt::Horizontal, QString(" LO  "), Qt::DisplayRole);
    model.setHeaderData(2, Qt::Horizontal, QString(" HI  "), Qt::DisplayRole);
    model.setHeaderData(3, Qt::Horizontal, QString("INIT "), Qt::DisplayRole);
    model.setHeaderData(4, Qt::Horizontal, QString("PRIOR"), Qt::DisplayRole);
    model.setHeaderData(5, Qt::Horizontal, QString("PR_TYPE"), Qt::DisplayRole);
    model.setHeaderData(6, Qt::Horizontal, QString(" SD  "), Qt::DisplayRole);
    model.setHeaderData(7, Qt::Horizontal, QString("PHASE"), Qt::DisplayRole);
    table.setModel(&model);
    table.setItemDelegate(&delegate);

    connect (&delegate, SIGNAL(commitData(QWidget*)), SLOT(commitData(QWidget *)));
    connect (&model, SIGNAL(dataChanged(QModelIndex,QModelIndex)), SLOT(dataChanged(QModelIndex,QModelIndex)));
}

shortParameterTable::~shortParameterTable()
{

}


