#include "data_widget.h"
#include "ui_data_widget.h"

data_widget::data_widget(ss_model *model, QWidget *parent) :
    QWidget(parent),
    ui(new Ui::data_widget)
{
    ui->setupUi(this);

    model_data = model;

    sdYearsView = new tableview();
    sdYearsDelegate = new spinBoxDelegate(this);
    sdYearsDelegate->setRange(1900, 3000);
    sdYearsView->setItemDelegate(sdYearsDelegate);
    sdYearsView->showRow(1);
    sdYearsView->setAcceptDrops(true);
    sdYearsView->setModel(model_data->sdYearsModel);
    ui->horizontalLayout_sdYears->addWidget(sdYearsView);

/*    mbweightview = new tableview();
    mbweightview->setParent(this);
    mbweightedit = new mbweightdelegate(this);
    mbweightview->setItemDelegate(mbweightedit);
    mbweightview->setModel(model_data->getMeanBwtModel());
    ui->horiz  verticalLayout_mbwt->addWidget(mbweightview);*/

    lengthBins = new tableview();
    lengthBins->setParent(this);
    lBinsDelegate = new spinBoxDelegate(this);
    lBinsDelegate->setRange(0, 200);
    lengthBins->setItemDelegate(lBinsDelegate);
    lengthBins->setAcceptDrops(true);
    lengthBins->showRow(1);
    lengthBins->setModel(model_data->get_length_composition()->getBinsModel());
    ui->horizontalLayout_length_bins->addWidget(lengthBins);
/*    lengthObs = new tableview();
    lengthObs->setParent(this);
    lengthObs->setModel(model_data->get_length_composition()->obsModel);
    ui->horizontalLayout_len_obs->addWidget(lengthObs);*/

    ageBins = new tableview();
    ageBins->setParent(this);
    aBinsDelegate = new spinBoxDelegate(this);
    aBinsDelegate->setRange(0, 50);
    ageBins->setItemDelegate(aBinsDelegate);
    ageBins->setAcceptDrops(true);
    ageBins->showRow(1);
    ageBins->setModel(model_data->get_age_composition()->getBinsModel());
    ui->horizontalLayout_age_bins->addWidget(ageBins);
/*    ageObs = new tableview();
    ageObs->setParent(this);
    ageObs->setModel(model_data->get_age_composition()->obsModel);
    ui->verticalLayout_age_obs->addWidget(ageObs);*/
    ageError = new tableview();
    ageError->setParent(this);
    ageError->setModel(model_data->get_age_composition()->getErrorModel());
    ui->horizontalLayout_age_error->addWidget(ageError);

    genBins = new tableview();
    genBins->setParent(this);
    ui->horizontalLayout_gen_bins->addWidget(genBins);
    current_gen_comp = NULL;
    connect (ui->spinBox_gen_comp, SIGNAL(valueChanged(int)), SLOT(changeGenCompMethod(int)));
    connect (ui->spinBox_gen_units, SIGNAL(valueChanged(int)), SLOT(changeGenUnits(int)));
    connect (ui->spinBox_gen_scale, SIGNAL(valueChanged(int)), SLOT(changeGenScale(int)));
    connect (ui->lineEdit_gen_mincomp, SIGNAL(editingFinished()), SLOT(changeGenMinComp()));
    connect (ui->spinBox_gen_num_bins, SIGNAL(valueChanged(int)), SLOT(changeGenBins(int)));

    tagGroups = new tableview();
    tagGroups->setParent(this);
    tagGroups->setModel(model_data->get_tag_observations());
    tagGroups->resizeColumnsToContents();
    ui->horizontalLayout_tag_reldata->addWidget(tagGroups);
    connect (ui->spinBox_tag_num_groups, SIGNAL(valueChanged(int)), model_data, SLOT(set_num_tag_groups(int)));
    connect (ui->spinBox_tag_latency, SIGNAL(valueChanged(int)), model_data, SLOT(set_tag_latency(int)));
    connect (ui->spinBox_tag_max_per, SIGNAL(valueChanged(int)), model_data, SLOT(set_tag_max_periods(int)));

    envVariables = new tableview();
    envVariables->setParent(this);
    envVariables->setModel(model_data->getEnvVariables());
    ui->verticalLayout_env_var_obs->addWidget(envVariables);
    connect (ui->spinBox_env_var_obs, SIGNAL(valueChanged(int)), model_data, SLOT(set_num_environ_var_obs(int)));
    connect (ui->spinBox_num_evn_var, SIGNAL(valueChanged(int)), model_data, SLOT(set_num_environ_vars(int)));

    timeBlocks = new tableview();
    timeBlocks->setParent(this);
    timeBlocks->setModel(0);
    ui->verticalLayout_block_years->addWidget(timeBlocks);
 //   ui->spinbox_bl
    addSdSpecification = new tableview();
    addSdSpecification->setParent(this);
    addSdSpecification->setModel(model_data->getAddSdReporting()->getSpecModel());
    ui->verticalLayout_8->addWidget(addSdSpecification);
    addSdBinList = new tableview();
    addSdBinList->setParent(this);
    addSdBinList->setModel(model_data->getAddSdReporting()->getBinModel());
    ui->verticalLayout_14->addWidget(addSdBinList);



    connect (ui->spinBox_year_start, SIGNAL(valueChanged(int)), model_data, SLOT(set_start_year(int)));
    connect (ui->spinBox_year_start, SIGNAL(valueChanged(int)), SLOT(changeTotalYears()));
    connect (ui->spinBox_year_end, SIGNAL(valueChanged(int)), model_data, SLOT(set_end_year(int)));
    connect (ui->spinBox_year_end, SIGNAL(valueChanged(int)), SLOT(changeTotalYears()));
    connect (ui->spinBox_seas_per_yr, SIGNAL(valueChanged(int)), model_data, SLOT(set_num_seasons(int)));
    connect (ui->spinBox_seas_per_yr, SIGNAL(valueChanged(int)), SLOT(changeMaxSeason(int)));
//    connect (ui->spinBox_sub_seasons, SIGNAL(valueChanged(int)), model_data, SLOT(set_num_subseasons(int)));
    connect (ui->spinBox_season, SIGNAL(valueChanged(int)), SLOT(changeSeason(int)));
    connect (ui->lineEdit_num_mo_season, SIGNAL(textChanged(QString)), SLOT(changeMoPerSeason(QString)));
    connect (ui->spinBox_spawn_season, SIGNAL(valueChanged(int)), model_data, SLOT(set_spawn_season(int)));
    connect (ui->spinBox_max_age, SIGNAL(valueChanged(int)), model_data, SLOT(set_num_ages(int)));
//    connect (ui->spinBox_num_ages, SIGNAL(valueChanged(int)), model_data, SLOT(set_num_ages(int)));
    connect (ui->spinBox_num_genders, SIGNAL(valueChanged(int)), SLOT(changeNumGenders(int)));

    connect (ui->checkBox_soft_bounds, SIGNAL(toggled(bool)), model_data, SLOT(set_use_softbounds(bool)));
    connect (ui->checkBox_priors, SIGNAL(toggled(bool)), model_data, SLOT(set_prior_likelihood(bool)));
    connect (ui->spinBox_last_phase, SIGNAL(valueChanged(int)), model_data, SLOT(set_last_estim_phase(int)));
    connect (ui->spinBox_mc_burn, SIGNAL(valueChanged(int)), model_data, SLOT(set_mc_burn(int)));
    connect (ui->spinBox_mc_thin, SIGNAL(valueChanged(int)), model_data, SLOT(set_mc_thin(int)));
    connect (ui->lineEdit_jitter, SIGNAL(editingFinished()), SLOT(changeJitter()));
    connect (ui->lineEdit_convergence, SIGNAL(editingFinished()), SLOT(changeConvergence()));
    connect (ui->spinBox_retrospect_yr, SIGNAL(valueChanged(int)), model_data, SLOT(set_retrospect_year(int)));
    connect (ui->spinBox_f_bmass_min_age, SIGNAL(valueChanged(int)), model_data, SLOT(set_biomass_min_age(int)));
    connect (ui->comboBox_f_dep, SIGNAL(currentIndexChanged(int)), model_data, SLOT(set_depletion_basis(int)));
    connect (ui->lineEdit_dep_denom, SIGNAL(editingFinished()), SLOT(changeDepDenom()));
    connect (ui->comboBox_spr_basis, SIGNAL(currentIndexChanged(int)), model_data, SLOT(set_spr_basis(int)));
    connect (ui->comboBox_f_rpt_units, SIGNAL(currentIndexChanged(int)), SLOT(setFRptUnits(int)));
    connect (ui->spinBox_f_min_age, SIGNAL(valueChanged(int)), model_data, SLOT(set_f_min_age(int)));
    connect (ui->spinBox_f_max_age, SIGNAL(valueChanged(int)), model_data, SLOT(set_f_max_age(int)));
    connect (ui->comboBox_f_report_basis, SIGNAL(currentIndexChanged(int)), model_data, SLOT(set_f_basis(int)));
    connect (ui->spinBox_sdrpt_min_yr, SIGNAL(valueChanged(int)), model_data, SLOT(set_bio_sd_min_year(int)));
    connect (ui->spinBox_sdrpt_max_yr, SIGNAL(valueChanged(int)), model_data, SLOT(set_bio_sd_max_year(int)));
    connect (ui->spinBox_num_std_yrs, SIGNAL(valueChanged(int)), SLOT(setNumSdYears(int)));
    connect (sdYearsDelegate, SIGNAL(commitData(QWidget*)), SLOT(numSdYearsChanged(QWidget *)));

//    connect (ui->spinBox_length_bin_method, SIGNAL(valueChanged(int)), SLOT(changeLengthCompMethod(int)));
    connect (ui->spinBox_length_num_bins, SIGNAL(valueChanged(int)), SLOT(changeLengthBins(int)));
//    connect (ui->spinBox_length_combine, SIGNAL(valueChanged(int)), SLOT(changeLengthCombine(int)));
//    connect (ui->lineEdit_length_comp_tails, SIGNAL(editingFinished()), SLOT(changeLengthCompress()));
//    connect (ui->lineEdit_length_constant, SIGNAL(editingFinished()), SLOT(changeLengthAdd()));
    connect (ui->pushButton_length_obs, SIGNAL(clicked()), SIGNAL(showLengthObs()));

    connect (ui->spinBox_age_bin_method, SIGNAL(valueChanged(int)), SLOT(changeAgeCompMethod(int)));
    connect (ui->spinBox_age_num_bins, SIGNAL(valueChanged(int)), SLOT(changeAgeBins(int)));
    connect (ui->spinBox_age_error_num, SIGNAL(valueChanged(int)), SLOT(changeAgeError(int)));
    connect (ui->pushButton_age_obs, SIGNAL(clicked()), SIGNAL(showAgeObs()));
    connect (ui->pushButton_saa_obs, SIGNAL(clicked()), SIGNAL(showSAAObs()));

    connect (ui->pushButton_gen_obs, SIGNAL(clicked()), SLOT(showGenObs()));

    connect (ui->groupBox_comp_morph, SIGNAL(toggled(bool)), SLOT(changeDoMorphs(bool)));
    connect (ui->spinBox_morph_num_stocks, SIGNAL(valueChanged(int)), SLOT(changeMorphs(int)));
    connect (ui->lineEdit_morph_min_comp, SIGNAL(editingFinished()), SLOT(changeMorphMincomp()));
    connect (ui->pushButton_morph_obs, SIGNAL(clicked()), SIGNAL(showMorphObs()));

    connect (ui->groupBox_tag, SIGNAL(toggled(bool)), SLOT(changeDoTags(bool)));
    connect (ui->spinBox_tag_num_groups, SIGNAL(valueChanged(int)), model_data, SLOT(set_num_tag_groups(int)));
    connect (ui->spinBox_tag_latency, SIGNAL(valueChanged(int)), model_data, SLOT(set_tag_latency(int)));
    connect (ui->spinBox_tag_max_per, SIGNAL(valueChanged(int)), model_data, SLOT(set_tag_max_periods(int)));
    connect (ui->pushButton_tag_rec_obs, SIGNAL(clicked()), SIGNAL(showRecapObs()));

    connect (ui->spinBox_block_pattern_num, SIGNAL(valueChanged(int)), SLOT(changeBlockPattern(int)));

    ui->spinBox_num_std_yrs->setMaximum(20);
    setNumSdYears(0);

    refresh();

    ui->tabWidget->setCurrentIndex(0);
}

