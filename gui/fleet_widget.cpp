#include <QInputDialog>
#include <QFont>
#include <QMessageBox>

#include "fleet_widget.h"
#include "ui_fleet_widget.h"

fleet_widget::fleet_widget(ss_model *m_data, QWidget *parent) :
    QWidget(parent),
    ui(new Ui::fleet_widget)
{
    ui->setupUi(this);
    titleFont = ui->label_title->font();
    titleFont.setPointSize(16);
    titleFont.setBold(true);

    ui->comboBox_fleet_name->setFont(titleFont);

    ui->label_selex_age_discard->setVisible(false);
    ui->spinBox_selex_age_discard->setVisible(false);

    catchview = new tableview();
    catchview->setParent(this);
    catchedit = new catchdelegate(this);
    catchview->setItemDelegate(catchedit);
    ui->verticalLayout_catch_table->addWidget(catchview);

    abundview = new tableview();
    abundview->setParent(this);
    abundedit = new abundancedelegate(this);
    abundview->setItemDelegate(abundedit);
    ui->verticalLayout_abund->addWidget(abundview);

    discardview = new tableview();
    discardview->setParent(this);
    discardedit = new abundancedelegate(this);
    discardview->setItemDelegate(discardedit);
    ui->verticalLayout_discard->addWidget(discardview);

    mbwtView = new tableview();
    mbwtView->setParent(this);
    ui->verticalLayout_mbwt->addWidget(mbwtView);
    lenCompView = new tableview();
    lenCompView->setParent(this);
    ui->verticalLayout_len_obs->addWidget(lenCompView);
    ageCompView = new tableview();
    ageCompView->setParent(this);
    ui->verticalLayout_age_obs->addWidget(ageCompView);
    saaObsView = new tableview();
    saaObsView->setParent(this);
    ui->verticalLayout_saa_obs->addWidget(saaObsView);
    genObsView = new tableview();
    genObsView->setParent(this);
    ui->verticalLayout_gen_obs->addWidget(genObsView);
    morphObsView = new tableview();
    morphObsView->setParent(this);
    ui->verticalLayout_morph_obs->addWidget(morphObsView);
    recapObsView = new tableview();
    recapObsView->setParent(this);
    ui->horizontalLayout_rec_obs->addWidget(recapObsView);

    qParamsView = new tableview();
    qParamsView->setParent(this);
    ui->verticalLayout_q_parameters->addWidget(qParamsView);

    sizeSelexParamsView = new tableview();
    sizeSelexParamsView->setParent(this);
    ui->verticalLayout_selex_size_params->addWidget(sizeSelexParamsView);
    ageSelexParamsView = new tableview();
    ageSelexParamsView->setParent(this);
    ui->verticalLayout_selex_age_params->addWidget(ageSelexParamsView);

    lambdaView = new tableview();
    lambdaView->setParent(this);
    ui->verticalLayout_lambda_changes->addWidget(lambdaView);

    model_data = m_data;
    totalFleets = m_data->num_fleets();

    connect (ui->comboBox_fleet_name, SIGNAL(currentIndexChanged(int)), SLOT(set_current_fleet(int)));
    connect (ui->pushButton_edit_name, SIGNAL(clicked()), SLOT(edit_name()));
    connect (ui->checkBox_active, SIGNAL(toggled(bool)), SLOT(setActive(bool)));
//    connect (ui->pushButton_next, SIGNAL(clicked()), SLOT(nextFleet()));
//    connect (ui->pushButton_prev, SIGNAL(clicked()), SLOT(prevFleet()));
    connect (ui->comboBox_type, SIGNAL(currentIndexChanged(int)), SLOT(set_fleet_type(int)));
    connect (ui->pushButton_delete, SIGNAL(clicked()), SLOT(delete_current_fleet()));
    connect (ui->pushButton_new, SIGNAL(clicked()), SLOT(create_new_fleet()));
    connect (ui->pushButton_duplicate, SIGNAL(clicked()), SLOT(duplicate_current_fleet()));

    connect (ui->spinBox_selex_size_pattern, SIGNAL(valueChanged(int)), SLOT(changeSelexSizePattern(int)));
    connect (ui->spinBox_selex_age_pattern, SIGNAL(valueChanged(int)), SLOT(changeSelexAgePattern(int)));
    connect (ui->pushButton_selex_size_pattern_info, SIGNAL(clicked()), SLOT(showSelexSizeInfo()));
    connect (ui->pushButton_selex_age_pattern_info, SIGNAL(clicked()), SLOT(showSelexAgeInfo()));

    connect (ui->lineEdit_length_comp_tails, SIGNAL(editingFinished()), SLOT(changeLengthMinTailComp()));
    connect (ui->lineEdit_length_constant, SIGNAL(editingFinished()), SLOT(changeLengthAddToData()));
    connect (ui->lineEdit_age_comp_tails, SIGNAL(editingFinished()), SLOT(changeAgeMinTailComp()));
    connect (ui->lineEdit_age_constant, SIGNAL(editingFinished()), SLOT(changeAgeAddToData()));

    current_fleet = NULL;
//    connectFleet();
    set_current_fleet(0);

    refresh();
//    ui->comboBox_fleet_name->setCurrentIndex(0);
    ui->tabWidget_fleet->setCurrentIndex(0);
}

