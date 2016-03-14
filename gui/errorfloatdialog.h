#ifndef ERRORFLOATDIALOG_H
#define ERRORFLOATDIALOG_H

//#include <QDialog>
//#include <QDoubleSpinBox>
#include <QtCore/QVariant>
#include <QtGui/QAction>
#include <QtGui/QApplication>
#include <QtGui/QButtonGroup>
#include <QtGui/QDialog>
#include <QtGui/QDialogButtonBox>
#include <QtGui/QDoubleSpinBox>
#include <QtGui/QHBoxLayout>
#include <QtGui/QHeaderView>
#include <QtGui/QLabel>
#include <QtGui/QVBoxLayout>
#define MAX_FLOAT_VALUES 9
/*
namespace Ui {
class ErrorFloatDialog;
}*/

class ErrorFloatDialog : public QDialog
{
    Q_OBJECT

public:
    explicit ErrorFloatDialog(QWidget *parent = 0);
    explicit ErrorFloatDialog(QWidget *parent, QString title, QString label, int numValues, bool sum = true);
    ~ErrorFloatDialog();

    void setTitle (QString title);
    void setLabel (QString label);
    void setValueLabel (QString label);
    void setNumValues(int num);
    void setValue (int index, QString txt);
    void setValue (int index, float val);
    float getValue (int index);
    float getTotal ();
    void setSum (bool flag);
    void setSumLabel (QString label);
    void setSumValue (float val);

    QString toText();
    void fromText (QString txt);

    bool checkValsWithSum ();

public slots:
    void acceptedClicked();
    void rejectedClicked();

private:
//    Ui::ErrorFloatDialog *ui;
    void setup();
    void retranslate();

    bool showSum;
    QList <QDoubleSpinBox *> boxes;
    float sumVal;

    QVBoxLayout *verticalLayout;
    QLabel *label_label;
    QHBoxLayout *horizontalLayout_values;
    QLabel *label_values;
    QHBoxLayout *horizontalLayout_sum;
    QLabel *label_sum;
    QDoubleSpinBox *doubleSpinBox_sum;
    QDialogButtonBox *buttonBox;
};

#endif // ERRORFLOATDIALOG_H
