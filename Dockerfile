ARG BUILDER_GOLANG_VERSION

FROM --platform=$TARGETPLATFORM gcr.io/spectro-images-public/golang:${BUILDER_GOLANG_VERSION}-alpine as builder
ARG CRYPTO_LIB
WORKDIR /workspace
COPY . .
RUN go mod download


RUN mkdir -p bin

RUN if [ ${CRYPTO_LIB} ]; \
    then \
      go-build-fips.sh -a -o bin/metrics-server cmd/metrics-server ;\
    else \
      go-build-static.sh -a -o bin/metrics-server cmd/metrics-server ;\
    fi

FROM --platform=$TARGETPLATFORM scratch
COPY --from=builder /workspace/bin/metrics-server /
USER 65534
ENTRYPOINT ["/metrics-server"]