void fleet_widget::disconnectFleet()
{
    if (current_fleet)
    {
    disconnect (ui->doubleSpinBox_timing, SIGNAL(valueChanged(double)), current_fleet, SLOT(set_timing(double)));
    disconnect (ui->spinBox_area, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_area(int)));
    disconnect (ui->doubleSpinBox_equ_catch_se, SIGNAL(valueChanged(double)), current_fleet, SLOT(set_equ_catch_se(double)));
    disconnect (ui->doubleSpinBox_catch_se, SIGNAL(valueChanged(double)), current_fleet, SLOT(set_catch_se(double)));
    disconnect (ui->spinBox_units, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_units(int)));
//    disconnect (ui->spinBox_need_catch_mult, SIGNAL(valueChanged(int)), current_fleet, SLOT()));
    disconnect (ui->comboBox_catch_units, SIGNAL(currentIndexChanged(int)), current_fleet, SLOT(set_catch_units(int)));
//    disconnect (ui->)
//    disconnect (ui->listWidget_init_catch, SIGNAL(itemDoubleClicked(QListWidgetItem*)), SLOT(edit_catch_line(QListWidgetItem*)));
    disconnect (ui->comboBox_abund_units, SIGNAL(currentIndexChanged(int)), current_fleet, SLOT(set_catch_units(int)));
    disconnect (ui->spinBox_abund_err, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_error_type(int)));
    disconnect (ui->spinBox_num_adund, SIGNAL(valueChanged(int)), current_fleet, SLOT(setNumAbundObs(int)));
    disconnect (ui->comboBox_discard_units, SIGNAL(currentIndexChanged(int)), current_fleet, SLOT(setComboDiscardUnits(int)));
    disconnect (ui->spinBox_discard_err, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_discard_err_type(int)));
    disconnect (ui->spinBox_num_discard, SIGNAL(valueChanged(int)), current_fleet, SLOT(setNumDiscardObs(int)));
    disconnect (ui->spinBox_mbwt_df, SIGNAL(valueChanged(int)), current_fleet, SLOT(setMbwtDF(int)));
    disconnect (ui->spinBox_num_mbwt, SIGNAL(valueChanged(int)), current_fleet, SLOT(setMbwtNumObs(int)));
    disconnect (ui->spinBox_obs_len_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthNumObs(int)));
    disconnect (ui->spinBox_length_combine, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthCombineGen(int)));
    disconnect (ui->spinBox_length_comp_bins, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthCompressBins(int)));
    disconnect (ui->spinBox_length_comp_error, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthCompError(int)));
    disconnect (ui->spinBox_length_comp_error_parm, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthCompErrorParm(int)));
    disconnect (ui->spinBox_obs_age_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeNumObs(int)));
    disconnect (ui->spinBox_age_combine, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeCombineGen(int)));
    disconnect (ui->spinBox_age_comp_bins, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeCompressBins(int)));
    disconnect (ui->spinBox_age_comp_error, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeCompError(int)));
    disconnect (ui->spinBox_age_comp_error_parm, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeCompErrorParm(int)));
    disconnect (ui->spinBox_obs_saa_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setSaaNumObs(int)));
    disconnect (ui->spinBox_obs_rec_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setRecapNumEvents(int)));
    disconnect (ui->spinBox_obs_morph_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setMorphNumObs(int)));
    disconnect (ui->spinBox_q_type, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_q_type(int)));
    }
}

