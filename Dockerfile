FROM registry.svc.ci.openshift.org/openshift/release:golang-1.12 AS builder
WORKDIR /go/src/github.com/openshift/cluster-config-operator
COPY . .
ENV GO_PACKAGE github.com/openshift/cluster-config-operator
RUN GODEBUG=tls13=1 go build -ldflags "-X $GO_PACKAGE/pkg/version.versionFromGit=$(git describe --long --tags --abbrev=7 --match 'v[0-9]*')" ./cmd/cluster-config-operator

FROM registry.svc.ci.openshift.org/ocp/4.2:base
RUN mkdir -p /usr/share/bootkube/manifests/manifests
RUN mkdir -p /usr/share/bootkube/manifests/bootstrap-manifests
COPY --from=builder /go/src/github.com/openshift/cluster-config-operator/manifests/* /usr/share/bootkube/manifests/manifests/
COPY --from=builder /go/src/github.com/openshift/cluster-config-operator/cluster-config-operator /usr/bin/
COPY manifests /manifests
COPY empty-resources /manifests
LABEL io.openshift.release.operator true
