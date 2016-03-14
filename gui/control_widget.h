#ifndef CONTROL_WIDGET_H
#define CONTROL_WIDGET_H

#include <QWidget>

#include "input_file.h"
#include "tablemodel.h"
#include "tableview.h"
#include "lambdadelegate.h"

namespace Ui {
class control_widget;
}

class control_widget : public QWidget
{
    Q_OBJECT
    
public:
    explicit control_widget(QWidget *parent = 0);
    ~control_widget();
    
public slots:
    void read_file (QString fname = QString(""));
    void write_file (QString fname = QString(""));
    int read_data ();
    int write_data ();

private:
    Ui::control_widget *ui;

    tableview *lambdaview;
    lambdaDelegate *lambdaedit;
    QString filename;

    ss_file *in_file;
    ss_file *out_file;

};

#endif // CONTROL_WIDGET_H
