FROM golang:1.25.5-alpine AS builder

COPY . /build
WORKDIR /build

# add git so VCS info will be stamped in binary
# ignore warning that a specific version of git isn't pinned
# hadolint ignore=DL3018
RUN apk add --no-cache git

# build as PIE to take advantage of exploit mitigations
ARG CGO_ENABLED=0
ARG VERSION=devel
RUN go build -buildmode=pie -buildvcs=true -ldflags "-s -w -X main.version=${VERSION}" -trimpath -o go-project-template

# pie-loader is built and scanned daily, we want the most recent version
# hadolint ignore=DL3007
FROM ghcr.io/capnspacehook/pie-loader:latest
COPY --from=builder /build/go-project-template /go-project-template

USER 1000:1000

ENTRYPOINT [ "/go-project-template" ]
CMD [ "-version" ]
