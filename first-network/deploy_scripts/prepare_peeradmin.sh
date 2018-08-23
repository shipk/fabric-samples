# Remove old certs
rm certs/*

# SGOrg cert, escaping \
awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' ../crypto-config/peerOrganizations/sgorg.sg.com/peers/peer0.sgorg.sg.com/tls/ca.crt > certs/ca-sgorg.txt

# Orderer cert, escaping \
awk 'NF {sub(/\r/, ""); printf "%s\\\\n",$0;}' ../crypto-config/ordererOrganizations/sg.com/orderers/orderer.sg.com/tls/ca.crt > certs/ca-orderer.txt

# SGOrg admin cert
export SGORG=../crypto-config/peerOrganizations/sgorg.sg.com/users/Admin@sgorg.sg.com/msp
cp -p $SGORG/signcerts/Admin@sgorg.sg.com-cert.pem certs/.
cp -p $SGORG/keystore/*_sk certs/.

# Copy from template
cp connection_template.json connection_sg.json

# Replace to CA cert
CERT=`cat certs/ca-sgorg.txt`
sed -i "s#INSERT_SGORG_CA_CERT#${CERT}#g" connection_sg.json

# Replace to Orderer cert
CERT=`cat certs/ca-orderer.txt`
sed -i "s#INSERT_ORDERER_CA_CERT#${CERT}#g" connection_sg.json

# Create composer card for PeerAdmin
composer card create \
  --connectionProfileFile connection_sg.json \
  --user PeerAdmin \
  --certificate certs/Admin@sgorg.sg.com-cert.pem \
  --privateKey certs/*_sk \
  --role PeerAdmin \
  --role ChannelAdmin \
  --file PeerAdmin@sgnetwork.card

# remove old card from wallet, if that exists
composer card delete -c PeerAdmin@sgnetwork

# import new card to wallet
composer card import -f PeerAdmin@sgnetwork.card --card PeerAdmin@sgnetwork

# install business network
composer network install --card PeerAdmin@sgnetwork --archiveFile ./bna/splitgrid-network-0.0.2-deploy.38.bna

rm -r alice 

# Retrieving business network administrator certificates for SGOrg
composer identity request \
  --card PeerAdmin@sgnetwork \
  --user admin \
  --enrollSecret cuzdc65Q \
  --path alice

# start network
composer network start \
  --card PeerAdmin@sgnetwork \
  --networkName splitgrid-network \
  --networkVersion 0.0.2-deploy.38 \
  --option endorsementPolicyFile=endorsement-policy.json \
  --networkAdmin alice \
  --networkAdminEnrollSecret alice/admin-pub.pem

composer network start \
  --card PeerAdmin@sgnetwork \
  --networkName splitgrid-network \
  --networkVersion 0.0.2-deploy.38 \
  --networkAdmin alice \
  --networkAdminEnrollSecret alice/admin-pub.pem
