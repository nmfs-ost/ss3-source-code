#include "fileIO32.h"
#include "model.h"
#include "fileIOgeneral.h"

bool read32_dataFile(ss_file *d_file, ss_model *data)
{
    QString token;
    QString temp_str;
    QStringList str_lst;
    float temp_float;
    int temp_int = 0, num_input_lines = 0;
    int i, j, num_vals, total_fleets;
    int n_fisheries = 0, n_surveys = 0, n_predators = 0;
    int n_areas = 0, n_ages = 0, n_genders = 0;
    int units, err_type, year, season, fleet, obslength;
    float obs, err;
    float month;

    if(d_file->open(QIODevice::ReadOnly))
    {

        //read_comments(model_data);
        d_file->seek(0);
        d_file->read_comments();

        token = d_file->next_value("start year");
        temp_int = token.toInt();
        data->set_start_year (temp_int);
        token = d_file->next_value("end year");
        temp_int = token.toInt();
        data->set_end_year(temp_int);
        token = d_file->next_value("seasons per year");
        temp_int = token.toInt();
        data->set_num_seasons(temp_int);
        for (i = 1; i <= data->num_seasons(); i++)
        {
            token = d_file->next_value("months per season");
            temp_int = token.toInt();
            data->set_months_per_season(i, temp_int);
        }
        data->set_num_subseasons(2);
        token = d_file->next_value("spawning season");
        temp_int = token.toInt();
        data->set_spawn_season(temp_int);
        token = d_file->next_value("number of fisheries");
        n_fisheries = token.toInt();
        token = d_file->next_value("number of surveys");
        n_surveys = token.toInt();
        total_fleets = n_fisheries + n_surveys;
        data->set_num_fleets(total_fleets);
        for (i = 0; i < n_fisheries; i++)
            data->getFleet(i)->setType(Fleet::Fishing);
        for (j = 0; i < total_fleets; i++, j++)
        {
            data->getFleet(i)->setType(Fleet::Survey);
        }
        if (j != n_surveys)
            d_file->error("The number of survey fleets is incorrect.");
        data->assignFleetNumbers();
        token = d_file->next_value("number of areas");
        temp_int = token.toInt();
        n_areas = temp_int;
        data->set_num_areas(n_areas);

        QStringList names;
        token = d_file->next_value("fleet names");
        names = token.split('%');
        for (i = 0; i < total_fleets; i++)
        {
            if (names.count() > i)
                data->getFleet(i)->set_name (names.at(i));
            else
                data->getFleet(i)->set_name("NONE");
        }
        for (i = 0; i < total_fleets; i++)
        {
            token = d_file->next_value("fishery timing in season");
            temp_float = token.toFloat();
            data->getFleet(i)->set_timing (temp_float);
        }
        for (i = 0; i < total_fleets; i++)
        {
            token = d_file->next_value("fishery area");
            temp_int = token.toInt();
            data->getFleet(i)->set_area (temp_int);
        }
        for (i = 0; i < n_fisheries; i++)
        {
            token = d_file->next_value("catch units");
            temp_int = token.toInt();
            data->getFleet(i)->set_catch_units (temp_int);
        }
        for (i = 0; i < n_fisheries; i++)
        {
            token = d_file->next_value("se of log (catch)");
            temp_float = token.toFloat();
            data->getFleet(i)->set_catch_se (temp_float);
            data->getFleet(i)->set_equ_catch_se(temp_float);
        }
        token = d_file->next_value("number of genders");
        temp_int = token.toInt();
        n_genders = temp_int;
        data->set_num_genders(n_genders);
        token = d_file->next_value("number of ages");
        temp_int = token.toInt();
        n_ages = temp_int;
        data->set_num_ages(n_ages);
        for (i = 0; i < n_fisheries; i++)
        {
            token = d_file->next_value("equilibrium catch");
            temp_float = token.toFloat();
            data->getFleet(i)->set_catch_equil (temp_float);
        }

        for (i = 0; i < n_fisheries; i++)
            data->add_fleet_catch_per_season(i, -999, 1, data->getFleet(i)->catch_equil(), data->getFleet(i)->catch_se());

        token = d_file->next_value("number catch input lines");
        num_input_lines = token.toInt();
/*        for (i = 0; i < n_fisheries; i++)
        {
            data->getFleet(i)->setCatchRows(num_input_lines);
        }*/
        {
            float numbs[20];
            for (i = 0; i < num_input_lines; i++)
            {
                int j;
                for (j = 0; j < n_fisheries; j++)
                {
                    token = d_file->next_value();
                    numbs[j] = token.toFloat();
                }
                token = d_file->next_value("year");
                year = token.toInt(); // year
                token = d_file->next_value("season");
                season = token.toInt(); // season
                for (j = 0; j < n_fisheries; j++)
                {
                    temp_float = data->getFleet(j)->catch_se();
                    data->add_fleet_catch_per_season(j, year, season, numbs[j], temp_float);
                }
            }
        }

        // Abundance
        token = d_file->next_value("number abundance input lines");
        num_input_lines = token.toInt();

        // before we record abundance, get units and error type for all fleets
        for (i = 0; i < total_fleets; i++)
        {
            fleet = abs(d_file->next_value().toInt()) - 1; // fishery
            Fleet *flt = data->getFleet(fleet);
            units = d_file->next_value().toInt(); // units
            flt->set_units(units);
            err_type = d_file->next_value().toInt(); // err_type
            flt->set_error_type(err_type);
        }
        // here are the abundance numbers
        for (i = 0; i < num_input_lines; i++)
        {    // year, season, fleet_number, observation, error
            year = d_file->next_value().toInt();
            season = d_file->next_value().toInt();
            fleet = abs(d_file->next_value().toInt()) - 1;
            obs = d_file->next_value().toFloat();
            err = d_file->next_value().toFloat();
            month = data->getMonthBySeasonFleet(season, fleet);
            data->getFleet(fleet)->addAbundByMonth(year, month, obs, err);
        }

        // Discard
        token = d_file->next_value("num fleets with discard");
        num_vals = token.toInt();
        if (num_vals > 0)
        {
            for (i = 0; i < num_vals; i++)
            {
                fleet = abs(d_file->next_value().toInt()) - 1;
                units = d_file->next_value().toInt();
                err_type = d_file->next_value().toInt();
                data->getFleet(fleet)->set_discard_units(units);
                data->getFleet(fleet)->set_discard_err_type(err_type);
            }
            token = d_file->next_value("number of discard observations");
            // observations
            num_input_lines = token.toInt();
            for (i = 0; i < num_input_lines; i++)
            {
                year = d_file->next_value().toInt();
                season = abs(d_file->next_value().toInt());
                fleet = abs(d_file->next_value().toInt()) - 1;
                obs = d_file->next_value().toFloat();
                err = d_file->next_value().toFloat();
                month = data->getMonthBySeasonFleet(season, fleet);
                data->getFleet(fleet)->setDiscardMonth(year, month, obs, err);
            }
        }
        else
        {
            temp_int = d_file->next_value("num discard observations").toInt();
            if (temp_int != 0)
                d_file->error("Reading number discard observations. No fleets.");
        }

        // mean body weight
        token = d_file->next_value();
        num_input_lines = token.toInt();
        temp_int = d_file->next_value().toInt();
        for (i = 0; i < data->num_fleets(); i++)
            data->getFleet(i)->setMbwtDF(temp_int);
        for (i = 0; i < num_input_lines; i++)
        {
            str_lst.clear();
            for (int j = 0; j < 6; j++)
                str_lst.append(d_file->next_value());
            fleet = abs(str_lst.takeAt(2).toInt()) - 1;
            season = abs(str_lst.takeAt(1).toInt());
            month = data->getMonthBySeasonFleet(season, temp_int-1);
            str_lst.insert(1, QString::number(month));
            data->getFleet(fleet)->addMbwtObservation(str_lst);
        }

        // length data
        {
        compositionLength *l_data = data->get_length_composition();
        if (l_data == NULL)
        {
            l_data = new compositionLength();
            data->set_length_composition(l_data);
        }
        temp_int = d_file->next_value().toInt();
        l_data->setAltBinMethod(temp_int);
        switch (temp_int)
        {
        case 1:  // same as data bins - set after data bins
            break;
        case 2:  // generate from min, max, width
            float min, max, width;
            token = d_file->next_value();
            width = token.toFloat();
            l_data->setAltBinWidth(width);
            token = d_file->next_value();
            min = token.toFloat();
            l_data->setAltBinMin(min);
            token = d_file->next_value();
            max = token.toFloat();
            l_data->setAltBinMax(max);
            l_data->generateAltBins();
            break;
        case 3:  // read vector
            str_lst.clear();
            temp_int = d_file->next_value().toInt();
            l_data->setNumberAltBins(temp_int);
            for (int j = 0; j < temp_int; j++)
                str_lst.append(d_file->next_value());
            l_data->setAltBins(str_lst);
            break;
        }

        token = d_file->next_value();
        for (i = 0; i < data->num_fleets(); i++)
        {
            data->getFleet(i)->setLengthMinTailComp(token);
            data->getFleet(i)->setAgeMinTailComp(token);
        }
//        l_data->set_compress_tails(token.toFloat());
        token = d_file->next_value();
        for (i = 0; i < data->num_fleets(); i++)
        {
            data->getFleet(i)->setLengthAddToData(token);
            data->getFleet(i)->setAgeAddToData(token);
        }
//        l_data->set_add_to_compression(token.toFloat());
        token = d_file->next_value();
        temp_int = token.toInt();
        for (i = 0; i < data->num_fleets(); i++)
        {
            data->getFleet(i)->setLengthCombineGen(temp_int);
        }
//        l_data->set_combine_genders(token.toInt());
        token = d_file->next_value();
        num_vals = token.toInt();
        l_data->setNumberBins(num_vals);
        for (int j = 0; j < data->num_fleets(); j++)
            data->getFleet(j)->setLengthNumBins(num_vals);
        temp_str.clear();
        for (i = 0; i < num_vals; i++)
        {
            str_lst.append(d_file->next_value());
//            token = d_file->next_value();
//            temp_str.append(QString("%1 ").arg(token));
        }
        l_data->setBins(str_lst);//setBin(0, temp_str);
        token = d_file->next_value();
        num_input_lines = token.toInt();
        obslength = data->getFleet(0)->getLengthObsLength() + 1;//l_data->get_obs_length();
        for (i = 0; i < num_input_lines; i++)
        {
            str_lst.clear();
            for (int j = 0; j < obslength; j++)
            {
                token = d_file->next_value();
                str_lst.append(token);
            }
            temp_int = abs(str_lst.takeAt(2).toInt());
            season = abs(str_lst.takeAt(1).toInt());
            month = data->getMonthBySeasonFleet(season, temp_int-1);
            str_lst.insert(1, QString::number(month));
            data->getFleet(temp_int - 1)->addLengthObservation(str_lst);
        }
        }

        // age data
        {
        compositionAge *a_data = data->get_age_composition();
        if (a_data == NULL)
        {
            a_data = new compositionAge ();
            data->set_age_composition(a_data);
        }
        token = d_file->next_value();
        num_vals = token.toInt();
        a_data->setNumberBins(num_vals);
        for (i = 0; i < data->num_fleets(); i++)
        {
            data->getFleet(i)->setAgeNumBins(num_vals);
            data->getFleet(i)->setSaaNumBins(num_vals);
        }
        str_lst.clear();
        temp_str.clear();
        for (i = 0; i < num_vals; i++)
        {
            str_lst.append(d_file->next_value());
//            token = d_file->next_value();
//            temp_str.append(QString("%1 ").arg(token));
        }
        a_data->setBins(str_lst);//0, temp_str);
        token = d_file->next_value();
        temp_int = token.toInt();
        a_data->set_num_error_defs(temp_int);
        for (i = 0; i < temp_int; i++)
        {
            int numAges = data->num_ages();
            str_lst.clear();
            for (int j = 0; j <= numAges; j++)
                str_lst.append(d_file->next_value());
            a_data->set_error_def_ages(i, str_lst);
            str_lst.clear();
            for (int j = 0; j <= numAges; j++)
                str_lst.append(d_file->next_value());
            a_data->set_error_def(i, str_lst);
        }
        token = d_file->next_value();
        num_input_lines = token.toInt();
 //       data->get_age_composition()->set_number_obs(num_input_lines);
        token = d_file->next_value();
        a_data->setAltBinMethod(token.toInt());
        temp_int = d_file->next_value().toInt();
        for (i = 0; i < total_fleets; i++)
            data->getFleet(i)->setAgeCombineGen(temp_int);

        obslength = data->getFleet(0)->getAgeObsLength() + 1;//a_data->get_obs_length();
        for (i = 0; i < num_input_lines; i++)
        {
            str_lst.clear();
            for (int j = 0; j < obslength; j++)
                str_lst.append(d_file->next_value());
            temp_int = abs(str_lst.takeAt(2).toInt());
            season = abs(str_lst.takeAt(1).toInt());
            month = data->getMonthBySeasonFleet(season, temp_int-1);
            str_lst.insert(1, QString::number(month));
            data->getFleet(temp_int - 1)->addAgeObservation(str_lst);
        }

        // mean size at age
        num_input_lines = d_file->next_value().toInt();
        obslength = a_data->getSaaModel()->columnCount() + 1;
        for (i = 0; i < num_input_lines; i++)
        {
            str_lst.clear();
            for (int j = 0; j < obslength; j++)
                str_lst.append(d_file->next_value());
            temp_int = abs(str_lst.takeAt(2).toInt());
            season = abs(str_lst.takeAt(1).toInt());
            month = data->getMonthBySeasonFleet(season, temp_int-1);
            str_lst.insert(1, QString::number(month));
            data->getFleet(temp_int - 1)->addSaaObservation(str_lst);
        }
        }

        // environment variables
        temp_int = d_file->next_value().toInt();
        data->set_num_environ_vars (temp_int);
        num_input_lines = d_file->next_value().toInt();
        obslength = data->getEnvVariables()->columnCount();
        for (i = 0; i < num_input_lines; i++)
        {
            str_lst.clear();
            for(int j = 0; j < 3; j++)
            {
                str_lst.append(d_file->next_value());
            }
            data->set_environ_var_obs (i, str_lst);
        }

        // generalized size composition
        num_vals = d_file->next_value().toInt();
        data->set_num_general_comp_methods(0);
        if (num_vals > 0)
        {
            for (i = 0; i < num_vals; i++)
            {
                compositionGeneral *cps = new compositionGeneral ();
                data->add_general_comp_method(cps);
                data->general_comp_method(i)->setNumber(i+1);
            }
            for (int j = 0; j < total_fleets; j++)
                data->getFleet(j)->setGenModelTotal(num_vals);
            for (i = 0; i < num_vals; i++)
            {
                temp_int = d_file->next_value().toInt();
                data->general_comp_method(i)->setNumberBins(temp_int);
                for (int j = 0; j < total_fleets; j++)
                    data->getFleet(j)->setGenNumBins(i, temp_int);
            }
            for (i = 0; i < num_vals; i++)
            {
                temp_int = d_file->next_value().toInt();
                data->general_comp_method(i)->setUnits(temp_int);
            }
            for (i = 0; i < num_vals; i++)
            {
                temp_int = d_file->next_value().toInt();
                data->general_comp_method(i)->setScale(temp_int);
            }
            for (i = 0; i < num_vals; i++)
            {
                temp_str = d_file->next_value();
                for (int j = 0; j < total_fleets; j++)
                    data->getFleet(j)->setGenMinTailComp(i, temp_str);
//                data->general_comp_method(i)->set_mincomp(temp_float);
            }
            for (i = 0; i < num_vals; i++)
            {
                temp_int = d_file->next_value().toInt();
                data->general_comp_method(i)->setNumberObs(temp_int);
            }
            for (i = 0; i < num_vals; i++)
            {
                compositionGeneral *cps = data->general_comp_method(i);
                str_lst.clear();
                for (int j = 0; j < cps->getNumberBins(); j++)
                {
                    str_lst.append(d_file->next_value());
                }
                cps->getBinsModel()->setRowData(0, str_lst);
            }
            for (i = 0; i < num_vals; i++)
            {
                compositionGeneral *cps = data->general_comp_method(i);
                obslength = data->getFleet(0)->getGenObsLength(i) + 1;
                num_input_lines = cps->getNumberObs();
                for (int j = 0; j < num_input_lines; j++)
                {
                    str_lst.clear();
                    for (int k = 0; k < obslength; k++)
                    {
                        str_lst.append(d_file->next_value());
                    }
                    temp_int = str_lst.at(0).toInt();
                    fleet = abs(str_lst.takeAt(3).toInt());
                    season = abs(str_lst.takeAt(2).toInt());
                    month = data->getMonthBySeasonFleet(season, (fleet - 1));
                    str_lst.insert(2, QString::number(month));
                    data->getFleet(fleet-1)->addGenObservation(temp_int-1, str_lst);
                    cps = data->general_comp_method(temp_int-1);
                }
            }
        }

        // tag-recapture data
        temp_int = d_file->next_value().toInt();
        data->set_do_tags(temp_int == 1);
        if (data->get_do_tags())
        {
            temp_int = d_file->next_value().toInt();
            data->set_num_tag_groups(temp_int);
            num_input_lines = d_file->next_value().toInt();
            temp_int = d_file->next_value().toInt();
            data->set_tag_latency(temp_int);
            temp_int = d_file->next_value().toInt();
            data->set_tag_max_periods(temp_int);
            // release data
            for (i = 0; i < data->get_num_tag_groups(); i++)
            {
                str_lst.clear();
                for (int j = 0; j < 8; j++)
                    str_lst.append(d_file->next_value());
                data->set_tag_observation(i, str_lst);
            }
            // recapture data
            for (i = 0; i < num_input_lines; i++)
            {
                str_lst.clear();
                for (int j = 0; j < 5; j++)
                    str_lst.append(d_file->next_value());
                temp_int = abs(str_lst.at(3).toInt());
                data->getFleet(temp_int - 1)->addRecapObservation(str_lst);
            }
        }

        // stock composition data
        temp_int = d_file->next_value().toInt();
        data->set_do_morph_comp(temp_int == 1);
        if (data->get_do_morph_comp())
        {
            compositionMorph *mcps = new compositionMorph();
            data->set_morph_composition (mcps);
            num_input_lines = d_file->next_value().toInt();
            mcps->setNumberObs(num_input_lines);
            temp_int = d_file->next_value().toInt();
//            mcps->set_number_morphs(temp_int);
            for (int j = 0; j < data->num_fleets(); j++)
                data->getFleet(j)->setMorphNumMorphs(temp_int);
            temp_str = d_file->next_value();
            for (i = 0; i < total_fleets; i++)
                data->getFleet(i)->setMorphMinTailComp(temp_str);
//            mcps->set_mincomp(temp_float);
            obslength = data->getFleet(0)->getMorphObsLength();// getmormcps->get_obs_length();
            for (i = 0; i < num_input_lines; i++)
            {
                str_lst.clear();
                for (int j = 0; j < obslength; j++)
                {
                    str_lst.append(d_file->next_value());
                }
                temp_int = abs(str_lst.at(2).toInt());
                data->getFleet(temp_int - 1)->addMorphObservation(str_lst);
            }
        }

        temp_int = d_file->next_value().toInt();
        if (temp_int != END_OF_DATA)
        {
            d_file->error(QString("Found incorrect end of data marker."));
        }

        d_file->close();
        return (1);
    }
    else
    {
        d_file->error(QString("File is unreadable."));
    }
    return (0);
}

