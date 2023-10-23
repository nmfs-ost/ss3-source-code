# Contributing to Stock Synthesis

## General Information

Thank you for your interest in contributing to Stock Synthesis! We strive to follow the [NMFS Fisheries Toolbox Contribution Guide](https://github.com/nmfs-fish-tools/Resources/blob/master/CONTRIBUTING.md). Note that these are guidelines, not rules, and we are open to collaborations in other ways that may work better for you. Please feel free to reach out to us by opening an issue in this repository or by emailing the developers at nmfs.stock.synthesis@noaa.gov.

This project and everyone participating in it is governed by the [NMFS Fisheries Toolbox Code of Conduct](https://github.com/nmfs-fish-tools/Resources/blob/master/CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [fisheries.toolbox@noaa.gov](mailto:fisheries.toolbox@noaa.gov). Note that the maintainers of SS do not have access to this email account, so unacceptable behavior of the maintainers can also be reported here.

## How can I contribute?

We welcome all contributions! For example, report bugs or request features through an [issue](https://github.com/nmfs-stock-synthesis/ss3-source-code/issues), suggest code changes through a pull request, or suggest changes to the [Stock Synthesis manual](https://github.com/nmfs-stock-synthesis/ss3-doc).

## How to submit a pull request to Stock Synthesis

All code contributions should be submitted as pull requests to be reviewed by an SS3 team member.

1. [Fork](https://docs.github.com/en/github/getting-started-with-github/fork-a-repo) the stock synthesis repository (or, if you are a member of the nmfs-stock-synthesis organization, clone the repository).
2. Create a new branch, make the changes, and test out by [building stock synthesis](#how-to-build-stock-synthesis-from-source) locally.
3. Commit the changes and push up to the github fork.
4. [Submit a pull request](https://docs.github.com/en/github/collaborating-with-issues-and-pull-requests/creating-a-pull-request-from-a-fork) to the main branch of Stock Synthesis Repository.
5. An SS3 team member will work with you to accept or make corrections to the pull request.

## How to build Stock Synthesis from source

1. Have a local version of the stock synthesis repository (though forking or cloning).
2. Download [ADMB](http://www.admb-project.org/). The current version of ADMB used to compile Stock Synthesis is listed in [SS_versioninfo_330safe.tpl](https://github.com/nmfs-stock-synthesis/ss3-source-code/blob/main/SS_versioninfo_330safe.tpl).
3. Add ADMB to the PATH or use the ADMB command window for the following commands.
4. On Linux or Mac:
    - Change directory to the cloned Stock Synthesis repository and use the script [Make_SS_330_new.sh](https://github.com/nmfs-stock-synthesis/ss3-source-code/blob/main/Make_SS_330_new.sh) by calling `./Make_SS_330_new.sh`. To see all options for the function, use `./Make_SS_330_new.sh --help`.
    - Follow the instructions found in the [GNUmakefile](https://github.com/nmfs-stock-synthesis/ss3-source-code/blob/main/GNUmakefile) which will allow you to compile Stock Synthesis using the command `~/stock-synthesis$ make` within a command line opened in the cloned Stock Synthesis repository folder.
6. On Windows: Change directory to the cloned Stock Synthesis repository's [Compile](https://github.com/nmfs-stock-synthesis/ss3-source-code/tree/main/Compile) subfolder and call the [Make_SS_safe batch script](https://github.com/nmfs-stock-synthesis/ss3-source-code/blob/main/Compile/Make_SS_safe.bat) to build the "safe" version of Stock Synthesis. (to build the fast (aka optimized) version of Stock Synthesis, call the Make_SS_fast.bat batch scripts instead). Upon calling the batch script, SS3 will be built in the Compile subfolder.

# Still have a question on the contributing workflow?

Please email nmfs.stock.synthesis@noaa.gov for assistance.
