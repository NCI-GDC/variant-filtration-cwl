ARG REGISTRY=docker.osdc.io
FROM ${REGISTRY}/ncigdc/bio-alpine:cwltool3 as builder

ARG WORKFLOW

COPY ./${WORKFLOW} /opt 
COPY ./tools /tools
COPY ./subworkflows /subworkflows

WORKDIR /opt

RUN just validate pack

FROM ${REGISTRY}/ncigdc/bio-alpine:just

COPY --from=builder /opt/cwl.json /opt/cwl.json
COPY --from=builder /opt/justfile /opt/justfile

WORKDIR /opt

ENTRYPOINT ["just"]

CMD ["_print-cwl"]
