#ifndef ABUNDANCEDELEGATE_H
#define ABUNDANCEDELEGATE_H

#include <QItemDelegate>
#include <QLineEdit>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QModelIndex>
#include <QObject>
#include <QSize>
#include <QString>

#define MAX_INTEGER  32768

class abundancedelegate : public QItemDelegate
{
public:
    abundancedelegate(QWidget *parent = 0);

    QWidget *createEditor (QWidget *parent, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
    void setEditorData (QWidget *editor, const QModelIndex &index) const;
    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;

    void setYearRange(int start, int end) {startYear = start; endYear = end;}
    void setMaxCatch(double amt) {maxCatch = amt;}
    void setValueRange(double min, double max) {minCatch = min; maxCatch = max;}

    int startYear;
    int endYear;
    double minCatch;
    double maxCatch;

};



#endif // ABUNDANCEDELEGATE_H


