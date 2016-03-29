#ifndef CHOOSE_YEAR_WIDGET_H
#define CHOOSE_YEAR_WIDGET_H

#include <QWidget>

namespace Ui {
class choose_year_widget;
}

class choose_year_widget : public QWidget
{
    Q_OBJECT
    
public:
    explicit choose_year_widget(QWidget *parent = 0);
    ~choose_year_widget();
    
private:
    Ui::choose_year_widget *ui;
};

#endif // CHOOSE_YEAR_WIDGET_H
