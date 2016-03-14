#include "abundancedelegate.h"

abundancedelegate::abundancedelegate(QWidget *parent)
    : QItemDelegate(parent)
{
    startYear = 1950;
    endYear = 2020;
    minCatch = 0.0;
    maxCatch = 199999.0;
}

QWidget *abundancedelegate::createEditor(QWidget *parent,
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
        editor = new QDoubleSpinBox(parent);
        static_cast<QDoubleSpinBox*>(editor)->setRange(minCatch, maxCatch);

        break;
    case 3:
        editor = new QDoubleSpinBox(parent);
        static_cast<QDoubleSpinBox*>(editor)->setRange(0.0, 1.0);
        static_cast<QDoubleSpinBox*>(editor)->setDecimals(3);
        break;
    default:
        editor = new QLineEdit(parent);
    }

    return editor;
}

void abundancedelegate::setEditorData(QWidget *editor,
         const QModelIndex &index) const
{
    switch (index.column())
    {
    case 0:
    {
        int val = index.model()->data(index, Qt::EditRole).toInt();
        QSpinBox *int_ed = static_cast<QSpinBox*>(editor);
        int_ed->setValue(val);
        break;
    }
    case 1:
    case 2:
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

void abundancedelegate::setModelData(QWidget *editor,
    QAbstractItemModel *model, const QModelIndex &index) const
{
    switch (index.column())
    {
    case 0:
    {
        QSpinBox *int_ed = static_cast<QSpinBox*>(editor);
        int val = int_ed->value();
        model->setData(index, QString::number(val), Qt::EditRole);
        break;
    }
    case 1:
    case 2:
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

void abundancedelegate::updateEditorGeometry(QWidget *editor,
         const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    editor->setGeometry(option.rect);
}

