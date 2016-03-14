
#include "doublespinboxdelegate.h"

doubleSpinBoxDelegate::doubleSpinBoxDelegate(QObject *parent)
    : QItemDelegate (parent)
{
}

QWidget *doubleSpinBoxDelegate::createEditor(QWidget *parent,
    const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    QDoubleSpinBox *editor = new QDoubleSpinBox(parent);
    editor->setMinimum(0);
    editor->setMaximum(100);

    return editor;
}

void doubleSpinBoxDelegate::setMinimum(QWidget *editor, double value)
{
    QDoubleSpinBox *doubleSpinBox = static_cast<QDoubleSpinBox*>(editor);
    doubleSpinBox->setMinimum(value);
}

void doubleSpinBoxDelegate::setMaximum(QWidget *editor, double value)
{
    QDoubleSpinBox *doubleSpinBox = static_cast<QDoubleSpinBox*>(editor);
    doubleSpinBox->setMaximum(value);
}

void doubleSpinBoxDelegate::setPrecision(QWidget *editor, int prec)
{
    QDoubleSpinBox *doubleSpinBox = static_cast<QDoubleSpinBox*>(editor);
    doubleSpinBox->setDecimals(prec);
}

void doubleSpinBoxDelegate::setEditorData(QWidget *editor,
    const QModelIndex &index) const
{
    double value = index.model()->data(index, Qt::EditRole).toInt();

    QDoubleSpinBox *doubleSpinBox = static_cast<QDoubleSpinBox*>(editor);
    doubleSpinBox->setValue(value);
}

void doubleSpinBoxDelegate::setModelData(QWidget *editor,
    QAbstractItemModel *model, const QModelIndex &index) const
{
    QDoubleSpinBox *doubleSpinBox = static_cast<QDoubleSpinBox*>(editor);
    doubleSpinBox->interpretText();
    double value = doubleSpinBox->value();

    model->setData(index, value, Qt::EditRole);
}

void doubleSpinBoxDelegate::updateEditorGeometry(QWidget *editor,
    const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    editor->setGeometry(option.rect);
}

