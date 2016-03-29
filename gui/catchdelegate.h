#ifndef CATCHDELEGATE_H
#define CATCHDELEGATE_H

#include <QItemDelegate>
#include <QLineEdit>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QModelIndex>
#include <QObject>
#include <QSize>
#include <QString>

#define MAX_INTEGER  32768

class catchdelegate : public QItemDelegate
{
public:
    catchdelegate(QWidget *parent = 0);

    QWidget *createEditor (QWidget *parent, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
    void setEditorData (QWidget *editor, const QModelIndex &index) const;
    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;

    void setYearRange(int start, int end) {startYear = start; endYear = end;}
    void setNumSeasons(int seas) {numSeasons = seas;}
    void setMaxCatch(double amt) {maxCatch = amt;}
    int startYear;
    int endYear;
    int numSeasons;
    float maxCatch;
};



#endif // CATCHDELEGATE_H


