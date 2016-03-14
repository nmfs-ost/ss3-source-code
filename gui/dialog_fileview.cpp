#include "dialog_fileview.h"
#include "ui_dialog_fileview.h"

#include <QPrinter>
#include <QPrintDialog>

Dialog_fileView::Dialog_fileView(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_fileView)
{
    ui->setupUi(this);

    connect (ui->pushButton_print, SIGNAL(clicked()), SLOT(print()));
    connect (ui->pushButton_close, SIGNAL(clicked()), SLOT(close()));
}

Dialog_fileView::~Dialog_fileView()
{
    delete ui;
}

void Dialog_fileView::viewFile(QString filename)
{
    ui->label_filename->setText(filename);

    QByteArray text;
    if (!filename.isEmpty())
    {
        QFile qf(filename);
        if (qf.open(QIODevice::ReadOnly))
        {
            text = qf.readAll();
            ui->plainTextEdit->setPlainText(QString(text));
        }
    }
}

void Dialog_fileView::print()
{
    QPrinter printer;
    QPrintDialog *qpd = new QPrintDialog(&printer, this);
    int action;
    action = qpd->exec();
    if (action == QDialog::Accepted)
        ui->plainTextEdit->print(&printer);
}
