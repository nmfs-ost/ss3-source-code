#ifndef METADATA_H
#define METADATA_H

#include <QString>

#define app_name          ("Stock Synthesis Interface")
#define app_version_major  2
#define app_version_minor  3
#define app_version_bugfix 0
#define app_version_apply ("3.30")
#define app_copyright_date  __DATE__
#define app_copyright_org ("NOAA")

#define app_manual        ("SS_User_Manual_3.30.pdf")
#define app_technical     ("SS_technical_description_2012.pdf")

QString getAppVersion ();
QString getAppAppliesTo ();
QString getAppName ();
QString getAppCopyright ();
QString getAppOrg ();
QString getAppUserManual ();
QString getAppTechDescription ();

#endif // METADATA_H
