#include "lambdadelegate.h"

lambdaDelegate::lambdaDelegate(QWidget *parent)
    : QItemDelegate(parent)
{
}

QWidget *lambdaDelegate::createEditor(QWidget *parent,
           const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    QWidget *editor;
    switch (index.column())
    {
    case 0:
    case 1:
    case 2:
    case 4:
        editor = new QSpinBox(parent);
        break;
    case 3:
        editor = new QDoubleSpinBox(parent);
        break;
    default:
        editor = new QLineEdit(parent);
    }

    return editor;
}

void lambdaDelegate::setEditorData(QWidget *editor,
         const QModelIndex &index) const
{
    switch (index.column())
    {
    case 0:
    case 1:
    case 2:
    case 4:
    {
        int val = index.model()->data(index, Qt::EditRole).toInt();
        QSpinBox *int_ed = static_cast<QSpinBox*>(editor);
        int_ed->setValue(val);
        break;
    }
    case 3:
    {
        double value = index.model()->data(index, Qt::EditRole).toDouble();
        QDoubleSpinBox *doub_ed = static_cast<QDoubleSpinBox*>(editor);
        doub_ed->setValue(value);
        break;
    }
    default:
    {
        QString text = index.model()->data(index, Qt::EditRole).toString();
        QLineEdit *line = static_cast<QLineEdit*>(editor);
        line->setText(text);
    }
    }
}

void lambdaDelegate::setModelData(QWidget *editor,
    QAbstractItemModel *model, const QModelIndex &index) const
{
    switch (index.column())
    {
    case 0:
    case 1:
    case 2:
    case 4:
    {
        QSpinBox *int_ed = static_cast<QSpinBox*>(editor);
        int val = int_ed->value();
        model->setData(index, QString::number(val), Qt::EditRole);
        break;
    }
    case 3:
    {
        QDoubleSpinBox *doub_ed = static_cast<QDoubleSpinBox*>(editor);
        double value = doub_ed->value();
        model->setData(index, QString::number(value), Qt::EditRole);
        break;
    }
    default:
    {
        QLineEdit *line = static_cast<QLineEdit*>(editor);
        QString text = line->text();
        model->setData(index, text, Qt::EditRole);
    }
    }
}

void lambdaDelegate::updateEditorGeometry(QWidget *editor,
         const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    editor->setGeometry(option.rect);
}

