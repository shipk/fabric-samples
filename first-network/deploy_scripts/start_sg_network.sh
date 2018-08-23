# Remove old certs

rm -if ./tmp/certs/*

# SGOrg cert, escaping \
awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' ../crypto-config/peerOrganizations/sgorg.sg.com/peers/peer0.sgorg.sg.com/tls/ca.crt > ./tmp/certs/ca-sgorg.txt

# Orderer cert, escaping \
awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' ../crypto-config/ordererOrganizations/sg.com/orderers/orderer.sg.com/tls/ca.crt > ./tmp/certs/ca-orderer.txt

# SGOrg admin cert
export SGORG=../crypto-config/peerOrganizations/sgorg.sg.com/users/Admin@sgorg.sg.com/msp
cp -p $SGORG/signcerts/Admin@sgorg.sg.com-cert.pem ./tmp/certs/.
cp -p $SGORG/keystore/*_sk ./tmp/certs/.

# Copy from template
cp connection_template.json ./tmp/connection_sg.json

# Replace to CA cert
CERT=`cat ./tmp/certs/ca-sgorg.txt`
sed -i "s#INSERT_SGORG_CA_CERT#${CERT}#g" ./tmp/connection_sg.json

# Replace to Orderer cert
CERT=`cat ./tmp/certs/ca-orderer.txt`
sed -i "s#INSERT_ORDERER_CA_CERT#${CERT}#g" ./tmp/connection_sg.json

# Create composer card for PeerAdmin
composer card create \
  --connectionProfileFile ./tmp/connection_sg.json \
  --user PeerAdmin \
  --certificate ./tmp/certs/Admin@sgorg.sg.com-cert.pem \
  --privateKey ./tmp/certs/*_sk \
  --role PeerAdmin \
  --role ChannelAdmin \
  --file ./tmp/PeerAdmin@sgnetwork.card

# remove old card from wallet, if that exists
composer card delete -c PeerAdmin@sgnetwork

# import new card to wallet
composer card import -f ./tmp/PeerAdmin@sgnetwork.card 

# install business network
composer network install --card PeerAdmin@sgnetwork --archiveFile ./bna/splitgrid-network-0.0.2-deploy.38.bna


# Retrieving business network administrator certificates for SGOrg
# admin/cuzdc65Q - user configured in CA (see docker-compose-cas-template.yaml)
#composer identity request \
#  --card PeerAdmin@sgnetwork \
#  --user admin \
#  --enrollSecret cuzdc65Q \
#  --path alice

skip () {
# start network
composer network start \
  --card PeerAdmin@sgnetwork \
  --networkName splitgrid-network \
  --networkVersion 0.0.2-deploy.38 \
  --option endorsementPolicyFile=endorsement-policy.json \
  --networkAdmin alice \
  --networkAdminEnrollSecret alice/admin-pub.pem

composer card delete -c alice@splitgrid-network

composer card create \
  -p connection_sg.json \
  -u alice \
  -n sgnetwork \
  -c alice/admin-pub.pem \
  -k alice/admin-priv.pem

composer card import -f alice@splitgrid-network.card

composer network ping -c alice@splitgrid-network
}

composer network start \
  --card PeerAdmin@sgnetwork \
  --networkName splitgrid-network \
  --networkVersion 0.0.2-deploy.38 \
  --networkAdmin admin \
  --networkAdminEnrollSecret cuzdc65Q
# --option endorsementPolicyFile=endorsement-policy.json \
  
composer card delete -c admin@splitgrid-network
composer card import -f admin@splitgrid-network.card

composer network ping -c admin@splitgrid-network