int write32_dataFile(ss_file *d_file, ss_model *data)
{
    bool read_seasons = true;
    QString temp_str, line;
    QStringList str_lst;
    int i, chars = 0;
    int num_years = 1 + data->end_year() - data->start_year();
    int year, season;
    int temp_int = 0, num, num_lines;
    float temp_float = 0.0;
    int totalFleets = data->getNumActiveFleets();


    if(d_file->open(QIODevice::WriteOnly))
    {
        chars += write_version_comment(d_file);
        chars += d_file->write_comments();

        line = QString (QString ("#_observed data:"));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_styr" ).arg
                        (QString::number(data->start_year())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_endyr" ).arg
                        (QString::number(data->end_year())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_N_seasons" ).arg
                        (QString::number(data->num_seasons())));
        chars += d_file->writeline (line);

        line.clear();
        for (i = 0; i < data->num_seasons(); i++)
            line.append (QString(" %1").arg
                         (QString::number(data->months_per_season(i))));
        line.append (" #_N_months/season" );
        chars += d_file->writeline (line);

        line = QString (QString ("%1 #_spawn_season" ).arg
                            (QString::number(data->spawn_season())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_N_fleets" ).arg
                        (QString::number(data->num_fisheries())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_N_surveys" ).arg
                        (QString::number(data->num_surveys())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_N_areas" ).arg
                        (QString::number(data->num_areas())));
        chars += d_file->writeline (line);

        line.clear();
        for (i = 0; i < data->num_fleets(); i++)
            line.append(QString("%1%").arg(data->getFleet(i)->get_name()));
        line.chop(1);
        chars += d_file->writeline (line);

        line.clear();
        for (i = 0; i < data->num_fleets(); i++)
            line.append(QString(" %1").arg
                        (QString::number(data->getFleet(i)->timing())));
        line.append(" #_surveytiming_in_season" );
        chars += d_file->writeline (line);

        line.clear();
        for (i = 0; i < data->num_fleets(); i++)
            line.append(QString(" %1").arg
                        (QString::number(data->getFleet(i)->area())));
        line.append(" #_area_assignments_for_each_fishery_and_survey" );
        chars += d_file->writeline (line);

        line.clear();
        for (i = 0; i < data->num_fisheries(); i++)
            line.append(QString(" %1").arg
                        (QString::number(data->getFleet(i)->catch_units())));
        line.append(" #_units of catch: 1=bio; 2=num" );
        chars += d_file->writeline (line);

        line.clear();
        for (i = 0; i < data->num_fisheries(); i++)
            line.append(QString(" %1").arg
                        (QString::number(data->getFleet(i)->catch_se())));
        line.append(" #_se of log(catch) only used for init_eq_catch and for Fmethod 2 and 3; use -1 for discard only fleets" );
        chars += d_file->writeline (line);

        line = QString (QString ("%1 #_N_genders" ).arg
                        (QString::number(data->num_genders())));
        chars += d_file->writeline (line);

        line = QString (QString ("%1 #_N_ages" ).arg
                        (QString::number(data->num_ages())));
        chars += d_file->writeline (line);

        line.clear();
        for (i = 0; i < data->num_fisheries(); i++)
            line.append(QString(" %1").arg
                        (QString::number(data->getFleet(i)->catch_equil())));
        line.append(" #_init_equil_catch_for_each_fishery" );
        chars += d_file->writeline (line);

        num_lines = data->getFleet(0)->getNumCatchObs();
        line = QString (QString ("%1 #_N_lines_of_catch_to_read" ).arg
                        (QString::number(num_lines)));
        chars += d_file->writeline (line);

        line = QString("#_catch_biomass_(mtons):_columns_are_fisheries,year,season" );
        chars += d_file->writeline (line);
//        num_lines = data->getFleet(0)->getCatchModel()->rowCount();
        for (i = 0; i <= num_lines; i++)
        {
            QString yr, ss;
            {
                line.clear();
                for (int k = 0; k < data->num_fisheries(); k++)
                {
                    temp_str = data->getFleet(k)->getCatchObservation(i).at(2);
                    line.append(QString(" %1").arg (temp_str));
                }
                yr = data->getFleet(0)->getCatchObservation(i).at(0);
                ss = data->getFleet(0)->getCatchObservation(i).at(1);
                line.append(QString(" %1 %2" ).arg (yr, ss));
                chars += d_file->writeline (line);
            }
        }
        d_file->newline();



        // Abundance
        temp_int = 0;
        for (i = data->num_fisheries(); i < data->num_fleets(); i++)
            temp_int += data->getFleet(i)->abundance_count();

        line = QString(QString ("#\n%1 #_N_cpue_and_surveyabundance_observations" ).arg(
                          QString::number(temp_int)));
        chars += d_file->writeline(line);
        line = QString ("#_Units:  0=numbers; 1=biomass; 2=F" );
        chars += d_file->writeline(line);
        line = QString ("#_Errtype:  -1=normal; 0=lognormal; >0=T" );
        chars += d_file->writeline(line);
        line = QString ("#_Fleet Units Errtype" );
        chars += d_file->writeline(line);
        for (i = 0; i < data->num_fleets(); i++)
        {
            line = QString(QString("%1 %2 %3 # %4" ).arg (
                   QString::number(i+1),
                   QString::number(data->getFleet(i)->units()),
                   QString::number(data->getFleet(i)->error_type()),
                   data->getFleet(i)->get_name()));
            chars += d_file->writeline (line);
        }

        line = QString("#_year seas fleet obs stderr" );
        chars += d_file->writeline (line);
        for (i = data->num_fisheries();i < data->num_fleets(); i++)
        {
            int num_lines = data->getFleet(i)->getAbundanceCount();
            for (int j = 0; j < num_lines; j++)
            {
                QString month;
                QStringList abund (data->getFleet(i)->getAbundanceObs(j));
                if (!abund.at(0).isEmpty())
                {
                    if (abund.at(1).isEmpty())
                        abund[1].append("1");
                    else
                    {
                        if (read_seasons)
                        {
                            float mn = abund.at(1).toFloat();
                            month = QString::number(data->getSeasonByMonth(mn));
                        }
                        else
                        {
                            month = abund.at(1);
                        }
                    }
                    if (abund.at(2).isEmpty()) abund[2].append("0");
                    if (abund.at(3).isEmpty()) abund[3].append("0");
                    line = QString (QString(" %1 %2 %3 %4 %5 # %6" ).arg (
                                        abund.at(0), month,
                                        QString::number(i + 1),
                                        abund.at(2), abund.at(3),
                                        data->getFleet(i)->get_name()));
                    chars += d_file->writeline (line);
                }
            }

        }
        d_file->newline();

        // discard
        temp_int = data->fleet_discard_count();
        line = QString (QString ("%1 #_N_fleets_with_discard" ).arg (temp_int));
        chars += d_file->writeline (line);
        line = QString("#_discard_units (1=same_as_catchunits(bio/num); 2=fraction; 3=numbers)" );
        chars += d_file->writeline (line);
        line = QString("#_discard_errtype:  >0 for DF of T-dist(read CV below); 0 for normal with CV; -1 for normal with se; -2 for lognormal" );
        chars += d_file->writeline (line);
        line = QString("#Fleet Disc_units err_type" );
        chars += d_file->writeline (line);
        for (i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->getDiscardCount() > 0)
            {
                line = QString(QString("%1 %2 %3" ).arg(
                            QString::number(i+1),
                            QString::number(data->getFleet(i)->discard_units()),
                            QString::number(data->getFleet(i)->discard_err_type())));
                chars += d_file->writeline (line);
            }
        }

        temp_int = data->fleet_discard_obs_count();
        line = QString(QString("%1 #N discard obs" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        line = QString("#_year seas fleet obs stderr" );
        chars += d_file->writeline (line);
        for (i = 0; i < data->num_fleets(); i++)
        {
            for (int j = 0; j < data->getFleet(i)->getDiscardCount(); j++)
            {
                line.clear();
                str_lst = data->getFleet(i)->getDiscard(j);
                season = data->getSeasonByMonth(str_lst.takeAt(1).toFloat());
                str_lst.insert(1, QString::number(season));
                str_lst.insert(2, QString::number(i));
                for (int m = 0; m < str_lst.count(); m++)
                    line.append(QString(" %1").arg(str_lst.at(m)));
                chars += d_file->writeline (line);
            }
        }


        //line = QString("\n#" );
        chars += d_file->writeline ("#" );//line);

        // mean body weight
        temp_int = 0;
        for (i = 0; i < data->num_fleets(); i++)
            temp_int += data->getFleet(i)->getMbwtNumObs();
        line = QString (QString("%1 #_N_meanbodywt_obs" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        temp_int = data->getFleet(0)->getMbwtDF();
        line = QString (QString("%1 #_DF_for_meanbodywt_T-distribution_like" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        line = QString ("#_year seas type part obs cv" );
        chars += d_file->writeline (line);
        for (i = 0; i < data->num_fleets(); i++)
        {
            num = data->getFleet(i)->getMbwtNumObs();
            for (int j = 0; j < num; j++)
            {
                line.clear();
                str_lst = data->getFleet(i)->getMbwtObservation(j);
                season = data->getSeasonByMonth(str_lst.takeAt(1).toFloat());
                str_lst.insert(1, QString::number(season));
                str_lst.insert(2, QString::number(i));
                for (int m = 0; m < str_lst.count(); m++)
                    line.append(QString(" %1").arg(str_lst.at(m)));
                line.append('\n');
                chars += d_file->writeline (line);
            }
        }
        line = QString("" );
        chars += d_file->writeline (line);

        // length composition
        {
        compositionLength *l_data = data->get_length_composition();
        temp_int = l_data->getAltBinMethod();
        line = QString (QString("%1 # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector " ).arg(
                            QString::number(temp_int)));
        chars += d_file->writeline (line);
        switch (temp_int)
        {
        case 1:
            line = QString("#_COND_1 no additional data." );
            chars += d_file->writeline (line);
            break;
        case 2:
            line = QString("%1 # binwidth for population size comp" ).arg(QString::number(l_data->getAltBinWidth()));
            chars += d_file->writeline (line);
            line = QString("%1 # minimum size in the population (lower edge of first bin and size at age 0.00)" ).arg(
                        QString::number(l_data->getAltBinMin()));
            chars += d_file->writeline (line);
            line = QString("%1 # maximum size in the population (lower edge of last bin)" ).arg(
                        QString::number(l_data->getAltBinMax()));
            chars += d_file->writeline (line);
            break;
        case 3:
            str_lst = l_data->getAltBins();
            line = QString("%1 # number of population bins to be read" ).arg(
                        QString::number(str_lst.count()));
            chars += d_file->writeline (line);
            line.clear();
            for (int j = 0; j < str_lst.count(); j++)
                line.append(QString(" %1").arg(str_lst.at(j)));
            line.append('\n');
            chars += d_file->writeline (line);
            break;
        }

        line = QString("%1 #_comp_tail_compression" ).arg(data->getFleet(0)->getLengthMinTailComp());
        chars += d_file->writeline (line);
        line = QString("%1 #_add_to_comp" ).arg(data->getFleet(0)->getLengthAddToData());
        chars += d_file->writeline (line);
        line = QString("%1 #_combine males into females at or below this bin number" ).arg(
                    QString::number(data->getFleet(0)->getLengthCombineGen()));
        chars += d_file->writeline (line);
        temp_int = l_data->getNumberBins();
        line = QString("%1 #_N_LengthBins" ).arg(
                    QString::number(temp_int));
        chars += d_file->writeline (line);
        line.clear();
        str_lst = l_data->getBinsModel()->getRowData(0);
        for (i = 0; i < str_lst.count(); i++)
            line.append(QString (" %1").arg (str_lst.at(i)));
        line.append('\n');
        chars += d_file->writeline (line);

        temp_int = 0;
        for (i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->isActive())
            {
                temp_int += data->getFleet(i)->getLengthNumObs();
            }
        }
        line = QString ("%1 #_N_Length_obs" ).arg(QString::number(temp_int));
        chars += d_file->writeline (line);
        line = QString ("#Yr Seas Flt/Svy Gender Part Nsamp datavector(female-male)" );
        chars += d_file->writeline (line);
        for (int type = Fleet::Fishing; type < Fleet::None; type++)
        for (i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->isActive() &&
                    data->getFleet(i)->getType() == (Fleet::FleetType)type)
            {
                temp_int = data->getFleet(i)->getLengthNumObs();
                for( int j = 0; j < temp_int; j++)
                {
                    str_lst = data->getFleet(i)->getLengthObservation(j);
                    season = data->getSeasonByMonth(str_lst.takeAt(1).toFloat());
                    str_lst.insert(1, QString::number(season));
                    str_lst.insert(2, QString::number(i+1));
                    line.clear();
                    for (int j = 0; j < str_lst.count(); j++)
                        line.append(QString (" %1").arg(str_lst.at(j)));
                    line.append('\n');
                    chars += d_file->writeline (line);
                }
            }
        }

        d_file->newline();
        }


        // age composition
        {
        compositionAge *a_data = data->get_age_composition();
        temp_int = a_data->getNumberBins();
        line = QString(QString("%1 #_N_age_bins" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        line.clear();
        str_lst = a_data->getBinsModel()->getRowData(0);
        for (i = 0; i < str_lst.count(); i++)
        {
            line.append(QString(" %1").arg(str_lst.at(i)));
        }
        line.append('\n');
        chars += d_file->writeline (line);
        temp_int = a_data->number_error_defs();
        line = QString(QString("%1 #_N_ageerror_definitions" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        for (i = 0; i < temp_int; i++)
        {
            line.clear();
            str_lst = a_data->get_error_ages(i);
            for (int j = 0; j < str_lst.count(); j++)
                line.append(QString(" %1").arg(str_lst.at(j)));
            line.append('\n');
            chars += d_file->writeline (line);
            line.clear();
            str_lst = a_data->get_error_def(i);
            for (int j = 0; j < str_lst.count(); j++)
                line.append(QString(" %1").arg(str_lst.at(j)));
            line.append('\n');
            chars += d_file->writeline (line);
//            write_error_vector(a_data->error_def(i));
        }
        temp_int = 0;
        for (i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->isActive())
            {
                temp_int += data->getFleet(i)->getAgeNumObs();
            }
        }
        line = QString ("%1 #_N_Agecomp_obs" ).arg(QString::number(temp_int));
        chars += d_file->writeline (line);

        temp_int = a_data->getAltBinMethod();
        line = QString(QString("%1 #_Lbin_method: 1=poplenbins; 2=datalenbins; 3=lengths" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        temp_int = data->getFleet(0)->getAgeCombineGen();//a_data->combine_genders();
        line = QString(QString("%1 #_combine males into females at or below this bin number" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        line = QString ("#Yr Seas Flt/Svy Gender Part Ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)" );
        chars += d_file->writeline (line);
        for (int type = Fleet::Fishing; type < Fleet::None; type++)
        for (i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->isActive() &&
                    data->getFleet(i)->getType() == (Fleet::FleetType)type)
            {
                temp_int = data->getFleet(i)->getAgeNumObs();
                for( int j = 0; j < temp_int; j++)
                {
                    str_lst = data->getFleet(i)->getAgeObservation(j);
                    season = data->getSeasonByMonth(str_lst.takeAt(1).toFloat());
                    str_lst.insert(1, QString::number(season));
                    str_lst.insert(2, QString::number(i+1));
                    line.clear();
                    for (int j = 0; j < str_lst.count(); j++)
                        line.append(QString (" %1").arg(str_lst.at(j)));
                    line.append('\n');
                    chars += d_file->writeline (line);
                }
            }
        }

        d_file->newline();

        // mean size at age
        num = 0;
        for (i =0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->isActive())
                num += data->getFleet(i)->getSaaModel()->rowCount();
        }
        line = QString ("%1 #_N_MeanSize-at-Age_obs" ).arg (
                    QString::number(num));
        chars += d_file->writeline (line);
        line = QString ("#Yr Seas Flt/Svy Gender Part Ageerr Ignore datavector(female-male)" );
        line.append    ("#                                          samplesize(female-male)" );
        chars += d_file->writeline (line);
        for (i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->isActive())
            {
                for (int j = 0; j < data->getFleet(i)->getSaaNumObs(); j++)
                {
                    line.clear();
                    str_lst = data->getFleet(i)->getSaaModel()->getRowData(j);
                    season = data->getSeasonByMonth(str_lst.takeAt(1).toFloat());
                    str_lst.insert(1, QString::number(season));
                    str_lst.insert(2, QString::number(i+1));
                    for (int m = 0; m < str_lst.count(); m++)
                        line.append(QString(" %1").arg(str_lst.at(m)));
                    line.append('\n');
                    chars += d_file->writeline (line);
                }
            }
        }
        d_file->newline();
        }


        // environment observations
        line = QString (QString("%1 #_N_environ_variables" ).arg(
                            QString::number(data->num_environ_vars())));
        chars += d_file->writeline (line);
        temp_int = data->num_environ_var_obs();
        line = QString (QString("%1 #_N_environ_observations" ).arg(
                            QString::number(temp_int)));
        chars += d_file->writeline (line);
        if(temp_int > 0)
        {
            line = QString ("#_year Variable value" );
            chars += d_file->writeline (line);
            for (i = 0; i < temp_int; i++)
            {
                line.clear();
                str_lst = data->get_environ_var_obs(i);
                for (int j = 0; j < str_lst.count(); j++)
                    line.append(QString(" %1").arg(str_lst.at(j)));
                chars += d_file->writeline (line);
            }
        }
        d_file->newline();

        // general composition methods
        num = data->num_general_comp_methods();
        line = QString (QString("%1 #_N_general_comp_methods_to_read" ).arg(
                            QString::number(num)));
        chars += d_file->writeline (line);
        if (num > 0)
        {
            line.clear();
            for (i = 0; i < num; i++)
            {
                temp_str = QString::number(data->general_comp_method(i)->getNumberBins());
                line.append(QString(" %1").arg(temp_str));
            }
            line.append(" #_nbins_per_method" );
            chars += d_file->writeline (line);
            line.clear();
            for (i = 0; i < num; i++)
            {
                temp_str = QString::number(data->general_comp_method(i)->getUnits());
                line.append(QString(" %1").arg(temp_str));
            }
            line.append(" #_units_per_each_method (1=biomass, 2=numbers)" );
            chars += d_file->writeline (line);
            line.clear();
            for (i = 0; i < num; i++)
            {
                temp_str = QString::number(data->general_comp_method(i)->getScale());
                line.append(QString(" %1").arg(temp_str));
            }
            line.append(" #_scale_per_each_method (1=kg, 2=lbs, 3=cm, 4=in)" );
            chars += d_file->writeline (line);
            line.clear();
            for (i = 0; i < num; i++)
            {
                line.append(QString(" %1").arg(data->getFleet(0)->getGenMinTailComp(i)));
            }
            line.append(" #_mincomp_to_add_to_each_obs (entry for each method)" );
            chars += d_file->writeline (line);
            line.clear();
            for (i = 0; i < num; i++)
            {
                temp_int = 0;
                for (int j = 0; j < data->num_fleets(); j++)
                {
                    if (data->getFleet(j)->isActive())
                    {
                        temp_int += data->getFleet(j)->getGenNumObs(i);
                    }
                }
                line.append(QString(" %1").arg(QString::number(temp_int)));
            }
            line.append(" #_N_observations (entry for each method)" );
            chars += d_file->writeline (line);
            line = QString("#_lower edge of bins for each method" );
            chars += d_file->writeline (line);
            for (i = 0; i < num; i++)
            {
                line.clear();
                str_lst = data->general_comp_method(i)->getBinsModel()->getRowData(0);
                for (int j = 0; j < str_lst.count(); j++)
                    line.append(QString (" %1").arg (str_lst.at(j)));
                line.append('\n');
                chars += d_file->writeline (line);
            }
            line = QString ("#Method Yr Seas Flt Gender Part Nsamp datavector(female-male)" );
            chars += d_file->writeline (line);
            for (i = 0; i < num; i++)
            {
                for (int j = 0; j < data->num_fleets(); j++)
                {
                    if (data->getFleet(j)->isActive())
                    {
                        num_lines = data->getFleet(j)->getGenNumObs(i);
                        for (int k = 0; k < num_lines; k++)
                        {
                            line.clear();
                            str_lst = data->getFleet(j)->getGenObservation(i, k);
                            season = data->getSeasonByMonth(str_lst.takeAt(2).toFloat());
                            str_lst.insert(2, QString::number(season));
                            str_lst.insert(3, QString::number(j+1));
                            for (int m = 0; m < str_lst.count(); m++)
                                line.append(QString (" %1").arg(str_lst.at(m)));
                            line.append('\n');
                            chars += d_file->writeline (line);
                        }
                    }
                }
            }
        }
        d_file->newline();

        // tag recapture
        if (data->get_do_tags())
        {
            line = QString (QString("%1 # Do_tags" ).arg(QString("1")));
            chars += d_file->writeline (line);
            num = data->get_num_tag_groups();
            line = QString (QString("%1 # N_tag_groups" ).arg(QString::number(num)));
            chars += d_file->writeline (line);
            temp_int = 0;
            for (i = 0; i < data->num_fleets(); i++)
            {
                if (data->getFleet(i)->isActive())
                    temp_int += data->getFleet(i)->getRecapNumEvents();
            }
            line = QString (QString("%1 # N_recapture_events" ).arg(QString::number(temp_int)));
            chars += d_file->writeline (line);
            temp_int = data->get_tag_latency();
            line = QString (QString("%1 # Mixing_latency_period" ).arg(QString::number(temp_int)));
            chars += d_file->writeline (line);
            temp_int = data->get_tag_max_periods();
            line = QString (QString("%1 # Max_periods" ).arg(QString::number(temp_int)));
            chars += d_file->writeline (line);
            line = QString (QString("#Release_Data\n#TG area yr season <tfill> gender age Nrelease" ));
            chars += d_file->writeline (line);
            for (i = 0; i < num; i++)
            {
                line.clear();
                str_lst = data->get_tag_observation(i);
                for (int j = 0; j < str_lst.count(); j++)
                    line.append(QString(" %1").arg(str_lst.at(j)));
                chars += d_file->writeline (line);
            }
            line = QString("#Recapture_Data\n#TG year seas fleet Number" );
            chars += d_file->writeline (line);
            for (i = 0; i < num; i++)
            {
                for (int j = 0; j < data->num_fleets(); j++)
                {
                    if (data->getFleet(j)->isActive())
                    {
                        num_lines = data->getFleet(j)->getRecapNumEvents();
                        for (int k = 0; k < num_lines; k++)
                        {
                            line.clear();
                            str_lst = data->getFleet(j)->getRecapObservation(k);
                            if (str_lst.at(0).toInt() == i)
                            {
                            for (int m = 0; m < str_lst.count(); m++)
                                line.append(QString(" %1").arg(str_lst.at(m)));
                            chars += d_file->writeline (line);
                            }
                        }
                    }
                }
            }
        }
        else
        {
            line = QString (QString("%1 # no tag data" ).arg(QString("0")));
            chars += d_file->writeline (line);
        }
        d_file->newline();

        // morph composition
        if (data->get_do_morph_comp())
        {
            line = QString (QString("%1 # Do_morphcomp" ).arg(QString("1")));
            chars += d_file->writeline (line);
            num_lines = 0;
            for (i = 0; i < data->num_fleets(); i++)
                num_lines += data->getFleet(i)->getMorphNumObs();
            line = QString (QString("%1 # N_observations" ).arg(QString::number(num_lines)));
            chars += d_file->writeline (line);
            temp_int = data->get_morph_composition()->getNumberMorphs();
            line = QString (QString("%1 # N_morphs" ).arg(QString::number(temp_int)));
            chars += d_file->writeline (line);
//            temp_float = data->getFleet(0)->getMorphMinTailComp();// get_morph_composition()->mincomp();
            line = QString (QString("%1 # Mincomp" ).arg(data->getFleet(0)->getMorphMinTailComp()));
            chars += d_file->writeline (line);
            temp_int = data->get_tag_latency();
            line = QString("#Year seas fleet partition Nsamp data_vector" );
            chars += d_file->writeline (line);
            for (num = 0; num < data->num_fleets(); num++)
            {
                if (data->fleets.at(num)->isActive())
                {
                    num_lines = data->getFleet(num)->getMorphNumObs();
                    for (int j = 0; j < num_lines; j++)
                    {
                        line.clear();
                        str_lst = data->getFleet(num)->getMorphObservation(j);
                        season = data->getSeasonByMonth(str_lst.takeAt(1).toFloat());
                        str_lst.insert(1, QString::number(season));
                        str_lst.insert(2, QString::number(i+1));
                        for (int k = 0; k < str_lst.count(); k++)
                            line.append(QString(" %1").arg(str_lst.at(k)));
                        chars += d_file->writeline (line);
                    }
                }
            }
        }
        else
        {
            line = QString (QString("%1 # no morph comp data" ).arg(QString::number(0)));
            chars += d_file->writeline (line);
        }
        d_file->newline();

        //end of data
        line = QString (QString("%1" ).arg (QString::number(END_OF_DATA)));
        chars += d_file->writeline (line);
        d_file->newline();

        d_file->close();
    }
}

bool read32_forecastFile(ss_file *f_file, ss_model *data)
{
    QString token;
    QString temp_str;
    QStringList str_lst(" ");
    float temp_float;
    int temp_int = 0;
    int i;

    if(f_file->open(QIODevice::ReadOnly))
    {
        ss_forecast *fcast = data->forecast;
        f_file->read_comments();

        token = f_file->next_value("benchmarks type");
        temp_int = token.toInt();
        fcast->set_benchmarks(temp_int);

        token = f_file->next_value("MSY");
        temp_int = token.toInt();
        fcast->set_MSY(temp_int);

        token = f_file->next_value("SPR target");
        temp_float = token.toFloat();
        fcast->set_spr_target(temp_float);

        token = f_file->next_value("biomass target");
        temp_float = token.toFloat();
        fcast->set_biomass_target(temp_float);

        for (i = 0; i < 6; i++)
        {
            token = f_file->next_value("benchmark year");
            temp_int = token.toInt();
            fcast->set_benchmark_years(i, temp_int);
        }

        token = f_file->next_value("rel f basis");
        temp_int = token.toInt();
        fcast->set_benchmark_rel_f(temp_int);
        token = f_file->next_value("forecast type");
        temp_int = token.toInt();
        fcast->set_forecast(temp_int);
        token = f_file->next_value("number of forecast years");
        temp_int = token.toInt();
        fcast->set_num_forecast_years(temp_int);
        token = f_file->next_value("F scalar");
        temp_float = token.toFloat();
        fcast->set_f_scalar(temp_float);
        for (i = 0; i < 4; i++)
        {
            token = f_file->next_value("forecast year");
            temp_int = token.toInt();
            fcast->set_forecast_year(i, temp_int);
        }

        token = f_file->next_value("control rule method");
        temp_int = token.toInt();
        fcast->set_cr_method(temp_int);
        token = f_file->next_value("control rule biomass const f");
        temp_float = token.toFloat();
        fcast->set_cr_biomass_const_f(temp_float);
        token = f_file->next_value("control rule biomass no f");
        temp_float = token.toFloat();
        fcast->set_cr_biomass_no_f(temp_float);
        token = f_file->next_value("control rule target");
        temp_float = token.toFloat();
        fcast->set_cr_target(temp_float);

        token = f_file->next_value("number of loops");
        temp_int = token.toInt();
        fcast->set_num_forecast_loops(temp_int);
        token = f_file->next_value("loop with recruitment");
        temp_int = token.toInt();
        fcast->set_forecast_loop_recruitment(temp_int);
        token = f_file->next_value("loop control 3");
        temp_int = token.toInt();
        fcast->set_forecast_loop_ctl3(temp_int);
        token = f_file->next_value("loop control 4");
        temp_int = token.toInt();
        fcast->set_forecast_loop_ctl4(temp_int);
        token = f_file->next_value("loop control 5");
        temp_int = token.toInt();
        fcast->set_forecast_loop_ctl5(temp_int);

        token = f_file->next_value("caps and allocs first yr");
        temp_int = token.toInt();
        fcast->set_caps_alloc_st_year(temp_int);

        token = f_file->next_value("std dev log(catch/tgt)");
        temp_float = token.toFloat();
        fcast->set_log_catch_std_dev(temp_float);
        token = f_file->next_value("West Coast rebuilder");
        temp_int = token.toInt();
        fcast->set_rebuilder(temp_int == 1? true: false);
        token = f_file->next_value("rebuilder: first year");
        temp_int = token.toInt();
        fcast->set_rebuilder_first_year(temp_int);
        token = f_file->next_value("rebuilder: curr year");
        temp_int = token.toInt();
        fcast->set_rebuilder_curr_year(temp_int);

        token = f_file->next_value("fleet relative F");
        temp_int = token.toInt();
        fcast->set_fleet_rel_f(temp_int);

        token = f_file->next_value("catch tuning basis");
        temp_int = token.toInt();
        fcast->set_catch_tuning_basis(temp_int);

        if (fcast->fleet_rel_f() == 2)
        {
            for (int s = 0; s < fcast->num_seasons(); s++)
            {
                for (i = 0; i < fcast->num_fleets(); i++)
                {
                    temp_float = f_file->next_value().toFloat();
                    fcast->set_seas_fleet_rel_f(s, i, temp_float);
                }
            }
        }

        for (i = 0; i < fcast->num_fleets(); i++)
        {
            token = f_file->next_value("max catch by fleet");
            temp_int = token.toInt();
            fcast->set_max_catch_fleet(i, temp_int);
            if (f_file->at_eol())
            {
                for (; i < fcast->num_fleets(); i++)
                    fcast->set_max_catch_fleet(i, temp_int);
            }
        }
/*        token = f_file->next_value("max catch by fleet");
        temp_int = token.toInt();
        fcast->set_max_catch_fleet(1, temp_int);
        i = 2;
        while (!f_file->at_eol())
        {
            token = f_file->next_value("max catch by fleet");
            temp_int = token.toInt();
            fcast->set_max_catch_fleet(i, temp_int);
            i++;
        }*/

        for (i = 0; i < fcast->num_areas(); i++)
        {
            token = f_file->next_value("max catch by area");
            temp_int = token.toInt();
            fcast->set_max_catch_area(i, temp_int);
            if (f_file->at_eol())
            {
                for (; i < fcast->num_areas(); i++)
                    fcast->set_max_catch_area(i, temp_int);
            }
        }

        for (i = 0; i < fcast->num_fleets(); i++)
        {
            token = f_file->next_value("alloc group assignment");
            temp_int = token.toInt();
            fcast->set_alloc_group(i, temp_int);
            if (f_file->at_eol())
            {
                for (; i < fcast->num_fleets(); i++)
                    fcast->set_alloc_group(i, temp_int);
            }
        }
/*        i = 2;
        while (!f_file->at_eol())
        {
            token = f_file->next_value("alloc group assignment");
            temp_int = token.toInt();
            fcast->set_alloc_group(i, temp_int);
            i++;
        }*/

        if (fcast->num_alloc_groups() > 1)
        {
        for (i = 0; i < fcast->num_alloc_groups(); i++)
        {
            token = f_file->next_value("alloc group fraction");
            str_lst.append(token);
            fcast->set_alloc_fractions(0, str_lst);
        }
        }

        token = f_file->next_value("number forecast catch levels");
        temp_int = token.toInt();
        fcast->set_num_catch_levels(temp_int);

        token = f_file->next_value("input catch basis");
        temp_int = token.toInt();
        fcast->set_input_catch_basis(temp_int);

        token = f_file->next_value();
        temp_int = token.toInt();
        if (temp_int != END_OF_DATA)
        {
            str_lst.clear();
            str_lst.append(token);                  // Year
            str_lst.append(f_file->next_value()); // Season
            str_lst.append(f_file->next_value()); // Fleet
            str_lst.append(f_file->next_value()); // Catch
            temp_int = str_lst.at(2).toInt();
            fcast->add_fixed_catch_value(str_lst);
//            data->getFleet(temp_int)->add_forecast_catch

            token = f_file->next_value();
            temp_int = token.toInt();
        }

        f_file->close();
    }
    else
    {
        f_file->error(QString("File is not readable."));
    }
    return 1;
}

int write32_forecastFile(ss_file *f_file, ss_model *data)
{
    int num, i, chars = 0;
    QString value, line, temp_string;
    QStringList str_lst;
    ss_forecast *fcast = data->forecast;


    if(f_file->open(QIODevice::WriteOnly))
    {
        chars += write_version_comment(f_file);
        chars += f_file->write_comments();

        line = QString("# for all year entries except rebuilder; enter either: actual year, -999 for styr, 0 for endyr, neg number for rel. endyr" );
        chars += f_file->writeline(line);

        value = QString::number(fcast->benchmarks());
        line = QString(QString ("%1 # Benchmarks: 0=skip; 1=calc F_spr, F_btgt, and F_msy " ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->MSY());
        line = QString(QString ("%1 # MSY: 1=set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt); 4=set to F(endyr) " ).arg (value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->spr_target());
        line = QString(QString("%1 # SPR target (e.g. 0.40) " ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->biomass_target());
        line = QString(QString("%1 # Biomass target (e.g. 0.40)" ).arg(value));
        chars += f_file->writeline(line);

        line = QString("#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF");
        temp_string = QString ("# ");
        line.append(QString("enter actual year, or values of 0 or -integer to be rel. endyr) " ));
        for (int i = 0; i < 6; i++)
        {
            value = QString::number(fcast->benchmark_year(i));
            line.append(QString(QString(" %1").arg(value)));
            if (fcast->benchmark_year(i) <= 0)
                temp_string.append(QString(" %1").arg(QString::number(data->end_year() + fcast->benchmark_year(i))));
            else
                temp_string.append(QString(" %1").arg(value));
        }
        chars += f_file->writeline(line);
        temp_string.append(" # after processing ");
        chars += f_file->writeline(temp_string);

        value = QString::number(fcast->benchmark_rel_f());
        line = QString(QString("%1 #_Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->forecast());
        line = QString(QString("%1 # Forecast: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (uses first-last relF yrs); 5=input annual F scalar" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->num_forecast_years());
        line = QString(QString("%1 # N forecast years" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->f_scalar());
        line = QString(QString("%1 # F scalar (only used for Do_Forecast==5)" ).arg(value));
        chars += f_file->writeline(line);

        line = QString("#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF  (enter actual year, or values of 0 or -integer to be rel. endyr)" );
        temp_string = QString("# ");
        for (int i = 0; i < 4; i++)
        {
            value = QString::number(fcast->forecast_year(i));
            line.append(QString(QString(" %1").arg(value)));
            if (fcast->forecast_year(i) <= 0)
                temp_string.append(QString(" %1").arg(QString::number(data->end_year() + fcast->forecast_year(i))));
            else
                temp_string.append(QString(" %1").arg(value));
        }
        chars += f_file->writeline(line);
        temp_string.append(" # after processing ");
        chars += f_file->writeline(temp_string);

        value = QString::number(fcast->cr_method());
        line = QString(QString("%1 # Control rule method (1=catch=f(SSB) west coast; 2=F=f(SSB) )" ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->cr_biomass_const_f());
        line = QString(QString("%1 # Control rule Biomass level for constant F (as frac of Bzero, e.g. 0.40); (Must be > the no F level below)" ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->cr_biomass_no_f());
        line = QString(QString("%1 # Control rule Biomass level for no F (as frac of Bzero, e.g. 0.40)" ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->cr_target());
        line = QString(QString("%1 # Control rule target as fraction of Flimit (e.g. 0.75)" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->num_forecast_loops());
        line = QString(QString("%1 #_N forecast loops (1=OFL only; 2=ABC; 3=get F from forecast ABC catch with allocations applied)" ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->forecast_loop_recruitment());
        line = QString(QString("%1 #_First forecast loop with stochastic recruitment" ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->forecast_loop_ctl3());
        line = QString(QString("%1 #_Forecast loop control #3 (reserved for future bells&whistles) " ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->forecast_loop_ctl4());
        line = QString(QString("%1 #_Forecast loop control #4 (reserved for future bells&whistles) " ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->forecast_loop_ctl5());
        line = QString(QString("%1 #_Forecast loop control #5 (reserved for future bells&whistles) " ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->caps_alloc_st_year());
        line = QString(QString("%1 # First Year for caps and allocations (should be after years with fixed inputs)" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->log_catch_std_dev());
        line = QString(QString("%1 # stddev of log (realized catch/target catch) in forecast (set value>0.0 to cause active impl_error)" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->rebuilder()? 1: 0);
        line = QString(QString("%1 # Do West Coast gfish rebuilder output (0/1)" ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->rebuilder_first_year());
        line = QString(QString("%1 # Rebuilder: first year catch could have been set to zero (Ydecl)(-1 to set to 1999)" ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->rebuilder_curr_year());
        line = QString(QString("%1 # Rebuilder: year for current age structure (Yinit) (-1 to set to endyear+1)" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->fleet_rel_f());
        line = QString(QString("%1 # fleet relative F: 1=use first-last alloc year; 2=read seas(row) x fleet(col) below" ).arg(value));
        chars += f_file->writeline(line);
        line = QString("# Note that fleet allocation is used directly as average F if Do_Forecast=4" );
        chars += f_file->writeline(line);

        value = QString::number(fcast->catch_tuning_basis());
        line = QString(QString("%1 # basis for fcast catch tuning and for fcast catch caps and allocation  (2=deadbio; 3=retainbio; 5=deadnum; 6=retainnum)" ).arg(value));
        chars += f_file->writeline(line);

        line = QString("# Conditional input if relative F choice = 2" );
        chars += f_file->writeline(line);
        line = QString("# Fleet relative F:  rows are seasons, columns are fleets" );
        chars += f_file->writeline(line);
        line = QString ("#_Fleet: ");
        temp_string = QString("# ");
            for (i = 0; i < data->num_fisheries(); i++)
            {
                line.append(QString(" %1").arg (data->getFleet(i)->get_name()));
                temp_string.append(" -1");
            }
        chars += f_file->writeline(line);
        chars += f_file->newline();
        chars += f_file->writeline(temp_string);
        chars += f_file->newline();
        line.clear();
        if (fcast->fleet_rel_f() == 2)
        {
            for (i = 0; i < fcast->num_seasons(); i++)
                for (int j = 0; j < fcast->num_fleets(); i++)
                    line.append(QString(" %1").arg(QString::number(0)));
        }
        chars += f_file->writeline(line);

        line = QString("# max totalcatch by fleet (-1 to have no max) must enter value for each fleet" );
        chars += f_file->writeline(line);
        line.clear();
            for (i = 0; i < fcast->num_fleets(); i++)
            {
                if(data->getFleet(i)->getType() != Fleet::Survey)
                {
                    value = QString::number(fcast->max_catch_fleet(i));
                    line.append(QString(" %1").arg(value));
                }
            }
        line.append('\n');
        chars += f_file->writeline(line);

        line = QString("# max totalcatch by area (-1 to have no max); must enter value for each area" );
        chars += f_file->writeline(line);
        line.clear();
        for (i = 0; i < fcast->num_areas(); i++)
        {
            value = QString::number(fcast->max_catch_area(i));
            line.append(QString(" %1").arg(value));
        }
        line.append('\n');
        chars += f_file->writeline(line);

        // allocation groups
        line = QString("# fleet assignment to allocation group (enter group ID# for each fleet, 0 for not included in an alloc group)" );
        chars += f_file->writeline(line);
        line.clear();
            for (i = 0; i < fcast->num_fleets(); i++)
            {
                if(data->getFleet(i)->getType() != Fleet::Survey)
                {
                    value = QString::number(fcast->alloc_group(i));
                    line.append(QString(" %1").arg(value));
                }
            }
        line.append('\n');
        chars += f_file->writeline(line);

        line = QString("#_Conditional on >1 allocation group" );
        chars += f_file->writeline(line);
        line.clear();
        if (fcast->num_alloc_groups() > 1)
        {
            str_lst = fcast->get_alloc_fractions(0);

            for (i = 0; i < str_lst.count(); i++)
            {
                line.append(QString(QString(" %1").arg(str_lst.at(i))));
            }
            line.append(QString(QString(" # allocation fraction for each of: %1 allocation groups" )).arg(
                            QString::number(i)));
        }
        else
        {
            line.append (QString(" # allocation fraction for each of: 0 allocation groups" ));
            line.append (QString ("# no allocation groups " ));
        }
        chars += f_file->writeline(line);

        num = fcast->num_catch_levels();
        value = QString::number(num);
        line = QString(QString("%1 # Number of forecast catch levels to input (else calc catch from forecast F)" ).arg(value));
        chars += f_file->writeline(line);
        value = QString::number(fcast->input_catch_basis());
        line = QString(QString("%1 # basis for input Fcast catch:  2=dead catch; 3=retained catch; 99=input Hrate(F) (units are from fleetunits; note new codes in SSV3.20)" ).arg(value));
        chars += f_file->writeline(line);
        line = QString("# Input fixed catch values" );
        chars += f_file->writeline(line);
        line = QString("#Year Seas Fleet Catch(or_F) Basis" );
        chars += f_file->writeline(line);
        num = fcast->num_catch_values();
        for (i = 0; i < num; i++)
        {
            QStringList obs = fcast->fixed_catch_value(i);
            line.clear();
            for (int j = 0; j < obs.count(); j++)
                line.append(QString(" %1").arg(obs.at(j)));
            line.append('\n');
            chars += f_file->writeline(line);
        }
        f_file->newline();
        f_file->writeline("#" );

        line = QString(QString("%1 # verify end of input " ).arg (
                           QString::number(END_OF_DATA)));
        chars += f_file->writeline(line);


        f_file->close();
    }
}

bool read32_controlFile(ss_file *c_file, ss_model *data)
{
    int i, temp_int, num, num_vals;
    float temp_float;
    QString temp_string;
    QStringList datalist;
    population * pop = data->pPopulation;
    int num_fleets = data->num_fleets();

    if(c_file->open(QIODevice::ReadOnly))
    {
        c_file->seek(0);
        c_file->read_comments();

        // growth patterns
        num = c_file->next_value().toInt();
        if (data->get_morph_composition() != NULL &&
                num != data->get_morph_composition()->getNumberMorphs())
            c_file->error(QString("Number of growth patterns doesn't match number of stocks."));
        pop->Grow()->setNum_patterns(num);
        // morphs or platoons
        num = c_file->next_value().toInt(); // only 1, 3, and 5 are allowed
        if (num > 4) num = 5;
        else if (num > 1) num = 3;
        else num = 1;
        pop->Grow()->setNum_morphs(num);
        pop->Grow()->setMorph_within_ratio(0.0);
        pop->Grow()->setMorph_dist(0, 1.0);
        if (num > 1)
        {
            temp_float = c_file->next_value().toFloat();
            pop->Grow()->setMorph_within_ratio (temp_float);
            temp_float = c_file->next_value().toFloat();
            if ((int)temp_float == -1)
            {
                if (num == 3)
                {
                    pop->Grow()->setMorph_dist(0, 0.15);
                    pop->Grow()->setMorph_dist(1, 0.70);
                    pop->Grow()->setMorph_dist(2, 0.15);
                }
                else if (num == 5)
                {
                    pop->Grow()->setMorph_dist(0, 0.031);
                    pop->Grow()->setMorph_dist(1, 0.237);
                    pop->Grow()->setMorph_dist(2, 0.464);
                    pop->Grow()->setMorph_dist(3, 0.237);
                    pop->Grow()->setMorph_dist(4, 0.031);
                }
            }
            else
            {
                pop->Grow()->setMorph_dist(0, temp_float);
                for (i = 1; i < num; i++)
                {
                    temp_float = c_file->next_value().toFloat();
                    pop->Grow()->setMorph_dist(i, temp_float);
                }
            }
        }

        pop->SR()->setDistribMethod(1);
        pop->SR()->setDistribArea(1);

        // recruitment designs
        num_vals = pop->Grow()->getNum_patterns() * data->num_seasons() * data->num_areas();
        if (num_vals > 1)
        {
            num = c_file->next_value().toInt();
            pop->SR()->setNumAssignments(num);
            temp_int = c_file->next_value().toInt();
            pop->SR()->setDoRecruitInteract(temp_int);
            for (i = 0; i < num; i++)
            {
                datalist.clear();
                for (int j = 0; j < 3; j++)
                    datalist.append(c_file->next_value());
                pop->SR()->setAssignment(i, datalist);
            }
        }
        else
        {
            datalist.clear();
            pop->SR()->setNumAssignments(1);
            datalist << "1" << "1" << "1";
            pop->SR()->setAssignment(0, datalist);
            pop->SR()->setDoRecruitInteract(false);
        }

        // movement definitions
        if (data->num_areas() > 1)
        {
            num = c_file->next_value().toInt();
            pop->Move()->setNumDefs(num);
            temp_float = c_file->next_value().toFloat();
            pop->Move()->setFirstAge(temp_float);
            for (i = 0; i < num; i++)
            {
                datalist.clear();
                for (int j = 0; j < 6; j++)
                    datalist.append(c_file->next_value());
                pop->Move()->setDefinition(i, datalist);
            }
        }
        else
        {
            pop->Move()->setNumDefs(0);
        }

        // time block definitions
        num = c_file->next_value().toInt();
        data->setNumBlockPatterns(num);
        if (num > 0)
        {
            for (i = 0; i < num; i++)
            {
                temp_int = c_file->next_value().toInt();
                data->getBlockPattern(i)->setNumBlocks(temp_int);
            }
            for (i = 0; i < num; i++)
            {
                for (int j = 0; j < data->getBlockPattern(i)->getNumBlocks(); j++)
                {
                    datalist.clear();
                    datalist.append(c_file->next_value());
                    datalist.append(c_file->next_value());
                    data->getBlockPattern(i)->setBlock(j, datalist);
                }
            }
        }

        // fraction female
        temp_float = c_file->next_value().toFloat();
        pop->set_frac_female(temp_float);

        // natural Mort
        temp_int = c_file->next_value().toInt();
        pop->Grow()->setNatural_mortality_type(temp_int);
        switch (temp_int)
        {
        default:
        case 0:
            num_vals = 1;  // 1 parameter per gender
            break;
        case 1:
            num_vals = c_file->next_value().toInt(); // num breakpoints
            pop->Grow()->setNatMortNumBreakPts(num_vals);
            num = pop->Grow()->getNatMortNumBreakPts();
            datalist.clear();
            for (int i = 0; i < num_vals; i++) // vector of breakpoints
                datalist.append(c_file->next_value());
            pop->Grow()->setNatMortBreakPts(datalist);
            break;
        case 2:
            temp_int = c_file->next_value().toInt(); // ref age for Lorenzen
            pop->Grow()->setNaturnalMortLorenzenRef(temp_int);
            num_vals = 2;
            break;
        case 3:
        case 4:
            // age-specific M values by sex by growth pattern
            num_vals = pop->Grow()->getNum_patterns();
            datalist.clear();
            for (int i = 0; i < 2; i++) // first female, then male
            {
                for (int j = 0; j < num; j++)
                {
                    datalist.append(c_file->next_value());
                }
            }
//            pop->Grow()->setNatMortNumAges(datalist.count());
            pop->Grow()->setNatMortAges(datalist);
            break;
        }
        for (i = 0; i < pop->Grow()->getNum_patterns(); i++)
        {
            pop->Grow()->getPattern(i)->setNumNatMParams(num_vals);
        }

        // growth model
        temp_int = c_file->next_value().toInt();
        pop->Grow()->setModel(temp_int);

        temp_float = c_file->next_value().toFloat();
        pop->Grow()->setAge_for_l1(temp_float);
        temp_float = c_file->next_value().toFloat();
        pop->Grow()->setAge_for_l2(temp_float);
        if (pop->Grow()->getModel() == 3)
        {
            temp_float = c_file->next_value().toFloat();
            pop->Grow()->setAgeMin_for_K(temp_float);
            temp_float = c_file->next_value().toFloat();
            pop->Grow()->setAgeMax_for_K(temp_float);
        }

        temp_float = c_file->next_value().toFloat();
        pop->Grow()->setSd_add(temp_float);

        temp_int = c_file->next_value().toInt();
        pop->Grow()->setCv_growth_pattern(temp_int);

        // maturity
        temp_int = c_file->next_value().toInt();
        pop->Grow()->setMaturity_option(temp_int);
        if (temp_int == 3 ||
            temp_int == 4)
        {
            datalist.clear();
            num = data->get_age_composition()->getNumber();
            for (i = 0; i <= num; i++)
                datalist.append(c_file->next_value());
            pop->Grow()->setNumMatAgeValues(datalist.count());
            pop->Grow()->setMatAgeVals(datalist);
        }
        else if (temp_int == 6)
        {
            datalist.clear();
            num = data->get_length_composition()->getNumberBins();
            for (i = 0; i < num; i++)
                datalist.append(c_file->next_value());
            pop->Grow()->setNumMatAgeValues(datalist.count());
            pop->Grow()->setMatAgeVals(datalist);
        }

        temp_float = c_file->next_value().toFloat();
        pop->Grow()->setFirst_mature_age(temp_float);

        // fecundity
        temp_int = c_file->next_value().toInt();
        pop->Fec()->setMethod(temp_int);

        temp_int = c_file->next_value().toInt();
        pop->Fec()->setHermaphroditism(temp_int == 1? true: false);
        if (temp_int == 1)
        {
            temp_float = c_file->next_value().toFloat();
            pop->Fec()->setHermSeason(temp_float);
            temp_int = c_file->next_value().toInt();
            pop->Fec()->setHermIncludeMales(temp_int);
        }

        temp_int = c_file->next_value().toInt();
        pop->Grow()->setParam_offset_method(temp_int);

        temp_int = c_file->next_value().toInt();
        pop->Grow()->setAdjustment_method(temp_int);

        // mortality growth parameters
        pop->Grow()->setNumMaturityParams(0);
        for (i = 0; i < pop->Grow()->getNum_patterns(); i++)
        {
            growthPattern *gp = pop->Grow()->getPattern(i);
            gp->setNumGrowthParams(0);
            gp->setNumCVParams(0);
                                              // Female parameters
            num = gp->getNumNatMParams();
            for (int j = 0; j < num; j++)
            {
                datalist = readParameter(c_file); // natMort
                gp->setNatMParam(j, datalist);
            }
            datalist = readParameter(c_file); // L at Amin
            gp->addGrowthParam(datalist);
            datalist = readParameter(c_file); // L at Amax
            gp->addGrowthParam(datalist);
            datalist = readParameter(c_file); // von Bertalanffy
            gp->addGrowthParam(datalist);
            if (pop->Grow()->getModel() == 2)
            {
                datalist = readParameter(c_file); // Richards coefficient
                gp->addGrowthParam(datalist);
            }
            if (pop->Grow()->getModel() == 3)
            {
                for (int k = 0; k < data->num_ages(); k++)
                {
                    datalist = readParameter(c_file); // K deviations per age
                    gp->addGrowthParam(datalist);
                }
            }
            datalist = readParameter(c_file); // CV young
            gp->addCVParam(datalist);
            datalist = readParameter(c_file); // CV old
            gp->addCVParam(datalist);
            if (data->num_genders() > 1)          // Male parameters
            {
                for (int j = 0; j < num; j++)
                {
                    datalist = readParameter(c_file); // natMort
                    gp->setNatMParam(j + num, datalist);
                }

                datalist = readParameter(c_file); // L at Amin
                gp->addGrowthParam(datalist);
                datalist = readParameter(c_file); // L at Amax
                gp->addGrowthParam(datalist);
                datalist = readParameter(c_file); // von Bertalanffy
                gp->addGrowthParam(datalist);
                if (pop->Grow()->getModel() == 2)
                {
                    datalist = readParameter(c_file); // Richards coefficient
                    gp->addGrowthParam(datalist);
                }
                if (pop->Grow()->getModel() == 3)
                {
                    for (int k = 0; k < data->num_ages(); k++)
                    {
                        datalist = readParameter(c_file); // K deviations per age
                        gp->addGrowthParam(datalist);
                    }
                }
                datalist = readParameter(c_file); // CV young
                gp->addCVParam(datalist);
                datalist = readParameter(c_file); // CV old
                gp->addCVParam(datalist);
            }
        }
        pop->Grow()->setNumMaturityParams(0);
        datalist = readParameter(c_file); // fem_wt_len_1
        pop->Grow()->addMaturityParam(datalist);
        datalist = readParameter(c_file); // fem_wt_len_2
        pop->Grow()->addMaturityParam(datalist);
        datalist = readParameter(c_file); // fem_mat_inflect
        pop->Grow()->addMaturityParam(datalist);
        datalist = readParameter(c_file); // fem_mat_slope
        pop->Grow()->addMaturityParam(datalist);
        datalist = readParameter(c_file); // fem_fec_alpha
        pop->Fec()->setFemaleParam(0, datalist);
        datalist = readParameter(c_file); // fem_fec_beta
        pop->Fec()->setFemaleParam(1, datalist);

        if (data->num_genders() > 1)
        {
            datalist = readParameter(c_file); // male_wt_len_1
            pop->Grow()->addMaturityParam(datalist);
            datalist = readParameter(c_file); // male_wt_len_2
            pop->Grow()->addMaturityParam(datalist);
        }

        if (pop->Fec()->getHermaphroditism() == 1)
        {
            for (i = 0; i < 3; i++)
            {
            datalist = readParameter(c_file); // hermaph_inflect, sd, asymptotic
            pop->Fec()->setHermParam(i, datalist);
            }
        }

        for (i = 0; i < pop->Grow()->getNum_patterns(); i++)
        {
            datalist = readParameter(c_file); // recr apportion main
            pop->SR()->setAssignmentParam(i, datalist);
        }
        for (num = 0; num < data->num_areas(); num++, i++)
        {
            datalist = readParameter(c_file); // recr apportion to areas
            pop->SR()->setAssignmentParam(i, datalist);
        }
        for (num = 0; num < data->num_seasons(); num++, i++)
        {
            datalist = readParameter(c_file); // recr apportion to seasons
            pop->SR()->setAssignmentParam(i, datalist);
        }
        if (pop->SR()->getDoRecruitInteract())
        {
            pop->SR()->setNumInteractParams(0);
            num = pop->Grow()->getNum_patterns() * data->num_areas() * data->num_seasons();
            for (i = 0; i < num; i++)
            {
                datalist = readParameter(c_file); // recr interaction
                pop->SR()->addInteractParam(datalist);
            }
        }
        datalist = readParameter(c_file); // cohort growth deviation
        pop->Grow()->setCohortParam(datalist);

        // movement parameters (2 per definition)
        num = pop->Move()->getNumDefs();
        for (i = 0; i < num; i++)
        {
            int par = i * 2;
            datalist = readParameter(c_file);    // parameter A
            pop->Move()->setParameter (par, datalist);
            datalist = readParameter(c_file);    // parameter B
            pop->Move()->setParameter (par + 1, datalist);
        }

        // ageing error if requested
        if (data->get_age_composition()->getUseParameters())
        {
            for (i = 0; i < 7; i++)
            {
                datalist = readParameter(c_file); // parameters for age error matrix
                data->get_age_composition()->setErrorParam(i, datalist);
            }
        }

        // seasonal_effects_on_biology_parms
        temp_int = c_file->next_value().toInt();
        pop->setFemwtlen1(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setFemwtlen2(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setMat1(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setMat2(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setFec1(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setFec2(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setMalewtlen1(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setMalewtlen1(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setL1(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->setK(temp_int);
        pop->setNumSeasParams();
        num = pop->getNumSeasParams();
        for (i = 0; i < num; i++)
        {
            datalist.clear();
            // read seasonal parameter
            for (int j = 0; j < 7; j++)
                datalist.append(c_file->next_value());
            pop->addSeasParam(datalist);
        }

        // ageing error if requested in data file

        // natM dev params
        num = 0;
        for (i = 0; i < pop->Grow()->getNum_patterns(); i++)
        {
            growthPattern *gp = pop->Grow()->getPattern(i);
            gp->setNumDevParams(0);
            for (int j = 0; j < gp->getNumNatMParams(); j++)
            {
                datalist = gp->getNatMParam(j);
                if (datalist.at(8).toInt() == 2)
                {
                    num ++;
                    datalist = readShortParameter(c_file);
                    gp->addDevParam(datalist);
                    datalist = readShortParameter(c_file);
                    gp->addDevParam(datalist);
                }
            }
            for (int j = 0; j < gp->getNumGrowthParams(); j++)
            {
                datalist = gp->getGrowthParam(j);
                if (datalist.at(8).toInt() == 2)
                {
                    num ++;
                    datalist = readShortParameter(c_file);
                    gp->addDevParam(datalist);
                    datalist = readShortParameter(c_file);
                    gp->addDevParam(datalist);
                }
            }
            for (int j = 0; j < gp->getNumCVParams(); j++)
            {
                datalist = gp->getCVParam(j);
                if (datalist.at(8).toInt() == 2)
                {
                    num ++;
                    datalist = readShortParameter(c_file);
                    gp->addDevParam(datalist);
                    datalist = readShortParameter(c_file);
                    gp->addDevParam(datalist);
                }
            }
        }
        if (num > 0)
            temp_int = c_file->next_value().toInt();
        else
            temp_int = 0;
        pop->Grow()->setDevPhase (temp_int);

        // Spawner-recruitment
        pop->SR()->fromFile(c_file);

        // Fishing mortality
        pop->M()->setNumFisheries(data->num_fisheries());
        temp_float = c_file->next_value().toFloat();
        pop->M()->setBparkF(temp_float);
        temp_int = c_file->next_value().toInt();
        pop->M()->setBparkYr(temp_int);
        temp_int = c_file->next_value().toInt();
        pop->M()->setMethod(temp_int);
        temp_float = c_file->next_value().toFloat();
        pop->M()->setMaxF(temp_float);
        pop->M()->setStartF(0);
        pop->M()->setPhase(0);
        pop->M()->setNumInputs(0);
        pop->M()->setNumTuningIters(0);
        switch (pop->M()->getMethod())
        {
        case 2:
            temp_int = c_file->next_value().toInt();
            pop->M()->setStartF(temp_int);
            temp_int = c_file->next_value().toInt();
            pop->M()->setPhase(temp_int);
            temp_int = c_file->next_value().toInt();
            pop->M()->setNumInputs(temp_int);
            break;
        case 3:
            temp_int = c_file->next_value().toInt();
            pop->M()->setNumTuningIters(temp_int);
            break;
        }

        datalist.clear();
        if (pop->M()->getNumInputs() > 0)
        {
            for (int i = 0; i < 6; i++)
            {
                datalist.append(c_file->next_value());
            }
            pop->M()->setInputLine(0, datalist);
        }

        pop->M()->setNumInitialParams(0);
        for (i = 0; i < data->num_fisheries(); i++)
        {
            datalist = readShortParameter(c_file);
            if (!datalist.at(2).isEmpty() && datalist.at(2).compare("0"))
                pop->M()->setInitialParam(i, datalist);
        }

        // Q setup
        for (int i = 0; i < data->num_fleets(); i++)
        {
            datalist.clear();
            for (int j = 0; j < 4; j++)
                datalist.append(c_file->next_value());
            data->getFleet(i)->Q()->setup(datalist);
        }

        for (int i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->Q()->getDoPower())
            {
                datalist.clear();
                datalist = readShortParameter(c_file);
                data->getFleet(i)->Q()->setPower(datalist);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->Q()->getDoEnvLink())
            {
                datalist.clear();
                datalist = readShortParameter(c_file);
                data->getFleet(i)->Q()->setVariable(datalist);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->Q()->getDoExtraSD())
            {
                datalist.clear();
                datalist = readShortParameter(c_file);
                data->getFleet(i)->Q()->setExtra(datalist);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            int tp = data->getFleet(i)->Q()->getType();
            if (tp > 1 && tp < 5)
            {
                datalist = readShortParameter(c_file);
                data->getFleet(i)->Q()->setBase(datalist);
            }
            if (tp == 3 || tp == 4)
            {
                // read 1 parameter for each observation
            }
        }

        for (int i = 0; i < num_fleets; i++)
        {
            temp_int = c_file->next_value().toInt();
            data->getFleet(i)->getSizeSelectivity()->setPattern(temp_int);
            temp_int = c_file->next_value().toInt();
            data->getFleet(i)->getSizeSelectivity()->setDiscard(temp_int);
            temp_int = c_file->next_value().toInt();
            data->getFleet(i)->getSizeSelectivity()->setMale(temp_int);
            temp_int = c_file->next_value().toInt();
            data->getFleet(i)->getSizeSelectivity()->setSpecial(temp_int);
        }

        for (int i = 0; i < num_fleets; i++)
        {
            temp_int = c_file->next_value().toInt();
            data->getFleet(i)->getAgeSelectivity()->setPattern(temp_int);
            temp_int = c_file->next_value().toInt();
            data->getFleet(i)->getAgeSelectivity()->setDiscard(temp_int);
            temp_int = c_file->next_value().toInt();
            data->getFleet(i)->getAgeSelectivity()->setMale(temp_int);
            temp_int = c_file->next_value().toInt();
            data->getFleet(i)->getAgeSelectivity()->setSpecial(temp_int);
        }

/*        temp_string = c_file->read_line();
        while (temp_string.split(' ',QString::SkipEmptyParts).at(0).startsWith('#'))
        {
            temp_string = c_file->read_line();
        }*/
        for (int i = 0; i < num_fleets; i++)
        {
 //           longParameter *lp;
            int num_params = data->getFleet(i)->getSizeSelectivity()->getNumParameters();
            //read num_params parameters
            for (int j = 0; j < num_params; j++)
            {
                datalist = readParameter (c_file);
//                datalist.clear();
//                for (int k = 0; k < 14; k++)
//                    datalist.append(c_file->next_value());
                data->getFleet(i)->getSizeSelectivity()->setParameter(j, datalist);
/*               lp = data->getFleet(i)->getSizeSelectivity()->getParameter(j);
               lp->fromText(temp_string);
               temp_string = c_file->read_line();*/
            }
        }

        for (int i = 0; i < num_fleets; i++)
        {
//            longParameter *lp;
            int num_params = data->getFleet(i)->getAgeSelectivity()->getNumParameters();
            //read num_params parameters
            for (int j = 0; j < num_params; j++)
            {
                datalist = readParameter(c_file);
//                datalist.clear();
//                for (int k = 0; k < 14; k++)
//                    datalist.append(c_file->next_value());
                data->getFleet(i)->getAgeSelectivity()->setParameter(j, datalist);
/*               lp = data->getFleet(i)->getAgeSelectivity()->getParameter(j);
               lp->fromText(temp_string);
               temp_string = c_file->read_line();*/
            }
        }

        // Environmental Linkage
        num_vals = 0;
        for (int i = 0; i < data->num_fleets(); i++)
        {
            num_vals += data->getFleet(i)->getSizeSelectivity()->getNumEnvLink();
            num_vals += data->getFleet(i)->getAgeSelectivity()->getNumEnvLink();
        }
        if (num_vals > 0)
        {
            parametermodel *pm, *pml;
            temp_int = c_file->next_value().toInt();
            data->setCustomEnviroLink(temp_int);
            for (int i = 0; i < data->num_fleets(); i++)
            {
                pm = data->getFleet(i)->getSizeSelectivity()->getParameterModel();
                pml = data->getFleet(i)->getSizeSelectivity()->getEnvLinkParamModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    datalist.clear();
                    if (pm->envLink(j))
                    {
                        for (int k = 0; k < 7; k++)
                            datalist.append(c_file->next_value());
                        pml->setRowData(j, datalist);
                    }
                }
                pm = data->getFleet(i)->getAgeSelectivity()->getParameterModel();
                pml = data->getFleet(i)->getAgeSelectivity()->getEnvLinkParamModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    datalist.clear();
                    if (pm->envLink(j))
                    {
                        for (int k = 0; k < 7; k++)
                            datalist.append(c_file->next_value());
                        pml->setRowData(j, datalist);
                    }
                }
            }
        }

        // Custom Block Setup
        num_vals = 0;
        for (int i = 0; i < data->num_fleets(); i++)
        {
            num_vals += data->getFleet(i)->getSizeSelectivity()->getNumUseBlock();
            num_vals += data->getFleet(i)->getAgeSelectivity()->getNumUseBlock();
        }
        if (num_vals > 0)
        {
            parametermodel *pm, *pmb;
            temp_int = c_file->next_value().toInt();
            data->setCustomBlockSetup(temp_int);
            for (int i = 0; i < data->num_fleets(); i++)
            {
                pm = data->getFleet(i)->getSizeSelectivity()->getParameterModel();
                pmb = data->getFleet(i)->getSizeSelectivity()->getBlockParamModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    datalist.clear();
                    if (pm->useBlock(j))
                    {
                        for (int k = 0; k < 7; k++)
                            datalist.append(c_file->next_value());
                        pmb->setRowData(j, datalist);
                    }
                }
                pm = data->getFleet(i)->getAgeSelectivity()->getParameterModel();
                pmb = data->getFleet(i)->getAgeSelectivity()->getBlockParamModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    datalist.clear();
                    if (pm->useBlock(j))
                    {
                        for (int k = 0; k < 7; k++)
                            datalist.append(c_file->next_value());
                        pmb->setRowData(j, datalist);
                    }
                }
            }
        }

        // Selex parm trends

        // Parameter Deviations
        num_vals = 0;
        for (int i = 0; i < data->num_fleets(); i++)
        {
            num_vals += data->getFleet(i)->getSizeSelectivity()->getNumUseDev();
            num_vals += data->getFleet(i)->getAgeSelectivity()->getNumUseDev();
        }
        if (num_vals > 0)
        {
            parametermodel *pm, *pme, *pmr;
            for (int i = 0; i < data->num_fleets(); i++)
            {
                pm = data->getFleet(i)->getSizeSelectivity()->getParameterModel();
                pme = data->getFleet(i)->getSizeSelectivity()->getDevErrParamModel();
                pmr = data->getFleet(i)->getSizeSelectivity()->getDevRhoParamModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    datalist.clear();
                    if (pm->useDev(j))
                    {
                        for (int k = 0; k < 7; k++)
                            datalist.append(c_file->next_value());
                        pme->setRowData(j, datalist);
                        datalist.clear();
                        for (int k = 0; k < 7; k++)
                            datalist.append(c_file->next_value());
                        pmr->setRowData(j, datalist);
                    }
                }
                pm = data->getFleet(i)->getAgeSelectivity()->getParameterModel();
                pme = data->getFleet(i)->getAgeSelectivity()->getDevErrParamModel();
                pmr = data->getFleet(i)->getAgeSelectivity()->getDevRhoParamModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    datalist.clear();
                    if (pm->useDev(j))
                    {
                        for (int k = 0; k < 7; k++)
                            datalist.append(c_file->next_value());
                        pme->setRowData(j, datalist);
                        datalist.clear();
                        for (int k = 0; k < 7; k++)
                            datalist.append(c_file->next_value());
                        pmr->setRowData(j, datalist);
                    }
                }
            }
            temp_int = c_file->next_value().toInt();
            data->setCustomSelParmDevPhase(temp_int);
            temp_int = c_file->next_value().toInt();
            data->setCustomSelParmDevAdjust(temp_int);
        }

        // Tag loss and Tag reporting parameters go next
        temp_int = c_file->next_value().toInt();
        data->setTagLoss(temp_int);
        if (temp_int == 1)
        {
            // tag loss init
            // tag loss chronic
            // tag overdispersion
            // tag report fleet
            // tag report decay
            data->setTagLossParameter(c_file->read_line());
        }

        //1 #_Variance_adjustments_to_input_value
        temp_int = c_file->next_value().toInt();
        data->setInputValueVariance(0);
        if (temp_int == 1)
        {
            for (int i = 0; i < num_fleets; i++)
            {
                temp_float = c_file->next_value().toFloat();
                data->getFleet(i)->setAddToSurveyCV(temp_float);
                if (floatEquals (temp_float, 0.0))
                    data->setInputValueVariance(1);
            }
            for (int i = 0; i < num_fleets; i++)
            {
                temp_float = c_file->next_value().toFloat();
                data->getFleet(i)->setAddToDiscardSD(temp_float);
                if (floatEquals (temp_float, 0.0))
                    data->setInputValueVariance(1);
            }
            for (int i = 0; i < num_fleets; i++)
            {
                temp_float = c_file->next_value().toFloat();
                data->getFleet(i)->setAddToBodyWtCV(temp_float);
                if (floatEquals (temp_float, 0.0))
                    data->setInputValueVariance(1);
            }
            for (int i = 0; i < num_fleets; i++)
            {
                temp_float = c_file->next_value().toFloat();
                data->getFleet(i)->setMultByLenCompN(temp_float);
                if (floatEquals (temp_float, 1.0))
                    data->setInputValueVariance(1);
            }
            for (int i = 0; i < num_fleets; i++)
            {
                temp_float = c_file->next_value().toFloat();
                data->getFleet(i)->setMultByAgeCompN(temp_float);
                if (floatEquals (temp_float, 1.0))
                    data->setInputValueVariance(1);
            }
            for (int i = 0; i < num_fleets; i++)
            {
                temp_float = c_file->next_value().toFloat();
                data->getFleet(i)->setMultBySAA(temp_float);
                if (floatEquals (temp_float, 1.0))
                    data->setInputValueVariance(1);
            }
        }

        // Max lambda phase
        temp_int = c_file->next_value().toInt();
        data->setLambdaMaxPhase(temp_int);

        // sd offset
        temp_int = c_file->next_value().toInt();
        data->setLambdaSdOffset(temp_int);

        // number of changes
        num = c_file->next_value().toInt();
        data->setLambdaNumChanges(num);

        // change info
        // component, fleet, phase, lambda, sizefreq method
        for (int i = 0; i < num_fleets; i++)
        {
            data->getFleet(i)->resetLambdas();
        }
        for(int i = 0; i < num; i++)
        {
            int cmp, flt = 1, phs, sf;
            float val;
            datalist.clear();
            datalist.append(c_file->next_value());
            flt = abs(c_file->next_value().toInt());
            datalist.append(c_file->next_value());
            datalist.append(c_file->next_value());
            datalist.append(c_file->next_value());

            data->getFleet(flt-1)->appendLambda(datalist);
        }

        temp_int = c_file->next_value().toInt();
        data->getAddSdReporting()->setActive(temp_int);
        if (temp_int == 1)
        {
            // read 9 more values
            datalist.clear();
            for (i = 0; i < 9; i++)
                datalist.append(c_file->next_value());
            data->getAddSdReporting()->setSpecs(datalist);

            datalist.clear();
            temp_int = data->getAddSdReporting()->getNumSelexBins();
            for (i = 0; i < temp_int; i++)
                datalist.append(c_file->next_value());
            data->getAddSdReporting()->setSelexBins(datalist);

            datalist.clear();
            temp_int = data->getAddSdReporting()->getNumGrowthBins();
            for (i = 0; i < temp_int; i++)
                datalist.append(c_file->next_value());
            data->getAddSdReporting()->setGrowthBins(datalist);

            datalist.clear();
            temp_int = data->getAddSdReporting()->getNumNatAgeBins();
            for (i = 0; i < temp_int; i++)
                datalist.append(c_file->next_value());
            data->getAddSdReporting()->setNatAgeBins(datalist);
        }

        temp_int = c_file->next_value().toInt();
        if (temp_int != 999)
        {
            temp_string = QString("Problem reading control file. The end of data token '%1' does not match '999'").arg(
                        QString::number(temp_int));
            c_file->error(temp_string);
        }

        c_file->close();
    }
    else
        c_file->error(QString("Control file is unreadable."));
    return 1;
}

int write32_controlFile(ss_file *c_file, ss_model *data)
{
    int temp_int, num, num_vals, chars = 0;
    int i, j;
    float temp_float;
    QString line, temp_string;
    QStringList str_list;
    population * pop = data->pPopulation;

    if(c_file->open(QIODevice::WriteOnly))
    {
        chars += write_version_comment(c_file);
        chars += c_file->write_comments();

        line = QString("#" );
        chars += c_file->writeline(line);

        // growth patterns
        num = pop->Grow()->getNum_patterns();
        line = QString(QString ("%1 #_N_Growth_Patterns" ).arg (
                           num));
        chars += c_file->writeline(line);
        line.clear();

        num = pop->Grow()->getNum_morphs();
        line.append(QString("%1 ").arg(
                         QString::number(num)));

        line.append(QString("#_N_Morphs_Within_Growth_Pattern" ));
        chars += c_file->writeline(line);
        line.clear();
        if (num > 1)
        {
            temp_float = pop->Grow()->getMorph_within_ratio();
            line.append(QString("%1 ").arg(QString::number(temp_float)));
            line.append(QString("#_Morph_between/within_stdev_ratio (no read if N_morphs=1)" ));
            chars += c_file->writeline(line);
            line.clear();
            for (int i = 0; i < num; i++)
            {
                temp_float = pop->Grow()->getMorph_dist(i);
                for (int j = 0; j < num; j++)
                    line.append(QString("%1 ").arg(
                         QString::number(temp_float)));
            }
            line.append(QString("#vector_Morphdist_(-1_in_first_val_gives_normal_approx)" ));
            chars += c_file->writeline(line);
            chars += c_file->writeline("#" );
        }
        else
        {
            line.append(QString("#_Cond 1 "));
            line.append(QString("#_Morph_between/within_stdev_ratio (no read if N_morphs=1)" ));
            chars += c_file->writeline(line);
            line.clear();
            line.append(QString("#_Cond 1 "));
            line.append(QString("#vector_Morphdist_(-1_in_first_val_gives_normal_approx)" ));
            chars += c_file->writeline(line);
            chars += c_file->writeline("#" );
        }

        // recruitment designs
        line.clear();
        num = pop->Grow()->getNum_patterns() * data->num_seasons() * data->num_areas();
        if (num > 1)
        {
            num = pop->SR()->getNumAssignments();
            line.append(QString("%1 # N recruitment designs (overrides N_GP*nseas*area parameter values)" ).arg(
                            QString::number(num)));
            temp_int = pop->SR()->getDoRecruitInteract()? 1: 0;
            line.append(QString("%1 # recruitment interaction requested" ).arg(
                            QString::number(temp_int)));
            line.append("# GP seas area for each recruitment assignment" );
            chars += c_file->writeline(line);
            for (int i = 0; i < num; i++)
            {
                line.clear();
                str_list = pop->SR()->getAssignment(i);
                for (int j = 0; j < 3; j++)
                    line.append(QString(" %1").arg(str_list.at(j)));
                line.append('\n');
                chars += c_file->writeline(line);
            }
        }
        else
        {
            line.append("#_Cond 0 # N recruitment designs goes here if N_GP*nseas*area>1" );
            line.append("#_Cond 0 # placeholder for recruitment interaction request" );
            line.append("#_Cond 1 1 1  # example recruitment design element for GP=1, seas=1, area=1" );
            chars += c_file->writeline(line);
        }
        chars += c_file->writeline("#" );
        c_file->newline();

        // movement definitions
        line.clear();
        if (data->num_areas() > 1)
        {
            num = pop->Move()->getNumDefs();
            line = QString(QString("%1 # N_movement_definitions" ).arg(
                            QString::number(num)));
            chars += c_file->writeline(line);
            temp_float = pop->Move()->getFirstAge();
            line = QString(QString("%1 # first age that moves (real age at begin of season, not integer)" ).
                           arg(QString::number(temp_float)));
            chars += c_file->writeline(line);
            line = QString("# seas, GP, source_area, dest_area, minage, maxage" );
            chars += c_file->writeline(line);
            for (int i = 0; i < num; i++)
            {
                line.clear();
                str_list = pop->Move()->getDefinition(i);
                for (int j = 0; j < str_list.count(); j++) // should be 6
                {
                    line.append(QString(" %1").arg(str_list.at(j)));
                }
                chars += c_file->writeline(line);
            }
        }
        else
        {
            line.append("#_Cond 0 # N_movement_definitions goes here if N_areas > 1" );
            line.append("#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0" );
            line.append("#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10" );
            chars += c_file->writeline(line);
        }
        chars += c_file->writeline("#" );


        // time block patterns
        num = data->getNumBlockPatterns();
        line = QString(QString("%1 #_N_block_Patterns" ).arg (
                           num));
        chars += c_file->writeline(line);
        line.clear();
        for (int i = 0; i < num; i++)
        {
            BlockPattern *blk = data->getBlockPattern(i);
            temp_int = blk->getNumBlocks();
            line.append(QString("%1 ").arg(temp_int));
        }
        if (line.isEmpty())
            line.append("#_Cond 0 ");
        line.append(QString("#_blocks_per_pattern" ));
        chars += c_file->writeline(line);
        line = QString("# begin and end years of blocks" );
        chars += c_file->writeline(line);
        line.clear();
        for (int i = 0; i < num; i++)
        {
            line.clear();
            BlockPattern *blk = data->getBlockPattern(i);
            temp_int = blk->getNumBlocks();
            for (int j = 0; j < temp_int; j++)
                line.append(blk->getBlockText(j));
            line.append(QString(" #" ));
            chars += c_file->writeline(line);
        }
        chars += c_file->writeline("#" );

        temp_float = pop->get_frac_female();
        line = QString(QString("%1 #_fracfemale " ).arg (temp_float));
        chars += c_file->writeline(line);

        temp_int = pop->Grow()->getNatural_mortality_type();
        line = QString(QString("%1 #_natM_type:_0=1Parm; 1=N_breakpoints;_2=Lorenzen;_3=agespecific;_4=agespec_withseasinterpolate" ).arg(
                           temp_int));
        chars += c_file->writeline (line);
        switch (temp_int)
        {
        case 0:
            line = QString ("  #_no additional input for selected M option; read 1P per morph" );
            chars += c_file->writeline(line);
            break;
        case 1:
            num = pop->Grow()->getNatMortNumBreakPts();
            line = QString("%1 #_N_breakpoints " ).arg(QString::number(num));
            chars += c_file->writeline(line);
            line.clear();
            str_list = pop->Grow()->getNatMortBreakPts();
            for (int i = 0; i < num; i++)
                line.append(QString(" %1").arg(str_list.at(i)));
            line.append(" # age(real) at M breakpoints" );
            chars += c_file->writeline(line);
            break;
        case 2:
            num = pop->Grow()->getNaturalMortLorenzenRef();
            line = QString("%1 #_Lorenzen ref age " ).arg(num);
            chars += c_file->writeline(line);
            break;
        case 3:
        case 4:
            line.clear();
//            num_vals = pop->Grow()->getNatMortNumAges();
            str_list = pop->Grow()->getNatMortAges();
            num = pop->Grow()->getNum_patterns();
            for (i = 0; i < num; i++)
            {
                line = (QString(" %1" ).arg(str_list.at(i).toFloat()));
                chars += c_file->writeline(line);
            }
            if (data->num_genders() > 1)
                for (; i < num; i++)
                {
                    line = (QString(" %1" ).arg(str_list.at(i).toFloat()));
                    chars += c_file->writeline(line);
                }

            break;
        }

        temp_int = pop->Grow()->getModel();
        line = QString(QString("%1 # GrowthModel: 1=vonBert with L1&L2; 2=Richards with L1&L2; 3=age_speciific_K; 4=not implemented" ).arg(
                           temp_int));
        chars += c_file->writeline (line);
        temp_float = pop->Grow()->getAge_for_l1();
        line = QString(QString("%1 #_Growth_Age_for_L1" ).arg(
                           QString::number(temp_float)));
        chars += c_file->writeline (line);
        temp_float = pop->Grow()->getAge_for_l2();
        line = QString(QString("%1 #_Growth_Age_for_L2 (999 to use as Linf)" ).arg(
                           QString::number(temp_float)));
        chars += c_file->writeline (line);
        if (temp_int == 3)
        {
            temp_float = pop->Grow()->getAgeMin_for_K();
            line = QString(QString("%1 #_Min age for age-specific K" ).arg(
                               QString::number(temp_float)));
            chars += c_file->writeline (line);
            temp_float = pop->Grow()->getAgeMax_for_K();
            line = QString(QString("%1 #_Max age for age-specific K" ).arg(
                               QString::number(temp_float)));
            chars += c_file->writeline (line);
        }

        temp_float = pop->Grow()->getSd_add();
        line = QString(QString("%1 #_SD_add_to_LAA (set to 0.1 for SS2 V1.x compatibility)" ).arg(
                           temp_float));
        chars += c_file->writeline (line);
        temp_int = pop->Grow()->getCv_growth_pattern();
        line = QString(QString("%1 #_CV_Growth_Pattern:  0 CV=f(LAA); 1 CV=F(A); 2 SD=F(LAA); 3 SD=F(A); 4 logSD=F(A)" ).arg(
                           temp_int));
        chars += c_file->writeline (line);
        temp_int = pop->Grow()->getMaturity_option();
        line = QString(QString("%1 #_maturity_option:  1=length logistic; 2=age logistic; 3=read age-maturity matrix by growth_pattern; 4=read age-fecundity; 5=read fec and wt from wtatage.ss" ).arg(
                           temp_int));
        chars += c_file->writeline (line);
        if (temp_int == 3 ||  // age specific maturity
            temp_int == 4)
        {
            line.clear();
            str_list = pop->Grow()->getMatAgeVals();
            for (int i = 0; i < str_list.count(); i++)
                line.append(QString(" %1").arg(str_list.at(i).toFloat()));
            line.append('\n');
            chars += c_file->writeline (line);
        }
        else
        {
            line = QString("#_placeholder for empirical age-maturity by growth pattern" );
            chars += c_file->writeline (line);
        }

        temp_float = pop->Grow()->getFirst_mature_age();
        line = QString(QString("%1 #_First_Mature_Age" ).arg(
                           QString::number(temp_float)));
        chars += c_file->writeline (line);
        temp_int = pop->Fec()->getMethod();
        line = QString(QString("%1 #_fecundity option:(1)eggs=Wt*(a+b*Wt);(2)eggs=a*L^b;(3)eggs=a*Wt^b; (4)eggs=a+b*L; (5)eggs=a+b*W" ).arg(
                           temp_int));
        chars += c_file->writeline (line);
        temp_int = pop->Fec()->getHermaphroditism();
        line = QString(QString("%1 #_hermaphroditism option:  0=none; 1=age-specific fxn" ).arg(
                           temp_int));
        chars += c_file->writeline (line);
        if (temp_int == 1)
        {
            temp_float = pop->Fec()->getHermSeason();
            line = QString(QString("%1 #_hermaphroditism Season:  -1 trans at end of each seas; or specific seas" ).arg(
                               QString::number(temp_float)));
            chars += c_file->writeline (line);
            temp_int = pop->Fec()->getHermIncludeMales();
            line = QString(QString("%1 #_include males in spawning biomass:  0=no males; 1=add males to females; xx=reserved." ).arg(
                               temp_int));
            chars += c_file->writeline (line);
        }
        temp_int = pop->Grow()->getParam_offset_method();
        line = QString(QString("%1 #_parameter_offset_approach (1=none, 2= M, G, CV_G as offset from female-GP1, 3=like SS2 V1.x)" ).arg(
                           temp_int));
        chars += c_file->writeline (line);
        temp_int = pop->Grow()->getAdjustment_method();
        line = QString(QString("%1 #_env/block/dev_adjust_method (1=standard; 2=logistic transform keeps in base parm bounds; 3=standard w/ no bound check)" ).arg(
                           temp_int));
        chars += c_file->writeline (line);

        // growth parameters
        line = QString("#\n#_growth_parms\n#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn" );
        chars += c_file->writeline(line);
        num = pop->Grow()->getNum_patterns();
        for (i = 0; i < num; i++)
        {
            growthPattern *gp = pop->Grow()->getPattern(i);
            QString gpstr (QString("GP_%1").arg(QString::number(i + 1)));
            QString genstr, parstr;
            num_vals = data->num_genders();
            {
                int numpar = 1;
                if (pop->Grow()->getNatural_mortality_type() > 0)
                    numpar = 2;
                genstr = QString ("Fem");
                for (int k = 0; k < numpar; k++)
                {
                    parstr = QString (QString("NatM_p_%1").arg(QString::number(k + 1)));
                    line.clear();
                    str_list = gp->getNatMParam(k);
                    for (int l = 0; l < str_list.count(); l++)
                        line.append(QString(" %1").arg(str_list.at(l)));
                    line.append(QString(" # %1_%2_%3" ).arg (parstr, genstr, gpstr));
                    chars += c_file->writeline (line);
                }
                for (int k = 0; k < gp->getNumGrowthParams()/num_vals; k++)
                {
                    parstr = QString(QString("Growth_p_%1").arg(QString::number(k + 1)));
                    line.clear();
                    str_list = gp->getGrowthParam(k);
                    for (int l = 0; l < str_list.count(); l++)
                        line.append(QString(" %1").arg(str_list.at(l)));
                    line.append(QString(" # %1_%2_%3" ).arg (parstr, genstr, gpstr));
                    chars += c_file->writeline (line);
                }
                for (int k = 0; k < gp->getNumCVParams()/num_vals; k++)
                {
                    parstr = QString(QString("CV_p_%1").arg(QString::number(k + 1)));
                    line.clear();
                    str_list = gp->getCVParam(k);
                    for (int l = 0; l < str_list.count(); l++)
                        line.append(QString(" %1").arg(str_list.at(l)));
                    line.append(QString(" # %1_%2_%3" ).arg (parstr, genstr, gpstr));
                    chars += c_file->writeline (line);
                }
                if (num_vals > 1)
                {
                    genstr = QString ("Male");
                    for (int k = gp->getNumNatMParams()/2; k < gp->getNumNatMParams(); k++)
                    {
                        parstr = QString (QString("NatM_p_%1").arg(QString::number(k + 1)));
                        line.clear();
                        str_list = gp->getNatMParam(k);
                        for (int l = 0; l < str_list.count(); l++)
                            line.append(QString(" %1").arg(str_list.at(l)));
                        line.append(QString(" # %1_%2_%3" ).arg (parstr, genstr, gpstr));
                        chars += c_file->writeline (line);
                    }
                    for (int k = gp->getNumGrowthParams()/num_vals; k < gp->getNumGrowthParams(); k++)
                    {
                        parstr = QString(QString("Growth_p_%1").arg(QString::number(k + 1)));
                        line.clear();
                        str_list = gp->getGrowthParam(k);
                        for (int l = 0; l < str_list.count(); l++)
                            line.append(QString(" %1").arg(str_list.at(l)));
                        line.append(QString(" # %1_%2_%3" ).arg (parstr, genstr, gpstr));
                        chars += c_file->writeline (line);
                    }
                    for (int k = gp->getNumCVParams()/num_vals; k < gp->getNumCVParams(); k++)
                    {
                        parstr = QString(QString("CV_p_%1").arg(QString::number(k + 1)));
                        line.clear();
                        str_list = gp->getCVParam(k);
                        for (int l = 0; l < str_list.count(); l++)
                            line.append(QString(" %1").arg(str_list.at(l)));
                        line.append(QString(" # %1_%2_%3" ).arg (parstr, genstr, gpstr));
                        chars += c_file->writeline (line);
                    }

                }
            }
        }
        line.clear();
        str_list = pop->Grow()->getMaturityParam(0);
        for (int l = 0; l < str_list.count(); l++)
            line.append(QString(" %1").arg(str_list.at(l)));
        line.append(" # Wtlen_1_Fem" );
        chars += c_file->writeline (line);
        line.clear();
        str_list = pop->Grow()->getMaturityParam(1);
        for (int l = 0; l < str_list.count(); l++)
            line.append(QString(" %1").arg(str_list.at(l)));
        line.append(" # Wtlen_2_Fem" );
        chars += c_file->writeline (line);
        line.clear();
        str_list = pop->Grow()->getMaturityParam(2);
        for (int l = 0; l < str_list.count(); l++)
            line.append(QString(" %1").arg(str_list.at(l)));
        line.append(" # Mat50%_Fem" );
        chars += c_file->writeline (line);
        line.clear();
        str_list = pop->Grow()->getMaturityParam(3);
        for (int l = 0; l < str_list.count(); l++)
            line.append(QString(" %1").arg(str_list.at(l)));
        line.append(" # Mat_slope_Fem" );
        chars += c_file->writeline (line);
        line.clear();
        str_list = pop->Fec()->getFemaleParam(0);
        for (int l = 0; l < str_list.count(); l++)
            line.append(QString(" %1").arg(str_list.at(l)));
        line.append(" # Eggs/kg_inter_Fem" );
        chars += c_file->writeline (line);
        line.clear();
        str_list = pop->Fec()->getFemaleParam(1);
        for (int l = 0; l < str_list.count(); l++)
            line.append(QString(" %1").arg(str_list.at(l)));
        line.append(" # Eggs/kg_slope_wt_Fem" );
        chars += c_file->writeline (line);

        if (num_vals > 1)
        {
            line.clear();
            str_list = pop->Grow()->getMaturityParam(4);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(" # Wtlen_1_Male" );
            chars += c_file->writeline (line);
            line.clear();
            str_list = pop->Grow()->getMaturityParam(5);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(" # Wtlen_2_Male" );
            chars += c_file->writeline (line);
        }
        if (pop->Fec()->getHermaphroditism() == 1)
        {
            for (i = 0; i < 3; i++)
            {
                line.clear();
                str_list = pop->Fec()->getHermParam(i); // hermaph_inflect, sd, asymptotic
                for (int l = 0; l < str_list.count(); l++)
                    line.append(QString(" %1").arg(str_list.at(l)));
                line.append(QString(" # Hermaph_p_%1" ).arg(QString::number(i + 1)));
                chars += c_file->writeline (line);
            }
        }

        for (num = 0, i = 0; num < pop->Grow()->getNum_patterns(); num++, i++)
        {
            line.clear();
            str_list = pop->SR()->getAssignmentParam(i);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(QString(" # RecrDist_GP_%1" ).arg(QString::number(num + 1)));
            chars += c_file->writeline (line);
        }
        for (num = 0; num < data->num_areas(); num++, i++)
        {
            line.clear();
            str_list = pop->SR()->getAssignmentParam(i);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(QString(" # RecrDist_Area_%1" ).arg(QString::number(num + 1)));
            chars += c_file->writeline (line);
        }
        for (num = 0; num < data->num_seasons(); num++, i++)
        {
            line.clear();
            str_list = pop->SR()->getAssignmentParam(i);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(QString(" # RecrDist_Seas_%1" ).arg(QString::number(num + 1)));
            chars += c_file->writeline (line);
        }
        if (pop->SR()->getDoRecruitInteract())
        {
            num = pop->SR()->getNumInteractParams();
            for (i = 0; i < num; i++)
            {
                line.clear();
                str_list = pop->SR()->getInteractParam(i);
                for (int l = 0; l < str_list.count(); l++)
                    line.append(QString(" %1").arg(str_list.at(l)));
                line.append(QString(" # RecrDist_interaction" ).arg(QString::number(i)));
                chars += c_file->writeline (line);
            }
        }
        line.clear();
        str_list = pop->Grow()->getCohortParam();
        for (int l = 0; l < str_list.count(); l++)
            line.append(QString(" %1").arg(str_list.at(l)));
        line.append(QString(" # CohortGrowDev" ));
        chars += c_file->writeline (line);

        // movement parameters
        num = pop->Move()->getNumDefs();
        for (i = 0; i < num; i++)
        {
            str_list = pop->Move()->getDefinition(i);
            QString seas = str_list.at(0);
            QString gp = str_list.at(1);
            QString from = str_list.at(2);
            QString to = str_list.at(3);
            int par = i * 2;
            line.clear();
            str_list = pop->Move()->getParameter(par);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(QString(" # MoveParm_A_seas_%1_GP_%2_from_%3_to_%4" ).arg(seas, gp, from, to));
            chars += c_file->writeline (line);
            line.clear();
            str_list = pop->Move()->getParameter(par + 1);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(QString(" # MoveParm_B_seas_%1_GP_%2_from_%3_to_%4" ).arg(seas, gp, from, to));
            chars += c_file->writeline (line);
        }

        // catch multiplier
/*        num = 0;
        for (i = 0; i < data->num_fleets(); i++)
            num += data->getFleet(i)->get_catch_mult();
        if (num > 0)
        {
            line.clear();
            str_list = data->getCatchMult();
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(QString(" # CatchMultParam" ));
            chars += c_file->writeline (line);
        }*/

        //ageing error parameters
        if (data->get_age_composition()->getUseParameters())
        {
            for (i = 0; i < 7; i++)
            {
                line.clear();
                str_list = data->get_age_composition()->getErrorParam(i);
                for (int l = 0; l < str_list.count(); l++)
                    line.append(QString(" %1").arg(str_list.at(l)));
                line.append(QString(" # AgeKeyParam%1" ).arg(QString::number(i+1)));
                chars += c_file->writeline (line);
            }
        }

        chars += c_file->writeline ("#" );
        temp_int = pop->Grow()->getCustomEnvLink();
        line = QString ("# custom_MG-env_setup (0/1)" );
        if (temp_int == -1)
        {
            line.prepend("#_Cond 0 ");
            line.append("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-environ parameters" );
        }
        else if (temp_int == 0)
        {
            line.prepend("0 ");
        }
        else if (temp_int == 1)
        {
            line.prepend("1 ");
        }
        chars += c_file->writeline (line);
        num = pop->Grow()->getNumEnvLinkParams();
        for (i = 0; i < num; i++)
        {
            str_list = pop->Grow()->getEnvironParam(i);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(QString(" " ).arg(QString::number(i)));
            chars += c_file->writeline (line);
        }

        chars += c_file->writeline ("#" );
        temp_int = pop->Grow()->getCustomBlock();
        line = QString ("# custom_MG-block_setup (0/1)" );
        if (temp_int == -1)
        {
            line.prepend("#_Cond 0 ");
            line.append("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-block parameters" );
        }
        else if (temp_int == 0)
        {
            line.prepend("0 ");
        }
        else if (temp_int == 1)
        {
            line.prepend("1 ");
        }
        chars += c_file->writeline (line);
        num = pop->Grow()->getNumBlockParams();
        for (i = 0; i < num; i++)
        {
            str_list = pop->Grow()->getBlockParam(i);
            for (int l = 0; l < str_list.count(); l++)
                line.append(QString(" %1").arg(str_list.at(l)));
            line.append(QString(" " ).arg(QString::number(i)));
            chars += c_file->writeline (line);
        }
        chars += c_file->writeline ("#" );

        line = QString("#_seasonal_effects_on_biology_parms" );
        chars += c_file->writeline(line);
        line.clear();
        line.append(QString(" %1").arg(QString::number(pop->getFemwtlen1())));
        line.append(QString(" %1").arg(QString::number(pop->getFemwtlen2())));
        line.append(QString(" %1").arg(QString::number(pop->getMat1())));
        line.append(QString(" %1").arg(QString::number(pop->getMat2())));
        line.append(QString(" %1").arg(QString::number(pop->getFec1())));
        line.append(QString(" %1").arg(QString::number(pop->getFec2())));
        line.append(QString(" %1").arg(QString::number(pop->getMalewtlen1())));
        line.append(QString(" %1").arg(QString::number(pop->getMalewtlen2())));
        line.append(QString(" %1").arg(QString::number(pop->getL1())));
        line.append(QString(" %1").arg(QString::number(pop->getK())));
        line.append(QString(" #_FemWtLn1,FemWtLn2,Mat1,Mat2,Fec1,Fec2,MaleWtLn1,MaleWtLn2,L1,K" ));
        chars += c_file->writeline(line);

        line = QString("#_LO HI INIT PRIOR PR_type SD PHASE" );
        chars += c_file->writeline(line);
        num = pop->getNumSeasParams();
        if (num == 0)
        {
            line = QString("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no seasonal MG parameters)" );
            chars += c_file->writeline(line);
        }
        else
        {
            for (i = 0; i < num; i++)
            {
                line.clear();
                str_list = pop->getSeasParam(i);
                for (int l = 0; l < str_list.count(); l++)
                    line.append(QString(" %1").arg(str_list.at(l)));
                line.append(QString(" # MG-environ param %1" ).arg(QString::number(i)));
                chars += c_file->writeline (line);
            }
        }

        // deviation error params
        line = QString("#\n# standard error parameters for MG devs" );
        chars += c_file->writeline(line);
        num = 0;
        for (i = 0; i < pop->Grow()->getNum_patterns(); i++)
        {
            growthPattern *gp = pop->Grow()->getPattern(i);
            num = gp->getNumDevParams();
            for (int j = 0; j < num; j++)
            {
                line.clear();
                str_list = gp->getDevParam(j);
                for (int l = 0; l < str_list.count(); l++)
                    line.append(QString(" %1").arg(str_list.at(l)));
                line.append(QString(" # MG-dev error param %1" ).arg(QString::number(j)));
                chars += c_file->writeline (line);
            }
        }
        if (num > 0)
        {
            line = QString(QString("#\n%1 #_MGparm_Dev_Phase" ).arg(pop->Grow()->getDevPhase()));
            chars += c_file->writeline(line);
        }
        else
        {
            line = QString(QString("#\n#0 #_MGparm_Dev_Phase" ));
            chars += c_file->writeline(line);
        }
        chars += c_file->writeline("#" );

        // Spawner-recruitment
        line = pop->SR()->toText();
        chars += c_file->writeline(line);
        c_file->newline();

        // mortality
        line = pop->M()->toText();
        chars += c_file->writeline(line);
        c_file->newline();

        line = QString("#_Q_setup" );
        line.append(QString("# Q_type options:  <0=mirror, 0=float_nobiasadj, 1=float_biasadj, 2=parm_nobiasadj, 3=parm_w_random_dev, 4=parm_w_randwalk, 5=mean_unbiased_float_assign_to_parm" ));
        line.append(QString("#_for_env-var:_enter_index_of_the_env-var_to_be_linked" ));
        line.append(QString("#_Den-dep  env-var  extra_se  Q_type  Q_offset" ));
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            line = data->getFleet(i)->Q()->getSetup();
            line.chop (2);
/*            QString powr, envr, extr, type, offs;
            powr = QString::number(data->getFleet(i)->Q()->getDoPower());
            envr = QString::number(data->getFleet(i)->Q()->getDoEnvVar());
            extr = QString::number(data->getFleet(i)->Q()->getDoExtraSD());
            type = QString::number(data->getFleet(i)->Q()->getType());
            offs = QString::number(data->getFleet(i)->Q()->getOffset());
            line = QString(QString(" %1 %2 %3 %4").arg(
                                   powr, envr, extr, type));
            if (datafile_version >= 3.30)
            {
                line.append(QString(" %1").arg(offs));
            }*/
            line.append(QString(" # %1 %2" ).arg(
                            QString::number(i + 1),
                            data->getFleet(i)->get_name()));
            chars += c_file->writeline(line);
        }
        line = QString ("#" );
        line.append(QString("#_Cond 0 #_If q has random component, then 0=read one parm for each fleet with random q; 1=read a parm for each year of index" ));
        line.append(QString("#_Q_parms(if_any);Qunits_are_ln(q)" ));
        line.append(QString("# LO HI INIT PRIOR PR_type SD PHASE" ));
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->Q()->getDoPower())
            {
                line = data->getFleet(i)->Q()->getPower();
                line.append(QString(" # Q_den_dep_%1_%2" ).arg(
                                QString::number(i+1),
                                data->getFleet(i)->get_name()));
                chars += c_file->writeline(line);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->Q()->getDoEnvLink())
            {
                line = data->getFleet(i)->Q()->getVariable();
                line.append(QString(" # Q_env_var_%1_%2" ).arg(
                                QString::number(i+1),
                                data->getFleet(i)->get_name()));
                chars += c_file->writeline(line);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->Q()->getDoExtraSD())
            {
                line = data->getFleet(i)->Q()->getExtra();
                line.append(QString(" # Q_extraSD_%1_%2" ).arg(
                                QString::number(i+1),
                                data->getFleet(i)->get_name()));
                chars += c_file->writeline(line);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->Q()->getType() > 0)
            {
                line = data->getFleet(i)->Q()->getBase();
                line.append(QString(" # Q_base_%1_%2" ).arg(
                                QString::number(i+1),
                                data->getFleet(i)->get_name()));
                chars += c_file->writeline(line);
            }
        }


        line = QString ("#" );
        line.append(QString("#_size_selex_types" ));
        line.append(QString("#discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead" ));
        line.append(QString("#_Pattern Discard Male Special" ));
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            line = QString(QString("%1 # %2 %3" ).arg (
                               data->getFleet(i)->getSizeSelectivity()->getSetupText(),
                               QString::number(i + 1),
                               data->getFleet(i)->get_name()));
            chars += c_file->writeline(line);
        }

        line = QString ("#" );
        line.append(QString("#_age_selex_types" ));
        line.append(QString("#_Pattern ___ Male Special" ));
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            line = QString(QString("%1 # %2 %3" ).arg (
                               data->getFleet(i)->getAgeSelectivity()->getSetupText(),
                               QString::number(i + 1),
                               data->getFleet(i)->get_name()));
            chars += c_file->writeline(line);
        }
        line = QString ("#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn" );
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            for (int j = 0; j < data->getFleet(i)->getSizeSelectivity()->getNumParameters(); j++)
            {
                line = QString(QString("%1 #_SizeSel_%2P_%3_%4" ).arg (
                                   data->getFleet(i)->getSizeSelectivity()->getParameterText(j),
                                   QString::number(i+1),
                                   QString::number(j+1),
                                   data->getFleet(i)->get_name()));
                chars += c_file->writeline(line);
            }
        }

        for (int i = 0; i < data->num_fleets(); i++)
        {
            for (int j = 0; j < data->getFleet(i)->getAgeSelectivity()->getNumParameters(); j++)
            {
                line = QString(QString("%1 #_AgeSel_%2P_%3_%4" ).arg (
                                   data->getFleet(i)->getAgeSelectivity()->getParameterText(j),
                                   QString::number(i+1),
                                   QString::number(j+1),
                                   data->getFleet(i)->get_name()));
                chars += c_file->writeline(line);
            }
        }

        // Environmental Linkage
        line = QString (" #_custom_sel-env_setup (0/1) " );
        num_vals = 0;
        for (int i = 0; i < data->num_fleets(); i++)
        {
            num_vals += data->getFleet(i)->getSizeSelectivity()->getNumEnvLink();
            num_vals += data->getFleet(i)->getAgeSelectivity()->getNumEnvLink();
        }
        if (num_vals > 0)
        {
            parametermodel *pm;
            temp_int = data->getCustomEnviroLink();
            line.prepend(QString::number(temp_int));
            chars += c_file->writeline(line);
            for (int i = 0; i < data->num_fleets(); i++)
            {
                pm = data->getFleet(i)->getSizeSelectivity()->getParameterModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    str_list = pm->getRowData(j);
                    if (pm->envLink(j) > 0)
                    {
                    line = QString(QString("%1 # SizeSel_P%2_%3(%4)_env_fxn" ).arg (
                                       data->getFleet(i)->getSizeSelectivity()->getEnvLinkParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name()));
                                       QString::number(i+1),
                    chars += c_file->writeline(line);
                    }
                }
                pm = data->getFleet(i)->getAgeSelectivity()->getParameterModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    str_list = pm->getRowData(j);
                    if (pm->envLink(j) > 0)
                    {
                    line = QString(QString("%1 # AgeSel_P%2_%3(%4)_env_fxn" ).arg (
                                       data->getFleet(i)->getAgeSelectivity()->getEnvLinkParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name()));
                                       QString::number(i+1),
                    chars += c_file->writeline(line);
                    }
                }
            }
        }
        else
        {
            line.prepend("#_Cond 0");
            line.append("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no enviro fxns" );
            chars += c_file->writeline(line);
        }


        // Custom Block Setup
        line = QString (" #_custom_sel-blk_setup (0/1) " );
        num_vals = 0;
        for (int i = 0; i < data->num_fleets(); i++)
        {
            num_vals += data->getFleet(i)->getSizeSelectivity()->getNumUseBlock();
            num_vals += data->getFleet(i)->getAgeSelectivity()->getNumUseBlock();
        }
        if (num_vals > 0)
        {
            parametermodel *pm;
            temp_int = data->getCustomBlockSetup();
            line.prepend(QString::number(temp_int));
            chars += c_file->writeline(line);
            for (int i = 0; i < data->num_fleets(); i++)
            {
                pm = data->getFleet(i)->getSizeSelectivity()->getParameterModel();
                num = data->getFleet(i)->getSizeSelectivity()->getNumParameters();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    str_list = pm->getRowData(j);
                    if (pm->useBlock(j) > 0)
                    {
                    line = QString(QString(" %1 # SizeSel_P%2_%3(%4)_blk_setup" ).arg (
                                       data->getFleet(i)->getSizeSelectivity()->getBlockParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name()));
                                       QString::number(i+1),
                    chars += c_file->writeline(line);
                    }
                }
                pm = data->getFleet(i)->getAgeSelectivity()->getParameterModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    str_list = pm->getRowData(j);
                    if (pm->useBlock(j) > 0)
                    {
                    line = QString(QString(" %1 # AgeSel_P%2_%3(%4)_blk_setup" ).arg (
                                       data->getFleet(i)->getAgeSelectivity()->getBlockParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name()));
                                       QString::number(i+1),
                    chars += c_file->writeline(line);
                    }
                }
            }
        }
        else
        {
            line.prepend("#_Cond 0");
            line.append("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no block usage" );
            chars += c_file->writeline(line);
        }

        // Selex parm trends
        line = QString ("#_Cond No selex parm trends " );
        chars += c_file->writeline(line);

        // Parameter Deviations
        line = QString ("# standard error parameters for selparm devs" );
        chars += c_file->writeline(line);
        num_vals = 0;
        for (int i = 0; i < data->num_fleets(); i++)
        {
            num_vals += data->getFleet(i)->getSizeSelectivity()->getNumUseDev();
            num_vals += data->getFleet(i)->getAgeSelectivity()->getNumUseDev();
        }
        if (num_vals > 0)
        {
            parametermodel *pm;
            for (int i = 0; i < data->num_fleets(); i++)
            {
                pm = data->getFleet(i)->getSizeSelectivity()->getParameterModel();
                num = data->getFleet(i)->getSizeSelectivity()->getNumParameters();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    str_list = pm->getRowData(j);
                    if (pm->useDev(j) > 0)
                    {
                    line = QString(QString(" %1 # SizeSel_P%2_%3(%4)_dev_se" ).arg (
                                       data->getFleet(i)->getSizeSelectivity()->getDevErrParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name()));
                                       QString::number(i+1),
                    chars += c_file->writeline(line);
                    line = QString(QString(" %1 # SizeSel_P%2_%3(%4)_dev_rho" ).arg (
                                       data->getFleet(i)->getSizeSelectivity()->getDevRhoParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name()));
                                       QString::number(i+1),
                    chars += c_file->writeline(line);
                    }
                }
                pm = data->getFleet(i)->getAgeSelectivity()->getParameterModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    str_list = pm->getRowData(j);
                    if (pm->useDev(j) > 0)
                    {
                    line = QString(QString(" %1 # AgeSel_P%2_%3(%4)_dev_se" ).arg (
                                       data->getFleet(i)->getAgeSelectivity()->getDevErrParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name(),
                                       QString::number(i+1)));
                    chars += c_file->writeline(line);
                    line = QString(QString(" %1 # AgeSel_P%2_%3(%4)_dev_rho" ).arg (
                                       data->getFleet(i)->getAgeSelectivity()->getDevRhoParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name(),
                                       QString::number(i+1)));
                    chars += c_file->writeline(line);
                    }
                }
            }
        }
        else
        {
            line = QString("#_Cond 0.0075 0.12 0.03 0.03 0 0.25 -5 # xSel_Px_Fishery(x)_dev_se" );
            line.append("#_Cond 0 0.99 0 0.2 0 0.2 -5 # xSel_Px_Fishery(x)_dev_rho" );
            chars += c_file->writeline(line);
        }

        // Tag Recapture Parameters
        temp_int = data->getTagLoss();
        line = QString(QString("#\n# Tag loss and Tag reporting parameters go next\n%1 # TG_custom:  0=no read; 1=read if tags exist" ).arg(
                           QString::number(temp_int)));
        chars += c_file->writeline(line);
        if (temp_int == 1)
        {
            line = QString(QString("%1 # tag loss parameter" ).arg(
                               data->getTagLossParameter()->toText()));
        }
        else
        {
            line = QString(QString("#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters" ));
        }
        chars += c_file->writeline(line);

        temp_int = data->getInputValueVariance();
        line = QString(QString("#\n %1 #_Variance_adjustments_to_input_values" ).arg (
                    QString::number(temp_int)));
        chars += c_file->writeline(line);
        line = QString ("#_fleet");
        for (int i = 0; i < data->num_fleets(); i++)
            line.append(QString(" %1").arg(QString::number(i+1)));
        line.append('\n');
        chars += c_file->writeline(line);

        if (temp_int == 1)
        {
            line = QString(" ");
            for (int i = 0; i < data->num_fleets(); i++)
            {
                line.append(QString("%1 ").arg(
                                QString::number(data->getFleet(i)->getAddToSurveyCV())));
            }
            line.append(QString("#_add_to_survey_CV\n "));
            for (int i = 0; i < data->num_fleets(); i++)
            {
                line.append(QString("%1 ").arg(
                                QString::number(data->getFleet(i)->getAddToDiscardSD())));
            }
            line.append(QString("#_add_to_discard_stddev\n "));
            for (int i = 0; i < data->num_fleets(); i++)
            {
                line.append(QString("%1 ").arg(
                                QString::number(data->getFleet(i)->getAddToBodyWtCV())));
            }
            line.append(QString("#_add_to_bodywt_CV\n "));
            for (int i = 0; i < data->num_fleets(); i++)
            {
                line.append(QString("%1 ").arg(
                                QString::number(data->getFleet(i)->getMultByLenCompN())));
            }
            line.append(QString("#_mult_by_lencomp_N\n "));
            for (int i = 0; i < data->num_fleets(); i++)
            {
                line.append(QString("%1 ").arg(
                                QString::number(data->getFleet(i)->getMultByAgeCompN())));
            }
            line.append(QString("#_mult_by_agecomp_N\n "));
            for (int i = 0; i < data->num_fleets(); i++)
            {
                line.append(QString("%1 ").arg(
                                QString::number(data->getFleet(i)->getMultBySAA())));
            }
            line.append(QString("#_mult_by_size-at-age_N\n "));
            chars += c_file->writeline(line);
        }

        line = QString(QString("#\n%1 #_maxlambdaphase\n%2 #_sd_offset" ).arg(
                           QString::number(data->getLambdaMaxPhase()),
                           QString::number(data->getLambdaSdOffset())));
        chars += c_file->writeline(line);
        line = QString(QString("#\n%1 # number of changes to make to default Lambdas (default value is 1.0)" ).arg(
                           QString::number(data->getLambdaNumChanges())));
        chars += c_file->writeline(line);
        line = QString(QString("# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch;" ));
        chars += c_file->writeline(line);
        line = QString(QString("# 9=init_equ_catch; 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin" ));
        chars += c_file->writeline(line);
        line = QString(QString("#like_comp fleet/survey  phase  value  sizefreq_method" ));
        chars += c_file->writeline(line);
        num = 0;
        for (int i = 0; i < data->num_fleets(); i++)
        {
            int j = 0;
            for (j = 0; j < data->getFleet(i)->getNumLambdas(); j++)
            {
                line.clear();
                str_list = data->getFleet(i)->getLambda(j);
                line.append(QString(" %1 ").arg(str_list.at(0)));
                line.append(QString::number(i + 1));
                line.append(QString(" %1").arg(str_list.at(1)));
                line.append(QString(" %1").arg(str_list.at(2)));
                line.append(QString(" %1").arg(str_list.at(3)));
                line.append('\n');

                chars += c_file->writeline(line);
            }
            num += j;
        }
        if (num > data->getLambdaNumChanges())
        {
            c_file->error(QString("Problem writing control file. Lambda changes do not match."));
        }

        temp_int = data->getAddSdReporting()->getActive();
        if (temp_int == 1)
        {
            line = QString("1 # (0/1) read specs for more stddev reporting" );
            chars += c_file->writeline(line);
            line = QString (QString("%1 # selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages" ).arg(
                                data->getAddVarSetupToText()));
            chars += c_file->writeline(line);
            line.clear();
            str_list = data->getAddSdReprtSelex();
            for (int i = 0; i < str_list.count(); i++)
            {
                line.append(QString (" %1").arg(str_list.at(i)));
            }
            line.append(" # vector with selex std bin picks (-1 in first bin to self-generate)" );
            chars += c_file->writeline(line);
            line.clear();
            str_list = data->getAddSdReprtGrwth();
            for (int i = 0; i < str_list.count(); i++)
            {
                line.append(QString(" %1").arg(str_list.at(i)));
            }
            line.append(" # vector with growth std bin picks (-1 in first bin to self-generate)" );
            chars += c_file->writeline(line);
            line.clear();
            str_list = data->getAddSdReprtAtAge();
            for (int i = 0; i < str_list.count(); i++)
            {
                line.append(QString(" %1").arg(str_list.at(i)));
            }
            line.append(" # vector with NatAge std bin picks (-1 in first bin to self-generate)" );
            chars += c_file->writeline(line);
        }
        else
        {
            line = QString("0 # (0/1) read specs for more stddev reporting" );
            chars += c_file->writeline(line);
        }

        c_file->newline();
        line = QString::number(END_OF_DATA);
        line.append('\n');
        chars += c_file->writeline(line);

        c_file->close();
    }
    return chars;
}

bool read32_parameterFile(ss_file *pr_file, ss_model *data)
{
    bool flag = false;
    if(pr_file->open(QIODevice::ReadOnly))
    {
        flag = true;
        pr_file->seek(0);
        pr_file->read_comments();

        pr_file->close();
    }
    else
        pr_file->error("File is not readable.");

    return flag;
}

int write32_parameterFile(ss_file *pr_file, ss_model *data)
{
    int chars = 0;

    if(pr_file->open(QIODevice::WriteOnly))
    {
        pr_file->write_comments();
        pr_file->close();
    }
    else
        pr_file->error("File is not writeable.");
    return chars;
}

bool read32_userDataFile (ss_file *ud_file, ss_model *data)
{
    return true;
}

int write32_userDataFile (ss_file ud_file, ss_model *data)
{
    return 0;
}

bool read32_profileFile (ss_file *pf_file, ss_model *data)
{
    bool okay;


    if(pf_file->open(QIODevice::ReadOnly))
    {
        pf_file->seek(0);
        pf_file->read_comments();
        pf_file->close();
        okay = true;
    }
    else
    {
        pf_file->error(QString("File is not readable."));
        okay = false;
    }

    return okay;
}

int write32_profileFile (ss_file *pf_file, ss_model *data)
{
    int code = 0;

    if(pf_file->open(QIODevice::WriteOnly))
    {
        pf_file->write_comments();
        pf_file->close();
    }
    else
    {
        pf_file->error(QString("File is not writeable."));
        code = 1;
    }

    return code;
}
