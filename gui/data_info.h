#ifndef DATA_INFO_H
#define DATA_INFO_H

#include <QStringList>
#include <QFile>

class data_info
{
public:
    data_info();

    virtual int read();
    virtual int write();

    void set_filename (QString fname) {data_file.setFileName(fname); read();}
    QString filename () {return data_file.fileName();}

private:
    int line_num;
    QFile data_file;
    QString current_line;
    QStringList current_tokens;

    QString read_line();
    QStringList get_line_tokens();
    QString get_next_token();

    void skip_line();

    void print_error (QString err);
    void print_message (QString msg);
};

#endif // DATA_INFO_H