data_widget::~data_widget()
{
    delete sdYearsView;
    delete ui;
}

void data_widget::set_model(ss_model *m_data)
{
    reset();
    {
        model_data = m_data;
    }
    refresh();
}

void data_widget::reset()
{

}

void data_widget::refresh()
{
    if (model_data != NULL)
    {
        ui->spinBox_year_start->setValue(model_data->start_year());
        ui->spinBox_year_end->setValue(model_data->end_year());
        changeTotalYears();
        ui->spinBox_seas_per_yr->setValue(model_data->num_seasons());
//        ui->spinBox_sub_seasons->setValue(model_data->get_num_subseasons());
//
        ui->spinBox_spawn_season->setValue(model_data->spawn_season());
        ui->spinBox_season->setValue(1);
        setMoPerSeason();
        setTotalMonths();
        ui->spinBox_num_fisheries->setValue(model_data->num_fisheries());
        ui->spinBox_num_surveys->setValue(model_data->num_surveys());
        ui->spinBox_total_fleets->setValue(model_data->num_fleets());
        ui->spinBox_num_areas->setValue(model_data->num_areas());
//        ui->spinBox_num_ages->setValue(model_data->num_ages());
        ui->spinBox_max_age->setValue(model_data->num_ages());
        ui->spinBox_num_genders->setValue(model_data->num_genders());

        ui->checkBox_soft_bounds->setChecked(model_data->use_softbounds());
        ui->checkBox_priors->setChecked(model_data->prior_likelihood());
        ui->spinBox_last_phase->setValue(model_data->last_estim_phase());
        ui->spinBox_mc_burn->setValue(model_data->mc_burn());
        ui->spinBox_mc_thin->setValue(model_data->mc_thin());
        ui->lineEdit_jitter->setText(QString::number(model_data->jitter_param()));
        ui->lineEdit_convergence->setText(QString::number(model_data->convergence_criteria()));
        ui->spinBox_f_bmass_min_age->setValue(model_data->biomass_min_age());
        ui->comboBox_f_dep->setCurrentIndex(model_data->depletion_basis());
        ui->lineEdit_dep_denom->setText(QString::number(model_data->depletion_denom()));
        ui->comboBox_spr_basis->setCurrentIndex(model_data->spr_basis());
        ui->comboBox_f_rpt_units->setCurrentIndex(model_data->f_units());
        ui->spinBox_f_min_age->setValue(model_data->f_min_age());
        ui->spinBox_f_max_age->setValue(model_data->f_max_age());
        ui->comboBox_f_report_basis->setCurrentIndex(model_data->f_basis());

        ui->spinBox_sdrpt_min_yr->setValue(model_data->bio_sd_min_year());
        ui->spinBox_sdrpt_max_yr->setValue(model_data->bio_sd_max_year());
        ui->spinBox_num_std_yrs->setValue(model_data->num_std_years());
        sdYearsView->setModel(model_data->sdYearsModel);
        sdYearsView->resizeColumnsToContents();

/*        ui->spinBox_mbwt_df->setValue(model_data->mean_body_wt_df());
        setMBWTObs(model_data->mean_body_wt_count());
        mbweightview->setModel(model_data->getMeanBwtModel());
        mbweightview->resizeColumnsToContents();*/

        setLengthCompMethod(model_data->get_length_composition()->getAltBinMethod());
        setLengthBins (model_data->get_length_composition()->getNumberBins());
        lengthBins->setModel(model_data->get_length_composition()->getBinsModel());
        lengthBins->resizeColumnsToContents();
//        lengthObs->setModel(model_data->get_length_composition()->getObsModel());
//        lengthObs->resizeColumnsToContents();

        ui->spinBox_age_bin_method->setValue(model_data->get_age_composition()->getAltBinMethod());
        setAgeBins(model_data->get_age_composition()->getNumberBins());
        setAgeError(model_data->get_age_composition()->number_error_defs());
        ageBins->setModel(model_data->get_age_composition()->getBinsModel());
        ageBins->resizeColumnsToContents();
        QSize size (ageBins->size());
        size.setHeight(40);
        ageBins->resize(size);
        ageError->setModel(model_data->get_age_composition()->getErrorModel());
        ageError->resizeColumnsToContents();
//        ageObs->setModel(model_data->get_age_composition()->getObsModel());
//        ageObs->resizeColumnsToContents();
        ui->label_gen_comp_total->setText(QString::number(model_data->num_general_comp_methods()));
        setGenCompMethod(0);

        setDoMorphs(model_data->get_do_morph_comp());

        setDoTags(model_data->get_do_tags());


        ui->spinBox_env_var_obs->setValue(model_data->num_environ_var_obs());
        ui->spinBox_num_evn_var->setValue(model_data->num_environ_vars());

        ui->spinBox_block_patterns_total->setValue(model_data->getNumBlockPatterns());
        setBlockPattern(0);

        ui->groupBox_add_sd->setChecked(model_data->getAddSdReporting()->getActive());
        addSdSpecification->setModel(model_data->getAddSdReporting()->getSpecModel());
        addSdSpecification->resizeColumnsToContents();
        ui->verticalLayout_add_sd_spec->addWidget(addSdSpecification);
        addSdBinList->setModel(model_data->getAddSdReporting()->getBinModel());
        addSdBinList->resizeColumnsToContents();
        ui->verticalLayout_add_sd_bins->addWidget(addSdBinList);
    }
}

