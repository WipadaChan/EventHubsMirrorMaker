#!/bin/bash
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

#SOURCE_DNS=$(parse_dns $SOURCE_CON_STR)
DEST_DNS=$(parse_dns $DEST_CON_STR)
CONSUMER_CONFIG="bootstrap.servers=52.175.55.32:9092\nrequest.timeout.ms=60000\ngroup.id=eh-mirrormaker-group\nexclude.internal.topics=true;"
echo -e $CONSUMER_CONFIG > consumer.config

PRODUCER_CONFIG="bootstrap.servers=$DEST_DNS:9093\nclient.id=mirror_maker_producer\nrequest.timeout.ms=60000\nsasl.mechanism=PLAIN\nsecurity.protocol=SASL_SSL\nsasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"\$ConnectionString\" password=\"$DEST_CON_STR\";"
echo -e $PRODUCER_CONFIG > producer.config

kafka-mirror-maker --consumer.config consumer.config --producer.config producer.config --whitelist=".*" --num.streams 8