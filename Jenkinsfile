#!groovy

node(BUILD_NODE_LABEL) {
  stage 'checkout'
  git url: 'https://github.com/cliqz-oss/osx-vm-templates'
  
  stage 'cleanup previous builds'
  sh 'rm -rf output-vmware-iso'
  sh 'rm -rf packer/packer_vmware-iso_vmware.box'
 
  stage 'build image'
  dir('packer') {
    sh """#!/bin/bash -l
      packer build \
        -var iso_url=${BASE_ISO_PATH} \
        -var update_system=0 \
        -only vmware-iso \
        template.json
    """
  }
  
  stage 'copy box to repository'
  sh "/usr/local/bin/vagrant box add mac-browser_ios-v${env.BUILD_ID} packer/packer_vmware-iso_vmware.box"
}
