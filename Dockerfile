FROM lacledeslan/steamcmd:linux AS TF2C-builder

RUN mkdir --parents /output/TF2; /app/steamcmd.sh +force_install_dir /output/TF2 +login anonymous +app_update 232250 validate +quit

RUN mkdir --parents /output/classified; /app/steamcmd.sh +force_install_dir /output/classified +login anonymous +app_update 3557020 validate +quit

# Grab x64 version of steamclient.so
RUN mkdir --parents /output/TF2/.steam/sdk64/ /app/ll-tests && \
    cp /app/linux64/steamclient.so /output/TF2/.steam/sdk64/steamclient.so

FROM debian:trixie-slim

ARG BUILDNODE=unspecified
ARG SOURCE_COMMIT=unspecified

RUN apt-get update && \
    apt-get install --no-install-recommends --no-install-suggests -y \
        ca-certificates locales locales-all tmux && \
    apt-get clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/* && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    useradd --home /app --gid root --system TF2C && \
    mkdir --parents /app && \
    chown TF2C:root -R /app

COPY --chown=TF2C:root --from=TF2C-builder /output/classified /app/classified
COPY --chown=TF2C:root --from=TF2C-builder /output/TF2 /app/TF2

USER TF2C

WORKDIR /app

CMD ["/bin/bash"]

ONBUILD USER root
