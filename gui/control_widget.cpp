#include <QMessageBox>

#include "control_widget.h"
#include "ui_control_widget.h"


control_widget::control_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::control_widget)
{
    ui->setupUi(this);

    lambdaview = new tableview();
    lambdaedit = new lambdaDelegate(this);
    lambdaview->setItemDelegate(lambdaedit);
    lambdaview->setAcceptDrops(true);
//    lambdaview->setModel(model);
    in_file = 0;
    out_file = 0;

    ui->comboBox_mortality_method->addItem("Constant");
    ui->comboBox_mortality_method->addItem("Segmented");
    ui->comboBox_mortality_method->addItem("Lorenzen");
    ui->comboBox_mortality_method->addItem("Age specific");
    ui->comboBox_mortality_method->addItem("Age specific plus interpolated by season");
}

control_widget::~control_widget()
{
    delete ui;
}

void control_widget::read_file(QString fname)
{
    if (!fname.isEmpty())
    {
        if (in_file != NULL)
            delete in_file;
        filename = fname;
        in_file = new ss_file(filename);
    }

    if (!filename.isEmpty())
    {
        in_file->open (QIODevice::ReadOnly);
        read_data();
        in_file->close();
    }
}

void control_widget::write_file(QString fname)
{
    if (!fname.isEmpty())
    {
        if (out_file != NULL)
            delete out_file;
        filename = fname;
        out_file = new ss_file(filename);
    }

    if (!filename.isEmpty())
    {
        out_file->open (QIODevice::WriteOnly);
        write_data();
        out_file->close();
    }
}

int control_widget::read_data()
{
    QString token = in_file->get_next_token();
    QString temp_str;
    int temp_int = 0, param = 1;
    double temp_dbl;

    while (token.compare("EOF", Qt::CaseInsensitive) != 0)
    {
        QMessageBox::information(this, "Current Token", QString("token from file %1 is %2").arg(filename, token));

        if (token.startsWith('#'))
            in_file->skip_line();

        if (token.toInt() == 999 || param > 30)
        {
            token = QString ("EOF");
        }
        else
        {
            in_file->skip_line();
            token = in_file->get_next_token();
        }
    }
    return param;
}

int control_widget::write_data()
{
    QString line("");
    int temp_int = 0, chars = 0;
    line = QString ("%1 #_N_Growth_Patterns ").arg
            (QString::number(ui->spinBox_lambda_num->value()));
    chars += out_file->writeline (line);
    line = QString ("%1 #_N_Morphs_within_growthpattern ").arg
            (QString::number(ui->spinBox_lambda_num->value()));
    chars += out_file->writeline (line);

    line = QString (QString ("%1 #_N_Block_patterns").arg
                    (QString::number(ui->spinBox_break_points->value())));
    chars += out_file->writeline (line);

    line= QString::number(999);
    chars += out_file->writeline (line);
    return chars;
}
