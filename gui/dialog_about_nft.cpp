#include "dialog_about_nft.h"
#include "ui_dialog_about_nft.h"

Dialog_About_NFT::Dialog_About_NFT(QWidget *parent) :
    QDialog(parent),
    ui(new Ui::Dialog_About_NFT)
{
    ui->setupUi(this);
    connect (ui->pushButton_website, SIGNAL(clicked()), SLOT(goToWebpage()));
    connect (ui->pushButton_website, SIGNAL(clicked()), SLOT(close()));
}

Dialog_About_NFT::~Dialog_About_NFT()
{
    delete ui;
}

void Dialog_About_NFT::goToWebpage ()
{
    emit show_webpage ("http://nft.nefsc.noaa.gov/");
}
