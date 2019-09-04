export FABRIC_CFG_PATH=$PWD/config
configtxgen -outputBlock  ./config/ehealthgenesis.block -channelID ordererchannel  -profile EhealthOrdererGenesis
configtxgen -outputCreateChannelTx  ./config/ehealthchannel.tx -channelID ehealthchannel  -profile EhealthChannel