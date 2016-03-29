#ifndef DIALOG_ABOUT_ADMB_H
#define DIALOG_ABOUT_ADMB_H

#include <QDialog>

namespace Ui {
class Dialog_About_ADMB;
}

class Dialog_About_ADMB : public QDialog
{
    Q_OBJECT

public:
    explicit Dialog_About_ADMB(QWidget *parent = 0);
    ~Dialog_About_ADMB();

signals:
    void show_webpage (QString pg);

public slots:
    void goToWebpage ();

private:
    Ui::Dialog_About_ADMB *ui;
};

#endif // DIALOG_ABOUT_ADMB_H
