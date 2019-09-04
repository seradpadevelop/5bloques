/**
 * reads the nw-config yaml
 * Replaces the PK/Cert for the peers
 * CODE Replicated in events.js
 */
const fs = require('fs');
const yaml = require('node-yaml')

const CRYPTOGEN_PEER="../crypto/crypto-config/peerOrganizations"

var obj = yaml.readSync('./nw-config.template.yaml')
createYAMLCryptogen(obj)
console.log('done')

// console.log("obj=", obj)



// console.log(genCertPathCryptogen('seradpa'))
// console.log(genPkCryptogen("seradpa"))

// Generates the YAML based on the 
function createYAMLCryptogen(obj){
    let 5bloquesCert = genCertPathCryptogen('5bloques')
    let 5bloquesPk = genPkCryptogen("5bloques")
    obj.organizations.5bloques.signedCert.path=5bloquesCert
    obj.organizations.5bloques.adminPrivateKey.path=5bloquesPk
    let seradpaCert = genCertPathCryptogen('seradpa')
    let seradpaPk = genPkCryptogen("seradpa")
    obj.organizations.seradpa.signedCert.path=seradpaCert
    obj.organizations.seradpa.adminPrivateKey.path=seradpaPk

    console.log(5bloquesCert)
    yaml.writeSync("nw-config.yaml", obj)
}

function genCertPathCryptogen(org){ 
    //seradpa.com/users/Admin@seradpa.com/msp/signcerts/Admin@seradpa.com-cert.pem"
    var certPath=CRYPTOGEN_PEER+"/"+org+".com/users/Admin@"+org+".com/msp/signcerts/Admin@"+org+".com-cert.pem"
    return certPath
}

// looks for the PK files in the org folder
function    genPkCryptogen(org){
    // ../crypto/crypto-config/peerOrganizations/seradpa.com/users/Admin@seradpa.com/msp/keystore/05beac9849f610ad5cc8997e5f45343ca918de78398988def3f288b60d8ee27c_sk
    var pkFolder=CRYPTOGEN_PEER+"/"+org+".com/users/Admin@"+org+".com/msp/keystore"
    fs.readdirSync(pkFolder).forEach(file => {
        // console.log(file);
        // return the first file
        pkfile = file
        return
    })

    return pkFolder+"/"+pkfile
}