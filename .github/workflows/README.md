# .github/workflows

All workflows run on GitHub runners using the latest ubuntu image.
Only performs clean builds.

## build-matrix.yaml
A common workflow template for building feature branches.
Triggered whenever a pull request is opened or updated.
Builds against all GHC versions defined in a project's cabal file.

Workflows must specify the following input parameter:
* cabal-file: The cabal file to use, e.g. "my-project.cabal"

## release.yaml
A common workflow for building Hackage releases.
Only builds against the GHC version currently used by Hackage.
Triggered whenever a new tag is pushed to origin.
