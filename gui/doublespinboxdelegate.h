#ifndef DOUBLESPINBOXDELEGATE_H
#define DOUBLESPINBOXDELEGATE_H

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
    void setMinimum (double value) {minimum = value;}
    void setMaximum (double value) {maximum = value;}
    void setRange (double lowvalue, double highvalue) {minimum = lowvalue; maximum = highvalue;}
    void setDigits (int number) {digits = number;}
    void setEditorData (QWidget *editor, const QModelIndex &index) const;
    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;

protected:
    double minimum;
    double maximum;
    int digits;
};

#endif // DOUBLESPINBOXDELEGATE_H
