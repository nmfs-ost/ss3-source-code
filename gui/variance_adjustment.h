#ifndef VARIANCE_ADJUSTMENT_H
#define VARIANCE_ADJUSTMENT_H

class variance_adjustment
{
public:
    variance_adjustment();

    float survey_cv_add ;
    float discard_sd_add;
    float body_wt_cv_add;
    float lencomp_N_mult;
    float agecomp_N_mult;
    float s_a_age_N_mult;
	
    float getSurvey_cv_add() const;
    void setSurvey_cv_add(float value);
    float getDiscard_sd_add() const;
    void setDiscard_sd_add(float value);
    float getBodywt_cv_add() const;
    void setBodywt_cv_add(float value);
    float getLencomp_N_mult() const;
    void setLencomp_N_mult(float value);
    float getAgecomp_N_mult() const;
    void setAgecomp_N_mult(float value);
    float getSa_age_N_mult() const;
    void setSa_age_N_mult(float value);
};

#endif // VARIANCE_ADJUSTMENT_H
