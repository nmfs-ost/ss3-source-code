#ifndef DIALOG_VIEW_H
#define DIALOG_VIEW_H

#include <QDialog>
#include <QFile>
#include <QTextDocument>

namespace Ui {
class Dialog_view;
}

class Dialog_view : public QDialog
{
    Q_OBJECT

public:
    explicit Dialog_view(QString filename = QString(""), QWidget *parent = 0);
    ~Dialog_view();

public slots:
    void print();
    void setText(QString txt);
    void setFileName(QString filename);

private:
    Ui::Dialog_view *ui;
    QFile *file;
    QTextDocument *doc;
};

#endif // DIALOG_VIEW_H