void fleet_widget::connectFleet()
{
    connect (ui->doubleSpinBox_timing, SIGNAL(valueChanged(double)), current_fleet, SLOT(set_timing(double)));
    connect (ui->spinBox_area, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_area(int)));
    connect (ui->doubleSpinBox_equ_catch_se, SIGNAL(valueChanged(double)), current_fleet, SLOT(set_equ_catch_se(double)));
    connect (ui->doubleSpinBox_catch_se, SIGNAL(valueChanged(double)), current_fleet, SLOT(set_catch_se(double)));
    connect (ui->spinBox_units, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_units(int)));
//    connect (ui->spinBox_need_catch_mult, SIGNAL(valueChanged(int)), current_fleet, SLOT()));
    connect (ui->comboBox_catch_units, SIGNAL(currentIndexChanged(int)), current_fleet, SLOT(set_catch_units(int)));
//    connect (ui->listWidget_init_catch, SIGNAL(itemDoubleClicked(QListWidgetItem*)), SLOT(edit_catch_line(QListWidgetItem*)));
    connect (ui->comboBox_abund_units, SIGNAL(currentIndexChanged(int)), current_fleet, SLOT(set_catch_units(int)));
    connect (ui->spinBox_abund_err, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_error_type(int)));
    connect (ui->spinBox_num_adund, SIGNAL(valueChanged(int)), current_fleet, SLOT(setNumAbundObs(int)));
    connect (ui->comboBox_discard_units, SIGNAL(currentIndexChanged(int)), current_fleet, SLOT(setComboDiscardUnits(int)));
    connect (ui->spinBox_discard_err, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_discard_err_type(int)));
    connect (ui->spinBox_num_discard, SIGNAL(valueChanged(int)), current_fleet, SLOT(setNumDiscardObs(int)));

    connect (ui->spinBox_mbwt_df, SIGNAL(valueChanged(int)), current_fleet, SLOT(setMbwtDF(int)));
    connect (ui->spinBox_num_mbwt, SIGNAL(valueChanged(int)), current_fleet, SLOT(setMbwtNumObs(int)));

    connect (ui->spinBox_obs_len_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthNumObs(int)));
    connect (ui->spinBox_length_combine, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthCombineGen(int)));
    connect (ui->spinBox_length_comp_bins, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthCompressBins(int)));
    connect (ui->spinBox_length_comp_error, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthCompError(int)));
    connect (ui->spinBox_length_comp_error_parm, SIGNAL(valueChanged(int)), current_fleet, SLOT(setLengthCompErrorParm(int)));

    connect (ui->spinBox_obs_age_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeNumObs(int)));
    connect (ui->spinBox_age_combine, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeCombineGen(int)));
    connect (ui->spinBox_age_comp_bins, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeCompressBins(int)));
    connect (ui->spinBox_age_comp_error, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeCompError(int)));
    connect (ui->spinBox_age_comp_error_parm, SIGNAL(valueChanged(int)), current_fleet, SLOT(setAgeCompErrorParm(int)));

    connect (ui->spinBox_obs_saa_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setSaaNumObs(int)));
    connect (ui->spinBox_obs_gen_num, SIGNAL(valueChanged(int)), SLOT(changeGenMethodNum(int)));
    connect (ui->spinBox_obs_gen_numObs, SIGNAL(valueChanged(int)), SLOT(changeGenNumObs(int)));
    connect (ui->spinBox_obs_rec_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setRecapNumEvents(int)));
    connect (ui->spinBox_obs_morph_numObs, SIGNAL(valueChanged(int)), current_fleet, SLOT(setMorphNumObs(int)));

    connect (ui->spinBox_q_type, SIGNAL(valueChanged(int)), current_fleet, SLOT(set_q_type(int)));
    connect (ui->checkBox_q_doPower, SIGNAL(toggled(bool)), current_fleet, SLOT(set_q_do_power(bool)));
    connect (ui->checkBox_q_doEnv, SIGNAL(toggled(bool)), current_fleet, SLOT(set_q_do_env_lnk(bool)));
    connect (ui->checkBox_q_doExtra, SIGNAL(toggled(bool)), current_fleet, SLOT(set_q_do_extra_sd(bool)));
}

