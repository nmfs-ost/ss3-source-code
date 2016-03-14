#ifndef FLEETLAMBDA_H
#define FLEETLAMBDA_H


class fleetLambda
{
public:
    fleetLambda();
    fleetLambda(int cmp, int phs, float lmb, int szfq);

    void setComponent (int cmp) {component = cmp;}
    int getComponent () {return component;}
    void setPhase (int phs) {phase = phs;}
    int getPhase () {return phase;}
    void setLambda (float lmb) {lambda = lmb;}
    float getLambda () {return lambda;}
    void setSizeFreq (int szfq) {sizeFreq = szfq;}
    int getSizeFreq () {return sizeFreq;}
    fleetLambda & operator = (fleetLambda rhs);
    bool operator == (fleetLambda rhs) const;

private:
    int component;
    int phase;
    float lambda;
    int sizeFreq;

};

#endif // FLEETLAMBDA_H
