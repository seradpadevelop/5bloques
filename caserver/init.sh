docker-compose -f docker-compose-ca.yaml down
rm -rf ./server/*
rm -rf ./client/*
cp fabric-ca-server-config.yaml ./server
docker-compose -f docker-compose-ca.yaml up -d

sleep 3s

# Bootstrap enrollment
export FABRIC_CA_CLIENT_HOME=$PWD/client/caserver/admin
fabric-ca-client enroll -u http://admin:adminpw@localhost:7054


######################
# Admin registration #
######################
echo "Registering: 5bloques-admin"
ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true","hf.Registrar.Attributes=*"'
fabric-ca-client register --id.type client --id.name 5bloques-admin --id.secret adminpw --id.affiliation 5bloques --id.attrs $ATTRIBUTES

# 3. Register seradpa-admin
echo "Registering: seradpa-admin"
ATTRIBUTES='"hf.Registrar.Roles=peer,user,client","hf.AffiliationMgr=true","hf.Revoker=true","hf.Registrar.Attributes=*"'
fabric-ca-client register --id.type client --id.name seradpa-admin --id.secret adminpw --id.affiliation seradpa --id.attrs $ATTRIBUTES

# 4. Register orderer-admin
echo "Registering: orderer-admin"
ATTRIBUTES='"hf.Registrar.Roles=orderer"'
fabric-ca-client register --id.type client --id.name orderer-admin --id.secret adminpw --id.affiliation orderer --id.attrs $ATTRIBUTES


####################
# Admin Enrollment #
####################
export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/admin
fabric-ca-client enroll -u http://5bloques-admin:adminpw@localhost:7054
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts

export FABRIC_CA_CLIENT_HOME=$PWD/client/seradpa/admin
fabric-ca-client enroll -u http://seradpa-admin:adminpw@localhost:7054
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts

export FABRIC_CA_CLIENT_HOME=$PWD/client/orderer/admin
fabric-ca-client enroll -u http://orderer-admin:adminpw@localhost:7054
mkdir -p $FABRIC_CA_CLIENT_HOME/msp/admincerts
cp $FABRIC_CA_CLIENT_HOME/../../caserver/admin/msp/signcerts/*  $FABRIC_CA_CLIENT_HOME/msp/admincerts

#################
# Org MSP Setup #
#################
# Path to the CA certificate
ROOT_CA_CERTIFICATE=./server/ca-cert.pem
mkdir -p ./client/orderer/msp/admincerts
mkdir ./client/orderer/msp/cacerts
mkdir ./client/orderer/msp/keystore
cp $ROOT_CA_CERTIFICATE ./client/orderer/msp/cacerts
cp ./client/orderer/admin/msp/signcerts/* ./client/orderer/msp/admincerts   

mkdir -p ./client/5bloques/msp/admincerts
mkdir ./client/5bloques/msp/cacerts
mkdir ./client/5bloques/msp/keystore
cp $ROOT_CA_CERTIFICATE ./client/5bloques/msp/cacerts
cp ./client/5bloques/admin/msp/signcerts/* ./client/5bloques/msp/admincerts   

mkdir -p ./client/seradpa/msp/admincerts
mkdir ./client/seradpa/msp/cacerts
mkdir ./client/seradpa/msp/keystore
cp $ROOT_CA_CERTIFICATE ./client/seradpa/msp/cacerts
cp ./client/seradpa/admin/msp/signcerts/* ./client/seradpa/msp/admincerts   

######################
# Orderer Enrollment #
######################
export FABRIC_CA_CLIENT_HOME=$PWD/client/orderer/admin
fabric-ca-client register --id.type orderer --id.name orderer --id.secret adminpw --id.affiliation orderer 
export FABRIC_CA_CLIENT_HOME=$PWD/client/orderer/orderer
fabric-ca-client enroll -u http://orderer:adminpw@localhost:7054
cp -a $PWD/client/orderer/admin/msp/signcerts  $FABRIC_CA_CLIENT_HOME/msp/admincerts

####################
# Peer Enrollments #
####################
export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/admin
fabric-ca-client register --id.type peer --id.name 5bloques-peer1 --id.secret adminpw --id.affiliation 5bloques 
export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/peer1
fabric-ca-client enroll -u http://5bloques-peer1:adminpw@localhost:7054
cp -a $PWD/client/5bloques/admin/msp/signcerts  $FABRIC_CA_CLIENT_HOME/msp/admincerts

export FABRIC_CA_CLIENT_HOME=$PWD/client/seradpa/admin
fabric-ca-client register --id.type peer --id.name seradpa-peer1 --id.secret adminpw --id.affiliation seradpa
export FABRIC_CA_CLIENT_HOME=$PWD/client/seradpa/peer1
fabric-ca-client enroll -u http://seradpa-peer1:adminpw@localhost:7054
cp -a $PWD/client/seradpa/admin/msp/signcerts  $FABRIC_CA_CLIENT_HOME/msp/admincerts


##############################
# User Enrollments 5bloques only #
##############################
export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/admin
ATTRIBUTES='"hf.AffiliationMgr=false:ecert","hf.Revoker=false:ecert","app.accounting.role=manager:ecert","department=accounting:ecert"'
fabric-ca-client register --id.type user --id.name mary --id.secret pw --id.affiliation 5bloques --id.attrs $ATTRIBUTES
export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/mary
fabric-ca-client enroll -u http://mary:pw@localhost:7054
cp -a $PWD/client/5bloques/admin/msp/signcerts  $FABRIC_CA_CLIENT_HOME/msp/admincerts

export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/admin
ATTRIBUTES='"hf.AffiliationMgr=false:ecert","hf.Revoker=false:ecert","app.accounting.role=accountant:ecert","department=accounting:ecert"'
fabric-ca-client register --id.type user --id.name john --id.secret pw --id.affiliation 5bloques --id.attrs $ATTRIBUTES
export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/john
fabric-ca-client enroll -u http://john:pw@localhost:7054
cp -a $PWD/client/5bloques/admin/msp/signcerts  $FABRIC_CA_CLIENT_HOME/msp/admincerts

export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/admin
ATTRIBUTES='"hf.AffiliationMgr=false:ecert","hf.Revoker=false:ecert","department=logistics:ecert","app.logistics.role=specialis:ecert"'
fabric-ca-client register --id.type user --id.name anil --id.secret pw --id.affiliation 5bloques --id.attrs $ATTRIBUTES
export FABRIC_CA_CLIENT_HOME=$PWD/client/5bloques/anil
fabric-ca-client enroll -u http://anil:pw@localhost:7054
cp -a $PWD/client/5bloques/admin/msp/signcerts  $FABRIC_CA_CLIENT_HOME/msp/admincerts

# Shutdown CA
docker-compose -f docker-compose-ca.yaml down

# Setup network config
export FABRIC_CFG_PATH=$PWD/config
configtxgen -outputBlock  ./config/orderer/ehealth-genesis.block -channelID ordererchannel  -profile EhealthOrdererGenesis
configtxgen -outputCreateChannelTx  ./config/ehealthchannel.tx -channelID ehealthchannel  -profile EhealthChannel

ANCHOR_UPDATE_TX=./config/ehealth-anchor-update-5bloques.tx
configtxgen -profile EhealthChannel -outputAnchorPeersUpdate $ANCHOR_UPDATE_TX -channelID ehealthchannel -asOrg 5bloquesMSP

ANCHOR_UPDATE_TX=./config/ehealth-anchor-update-seradpa.tx
configtxgen -profile EhealthChannel -outputAnchorPeersUpdate $ANCHOR_UPDATE_TX -channelID ehealthchannel -asOrg seradpaMSP