fleet_widget::~fleet_widget()
{
    delete ui;
}

void fleet_widget::edit_name()
{
    int in = ui->comboBox_fleet_name->currentIndex();
    bool ok;
    QString name (ui->comboBox_fleet_name->currentText());
    QString text = QInputDialog::getText(this, tr("Edit Fleet Name"),
                tr("Fleet name:"), QLineEdit::Normal, name, &ok);
    if (ok && !text.isEmpty())
    {
        // set name in fleet in model data
        current_fleet->set_name(text);
        // clear list item and set it to new
        ui->comboBox_fleet_name->removeItem(in);
        ui->comboBox_fleet_name->insertItem(in, text);
        ui->comboBox_fleet_name->setCurrentIndex(in);
        ui->label_name->setText(text);
    }
}

void fleet_widget::setActive(bool flag)
{
    ui->label_number->setVisible(flag);
    ui->spinBox_number->setVisible(flag);
    if (current_fleet->getActive() != flag)
    {
        current_fleet->setActive(flag);
        model_data->assignFleetNumbers();
        refresh();
    }
}

void fleet_widget::reset ()
{
    totalFleets = model_data->num_fleets();
    refresh();
}

void fleet_widget::refreshFleetNames()
{
    disconnect (ui->comboBox_fleet_name, SIGNAL(currentIndexChanged(int)), this, SLOT(set_current_fleet(int)));
    while (ui->comboBox_fleet_name->count() > 0)
        ui->comboBox_fleet_name->removeItem(0);

    for (int i = 0; i < totalFleets; i++)
    {
        QString str = QString(model_data->getFleet(i)->get_name());
        ui->comboBox_fleet_name->addItem(str);
    }
    connect (ui->comboBox_fleet_name, SIGNAL(currentIndexChanged(int)), SLOT(set_current_fleet(int)));
}

void fleet_widget::refresh()
{
    int curr = ui->comboBox_fleet_name->currentIndex();
    catchedit->setYearRange(model_data->start_year(), model_data->end_year());
    catchedit->setNumSeasons(model_data->num_seasons());
    catchedit->setMaxCatch(199999.0);
    abundedit->setYearRange(model_data->start_year(), model_data->end_year());
    abundedit->setMaxCatch(199999.0);
    discardedit->setYearRange(model_data->start_year(), model_data->end_year());
    discardedit->setValueRange(0, 199999.0);

    totalFleets = model_data->num_fleets();
//    ui->spinBox_total->setValue(totalFleets);
    ui->spinBox_area->setMaximum(model_data->num_areas());
    refreshFleetNames();

    ui->comboBox_fleet_name->setCurrentIndex(curr);
    set_current_fleet(curr);

    ui->tabWidget_fleet->setCurrentIndex(0);
    ui->tabWidget_obs->setCurrentIndex(0);
    ui->tabWidget_comp->setCurrentIndex(0);
    ui->tabWidget_selex->setCurrentIndex(0);
}

void fleet_widget::set_model (ss_model *model)
{
    model_data = model;
    refresh();
}

