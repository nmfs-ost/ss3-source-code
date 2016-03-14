#ifndef DIALOG_FILEVIEW_H
#define DIALOG_FILEVIEW_H

#include <QDialog>
#include <QString>

namespace Ui {
class Dialog_fileView;
}

class Dialog_fileView : public QDialog
{
    Q_OBJECT

public:
    explicit Dialog_fileView(QWidget *parent = 0);
    ~Dialog_fileView();

public slots:
    void viewFile(QString filename);

private:
    Ui::Dialog_fileView *ui;

private slots:
    void print();
};

#endif // DIALOG_FILEVIEW_H
