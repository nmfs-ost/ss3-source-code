#ifndef FILE_INFO_DIALOG_H
#define FILE_INFO_DIALOG_H

#include <QDialog>
#include "input_file.h"

namespace Ui {
class file_info_dialog;
}

class file_info_dialog : public QDialog
{
    Q_OBJECT

public:
    explicit file_info_dialog(QWidget *parent = 0);
    file_info_dialog (ss_file *ifile, QWidget *parent = 0);
    ~file_info_dialog();

public slots:
    void set_file_name (QString fname);
    void set_comments (QStringList comments);
    void change_comments ();
    void choose_file ();
    void accept();

signals:
    void select_file (ss_file *ifile);

private:
    ss_file *file;
    Ui::file_info_dialog *ui;
};

#endif // FILE_INFO_DIALOG_H
