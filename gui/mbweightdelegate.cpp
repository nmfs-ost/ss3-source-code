#include "mbweightdelegate.h"

mbweightdelegate::mbweightdelegate(QWidget *parent)
    : QItemDelegate(parent)
{
    setYearRange(1950, 2020);
    setTypeRange(0, 2);
    setPartRange(0, 2);
    setValueRange(0, 20);
    setErrorRange(0, 1.0);
}

QWidget *mbweightdelegate::createEditor(QWidget *parent,
           const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    QWidget *editor;
    switch (index.column())
    {
    case 0:
        editor = new QSpinBox(parent);
        static_cast<QSpinBox*>(editor)->setRange(startYear, endYear);
        break;
    case 1:
        editor = new QDoubleSpinBox(parent);
        static_cast<QDoubleSpinBox*>(editor)->setRange(1, 12.999);
        break;
    case 2:
        editor = new QSpinBox(parent);
        static_cast<QSpinBox*>(editor)->setRange(minType, maxType);
        break;
    case 3:
        editor = new QSpinBox(parent);
        static_cast<QSpinBox*>(editor)->setRange(minPart, maxPart);
        break;
    case 4:
        editor = new QDoubleSpinBox(parent);
        static_cast<QDoubleSpinBox*>(editor)->setRange(minValue, maxValue);

        break;
    case 5:
        editor = new QDoubleSpinBox(parent);
        static_cast<QDoubleSpinBox*>(editor)->setRange(minError, maxError);
        static_cast<QDoubleSpinBox*>(editor)->setDecimals(3);
        break;
    default:
        editor = new QLineEdit(parent);
    }

    return editor;
}

void mbweightdelegate::setEditorData(QWidget *editor,
         const QModelIndex &index) const
{
    switch (index.column())
    {
    case 0:
    case 2:
    case 3:
    {
        int val = index.model()->data(index, Qt::EditRole).toInt();
        QSpinBox *int_ed = static_cast<QSpinBox*>(editor);
        int_ed->setValue(val);
        break;
    }
    case 1:
    case 4:
    case 5:
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

void mbweightdelegate::setModelData(QWidget *editor,
    QAbstractItemModel *model, const QModelIndex &index) const
{
    switch (index.column())
    {
    case 0:
    case 2:
    case 3:
    {
        QSpinBox *int_ed = static_cast<QSpinBox*>(editor);
        int val = int_ed->value();
        model->setData(index, QString::number(val), Qt::EditRole);
        break;
    }
    case 1:
    case 4:
    case 5:
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

void mbweightdelegate::updateEditorGeometry(QWidget *editor,
         const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    editor->setGeometry(option.rect);
}

