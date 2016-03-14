#include "lineeditdelegate.h"

lineEditDelegate::lineEditDelegate(QWidget *parent)
    : QItemDelegate(parent)
{
}

QWidget *lineEditDelegate::createEditor(QWidget *parent,
           const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    QLineEdit *editor = new QLineEdit(parent);
    return editor;
}

void lineEditDelegate::setEditorData(QWidget *editor,
         const QModelIndex &index) const
{
    QString text = index.model()->data(index, Qt::EditRole).toString();

    QLineEdit *line = static_cast<QLineEdit*>(editor);
    line->setText(text);
}

void lineEditDelegate::setModelData(QWidget *editor,
    QAbstractItemModel *model, const QModelIndex &index) const
{
    QLineEdit *line = static_cast<QLineEdit*>(editor);
    QString text = line->text();

    model->setData(index, text, Qt::EditRole);
}

void lineEditDelegate::updateEditorGeometry(QWidget *editor,
         const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    editor->setGeometry(option.rect);
}



intEditDelegate::intEditDelegate(QWidget *parent)
 : lineEditDelegate(parent)
{
    rangeSet = false;
    first_value = last_value = 0;
}

void intEditDelegate::setMinimum(int first)
{
    rangeSet = true;
    first_value = first;
    if (last_value < first_value)
        last_value = MAX_INTEGER;
}

void intEditDelegate::setMaximum(int last)
{
    rangeSet = true;
    last_value = last;
    if (last_value < first_value)
        first_value = last_value - 100;
}

void intEditDelegate::setRange(int first, int last)
{
    rangeSet = true;
    if (first < last)
    {
        first_value = first;
        last_value = last;
    }
    else
    {
        first_value = last;
        last_value = first;
    }
}

QString intEditDelegate::setText(QString txt)
{
    bool okay;
    value = txt.toInt(&okay);
    QString newtxt(txt);
    if (okay)
    {
        if (rangeSet)
        {
            if (value < first_value)
                value = first_value;
            if (value > last_value)
                value = last_value;
        }
        newtxt = QString::number(value);
    }
    return newtxt;
}

void intEditDelegate::setModelData(QWidget *editor,
         QAbstractItemModel *model, const QModelIndex &index) const
{
    QLineEdit *line = static_cast<QLineEdit*>(editor);
    QString text = line->text();
    model->setData(index, text, Qt::EditRole);
}

yearEditDelegate::yearEditDelegate(QWidget *parent)
 : intEditDelegate(parent)
{
    rangeSet = false;
    first_value = -30;
    last_value = 3000;
}


QString yearEditDelegate::setText(const QString txt)
{
    bool okay;
    QString newtxt(txt);
    value = txt.toInt(&okay);
    if (okay)
    {
        if (rangeSet)
        {
            if (value <= 0) value += last_value;
            if (value < first_value) value = first_value;
            if (value > last_value) value = last_value;
        }
        newtxt = QString::number(value);
    }
    return newtxt;
}



doubleEditDelegate::doubleEditDelegate(QWidget *parent)
 : lineEditDelegate(parent)
{
    precision = 6;
    rangeSet = false;
    first_value = last_value = 0;
}

void doubleEditDelegate::setPrecision(int prec)
{
    precision = prec;
}

void doubleEditDelegate::setMinimum(double first)
{
    rangeSet = true;
    first_value = first;
    if (last_value < first_value)
        last_value = first_value + 1;
}

void doubleEditDelegate::setMaximum(double last)
{
    rangeSet = true;
    last_value = last;
    if (last_value < first_value)
        first_value = last_value - 1;
}

void doubleEditDelegate::setRange(double first, double last)
{
    rangeSet = true;
    if (first < last)
    {
        first_value = first;
        last_value = last;
    }
    else
    {
        first_value = last;
        last_value = first;
    }
}

QString doubleEditDelegate::setText(const QString txt)
{
    bool okay;
    QString newtxt = txt;
    value = txt.toDouble(&okay);
    if (okay)
    {
        if (rangeSet)
        {
            if (value < first_value) value = first_value;
            if (value > last_value) value = last_value;
        }
        newtxt = QString::number(value, 'g', precision);
    }
    return newtxt;
}

void doubleEditDelegate::setModelData(QWidget *editor,
         QAbstractItemModel *model, const QModelIndex &index) const
{
    QLineEdit *line = static_cast<QLineEdit*>(editor);
    QString text = line->text();
    model->setData(index, text, Qt::EditRole);
}

