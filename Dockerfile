#syntax=docker/dockerfile:1-labs

ARG GO_VERSION=1.20.6
ARG ALPINE_VERSION=3.18
ARG RESTIC_VERSION

####################################################################################################
## Builder
####################################################################################################
FROM --platform=${BUILDPLATFORM} golang:${GO_VERSION}-alpine${ALPINE_VERSION} AS builder

ARG RESTIC_VERSION
ARG TARGETOS
ARG TARGETARCH

ENV CGO_ENABLE=0

RUN apk add --no-cache \
    ca-certificates \
    git

ADD --keep-git-dir=true https://github.com/restic/restic.git#v${RESTIC_VERSION} /restic

WORKDIR /restic

RUN go run helpers/build-release-binaries/main.go --platform "${TARGETOS}/${TARGETARCH}" --skip-compress && \
    mv "/output/restic_${TARGETOS}_${TARGETARCH}" /output/restic

####################################################################################################
## Final image
####################################################################################################
FROM alpine:${ALPINE_VERSION}

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    bash

COPY --from=builder --chmod=755 /output/restic /usr/local/bin
COPY --chmod=755 entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]

CMD ["restic", "--help"]

LABEL org.opencontainers.image.source="https://github.com/restic/restic.git"
LABEL org.opencontainers.image.licenses="BSD-2-Clause"
LABEL org.opencontainers.image.title="Restic"
LABEL org.opencontainers.image.description="Fast, secure, efficient backup program"