void data_widget::changeMaxSeason(int num)
{
    if (num < 1)
        num = 1;
    ui->spinBox_season->setMaximum(num);
    ui->spinBox_spawn_season->setMaximum(num);
    ui->spinBox_season->setMaximum(num);
}

void data_widget::changeSeason(int seas)
{
    setMoPerSeason();
//    setNumSubSeasons();
}

void data_widget::setMoPerSeason()
{
    int seas = ui->spinBox_season->value();
    double months = model_data->getSeason(seas)->getNumMonths();
    ui->lineEdit_num_mo_season->setText(QString::number(months));
}

void data_widget::changeMoPerSeason(QString txt)
{
    int seas = ui->spinBox_season->value();
    int months = txt.toInt();
    model_data->getSeason(seas)->setNumMonths(months);
    setTotalMonths();
}

int data_widget::setTotalMonths()
{
    int num_seas = model_data->num_seasons();
    int tot_months = 0;
    for (int i = 1; i <= num_seas; i++)
        tot_months += model_data->getSeason(i)->getNumMonths();
    ui->spinBox_total_months->setValue(tot_months);
    return tot_months;
}

void data_widget::changeSpawnSeason(int seas)
{
    if (seas > ui->spinBox_seas_per_yr->maximum())
        seas = ui->spinBox_seas_per_yr->maximum();
    ui->spinBox_spawn_season->setValue(seas);
    model_data->set_spawn_season(seas);
}

