#ifndef LINEEDITDELEGATE_H
#define LINEEDITDELEGATE_H

#include <QItemDelegate>
#include <QLineEdit>
#include <QModelIndex>
#include <QObject>
#include <QSize>
#include <QString>

#define MAX_INTEGER  32768

class lineEditDelegate : public QItemDelegate
{
public:
    lineEditDelegate(QWidget *parent = 0);

    QWidget *createEditor (QWidget *parent, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
    void setEditorData (QWidget *editor, const QModelIndex &index) const;
    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;
    void updateEditorGeometry(QWidget *editor, const QStyleOptionViewItem &option,
                       const QModelIndex &index) const;
};


class intEditDelegate : public lineEditDelegate
{
public:
    intEditDelegate(QWidget *parent = 0);

    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;

    QString setText (QString txt);
    void setMinimum (int first);
    void setMaximum (int last);
    void setRange (int first, int last);

protected:
    int value;

    bool rangeSet;
    int first_value;
    int last_value;
};

class yearEditDelegate : public intEditDelegate
{
public:
    yearEditDelegate(QWidget *parent = 0);

    QString setText(const QString txt) ;

};

class doubleEditDelegate : public lineEditDelegate
{
public:
    doubleEditDelegate(QWidget *parent = 0);

    QString setText (const QString txt);
    void setModelData (QWidget *editor, QAbstractItemModel *model,
                       const QModelIndex &index) const;

    void setMinimum (double first);
    void setMaximum (double last);
    void setRange (double first, double last);
    void setPrecision (int prec);

protected:
    int precision;
    double value;

    bool rangeSet;
    double first_value;
    double last_value;
};


#endif // LINEEDITDELEGATE_H


