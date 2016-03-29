#include "file_widget.h"
#include "ui_file_widget.h"

//#include "metadata.h"

#include <QFileDialog>
#include <QMessageBox>

file_widget::file_widget(QWidget *parent) :
    QWidget (parent),
    ui(new Ui::file_widget)
{
    ui->setupUi(this);
    QFont title_font ("Arial", 20, 4);

    in_file = NULL;
    out_file = NULL;

    title_font.setBold(true);
    ui->label_toolbox->setFont(title_font);
    title_font.setBold(false);
    title_font.setPointSize(18);
    ui->label_app_name->setFont(title_font);
    title_font.setPointSize(14);
    ui->label_app_version->setFont(title_font);

    connect (ui->lineEdit_starter_file, SIGNAL(textChanged(QString)), SIGNAL(starter_file_changed(QString)));
    connect (ui->lineEdit_forecast_file, SIGNAL(textChanged(QString)), SIGNAL(forecast_file_changed(QString)));
    connect (ui->pushButton_control_file, SIGNAL(clicked()), SIGNAL(choose_control_file()));
    connect (ui->pushButton_data_file, SIGNAL(clicked()), SIGNAL(choose_data_file()));

    ui->comboBox_detail_level->addItem("0 - only ADMB outputs");
    ui->comboBox_detail_level->addItem("1 - brief diplay for each iteration");
    ui->comboBox_detail_level->addItem("2 - fuller display");

    ui->comboBox_parm_trace_iter->addItem("Good iter");
    ui->comboBox_parm_trace_iter->addItem("Every iter");
    ui->comboBox_parm_trace_param->addItem("Active params");
    ui->comboBox_parm_trace_param->addItem("All params");
    connect (ui->checkBox_parm_trace, SIGNAL(toggled(bool)), SLOT(parm_trace_changed(bool)));
    connect (ui->checkBox_cumrpt_fits, SIGNAL(toggled(bool)), SLOT(cumrpt_fits_changed(bool)));

    ui->spinBox_datafiles->setMinimum(1);
    ui->spinBox_datafiles->setMaximum(10);

    connect ();
    connect ();
    connect ();


    parm_trace_changed(false);
    ui->tabWidget->setCurrentIndex(0);
}

file_widget::~file_widget()
{
    delete ui;
    delete in_file;
    delete out_file;
}

QString file_widget::end_of_file()
{
//    return ui->label_end_value->text();
}

bool file_widget::param_file()
{
    return ui->checkBox_parameter_file->isChecked();
}
void file_widget::set_starter_file(QString fname)
{
    filename = fname;
    ui->lineEdit_starter_file->setText(fname);
}


QString file_widget::starter_file()
{
    return ui->lineEdit_starter_file->text();
}

void file_widget::set_forecast_file(QString filename)
{
    ui->lineEdit_forecast_file->setText(filename);
}

QString file_widget::forecast_file ()
{
    return ui->lineEdit_forecast_file->text();
}

void file_widget::set_control_file(QString filename)
{
    ui->lineEdit_control_file->setText(filename);
}

QString file_widget::control_file()
{
    return ui->lineEdit_control_file->text();
}

void file_widget::set_data_file(QString filename)
{
    ui->lineEdit_data_file->setText(filename);
}

QString file_widget::data_file()
{
    return ui->lineEdit_data_file->text();
}

void file_widget::parm_trace_changed(bool flag)
{
    if (flag)
    {
        ui->comboBox_parm_trace_iter->show();
        ui->comboBox_parm_trace_param->show();
    }
    else
    {
        ui->comboBox_parm_trace_iter->hide();
        ui->comboBox_parm_trace_param->hide();
    }
}

void file_widget::cumrpt_fits_changed(bool flag)
{
    if (flag)
        ui->checkBox_cumrpt_like->setChecked(true);
}

void file_widget::read_file (QString fname)
{
    if (in_file->fileName() != fname)
    {
    if (!fname.isEmpty())
        set_starter_file(fname);

    if (!ui->lineEdit_starter_file->text().isEmpty())
    {
        if (in_file == NULL)
            in_file = new input_file(ui->lineEdit_starter_file->text());
        in_file->open(QIODevice::ReadOnly);
        read_data();
        in_file->close();
    }
    }
}

void file_widget::write_file (QString fname)
{
    if (!fname.isEmpty())
        set_starter_file(fname);

    out_file->setFileName(ui->lineEdit_starter_file->text());
    out_file->open(QIODevice::WriteOnly);
    write_data();
    out_file->close();
}

int file_widget::read_data()
{
    return (int)(0);
}

int file_widget::write_data ()
{
    QString line("");
    int temp_int = 0, chars = 0;
    return chars;
}