void fleet_widget::set_current_fleet(int index)
{
    if (index >= totalFleets)
        ui->comboBox_fleet_name->setCurrentIndex(totalFleets - 1);
    else if (index < 0)
        ui->comboBox_fleet_name->setCurrentIndex(0);
    Fleet *temp_flt = model_data->getFleet(index);
    if (current_fleet != temp_flt)
    {
        if (current_fleet)
            disconnectFleet ();
        current_fleet = temp_flt;
        ui->label_name->setText(current_fleet->get_name());
        ui->checkBox_active->setChecked(current_fleet->isActive());
        ui->spinBox_number->setValue(current_fleet->getNumber());
//        ui->spinBox_num->setValue(index + 1);
//        ui->label_title->setText(QString("Fleet Info - %1").arg(*current_fleet->name()));
//        ui->label_title->setFont(titleFont);
        set_type_fleet(current_fleet->getType());
        ui->doubleSpinBox_timing->setValue(current_fleet->timing());

        ui->spinBox_area->setValue(current_fleet->area());
        ui->doubleSpinBox_equ_catch_se->setValue(current_fleet->equ_catch_se());
        ui->doubleSpinBox_catch_se->setValue(current_fleet->catch_se());
        ui->spinBox_units->setValue(current_fleet->units());
    //    ui->spinBox_need_catch_mult->setValue(current_fleet->catch_mult());
        ui->comboBox_catch_units->setCurrentIndex(current_fleet->catch_units());
    //    connect (ui->)
    //    connect (ui->listWidget_init_catch, SIGNAL(itemDoubleClicked(QListWidgetItem*)), SLOT(edit_catch_line(QListWidgetItem*)));
        ui->comboBox_abund_units->setCurrentIndex(current_fleet->catch_units());
        ui->spinBox_abund_err->setValue(current_fleet->error_type());
        ui->spinBox_num_adund->setValue(current_fleet->getAbundanceCount());
        catchview->setModel(current_fleet->getCatchModel());
        abundview->setModel(current_fleet->getAbundanceModel());

        ui->comboBox_discard_units->setCurrentIndex(current_fleet->getComboDiscardUnits());
        ui->spinBox_discard_err->setValue(current_fleet->discard_err_type());
        ui->spinBox_num_discard->setValue(current_fleet->getDiscardCount());
        discardview->setModel(current_fleet->getDiscardModel());

        ui->spinBox_mbwt_df->setValue(current_fleet->getMbwtDF());
        ui->spinBox_num_mbwt->setValue(current_fleet->getMbwtNumObs());
        mbwtView->setModel(current_fleet->getMbwtModel());
        mbwtView->resizeColumnsToContents();

        lenCompView->setModel(current_fleet->getLengthModel());
        lenCompView->resizeColumnsToContents();
        ui->spinBox_obs_len_numObs->setValue(current_fleet->getLengthNumObs());
        ui->lineEdit_length_comp_tails->setText(current_fleet->getLengthMinTailComp());
        ui->lineEdit_length_constant->setText(current_fleet->getLengthAddToData());
        ui->spinBox_length_combine->setValue(current_fleet->getLengthCombineGen());
        ui->spinBox_length_comp_bins->setValue(current_fleet->getLengthCompressBins());
        ui->spinBox_length_comp_error->setValue(current_fleet->getLengthCompError());
        ui->spinBox_length_comp_error_parm->setValue(current_fleet->getLengthCompErrorParm());

        ageCompView->setModel(current_fleet->getAgeModel());
        ageCompView->resizeColumnsToContents();
        ui->spinBox_obs_age_numObs->setValue(current_fleet->getAgeNumObs());
        ui->lineEdit_age_comp_tails->setText(current_fleet->getAgeMinTailComp());
        ui->lineEdit_age_constant->setText(current_fleet->getAgeAddToData());
        ui->spinBox_age_combine->setValue(current_fleet->getAgeCombineGen());
        ui->spinBox_age_comp_bins->setValue(current_fleet->getAgeCompressBins());
        ui->spinBox_age_comp_error->setValue(current_fleet->getAgeCompError());
        ui->spinBox_age_comp_error_parm->setValue(current_fleet->getAgeCompErrorParm());

        saaObsView->setModel(current_fleet->getSaaModel());
        saaObsView->resizeColumnsToContents();
        ui->spinBox_obs_saa_numObs->setValue(current_fleet->getSaaNumObs());

        setGenMethodTotal(current_fleet->getGenModelTotal());
        setGenMethodNum(0);

        morphObsView->setModel(current_fleet->getMorphModel());
        morphObsView->resizeColumnsToContents();
        ui->spinBox_obs_morph_numObs->setValue(current_fleet->getMorphNumObs());
        recapObsView->setModel(current_fleet->getRecapModel());
        recapObsView->resizeColumnsToContents();
        ui->spinBox_obs_rec_numObs->setValue(current_fleet->getRecapNumEvents());

        ui->checkBox_q_doPower->setChecked(current_fleet->q_do_power());
        ui->checkBox_q_doEnv->setChecked(current_fleet->q_do_env_lnk());
        ui->checkBox_q_doExtra->setChecked(current_fleet->q_do_power());
        ui->spinBox_q_type->setValue(current_fleet->q_type());
        qParamsView->setModel(current_fleet->getQParams());
        qParamsView->resizeColumnsToContents();

        ui->spinBox_selex_size_pattern->setValue(current_fleet->getSizeSelectivity()->getPattern());
        ui->spinBox_selex_size_discard->setValue(current_fleet->getSizeSelectivity()->getDiscard());
        ui->spinBox_selex_size_male->setValue(current_fleet->getSizeSelectivity()->getMale());
        ui->spinBox_selex_size_special->setValue(current_fleet->getSizeSelectivity()->getSpecial());
        sizeSelexParamsView->setModel(current_fleet->getSizeSelectivity()->getParameterModel());
        ui->spinBox_selex_age_pattern->setValue(current_fleet->getAgeSelectivity()->getPattern());
        ui->spinBox_selex_age_discard->setValue(current_fleet->getAgeSelectivity()->getDiscard());
        ui->spinBox_selex_age_male->setValue(current_fleet->getAgeSelectivity()->getMale());
        ui->spinBox_selex_age_special->setValue(current_fleet->getAgeSelectivity()->getSpecial());
        ageSelexParamsView->setModel(current_fleet->getAgeSelectivity()->getParameterModel());

        ui->spinBox_lambda_max_phase->setValue(model_data->getLambdaMaxPhase());
        ui->spinBox_lambda_sd_offset->setValue(model_data->getLambdaSdOffset());
        ui->spinBox_lambda_num_changes->setValue(current_fleet->getNumLambdas());
        lambdaView->setModel(current_fleet->getLambdaModel());
        lambdaView->resizeColumnsToContents();
        connectFleet ();
    }
}

