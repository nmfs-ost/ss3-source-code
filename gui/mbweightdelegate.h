#ifndef MBWEIGHTDELEGATE_H
#define MBWEIGHTDELEGATE_H

#include <QItemDelegate>
#include <QLineEdit>
#include <QSpinBox>
#include <QDoubleSpinBox>
#include <QModelIndex>
#include <QObject>
#include <QSize>
#include <QString>

#define MAX_INTEGER  32768

class mbweightdelegate : public QItemDelegate
{
public:
    mbweightdelegate(QWidget *parent = 0);

    QWidget *createEditor (QWidget *parent, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
    void setEditorData (QWidget *editor, const QModelIndex &index) const;
    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;

    void setYearRange(int start, int end) {startYear = start; endYear = end;}
    void setTypeRange(int start, int end) {minType = start; maxType = end;}
    void setPartRange(int start, int end) {minPart = start; maxPart = end;}
    void setValueRange(double min, double max) {minValue = min; maxValue = max;}
    void setErrorRange(double min, double max) {minError = min; maxError = max;}

    int startYear;
    int endYear;
    int minType;
    int maxType;
    int minPart;
    int maxPart;
    double minValue;
    double maxValue;
    double minError;
    double maxError;

};



#endif // MBWEIGHTDELEGATE_H


