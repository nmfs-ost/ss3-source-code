#ifndef TABLEMODEL_H
#define TABLEMODEL_H

#include <QStandardItemModel>
#include <QHeaderView>
#include <QVector>
#include <QStringList>

class tablemodel : public QStandardItemModel
{
public:
    tablemodel(QObject *parent = 0);
    ~tablemodel();

    void reset() {setRowCount(0);}

    void setRowData(int &row, QString rowstring);
    void setRowData(int row, QStringList &rowstringlist);
    void setRowData(int row, QVector<double> rowdata);

    QStringList getRowData (int row);
    QString getRowText (int row);

    void setHeader (QStringList titles);
    void setColumnHeader (int column, QString title);
    void setRowHeader (int row, QString title);

};

class shortParameterModel : public tablemodel
{
    shortParameterModel(QObject *parent = 0);
};

#endif // TABLEMODEL_H
