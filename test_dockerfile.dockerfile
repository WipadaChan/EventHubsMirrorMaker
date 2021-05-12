FROM mcr.microsoft.com/azureml/intelmpi2018.3-ubuntu16.04
RUN mkdir -p /usr/src/app
#COPY ./app/mirrorstart.sh /usr/src/app/mirrorstart.sh

# Install OpenJDK-8
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
    apt-get install -y ant && \
    apt-get clean;

# Fix certificate issues
RUN apt-get update && \
    apt-get install ca-certificates-java && \
    apt-get clean && \
    update-ca-certificates -f;

# Setup JAVA_HOME -- useful for docker commandline
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/
RUN export JAVA_HOME

WORKDIR /usr/src/app
ADD mirrormaker.sh /
COPY mirrormaker.sh /usr/src/app/mirrormaker.sh
#ADD test.sh /
#COPY test.sh /usr/src/app/test.sh

RUN wget http://www-us.apache.org/dist/kafka/2.7.0/kafka_2.13-2.7.0.tgz && \
    tar -xzf kafka_2.13-2.7.0.tgz && mv kafka_2.13-2.7.0 /usr/src/app/kafka;

#give ARG RAILS_ENV a default value = production
#ARG DEST_CON_STR="Endpoint=sb://wcpevent.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=a9k5Z+TGMpBnLDrShEKhQY0nsYPmqwTbGjQW66xNx5o="

#assign the $RAILS_ENV arg to the RAILS_ENV ENV so that it can be accessed
#by the subsequent RUN call within the container
#ENV DEST_CON_STR $DEST_CON_STR

ENTRYPOINT ["/usr/src/app/mirrormaker.sh", "$DEST_CON_STR"]
#ENTRYPOINT ["/usr/src/app/mirrorstart.sh", "$DEST_CON_STR"]

#CMD [ "/kafka_2.13-2.7.0/bin/kafka-topics.sh", "--version" ]