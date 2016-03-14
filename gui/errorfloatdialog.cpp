#include "errorfloatdialog.h"
#include "ui_errorfloatdialog.h"

ErrorFloatDialog::ErrorFloatDialog(QWidget *parent) :
    QDialog(parent)/*,
    ui(new Ui::ErrorFloatDialog)*/
{
    setup();
//    ui->setupUi(this);
    setSumValue(0);
}

ErrorFloatDialog::~ErrorFloatDialog()
{
//    delete ui;
    while (boxes.count() > 0)
    {
        QDoubleSpinBox *ds = boxes.takeLast();
        delete ds;
    }
}

ErrorFloatDialog::ErrorFloatDialog(QWidget *parent, QString title, QString label, int numValues, bool sum) :
    QDialog(parent)/*,
    ui(new Ui::ErrorFloatDialog)*/
{
    setTitle(title);
    setLabel(label);
    setNumValues(numValues);
    setSum (sum);
    setSumValue(0);
}

void ErrorFloatDialog::setTitle (QString title)
{
    setWindowTitle((title));
}

void ErrorFloatDialog::setLabel (QString label)
{
    label_label->setText((label));
}

void ErrorFloatDialog::setValueLabel (QString label)
{
    label_values->setText((label));
}

void ErrorFloatDialog::setSum(bool flag)
{
    label_sum->setVisible(flag);
    doubleSpinBox_sum->setVisible(flag);
}

void ErrorFloatDialog::setSumLabel (QString label)
{
    label_sum->setText((label));
}

void ErrorFloatDialog::setNumValues(int num)
{
    QDoubleSpinBox *ds = NULL;

    while (boxes.count() < num)
    {
        ds = new QDoubleSpinBox(this);
        boxes.append(ds);
        horizontalLayout_values->addWidget(ds);
    }
    while (num > boxes.count())
    {
        ds = boxes.takeLast();
        delete ds;
    }
}

void ErrorFloatDialog::setValue (int index, QString txt)
{
    setValue(index, txt.toFloat());
}

void ErrorFloatDialog::setValue (int index, float val)
{
    boxes.at(index)->setValue(val);
}

float ErrorFloatDialog::getValue (int index)
{
    return boxes.at(index)->value();
}

float ErrorFloatDialog::getTotal()
{
    float tot = 0;
    for (int i = 0; i < boxes.count(); i++)
        tot += boxes.at(i)->value();
    return tot;
}

void ErrorFloatDialog::setSumValue (float val)
{
    doubleSpinBox_sum->setValue(val);
}

QString ErrorFloatDialog::toText()
{
    QString txt("");
    for (int i = 0; i < boxes.count(); i++)
        txt.append(QString(" %1").arg (
                       QString::number(boxes.at(i)->value())));
    return txt;
}

void ErrorFloatDialog::fromText (QString txt)
{
    QStringList ql(txt.split(' ', QString::SkipEmptyParts));
    setNumValues(ql.count());
    for (int i = 0; i > ql.count(); i++)
        setValue(i, ql.at(i));
}


bool ErrorFloatDialog::checkValsWithSum()
{
    bool okay = true;

    if (boxes.count() > 0)
    {
        float total = getTotal();
        if (total != sumVal)
            okay = false;
    }

    return okay;
}

void ErrorFloatDialog::acceptedClicked()
{
    bool okay = true;

    if (showSum)
        okay = checkValsWithSum();

    if (okay)
        accepted();
}

void ErrorFloatDialog::rejectedClicked()
{
    bool okay = true;

    if (showSum)
        okay = checkValsWithSum();

    if (okay)
        rejected();
}

void ErrorFloatDialog::setup()
{
    if (objectName().isEmpty())
        setObjectName(QString::fromUtf8("ErrorFloatDialog"));
    resize(671, 116);
    setSizeGripEnabled(true);
    setModal(true);
    verticalLayout = new QVBoxLayout(this);
    verticalLayout->setObjectName(QString::fromUtf8("verticalLayout"));
    label_label = new QLabel(this);
    label_label->setObjectName(QString::fromUtf8("label_label"));
    label_label->setAlignment(Qt::AlignCenter);

    verticalLayout->addWidget(label_label);

    horizontalLayout_values = new QHBoxLayout();
    horizontalLayout_values->setObjectName(QString::fromUtf8("horizontalLayout_values"));
    label_values = new QLabel(this);
    label_values->setObjectName(QString::fromUtf8("label_values"));

    horizontalLayout_values->addWidget(label_values);


    verticalLayout->addLayout(horizontalLayout_values);

    horizontalLayout_sum = new QHBoxLayout();
    horizontalLayout_sum->setObjectName(QString::fromUtf8("horizontalLayout_sum"));
    label_sum = new QLabel(this);
    label_sum->setObjectName(QString::fromUtf8("label_sum"));

    horizontalLayout_sum->addWidget(label_sum);

    doubleSpinBox_sum = new QDoubleSpinBox(this);
    doubleSpinBox_sum->setObjectName(QString::fromUtf8("doubleSpinBox_sum"));
    doubleSpinBox_sum->setReadOnly(true);
    doubleSpinBox_sum->setButtonSymbols(QAbstractSpinBox::NoButtons);

    horizontalLayout_sum->addWidget(doubleSpinBox_sum);

    buttonBox = new QDialogButtonBox(this);
    buttonBox->setObjectName(QString::fromUtf8("buttonBox"));
    buttonBox->setOrientation(Qt::Horizontal);
    buttonBox->setStandardButtons(QDialogButtonBox::Cancel|QDialogButtonBox::Ok);

    horizontalLayout_sum->addWidget(buttonBox);

    verticalLayout->addLayout(horizontalLayout_sum);


    retranslate();
    QObject::connect(buttonBox, SIGNAL(accepted()), SLOT(accept()));
    QObject::connect(buttonBox, SIGNAL(rejected()), SLOT(reject()));

    QMetaObject::connectSlotsByName(this);
}

void ErrorFloatDialog::retranslate()
{
    setWindowTitle(QApplication::translate("ErrorFloatDialog", "Dialog", 0, QApplication::UnicodeUTF8));
    label_label->setText(QApplication::translate("ErrorFloatDialog", "Label", 0, QApplication::UnicodeUTF8));
    label_values->setText(QApplication::translate("ErrorFloatDialog", "Values ", 0, QApplication::UnicodeUTF8));
    label_sum->setText(QApplication::translate("ErrorFloatDialog", "Sum  ", 0, QApplication::UnicodeUTF8));
}
