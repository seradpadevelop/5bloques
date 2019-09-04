#!/bin/bash

docker-compose down

# REMOVE the dev- container images also - TBD
docker rm $(docker ps -a -q)            &> /dev/null
docker rmi $(docker images dev-* -q)    &> /dev/null
sudo rm -rf $HOME/ledgers/ca &> /dev/null

docker-compose up -d

SLEEP_TIME=3s
echo    '========= Submitting txn for channel creation as 5bloquesAdmin ============'
export CHANNEL_TX_FILE=./config/ehealth-channel.tx
export ORDERER_ADDRESS=orderer.5bloques.com:7050
# export FABRIC_LOGGING_SPEC=DEBUG
export CORE_PEER_LOCALMSPID=5bloquesMSP
export CORE_PEER_MSPCONFIGPATH=$PWD/client/5bloques/admin/msp
export CORE_PEER_ADDRESS=5bloques-peer1.5bloques.com:7051
peer channel create -o $ORDERER_ADDRESS -c ehealthchannel -f ./config/ehealthchannel.tx

echo    '========= Joining the 5bloques-peer1 to Ehealth channel ============'
AIRLINE_CHANNEL_BLOCK=./ehealthchannel.block
export CORE_PEER_ADDRESS=5bloques-peer1.5bloques.com:7051
peer channel join -o $ORDERER_ADDRESS -b $AIRLINE_CHANNEL_BLOCK
# Update anchor peer on channel for 5bloques
# sleep  3s
sleep $SLEEP_TIME
ANCHOR_UPDATE_TX=./config/ehealth-anchor-update-5bloques.tx
peer channel update -o $ORDERER_ADDRESS -c ehealthchannel -f $ANCHOR_UPDATE_TX

echo    '========= Joining the seradpa-peer1 to Ehealth channel ============'
# peer channel fetch config $AIRLINE_CHANNEL_BLOCK -o $ORDERER_ADDRESS -c ehealthchannel
export CORE_PEER_LOCALMSPID=seradpaMSP
ORG_NAME=seradpa.com
export CORE_PEER_ADDRESS=seradpa-peer1.seradpa.com:8051
export CORE_PEER_MSPCONFIGPATH=$PWD/client/seradpa/admin/msp
peer channel join -o $ORDERER_ADDRESS -b $AIRLINE_CHANNEL_BLOCK
# Update anchor peer on channel for seradpa
sleep  $SLEEP_TIME
ANCHOR_UPDATE_TX=./config/ehealth-anchor-update-seradpa.tx
peer channel update -o $ORDERER_ADDRESS -c ehealthchannel -f $ANCHOR_UPDATE_TX

