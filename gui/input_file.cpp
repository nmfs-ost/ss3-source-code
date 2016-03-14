#include "input_file.h"

#include <QMessageBox>

ss_file::ss_file(QString name, QObject *parent) :
    QFile(parent)
{
    setFileName(name);
    line_num = 0;
    current_line = new QString("");
    current_tokens = new QStringList(*current_line);
    current_tokens->clear();
}

ss_file::~ss_file ()
{
    delete current_line;
    delete current_tokens;
}


QString ss_file::read_line()
{
    if (atEnd())
        return QString("EOF");
    else
    {
        QByteArray qba = readLine(MAX_LINE_LENGTH);
        line_num++;
        return QString (qba);
    }
}

void ss_file::skip_line()
{
    if (current_line->count() > 0)
        current_line->clear();
    if (current_tokens->count() > 0)
        current_tokens->clear();
}

bool ss_file::at_eol()
{
    bool flag = false;
    if (current_tokens->count() == 0)
        flag = true;
    return flag;
}

QStringList ss_file::read_comments()
{
    QString cmt, token (get_next_token());
    comments.clear();

    while (token.startsWith("#"))
    {
        if (current_line->startsWith("#C"))
        {
            cmt = current_line->section("#C", 1, -1);
            while (cmt.startsWith(' '))
                cmt = cmt.section(' ', 1, -1);
            while (cmt.endsWith('\n') || cmt.endsWith('\r'))
                cmt.chop(1);
            comments.append(cmt);
        }
        skip_line();
        token = get_next_token();
    }
    get_line_tokens(current_line);
    return comments;
}

void ss_file::set_comments(QStringList cmts)
{
    comments.clear();
    for (int i = 0; i < cmts.count(); i++)
    {
        comments.append(QString(cmts.at(i)));
    }
}

int ss_file::write_comments()
{
    int chars;
    QString cmt, line;
    for (int i = 0; i < comments.count(); i++)
    {
//        cmt = comments.at(i);
        line = QString("#C %1").arg(comments.at(i));
        chars = writeline (line);
    }
    return chars;
}

int ss_file::writeline(QString str)
{
    int chars = 0;
    chars += write (str.toAscii());
    chars += newline();
    return chars;
}

int ss_file::newline()
{
    return write (ENDLINE);
}

/* Get the next line from the input file,
 * and separate by tabs and spaces into separate tokens. */
QStringList *ss_file::get_line_tokens()
{
    if (current_line->count() > 0)
        current_line->clear();
    current_line->append(read_line());

    return get_line_tokens(current_line);
}

QStringList *ss_file::get_line_tokens(QString *line)
{
    QString last;

    current_tokens->clear();
    QStringList cl(line->split('\t', QString::SkipEmptyParts));
    for (int i = 0; i < cl.count(); i++)
        current_tokens->append(cl.at(i).split (' ', QString::SkipEmptyParts));

    last = current_tokens->takeLast();
    if (last.compare("\n") != 0)
    {
        last = last.split ('\n', QString::SkipEmptyParts).takeFirst();
        if (last.compare("\r") != 0)
            last = last.split ('\r', QString::SkipEmptyParts).takeFirst();
        else
            last.clear();
    }
    else
        last.clear();
    if (!last.isEmpty())
       current_tokens->append(last);
    if (current_tokens->count() == 0)
        get_line_tokens();

    return current_tokens;
}

QString ss_file::next_value()
{
    QString tk (get_next_token());
    while (tk.startsWith("#"))
    {
        skip_line();
        tk = get_next_token();
    }
    return tk;
}

QString ss_file::next_value(QString prompt)
{
    QString tk (next_value());
    if (tk.compare("EOF") == 0)
    {
        QString msg(QString("Found EOF when looking for %1 in file %2.")
                       .arg(prompt, this->fileName()));
 //       QMessageBox::critical(0, tr("Input File unexpected EOF"), msg);
    }
    return tk;
}

QString ss_file::get_next_token()
{
    if (current_tokens->count() == 0)
    {
        get_line_tokens();
    }

    return current_tokens->takeFirst();
}

QString ss_file::get_next_token(QString line)
{
    if (line.isEmpty())
        get_line_tokens();
    else
        get_line_tokens(&line);
    if (current_tokens->count() == 0)
    {
        get_line_tokens();
    }

    return current_tokens->takeFirst();
}

void ss_file::return_token(QString tokn)
{
    current_tokens->prepend(tokn);
}

QString ss_file::get_line()
{
    if (current_line->isEmpty())
        get_line_tokens();
    QString line (*current_line);
//    skip_line();
    return line;
}

void ss_file::append_file_line_info (QString &txt)
{
    txt.append(QString ("\n  File: %1  Line: %2").arg(fileName(), QString::number (line_num)));
}

int ss_file::error (QString err)
{
    append_file_line_info (err);
    int btn = QMessageBox::critical((QWidget*)parent(), tr("Error"), err, QMessageBox::Cancel | QMessageBox::Ok);
    return btn;
}


int ss_file::message(QString msg)
{
    append_file_line_info (msg);
    int btn = QMessageBox::information((QWidget*)parent(), tr("Information"), msg, QMessageBox::Ok);
    return btn;
}
