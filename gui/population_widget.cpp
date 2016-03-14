#include <QWidget>

#include "population_widget.h"
#include "ui_population_widget.h"

population_widget::population_widget(ss_model *m_data, QWidget *parent) :
    QWidget(parent), ui(new Ui::population_widget)
{
    ui->setupUi(this);
    model_data = m_data;
    pop = model_data->pPopulation;

//    ui->verticalLayout_fishingMort_2_detail->addWidget();

    // Fecundity
    ui->spinBox_fecund_hermaph_season->setMinimum(-1);

    fecundParamsView = new tableview();
    fecundParamsView->setParent(this);
    fecundParamsView->setModel(pop->Fec()->getFemaleParams());
    fecundParamsView->resizeColumnsToContents();
    fecundParamsView->resize(8192, 150);
    ui->verticalLayout_fec_params->addWidget(fecundParamsView);

    hermaphParamsView = new tableview();
    hermaphParamsView->setParent(this);
    hermaphParamsView->setModel(pop->Fec()->getHermParams());
    ui->verticalLayout_hermaph_params->addWidget(hermaphParamsView);

    connect (ui->lineEdit_fraction_female, SIGNAL(editingFinished()), SLOT(changeFractionFemale()));
    connect (ui->comboBox_fecund_option, SIGNAL(currentIndexChanged(int)), SLOT(changeFecundityOption(int)));
    connect (ui->checkBox_fecund_hermaph, SIGNAL(toggled(bool)), SLOT(changeHermaph(bool)));
    connect (ui->spinBox_fecund_hermaph_season, SIGNAL(valueChanged(int)), SLOT(changeHermaphSeas(int)));
    connect (ui->spinBox_fecund_hermaph_male, SIGNAL(valueChanged(int)), SLOT(changeHermaphMales(int)));
    connect (ui->comboBox_fecund_gend_offset, SIGNAL(currentIndexChanged(int)), SLOT(changeFecundityOffsetOption(int)));
    connect (ui->comboBox_fecund_adj_constraint, SIGNAL(currentIndexChanged(int)), SLOT(changeFecundityAdjustment(int)));

    // Recruitment
    assignmentView = new tableview();
    assignmentView->setParent(this);
    assignmentView->setModel(pop->SR()->getAssignments());
    assignmentView->resizeColumnsToContents();
    ui->horizontalLayout_recr_assigns->addWidget(assignmentView);

    recruitParamsView = new tableview();
    recruitParamsView->setParent(this);
    recruitParamsView->setModel(pop->SR()->getSetupModel());
    recruitParamsView->resizeColumnsToContents();
    ui->verticalLayout_recr_params->addWidget(recruitParamsView);

    recruitDevsView = new tableview();
    recruitDevsView->setParent(this);
    recruitDevsView->setModel(pop->SR()->getRecruitDevs()->getObservations());
    recruitDevsView->resizeColumnsToContents();
    ui->verticalLayout_recr_devs->addWidget(recruitDevsView);

    // Growth
    recruitFullParamsView = new tableview();
    recruitFullParamsView->setParent(this);
    recruitFullParamsView->setModel(pop->SR()->getFullParameterModel());
    recruitFullParamsView->resizeColumnsToContents();
    ui->verticalLayout_recr_full_params->addWidget(recruitFullParamsView);

    connect (ui->spinBox_growth_pattern, SIGNAL(valueChanged(int)), SLOT(changeGrowthPattern(int)));
    connect (ui->spinBox_growth_num_patterns, SIGNAL(valueChanged(int)), SLOT(changeNumGrowthPat(int)));
    ui->spinBox_growth_num_patterns->setValue(pop->Grow()->getNum_patterns());
    connect (ui->spinBox_growth_num_submorphs, SIGNAL(valueChanged(int)), SLOT(changeNumSubMorph(int)));
    ui->spinBox_growth_num_submorphs->setValue(pop->Grow()->getNum_morphs());
    connect (ui->comboBox_growth_model, SIGNAL(currentIndexChanged(int)), SLOT(changeGrowthModel(int)));
    ui->comboBox_growth_model->setCurrentIndex(pop->Grow()->getModel() - 1);

    // Movement
    moveDefsView = new tableview();
    moveDefsView->setParent(this);
    moveDefsView->setModel(pop->Move()->getMovementDefs());
    moveDefsView->resizeColumnsToContents();
    ui->horizontalLayout_move_defs->addWidget(moveDefsView);

    // Maturity
    growthParamsView = new tableview();
    growthParamsView->setParent(this);
    ui->verticalLayout_maturity_params->addWidget(growthParamsView);

    connect (ui->comboBox_maturity_option, SIGNAL(currentIndexChanged(int)), SLOT(changeMaturityOpt(int)));
    connect (ui->lineEdit_maturity_first_age, SIGNAL(editingFinished()), SLOT(changeFirstMatureAge()));


    // Mortality
    mortBreakPtsView = new tableview();
    mortBreakPtsView->setParent (this);
    mortBreakPtsView->setModel(pop->Grow()->getNatMortValues());
    mortBreakPtsView->resizeColumnsToContents();
    ui->verticalLayout_breakpoints->addWidget(mortBreakPtsView);
    mortAgesView = new tableview();
    mortAgesView->setParent(this);
    mortAgesView->setModel(pop->Grow()->getNatMortAgeValues());
    mortAgesView->resizeColumnsToContents();
    ui->horizontalLayout_mort_age_specific->addWidget(mortAgesView);
    mortParamsView = new tableview();
    mortParamsView->setParent (this);
    mortParamsView->setModel(pop->Grow()->getPattern(0)->getNatMParams());
    mortParamsView->resizeColumnsToContents();
    ui->verticalLayout_mort_params->addWidget(mortParamsView);

    mortInputsView = new tableview();
    mortInputsView->setParent(this);
    mortInputsView->setModel(pop->M()->getInputModel());
    mortInputsView->resizeColumnsToContents();
    ui->verticalLayout_mort_inputs->addWidget(mortInputsView);
    mortInitialParamsView = new tableview();
    mortInitialParamsView->setParent(this);
    mortInitialParamsView->setModel(pop->M()->getInitialParams());
    mortInitialParamsView->resizeColumnsToContents();
    ui->verticalLayout_init_F->addWidget(mortInitialParamsView);

    connect (ui->comboBox_mort_option, SIGNAL(currentIndexChanged(int)), SLOT(changeMortOption(int)));

    // Seasonal
    seasonParamsView = new tableview();
    seasonParamsView->setParent(this);
    seasonParamsView->setModel(pop->getSeasonalParams());
    seasonParamsView->resizeColumnsToContents();
    ui->verticalLayout_seasonal_params->addWidget(seasonParamsView);

    connect (ui->spinBox_seas_femWtLen1, SIGNAL(valueChanged(int)), pop, SLOT(setFemwtlen1(int)));
    connect (ui->spinBox_seas_femWtLen2, SIGNAL(valueChanged(int)), pop, SLOT(setFemwtlen2(int)));
    connect (ui->spinBox_seas_fecundity1, SIGNAL(valueChanged(int)), pop, SLOT(setFec1(int)));
    connect (ui->spinBox_seas_fecundity2, SIGNAL(valueChanged(int)), pop, SLOT(setFec2(int)));
    connect (ui->spinBox_seas_maturity1, SIGNAL(valueChanged(int)), pop, SLOT(setMat1(int)));
    connect (ui->spinBox_seas_maturity2, SIGNAL(valueChanged(int)), pop, SLOT(setMat2(int)));
    connect (ui->spinBox_seas_maleWtLen1, SIGNAL(valueChanged(int)), pop, SLOT(setMalewtlen1(int)));
    connect (ui->spinBox_seas_maleWtLen2, SIGNAL(valueChanged(int)), pop, SLOT(setMalewtlen2(int)));
    connect (ui->spinBox_seas_L1, SIGNAL(valueChanged(int)), pop, SLOT(setL1(int)));
    connect (ui->spinBox_seas_K, SIGNAL(valueChanged(int)), pop, SLOT(setK(int)));
    connect (ui->spinBox_seas_femWtLen1, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_femWtLen2, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_fecundity1, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_fecundity2, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_maturity1, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_maturity2, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_maleWtLen1, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_maleWtLen2, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_L1, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));
    connect (ui->spinBox_seas_K, SIGNAL(valueChanged(int)), SLOT(changeSeasParams()));

    setRecrArea(2);
    setRecrDistParam(1);
    ui->checkBox_recr_interaction->setChecked(false);
    ui->spinBox_growth_pattern->setMinimum(1);
    connect (ui->radioButton_area, SIGNAL(clicked()), SLOT(changeRecrArea()));
    connect (ui->radioButton_global, SIGNAL(clicked()), SLOT(changeRecrArea()));
    connect (ui->spinBox_recr_dist_params, SIGNAL(valueChanged(int)), SLOT(changeRecrDistParam(int)));
    connect (ui->checkBox_recr_interaction, SIGNAL(toggled(bool)), SLOT(changeRecAssignInteract(bool)));
    connect (ui->spinBox_recr_num_assigns, SIGNAL(valueChanged(int)), SLOT(changeRecNumAssigns(int)));
    connect (ui->comboBox_recr_spec, SIGNAL(currentIndexChanged(int)), SLOT(changeSpawnRecrSpec(int)));

    connect (ui->spinBox_num_move_defs, SIGNAL(valueChanged(int)), SLOT(changeMoveNumDefs(int)));
    connect (ui->lineEdit_move_age, SIGNAL(editingFinished()), SLOT(changeMoveFirstAge()));

    connect (ui->lineEdit_fishingMort_bpark, SIGNAL(editingFinished()), SLOT(changeFMortBpark()));
    connect (ui->spinBox_fishingMort_bpark_year, SIGNAL(valueChanged(int)), SLOT(changeFMortBparkYr(int)));
    connect (ui->lineEdit_fishingMort_max, SIGNAL(editingFinished()), SLOT(changeFMortMaxF()));
    connect (ui->comboBox_fishingMort_method, SIGNAL(currentIndexChanged(int)), SLOT(changeFMortMethod(int)));
    connect (ui->lineEdit_fishingMort_2_fstart, SIGNAL(editingFinished()), SLOT(changeFMortStartF()));
    connect (ui->spinBox_fishingMort_2_phase, SIGNAL(valueChanged(int)), SLOT(changeFMortPhase(int)));
    connect (ui->spinBox_fishingMort_2_num_detail, SIGNAL(valueChanged(int)), SLOT(changeFMortNumInput(int)));
    connect (ui->spinBox_fishingMort_3_num_iters, SIGNAL(valueChanged(int)), SLOT(changeFMortNumIters(int)));

    reset();
    refresh();
    ui->tabWidget->setCurrentIndex(0);
}

