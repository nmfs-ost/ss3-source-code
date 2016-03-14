#include "composition_widget.h"
#include "ui_composition_widget.h"

composition_widget::composition_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::composition_widget)
{
    ui->setupUi(this);
}

composition_widget::~composition_widget()
{
    delete ui;
}


length_composition_widget::length_composition_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::composition_widget)
{
    ui->setupUi(this);
}

length_composition_widget::~length_composition_widget()
{
    delete ui;
}


age_composition_widget::age_composition_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::composition_widget)
{
    ui->setupUi(this);
}

age_composition_widget::~age_composition_widget()
{
    delete ui;
}


morph_composition_widget::morph_composition_widget(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::composition_widget)
{
    ui->setupUi(this);
}

morph_composition_widget::~morph_composition_widget()
{
    delete ui;
}
