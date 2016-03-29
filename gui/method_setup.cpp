#include "method_setup.h"

method_setup::method_setup()
{
    setup = new tablemodel();
    setup->setColumnCount(4);
    setup->setRowCount(0);
    header << "Pattern" << "Discard" << "Male" << "Special";
    setup->setHeader(header);
}

method_setup::~method_setup()
{
    delete setup;
}

int method_setup::getA() const
{
    return setup->getRowData(0).at(0).toInt();
}

void method_setup::setA(int value)
{
    QString txt = QString::number(value);
    QStringList txtlist(setup->getRowData(0));
    txtlist[0] = txt;
    setup->setRowData(0, txtlist);
}
int method_setup::getB() const
{
    return setup->getRowData(0).at(1).toInt();
}

void method_setup::setB(int value)
{
    QStringList txtlist(setup->getRowData(0));
    txtlist[1] = QString::number(value);
    setup->setRowData(0, txtlist);
    B = value;
}
int method_setup::getC() const
{
    return setup->getRowData(0).at(2).toInt();
}

void method_setup::setC(int value)
{
    QStringList txtlist(setup->getRowData(0));
    txtlist[2] = QString::number(value);
    setup->setRowData(0, txtlist);
    C = value;
}
int method_setup::getD() const
{
    return setup->getRowData(0).at(3).toInt();
}

void method_setup::setD(int value)
{
    QStringList txtlist(setup->getRowData(0));
    txtlist[3] = QString::number(value);
    setup->setRowData(0, txtlist);
    D = value;
}

void method_setup::fromText(QString text)
{
    QStringList ql = text.split(' ', QString::SkipEmptyParts);
    setup->setRowData(0, ql);
/*    setA(ql.at(0).toInt());
    setB(ql.at(1).toInt());
    setC(ql.at(2).toInt());
    setD(ql.at(3).toInt());*/
}

void method_setup::fromText(QStringList textlist)
{
    setup->setRowData(0, textlist);
}

QString method_setup::toText()
{
    QString text("");
    QStringList txtlist(setup->getRowData(0));
    for (int i = 0; i < 4; i++)
        text.append(QString(" %1").arg(txtlist.at(i)));
    return text;
}

QStringList method_setup::getHeader() const
{
    return header;
}

void method_setup::setHeader(const QStringList &value)
{
    header = value;
}

tablemodel *method_setup::getSetupModel()
{
    return setup;
}