void data_widget::changeTotalYears()
{
    int start = ui->spinBox_year_start->value();
    int end = ui->spinBox_year_end->value();
    ui->spinBox_year_total->setValue(end - start + 1);
}

void data_widget::setFRptUnits(int val)
{
    bool flag = false;
    if (val == 4)
    {
        flag = true;
    }
    ui->label_f_min_age->setVisible(flag);
    ui->spinBox_f_min_age->setVisible(flag);
    ui->label_f_max_age->setVisible(flag);
    ui->spinBox_f_max_age->setVisible(flag);
    model_data->set_f_units(val);
}

void data_widget::setNumSdYears(int val)
{
    model_data->set_num_std_years(val);
    model_data->sdYearsModel->setColumnCount(val);
    ui->label_std_yrs->setVisible(val);
    sdYearsView->setVisible(val);
}

void data_widget::numSdYearsChanged(QWidget *qw)
{

}

void data_widget::changeNumGenders(int val)
{
    model_data->set_num_genders(val);
    for (int i = 0; i < model_data->num_fleets(); i++)
    {
        int bins = model_data->get_length_composition()->getNumberBins();
        if (bins > 0)
            model_data->getFleet(i)->setLengthNumBins(bins);
        bins = model_data->get_age_composition()->getNumberBins();
        if (bins > 0)
            model_data->getFleet(i)->setAgeNumBins(bins);
        for (int j = 0; j < model_data->num_general_comp_methods(); j++)
            model_data->getFleet(i)->setGenNumBins(j, model_data->general_comp_method(j)->getNumberBins());
    }
}

