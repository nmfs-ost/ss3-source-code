#ifndef DIALOG_YEARLYVALUES_H
#define DIALOG_YEARLYVALUES_H

#include <QDialog>

namespace Ui {
class Dialog_YearlyValues;
}

class Dialog_YearlyValues : public QDialog
{
    Q_OBJECT
    
public:
    explicit Dialog_YearlyValues(QWidget *parent = 0);
    ~Dialog_YearlyValues();
    
private:
    Ui::Dialog_YearlyValues *ui;
};

#endif // DIALOG_YEARLYVALUES_H
