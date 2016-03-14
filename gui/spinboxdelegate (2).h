#ifndef SPINBOXDELEGATE_H
#define SPINBOXDELEGATE_H

#include <QItemDelegate>
#include <QModelIndex>
#include <QObject>
#include <QSize>
#include <QDoubleSpinBox>

class doubleSpinBoxDelegate : public QItemDelegate
{
    Q_OBJECT

public:
    doubleSpinBoxDelegate(QObject *parent = 0);

    QWidget *createEditor (QWidget *parent, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
    void setMinimum (QWidget *editor, double value);
    void setMaximum (QWidget *editor, double value);
    void setPrecision(QWidget *editor, int prec);
    void setEditorData (QWidget *editor, const QModelIndex &index) const;
    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
};

#endif // SPINBOXDELEGATE_H