/*void data_widget::setMBWTObs(int count)
{
    ui->spinBox_mbwt_num_obs->setValue(count);
    if (count > 0)
        mbweightview->show();
    else
        mbweightview->hide();
}

void data_widget::changeMBWTObs(int count)
{
    model_data->set_mean_body_wt_obs_count(count);
}*/

void data_widget::setLengthCompMethod(int method)
{
//    ui->spinBox_length_bin_method->setValue(method);
    ui->spinBox_length_num_bins->setValue(model_data->get_length_composition()->getNumberBins());
    if (method == 1)
    {
        ui->label_length_num_bins->setVisible(false);
        ui->label_length_bins->setVisible(false);
        ui->spinBox_length_num_bins->setVisible(false);

    }
    else
    {
        ui->label_length_num_bins->setVisible(true);
        ui->label_length_bins->setVisible(true);
        ui->spinBox_length_num_bins->setVisible(true);

    }
}

void data_widget::changeLengthCompMethod(int method)
{
    model_data->get_length_composition()->setAltBinMethod(method);
}

void data_widget::setLengthBins(int numBins)
{
    ui->spinBox_length_num_bins->setValue(numBins);
    if (numBins > 0)
    {
        lengthBins->show();
    }
    else
    {
        lengthBins->hide();
    }
}

