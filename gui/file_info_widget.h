#ifndef FILE_INFO_WIDGET_H
#define FILE_INFO_WIDGET_H

#include <QWidget>

namespace Ui {
class file_info_widget;
}

class file_info_widget : public QWidget
{
    Q_OBJECT

public:
    explicit file_info_widget(QWidget *parent = 0);
    ~file_info_widget();

private:
    Ui::file_info_widget *ui;
};

#endif // FILE_INFO_WIDGET_H
