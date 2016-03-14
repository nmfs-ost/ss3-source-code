#ifndef OBSERVATION_DIALOG_H
#define OBSERVATION_DIALOG_H

#include <QDialog>

namespace Ui {
class observation_dialog;
}

class observation_dialog : public QDialog
{
    Q_OBJECT

public:
    explicit observation_dialog(QWidget *parent = 0);
    ~observation_dialog();

    void setTitle(QString title);

    void addItem(QString item);
    void setItem(int index, QString item);
    QString getItem(int index);

public slots:
    void dataChanged();
    QString editItem(int index);

signals:
    void itemChanged(int);

private:
    int currentItem;
    bool changed;

    Ui::observation_dialog *ui;
};

#endif // OBSERVATION_DIALOG_H