population_widget::~population_widget()
{
    delete ui;
}

void population_widget::set_model(ss_model *model)
{
    model_data = model;
    pop = model_data->pPopulation;
    reset();
}

void population_widget::changeGrowthPattern (int num)
{
    growthParamsView->setModel(pop->Grow()->getPattern(num-1)->getGrowthParams());
    growthParamsView->resizeColumnsToContents();

    mortParamsView->setModel(pop->Grow()->getPattern(num-1)->getNatMParams());
    mortParamsView->resizeColumnsToContents();
}

void population_widget::reset()
{
    ui->lineEdit_fraction_female->setText(QString::number(pop->get_frac_female()));
    setFecundityOption(pop->Fec()->getMethod());
    ui->checkBox_fecund_hermaph->setChecked(pop->Fec()->getHermaphroditism());
    ui->spinBox_fecund_hermaph_season->setMaximum(model_data->num_seasons());
    ui->spinBox_fecund_hermaph_season->setValue(pop->Fec()->getHermSeason());
    ui->spinBox_fecund_hermaph_male->setValue(pop->Fec()->getHermIncludeMales());
    setFecundityOffsetOption(pop->Grow()->getParam_offset_method());
    setFecundityAdjustment(pop->Grow()->getAdjustment_method());

    setMaturityOpt(pop->Grow()->getMaturity_option());
    ui->lineEdit_maturity_first_age->setText(QString::number(pop->Grow()->getFirst_mature_age()));

    int temp_int = pop->Grow()->getNum_patterns();
    ui->spinBox_growth_num_patterns->setValue(temp_int);
    changeNumGrowthPat(temp_int);
    if (temp_int != 0)
        temp_int = pop->Grow()->getNum_morphs();
    ui->spinBox_growth_num_submorphs->setValue(temp_int);
    changeNumSubMorph(temp_int);

    ui->spinBox_seas_femWtLen1->setValue(pop->getFemwtlen1());
    ui->spinBox_seas_femWtLen2->setValue(pop->getFemwtlen2());
    ui->spinBox_seas_fecundity1->setValue(pop->getFec1());
    ui->spinBox_seas_fecundity2->setValue(pop->getFec2());
    ui->spinBox_seas_maturity1->setValue(pop->getMat1());
    ui->spinBox_seas_maturity2->setValue(pop->getMat2());
    ui->spinBox_seas_maleWtLen1->setValue(pop->getMalewtlen1());
    ui->spinBox_seas_maleWtLen2->setValue(pop->getMalewtlen2());
    ui->spinBox_seas_L1->setValue(pop->getL1());
    ui->spinBox_seas_K->setValue(pop->getK());
    changeSeasParams();

    setRecrArea(pop->SR()->getDistribArea());
    setRecrDistParam(pop->SR()->getDistribMethod());
    ui->checkBox_recr_interaction->setChecked(pop->SR()->getDoRecruitInteract());
    ui->spinBox_recr_num_assigns->setValue(pop->SR()->getNumAssignments());
    setSpawnRecrSpec(pop->SR()->method);
    ui->spinBox_sr_env_link->setValue(pop->SR()->env_link);
    ui->spinBox_sr_env_tgt->setValue(pop->SR()->env_target);
    ui->spinBox_sr_recr_dev_begin_yr->setValue(pop->SR()->rec_dev_start_yr);
    ui->spinBox_sr_recr_dev_phase->setValue(pop->SR()->rec_dev_phase);
    ui->spinBox_sr_recr_dev_end_yr->setValue(pop->SR()->rec_dev_end_yr);
    ui->checkBox_recr_dev_adv_opt->setChecked(pop->SR()->advanced_opts);
    ui->spinBox_recr_dev_early_start->setValue(pop->SR()->rec_dev_early_start);
    ui->spinBox_recr_dev_early_phase->setValue(pop->SR()->rec_dev_early_phase);
    ui->spinBox_recr_dev_fcast_phase->setValue(pop->SR()->fcast_rec_phase);
    ui->lineEdit_recr_dev_fcast_lambda->setText(QString::number(pop->SR()->fcast_lambda));
    ui->spinBox_recr_dev_last_nobias->setValue(pop->SR()->nobias_last_early_yr);
    ui->spinBox_recr_dev_first_bias->setValue(pop->SR()->fullbias_first_yr);
    ui->spinBox_recr_dev_last_bias->setValue(pop->SR()->fullbias_last_yr);
    ui->spinBox_recr_dev_first_nobias->setValue(pop->SR()->nobias_first_recent_yr);
    ui->lineEdit_recr_dev_max_bias->setText(QString::number(pop->SR()->max_bias_adjust));
    ui->spinBox_recr_dev_cycles->setValue(pop->SR()->rec_cycles);
    ui->lineEdit_recr_dev_min_dev->setText(QString::number(pop->SR()->rec_dev_min));
    ui->lineEdit_recr_dev_max_dev->setText(QString::number(pop->SR()->rec_dev_max));
    ui->spinBox_num_recr_devs->setValue(pop->SR()->getRecruitDevs()->getNumObs());


    ui->spinBox_num_move_defs->setValue(pop->Move()->getNumDefs());
    ui->lineEdit_move_age->setText(QString::number(pop->Move()->getFirstAge()));

    ui->comboBox_mort_option->setCurrentIndex(pop->Grow()->getNatural_mortality_type());
    ui->spinBox_mort_lorenz_int->setValue(pop->Grow()->getNaturalMortLorenzenRef());
    ui->spinBox_mort_num_breakpoints->setValue(pop->Grow()->getNatMortNumBreakPts());

    ui->lineEdit_fishingMort_bpark->setText(QString::number(pop->M()->getBparkF()));
    ui->spinBox_fishingMort_bpark_year->setValue(pop->M()->getBparkYr());
    ui->lineEdit_fishingMort_max->setText(QString::number(pop->M()->getMaxF()));
    ui->comboBox_fishingMort_method->setCurrentIndex(pop->M()->getMethod() - 1);
    changeFMortMethod(ui->comboBox_fishingMort_method->currentIndex());
    ui->lineEdit_fishingMort_2_fstart->setText(QString::number(pop->M()->getStartF()));
    ui->spinBox_fishingMort_2_phase->setValue(pop->M()->getPhase());
    ui->spinBox_fishingMort_2_num_detail->setValue(pop->M()->getNumInputs());
    ui->spinBox_fishingMort_3_num_iters->setValue(pop->M()->getNumTuningIters());
}

