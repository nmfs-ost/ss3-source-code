#include "selex_equation.h"

selex_equation::selex_equation()
{
    numParams = 0;
}

int selex_equation::getNumParams() const
{
    return numParams;
}

void selex_equation::setNumParams(int value)
{
    numParams = value;
}

float selex_equation::evaluate()
{
    return 0.0;
}

none::none()
{
    numParams = 0;
}

mirror::mirror()
{
    numParams = 0;
}

mirror_range::mirror_range()
{
    numParams = 2;
}

simple_logistic::simple_logistic()
{
    numParams = 2;
}

exponent_logistic::exponent_logistic()
{
    numParams = 3;
}

simple_double_logistic::simple_double_logistic()
{
    numParams = 6;
}

double_logistic::double_logistic()
{
    numParams = 8;
}

double_normal_plateau::double_normal_plateau()
{
    numParams = 4;
}

double_normal_plateau_ends::double_normal_plateau_ends()
{
    numParams = 6;
}

linear_segments::linear_segments()
{
    numParams = 9;
}

cubic_spline::cubic_spline()
{
    numParams = 9;
}

constant_for_range::constant_for_range()
{
    numParams = 2;
}

coleraine::coleraine()
{
    numParams = 0;
}

random_walk::random_walk()
{
    numParams = 0;
}

each_age::each_age()
{
    numParams = 0;
}

