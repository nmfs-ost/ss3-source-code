#ifndef DIALOGINPUTFILES_H
#define DIALOGINPUTFILES_H

#include <QDialog>

namespace Ui {
class DialogInputFiles;
}

class DialogInputFiles : public QDialog
{
    Q_OBJECT
    
public:
    explicit DialogInputFiles(QWidget *parent = 0);
    ~DialogInputFiles();
    
private:
    Ui::DialogInputFiles *ui;
};

#endif // DIALOGINPUTFILES_H
