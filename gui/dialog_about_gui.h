#ifndef DIALOG_ABOUT_GUI_H
#define DIALOG_ABOUT_GUI_H

#include <QDialog>

namespace Ui {
class Dialog_about_gui;
}

class Dialog_about_gui : public QDialog
{
    Q_OBJECT

public:
    explicit Dialog_about_gui(QWidget *parent = 0);
    ~Dialog_about_gui();

private:
    Ui::Dialog_about_gui *ui;

signals:
    void showAboutSS();
    void showAboutQt();
};

#endif // DIALOG_ABOUT_GUI_H
