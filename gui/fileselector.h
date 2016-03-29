#ifndef FILESELECTOR_H
#define FILESELECTOR_H

#include <QWidget>

namespace Ui {
class FileSelector;
}

class FileSelector : public QWidget
{
    Q_OBJECT
    
public:
    explicit FileSelector(QWidget *parent = 0);
    ~FileSelector();
    
private:
    Ui::FileSelector *ui;
};

#endif // FILESELECTOR_H
