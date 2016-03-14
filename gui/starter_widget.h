#ifndef STARTER_WIDGET_H
#define STARTER_WIDGET_H

#include <QWidget>
#include <QString>
#include <QDir>
#include <QFile>
#include <QFont>

#include "input_file.h"

namespace Ui {
class starter_widget;
}

class starter_widget : public QWidget
{
    Q_OBJECT
    
public:
    explicit starter_widget(QWidget *parent = 0);
    ~starter_widget();

    QString end_of_file();

    bool param_file();

public slots:
    void set_starter_file (QString filename);
    QString starter_file ();
    void set_forecast_file (QString filename);
    QString forecast_file ();
    void set_control_file (QString filename);
    QString control_file ();
    void set_data_file (QString filename);
    QString data_file ();

    void read_file (QString fname = QString(""));
    void write_file (QString fname = QString(""));
    int read_data ();
    int write_data ();

signals:
    void directory_changed (QString dirname);
    void starter_file_changed (QString fname);
    void forecast_file_changed (QString fname);
    void control_file_changed (QString fname);
    void data_file_changed (QString fname);
    void choose_control_file();
    void choose_data_file();

private:
    Ui::starter_widget *ui;

    QString filename;

    input_file *in_file;
    input_file *out_file;

private slots:
    void parm_trace_changed(bool flag);
    void cumrpt_fits_changed(bool flag);
};

#endif // STARTER_WIDGET_H
