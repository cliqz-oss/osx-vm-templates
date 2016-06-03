#!groovy

node('mac') {
  stage 'checkout'
  git url: 'https://github.com/cliqz-oss/osx-vm-templates'

  stage 'get base image'

  stage 'build image'
  dir('packer') {
    sh '''
      packer build \
        -var iso_url=../out/10.11.dmg \
        -var update_system=0 \
        template.json
    '''
  }

  stage 'copy box to repository'
}