void population_widget::refresh()
{
    hermaphParamsView->resizeColumnsToContents();
    growthParamsView->resizeColumnsToContents();
    seasonParamsView->resizeColumnsToContents();
    assignmentView->resizeColumnsToContents();
    recruitParamsView->resizeColumnsToContents();
    recruitDevsView->resizeColumnsToContents();
    recruitFullParamsView->resizeColumnsToContents();
    mortBreakPtsView->resizeColumnsToContents();
    changeMortOption(model_data->getPopulation()->Grow()->getNatural_mortality_type());
}

void population_widget::setFecundityOption(int opt)
{
    int index = opt - 1;
    ui->comboBox_fecund_option->setCurrentIndex(index);
}

void population_widget::changeFecundityOption(int opt)
{
    int num = opt + 1;
    pop->Fec()->setMethod(num);
}

int population_widget::getFecundityOption()
{
    int num = ui->comboBox_fecund_option->currentIndex() + 1;
    return num;
}

void population_widget::setFecundityOffsetOption(int opt)
{
    ui->comboBox_fecund_gend_offset->setCurrentIndex(opt - 1);
}

void population_widget::changeFecundityOffsetOption(int opt)
{
    int num = opt + 1;
    pop->Grow()->setParam_offset_method(num);
}

int population_widget::getFecundityOffsetOption()
{
    return (ui->comboBox_fecund_gend_offset->currentIndex() + 1);
}

