###########################################################################
#         
#  Build the image:                                                       
#    $ docker build -t stanbol:release1.16-alpine3.6 --no-cache -f stanbol-release.alpine.dockerfile . # longer but more accurate
#    $ docker build -t stanbol:release1.16-alpine3.6 .                                              # faster but increase mistakes
#                                                                         
#  Run the container:                                                     
#    $ docker run -it --rm -v $(pwd)/shared:/shared -p 9998:9998 -p 8010:8010 stanbol:release1.16-alpine3.6
#    $ docker run -d --name stanbol -p 9998:9998 -p 8010:8010 -v $(pwd)/shared:/shared stanbol:release1.16-alpine3.6
#                                                                     
###########################################################################

FROM alpine:3.6
LABEL maintainer "Luc Michalski <michalski.luc@gmail.com>"

ARG STANBOL_VERSION=${STANBOL_VERSION:-"1.16"}
EXPOSE 9001 9998 8010

ENTRYPOINT ["java", "-jar", "/app/stanbol-server-${VERSION}.jar", "-p", "8010", "-h", "0.0.0.0"]
# CMD []

ADD http://www.apache.org/dist/stanbol/stanbol-server-${STANBOL_VERSION}.jar -s -o /app/stanbol-server-${STANBOL_VERSION}.jar

# Install Java 8  (JRE) and Tika
RUN apk add --no-cache --no-progress --update curl openjdk8-jre 
