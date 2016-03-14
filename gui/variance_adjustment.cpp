#include "variance_adjustment.h"

variance_adjustment::variance_adjustment()
{
}
float variance_adjustment::getSa_age_N_mult() const
{
    return s_a_age_N_mult;
}

void variance_adjustment::setSa_age_N_mult(float value)
{
    s_a_age_N_mult = value;
}

float variance_adjustment::getAgecomp_N_mult() const
{
    return agecomp_N_mult;
}

void variance_adjustment::setAgecomp_N_mult(float value)
{
    agecomp_N_mult = value;
}

float variance_adjustment::getLencomp_N_mult() const
{
    return lencomp_N_mult;
}

void variance_adjustment::setLencomp_N_mult(float value)
{
    lencomp_N_mult = value;
}

float variance_adjustment::getBodywt_cv_add() const
{
    return body_wt_cv_add;
}

void variance_adjustment::setBodywt_cv_add(float value)
{
    body_wt_cv_add = value;
}

float variance_adjustment::getDiscard_sd_add() const
{
    return discard_sd_add;
}

void variance_adjustment::setDiscard_sd_add(float value)
{
    discard_sd_add = value;
}

float variance_adjustment::getSurvey_cv_add() const
{
    return survey_cv_add;
}

void variance_adjustment::setSurvey_cv_add(float value)
{
    survey_cv_add = value;
}