void fleet_widget::set_fleet_type(int type)
{
    switch(type)
    {
    case 0:
        current_fleet->setType(Fleet::Fishing);
        break;
    case 1:
        current_fleet->setType(Fleet::Bycatch);
        break;
    case 2:
        current_fleet->setType(Fleet::Survey);
        break;
    case 3:
    default:
        current_fleet->setType(Fleet::Predator);
    }
    model_data->assignFleetNumbers();
    refresh();
//    current_fleet->setType(Fleet::FleetType(type));
}

void fleet_widget::set_type_fleet(Fleet::FleetType ft)
{
    switch (ft)
    {
    case Fleet::Fishing:
        ui->comboBox_type->setCurrentIndex(0);
        break;
    case Fleet::Bycatch:
        ui->comboBox_type->setCurrentIndex(1);
        break;
    case Fleet::Survey:
        ui->comboBox_type->setCurrentIndex(2);
        break;
    case Fleet::Predator:
    default:
        ui->comboBox_type->setCurrentIndex(3);
        break;
    }
}

void fleet_widget::nextFleet()
{
/*    int index = ui->spinBox_num->value();
    if (index < ui->spinBox_total->value())
        ui->comboBox_fleet_name->setCurrentIndex(--index + 1);*/
}

void fleet_widget::prevFleet()
{
/*    int index = ui->spinBox_num->value();
    if (index > 0)
        ui->comboBox_fleet_name->setCurrentIndex(--index - 1);*/
}

void fleet_widget::create_new_fleet()
{
    new_fleet("NewFleet");
    refresh();
}

void fleet_widget::duplicate_current_fleet()
{
    int index = ui->comboBox_fleet_name->currentIndex();
    duplicate_fleet(index);
    refresh();
}

void fleet_widget::delete_current_fleet()
{
    int index = ui->comboBox_fleet_name->currentIndex();
    delete_fleet(index);
    refresh();
}

void fleet_widget::new_fleet (QString name)
{
    model_data->newFleet(name);
    totalFleets++;
    set_current_fleet(totalFleets);
}

void fleet_widget::duplicate_fleet (int index)
{
    ui->comboBox_fleet_name->setCurrentIndex(index);
    Fleet *newfl, *oldfl = model_data->getFleet(index);
    QString newname(oldfl->get_name());
    newname.prepend("Copy_of_");
    newfl = model_data->duplicateFleet(oldfl);
    newfl->set_name(newname);
    totalFleets++;
    set_current_fleet(totalFleets);
}

void fleet_widget::delete_fleet(int index)
{
    if (totalFleets == 1)
    {
        model_data->getFleet(0)->reset();
        model_data->getFleet(0)->set_name("newFleet");
    }
    else
    {
        if (index >= 0 &&
            index < totalFleets)
        {
            disconnectFleet();
            current_fleet = NULL;
            model_data->deleteFleet(index);
            totalFleets--;
        }
    }
}

void fleet_widget::showLengthObs()
{
    ui->tabWidget_fleet->setCurrentIndex(2);
    ui->tabWidget_comp->setCurrentIndex(0);
}