void data_widget::changeLengthBins(int numBins)
{
    if (numBins != model_data->get_length_composition()->getNumberBins())
    {
        model_data->get_length_composition()->setNumberBins(numBins);
        for (int i = 0; i < model_data->num_fleets(); i++)
            model_data->getFleet(i)->setLengthNumBins(numBins);
    }
    setLengthBins(numBins);
}

void data_widget::changeLengthCompress()
{
//    double comp = ui->lineEdit_length_comp_tails->text().toDouble();
//    model_data->get_length_composition()->set_compress_tails(comp);
}

void data_widget::changeLengthAdd()
{
//    double add = ui->lineEdit_length_constant->text().toDouble();
//    model_data->get_length_composition()->set_add_to_compression(add);
}

void data_widget::changeLengthCombine(int gen)
{
//    model_data->get_length_composition()->set_combine_genders(gen);
}

void data_widget::setAgeCompMethod(int method)
{
    ui->spinBox_age_bin_method->setValue(method);
}

void data_widget::changeAgeCompMethod(int method)
{
    model_data->get_age_composition()->setAltBinMethod(method);
}

void data_widget::setAgeBins(int numBins)
{
    ui->spinBox_age_num_bins->setValue(numBins);
    if (numBins > 0)
    {
        ageBins->show();
    }
    else
    {
        ageBins->hide();
    }
}

