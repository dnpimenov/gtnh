FROM openjdk:8-jdk as base
RUN apt -y update && \
    apt -y upgrade
WORKDIR /opt

FROM base as bootstrap
RUN apt -y install maven
RUN wget -O bootstrap.jar http://get.ultramine.ru/bootstrap.jar
RUN mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get \
        -Dartifact=org.scala-lang.modules:scala-swing_2.11:1.0.1 && \
    mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get \
        -Dartifact=org.scala-lang.modules:scala-parser-combinators_2.11:1.0.1 && \
    mvn org.apache.maven.plugins:maven-dependency-plugin:3.3.0:get \
        -Dartifact=org.scala-lang.modules:scala-xml_2.11:1.0.2 && \
    mv ~/.m2/repository/org/scala-lang/modules/* ~/.m2/repository/org/scala-lang
RUN java -jar bootstrap.jar --install
RUN rm bootstrap.jar
RUN chmod +x start.sh
RUN chmod +x ultramine_server_run_line.sh

FROM base as ultramine
WORKDIR /opt
COPY --from=bootstrap /opt /opt

FROM ultramine as gtnh
ARG GTNH_VERSION=2.1.2.3qf
RUN \
  apt -y install \
    mc \
    nano \
    vim \
    htop \
    ncdu \
    atop
RUN wget -O server.zip http://downloads.gtnewhorizons.com/ServerPacks/GTNewHorizonsServer-1.7.10-${GTNH_VERSION}.zip
RUN unzip server.zip
RUN rm server.zip

RUN rm mods/magicbees-1.7.10-2.5.8-GTNH.jar
ADD . .

VOLUME [ \
  "/opt/logs", \
  "/opt/settings", \
  "/opt/storage", \
  "/opt/visualprospecting", \
  "/opt/GregTech.lang", \
  "/opt/minetweaker.log", \
  "/opt/server.properties", \
  "/opt/worlds", \
]

ARG JAVA_XMS=2G
ARG JAVA_XMX=8G
ENV JAVA_XMS ${JAVA_XMS}
ENV JAVA_XMX ${JAVA_XMX}
# ENTRYPOINT [ "/bin/bash", "./gtnh.sh" ]
EXPOSE 6586/tcp
