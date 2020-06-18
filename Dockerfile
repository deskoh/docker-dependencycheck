ARG BASE_REGISTRY=registry.access.redhat.com
ARG BASE_IMAGE=ubi8/ubi-minimal
ARG BASE_TAG=latest

FROM ${BASE_REGISTRY}/${BASE_IMAGE}:${BASE_TAG} as base

RUN microdnf update -y && rm -rf /var/cache/yum
RUN microdnf install --nodocs java-1.8.0-openjdk && \
    microdnf clean all;

ENV \
    JAVA_HOME="/usr/lib/jvm/jre" \
    JAVA_VENDOR="openjdk" \
    JAVA_VERSION="1.8.0"

ARG VERSION=5.3.2

RUN microdnf install --nodocs unzip && \
    curl -L https://dl.bintray.com/jeremy-long/owasp/dependency-check-${VERSION}-release.zip -o dc.zip  && \
    unzip dc.zip -d /usr/share/  && \
    rm -f dc.zip && \
    microdnf remove unzip && \
    microdnf clean all

RUN /usr/share/dependency-check/bin/dependency-check.sh --updateonly

WORKDIR /usr/share/dependency-check/bin/

CMD ["--help"]
ENTRYPOINT ["/usr/share/dependency-check/bin/dependency-check.sh"]