void data_widget::changeAgeBins(int numBins)
{
    if (numBins != model_data->get_age_composition()->getNumberBins())
    {
        model_data->get_age_composition()->setNumberBins(numBins);
        for (int i = 0; i < model_data->num_fleets(); i++)
            model_data->getFleet(i)->setAgeNumBins(numBins);
    }
    setAgeBins(numBins);
}

void data_widget::setAgeError(int numDefs)
{
    ui->spinBox_age_error_num->setValue(numDefs);
    if (numDefs > 0)
    {

    }
    else
    {

    }
}

void data_widget::changeAgeError(int numDefs)
{
    model_data->get_age_composition()->set_num_error_defs(numDefs);
}

void data_widget::changeAgeCombine(int gen)
{
//    model_data->get_age_composition()->set_combine_genders(gen);
}

void data_widget::setGenCompMethod(int method)
{
    ui->spinBox_gen_comp->setValue(method);
    changeGenCompMethod(method);
}

void data_widget::changeGenCompMethod(int method)
{
    int total = model_data->num_general_comp_methods();
    if (total > 0)
    {
        if (method < 1)
            ui->spinBox_gen_comp->setValue(1);
        else if (method > total)
            ui->spinBox_gen_comp->setValue(total);

        else
        {
            ui->label_gen_comp_total->setText(QString::number(model_data->num_general_comp_methods()));
            current_gen_comp = model_data->general_comp_method(method - 1);
//            ui->spinBox_gen_units->setValue(current_gen_comp->getUnits());
//            ui->spinBox_gen_scale->setValue(current_gen_comp->getScale());
//            ui->lineEdit_gen_mincomp->setText(QString::number(current_gen_comp->mincomp()));
            ui->spinBox_gen_num_bins->setValue(current_gen_comp->getNumberBins());
            genBins->setModel(current_gen_comp->getBinsModel());
            genBins->resizeColumnsToContents();
        }
    }
    else
    {
        ui->label_gen_comp_total->setText("0");
        current_gen_comp = NULL;
        ui->spinBox_gen_units->setValue(0);
        ui->spinBox_gen_scale->setValue(0);
        ui->lineEdit_gen_mincomp->setText(" ");
        ui->spinBox_gen_num_bins->setValue(0);
        genBins->setModel(NULL);
    }
}

void data_widget::changeGenUnits(int units)
{
    if (units < 1)
        ui->spinBox_gen_units->setValue(1);
    else if (units > 2)
        ui->spinBox_gen_units->setValue(2);

//    else if (current_gen_comp != NULL)
//        current_gen_comp->set_units(units);
}

void data_widget::changeGenScale(int scale)
{
    if (scale < 1)
        ui->spinBox_gen_scale->setValue(1);
    else if (scale > 4)
        ui->spinBox_gen_scale->setValue(4);

//    else if (current_gen_comp != NULL)
//        current_gen_comp->set_scale(scale);
}

void data_widget::changeGenMinComp()
{
    float temp = ui->lineEdit_gen_mincomp->text().toFloat();
//    if (current_gen_comp != NULL)
//        current_gen_comp->set_mincomp(temp);
}

void data_widget::changeGenBins(int numBins)
{
    if (numBins < 0)
        ui->spinBox_gen_num_bins->setValue(0);
    else if (current_gen_comp != NULL)
    {
        int method = ui->spinBox_gen_comp->value();
        current_gen_comp->setNumberBins(numBins);
        for (int i = 0; i < model_data->num_fleets(); i++)
            model_data->getFleet(i)->setGenNumBins(method-1, numBins);
    }
}

void data_widget::showGenObs()
{
    int in = ui->spinBox_gen_comp->value();
    emit showGenObs(in);
}

