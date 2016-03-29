#include "tablemodel.h"

#include <QVector>
#include <QModelIndex>

tablemodel::tablemodel(QObject *parent)
  : QStandardItemModel(parent)
{
    reset();
}

tablemodel::~tablemodel()
{
    reset();
}


void tablemodel::setRowData(int row, QVector<double> rowdata)
{
    QList<QStandardItem *> px;
    if (row >= rowCount())
        setRowCount(row + 1);

    for (int i = 0; i < rowdata.count(); i++)
    {
        QStandardItem *pxi = new QStandardItem(QString::number(rowdata.at(i),'g',6));
        px << pxi;
    }
    insertRow(row, px);
    removeRow(row + 1);
}

void tablemodel::setRowData(int row, QStringList &rowstringlist)
{
    QList<QStandardItem *> px;
    if (row >= rowCount())
        setRowCount(row + 1);

    for (int i = 0; i < rowstringlist.count(); i++)
    {
        QStandardItem *pxi = new QStandardItem(rowstringlist.at(i));
        px << pxi;
    }
    insertRow(row, px);
    removeRow(row + 1);
}

void tablemodel::setRowData(int &row, QString rowstring)
{
    QStringList datalist (rowstring.split(' ', QString::SkipEmptyParts));
    setRowData(row, datalist);
/*    QList<QStandardItem *> px;
    for (int i = 0; i < datalist.count(); i++)
    {
        QStandardItem *pxi = new QStandardItem(datalist.at(i));
        px << pxi;
    }
    insertRow(row, px);
    removeRow(row + 1);*/
}

QStringList tablemodel::getRowData(int row)
{
    QVariant qdata;
    QStringList *newstring = new QStringList();

    for (int i = 0; i < columnCount(); i++)
    {
        qdata = data (index(row, i), Qt::EditRole);
        newstring->append(qdata.toString());
    }
    return *newstring;
}

QString tablemodel::getRowText(int row)
{
    QStringList list = getRowData(row);
    QString text("");
    for (int i = 0; i < list.count(); i++)
        text.append(QString(" %1").arg(list.at(i)));
    return text;
}

void tablemodel::setHeader(QStringList titles)
{
    for (int i = 0; i < titles.count(); i++)
        setHeaderData(i, Qt::Horizontal, titles.at(i));
}

void tablemodel::setColumnHeader(int column, QString title)
{
    setHeaderData(column, Qt::Horizontal, title);
}

void tablemodel::setRowHeader(int row, QString title)
{
    setHeaderData(row, Qt::Vertical, title);
}

