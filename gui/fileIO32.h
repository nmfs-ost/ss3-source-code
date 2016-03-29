#ifndef FILEIO32_H
#define FILEIO32_H

#include "input_file.h"
#include "model.h"

bool read32_dataFile (ss_file *d_file, ss_model *data);
int write32_dataFile (ss_file *d_file, ss_model *data);

bool read32_controlFile (ss_file *c_file, ss_model *data);
int write32_controlFile (ss_file *c_file, ss_model *data);

bool read32_forecastFile (ss_file *f_file, ss_model *data);
int write32_forecastFile (ss_file *f_file, ss_model *data);

bool read32_parameterFile (ss_file *pr_file, ss_model *data);
int write32_parameterFile (ss_file *pr_file, ss_model *data);

bool read32_profileFile(ss_file *pf_file, ss_model *data);
int write32_profileFile(ss_file *pf_file, ss_model *data);

#endif // FILEIO32_H

