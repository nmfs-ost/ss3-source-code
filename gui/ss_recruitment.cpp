#include "ss_recruitment.h"

spawn_recruit::spawn_recruit()
{
    parameters = new parametermodel();
    full_parameters = new parametermodel();
    parameters->setRowCount(6);
    parameters->setColumnCount(7);
    full_parameters->setRowCount(0);

    assignments = new tablemodel();
    header << "GP" << "seas" << "area";
    assignments->setHeader(header);
    assignments->setColumnCount(3);
    assignments->setRowCount(0);

    assignmentParams = new parametermodel();
    interactParams = new parametermodel();

    method = 3;
    env_link = 0;
    env_target = 0;
    rec_dev = 1;
    rec_dev_start_yr = 1980;
    rec_dev_end_yr = 2009;
    rec_dev_phase = -3;
    advanced_opts = true;
    rec_dev_early_start = 0;
    rec_dev_early_phase = -4;
    fcast_rec_phase = 0;
    fcast_lambda = 1;
    nobias_last_early_yr = 971;
    fullbias_first_yr = 1931;
    fullbias_last_yr = 2010;
    nobias_first_recent_yr = 2011;
    max_bias_adjust = 0;
    rec_cycles = 0;
    rec_dev_min = -5;
    rec_dev_max = 5;
    num_rec_dev = 0;
    recruitDeviations = new recruitDevs();
}

spawn_recruit::~spawn_recruit()
{
    delete parameters;
    delete full_parameters;
    delete assignments;
    delete assignmentParams;
    delete recruitDeviations;
    delete interactParams;
}

int spawn_recruit::getNumAssignments()
{
    return assignments->rowCount();
}

void spawn_recruit::setNumAssignments(int rows)
{
    assignments->setRowCount(rows);
}

tablemodel *spawn_recruit::getAssignments() const
{
    return assignments;
}

QStringList spawn_recruit::getAssignment(int row)
{
    return assignments->getRowData(row);
}

void spawn_recruit::setAssignment(int row, QStringList data)
{
    if (row >= assignments->rowCount())
        assignments->setRowCount(row + 1);
    assignments->setRowData(row, data);
}

bool spawn_recruit::getDoRecruitInteract() const
{
    return doRecruitInteract;
}

void spawn_recruit::setDoRecruitInteract(bool value)
{
    doRecruitInteract = value;
}

void spawn_recruit::setDoRecruitInteract(int value)
{
    if (value != 0)
        doRecruitInteract = true;
    else
        doRecruitInteract = false;
}

void spawn_recruit::setInteractParam(int index, QStringList data)
{
    if (index >= interactParams->rowCount())
        interactParams->setRowCount(index + 1);
    interactParams->setRowData(index, data);
}

void spawn_recruit::setAssignmentParam(int index, QStringList data)
{
    if (index >= assignmentParams->rowCount())
        assignmentParams->setRowCount(index + 1);
    assignmentParams->setRowData(index, data);
}

void spawn_recruit::fromFile(ss_file *file)
{
    QString token('#'), temp_str;
    QStringList datalist;
    int i, temp_int, num_lines;
    float temp_float;
    
    method = file->next_value().toInt();
    for (i = 0; i < 6; i++)
    {
        datalist = readShortParameter(file);//.clear();
//        for (int j = 0; j < 7; j++)
//            datalist.append(file->next_value());
        parameters->setRowData(i, datalist);
//        parameters[i].fromText(token);
//        token = file->read_line();
    }
    if (method == 5 ||
            method == 7 ||
            method == 8)
    {
        datalist = readShortParameter(file);
        parameters->setRowData(i, datalist);
    }
    env_link = file->next_value().toFloat();//token.split(' ', QString::SkipEmptyParts).at(0).toFloat();
    env_target = file->next_value().toInt();
    rec_dev = file->next_value().toInt();
    rec_dev_start_yr = file->next_value().toInt();
    rec_dev_end_yr = file->next_value().toInt();
    rec_dev_phase = file->next_value().toInt();
    advanced_opts = (file->next_value().compare("0") != 0);

    if (advanced_opts)
    {
        rec_dev_early_start = file->next_value().toInt();
        rec_dev_early_phase = file->next_value().toInt();
        fcast_rec_phase = file->next_value().toInt();
        fcast_lambda = file->next_value().toFloat();
        nobias_last_early_yr = file->next_value().toInt();
        fullbias_first_yr = file->next_value().toInt();
        fullbias_last_yr = file->next_value().toInt();
        nobias_first_recent_yr = file->next_value().toInt();
        max_bias_adjust = file->next_value().toFloat();
        rec_cycles = file->next_value().toInt();
        rec_dev_min = file->next_value().toInt();
        rec_dev_max = file->next_value().toInt();
        num_rec_dev = file->next_value().toInt();

        full_parameters->setRowCount(rec_cycles);
        for (i = 0; i < rec_cycles; i++)
        {
            datalist = readParameter(file);
            full_parameters->setRowData(i, datalist);
        }

        getRecruitDevs()->setNumRecruitDevs(num_rec_dev);
        for (i = 0; i < num_rec_dev; i++)
        {
            datalist.clear();
            datalist.append(file->next_value());
            datalist.append(file->next_value());
            getRecruitDevs()->setRecruitDev(i, datalist);
/*            temp_int = file->next_value().toInt();
            temp_float = file->next_value().toFloat();
            yearly_devs[temp_int] = temp_float;*/
        }
    }
}

