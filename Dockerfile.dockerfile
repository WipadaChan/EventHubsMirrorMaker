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

RUN wget http://www-us.apache.org/dist/kafka/2.7.0/kafka_2.13-2.7.0.tgz && \
    tar -xzf kafka_2.13-2.7.0.tgz && mv kafka_2.13-2.7.0 /usr/src/app/kafka;


ENTRYPOINT ["/usr/src/app/mirrormaker.sh", "$DEST_CON_STR"]
