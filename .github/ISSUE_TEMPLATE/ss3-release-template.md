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
  - e-gugliotti-NOAA
---

# Release checklist

<!---Note all instances of xx should be replaced with the version number (e.g., the release for v3.30.20 would replace xx with 20)-->

<!-- Uncomment the option the pre-release checklist if doing a pre-release. -->
<!-- ## Checklist for before pre-release
- [ ] SS3 testing and debugging completed (RM and IT)
- [ ] Check artifact from the `call-build-ss3-warnings` GitHub action for useful warnings (RM and IT)
- [ ] r4ss updated (IT)
- [ ] Put together pre-release announcement (RM)
- [ ] code committed and tagged in repo as `v3.30.xx-prerel` (RM)
- [ ] All exes added to GitHub releases as `v3.30.xx-prerel` (RM)
- [ ] Announce prerelease (RM)
-->

## Checklist to get ready for release
- [ ] SS3 testing and debugging completed (RM and IT)
- [ ] Check artifact from the `call-build-ss3-warnings` GitHub action for useful warnings (RM and IT)
- [ ] r4ss updated (IT)
- [ ] Make sure all issues relevant to the release are marked with `v3.30.xx` milestone **AND** have `change log` label (RM/EG)

## Checklist for before release
- [ ] [Change log project board](https://github.com/orgs/nmfs-ost/projects/11) updated with any issues labelled "change log" (RM)
- [ ] Manual updated in repo (EG) - address at least issues with the [`v3.30.xx` release label](https://github.com/nmfs-ost/ss3-source-code/issues?q=is%3Aissue+milestone%3A3.30.xx).
- [ ] Manual release date and version changed in .tex file, tagged and added to a GitHub release, include attaching a pdf version (EG). (Instructions on [how to push a a local tag to a remote](https://github.com/nmfs-ost/ss3-source-code/wiki/Stock-Synthesis:-practices-for-maintainers#how-to-push-a-local-tag-up-to-github)).
- [ ] Manual release version on website updated once pdf and html built (EG) (update https://github.com/nmfs-ost/ss3-doc/blob/main/docs/SS330_User_Manual_release.html to the `v3.30.xx` version. Don't forget to change the version for the pdf link in the docs/index.md.
- [ ] Code committed and tagged in repo as `v3.30.xx`, which will trigger a GHA to build the release executables (EG) (Instructions on [how to push a a local tag to a remote](https://github.com/nmfs-ost/ss3-source-code/wiki/Stock-Synthesis:-practices-for-maintainers#how-to-push-a-local-tag-up-to-github))
- [ ] Exe and .tpl archived on [Google drive](https://drive.google.com/drive/folders/1Gh_dXi8v3rqawpwn2N6yaaEXZPq6G2io) (EG)
- [ ] All exes added to GitHub releases as `v3.30.xx` (EG) (get exes in the artifacts of the GHA that built the release exes) along with release notes
- [ ] Send out release announcement msg on VLab (RM)
- [ ] Add to release discussion on GitHub repository (EG)

## Checklist for after release
- [ ] Update user-example models using [this github action](https://github.com/nmfs-ost/ss3-user-examples/blob/main/R/update_examples.R) and tag with new release number after updating (EG)
- [ ] Update test models using [this github action](https://github.com/nmfs-ost/ss3-test-models/actions/workflows/update-ss3-models.yml) and tag with new release number after updating (EG)
- [ ] Removed "resolved" tag and close all issues worked in the milestone for this release (RM)
- [ ] Move unworked issues for the release milestone to the next milestone (RM)