void data_widget::setDoMorphs(bool flag)
{
    ui->groupBox_comp_morph->setChecked(flag);
    changeDoMorphs(flag);
}

void data_widget::changeDoMorphs(bool flag)
{
    model_data->set_do_morph_comp(flag);
    if (flag)
    {
        ui->groupBox_comp_morph->setChecked(true);
        ui->spinBox_morph_num_stocks->setValue(model_data->get_morph_composition()->getNumberMorphs());
//        ui->lineEdit_morph_min_comp->setText(QString::number(model_data->get_morph_composition()->mincomp()));
    }
    else
    {
        ui->groupBox_comp_morph->setChecked(false);
        ui->spinBox_morph_num_stocks->setValue(0);
        ui->lineEdit_morph_min_comp->setText("0");
    }
}

void data_widget::changeMorphs(int num)
{
    model_data->get_morph_composition()->setNumberMorphs(num);
    for (int i = 0; i < model_data->num_fleets(); i++)
        model_data->getFleet(i)->setMorphNumMorphs(num);
}

void data_widget::changeMorphMincomp()
{
    double val = ui->lineEdit_morph_min_comp->text().toDouble();
//    model_data->get_morph_composition()->set_mincomp(val);
}

void data_widget::setDoTags(bool flag)
{
    ui->groupBox_tag->setChecked(flag);
    changeDoTags(flag);
}

void data_widget::changeDoTags(bool flag)
{
    model_data->set_do_tags(flag);
    if (flag)
    {
        ui->spinBox_tag_num_groups->setValue(model_data->get_num_tag_groups());
        ui->spinBox_tag_latency->setValue(model_data->get_tag_latency());
        ui->spinBox_tag_max_per->setValue(model_data->get_tag_max_periods());
        tagGroups->setModel(model_data->get_tag_observations());
        tagGroups->resizeColumnsToContents();
    }
    else
    {
        ui->spinBox_tag_num_groups->setValue(0);
        ui->spinBox_tag_latency->setValue(0);
        ui->spinBox_tag_max_per->setValue(0);
        tagGroups->setModel(NULL);
    }
}

void data_widget::setBlockPattern(int num)
{
    if (model_data->getNumBlockPatterns() > 0)
    {
        ui->spinBox_block_pattern_num->setValue(num);
    }
    else
    {
        ui->spinBox_block_pattern_num->setValue(0);
        ui->spinBox_blocks_count->setValue(0);
    }
}

void data_widget::changeBlockPattern(int num)
{
    if (model_data->getNumBlockPatterns() > 0)
    {
        if (num > model_data->getNumBlockPatterns())
            ui->spinBox_block_pattern_num->setValue(model_data->getNumBlockPatterns());
        else if (num < 1)
            ui->spinBox_block_pattern_num->setValue(1);
        else
            timeBlocks->setModel(model_data->getBlockPattern(num-1)->getBlocks());
    }
}

void data_widget::changeJitter()
{
    QString value(ui->lineEdit_jitter->text());
    bool okay = true;
    double fl = value.toDouble(&okay);
    if (okay)
        model_data->set_jitter_param(fl);
    else
        while (!okay)
        {
            value.truncate(value.count() - 1);
            fl = value.toDouble(&okay);
        }
    ui->lineEdit_jitter->setText(QString::number(fl));
}

void data_widget::changeConvergence()
{
    QString value(ui->lineEdit_convergence->text());
    bool okay = true;
    double fl = value.toDouble(&okay);
    if (okay)
        model_data->set_convergence_criteria(fl);
    else
        while (!okay)
        {
            value.truncate(value.count() - 1);
            fl = value.toDouble(&okay);
        }
    ui->lineEdit_convergence->setText(QString::number(fl));
}

void data_widget::changeDepDenom()
{
    QString value(ui->lineEdit_dep_denom->text());
    double db = checkdoublevalue(value);
    model_data->set_depletion_denom(db);
    ui->lineEdit_dep_denom->setText(QString::number(db));
}

