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
- [ ] Manual updated and tagged in repo (CW) - address at least issues with the [`v3.30.xx` release label](add correct link to github issues using filter: is:issue is:open label:"3.30.xx release" when available)
- [ ] Manual added to a github release, include attaching a pdf version (KJ and CW)
- [ ] Manual release version on website updated once pdf and html built (KJ) (update https://github.com/nmfs-stock-synthesis/doc/blob/main/docs/SS330_User_Manual_release.html to the `v3.30.xx` version; update links to link to `v3.30.xx` in https://github.com/nmfs-stock-synthesis/doc/blob/main/docs/index.md#links-to-documentation)
- [ ] SSI updated (NS)
- [ ] Make changes to SS3 if any bugs caught in prerelease (RM)
- [ ] Change log updated in Stock Synthesis repo (RM)
- [ ] Code committed and tagged in repo as `v3.30.xx`, which will trigger a gha to build the release executables (KJ) (Instructions on [how to push a a local tag to a remote](https://github.com/nmfs-stock-synthesis/stock-synthesis/wiki/Stock-Synthesis:-practices-for-maintainers#how-to-push-a-local-tag-up-to-github))
- [ ] Exe and .tpl archived on [Google drive](https://drive.google.com/drive/folders/1Gh_dXi8v3rqawpwn2N6yaaEXZPq6G2io) (KJ)
- [ ] All exes added to github releases as `v3.30.xx` (KJ) (get exes in the artifacts of the gha that built the release exes)
- [ ] Send out release announcement msg (RM)

## Checklist for after release
- [ ] Examples updated in user-examples repo using [this script](https://github.com/nmfs-stock-synthesis/user-examples/blob/main/R/update_examples.R) (KJ)
- [ ] Update ss-test-models reference files to the release version using [this update script](https://github.com/nmfs-stock-synthesis/test-models/blob/main/.github/r_scripts/update_ref_files.R) (EG). Also tag after updating with release number.
- [ ] Removed "resolved" tag and close all issues worked in the milestone for this release (RM)
- [ ] Move unworked issues for the release milestone to the next milestone (RM)