void population_widget::setFecundityAdjustment(int opt)
{
    ui->comboBox_fecund_adj_constraint->setCurrentIndex(opt - 1);
}

void population_widget::changeFecundityAdjustment(int opt)
{
    int num = opt + 1;
    pop->Grow()->setAdjustment_method(num);
}

int population_widget::getFecundityAdjustment()
{
    return (ui->comboBox_fecund_adj_constraint->currentIndex() + 1);
}

void population_widget::changeMortOption(int opt)
{
    model_data->getPopulation()->Grow()->setNatural_mortality_type(opt);
    ui->widget_mort_breakpoints->setVisible(false);
    ui->widget_mort_lorenz->setVisible(false);
    ui->widget_mort_age_specific->setVisible(false);
    switch (opt)
    {
    case 0:
        ui->widget_mort_breakpoints->setVisible(false);
        ui->widget_mort_age_specific->setVisible(false);
        break;
    case 1:
        ui->widget_mort_breakpoints->setVisible(true);
        ui->widget_mort_age_specific->setVisible(false);
//        ui->verticalLayout_mort_params->addWidget(mortParamsView);
        break;
    case 2:
        ui->widget_mort_lorenz->setVisible(true);
        break;
    case 3:
    case 4:
        ui->widget_mort_breakpoints->setVisible(false);
        ui->widget_mort_age_specific->setVisible(true);
//        ui->horizontalLayout_mort_age_specific->addWidget(mortBreakPtsView);
        break;
    }
    reset();
}

