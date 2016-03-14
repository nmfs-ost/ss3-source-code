
#include "fileIO33.h"
#include "model.h"
#include "fileIOgeneral.h"

bool read33_dataFile(ss_file *d_file, ss_model *data)
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
//        data->reset();

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
            temp_float = token.toFloat();
            data->set_months_per_season(i, temp_float);
        }
        token = d_file->next_value("subseasons");
        temp_int = token.toInt();
        data->set_num_subseasons(temp_int);
        token = d_file->next_value("spawning season");
        temp_int = token.toInt();
        data->set_spawn_season(temp_int);
        token = d_file->next_value("number of genders");
        temp_int = token.toInt();
        n_genders = temp_int;
        data->set_num_genders(n_genders);
        token = d_file->next_value("number of ages");
        temp_int = token.toInt();
        n_ages = temp_int;
        data->set_num_ages(n_ages);
        token = d_file->next_value("number of areas");
        temp_int = token.toInt();
        n_areas = temp_int;
        data->set_num_areas(n_areas);
        data->getPopulation()->Move()->setNumAreas(n_areas);
        token = d_file->next_value("number of fleets");
        temp_int = token.toInt();
        total_fleets = temp_int;
        data->set_num_fleets(total_fleets);
        for (i = 0; i < total_fleets; i++)
        {
            Fleet *flt = data->getFleet(i);
            flt->setActive(true);
            flt->getSizeSelectivity()->setNumAges(data->num_ages());
            flt->getAgeSelectivity()->setNumAges (data->num_ages());
            temp_int = d_file->next_value("fleet type").toInt();
            flt->setTypeInt(temp_int);
            temp_float = d_file->next_value("timing").toFloat();
            flt->set_timing(temp_float);
            temp_int = d_file->next_value("area").toInt();
            flt->set_area(temp_int);
            temp_int = d_file->next_value("catch units").toInt();
            flt->set_catch_units(temp_int);
            temp_float = d_file->next_value("equ_catch_se").toFloat();
            flt->set_equ_catch_se(temp_float);
            temp_float = d_file->next_value("catch_se").toFloat();
            flt->set_catch_se(temp_float);
            temp_int = d_file->next_value("need_catch_mult").toInt();
            flt->set_catch_mult(temp_int);
            temp_str = d_file->next_value("fleet name");
            flt->set_name(temp_str);
            flt->setNumGenders(data->num_genders());
            flt->set_num_seasons(data->num_seasons());
            flt->setStartYear(data->start_year());
            flt->setTotalYears(data->totalYears());
        }
        n_fisheries = data->num_fisheries();
        n_surveys = data->num_surveys();
        data->assignFleetNumbers();

        do {
            float ctch, ctch_se;
            year   = d_file->next_value("year").toInt();
            season = d_file->next_value("season").toInt();
            fleet = d_file->next_value("fleet").toInt();
            ctch = d_file->next_value("catch").toFloat();
            ctch_se = d_file->next_value("catch_se").toFloat();
            if (year == -999)
                data->getFleet(fleet-1)->set_catch_equil(ctch);
            if (year != -9999)
                data->getFleet(fleet-1)->add_catch_per_season(year, season, ctch, ctch_se);
        } while (year != -9999);

        // CPUE Abundance
//        token = d_file->next_value("number abundance input lines");
//        num_input_lines = token.toInt();

        // before we record abundance, get units and error type for all fleets
        for (i = 0; i < total_fleets; i++)
        {
            Fleet *flt = data->getFleet(i);
            fleet = abs(d_file->next_value().toInt()); // fleet number
            if (fleet != (i + 1))
                d_file->error(QString("Fleet number does not match."));
            units = d_file->next_value().toInt(); // units
            flt->set_units(units);
            err_type = d_file->next_value().toInt(); // err_type
            flt->set_error_type(err_type);
        }
        // here are the abundance numbers
        do
        {    // year, month, fleet_number, observation, error
            year = d_file->next_value().toInt();
            month = d_file->next_value().toFloat();
            fleet = abs(d_file->next_value().toInt()) - 1;
            obs = d_file->next_value().toFloat();
            err = d_file->next_value().toFloat();
            if (year != -9999)
                data->getFleet(fleet)->addAbundByMonth(year, month, obs, err);
        } while (year != -9999);

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
                data->getFleet(fleet)->setDiscardMonth(year, season, obs, err);
            }
        }
        else
        {
            temp_int = d_file->next_value("num discard observations").toInt();
            if (temp_int != 0)
                d_file->error("Reading number discard observations.");
        }

        // mean body weight
        token = d_file->next_value();
        num_input_lines = token.toInt();
        if (num_input_lines != 0)
        {
            temp_int = d_file->next_value().toInt();
            for (i = 0; i < data->num_fleets(); i++)
                data->getFleet(i)->setMbwtDF(temp_int);
            for (i = 0; i < num_input_lines; i++)
            {
                str_lst.clear();
                for (int j = 0; j < 6; j++)
                    str_lst.append(d_file->next_value());
                fleet = abs(str_lst.takeAt(2).toInt()) - 1;
                data->getFleet(fleet)->addMbwtObservation(str_lst);
            }
        }

        // length data
        {
        compositionLength *l_data = data->get_length_composition();
        if (l_data == NULL)
            l_data = new compositionLength();
        data->set_length_composition(l_data);
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
        for (i = 0; i < total_fleets; i++)
        {
            data->getFleet(i)->setLengthMinTailComp(d_file->next_value());
            data->getFleet(i)->setLengthAddToData(d_file->next_value());
            temp_int = d_file->next_value().toInt();
            data->getFleet(i)->setLengthCombineGen(temp_int);
            temp_int = d_file->next_value().toInt();
            data->getFleet(i)->setLengthCompressBins(temp_int);
            temp_int = d_file->next_value().toInt();
            data->getFleet(i)->setLengthCompError(temp_int);
            temp_int = d_file->next_value().toInt();
            data->getFleet(i)->setLengthCompErrorParm(temp_int);
        }
        temp_int = d_file->next_value().toInt();//token.toInt();
        l_data->setNumberBins(temp_int);
        for (int j = 0; j < data->num_fleets(); j++)
            data->getFleet(j)->setLengthNumBins(temp_int);
        str_lst.clear();
        for (i = 0; i < temp_int; i++)
        {
            str_lst.append(d_file->next_value());
        }
        l_data->setBins(str_lst);
        if (l_data->getAltBinMethod() == 1) // set alt bins if method = 1
        {
            l_data->setNumberAltBins(l_data->getNumberBins());
            l_data->setAltBins(l_data->getBins());
        }

        obslength = data->getFleet(0)->getLengthObsLength() + 1;//l_data->get_obs_length();
        do
        {
            str_lst.clear();
            for (int j = 0; j < obslength; j++)
            {
                token = d_file->next_value();
                str_lst.append(token);
            }
            if (str_lst.at(0).toInt() == -9999)
                break;
            temp_int = abs(str_lst.takeAt(2).toInt());
            data->getFleet(temp_int - 1)->addLengthObservation(str_lst);// getLengthObs.addObservation(data);
        } while (str_lst.at(0).toInt() != -9999);
        data->set_length_composition(l_data);
        }

        // age data
        {
        compositionAge *a_data = data->get_age_composition();
        if (a_data == NULL)
            a_data = new compositionAge ();
        token = d_file->next_value();
        temp_int = token.toInt();
        a_data->setNumberBins(temp_int);
        for (i = 0; i < data->num_fleets(); i++)
        {
            data->getFleet(i)->setAgeNumBins(temp_int);
            data->getFleet(i)->setSaaNumBins(temp_int);
        }
        str_lst.clear();
        for (i = 0; i < temp_int; i++)
        {
            token = d_file->next_value();
            str_lst.append(token);
        }
        a_data->setBins(str_lst);
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
        for (i = 0; i < total_fleets; i++)
        {
            data->getFleet(i)->setAgeMinTailComp(d_file->next_value());
            data->getFleet(i)->setAgeAddToData(d_file->next_value());
            temp_int = d_file->next_value().toInt();
            data->getFleet(i)->setAgeCombineGen(temp_int);
            temp_int = d_file->next_value().toInt();
            data->getFleet(i)->setAgeCompressBins(temp_int);
            temp_int = d_file->next_value().toInt();
            data->getFleet(i)->setAgeCompError(temp_int);
            temp_int = d_file->next_value().toInt();
            data->getFleet(i)->setAgeCompErrorParm(temp_int);
        }

        token = d_file->next_value();
        a_data->setAltBinMethod(token.toInt());
        token = d_file->next_value();
        num_input_lines = token.toInt();
        obslength = data->getFleet(0)->getAgeObsLength() + 1;//a_data->get_obs_length();
        for (i = 0; i < num_input_lines; i++)
        {
            str_lst.clear();
            for (int j = 0; j < obslength; j++)
                str_lst.append(d_file->next_value());
            temp_int = abs(str_lst.takeAt(2).toInt());
            data->getFleet(temp_int - 1)->addAgeObservation(str_lst);
        }

        // mean size at age
        num_input_lines = d_file->next_value().toInt();
        obslength = data->getFleet(0)->getSaaObservation(0).count() + 1;//a_data->getSaaModel()->columnCount() + 1;
        for (i = 0; i < num_input_lines; i++)
        {
            str_lst.clear();
            for (j = 0; j < obslength; j++)
                str_lst.append(d_file->next_value());
            temp_int = abs(str_lst.takeAt(2).toInt());
            data->getFleet(temp_int - 1)->addSaaObservation(str_lst);
        }
        data->set_age_composition(a_data);
        }

        // environment variables
        temp_int = d_file->next_value().toInt();
        data->set_num_environ_vars (temp_int);
        num_input_lines = d_file->next_value().toInt();
        obslength = data->getEnvVariables()->columnCount();
        for (i = 0; i < num_input_lines; i++)
        {
            str_lst.clear();
            for(int j = 0; j < obslength; j++)
            {
                str_lst.append(d_file->next_value());
            }
            data->set_environ_var_obs (i, str_lst);
        }

        // generalized size composition
        num_vals = d_file->next_value().toInt();
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
                temp_str = d_file->next_value();//.toFloat();
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
                obslength = data->getFleet(0)->getGenObsLength(i) + 1;//cps->get_obs_length();
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
                    data->getFleet(fleet-1)->addGenObservation(temp_int-1, str_lst);
                    cps = data->general_comp_method(temp_int-1);
                }
            }
        }

        // tag-recapture data
        temp_int = d_file->next_value().toInt();
        data->set_do_tags(temp_int == 1);
        if (temp_int == 1)
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
                temp_int = abs(str_lst.takeAt(3).toInt());
                data->getFleet(temp_int - 1)->addRecapObservation(str_lst);
            }
        }

        // morph composition data
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
            temp_str = d_file->next_value();//.toFloat();
            for (int j = 0; j < data->num_fleets(); j++)
                data->getFleet(j)->setMorphMinTailComp(temp_str);
