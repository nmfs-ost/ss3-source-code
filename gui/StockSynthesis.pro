#-------------------------------------------------
#
# Project created by QtCreator 2013-09-24T08:40:37
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = StockSynthesis
TEMPLATE = app


SOURCES += main.cpp\
        mainwindow.cpp \
    dialoginputfiles.cpp \
    fileselector.cpp \
    dialog_yearlyvalues.cpp \
    form_yearvalue.cpp \
    choose_year_widget.cpp \
    data_widget.cpp \
    control_widget.cpp \
    input_file.cpp \
    model.cpp \
    area.cpp \
    file_info_widget.cpp \
    file_info_dialog.cpp \
    file_widget.cpp \
    population.cpp \
    selectivity.cpp \
    catchability.cpp \
    sizecomp.cpp \
    agecomp.cpp \
    dialog_about.cpp \
    forecast_widget.cpp \
    dialog_about_admb.cpp \
    fleet.cpp \
    composition.cpp \
    error_vector.cpp \
    ss_forecast.cpp \
    fleet_widget.cpp \
    observation_widget.cpp \
    data_input_dialog.cpp \
    growth.cpp \
    growth_morph.cpp \
    ss_observation.cpp \
    ss_recruitment.cpp \
    ss_movement.cpp \
    ss_fecundity.cpp \
    ss_mortality.cpp \
    long_parameter.cpp \
    short_parameter.cpp \
    ss_q.cpp \
    method_setup.cpp \
    block_pattern.cpp \
    sd_reporting.cpp \
    lambda_change.cpp \
    lambda.cpp \
    variance_adjustment.cpp \
    tag.cpp \
    selex_equation.cpp \
    q.cpp \
    growth_season_effects.cpp \
    growth_pattern.cpp \
    dialog_about_nft.cpp \
    population_widget.cpp \
    yearindexmeasure.cpp \
    composition_widget.cpp \
    dialog_float_list.cpp \
    observation_dialog.cpp \
    fleetlambda.cpp \
    errorfloatdialog.cpp \
    dialog_run.cpp \
    dialog_view.cpp \
    spinboxdelegate.cpp \
    doublespinboxdelegate.cpp \
    dialog_fileview.cpp \
    console_redir.cpp \
    fleet_catch.cpp \
    lineeditdelegate.cpp \
    tablemodel.cpp \
    tableview.cpp \
    lambdadelegate.cpp \
    catchdelegate.cpp \
    abundancedelegate.cpp \
    mbweightdelegate.cpp \
    parametermodel.cpp \
    newfleetdialog.cpp \
    fileIO32.cpp \
    fileIO33.cpp \
    dialog_about_gui.cpp \
    metadata.cpp \
    fileIOgeneral.cpp \
    fleet_composition.cpp \
    documentdialog.cpp

HEADERS  += mainwindow.h \
    dialoginputfiles.h \
    fileselector.h \
    dialog_yearlyvalues.h \
    form_yearvalue.h \
    choose_year_widget.h \
    data_widget.h \
    control_widget.h \
    metadata.h \
    input_file.h \
    model.h \
    area.h \
    file_info_widget.h \
    file_info_dialog.h \
    file_widget.h \
    population.h \
    selectivity.h \
    catchability.h \
    sizecomp.h \
    agecomp.h \
    dialog_about.h \
    forecast_widget.h \
    dialog_about_admb.h \
    fleet.h \
    composition.h \
    error_vector.h \
    ss_forecast.h \
    fleet_widget.h \
    observation_widget.h \
    data_input_dialog.h \
    growth.h \
    growth_morph.h \
    ss_observation.h \
    ss_recruitment.h \
    ss_movement.h \
    ss_fecundity.h \
    ss_mortality.h \
    long_parameter.h \
    short_parameter.h \
    ss_q.h \
    method_setup.h \
    block_pattern.h \
    sd_reporting.h \
    lambda_change.h \
    lambda.h \
    variance_adjustment.h \
    tag.h \
    selex_equation.h \
    q.h \
    growth_season_effects.h \
    growth_pattern.h \
    dialog_about_nft.h \
    population_widget.h \
    yearindexmeasure.h \
    composition_widget.h \
    dialog_float_list.h \
    observation_dialog.h \
    fleetlambda.h \
    errorfloatdialog.h \
    dialog_run.h \
    dialog_view.h \
    spinboxdelegate.h \
    doublespinboxdelegate.h \
    dialog_fileview.h \
    console_redir.h \
    fleet_catch.h \
    lineeditdelegate.h \
    tablemodel.h \
    tableview.h \
    lambdadelegate.h \
    catchdelegate.h \
    abundancedelegate.h \
    mbweightdelegate.h \
    parametermodel.h \
    newfleetdialog.h \
    fileIO32.h \
    fileIO33.h \
    fileIOJSON.h \
    fileIOXML.h \
    dialog_about_gui.h \
    fileIOgeneral.h \
    fleet_composition.h \
    documentdialog.h

FORMS    += mainwindow.ui \
    dialoginputfiles.ui \
    fileselector.ui \
    dialog_yearlyvalues.ui \
    form_yearvalue.ui \
    choose_year_widget.ui \
    data_widget.ui \
    control_widget.ui \
    length_bin_data.ui \
    length_bin_boundaries.ui \
    file_info_widget.ui \
    file_info_dialog.ui \
    file_widget.ui \
    dialog_about.ui \
    forecast_widget.ui \
    dialog_about_admb.ui \
    fleet_widget.ui \
    observation_widget.ui \
    data_input_dialog.ui \
    dialog_about_nft.ui \
    population_widget.ui \
    composition_widget.ui \
    dialog_float_list.ui \
    observation_dialog.ui \
    errorfloatdialog.ui \
    dialog_run.ui \
    dialog_view.ui \
    dialog_fileview.ui \
    newfleetdialog.ui \
    dialog_about_gui.ui \
    documentdialog.ui

OTHER_FILES +=

RESOURCES += \
    stock_synth.qrc
