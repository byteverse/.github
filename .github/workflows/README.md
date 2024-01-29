# .github/workflows

## build.yaml
A common workflow template for building Haskell projects.
Uses a GitHub-hosted runner.
Only performs clean builds.

Workflows can specify the following input parameters:
* docker-image: The name of the Docker image for the runner to use, e.g. "ubuntu-22.04"
* ghc-version: The GHC version to use, e.g. "9.4.7"
* cabal-version: The version of cabal to use, e.g. "3.10.1.0"
* release: set to true for a release build

Default values will be used if parameters aren't defined.
