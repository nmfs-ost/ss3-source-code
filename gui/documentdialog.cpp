#include "documentdialog.h"
#include "ui_documentdialog.h"
#include "metadata.h"

#include <QFileInfo>
#include <QFileDialog>

documentDialog::documentDialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::documentDialog)
{
    ui->setupUi(this);
    connect (ui->pushButton_manual, SIGNAL(clicked()), SLOT(chooseManual()));
    connect (ui->pushButton_technical, SIGNAL(clicked()), SLOT(chooseTechnical()));

    QSettings settings (app_copyright_org, app_name);
    settings.beginGroup("documents");
    ui->lineEdit_manual->setText(settings.value("manual").toString());
    ui->lineEdit_technical->setText(settings.value("technical").toString());
    settings.endGroup();
}

documentDialog::~documentDialog()
{
    QSettings settings (app_copyright_org, app_name);
    settings.beginGroup("documents");
    settings.setValue("manual", ui->lineEdit_manual->text());
    settings.setValue("technical", ui->lineEdit_technical->text());
    settings.endGroup();

    delete ui;
}

void documentDialog::chooseManual()
{
    QString filename (chooseDocument("User Manual"));
    ui->lineEdit_manual->setText(filename);
}

void documentDialog::chooseTechnical()
{
    QString filename (chooseDocument("Technical Description"));
    ui->lineEdit_technical->setText(filename);
}

QString documentDialog::chooseDocument(QString title)
{
    QString filename ("");
    QString str (QString ("Select %1 File").arg(title));
    filename = (QFileDialog::getOpenFileName (this, tr(str.toAscii()),
        qApp->applicationDirPath(), tr("documentation files (*.pdf)")));
    return filename;
}