void fleet_widget::changeLengthMinTailComp()
{
    current_fleet->setLengthMinTailComp(ui->lineEdit_length_comp_tails->text());
}

void fleet_widget::changeLengthAddToData()
{
    current_fleet->setLengthAddToData(ui->lineEdit_length_constant->text());
}

void fleet_widget::showAgeObs()
{
    ui->tabWidget_fleet->setCurrentIndex(2);
    ui->tabWidget_comp->setCurrentIndex(1);
}

void fleet_widget::changeAgeMinTailComp()
{
    current_fleet->setAgeMinTailComp(ui->lineEdit_age_comp_tails->text());
}

void fleet_widget::changeAgeAddToData()
{
    current_fleet->setAgeAddToData(ui->lineEdit_age_constant->text());
}

void fleet_widget::showMeanSAAObs()
{
    ui->tabWidget_fleet->setCurrentIndex(1);
    ui->tabWidget_obs->setCurrentIndex(4);
}

void fleet_widget::showGenSizeObs(int index)
{
    ui->tabWidget_fleet->setCurrentIndex(2);
    ui->tabWidget_comp->setCurrentIndex(2);
    ui->spinBox_obs_gen_num->setValue(index);
}

void fleet_widget::showRecapObs()
{
    ui->tabWidget_fleet->setCurrentIndex(1);
    ui->tabWidget_obs->setCurrentIndex(5);
}

void fleet_widget::showMorphObs()
{
    ui->tabWidget_fleet->setCurrentIndex(2);
    ui->tabWidget_comp->setCurrentIndex(3);
}

void fleet_widget::changeSelexSizePattern(int pat)
{
    switch (pat)
    {
    case 2:
    case 7:
        ui->label_selex_size_pattern_info->setText(tr("Discontinued, use pattern #8."));
        break;
    case 3:
        ui->label_selex_size_pattern_info->setText(tr("Discontinued, select another pattern."));
        break;
    case 4:
        ui->label_selex_size_pattern_info->setText(tr("Discontinued, use pattern #30."));
        break;
    case 13:
        ui->label_selex_size_pattern_info->setText(tr("Discontinued, use pattern #18."));
    case 10:
    case 11:
    case 12:
    case 14:
    case 16:
    case 17:
    case 18:
    case 19:
    case 20:
    case 26:
        ui->label_selex_size_pattern_info->setText(tr("Used for age selectivity only."));
        break;
    case 21:
    case 28:
    case 29:
        ui->label_selex_size_pattern_info->setText(tr("Not used, select another pattern."));
        break;
    default:
        ui->label_selex_size_pattern_info->setText(" ");
        current_fleet->getSizeSelectivity()->setPattern(pat);
        ui->spinBox_selex_size_pattern->setValue
                (current_fleet->getSizeSelectivity()->getPattern());
        ui->spinBox_selex_size_num_params->setValue
                (current_fleet->getSizeSelectivity()->getNumParameters());
    }
}

void fleet_widget::showSelexSizeInfo()
{
    QString title("Size Selectivity Pattern Information");
    QString msg ("Pattern\tNumParams\tDescription\n");
    msg.append("0\t0\tSelectivity = 1.0 for all sizes.\n");
    msg.append("1\t2\tLogistic.\n");
    msg.append("2\t8\tDiscontinued, use pattern #8.\n");
    msg.append("3\t0\tDiscontinued.\n");
    msg.append("4\t0\tDiscontinued, use special pattern #30.\n");
    msg.append("5\t2\tMirror another selectivity, special is source fleet.\n");
    msg.append("6\t2+\tLinear, special value is num of segments.\n");
    msg.append("7\t8\tDiscontinued, use pattern #8.\n");
    msg.append("8\t8\tDouble logistic with defined peak, smooth joiners.\n");
    msg.append("9\t6\tSimple double logistic, no defined peak.\n");
    msg.append("15\t0\tMirror another selex, special is source fleet.\n");
    msg.append("22\t4\tDouble normal, similar to CASAL.\n");
    msg.append("23\t6\tSimilar to #24.\n");
    msg.append("24\t6\tDouble normal with defined initial and final selex.\n");
    msg.append("25\t3\tExponential - logistic.\n");
    msg.append("27\t3+\tCubic spline, 3 + Number of nodes parameters.\n");
    msg.append("30\t0\tExpected survey abundance equals spawning biomass.\n");
    msg.append("31\t0\tExpected survey abundance equals exp(recr dev).\n");
    msg.append("32\t0\tExpected survey abundance equals exp(recr dev) * SpawnBiomass.\n");
    msg.append("33\t0\tExpected survey abundance equals age 0 recruitment.\n");
    msg.append("34\t0\tSpawning biomass depletion (B/B0).\n");
    msg.append("");
    /*int button = */QMessageBox::information(this, title, msg, QMessageBox::Ok);
}

