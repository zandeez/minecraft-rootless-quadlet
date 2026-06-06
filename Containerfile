FROM alpine:latest
RUN addgroup -S minecraft
RUN adduser -S minecraft -G minecraft
RUN apk add openjdk25-jre-headless 
RUN mkdir /opt/minecraft
RUN mkdir /data
RUN chown minecraft:minecraft /data
USER minecraft
WORKDIR /data
COPY minecraft_server.jar /opt/minecraft
COPY entrypoint.sh /opt/minecraft
ENTRYPOINT /opt/minecraft/entrypoint.sh
EXPOSE 25565/tcp 25575/tcp
