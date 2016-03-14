#ifndef LAMBDADELEGATE_H
#define LAMBDADELEGATE_H

#include <QItemDelegate>
#include <QLineEdit>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QModelIndex>
#include <QObject>
#include <QSize>
#include <QString>

#define MAX_INTEGER  32768

class lambdaDelegate : public QItemDelegate
{
public:
    lambdaDelegate(QWidget *parent = 0);

    QWidget *createEditor (QWidget *parent, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
    void setEditorData (QWidget *editor, const QModelIndex &index) const;
    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
};



#endif // LAMBDADELEGATE_H