void population_widget::changeNumGrowthPat(int num)
{
    bool vis = (bool)num;
    pop->Grow()->setNum_patterns(num);
    ui->spinBox_growth_pattern->setMaximum(num);
    ui->label_growth_num_submorphs->setVisible(vis);
    ui->spinBox_growth_num_submorphs->setVisible(vis);
    if (vis)
        changeNumSubMorph(ui->spinBox_growth_num_submorphs->value());
    else
        changeNumSubMorph(1);
}

void population_widget::changeNumSubMorph(int num)
{
    bool vis = false;
    pop->Grow()->setNum_morphs(num);
    if (num > 1)
        vis = true;
//    ui->label_growth_submorph_dist->setVisible(vis);
//    ui->label_growth_submorph_ratio->setVisible(vis);
//    ui->doubleSpinBox_growth_morph_ratio->setVisible(vis);
    ui->frame_submorphs->setVisible(vis);
}

void population_widget::setGrowthModel(int opt)
{
    ui->comboBox_growth_model->setCurrentIndex(opt - 1);
    changeGrowthModel(ui->comboBox_growth_model->currentIndex());
}

void population_widget::changeGrowthModel(int opt)
{
    bool vis = false;
    pop->Grow()->setModel(opt + 1);
    if (opt == 2)
        vis = true;
    ui->frame_growth_age_spec_k->setVisible(vis);
}

