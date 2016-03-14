#ifndef ABOUT_WIDGET_H
#define ABOUT_WIDGET_H

#include <QWidget>

namespace Ui {
class about_widget;
}

class about_widget : public QWidget
{
    Q_OBJECT

public:
    explicit about_widget(QWidget *parent = 0);
    ~about_widget();

private:
    Ui::about_widget *ui;
};

#endif // ABOUT_WIDGET_H
