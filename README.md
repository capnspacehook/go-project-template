# go-project-template

Template repository for Go projects. Contains an example Go application and a minimal Dockerfile.

## Details

Dependabot is configured to keep Go, Docker and Github Actions dependencies up to date by opening
pull requests when new versions are released.

Multiple workflows are configured that will:

- Lint Go code with [`golangci-lint`](https://golangci-lint.run/) and [`staticcheck`](https://staticcheck.io/)
- Check that `go.mod` is tidied
- Test Go code and run all fuzz tests
- Check that generated files are up to date
- Scan for vulnerabilities with [`govulncheck`](https://pkg.go.dev/golang.org/x/vuln/cmd/govulncheck)
- Build, sign, publish binaries and create releases with [`goreleaser`](https://github.com/goreleaser/goreleaser) and [`cosign`](https://github.com/sigstore/cosign)
- Open pull requests to update the Go version in `go.mod` to the latest stable version
- Lint Dockerfiles with [`hadolint`](https://github.com/hadolint/hadolint)
- Build, publish and sign Docker images with [`cosign`](https://github.com/sigstore/cosign)
- Lint workflow files with [`actionlint`](https://github.com/rhysd/actionlint)
- Run Github CodeQL on Go code

Almost all workflows will trigger when appropriate files are modified from pushes or pull requests. 
Binaries will only be released when a semver compatible tag is pushed however.

For more details on the workflows see the https://github.com/capnspacehook/go-workflows.

## Usage

Use this repository as a template and build your project from it.

Almost all workflow files will work without modification, as will releasing Docker images and binaries with goreleaser.
Note that only `linux/amd64` images and binaries are built by default, so you may need to add more target
operating systems and/or architectures based off of your requirements.

The `Check generated files` job assumes code generation tools will be installed by running `go generate`.

The `Test` workflow will still pass if no tests or fuzz tests are present, so when you
do add tests and fuzz tests the workflow will run them without needing any changes from you.

When you want to change the Go version that is used in workflows, simply change the version of Go in the `go` directive of `go.mod`.

## Verifying releases

Verifying binaries or Docker images both require [cosign](https://github.com/sigstore/cosign).

### Verifying binaries

Download the checksums file, certificate and signature and the archive to the same directory.

Extract the binary from the archive, verify the checksums file and verify the contents of the binary:

```bash
tar xfs go-project-template_<version>_linux_amd64.tar.gz
cosign verify-blob --certificate checksums.txt.crt --signature checksums.txt.sig checksums.txt
sha256sum -c checksums.txt
```

### Verifying Docker images

Simply check the signature of the image with `cosign`:

```bash
COSIGN_EXPERIMENTAL=true cosign verify ghcr.io/capnspacehook/go-project-template | jq
```

You can verify the image was built by Github Actions by inspecting the `Issuer` and `Subject` fields of the output.
