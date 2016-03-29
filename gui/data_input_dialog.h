#ifndef DATA_INPUT_DIALOG_H
#define DATA_INPUT_DIALOG_H

#include <QDialog>

namespace Ui {
class data_input_dialog;
}

class data_input_dialog : public QDialog
{
    Q_OBJECT

public:
    explicit data_input_dialog(QWidget *parent = 0);
    ~data_input_dialog();

private:
    Ui::data_input_dialog *ui;
};

#endif // DATA_INPUT_DIALOG_H
