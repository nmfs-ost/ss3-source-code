#ifndef SELEX_EQUATION_H
#define SELEX_EQUATION_H

class selex_equation
{
public:
    selex_equation();
    virtual float evaluate();

    int getNumParams() const;
    void setNumParams(int value);

protected:
    int numParams;

};

class none: public selex_equation
{
public:
    none();
    float evaluate() {return 0.0;}
};

class mirror: public selex_equation
{
public:
    mirror();
    float evaluate() {return 0.0;}
};

class mirror_range: public selex_equation
{
public:
    mirror_range();
    float evaluate() {return 0.0;}
};

class simple_logistic: public selex_equation
{
public:
    simple_logistic();
    float evaluate() {return 0.0;}
};

class exponent_logistic: public selex_equation
{
public:
    exponent_logistic();
    float evaluate() {return 0.0;}
};

class double_logistic: public selex_equation
{
public:
    double_logistic();
    float evaluate() {return 0.0;}
};

class linear_segments: public selex_equation
{
public:
    linear_segments();
    float evaluate() {return 0.0;}
};

class simple_double_logistic: public selex_equation
{
public:
    simple_double_logistic();
    float evaluate() {return 0.0;}
};

class cubic_spline: public selex_equation
{
public:
    cubic_spline();
    float evaluate() {return 0.0;}
};

class double_normal_plateau: public selex_equation
{
public:
    double_normal_plateau();
    float evaluate() {return 0.0;}
};

class double_normal_plateau_ends: public double_normal_plateau
{
public:
    double_normal_plateau_ends();
    float evaluate() {return 0.0;}
};

class constant_for_range: public selex_equation
{
public:
    constant_for_range();
    float evaluate() {return 0.0;}
};

class coleraine: public selex_equation
{
public:
    coleraine();
    float evaluate() {return 0.0;}
};

class each_age: public selex_equation
{
public:
    each_age();
    float evaluate() {return 0.0;}

};

class random_walk: public selex_equation
{
public:
    random_walk();
    float evaluate() {return 0.0;}
};

#endif // SELEX_EQUATION_H
