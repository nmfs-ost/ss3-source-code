#ifndef INPUT_FILE_H
#define INPUT_FILE_H

#include <QFile>
#include <QStringList>

#define MAX_LINE_LENGTH 1024

#define END_OF_DATA   999  // signifies end of data in files
#define END_OF_LIST -9999  // signifies end of data values

#ifdef WIN32
 #define ENDLINE ("\r\n")
#else
 #ifdef MACOS
  #define ENDLINE ("\r")
 #else
  #define ENDLINE ("\n")
 #endif
#endif

class ss_file : public QFile
{
    Q_OBJECT
public:
    explicit ss_file(QString name, QObject *parent = 0);
    ~ss_file();

    QString next_value ();
    QString next_value (QString prompt);
    QString get_next_token();
    QString get_next_token(QString line);
    void return_token (QString tokn);

    QString get_line();
    int getLineNum() {return line_num;}

    void skip_line();// {current_line->clear(); current_tokens->clear();}

    QStringList comments;
    QString read_line();
    QStringList read_comments();
    QStringList get_comments() {return comments;}
    void set_comments(QStringList cmts);
    int write_comments();
    int newline();
    int writeline(QString str = QString(""));

    int read_int (QString info = QString(""));
    float read_float (QString info = QString(""));
/*    observation *read_environ_obs (QString info = QString(""));
    observation *read_length_obs (QString info = QString(""));
    observation *read_age_obs (QString info = QString(""));
    observation *read_saa_obs (QString info = QString(""));
    observation *read_discard_obs (QString info = QString(""));
    observation *read_mean_bw_obs (QString info = QString(""));
    observation *read_abund_obs (QString info = QString(""));
  */
    int write_int (int i_val, QString info = QString(""));
    int write_float (float f_val, QString info = QString(""));
/*    int write_environ_obs (observation *obs);
    int write_length_obs (observation *obs);
    int write_age_obs (observation *obs);
    int write_saa_obs (observation *obs);
    int write_discard_obs (observation *obs);
    int write_mean_bw_obs (observation *obs);
    int write_abund_obs (observation *obs);
  */

    bool at_eol ();

private:
    int line_num;
    QString *current_line;
    QStringList *current_tokens;

protected:
    QStringList *get_line_tokens();
    QStringList *get_line_tokens(QString *line);

    void append_file_line_info (QString &txt);

signals:
    
public slots:
    int error (QString msg);
    int message (QString msg);


};

#endif // INPUT_FILE_H
