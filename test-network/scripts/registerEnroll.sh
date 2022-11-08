#!/bin/bashx

function createPeer() {
  subinfoln "Enrolling the CA admin of peerOrg"
  mkdir -p organizations/peerOrgs/${ORG_NAME}/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrgs/${ORG_NAME}
  export PEER_TLS_PATH=${PWD}/organizations/CAs/peers/${ORG_NAME}

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  printf "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_peer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_peer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_peer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_peer.pem
    OrganizationalUnitIdentifier: orderer" "${CA_PEER_PORT}" "${ORG_NAME}" "${CA_PEER_PORT}" "${ORG_NAME}" "${CA_PEER_PORT}" "${ORG_NAME}" "${CA_PEER_PORT}" "${ORG_NAME}" >${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml

  subinfoln "Registering ${PEER1_NAME}"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_peer --id.name ${PEER1_NAME} --id.secret ${PEER1_NAME}pw --id.type peer --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Registering ${PEER2_NAME}"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_peer --id.name ${PEER2_NAME} --id.secret ${PEER2_NAME}pw --id.type peer --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Registering peer ${ORG_NAME} user"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_peer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Registering peer ${ORG_NAME} admin"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_peer --id.name peer${ORG_NAME}admin --id.secret peer${ORG_NAME}adminpw --id.type admin --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Generating the ${PEER1_NAME} msp"
  set -x
  fabric-ca-client enroll -u https://${PEER1_NAME}:${PEER1_NAME}pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER1_NAME}/msp --csr.hosts ${PEER1_NAME}.${ORG_NAME}.com --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER1_NAME}/msp/config.yaml

  subinfoln "Generating the ${PEER2_NAME} msp"
  set -x
  fabric-ca-client enroll -u https://${PEER2_NAME}:${PEER2_NAME}pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER2_NAME}/msp --csr.hosts ${PEER2_NAME}.${ORG_NAME}.com --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER2_NAME}/msp/config.yaml

  subinfoln "Generating the ${PEER1_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${PEER1_NAME}:${PEER1_NAME}pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER1_NAME}/tls --enrollment.profile tls --csr.hosts ${PEER1_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Generating the ${PEER2_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${PEER2_NAME}:${PEER2_NAME}pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/peers/${PEER2_NAME}/tls --enrollment.profile tls --csr.hosts ${PEER2_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # ${PEER1_NAME}.${ORG_NAME}

  export PEER0_PATH=organizations/peerOrgs/${ORG_NAME}/peers/${PEER1_NAME}

  cp ${PWD}/${PEER0_PATH}/tls/tlscacerts/* ${PWD}/${PEER0_PATH}/tls/ca.crt
  cp ${PWD}/${PEER0_PATH}/tls/signcerts/* ${PWD}/${PEER0_PATH}/tls/server.crt
  cp ${PWD}/${PEER0_PATH}/tls/keystore/* ${PWD}/${PEER0_PATH}/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/tlscacerts
  cp ${PWD}/${PEER0_PATH}/tls/tlscacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/tlsca
  cp ${PWD}/${PEER0_PATH}/tls/tlscacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/tlsca/tlsca.${ORG_NAME}.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/ca
  cp ${PWD}/${PEER0_PATH}/msp/cacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/ca/ca.${ORG_NAME}.com-cert.pem

   # ${PEER2_NAME}.${ORG_NAME}

  export PEER1_PATH=organizations/peerOrgs/${ORG_NAME}/peers/${PEER2_NAME}

  cp ${PWD}/${PEER1_PATH}/tls/tlscacerts/* ${PWD}/${PEER1_PATH}/tls/ca.crt
  cp ${PWD}/${PEER1_PATH}/tls/signcerts/* ${PWD}/${PEER1_PATH}/tls/server.crt
  cp ${PWD}/${PEER1_PATH}/tls/keystore/* ${PWD}/${PEER1_PATH}/tls/server.key

  # mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/tlscacerts
  cp ${PWD}/${PEER1_PATH}/tls/tlscacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/tlscacerts/ca.crt

  # mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/tlsca
  cp ${PWD}/${PEER1_PATH}/tls/tlscacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/tlsca/tlsca.${ORG_NAME}.com-cert.pem

  # mkdir -p ${PWD}/organizations/peerOrgs/${ORG_NAME}/ca
  cp ${PWD}/${PEER1_PATH}/msp/cacerts/* ${PWD}/organizations/peerOrgs/${ORG_NAME}/ca/ca.${ORG_NAME}.com-cert.pem

  subinfoln "Generating the peer ${ORG_NAME} user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/users/User1@peer${ORG_NAME}.com/msp --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/peerOrgs/${ORG_NAME}/users/User1@peer${ORG_NAME}.com/msp/config.yaml

  subinfoln "Generating the peer ${ORG_NAME} admin msp"
  set -x
  fabric-ca-client enroll -u https://peer${ORG_NAME}admin:peer${ORG_NAME}adminpw@localhost:${CA_PEER_PORT} --caname ca_${ORG_NAME}_peer -M ${PWD}/organizations/peerOrgs/${ORG_NAME}/users/Admin@peer${ORG_NAME}.com/msp --tls.certfiles ${PEER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/peerOrgs/${ORG_NAME}/users/Admin@peer${ORG_NAME}.com/msp/config.yaml
}

function createOrderer_double() {
  subinfoln "Enrolling the CA admin of ordererOrg"
  mkdir -p organizations/ordererOrgs/${ORG_NAME}

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrgs/${ORG_NAME}
  export ORDERER_TLS_PATH=${PWD}/organizations/CAs/orderers/${ORG_NAME}

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  printf "NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-%s-ca_%s_orderer.pem
    OrganizationalUnitIdentifier: orderer" "${CA_ORDERER_PORT}" "${ORG_NAME}" "${CA_ORDERER_PORT}" "${ORG_NAME}" "${CA_ORDERER_PORT}" "${ORG_NAME}" "${CA_ORDERER_PORT}" "${ORG_NAME}" >${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/config.yaml

  subinfoln "Registering ${ORDERER1_NAME}"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_orderer --id.name ${ORDERER1_NAME} --id.secret ${ORDERER1_NAME}pw --id.type orderer --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Registering ${ORDERER2_NAME}"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_orderer --id.name ${ORDERER2_NAME} --id.secret ${ORDERER2_NAME}pw --id.type orderer --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Registering orderer ${ORG_NAME} admin"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_orderer --id.name orderer${ORG_NAME}admin --id.secret orderer${ORG_NAME}adminpw --id.type admin --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Generating the ${ORDERER1_NAME} msp"
  set -x
  fabric-ca-client enroll -u https://${ORDERER1_NAME}:${ORDERER1_NAME}pw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer -M ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER1_NAME}/msp --csr.hosts ${ORDERER1_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER1_NAME}/msp/config.yaml

  subinfoln "Generating the ${ORDERER2_NAME} msp"
  set -x
  fabric-ca-client enroll -u https://${ORDERER2_NAME}:${ORDERER2_NAME}pw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer -M ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER2_NAME}/msp --csr.hosts ${ORDERER2_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER2_NAME}/msp/config.yaml

  subinfoln "Generating the ${ORDERER1_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${ORDERER1_NAME}:${ORDERER1_NAME}pw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer -M ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER1_NAME}/tls --enrollment.profile tls --csr.hosts ${ORDERER1_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Generating the ${ORDERER2_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${ORDERER2_NAME}:${ORDERER2_NAME}pw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer -M ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER2_NAME}/tls --enrollment.profile tls --csr.hosts ${ORDERER2_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # ${ORDERER1_NAME}.${ORG_NAME}

  export ORDERER0_PATH=organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER1_NAME}

  cp ${PWD}/${ORDERER0_PATH}/tls/tlscacerts/* ${PWD}/${ORDERER0_PATH}/tls/ca.crt
  cp ${PWD}/${ORDERER0_PATH}/tls/signcerts/* ${PWD}/${ORDERER0_PATH}/tls/server.crt
  cp ${PWD}/${ORDERER0_PATH}/tls/keystore/* ${PWD}/${ORDERER0_PATH}/tls/server.key

  mkdir -p ${PWD}/${ORDERER0_PATH}/msp/tlscacerts
  cp ${PWD}/${ORDERER0_PATH}/tls/tlscacerts/* ${PWD}/${ORDERER0_PATH}/msp/tlscacerts/tlsca.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/tlscacerts
  cp ${PWD}/${ORDERER0_PATH}/tls/tlscacerts/* ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/tlscacerts/tlsca.com-cert.pem

  # ${ORDERER2_NAME}.${ORG_NAME}

  export ORDERER1_PATH=organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER2_NAME}

  cp ${PWD}/${ORDERER1_PATH}/tls/tlscacerts/* ${PWD}/${ORDERER1_PATH}/tls/ca.crt
  cp ${PWD}/${ORDERER1_PATH}/tls/signcerts/* ${PWD}/${ORDERER1_PATH}/tls/server.crt
  cp ${PWD}/${ORDERER1_PATH}/tls/keystore/* ${PWD}/${ORDERER1_PATH}/tls/server.key

  mkdir -p ${PWD}/${ORDERER1_PATH}/msp/tlscacerts
  cp ${PWD}/${ORDERER1_PATH}/tls/tlscacerts/* ${PWD}/${ORDERER1_PATH}/msp/tlscacerts/tlsca.com-cert.pem

  # mkdir -p ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/tlscacerts
  cp ${PWD}/${ORDERER1_PATH}/tls/tlscacerts/* ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/tlscacerts/tlsca.com-cert.pem

  subinfoln "Generating the orderer ${ORG_NAME} admin msp"
  set -x
  fabric-ca-client enroll -u https://orderer${ORG_NAME}admin:orderer${ORG_NAME}adminpw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer -M ${PWD}/organizations/ordererOrgs/${ORG_NAME}/admin/Admin@orderer${ORG_NAME}.com/msp --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/ordererOrgs/${ORG_NAME}/admin/Admin@orderer${ORG_NAME}.com/msp/config.yaml
}

function createOrderer_one() {
  subinfoln "Enrolling the CA admin of ordererOrg"
  mkdir -p organizations/ordererOrgs/${ORG_NAME}

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrgs/${ORG_NAME}
  export ORDERER_TLS_PATH=${PWD}/organizations/CAs/orderers/${ORG_NAME}

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-${CA_ORDERER_PORT}-ca_${ORG_NAME}_orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-${CA_ORDERER_PORT}-ca_${ORG_NAME}_orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-${CA_ORDERER_PORT}-ca_${ORG_NAME}_orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-${CA_ORDERER_PORT}-ca_${ORG_NAME}_orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/config.yaml

  subinfoln "Registering ${ORDERER1_NAME}"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_orderer --id.name ${ORDERER1_NAME} --id.secret ${ORDERER1_NAME}pw --id.type orderer --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Registering orderer ${ORG_NAME} admin"
  set -x
  fabric-ca-client register --caname ca_${ORG_NAME}_orderer --id.name orderer${ORG_NAME}admin --id.secret orderer${ORG_NAME}adminpw --id.type admin --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  subinfoln "Generating the ${ORDERER1_NAME} msp"
  set -x
  fabric-ca-client enroll -u https://${ORDERER1_NAME}:${ORDERER1_NAME}pw@localhost:${CA_ORDERER_PORT
  } --caname ca_${ORG_NAME}_orderer -M ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER1_NAME}/msp --csr.hosts ${ORDERER1_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER1_NAME}/msp/config.yaml

  subinfoln "Generating the ${ORDERER1_NAME}-tls certificates"
  set -x
  fabric-ca-client enroll -u https://${ORDERER1_NAME}:${ORDERER1_NAME}pw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer -M ${PWD}/organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER1_NAME}/tls --enrollment.profile tls --csr.hosts ${ORDERER1_NAME}.${ORG_NAME}.com --csr.hosts localhost --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  # ${ORDERER1_NAME}.${ORG_NAME}

  export ORDERER0_PATH=organizations/ordererOrgs/${ORG_NAME}/orderers/${ORDERER1_NAME}

  cp ${PWD}/${ORDERER0_PATH}/tls/tlscacerts/* ${PWD}/${ORDERER0_PATH}/tls/ca.crt
  cp ${PWD}/${ORDERER0_PATH}/tls/signcerts/* ${PWD}/${ORDERER0_PATH}/tls/server.crt
  cp ${PWD}/${ORDERER0_PATH}/tls/keystore/* ${PWD}/${ORDERER0_PATH}/tls/server.key

  mkdir -p ${PWD}/${ORDERER0_PATH}/msp/tlscacerts
  cp ${PWD}/${ORDERER0_PATH}/tls/tlscacerts/* ${PWD}/${ORDERER0_PATH}/msp/tlscacerts/tlsca.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/tlscacerts
  cp ${PWD}/${ORDERER0_PATH}/tls/tlscacerts/* ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/tlscacerts/tlsca.com-cert.pem

  subinfoln "Generating the orderer ${ORG_NAME} admin msp"
  set -x
  fabric-ca-client enroll -u https://orderer${ORG_NAME}admin:orderer${ORG_NAME}adminpw@localhost:${CA_ORDERER_PORT} --caname ca_${ORG_NAME}_orderer -M ${PWD}/organizations/ordererOrgs/${ORG_NAME}/admin/Admin@orderer${ORG_NAME}.com/msp --tls.certfiles ${ORDERER_TLS_PATH}/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrgs/${ORG_NAME}/msp/config.yaml ${PWD}/organizations/ordererOrgs/${ORG_NAME}/admin/Admin@orderer${ORG_NAME}.com/msp/config.yaml
}