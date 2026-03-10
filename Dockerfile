FROM lacledeslan/steamcmd:linux AS tf2c-builder

RUN mkdir --parents /output/TF2 && chmod 777 /output/TF2 && /app/steamcmd.sh +force_install_dir /output/TF2/ +login anonymous +app_update 232250 validate +quit

RUN mkdir --parents /output/classified && chmod 777 /output/classified && /app/steamcmd.sh +force_install_dir /output/classified/ +login anonymous +app_update 3557020 validate +quit && \
echo "3557020" > /output/classified/steam_appid.txt

# Grab x64 version of steamclient.so
RUN mkdir --parents /output/.steam/sdk64/ /app/ll-tests && \
    cp /app/linux64/steamclient.so /output/.steam/sdk64/steamclient.so

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

COPY --chown=TF2C:root --from=tf2c-builder /output /app

USER TF2C

WORKDIR /app/classified

ENV PORT=27015 \
MAXPLAYERS=24 \
STARTMAP="ctf_2fort" \
REGION=0 \
CFG_FILE="/app/classified/tf2classified/cfg/config_default.cfg" \
MAPCYCLE_FILE="/app/classified/tf2classified/cfg/mapcycle_default.txt" \
REPLAY=0 \
SRCDS_TOKEN=0 \
EXTRA_ARGS=""

ENTRYPOINT ["/bin/bash", "-c"]
CMD ["/app/classified/srcds.sh -tf_path /app/TF2 +map $STARTMAP +maxplayers $MAXPLAYERS +sv_region $REGION +sv_setsteamaccount $SRCDS_TOKEN -port $PORT +exec $CFG_FILE +maycyclefile $MAPCYCLE_FILE"]
CMD ["/app/classified/srcds.sh -tf_path /app/TF2 +map $STARTMAP +maxplayers $MAXPLAYERS +sv_region $REGION +sv_setsteamaccount $SRCDS_TOKEN -port $PORT +exec $CFG_FILE +mapcyclefile $MAPCYCLE_FILE"]
ONBUILD USER root