int population_widget::getGrowthModel()
{
    return ui->comboBox_growth_model->currentIndex() + 1;
}

void population_widget::changeFractionFemale()
{
    float value = ui->lineEdit_fraction_female->text().toFloat();
    pop->set_frac_female(value);
}

void population_widget::changeHermaph(bool flag)
{
    pop->Fec()->setHermaphroditism(flag);
    ui->frame_fecund_hermaph->setVisible(flag);
}

void population_widget::changeHermaphSeas(int seas)
{
    pop->Fec()->setHermSeason(seas);
}

void population_widget::changeHermaphMales(int opt)
{
    pop->Fec()->setHermIncludeMales(opt);
}

void population_widget::setMaturityOpt(int opt)
{
    ui->comboBox_maturity_option->setCurrentIndex(opt - 1);
    changeMaturityOpt(ui->comboBox_maturity_option->currentIndex());
}

void population_widget::changeMaturityOpt(int opt)
{
    bool vis = false;
    pop->Grow()->setMaturity_option(opt + 1);
    if (opt == 2 || opt == 3)
        vis = true;
    ui->frame_growth_age_spec->setVisible(vis);
}

int population_widget::getMaturityOpt()
{
    return ui->comboBox_maturity_option->currentIndex() + 1;
}

void population_widget::changeFirstMatureAge()
{
    float value = ui->lineEdit_maturity_first_age->text().toFloat();
    pop->Grow()->setFirst_mature_age(value);
}

void population_widget::changeSeasParams()
{
    bool showtable = false;
    if (ui->spinBox_seas_femWtLen1->value() > 0) showtable = true;
    if (ui->spinBox_seas_femWtLen2->value() > 0) showtable = true;
    if (ui->spinBox_seas_maturity1->value() > 0) showtable = true;
    if (ui->spinBox_seas_maturity2->value() > 0) showtable = true;
    if (ui->spinBox_seas_fecundity1->value() > 0) showtable = true;
    if (ui->spinBox_seas_fecundity2->value() > 0) showtable = true;
    if (ui->spinBox_seas_maleWtLen1->value() > 0) showtable = true;
    if (ui->spinBox_seas_maleWtLen2->value() > 0) showtable = true;
    if (ui->spinBox_seas_L1->value() > 0) showtable = true;
    if (ui->spinBox_seas_K->value() > 0) showtable = true;
    seasonParamsView->setVisible(showtable);
}

