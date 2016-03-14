#include "file_info_dialog.h"
#include "ui_file_info_dialog.h"

file_info_dialog::file_info_dialog(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::file_info_dialog)
{
    ui->setupUi(this);
}

file_info_dialog::file_info_dialog (ss_file *ifile, QWidget *parent) :
    QDialog(parent),
    ui(new Ui::file_info_dialog)
{
    ui->setupUi(this);

    file = ifile;
    ui->lineEdit_file_name->setText(file->fileName());
    set_comments(file->comments);

    connect (ui->buttonBox, SIGNAL(accepted()), SLOT(accept()));
    connect (ui->buttonBox, SIGNAL(rejected()), SLOT(close()));
//    connect (ui->plainTextEdit_comments, SIGNAL(textChanged()), SLOT(change_comments()));

 //   connect (ui->plainTextEdit_comments, SIGNAL(textChanged()), SLOT(change_comments()));
 //   connect (ui->pushButton_select, SIGNAL(clicked()), SLOT(choose_file()));
}

file_info_dialog::~file_info_dialog()
{
    delete ui;
}

void file_info_dialog::set_file_name(QString fname)
{
    file->setFileName(fname);
}

void file_info_dialog::set_comments (QStringList comments)
{
    QString cmnts ("");
    for (int i = 0; i < comments.count(); i++)
    {
        cmnts.append(comments.at(i));
        cmnts.append('\n');
    }
    ui->plainTextEdit_comments->setPlainText(cmnts);
}

void file_info_dialog::change_comments()
{
    QString cmnts = ui->plainTextEdit_comments->toPlainText();
    QStringList comments = cmnts.split('\n', QString::SkipEmptyParts);
/*    for (int i = 0; i < comments.count(); i++)
    {
        comments[i].prepend("#C ");
    }*/
    file->set_comments(comments);
}

void file_info_dialog::choose_file ()
{
    emit select_file (file);
    close();
}

void file_info_dialog::accept()
{
    change_comments();
    close();
}

