#include "dialog_view.h"
#include "ui_dialog_view.h"

#include <QPrintDialog>
#include <QPrinter>
#include <QTextDocument>

Dialog_view::Dialog_view(QString filename, QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_view)
{
    ui->setupUi(this);

    connect (ui->pushButton_done, SIGNAL(clicked()), SLOT(accept()));
    connect (ui->pushButton_print, SIGNAL(clicked()), SLOT(print()));

    file = new QFile(this);
    if (!filename.isEmpty())
        setFileName(filename);

    doc = new QTextDocument(this);
}

Dialog_view::~Dialog_view()
{
    delete ui;
}

void Dialog_view::print()
{
    QPrinter printer;
//    QTextDocument doc (ui->plainTextEdit->toPlainText(), this);

    QPrintDialog *dialog = new QPrintDialog(&printer, this);
    dialog->setWindowTitle(tr("Print Document"));
    if (dialog->exec() != QDialog::Accepted)
        return;

    doc->print(&printer);
}

void Dialog_view::setFileName(QString filename)
{
    QString txt("");
    file->setFileName(filename);
    if(file->isReadable())
    {
        file->open(QIODevice::ReadOnly);
        while (!file->atEnd())
            txt.append(file->readLine(256));
        file->close();
        doc->setPlainText(txt);
        doc->setDefaultFont(QFont("Courier New", 11));
        setText(txt);
    }
    else
    {
        setText(QString("File '%1' is unreadable.").arg(filename));
    }
}

void Dialog_view::setText(QString txt)
{
    ui->plainTextEdit->clear();
    ui->plainTextEdit->appendPlainText(txt);
}