void population_widget::setRecrArea(int value)
{
    if (value == 1)
        ui->radioButton_global->setChecked(true);
    else if (value == 2)
        ui->radioButton_area->setChecked(true);
}

void population_widget::changeRecrArea()
{
    int area = getRecrArea();
    pop->SR()->setDistribArea(area);
}

int population_widget::getRecrArea()
{
    int value = 0;
    if (ui->radioButton_global->isChecked())
        value = 1;
    else if (ui->radioButton_area->isChecked())
        value = 2;
    return value;
}

void population_widget::setRecrDistParam(int method)
{
    ui->spinBox_recr_dist_params->setValue(method);
    changeRecrDistParam(method);
}

void population_widget::changeRecrDistParam(int method)
{
    pop->SR()->setDistribMethod(method);
    if (method == 1)
        ui->checkBox_recr_interaction->setVisible(true);
    else
        ui->checkBox_recr_interaction->setVisible(false);
}

int population_widget::getRecrDistParam()
{
    return ui->spinBox_recr_dist_params->value();
}

void population_widget::changeRecAssignInteract(bool flag)
{
    pop->SR()->setDoRecruitInteract(flag);
}

void population_widget::changeRecNumAssigns(int num)
{
    bool vis = (num != 0);
    pop->SR()->setNumAssignments(num);
    ui->label_recr_num_assigns->setVisible(vis);
    assignmentView->setVisible(vis);
}

void population_widget::setSpawnRecrSpec(int spec)
{
    if (spec < 1) spec = 1;
    if (spec > 7) spec = 7;
    ui->comboBox_recr_spec->setCurrentIndex(spec - 1);
}

void population_widget::changeSpawnRecrSpec(int num)
{
    pop->SR()->method = num + 1;
}

void population_widget::changeMoveNumDefs(int value)
{
    pop->Move()->setNumDefs(value);
}

void population_widget::changeMoveFirstAge()
{
    float age = ui->lineEdit_move_age->text().toFloat();
    pop->Move()->setFirstAge(age);
}

void population_widget::changeFMortMethod (int opt)
{
    pop->M()->setMethod(opt + 1);
    switch (opt)
    {
    case 0:
        ui->frame_fishingMort_2->setVisible(false);
        ui->frame_fishingMort_3->setVisible(false);
        break;
    case 1:
        ui->frame_fishingMort_2->setVisible(true);
        ui->frame_fishingMort_3->setVisible(false);
        break;
    case 2:
        ui->frame_fishingMort_2->setVisible(false);
        ui->frame_fishingMort_3->setVisible(true);
        break;
    }

}

void population_widget::changeFMortBpark ()
{
    QString txt = ui->lineEdit_fishingMort_bpark->text();
    pop->M()->setBparkF(txt.toFloat());
}

void population_widget::changeFMortBparkYr (int yr)
{
    pop->M()->setBparkYr(yr);
}

void population_widget::changeFMortMaxF ()
{
    QString txt = ui->lineEdit_fishingMort_max->text();
    pop->M()->setMaxF(txt.toFloat());
}

void population_widget::changeFMortStartF ()
{
    QString txt = ui->lineEdit_fishingMort_2_fstart->text();
    pop->M()->setStartF(txt.toFloat());
}

void population_widget::changeFMortPhase (int phs)
{
    pop->M()->setPhase(phs);
}

void population_widget::changeFMortNumInput (int num)
{
    pop->M()->setNumInputs(num);
}

void population_widget::changeFMortNumIters (int num)
{
    pop->M()->setNumTuningIters(num);
}

