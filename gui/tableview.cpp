#include "tableview.h"

#include <QApplication>
#include <QClipboard>
#include <QStandardItemModel>
#include <QItemSelectionModel>
#include <QModelIndexList>
#include <QStringList>


tableview::tableview()
{
}


void tableview::keyPressEvent(QKeyEvent *event)
{
    if (event->matches(QKeySequence::Copy))
    {
        copy();
    }
    else if (event->matches(QKeySequence::Paste))
    {
        paste();
    }
    else
    {
        QTableView::keyPressEvent(event);
    }
}

void tableview::copy()
{
    QStandardItemModel *abmodel = (QStandardItemModel *)model();
    QItemSelectionModel *selmodel = selectionModel();
    QModelIndexList list = selmodel->selectedIndexes();

    qSort(list);

    if(list.size() < 1)
        return;

    QString copy_table;
    QModelIndex last = list.last();
    QModelIndex previous = list.first();

    list.removeFirst();

    for(int i = 0; i < list.size(); i++)
    {
        QVariant data = abmodel->data(previous);
        QString text = data.toString();

        QModelIndex index = list.at(i);
        copy_table.append(text);

        if(index.row() != previous.row())

        {
            copy_table.append('\n');
        }
        else
        {
            copy_table.append('\t');
        }
        previous = index;
    }

    copy_table.append(abmodel->data(list.last(), Qt::EditRole).toString());
    copy_table.append('\n');

    QClipboard *clipboard = QApplication::clipboard();
    clipboard->setText(copy_table);
}

void tableview::paste()
{
    QAbstractItemModel *abmodel = model();
    QItemSelectionModel *selmodel = selectionModel();
    QModelIndexList list = selmodel->selectedIndexes();
    QClipboard *clipboard = QApplication::clipboard();
    QString text (clipboard->text());
    if (text.isEmpty())
        return;
    QStringList rowTextList (text.split('\n', QString::SkipEmptyParts));
    int row, col, curr_row, curr_col;

    if(rowTextList.count() < 1)
        return;

    qSort(list);

    if (list.isEmpty())
        return;

    row = list.first().row();
    col = list.first().column();
    QModelIndex curr_index = list.first();

    for(int i = 0; i < rowTextList.count(); i++)
    {
        curr_row = row + i;
        if (curr_row >= abmodel->rowCount())
             abmodel->insertRow(curr_row);//break;
        QStringList colTextList(rowTextList.at(i).split('\t', QString::SkipEmptyParts));
        for (int j = 0; j < colTextList.count(); j++)
        {
            curr_col = col + j;
            if (col >= abmodel->columnCount())
                break;
            curr_index = abmodel->index(curr_row, curr_col);

            abmodel->setData (curr_index, colTextList[j], Qt::EditRole);
            update(curr_index);
        }
    }
}

void tableview::mousePressEvent(QMouseEvent *event)
{
/*    if (event->button() == Qt::RightButton)
    {
        // display context menu
    }
    else*/
    {
        QTableView::mousePressEvent(event);
    }
}
