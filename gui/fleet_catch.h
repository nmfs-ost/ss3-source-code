#ifndef FLEET_CATCH_H
#define FLEET_CATCH_H

#include <QAbstractTableModel>

class fleet_catch : public QAbstractTableModel
{
public:
    fleet_catch(QObject *parent = 0);
    ~fleet_catch();

/*    int rowCount(const QModelIndex &parent) const;
    bool insertRow(int row, const QModelIndex &parent);
    bool removeRow(int row, const QModelIndex &parent);

    QVariant data(const QModelIndex &index, int role) const;
    bool setData(const QModelIndex &index, const QVariant &value, int role);

    QVariant headerData(int section, Qt::Orientation orientation, int role) const;
    bool setHeaderData(int section, Qt::Orientation orientation, const QVariant &value, int role);


    Qt::ItemFlags flags(const QModelIndex &index) const;*/
public slots:
};

#endif // FLEET_CATCH_H