void fleet_widget::changeSelexAgePattern(int pat)
{
    switch (pat)
    {
    case 21:
    case 28:
    case 29:
        ui->label_selex_age_pattern_info->setText(tr("Not used, select another pattern."));
    case 22:
    case 23:
    case 24:
    case 25:
    case 27:
        ui->label_selex_age_pattern_info->setText(tr("Used for size selectivity only."));
        break;
    default:
        ui->label_selex_age_pattern_info->setText(tr(" "));
        current_fleet->getAgeSelectivity()->setPattern(pat);
        ui->spinBox_selex_age_pattern->setValue
                (current_fleet->getAgeSelectivity()->getPattern());
        ui->spinBox_selex_age_num_params->setValue
                (current_fleet->getAgeSelectivity()->getNumParameters());
    }
}

void fleet_widget::showSelexAgeInfo()
{
    QString title("Age Selectivity Pattern Information");
    QString msg ("Pattern\tNumParams\tDescription\n");
    msg.append("10\t0\tSelectivity = 1.0 for all ages, age 1+.\n");
    msg.append("11\t2\tChoose minimum and maximum ages.\n");
    msg.append("12\t2\tLogistic.\n");
    msg.append("13\t8\tDouble logistic, IF joiners, Discouraged, use pattern #18.\n");
    msg.append("14\tNages+1\tEach age, value at age is 1/(1+exp(-x)).\n");
    msg.append("15\t0\tMirror another selectivity, special is source fleet.\n");
    msg.append("16\t2\tColeraine, single Gaussian.\n");
    msg.append("17\tNages+1\tEach age as random walk.\n");
    msg.append("18\t8\tDouble logistic with defined peak, smooth joiners.\n");
    msg.append("19\t6\tSimple double logistic, no defined peak.\n");
    msg.append("20\t6\tDouble normal with defined init and final level.\n");
    msg.append("26\t3\tExponential - logistic.\n");
    msg.append("");
    QMessageBox::information(this, title, msg);
}

void fleet_widget::setGenMethodTotal(int num)
{
    ui->spinBox_obs_gen_num_total->setValue(num);
}

void fleet_widget::changeGenMethodTotal(int num)
{

    if (ui->spinBox_obs_gen_num_total->value() > 0)
    {
        setGenMethodNum(0);
        ui->spinBox_obs_gen_numObs->setVisible(true);
        genObsView->setVisible(true);
    }
    else
    {
        ui->spinBox_obs_gen_numObs->setVisible(true);
        genObsView->setVisible(true);
    }

}

void fleet_widget::setGenMethodNum(int num)
{
    if (num < 0) num = 0;
    if (num >= ui->spinBox_obs_gen_num_total->value())
        num = ui->spinBox_obs_gen_num_total->value() - 1;
    ui->spinBox_obs_gen_num->setValue(num + 1);
}

void fleet_widget::changeGenMethodNum(int num)
{
    if (num < 1)
        ui->spinBox_obs_gen_num->setValue(1);
    else if (num > ui->spinBox_obs_gen_num_total->value())
        ui->spinBox_obs_gen_num->setValue(ui->spinBox_obs_gen_num_total->value());
    else
    {
        cur_gen_obs = num - 1;
        ui->spinBox_obs_gen_numObs->setValue(current_fleet->getGenNumObs(cur_gen_obs));
        genObsView->setModel(current_fleet->getGenModel(cur_gen_obs));
    }
}

void fleet_widget::setGenNumObs(int num)
{
    if (num < 0) num = 0;
    ui->spinBox_obs_gen_numObs->setValue(num);
}

void fleet_widget::changeGenNumObs(int num)
{
    current_fleet->setGenNumObs(cur_gen_obs, num);
}


