---
name: SS3 release checklist
about: SS3 dev team only - Checklist for steps needed to release a version of SS3
title: Release v3.30.[xx] checklist
labels: request
assignees:
  - Rick-Methot-NOAA
  - chantelwetzel-noaa
  - iantaylor-NOAA
  - kellijohnson-NOAA
  - nschindler-noaa
  - k-doering-NOAA

---

# Release checklist

Note all instances of xx should be replaced with the version number (e.g., the release for 3.30.20 would replace xx with 20)

## Checklist for before prerelease
- [ ] SS testing and debugging completed (RM and IT)
- [ ] r4ss updated (IT)
- [ ] Put together pre-release announcement (RM)
- [ ] code committed and tagged in repo as `v3.30.xx-prerel` (RM)
- [ ] All exes added to github releases as `v3.30.xx-prerel` (RM)
- [ ] Announce prerelease (RM)

## Checklist for before release
- [ ] Manual updated and tagged in repo (CW)
- [ ] Manual added to a github release, include attaching a pdf version (CW)
- [ ] Manual release version on website updated once pdf and html built (CW)
- [ ] SSI updated (NS)
- [ ] Make changes to SS3 if any bugs caught in prerelease (RM)
- [ ] Change log updated in Stock Synthesis repo (RM)
- [ ] Code committed and tagged in repo as `v3.30.xx` (RM)
- [ ] Exe and .tpl archived on Google drive (RM)
- [ ] All exes added to github releases as `v3.30.xx` (RM)
- [ ] Add GUI as as a github release (NS)
- [ ] Send out release announcement msg (RM)

## Checklist for after release
- [ ] examples updated in user-examples repo using [this script](https://github.com/nmfs-stock-synthesis/user-examples/blob/main/R/update_examples.R) (IT)
- [ ] Update ss-test-models reference files to the release version using [this update script](https://github.com/nmfs-stock-synthesis/test-models/blob/main/.github/r_scripts/update_ref_files.R) (IT)
- [ ] Removed "resolved" tag and close all issues worked in the milestone for this release (RM)
- [ ] Move unworked issues for the release milestone to the next milestone (RM)
