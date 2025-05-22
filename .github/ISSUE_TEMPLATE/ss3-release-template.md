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
  - shcaba
  - e-perl-NOAA
---

# Release checklist

<!---Note all instances of xx should be replaced with the version number (e.g., the release for v3.30.20 would replace xx with 20)-->

## General checklist before pre-release and release
- [ ] SS3 testing and debugging completed (RM/IT)
- [ ] Check artifact from the `call-build-ss3-warnings` GitHub action for useful warnings (RM/IT/EP)
- [ ] r4ss updated (IT/EP)
- [ ] [Change log project board](https://github.com/orgs/nmfs-ost/projects/11) updated with any issues labelled "change log" and check for any issues that should be labelled "change log" (RM)

<!---## Checklist for before pre-release (if pre-release is being done)
- [ ] Put together pre-release announcement (RM)
- [ ] code committed and tagged in repo as `v3.30.xx-prerel` (RM)
- [ ] All exes added to GitHub releases as `v3.30.xx-prerel` (RM)
- [ ] Announce prerelease (RM)-->

## Checklist for before release
- [ ] Make changes to SS3 if any bugs caught in prerelease (RM)
- [ ] Code committed and tagged in repo as `v3.30.xx`, which will trigger a GHA to build the release executables (EP) (Instructions on [how to push a a local tag to a remote](https://github.com/nmfs-ost/ss3-source-code/wiki/Stock-Synthesis:-practices-for-maintainers#how-to-push-a-local-tag-up-to-github))
- [ ] All exes added to GitHub releases as `v3.30.xx` (EP) (get exes in the artifacts of the GHA that built the release exes)
- [ ] Run [release workflow](https://github.com/nmfs-ost/ss3-doc/actions/workflows/release.yml) (or [bug fix release workflow](https://github.com/nmfs-ost/ss3-doc/actions/workflows/release_bug_fix.yml) if the release is a bug fix). **Note that the branch protection rules must be briefly turned off to allow this workflow to run.** (EP)
- [ ] Exe and .tpl archived on [Google drive](https://drive.google.com/drive/folders/1Gh_dXi8v3rqawpwn2N6yaaEXZPq6G2io) (EP)
- [ ] Send out release announcement message to the [SS3 forum](https://groups.google.com/g/ss3-forum) (RM)
- [ ] Add to release discussion on GitHub repository (EP)

## Checklist for after release
- [ ] Update user-example models using [this github action](https://github.com/nmfs-ost/ss3-user-examples/blob/main/R/update_examples.R) and tag with new release number after updating (EP)
- [ ] Update test models using [this github action](https://github.com/nmfs-ost/ss3-test-models/actions/workflows/update-ss3-models.yml) and tag with new release number after updating (EP)
- [ ] Update executables in the [SAC tool](https://github.com/shcaba/SS-DL-tool) (also suggest updating the input files to the .ss_new files (EP/JC)
- [ ] Removed "resolved" tag and close all issues worked in the milestone for this release (RM)
- [ ] Move unworked issues for the release milestone to the next milestone (RM)
