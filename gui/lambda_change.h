#ifndef LAMBDA_CHANGE_H
#define LAMBDA_CHANGE_H

class lambda_change
{
public:
    lambda_change();

    void set_like_comp (int val) {like_comp = val;}
    int get_like_comp () {return like_comp;}
    void set_fleet (int val) {fleet = val;}
    int get_fleet () {return fleet;}
    void set_phase (int val) {phase = val;}
    int get_phase () {return phase;}
    void set_value (float val) {value = val;}
    float get_value () {return value;}
    void set_method (int val) {method = val;}
    int get_method () {return method;}


    int like_comp;
    int fleet;
    int phase;
    float value;
    int method;
};

#endif // LAMBDA_CHANGE_H
