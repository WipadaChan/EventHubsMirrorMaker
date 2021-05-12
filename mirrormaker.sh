#!/bin/bash
pwd

set -e
parse_dns () {
        START=`expr index "$1" sb://`
        END=`expr index "$1" \;`
        SSTART=$((START+5))
        #SSTART=$(echo $START + 5 | bc)
        #SEND=$(echo $END -$SSTART -1 | bc)
        SEND=$(($END -$SSTART -1))
        echo `expr substr $1 $SSTART $SEND`
}

DEST_DNS=$(parse_dns $DEST_CON_STR)
CONSUMER_CONFIG="bootstrap.servers=172.17.0.4:9092\nrequest.timeout.ms=60000\ngroup.id=eh-mirrormaker-group\nexclude.internal.topics=true"
echo -e $CONSUMER_CONFIG > consumer.properties

PRODUCER_CONFIG="bootstrap.servers=$DEST_DNS:9093\nclient.id=mirror_maker_producer\nrequest.timeout.ms=60000\nsasl.mechanism=PLAIN\nsecurity.protocol=SASL_SSL\nsasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"\$ConnectionString\" password=\"$DEST_CON_STR\";"
echo -e $PRODUCER_CONFIG > producer.properties

cat producer.properties

./kafka/bin/kafka-topics.sh --version
./kafka/bin/kafka-run-class.sh kafka.tools.MirrorMaker --consumer.config consumer.properties --producer.config producer.properties --whitelist=".*" --num.streams 8