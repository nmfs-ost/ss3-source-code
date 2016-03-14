
#include "doublespinboxdelegate.h"

doubleSpinBoxDelegate::doubleSpinBoxDelegate(QObject *parent)
    : QItemDelegate (parent)
{
    minimum = 0;
    maximum = 100;
    digits = 6;
}

QWidget *doubleSpinBoxDelegate::createEditor(QWidget *parent,
    const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    QDoubleSpinBox *editor = new QDoubleSpinBox(parent);
    editor->setRange(minimum, maximum);

    return editor;
}

void doubleSpinBoxDelegate::setEditorData(QWidget *editor,
    const QModelIndex &index) const
{
    int value = index.model()->data(index, Qt::EditRole).toInt();

    QDoubleSpinBox *spinBox = static_cast<QDoubleSpinBox*>(editor);
    spinBox->setValue(value);
}

void doubleSpinBoxDelegate::setModelData(QWidget *editor,
    QAbstractItemModel *model, const QModelIndex &index) const
{
    QDoubleSpinBox *spinBox = static_cast<QDoubleSpinBox*>(editor);
    spinBox->interpretText();
    int value = spinBox->value();

    model->setData(index, value, Qt::EditRole);
}

void doubleSpinBoxDelegate::updateEditorGeometry(QWidget *editor,
    const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    editor->setGeometry(option.rect);
}