QString spawn_recruit::toText()
{
    int i, temp_ind;
    float temp_val;
    QString txt;
    QStringList datalist;

    sr_text.clear();
    sr_text.append(QString("#_Spawner-Recruitment" ));
    sr_text.append(QString("%1 #_SR_function").arg(
                       QString::number(method)));
    sr_text.append(QString(": 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepard_3Parm" ));
    sr_text.append(QString("#_LO HI INIT PRIOR PR_TYPE SD PHASE" ));
/*    for (i = 0; i < 6; i++)
    {
        datalist = parameters->getRowData(i);
        for (int j = 0; j < 7; j++)
            sr_text.append(QString(" %1").arg(datalist.at(j)));

        sr_text.append(QString (" # " ));
    }*/
    sr_text.append(QString ("%1 # SR_LN(R0)" ).arg(parameters->getRowText(0)));
    sr_text.append(QString ("%1 # SR_BH_steep" ).arg(parameters->getRowText(1)));
    sr_text.append(QString ("%1 # SR_sigmaR" ).arg(parameters->getRowText(2)));
    sr_text.append(QString ("%1 # SR_envlink" ).arg(parameters->getRowText(3)));
    sr_text.append(QString ("%1 # SR_R1_offset" ).arg(parameters->getRowText(4)));
    sr_text.append(QString ("%1 # SR_autocorr" ).arg(parameters->getRowText(5)));

    sr_text.append(QString ("%1 #_SR_env_link" ).arg(
                       QString::number(env_link)));
    sr_text.append(QString ("%1 #_SR_env_target_0=none;1=devs;_2=R0;_3=steepness" ).arg(
                       QString::number(env_target)));
    sr_text.append(QString ("%1 #_do_rec_dev:  0=none; 1=devvector; 2=simple deviations" ).arg(
                       QString::number(rec_dev)));
    sr_text.append(QString ("%1 #_first_year_of_main_rec_devs; early devs can preceed this era" ).arg(
                       QString::number(rec_dev_start_yr)));
    sr_text.append(QString ("%1 #_last_year_of_main_rec_devs; forecast devs start in following year" ).arg(
                       QString::number(rec_dev_end_yr)));
    sr_text.append(QString ("%1 #_rec-dev phase" ).arg(
                       QString::number(rec_dev_phase)));
    sr_text.append(QString ("%1 # (0/1) to read 13 advanced options" ).arg(
                       advanced_opts? "1":"0"));

    if (advanced_opts)
    {
        sr_text.append(QString (" %1 #_rec-dev early start (0=none; neg value makes relative to recdev_start)" ).arg(
                           QString::number(rec_dev_early_start)));
        sr_text.append(QString (" %1 #_rec-dev early phase" ).arg(
                           QString::number(rec_dev_early_phase)));
        sr_text.append(QString (" %1 #_forecast recruitment phase (incl. late recr) (0 value resets to maxphase+1)" ).arg(
                           QString::number(fcast_rec_phase)));
        sr_text.append(QString (" %1 #_lambda for forecast_recr_like occurring before endyr+1" ).arg(
                           QString::number(fcast_lambda)));
        sr_text.append(QString (" %1 #_last_early_yr_nobias_adj_in_MPD" ).arg(
                           QString::number(nobias_last_early_yr)));
        sr_text.append(QString (" %1 #_first_yr_fullbias_adj_in_MPD" ).arg(
                           QString::number(fullbias_first_yr)));
        sr_text.append(QString (" %1 #_last_yr_fullbias_adj_in_MPD" ).arg(
                           QString::number(fullbias_last_yr)));
        sr_text.append(QString (" %1 #_first_recent_yr_nobias_adj_in_MPD" ).arg(
                           QString::number(nobias_first_recent_yr)));
        sr_text.append(QString (" %1 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)" ).arg(
                           QString::number(max_bias_adjust)));
        sr_text.append(QString (" %1 #_period of cycles in recruitment (N parms read below)" ).arg(
                           QString::number(rec_cycles)));
        sr_text.append(QString (" %1 #_min rec_dev" ).arg(
                           QString::number(rec_dev_min)));
        sr_text.append(QString (" %1 #_max rec_dev" ).arg(
                           QString::number(rec_dev_max)));
        sr_text.append(QString (" %1 #_read rec_devs" ).arg(
                           QString::number(num_rec_dev)));
        sr_text.append(QString ("#_end of advanced SR options" ));
    }
    sr_text.append("#" );

    if (rec_cycles == 0)
    {
        sr_text.append("#_placeholder for full parameter lines for recruitment cycles" );
    }
    else
    {
        for (i = 0; i < rec_cycles; i++)
        {
//            txt.clear();
            datalist = full_parameters->getRowData(i);
            for (int j = 0; j < 14; j++)
                sr_text.append(QString(" %1").arg(datalist.at(j)));
            sr_text.append(QString (" # " ));
        }
    }

    sr_text.append(QString("# read %1 specified recr devs\n#_Yr Input_value" ).arg(
                       QString::number(num_rec_dev)));
    for (std::map<int,float>::iterator itr = yearly_devs.begin(); itr != yearly_devs.end(); itr++)
    {
        temp_ind = itr->first;
        temp_val = itr->second;
        sr_text.append(QString("%1 %2" ).arg(
                           QString::number(temp_ind),
                           QString::number(temp_val)));
    }
    sr_text.append("#" );

    return sr_text;
}
