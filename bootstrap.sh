#!/bin/sh

echo "Enter SSH private key of server, base64 encoded"
read SSH_PRIVATE_KEY
echo "Enter eyaml private key, base64 encoded"
read EYAML_PRIVATE_KEY

cat > /etc/r10k.yaml << EOF
:cachedir: '/var/cache/r10k'
:sources:
  :plops:
    remote: 'git@github.com:gehel/puppetmaster.git'
    basedir: '/etc/puppet/environments'
:purgedirs:
  - '/etc/puppet/environments'
EOF

mkdir -p /etc/puppet/

echo $EYAML_PRIVATE_KEY | base64 -d > /etc/puppet/private_key.pkcs7.pem

mkdir /root/.ssh
echo $SSH_PRIAVTE_KEY | base64 -d > /root/.ssh/id_rsa
chmod 600 /root/.ssh/id_rsa
ssh-keyscan github.com >> /root/.ssh/known_hosts

echo 'make sure everything is up to date'
apt-get update
apt-get dist-upgrade -y

echo 'install puppet and dependencies'
wget http://apt.puppetlabs.com/puppetlabs-release-`lsb_release -cs`.deb
dpkg -i puppetlabs-release-`lsb_release -cs`.deb
apt-get update
apt-get install -y unattended-upgrades puppet git ruby
gem install --no-rdoc --no-ri r10k
gem install --no-rdoc --no-ri hiera-eyaml

/usr/local/bin/r10k -v info deploy environment

echo 'puppet run to ensure basic configuration'
puppet apply \
  --modulepath=/etc/puppet/environments/production/modules:/etc/puppet/environments/production/dist \
  --hiera_config=/etc/puppet/environments/production/hiera.yaml \
  /etc/puppet/environments/production/site/site.pp


echo 'Installation completed'