//            mcps->set_mincomp(temp_float);
            obslength = data->getFleet(0)->getMorphObsLength() + 1;//mcps->get_obs_length();
            for (i = 0; i < num_input_lines; i++)
            {
                str_lst.clear();
                for (int j = 0; j < obslength; j++)
                {
                    str_lst.append(d_file->next_value());
                }
                temp_int = abs(str_lst.takeAt(2).toInt());
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

int write33_dataFile(ss_file *d_file, ss_model *data)
{
    bool read_seasons = false;
    QString temp_str, line, index_str = QString("month");
    QStringList str_lst;
    int i, j, chars = 0;
    int num_years = 1 + data->end_year() - data->start_year();
    int start_yr = data->start_year();
    int end_yr = data->end_year();
    int temp_int = 0, num, num_lines;
    float temp_float = 0.0;
    int total_fleets = data->getNumActiveFleets();
    Fleet *flt;

    if(d_file->open(QIODevice::WriteOnly))
    {
        chars += write_version_comment(d_file);
        chars += d_file->write_comments();// (writeDatafileComment().toAscii());

        line = QString (QString ("#_observed data:" ));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_styr" ).arg
                        (QString::number(data->start_year())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_endyr" ).arg
                        (QString::number(data->end_year())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_nseas" ).arg
                        (QString::number(data->num_seasons())));
        chars += d_file->writeline (line);

        line.clear();
        for (i = 0; i < data->num_seasons(); i++)
            line.append (QString(" %1").arg
                         (QString::number(data->months_per_season(i))));
        line.append (" #_months/season" );
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_N_subseasons(even number, minimum is 2)" ).arg
                        (QString::number(data->get_num_subseasons())));
        chars += d_file->writeline (line);

        line = QString (QString ("%1 #_spawn_seas" ).arg
                            (QString::number(data->spawn_season())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_Ngenders" ).arg
                        (QString::number(data->num_genders())));
        chars += d_file->writeline (line);

        line = QString (QString ("%1 #_Nages=accumulator age" ).arg
                        (QString::number(data->num_ages())));
        chars += d_file->writeline (line);

        line = QString (QString ("%1 #_N_areas" ).arg
                        (QString::number(data->num_areas())));
        chars += d_file->writeline (line);
        line = QString (QString ("%1 #_Nfleets (including surveys)" ).arg
                        (QString::number(data->num_fleets())));
        chars += d_file->writeline (line);
        line = QString ("#_fleet_type: 1=catch fleet; 2=bycatch only fleet; 3=survey; 4=ignore " );
        chars += d_file->writeline (line);
        line = QString ("#_survey_timing: -1=for use of catch-at-age to override the month value associated with a datum " );
        chars += d_file->writeline (line);
        line = QString ("#_fleet_area:  area the fleet/survey operates in " );
        chars += d_file->writeline (line);
        line = QString ("#_units of catch:  1=bio; 2=num (ignored for surveys; their units read later)" );
        chars += d_file->writeline (line);
        line = QString ("#_equ_catch_se:  standard error of log(initial equilibrium catch)" );
        chars += d_file->writeline (line);
        line = QString ("#_catch_se:  standard error of log(catch); can be overridden in control file with detailed F input" );
        chars += d_file->writeline (line);
        line = QString ("#_rows are fleets" );
        chars += d_file->writeline (line);
        line = QString ("#_fleet_type, timing, area, units, equ_catch_se, catch_se, need_catch_mult fleetname" );
        chars += d_file->writeline (line);

        for (i = 1; i <= total_fleets; i++)
        {
            flt = data->getActiveFleet(i);
            line.clear();
            line.append(QString(" %1").arg(QString::number(flt->getTypeInt())));
            line.append(QString(" %1").arg(QString::number(flt->timing())));
            line.append(QString(" %1").arg(QString::number(flt->area())));
            line.append(QString(" %1").arg(QString::number(flt->catch_units())));
            line.append(QString(" %1").arg(QString::number(flt->equ_catch_se())));
            line.append(QString(" %1").arg(QString::number(flt->catch_se())));
            line.append(QString(" %1").arg(QString::number(flt->get_catch_mult())));
            line.append(QString(" %1").arg(flt->get_name()));

            line.append(QString("  # %1" ).arg(QString::number(i)));
            chars += d_file->writeline (line);
        }


        line = QString("#_Catch data: yr, seas, fleet, catch, catch_se" );
        chars += d_file->writeline (line);
        for (i = 1; i <= total_fleets; i++)
        {
            flt = data->getActiveFleet(i);
            if (flt->getTypeInt() < 3)
            {
                num_lines = flt->getCatchModel()->rowCount();
                for (int j = 0; j <= num_lines; j++)
                {
                    str_lst = flt->getCatchObservation(j);
                    if (str_lst.at(0).isEmpty())
                        break;
                    str_lst.insert(2, QString::number(i));
                    line.clear();
                    for (int k = 0; k < str_lst.count(); k++)
                    {
                        line.append(QString("%1 ").arg (str_lst.at(k)));
                    }
                    line.chop(1);

                    chars += d_file->writeline (line);
                }
            }
        }
        line = QString("-9999 0 0 0 0" );
        chars += d_file->writeline (line);
        chars += d_file->writeline ("#" );

        // CPUE Abundance
        line = QString (" #_CPUE_and_surveyabundance_observations" );
        chars += d_file->writeline(line);
        line = QString ("#_Units:  0=numbers; 1=biomass; 2=F; >=30 for special types" );
        chars += d_file->writeline(line);
        line = QString ("#_Errtype:  -1=normal; 0=lognormal; >0=T" );
        chars += d_file->writeline(line);
        line = QString ("#_Fleet Units Errtype" );
        chars += d_file->writeline(line);
        for (i = 1; i <= total_fleets; i++)
        {
            flt = data->getActiveFleet(i);
            line = QString(QString("%1 %2 %3 # %4" ).arg (
                   QString::number(i),
                   QString::number(flt->units()),
                   QString::number(flt->error_type()),
                   flt->get_name()));
            chars += d_file->writeline (line);
        }

        line = QString("#_year month fleet obs stderr" );
        chars += d_file->writeline (line);
        for (i = 1; i <= total_fleets; i++)//data->num_fisheries();i < data->num_fleets(); i++)
        {
            flt = data->getActiveFleet(i);
            int num_lines = flt->getAbundanceCount();
            for (int j = 0; j < num_lines; j++)
            {
                QStringList abund (flt->getAbundanceObs(j));
                if (!abund.at(0).isEmpty())
                {
                    if (abund.at(1).isEmpty()) abund[1].append("1");

                    if (abund.at(2).isEmpty()) abund[2].append("0");
                    if (abund.at(3).isEmpty()) abund[3].append("0");
                    line = QString (QString(" %1 %2 %3 %4 %5 #_ %6" ).arg (
                                        abund.at(0), abund.at(1),
                                        QString::number(i),
                                        abund.at(2), abund.at(3),
                                        flt->get_name()));
                    chars += d_file->writeline (line);
                }
            }
        }
        line = QString("-9999 1 1 1 1 # terminator for survey observations " );
        chars += d_file->writeline (line);

        chars += d_file->writeline ("#" );

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
        for (i = 1; i <= total_fleets; i++)
        {
            flt = data->getActiveFleet(i);
            if (flt->getDiscardCount() > 0)
            {
                line = QString(QString("%1 %2 %3" ).arg(
                            QString::number(i),
                            QString::number(flt->discard_units()),
                            QString::number(flt->discard_err_type())));
                chars += d_file->writeline (line);
            }
        }

        temp_int = data->fleet_discard_obs_count();
        line = QString(QString("%1 #N discard obs" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        line = QString("#_year month fleet obs stderr" );
        chars += d_file->writeline (line);
        for (i = 1; i <= total_fleets; i++)
        {
            flt = data->getActiveFleet(i);
            for (int j = 0; j < flt->getDiscardCount(); j++)
            {
                line.clear();
                str_lst = flt->getDiscard(j);
                for (int m = 0; m < str_lst.count(); m++)
                    line.append(QString(" %1").arg(str_lst.at(m)));
                chars += d_file->writeline (line);
            }
        }

        chars += d_file->writeline ("#" );

        // mean body weight
        temp_int = 0;
        for (i = 1; i <= total_fleets; i++) // for (i = 0; i < data->num_fleets(); i++)
            temp_int += data->getActiveFleet(i)->getMbwtNumObs();
        line = QString (QString("%1 #_N_meanbodywt_obs" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        if (temp_int == 0)
        {
            line = QString("#_COND 0 ");
        }
        else
        {
            temp_int = data->getFleet(0)->getMbwtDF();
            line = QString (QString("%1 ").arg(QString::number(temp_int)));
        }
        line.append("#_DF_for_meanbodywt_T-distribution_like" );
        chars += d_file->writeline (line);
        line = QString ("#_year month fleet part obs stderr" );
        chars += d_file->writeline (line);
        for (i = 1; i <= total_fleets; i++) // (i = 0; i < data->num_fleets(); i++)
        {
            flt = data->getActiveFleet(i);
            num = flt->getMbwtNumObs();
            for (int j = 0; j < num; j++)
            {
                line.clear();
                str_lst = flt->getMbwtObservation(j);
                for (int m = 0; m < str_lst.count(); m++)
                    line.append(QString(" %1").arg(str_lst.at(m)));

                chars += d_file->writeline (line);
            }
        }
        chars += d_file->writeline ("#" );


        // length composition
        {
        compositionLength *l_data = data->get_length_composition();
        line = QString (QString("%1 # length bin method: 1=use databins; 2=generate from binwidth,min,max below; 3=read vector " ).arg(
                            QString::number(l_data->getAltBinMethod())));
        chars += d_file->writeline (line);
        switch (l_data->getAltBinMethod())
        {
        case 1:
            line = QString("# no additional input required." );
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
            line = QString("# vector of population bin edges." );
            chars += d_file->writeline (line);
            line.clear();
            str_lst = l_data->getAltBins();
            for (int j = 0; j < str_lst.count(); j++)
                line.append(QString(" %1").arg(str_lst.at(j)));

            chars += d_file->writeline (line);
            break;
        }

        line = QString("#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level." );
        chars += d_file->writeline (line);
        line = QString("#_addtocomp:  after accumulation of tails; this value added to all bins" );
        chars += d_file->writeline (line);
        line = QString("#_males and females treated as combined gender below this bin number " );
        chars += d_file->writeline (line);
        line = QString("#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation" );
        chars += d_file->writeline (line);
        line = QString("#_Comp_Error:  0=multinomial, 1=dirichlet" );
        chars += d_file->writeline (line);
        line = QString("#_Comp_Error2:  parm number  for dirichlet" );
        chars += d_file->writeline (line);
        line = QString("#_mintailcomp_addtocomp_combM+F_CompressBins_CompError_ParmSelect" );
        chars += d_file->writeline (line);
//        int fleetNum = 1;
        for (i = 1; i <= total_fleets; i++) // for (i = 0; i < data->num_fleets(); i++)
        {
            flt = data->getActiveFleet(i);
            line.clear();
            line.append(QString("%1 ").arg((flt->getLengthMinTailComp())));
            line.append(QString("%1 ").arg((flt->getLengthAddToData())));
            line.append(QString("%1 ").arg(QString::number(flt->getLengthCombineGen())));
            line.append(QString("%1 ").arg(QString::number(flt->getLengthCompressBins())));
            line.append(QString("%1 ").arg(QString::number(flt->getLengthCompError())));
            line.append(QString("%1 ").arg(QString::number(flt->getLengthCompErrorParm())));
            line.append(QString("#_fleet:%1_%2" ).arg(QString::number(i), flt->get_name()));
            chars += d_file->writeline (line);
        }

        temp_int = l_data->getNumberBins();
        line = QString(QString("%1 #_N_length_bins" ).arg(QString::number(temp_int)));
        chars += d_file->writeline (line);
        line.clear();
        str_lst = l_data->getBinsModel()->getRowData(0);
        for (i = 0; i < str_lst.count(); i++)
        {
            line.append(QString(" %1").arg(str_lst.at(i)));
        }

        chars += d_file->writeline (line);

        line = QString ("#Yr Month Fleet Gender Part Nsamp datavector(female-male)" );
        chars += d_file->writeline (line);
//        for (int type = Fleet::Fishing; type < Fleet::None; type++)
        for (i = 1; i <= total_fleets; i++) // for (i = 0; i < data->num_fleets(); i++)
        {
            flt = data->getActiveFleet(i);
            num = flt->getLengthNumObs();
            for( int j = 0; j < num; j++)
            {
                str_lst = flt->getLengthObservation(j);
                str_lst.insert(2, QString::number(i));
                line.clear();
                for (int j = 0; j < str_lst.count(); j++)
                    line.append(QString (" %1").arg(str_lst.at(j)));

                chars += d_file->writeline (line);
            }
        }
        line = QString("-9999");
        for (int j = 1; j < str_lst.count(); j++)
            line.append(QString(" %1").arg (QString::number(0)));

        chars += d_file->writeline (line);
        chars += d_file->writeline ("#" );
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

            chars += d_file->writeline (line);
            line.clear();
            str_lst = a_data->get_error_def(i);
            for (int j = 0; j < str_lst.count(); j++)
                line.append(QString(" %1").arg(str_lst.at(j)));

            chars += d_file->writeline (line);
//            write_error_vector(a_data->error_def(i));
        }
        line = QString("#_mintailcomp: upper and lower distribution for females and males separately are accumulated until exceeding this level." );
        chars += d_file->writeline (line);
        line = QString("#_addtocomp:  after accumulation of tails; this value added to all bins" );
        chars += d_file->writeline (line);
        line = QString("#_males and females treated as combined gender below this bin number " );
        chars += d_file->writeline (line);
        line = QString("#_compressbins: accumulate upper tail by this number of bins; acts simultaneous with mintailcomp; set=0 for no forced accumulation" );
        chars += d_file->writeline (line);
        line = QString("#_Comp_Error:  0=multinomial, 1=dirichlet" );
        chars += d_file->writeline (line);
        line = QString("#_Comp_Error2:  parm number  for dirichlet" );
        chars += d_file->writeline (line);
        line = QString("#_mintailcomp_addtocomp_combM+F_CompressBins_CompError_ParmSelect" );
        chars += d_file->writeline (line);
        for (i = 1; i <= total_fleets; i++) // for (i = 0; i < data->num_fleets(); i++)
        {
            flt = data->getActiveFleet(i);
            line = QString(QString("%1 %2 %3 %4 %5 %6 # fleet:%7_%8" ).arg (
                               flt->getAgeMinTailComp(),
                               flt->getAgeAddToData(),
                               QString::number(flt->getAgeCombineGen()),
                               QString::number(flt->getAgeCompressBins()),
                               QString::number(flt->getAgeCompError()),
                               QString::number(flt->getAgeCompErrorParm()),
                               QString::number(i),
                               flt->get_name()));
            chars += d_file->writeline (line);
        }
        temp_int = a_data->getAltBinMethod();
        line = QString(QString("%1 #_Lbin_method_for_Age_Data: 1=poplenbins; 2=datalenbins; 3=lengths" ).arg(
                           QString::number(temp_int)));
        chars += d_file->writeline (line);

        temp_int = 0;
        for (i = 1; i <= total_fleets; i++) // for (i = 0; i < data->num_fleets(); i++)
        {
            temp_int += data->getActiveFleet(i)->getAgeNumObs();
        }
        line = QString ("%1 #_N_Agecomp_obs" ).arg(QString::number(temp_int));
        chars += d_file->writeline (line);

        line = QString ("#Yr Month Fleet Gender Part Ageerr Lbin_lo Lbin_hi Nsamp datavector(female-male)" );
        chars += d_file->writeline (line);
//        for (int type = Fleet::Fishing; type < Fleet::None; type++)
        for (i = 1; i <= total_fleets; i++) // for (i = 0; i < data->num_fleets(); i++)
        {
            flt = data->getActiveFleet(i);
//            if (data->getFleet(i)->isActive() &&
//                    data->getFleet(i)->getType() == (Fleet::FleetType)type)
            {
                temp_int = flt->getAgeNumObs();
                for( int j = 0; j < temp_int; j++)
                {
                    str_lst = flt->getAgeObservation(j);
                    str_lst.insert(2, QString::number(i));
                    line.clear();
                    for (int j = 0; j < str_lst.count(); j++)
                        line.append(QString (" %1").arg(str_lst.at(j)));

                    chars += d_file->writeline (line);
                }
            }
        }
        chars += d_file->writeline ("#" );

        // mean size at age
        num = 0;
        for (i = 1; i <= total_fleets; i++) // for (i =0; i < data->num_fleets(); i++)
        {
//            if (data->getFleet(i)->isActive())
                num += data->getActiveFleet(i)->getSaaModel()->rowCount();
        }
        line = QString ("%1 #_N_MeanSize-at-Age_obs" ).arg (
                    QString::number(num));
        chars += d_file->writeline (line);
        line = QString ("#Yr Month Fleet Gender Part Ageerr Ignore datavector(female-male)" );
        line.append    ("#                                          samplesize(female-male)" );
        chars += d_file->writeline (line);
        for (i = 1; i <= total_fleets; i++) // for (i = 0; i < data->num_fleets(); i++)
        {
            flt = data->getActiveFleet(i);
//            if (data->getFleet(i)->isActive())
            {
                for (int j = 0; j < flt->getSaaNumObs(); j++)
                {
                    line.clear();
                    str_lst = flt->getSaaModel()->getRowData(j);
                    str_lst.insert(2, QString::number(i));
                    for (int m = 0; m < str_lst.count(); m++)
                        line.append(QString(" %1").arg(str_lst.at(m)));

                    chars += d_file->writeline (line);
                }
            }
        }
        chars += d_file->writeline ("#" );
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
        chars += d_file->writeline ("#" );

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
                line.append(QString("%1 ").arg(temp_str));
            }
            line.append("#_nbins_per_method" );
            chars += d_file->writeline (line);
            line.clear();
            for (i = 0; i < num; i++)
            {
                temp_str = QString::number(data->general_comp_method(i)->getUnits());
                line.append(QString("%1 ").arg(temp_str));
            }
            line.append("#_units_per_each_method (1=biomass, 2=numbers)" );
            chars += d_file->writeline (line);
            line.clear();
            for (i = 0; i < num; i++)
            {
                temp_str = QString::number(data->general_comp_method(i)->getScale());
                line.append(QString("%1 ").arg(temp_str));
            }
            line.append("#_scale_per_each_method (1=kg, 2=lbs, 3=cm, 4=in)" );
            chars += d_file->writeline (line);
            line.clear();
            for (i = 0; i < num; i++)
            {
                temp_str = data->getActiveFleet(1)->getGenMinTailComp(i);//QString::number(general_comp_method(i)->mincomp());
                line.append(QString("%1 ").arg(temp_str));
            }
            line.append("#_mincomp_to_add_to_each_obs (entry for each method)" );
            chars += d_file->writeline (line);
            line.clear();
            for (i = 0; i < num; i++)
            {
                temp_int = 0;
                for (j = 1; j <= total_fleets; j++) // for (int j = 0; j < data->num_fleets(); j++)
                {
                    flt = data->getActiveFleet(j);
//                    if (data->getFleet(j)->isActive())
                    {
                        temp_int += flt->getGenNumObs(i);
                    }
                }
                line.append(QString("%1 ").arg(QString::number(temp_int)));
            }
            line.append("#_N_observations (entry for each method)" );
            chars += d_file->writeline (line);
            line = QString("#_lower edge of bins for each method" );
            chars += d_file->writeline (line);
            for (i = 0; i < num; i++)
            {
                line.clear();
                str_lst = data->general_comp_method(i)->getBinsModel()->getRowData(0);
                for (int j = 0; j < str_lst.count(); j++)
                    line.append(QString (" %1").arg (str_lst.at(j)));

                chars += d_file->writeline (line);
            }
            line = QString ("#Method Yr Month Flt Gender Part Nsamp datavector(female-male)" );
            chars += d_file->writeline (line);
            for (i = 0; i < num; i++)
            {
                for (j = 1; j <= total_fleets; j++) // for (int j = 0; j < data->num_fleets(); j++)
                {
                    flt = data->getActiveFleet(j);
//                    if (data->getFleet(j)->isActive())
                    {
                        num_lines = flt->getGenNumObs(i);
                        for (int k = 0; k < num_lines; k++)
                        {
                            line.clear();
                            str_lst = flt->getGenObservation(i, k);
                            str_lst.insert(2, QString::number(j));
                            for (int m = 0; m < str_lst.count(); m++)
                                line.append(QString (" %1").arg(str_lst.at(m)));

                            chars += d_file->writeline (line);
                        }
                    }
                }
            }
        }
        chars += d_file->writeline ("#" );

        // tag recapture
        if (data->get_do_tags())
        {
            line = QString (QString("%1 # Do_tags" ).arg(QString("1")));
            chars += d_file->writeline (line);
            num = data->get_num_tag_groups();
            line = QString (QString("%1 # N_tag_groups" ).arg(QString::number(num)));
            chars += d_file->writeline (line);
            temp_int = 0;
            for (i = 1; i <= total_fleets; i++) // for (i = 0; i < data->num_fleets(); i++)
            {
//                if (data->getFleet(i)->isActive())
                    temp_int += data->getActiveFleet(i)->getRecapNumEvents();
            }
            line = QString (QString("%1 # N_recapture_events").arg(QString::number(temp_int)));
            chars += d_file->writeline (line);
            temp_int = data->get_tag_latency();
            line = QString (QString("%1 # Mixing_latency_period").arg(QString::number(temp_int)));
            chars += d_file->writeline (line);
            temp_int = data->get_tag_max_periods();
            line = QString (QString("%1 # Max_periods").arg(QString::number(temp_int)));
            chars += d_file->writeline (line);
            line = QString (QString("#Release_Data"));
            chars += d_file->writeline (line);
            line = QString (QString("#TG area yr month <tfill> gender age Nrelease"));
            chars += d_file->writeline (line);
            for (i = 0; i < num; i++)
            {
                line.clear();
                str_lst = data->get_tag_observation(i);
                for (int j = 0; j < str_lst.count(); j++)
                    line.append(QString(" %1").arg(str_lst.at(j)));
                chars += d_file->writeline (line);
            }
            line = QString("#Recapture_Data");
            chars += d_file->writeline (line);
            line = QString("#TG year month fleet Number");
            chars += d_file->writeline (line);
            for (i = 0; i < num; i++)
            {
                for (j = 1; j <= total_fleets; j++) // for (int j = 0; j < data->num_fleets(); j++)
                {
                    flt = data->getActiveFleet(j);
//                    if (data->getFleet(j)->isActive())
                    {
                        num_lines = flt->getRecapNumEvents();
                        for (int k = 0; k < num_lines; k++)
                        {
                            line.clear();
                            str_lst = flt->getRecapObservation(k);
                            str_lst.insert(3, QString::number(j));
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
            line = QString (QString("%1 # no tag groups" ).arg(QString("0")));
            chars += d_file->writeline (line);
        }
        chars += d_file->writeline ("#" );

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
            temp_str = data->getFleet(0)->getMorphMinTailComp();//get_morph_composition()->mincomp();
            line = QString (QString("%1 # Mincomp" ).arg(temp_str));//QString::number(temp_float)));
            chars += d_file->writeline (line);
            temp_int = data->get_tag_latency();
            line = QString("#Year month fleet partition Nsamp data_vector" );
            chars += d_file->writeline (line);
            for (i = 1; i <= total_fleets; i++) // for (num = 0; num < data->num_fleets(); num++)
            {
                flt = data->getActiveFleet(i);
//                if (data->fleets.at(num)->isActive())
                {
                    num_lines = flt->getMorphNumObs();
                    for (int j = 0; j < num_lines; j++)
                    {
                        line.clear();
                        str_lst = flt->getMorphObservation(j);
                        str_lst.insert(2, QString::number(i));
                        for (int k = 0; k < str_lst.count(); k++)
                            line.append(QString(" %1").arg(str_lst.at(k)));
                        chars += d_file->writeline (line);
                    }
                }
            }
        }
        else
        {
            line = QString (QString("%1 # no morph composition" ).arg(QString::number(0)));
            chars += d_file->writeline (line);
        }
        chars += d_file->writeline ("#" );
        d_file->newline();

        //end of data
        line = QString (QString("%1" ).arg (QString::number(END_OF_DATA)));
        chars += d_file->writeline (line);
        d_file->newline();
        chars += d_file->writeline ("ENDDATA" );


        d_file->close();
    }
}

bool read33_forecastFile(ss_file *f_file, ss_model *data)
{
    QString token;
    QString temp_str;
    QStringList str_lst(" ");
    float temp_float;
    int temp_int = 0;
    int i, num;

    if(f_file->open(QIODevice::ReadOnly))
    {
        ss_forecast *fcast = data->forecast;
        f_file->seek(0);
        f_file->read_comments();

        fcast->set_num_seasons(data->num_seasons());
        fcast->set_num_fleets(data->num_fleets());
        fcast->set_num_genders(data->num_genders());

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
        token = f_file->next_value("bmark rel f basis");
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
        token = f_file->next_value("control rule biomass F const");
        temp_float = token.toFloat();
        fcast->set_cr_biomass_const_f(temp_float);
        token = f_file->next_value("control rule biomass F 0");
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
        }

        for (i = 0; i < fcast->num_areas(); i++)
        {
            token = f_file->next_value("max catch by area");
            temp_int = token.toInt();
            fcast->set_max_catch_area(i, temp_int);
        }

        fcast->set_num_alloc_groups(0);
        for (i = 0; i < fcast->num_fleets(); i++)
        {
            token = f_file->next_value("alloc group assignment");
            temp_int = token.toInt();
            fcast->set_alloc_group(i, temp_int);
        }

        for (int j = 0; j < fcast->num_forecast_years(); j++)
        {
            str_lst.clear();
        for (i = 0; i < fcast->num_alloc_groups(); i++)
        {
            token = f_file->next_value("alloc group fraction");
            str_lst.append(token);
            fcast->set_alloc_fractions(j, str_lst);
        }
        }


        token = f_file->next_value("input catch basis");
        temp_int = token.toInt();
        fcast->set_input_catch_basis(temp_int);

        do
        {
            str_lst.clear();
            token = f_file->next_value();
            temp_int = token.toInt();
            str_lst.append(token);                // Year
            str_lst.append(f_file->next_value()); // Season
            str_lst.append(f_file->next_value()); // Fleet
            str_lst.append(f_file->next_value()); // Catch
            if (temp_int != -9999)
                fcast->add_fixed_catch_value(str_lst);

        } while (temp_int != -9999);

        token = f_file->next_value();
        temp_int = token.toInt();
        if (temp_int != END_OF_DATA)
        {
            if (f_file->atEnd())
            {
                f_file->error(QString("No end of data marker!"));
            }
            else
            {
                f_file->error(QString("Stopped reading before end of data marker!"));
            }
        }

        f_file->close();
    }
    else
    {
        f_file->error(QString("File is not readable."));
    }
    return 1;
}

int write33_forecastFile(ss_file *f_file, ss_model *data)
{
    int num, i, chars = 0;
    int yr, j;
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
        line = QString(QString ("%1 # Benchmarks: 0=skip; 1=calc F_spr,F_btgt,F_msy " ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->MSY());
        line = QString(QString ("%1 # MSY: 1=set to F(SPR); 2=calc F(MSY); 3=set to F(Btgt); 4=set to F(endyr) " ).arg (value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->spr_target());
        line = QString(QString("%1 # SPR target (e.g. 0.40)" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->biomass_target());
        line = QString(QString("%1 # Biomass target (e.g. 0.40)" ).arg(value));
        chars += f_file->writeline(line);

        line = QString("#_Bmark_years: beg_bio, end_bio, beg_selex, end_selex, beg_relF, end_relF");
        temp_string = QString ("# ");
        line.append(QString("enter actual year, or values of 0 or -integer to be rel. endyr)" ));
        chars += f_file->writeline(line);
        line.clear();
        for (i = 0; i < 6; i++)
        {
            value = QString::number(fcast->benchmark_year(i));
            line.append(QString(QString(" %1").arg(value)));
            if (fcast->benchmark_year(i) <= 0)
                temp_string.append(QString(" %1").arg(QString::number(data->end_year() + fcast->benchmark_year(i))));
            else
                temp_string.append(QString(" %1").arg(value));
        }
        chars += f_file->writeline(line);
        temp_string.append(" # after processing " );
        chars += f_file->writeline(temp_string.toAscii());

        value = QString::number(fcast->benchmark_rel_f());
        line = QString(QString("%1 #_Bmark_relF_Basis: 1 = use year range; 2 = set relF same as forecast below" ).arg(value));
        chars += f_file->writeline(line);

        chars += f_file->writeline("#" );

        value = QString::number(fcast->forecast());
        line = QString(QString("%1 # Forecast: 0=none; 1=F(SPR); 2=F(MSY) 3=F(Btgt); 4=Ave F (uses first-last relF yrs); 5=input annual F scalar" ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->num_forecast_years());
        line = QString(QString("%1 # N forecast years " ).arg(value));
        chars += f_file->writeline(line);

        value = QString::number(fcast->f_scalar());
        line = QString(QString("%1 # F scalar (only used for Do_Forecast==5)" ).arg(value));
        chars += f_file->writeline(line);

        line = QString("#_Fcast_years:  beg_selex, end_selex, beg_relF, end_relF  (enter actual year, or values of 0 or -integer to be rel. endyr)" );
        chars += f_file->writeline(line);
        line.clear();
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
        temp_string.append(" # after processing " );
        chars += f_file->writeline(temp_string.toAscii());

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
        for (i = 1; i <= data->getNumActiveFleets(); i++) // for (i = 0; i < data->num_fleets(); i++)
        {
            line.append(QString(" %1").arg (data->getActiveFleet(i)->get_name()));
        }
        chars += f_file->writeline(line);
        if (fcast->fleet_rel_f() == 2)
        {
            temp_string = QString("");
            for (int seas = 0; seas < data->num_seasons(); seas++)
            {
                for (i = 0; i < data->num_fleets(); i++)
                {
                    if (data->getFleet(i)->isActive())
                    temp_string.append(QString(" %1").arg (
                                       QString::number(fcast->seas_fleet_rel_f(seas, i))));
                }

                chars += f_file->writeline(temp_string);
            }
        }
        else
        {
            temp_string = QString("# ");
            for (i = 0; i < data->num_fleets(); i++)
            {
                if (data->getFleet(i)->isActive())
                temp_string.append(" 0");
            }
            chars += f_file->writeline(temp_string);
        }
        temp_string.clear();

        line = QString("# max totalcatch by fleet (-1 to have no max) must enter value for each fleet" );
        chars += f_file->writeline(line);
        line.clear();
            for (i = 0; i < fcast->num_fleets(); i++)
            {
                if (data->getFleet(i)->isActive())
                {
                    value = QString::number(fcast->max_catch_fleet(i));
                    line.append(QString(" %1").arg(value));
                }
            }
        chars += f_file->writeline(line);

        line = QString("# max totalcatch by area (-1 to have no max); must enter value for each area" );
        chars += f_file->writeline(line);
        line.clear();
        for (i = 0; i < fcast->num_areas(); i++)
        {
            value = QString::number(fcast->max_catch_area(i));
            line.append(QString(" %1").arg(value));
        }
        chars += f_file->writeline(line);

        // allocation groups
        line = QString("# fleet assignment to allocation group (enter group ID# for each fleet, 0 for not included in an alloc group)" );
        chars += f_file->writeline(line);
        line.clear();
        for (i = 0; i < fcast->num_fleets(); i++)
        {
            if (data->getFleet(i)->isActive())
            {
                value = QString::number(fcast->alloc_group(i));
                line.append(QString(" %1").arg(value));
            }
        }
        chars += f_file->writeline(line);

        temp_string = QString::number(fcast->num_alloc_groups());
        line = QString("# SS's count of the number of unique allocation group IDs: ");
        line.append(QString("%1" ).arg(temp_string));
        chars += f_file->writeline(line);
        line = QString("#_if N allocation groups > 0, list year, allocation fraction for each group " );
        chars += f_file->writeline(line);
        line = QString("# list sequentially because read values fill to end of N forecast" );
        chars += f_file->writeline(line);
        line = QString("# terminate with -9999 in year field" );
        chars += f_file->writeline(line);
        line.clear();
        if (fcast->num_alloc_groups() > 1)
        {
            line = QString(QString("#Yr alloc frac for each of: %1 alloc grps").arg(temp_string));
            for (yr = 0; yr < fcast->num_forecast_years(); yr++)
            {
                line = QString::number(yr);
                str_lst = fcast->get_alloc_fractions(yr);
                for (i = 0; i < str_lst.count(); i++)
                {
                    line.append(QString(QString(" %1").arg(str_lst.at(i))));
                }
                chars += f_file->writeline(line);
             }
         }
        else
        {
            line = QString ("# no allocation groups" );
            chars += f_file->writeline(line);
        }

//        num = fcast->num_catch_levels();
//        value = QString::number(num);
//        line = QString(QString("%1 # Number of forecast catch levels to input (else calc catch from forecast F)" ).arg(value));
//        chars += f_file->writeline(line);
        value = QString::number(fcast->input_catch_basis());
        line = QString(QString("%1 # basis for input Fcast catch: -1=read basis with each obs; 2=dead catch; 3=retained catch; 99=input Hrate(F)" ).arg(value));
        chars += f_file->writeline(line);
        line = QString("#enter list of Fcast catches; terminate with line having year=-9999" );
        chars += f_file->writeline(line);
        line = QString("#_Year Seas Fleet Catch(or_F)" );
        chars += f_file->writeline(line);
        num = fcast->num_catch_values();
        for (i = 0; i < num; i++)
        {
            QStringList obs = fcast->fixed_catch_value(i);
            line.clear();
            for (int j = 0; j < obs.count(); j++)
                line.append(QString(" %1").arg(obs.at(j)));
            chars += f_file->writeline(line);
        }
        line = QString("-9999 1 1 0 " );
        chars += f_file->writeline(line);

        f_file->writeline("#" );

        line = QString(QString("%1 # verify end of input " ).arg (
                           QString::number(END_OF_DATA)));
        chars += f_file->writeline(line);


        f_file->close();
    }
}

bool read33_controlFile(ss_file *c_file, ss_model *data)
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

        // recruitment designs
        temp_int = c_file->next_value().toInt(); // recruitment distribution
        pop->SR()->setDistribMethod(temp_int);
        temp_int = c_file->next_value().toInt(); // recruitment area
        pop->SR()->setDistribArea(temp_int);
        num = c_file->next_value().toInt(); // num recr assignments
        pop->SR()->setNumAssignments(num);
        pop->SR()->setDoRecruitInteract(0);
        if (pop->SR()->getDistribMethod() == 1)
        {
            temp_int = c_file->next_value().toInt();
            pop->SR()->setDoRecruitInteract(temp_int);
        }
        for (i = 0; i < num; i++) // gr pat, month, area for each assignment
        {
            datalist.clear();
            for (int j = 0; j < 3; j++)
                datalist.append(c_file->next_value());
            pop->SR()->setAssignment(i, datalist);
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
            num_vals = 1;  // 1 parameter only
            break;
        case 1:
            num_vals = c_file->next_value().toInt(); // num breakpoints
            pop->Grow()->setNatMortNumBreakPts(num_vals);
 //           num = pop->Grow()->getNatMortNumBreakPts();
            datalist.clear();
            for (int i = 0; i < num_vals; i++) // vector of breakpoints
                datalist.append(c_file->next_value());
            pop->Grow()->setNatMortBreakPts(datalist);
            num_vals = data->num_genders(); // read 1 param for each gender for each GP
            break;
        case 2:
            temp_int = c_file->next_value().toInt(); // ref age for Lorenzen
            pop->Grow()->setNaturnalMortLorenzenRef(temp_int);
            num_vals = data->num_genders(); // read 1 param for each gender for each GP
            break;
        case 3:
        case 4:
            // age-specific M values by sex by growth pattern
            num_vals = pop->Grow()->getNum_patterns();
            num = data->num_genders();
            if (num > 2) num = 2;
            datalist.clear();
            for (int i = 0; i < num; i++) // first female, then male
            {
                for (int j = 0; j < num_vals; j++)
                {
                    datalist.append(c_file->next_value());
                }
            }
//            pop->Grow()->setNatMortNumAges(datalist.count());
            pop->Grow()->setNatMortAges(datalist);
            num_vals = 0; // read no additional parameters
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
            num = data->get_age_composition()->getNumber(); // num_ages() + 1;
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

                datalist = readParameter(c_file); // male_wt_len_1
                pop->Grow()->addMaturityParam(datalist);
                datalist = readParameter(c_file); // male_wt_len_2
                pop->Grow()->addMaturityParam(datalist);
            }
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
        num = 0;
        pop->M()->setNumFisheries(data->num_fisheries());
        for (i = 0; i < num_fleets; i++)
        {
            if (data->getFleet(i)->catch_equil() != 0)
                num++;
        }
        pop->M()->fromFile(c_file, num);

        // Q setup
        for (int i = 0; i < data->num_fleets(); i++)
        {
            datalist.clear();
            for (int j = 0; j < 5; j++)
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

        // #_Variance_adjustments_to_input_value
        temp_int = c_file->next_value().toInt();
        data->setInputValueVariance(0);
        while (temp_int != -9999)
        {
            data->setInputValueVariance(1);
            int flt = c_file->next_value().toInt();
            temp_float = c_file->next_value().toFloat();
            switch (temp_int)
            {
            case 1:
                data->getFleet(flt)->setAddToSurveyCV(temp_float);
                break;
            case 2:
                data->getFleet(flt)->setAddToDiscardSD(temp_float);
                break;
            case 3:
                data->getFleet(flt)->setAddToBodyWtCV(temp_float);
                break;
            case 4:
                data->getFleet(flt)->setMultByLenCompN(temp_float);
                break;
            case 5:
                data->getFleet(flt)->setMultByAgeCompN(temp_float);
                break;
            case 6:
                data->getFleet(flt)->setMultBySAA(temp_float);
                break;
            case 7:
            default:
                break;
            }
        }
        c_file->next_value();
        c_file->next_value();


        // Max lambda phase
        temp_int = c_file->next_value().toInt();
        data->setLambdaMaxPhase(temp_int);

        // sd offset
        temp_int = c_file->next_value().toInt();
        data->setLambdaSdOffset(temp_int);

        // lambda changes
        // component, fleet, phase, value, sizefreq method
        do
        {
            int flt = 1;
            datalist.clear();
            datalist.append(c_file->next_value());
            flt = abs(c_file->next_value().toInt());
            datalist.append(c_file->next_value());
            datalist.append(c_file->next_value());
            datalist.append(c_file->next_value());
            if (datalist.at(0).compare("-9999") != 0)
                data->getFleet(flt-1)->appendLambda(datalist);
        } while (datalist.at(0).compare("-9999") != 0);

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

int write33_controlFile(ss_file *c_file, ss_model *data)
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

        line.append(QString("#_N_platoons_Within_Growth_Pattern" ));
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
        temp_int = pop->SR()->getDistribMethod();
        line = QString (QString("%1 # recr_dist_method for parameters:").arg(QString::number(temp_int)));
        line.append(QString(" 1=like 3.24; 2=main effects for GP, Settle timing, Area; 3=each Settle entity; 4=none when N_GP*Nsettle*pop==1" ));
        chars += c_file->writeline(line);
        temp_int = pop->SR()->getDistribArea();
        line = QString (QString("%1 # Recruitment: 1=global; 2=by area" ).arg(QString::number(temp_int)));
        chars += c_file->writeline(line);
        num = pop->SR()->getNumAssignments();
        line = QString (QString("%1 #  number of recruitment settlement assignments " ).arg(QString::number(num)));
        chars += c_file->writeline(line);
        if (pop->SR()->getDistribMethod() == 1)
        {
            temp_int = pop->SR()->getDoRecruitInteract()? 1: 0;
            line = QString (QString("%1 ").arg(QString::number(temp_int)));
        }
        else
        {
            line = QString ("#_COND1 ");
        }
        line.append(QString("# year_x_area_x_settlement_event interaction requested (only for recr_dist_method=1)" ));
        chars += c_file->writeline(line);
        line = QString ("#GPat month area (for each settlement assignment)" );
        chars += c_file->writeline(line);
        for (int i = 0; i < num; i++)
        {
            line.clear();
            str_list = pop->SR()->getAssignment(i);
            for (int j = 0; j < 3; j++)
                line.append(QString(" %1").arg(str_list.at(j)));

            chars += c_file->writeline(line);
        }
        chars += c_file->writeline("#" );

        // movement definitions
        line.clear();
        if (data->num_areas() > 1)
        {
            num = pop->Move()->getNumDefs();
            line = QString(QString("%1 # N_movement_definitions").arg(
                            QString::number(num)));
            chars += c_file->writeline(line);
            temp_float = pop->Move()->getFirstAge();
            line = QString(QString("%1 # first age that moves (real age at begin of season, not integer)").
                           arg(QString::number(temp_float)));
            chars += c_file->writeline(line);
            line = QString("# seas, GP, source_area, dest_area, minage, maxage");
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
            line = QString("#_Cond 0 # N_movement_definitions goes here if N_areas > 1" );
            chars += c_file->writeline(line);
            line = QString("#_Cond 1.0 # first age that moves (real age at begin of season, not integer) also cond on do_migration>0" );
            chars += c_file->writeline(line);
            line = QString("#_Cond 1 1 1 2 4 10 # example move definition for seas=1, morph=1, source=1 dest=2, age1=4, age2=10" );
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
            str_list = pop->Grow()->getNatMortAges();
            num_vals = pop->Grow()->getNum_patterns();
            for (i = 0; i < num_vals; i++)
            {
                line.append(QString(" %1 # F_GP%1" ).arg(str_list.at(i), QString::number(j+1)));
                chars += c_file->writeline(line);
            }
            if (data->num_genders() > 1)
                for (int j = 0; j < num_vals; j++, i++)
                {
                    line.append(QString(" %1 # M_GP%1" ).arg(str_list.at(i), QString::number(j+1)));
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

            chars += c_file->writeline (line);
        }
        else if (temp_int == 6)  // length specific maturity
        {
            line.clear();
            str_list = pop->Grow()->getMatAgeVals();
            for (int i = 0; i < str_list.count(); i++)
                line.append(QString(" %1").arg(str_list.at(i).toFloat()));

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
        chars += c_file->writeline("#");

        // growth parameters
        line = QString("#_growth_parms" );
        chars += c_file->writeline(line);
        line = QString("#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn" );
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
            }
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
            chars += c_file->writeline (line);
            line = QString("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-environ parameters" );
            chars += c_file->writeline (line);
        }
        else if (temp_int == 0)
        {
            line.prepend("0 ");
            chars += c_file->writeline (line);
        }
        else if (temp_int == 1)
        {
            line.prepend("1 ");
            chars += c_file->writeline (line);
        }
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
            chars += c_file->writeline (line);
            line.append(QString("#_LO HI INIT PRIOR PR_type SD PHASE" ));
            line.append("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-block parameters" );
        }
        else if (temp_int == 0)
        {
            line.prepend("0 ");
            chars += c_file->writeline (line);
        }
        else if (temp_int == 1)
        {
            line.prepend("1 ");
            chars += c_file->writeline (line);
        }
        line = QString("#_LO HI INIT PRIOR PR_type SD PHASE" );
        chars += c_file->writeline (line);
        if (temp_int == -1)
        {
            line = QString("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no MG-block parameters" );
            chars += c_file->writeline (line);
        }
        else
        {
            num = pop->Grow()->getNumBlockParams();
            for (i = 0; i < num; i++)
            {
                str_list = pop->Grow()->getBlockParam(i);
                for (int l = 0; l < str_list.count(); l++)
                    line.append(QString(" %1").arg(str_list.at(l)));
                line.append(QString(" " ).arg(QString::number(i)));
                chars += c_file->writeline (line);
            }
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
        chars += c_file->writeline("#");
        line = QString("# standard error parameters for MG devs" );
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
        chars += c_file->writeline("#");
        if (num > 0)
        {
            line = QString(QString("%1 #_MGparm_Dev_Phase" ).arg(pop->Grow()->getDevPhase()));
            chars += c_file->writeline(line);
        }
        else
        {
            line = QString(QString("#0 #_MGparm_Dev_Phase" ));
            chars += c_file->writeline(line);
        }
        chars += c_file->writeline("#");

        // Spawner-recruitment
        line = QString("#_Spawner-Recruitment");
        chars += c_file->writeline(line);
        line = QString(QString("%1 #_SR_function").arg(
                           QString::number(pop->SR()->method)));
        line.append(": 2=Ricker; 3=std_B-H; 4=SCAA; 5=Hockey; 6=B-H_flattop; 7=survival_3Parm; 8=Shepard_3Parm");
        chars += c_file->writeline(line);
        line = QString("#_LO HI INIT PRIOR PR_type SD PHASE");
        chars += c_file->writeline(line);

        line = QString(QString ("%1 # SR_LN(R0)" ).arg(pop->SR()->parameters->getRowText(0)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # SR_BH_steep" ).arg(pop->SR()->parameters->getRowText(1)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # SR_sigmaR" ).arg(pop->SR()->parameters->getRowText(2)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # SR_envlink" ).arg(pop->SR()->parameters->getRowText(3)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # SR_R1_offset" ).arg(pop->SR()->parameters->getRowText(4)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # SR_autocorr" ).arg(pop->SR()->parameters->getRowText(5)));
        chars += c_file->writeline(line);

        line = QString(QString ("%1 #_SR_env_link" ).arg(
                           QString::number(pop->SR()->env_link)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 #_SR_env_target_0=none;1=devs;_2=R0;_3=steepness" ).arg(
                           QString::number(pop->SR()->env_target)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 #_do_rec_dev:  0=none; 1=devvector; 2=simple deviations" ).arg(
                           QString::number(pop->SR()->rec_dev)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # first year of main recr_devs; early devs can preceed this era" ).arg(
                           QString::number(pop->SR()->rec_dev_start_yr)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # last year of main recr_devs; forecast devs start in following year" ).arg(
                           QString::number(pop->SR()->rec_dev_end_yr)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 #_rec-dev phase" ).arg(
                           QString::number(pop->SR()->rec_dev_phase)));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # (0/1) to read 13 advanced options" ).arg(
                           pop->SR()->advanced_opts? "1":"0"));
        chars += c_file->writeline(line);

        if (pop->SR()->advanced_opts)
        {
            line = QString(QString (" %1 #_rec-dev early start (0=none; neg value makes relative to recdev_start)" ).arg(
                               QString::number(pop->SR()->rec_dev_early_start)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_rec-dev early phase" ).arg(
                               QString::number(pop->SR()->rec_dev_early_phase)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_forecast recruitment phase (incl. late recr) (0 value resets to maxphase+1)" ).arg(
                               QString::number(pop->SR()->fcast_rec_phase)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_lambda for forecast_recr_like occurring before endyr+1" ).arg(
                               QString::number(pop->SR()->fcast_lambda)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_last_early_yr_nobias_adj_in_MPD" ).arg(
                               QString::number(pop->SR()->nobias_last_early_yr)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_first_yr_fullbias_adj_in_MPD" ).arg(
                               QString::number(pop->SR()->fullbias_first_yr)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_last_yr_fullbias_adj_in_MPD" ).arg(
                               QString::number(pop->SR()->fullbias_last_yr)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_first_recent_yr_nobias_adj_in_MPD" ).arg(
                               QString::number(pop->SR()->nobias_first_recent_yr)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_max_bias_adj_in_MPD (-1 to override ramp and set biasadj=1.0 for all estimated recdevs)" ).arg(
                               QString::number(pop->SR()->max_bias_adjust)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_period of cycles in recruitment (N parms read below)" ).arg(
                               QString::number(pop->SR()->rec_cycles)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_min rec_dev" ).arg(
                               QString::number(pop->SR()->rec_dev_min)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_max rec_dev" ).arg(
                               QString::number(pop->SR()->rec_dev_max)));
            chars += c_file->writeline(line);
            line = QString(QString (" %1 #_read rec_devs" ).arg(
                               QString::number(pop->SR()->num_rec_dev)));
            chars += c_file->writeline(line);
            line = QString(QString ("#_end of advanced SR options" ));
            chars += c_file->writeline(line);
        }
        line = QString("#" );
        chars += c_file->writeline(line);

        if (pop->SR()->rec_cycles == 0)
        {
            line = QString("#_placeholder for full parameter lines for recruitment cycles" );
            chars += c_file->writeline(line);
        }
        else
        {
            for (i = 0; i < pop->SR()->rec_cycles; i++)
            {
                line.clear();
                str_list = pop->SR()->full_parameters->getRowData(i);
                for (int j = 0; j < 14; j++)
                    line.append(QString(" %1").arg(str_list.at(j)));
                line.append(QString (" # " ));
                chars += c_file->writeline(line);
            }
        }

        line = QString(QString("# read %1 specified recr devs").arg(
                           QString::number(pop->SR()->num_rec_dev)));
        chars += c_file->writeline(line);
        line = QString("#_Yr Input_value");
        chars += c_file->writeline(line);
        for (std::map<int,float>::iterator itr = pop->SR()->yearly_devs.begin(); itr != pop->SR()->yearly_devs.end(); itr++)
        {
            line.clear();
            temp_int = itr->first;
            temp_float = itr->second;
            line.append(QString("%1 %2" ).arg(
                               QString::number(temp_int),
                               QString::number(temp_float)));
            chars += c_file->writeline(line);
        }
        line = QString("#" );
        chars += c_file->writeline(line);
        c_file->newline();

        // mortality
        line = QString("#Fishing Mortality info " );
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # F ballpark" ).arg(
                           QString::number(pop->M()->getBparkF())));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # F ballpark year (neg value to disable)" ).arg(
                           QString::number(pop->M()->getBparkYr())));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # F_Method: 1=Pope; 2=instan. F; 3=hybrid (hybrid is recommended)" ).arg(
                           QString::number(pop->M()->getMethod())));
        chars += c_file->writeline(line);
        line = QString(QString ("%1 # max F or harvest rate, depends on F_Method" ).arg(
                           QString::number(pop->M()->getMaxF())));
        chars += c_file->writeline(line);
        line = QString("# no additional F input needed for Fmethod 1" );
        chars += c_file->writeline(line);
        line = QString("# if Fmethod=2; read overall start F value; overall phase; N detailed inputs to read" );
        chars += c_file->writeline(line);
        line = QString("# if Fmethod=3; read N iterations for tuning for Fmethod 3" );
        chars += c_file->writeline(line);

        switch (pop->M()->getMethod())
        {
        case 1:
            break;
        case 2:
            line = QString(QString ("%1 # overall start F value" ).arg(
                               QString::number(pop->M()->getStartF())));
            chars += c_file->writeline(line);
            line = QString(QString ("%1 # overall phase" ).arg(
                               QString::number(pop->M()->getPhase())));
            chars += c_file->writeline(line);
            line = QString(QString ("%1 # N detailed inputs" ).arg(
                               QString::number(pop->M()->getNumInputs())));
            chars += c_file->writeline(line);
            break;
        case 3:
            line = QString(QString ("%1 # N iterations for tuning Fin hybrid method (recommend 3 to 7)" ).arg(
                               QString::number(pop->M()->getNumTuningIters())));
            chars += c_file->writeline(line);
        }

        temp_int = pop->M()->getInputModel()->rowCount();
        for (i = 0; i < temp_int; i++)
        {
            str_list = pop->M()->getInputLine(i);
            for (int j = 0; j < str_list.count(); j++)
            {
                line = QString(QString(" %1").arg(str_list.at(j)));
                chars += c_file->writeline(line);
            }
            line = QString(" # " );
            chars += c_file->writeline(line);
        }
        chars += c_file->writeline("#");

        temp_int = 0;
        for (i = 0; i < data->num_fisheries(); i++)
            if (data->getFleet(i)->catch_equil() > 0.0)
                temp_int++;
        line = QString(QString("#_initial_F_params; count = %1" ).arg (QString::number(temp_int)));
        chars += c_file->writeline(line);
        line = QString("#_LO HI INIT PRIOR PR_type SD PHASE" );
        chars += c_file->writeline(line);
        for (i = 0; i < data->num_fisheries(); i++)
        {
            str_list = pop->M()->getInitialParam(i);
            if (str_list.at(2).compare("0") == 0)
            {
                for (j = 0; j < str_list.count(); j++)
                {
                    line = QString(QString(" %1").arg(str_list.at(j)));
                    chars += c_file->writeline(line);
                }
                line = QString(QString(" # InitF_%1 %2" ).arg(
                                   QString::number(data->getFleet(i)->getNumber()),
                                   data->getFleet(i)->get_name()));
                chars += c_file->writeline(line);
            }
        }
        line = QString("# " );
        chars += c_file->writeline(line);
        c_file->newline();

        line = QString("#_Q_setup" );
        chars += c_file->writeline(line);
        line = QString("# Q_type options:  <0=mirror, 0=float_nobiasadj, 1=float_biasadj, 2=parm_nobiasadj, 3=parm_w_random_dev, 4=parm_w_randwalk, 5=mean_unbiased_float_assign_to_parm" );
        chars += c_file->writeline(line);
        line = QString("#_for_env-var:_enter_index_of_the_env-var_to_be_linked" );
        chars += c_file->writeline(line);
        line = QString("#_Den-dep  env-var  extra_se  Q_type  Q_offset" );
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            line = data->getFleet(i)->Q()->getSetup();
            line.append(QString(" # %1 %2" ).arg(
                            QString::number(i + 1),
                            data->getFleet(i)->get_name()));
            chars += c_file->writeline(line);
        }
        line = QString ("#" );
        chars += c_file->writeline(line);
        line = QString("#_Cond 0 #_If q has random component, then 0=read one parm for each fleet with random q; 1=read a parm for each year of index" );
        chars += c_file->writeline(line);
        line = QString("#_Q_parms(if_any);Qunits_are_ln(q)" );
        chars += c_file->writeline(line);
        line = QString("# LO HI INIT PRIOR PR_type SD PHASE" );
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            if (data->getFleet(i)->Q()->getDoPower())
            {
                line = data->getFleet(i)->Q()->getPower();
                line.append(QString(" # Q_den_dep_%2(%1)" ).arg(
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
                line.append(QString(" # Q_env_var_%2(%1)" ).arg(
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
                line.append(QString(" # Q_extraSD_%2(%1)" ).arg(
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
                line.append(QString(" # Q_base_%2(%1)" ).arg(
                                QString::number(i+1),
                                data->getFleet(i)->get_name()));
                chars += c_file->writeline(line);
            }
        }


        line = QString ("#" );
        chars += c_file->writeline(line);
        line = QString("#_size_selex_types");
        chars += c_file->writeline(line);
        line = QString("#discard_options:_0=none;_1=define_retention;_2=retention&mortality;_3=all_discarded_dead");
        chars += c_file->writeline(line);
        line = QString("#_Pattern Discard Male Special");
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            line = QString(QString("%1 # %2 %3").arg (
                               data->getFleet(i)->getSizeSelectivity()->getSetupText(),
                               QString::number(i + 1),
                               data->getFleet(i)->get_name()));
            chars += c_file->writeline(line);
        }

        line = QString ("#" );
        chars += c_file->writeline(line);
        line = QString("#_age_selex_types");
        chars += c_file->writeline(line);
        line = QString("#_Pattern ___ Male Special");
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            line = QString(QString("%1 # %2 %3").arg (
                               data->getFleet(i)->getAgeSelectivity()->getSetupText(),
                               QString::number(i + 1),
                               data->getFleet(i)->get_name()));
            chars += c_file->writeline(line);
        }
        line = QString ("#_LO HI INIT PRIOR PR_type SD PHASE env-var use_dev dev_minyr dev_maxyr dev_stddev Block Block_Fxn");
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            for (int j = 0; j < data->getFleet(i)->getSizeSelectivity()->getNumParameters(); j++)
            {
                line = QString(QString("%1 # SizeSel_P%3_%4(%2)").arg (
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
                line = QString(QString("%1 # AgeSel_P%3_%4(%2)").arg (
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
                        line = QString(QString("%1 # SizeSel_P%2_%3(%4)_env_fxn").arg (
                                       data->getFleet(i)->getSizeSelectivity()->getEnvLinkParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name(),
                                       QString::number(i+1)));
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
                                       data->getFleet(i)->get_name(),
                                       QString::number(i+1)));
                        chars += c_file->writeline(line);
                    }
                }
            }
        }
        else
        {
            line.prepend("#_Cond 0");
            chars += c_file->writeline(line);
            line = QString("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no enviro fxns");
            chars += c_file->writeline(line);
        }


        // Custom Block Setup
        line = QString (" #_custom_sel-blk_setup (0/1) ");
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
                    line = QString(QString("%1 # SizeSel_P%2_%3(%4)_blk_setup" ).arg (
                                       data->getFleet(i)->getSizeSelectivity()->getBlockParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name(),
                                       QString::number(i+1)));
                    chars += c_file->writeline(line);
                    }
                }
                pm = data->getFleet(i)->getAgeSelectivity()->getParameterModel();
                for (int j = 0; j < pm->rowCount(); j++)
                {
                    str_list = pm->getRowData(j);
                    if (pm->useBlock(j) > 0)
                    {
                    line = QString(QString("%1 # AgeSel_P%2_%3(%4)_blk_setup" ).arg (
                                       data->getFleet(i)->getAgeSelectivity()->getBlockParameter(j),
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
            line.prepend("#_Cond 0");
            chars += c_file->writeline(line);
            line = QString("#_Cond -2 2 0 0 -1 99 -2 #_placeholder when no block usage" );
            chars += c_file->writeline(line);
        }

        // Selex parm trends
        line = QString ("#_Cond No selex parm trends " );
        chars += c_file->writeline(line);

        // Parameter Deviations
        line = QString ("#_Cond -4 # placeholder for selparm_Dev_Phase" );
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
                                       data->getFleet(i)->get_name(),
                                       QString::number(i+1)));
                    chars += c_file->writeline(line);
                    line = QString(QString(" %1 # SizeSel_P%2_%3(%4)_dev_rho" ).arg (
                                       data->getFleet(i)->getSizeSelectivity()->getDevRhoParameter(j),
                                       QString::number(j+1),
                                       data->getFleet(i)->get_name(),
                                       QString::number(i+1)));
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
            line = QString("#_Cond 0 #_env/block/dev_adjust_method (1=standard; 2=logistic trans to keep in base parm bounds; 3=standard w/ no bound check)" );
            chars += c_file->writeline(line);
        }
        chars += c_file->writeline("#");

        // Tag Recapture Parameters
        temp_int = data->getTagLoss();
        line = QString(QString("# Tag loss and Tag reporting parameters go next"));
        chars += c_file->writeline(line);
        line = QString(QString("%1 # TG_custom:  0=no read; 1=read if tags exist").arg(
                           QString::number(temp_int)));
        chars += c_file->writeline(line);
        if (temp_int == 1)
        {
            line = QString(QString(" %1 # tag loss parameter").arg(
                               data->getTagLossParameter()->toText()));
        }
        else
        {
            line = QString(QString("#_Cond -6 6 1 1 2 0.01 -4 0 0 0 0 0 0 0  #_placeholder if no parameters"));
        }
        chars += c_file->writeline(line);

        chars += c_file->writeline("#");
        temp_int = data->getInputValueVariance();
        line = QString("# Input variance adjustments; factors: ");
        chars += c_file->writeline(line);
        line = QString(" #_1=add_to_survey_CV");
        chars += c_file->writeline(line);
        line = QString(" #_2=add_to_discard_stddev");
        chars += c_file->writeline(line);
        line = QString(" #_3=add_to_bodywt_CV");
        chars += c_file->writeline(line);
        line = QString(" #_4=mult_by_lencomp_N");
        chars += c_file->writeline(line);
        line = QString(" #_5=mult_by_agecomp_N");
        chars += c_file->writeline(line);
        line = QString(" #_6=mult_by_size-at-age_N");
        chars += c_file->writeline(line);
        line = QString(" #_7=mult_by_generalized sizecomp (not implemented yet)");
        chars += c_file->writeline(line);
        line = QString("#_Factor  Fleet  Value");
        chars += c_file->writeline(line);
        for (int i = 0; i < data->num_fleets(); i++)
        {
            temp_float = data->getFleet(i)->getAddToSurveyCV();
            if (!floatEquals(temp_float, 0.0))
            {
                line = QString(QString(" 1 %1 %2 #_add_to_survey_CV" ).arg(
                                   QString::number(i+1),
                                   QString::number(temp_float)));
                chars += c_file->writeline(line);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            temp_float = data->getFleet(i)->getAddToSurveyCV();
            if (!floatEquals(temp_float, 0.0))
            {
                line = QString(QString(" 2 %1 %2 #_add_to_discard_stddev" ).arg(
                                   QString::number(i+1),
                                   QString::number(temp_float)));
                chars += c_file->writeline(line);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            temp_float = data->getFleet(i)->getAddToBodyWtCV();
            if (!floatEquals(temp_float, 0.0))
            {
                line = QString(QString(" 3 %1 %2 #_add_to_bodywt_CV" ).arg(
                                   QString::number(i+1),
                                   QString::number(temp_float)));
                chars += c_file->writeline(line);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            temp_float = data->getFleet(i)->getMultByLenCompN();
            if (!floatEquals(temp_float, 1.0))
            {
                line = QString(QString(" 4 %1 %2 #_mult_by_lencomp_N" ).arg(
                                   QString::number(i+1),
                                   QString::number(temp_float)));
                chars += c_file->writeline(line);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            temp_float = data->getFleet(i)->getMultByAgeCompN();
            if (!floatEquals(temp_float, 1.0))
            {
                line = QString(QString(" 5 %1 %2 #_mult_by_agecomp_N" ).arg(
                                   QString::number(i+1),
                                   QString::number(temp_float)));
                chars += c_file->writeline(line);
            }
        }
        for (int i = 0; i < data->num_fleets(); i++)
        {
            temp_float = data->getFleet(i)->getMultBySAA();
            if (!floatEquals(temp_float, 1.0))
            {
                line = QString(QString(" 6 %1 %2 #_mult_by_size-at-age_N" ).arg(
                                   QString::number(i+1),
                                   QString::number(temp_float)));
                chars += c_file->writeline(line);
            }
        }

        line = QString ("-9999 1 0 # terminator");
        chars += c_file->writeline(line);


        chars += c_file->writeline("#");
        line = QString(QString("%1 #_maxlambdaphase").arg(
                           QString::number(data->getLambdaMaxPhase())));
        chars += c_file->writeline(line);
        line = QString(QString("%2 #_sd_offset").arg(
                           QString::number(data->getLambdaSdOffset())));
        chars += c_file->writeline(line);
        line = QString(QString("# read %1 changes to default Lambdas (default value is 1.0)" ).arg(QString::number(data->getLambdaNumChanges())));
        chars += c_file->writeline(line);
        line = QString(QString("# Like_comp codes:  1=surv; 2=disc; 3=mnwt; 4=length; 5=age; 6=SizeFreq; 7=sizeage; 8=catch; 9=init_equ_catch;"));
        chars += c_file->writeline(line);
        line = QString(QString("# 10=recrdev; 11=parm_prior; 12=parm_dev; 13=CrashPen; 14=Morphcomp; 15=Tag-comp; 16=Tag-negbin; 17=F_ballpark"));
        chars += c_file->writeline(line);
        line = QString(QString("#like_comp  fleet  phase  value  sizefreq_method"));
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

                chars += c_file->writeline(line);
            }
            num += j;
        }
        if (num > data->getLambdaNumChanges())
        {
            c_file->error(QString("Problem writing control file. Lambda changes do not match."));
        }
        line = QString ("-9999  1  1  1  1  # terminator");
        chars += c_file->writeline(line);

        temp_int = data->getAddSdReporting()->getActive();
        if (temp_int == 1)
        {
            line = QString("1 # (0/1) read specs for more stddev reporting");
            chars += c_file->writeline(line);
            line = QString (QString("%1 # selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages").arg(
                                data->getAddVarSetupToText()));
            chars += c_file->writeline(line);
            line.clear();
            str_list = data->getAddSdReprtSelex();
            for (int i = 0; i < str_list.count(); i++)
            {
                line.append(QString (" %1").arg(str_list.at(i)));
            }
            line.append(" # vector with selex std bin picks (-1 in first bin to self-generate)");
            chars += c_file->writeline(line);
            line.clear();
            str_list = data->getAddSdReprtGrwth();
            for (int i = 0; i < str_list.count(); i++)
            {
                line.append(QString(" %1").arg(str_list.at(i)));
            }
            line.append(" # vector with growth std bin picks (-1 in first bin to self-generate)");
            chars += c_file->writeline(line);
            line.clear();
            str_list = data->getAddSdReprtAtAge();
            for (int i = 0; i < str_list.count(); i++)
            {
                line.append(QString(" %1").arg(str_list.at(i)));
            }
            line.append(" # vector with NatAge std bin picks (-1 in first bin to self-generate)");
            chars += c_file->writeline(line);
        }
        else
        {
            line = QString("0 # (0/1) read specs for more stddev reporting");
            chars += c_file->writeline(line);
            line = QString(" # 0 1 -1 5 1 5 1 -1 5 # placeholder for selex type, len/age, year, N selex bins, Growth pattern, N growth ages, NatAge_area(-1 for all), NatAge_yr, N Natages");
            chars += c_file->writeline(line);
            line = QString(" # placeholder for vector of selex bins to be reported");
            chars += c_file->writeline(line);
            line = QString(" # placeholder for vector of growth ages to be reported");
            chars += c_file->writeline(line);
            line = QString(" # placeholder for vector of NatAges ages to be reported");
            chars += c_file->writeline(line);
        }

        line = QString::number(END_OF_DATA);
        chars += c_file->writeline(line);

        c_file->close();
    }
    return chars;
}

bool read33_parameterFile(ss_file *pr_file, ss_model *data)
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

int write33_parameterFile(ss_file *pr_file, ss_model *data)
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

bool read33_userDataFile (ss_file *ud_file, ss_model *data)
{
    return true;
}

int write33_userDataFile (ss_file ud_file, ss_model *data)
{
    return 0;
}

bool read33_profileFile (ss_file *pf_file, ss_model *data)
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

int write33_profileFile (ss_file *pf_file, ss_model *data)
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
