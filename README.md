# Stock Synthesis 3.30
![GitHub release (latest by date)](https://img.shields.io/github/v/release/nmfs-ost/ss3-source-code)
![GitHub Release Date](https://img.shields.io/github/release-date/nmfs-ost/ss3-source-code)
[![GitHub last commit](https://img.shields.io/github/last-commit/nmfs-ost/ss3-source-code)](https://github.com/nmfs-ost/ss3-source-code/commits/main)
![GitHub release (latest by date)](https://img.shields.io/github/downloads/nmfs-ost/ss3-source-code/latest/total)
![GitHub release (latest by date)](https://img.shields.io/github/v/release/nmfs-ost/ss3-source-code)
![GitHub Release Date](https://img.shields.io/github/release-date/nmfs-ost/ss3-source-code)
[![GitHub last commit](https://img.shields.io/github/last-commit/nmfs-ost/ss3-source-code)](https://github.com/nmfs-ost/ss3-source-code/commits/main)
![GitHub release (latest by date)](https://img.shields.io/github/downloads/nmfs-ost/ss3-source-code/latest/total)

Stock Synthesis (SS3) is a generalized age-structured population dynamics model implemented in [ADMB](http://www.admb-project.org/). It is used to assess the effect of fisheries on fish and shellfish stocks while taking into account the influence of environmental factors.

# Table of contents
-   [Citing Stock Synthesis](#citing-stock-synthesis)
-   [Installation](#installation)
-   [How can I learn how to use Stock Synthesis?](#how-can-i-learn-how-to-use-stock-synthesis)
-   [How do I ask questions about Stock Synthesis?](#how-do-i-ask-questions-about-stock-synthesis)
-   [How can I contribute to Stock Synthesis?](#how-can-i-contribute-to-stock-synthesis)
-   [Tools for working with Stock Synthesis](#tools-for-working-with-stock-synthesis)
-   [Disclaimer](#disclaimer)


## Citing Stock Synthesis

Please cite Stock Synthesis as:

```
Methot, R.D. and Wetzel, C.R. (2013). Stock Synthesis: A biological and statistical
framework for fish stock assessment and fishery management. Fisheries Research, 
142: 86-99. https://doi.org/10.1016/j.fishres.2012.10.012
```

## Installation

Download the latest compiled versions from [Github Releases](https://github.com/nmfs-ost/ss3-source-code/releases). For information on specific changes with each release, please refer to the [change log on GitHub](https://github.com/orgs/nmfs-ost/projects/11) for changes from v.3.30.19 onward and the [Excel spreadsheet version of the change log](https://github.com/nmfs-ost/ss3-source-code/blob/v3.30.19/Change_log_for_SS_3.30.xlsx?raw=true) for changes prior to v.3.30.19.

## How can I learn how to use Stock Synthesis?

To learn more about how to use Stock Synthesis, see the [getting started guide with Stock Synthesis guide](https://nmfs-ost.github.io/ss3-doc/Getting_Started_SS3.html). To learn how to build your own models in Stock Synthesis, see the [Develop an Stock Synthesis model guide](https://nmfs-ost.github.io/ss3-doc/ss3_model_tips.html).

The [Stock Synthesis user manual](https://nmfs-ost.github.io/doc/SS330_User_Manual_release.html) provides the complete documentation of Stock Synthesis.

## How do I ask questions about Stock Synthesis?

Please look for answers or submit questions to the [Stock Synthesis forums](https://vlab.noaa.gov/web/stock-synthesis/public-forums). Note that an account is required to ask questions on the forums. Questions can also be asked by opening an [issue](https://github.com/nmfs-ost/ss3-source-code/issues) in this repository or by emailing nmfs.stock.synthesis@noaa.gov.

## How can I contribute to Stock Synthesis?

Have feature requests or bug reports? Want to contribute code? Please open an [issue](https://github.com/nmfs-ost/ss3-source-code/issues) or submit a pull request. For complete details, please see [CONTRIBUTING.md](CONTRIBUTING.md)

This project and everyone participating in it is governed by the [NMFS Fisheries Toolbox Code of Conduct](https://github.com/nmfs-fish-tools/Resources/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Tools for working with Stock Synthesis

As Stock Synthesis usage has grown, so has the number of tools to work with it. These include [repositories on github with the stock-synthesis topic](https://github.com/topics/stock-synthesis) as well as:

- [r4ss](https://github.com/r4ss/r4ss): Create plots of Stock Synthesis output and functions to work with Stock Synthesis in R.
- [ss3diags](https://github.com/PIFSCstockassessments/ss3diags): Run advanced diagnostics for Stock Synthesis models.
- [ss3sim](https://github.com/ss3sim/ss3sim): Conduct simulation studies using Stock Synthesis.
- [SSI](https://vlab.noaa.gov/web/stock-synthesis/document-library/-/document_library/0LmuycloZeIt/view/5042951): Stock Synthesis Interface, a GUI for developing models and running Stock Synthesis. Links to r4ss.
- [SS3 Shiny helper app](https://connect.fisheries.noaa.gov/ss3-helper/): Visualize common selectivity pattern options available within Stock Synthesis.
- [SSMSE](https://github.com/nmfs-fish-tools/SSMSE): Use Stock Synthesis operating models in Management Strategy Evaluation.
- [sa4ss](https://github.com/nwfsc-assess/sa4ss): Create accessible R markdown stock assessment documents with results from Stock Synthesis models. Note this tool is intended for use by analysts within the Northwest and Southwest Fisheries Science Centers currently.
- Data limited tools - Options included Simple Stock Synthesis ([SSS](https://github.com/shcaba/SSS)) and Extended Simple Stock Synthesis ([XSSS](https://github.com/chantelwetzel-noaa/XSSS)), as well as [SS-DL-tool](https://github.com/shcaba/SS-DL-tool), a shiny app that includes XSSS and SSS in its functionality.

Have a tool to work with Stock Synthesis that should be mentioned here? Open an issue or pull request to let us know!

## Disclaimer

This repository is a scientific product and is not official communication of the National Oceanic and
Atmospheric Administration, or the United States Department of Commerce. All NOAA GitHub project
code is provided on an ‘as is’ basis and the user assumes responsibility for its use. Any claims against the
Department of Commerce or Department of Commerce bureaus stemming from the use of this GitHub
project will be governed by all applicable Federal law. Any reference to specific commercial products,
processes, or services by service mark, trademark, manufacturer, or otherwise, does not constitute or
imply their endorsement, recommendation or favoring by the Department of Commerce. The Department
of Commerce seal and logo, or the seal and logo of a DOC bureau, shall not be used in any manner to
imply endorsement of any commercial product or activity by DOC or the United States Government.
