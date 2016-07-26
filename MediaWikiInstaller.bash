#!/bin/bash
python -mplatform | grep -qi Ubuntu && sudo apt-get update && sudo apt-get install -y build-essential git curl || sudo yum groupinstall -y "Development tools"&&yum install -y git curl
export PATH=/opt/chef/embedded/bin:$PATH
curl -L https://omnitruck.chef.io/install.sh | sudo bash -s -- -v 12.12.15
mkdir /cookbooks
cd /cookbooks
knife cookbook site download mediawiki
tar -xzf mediawiki*
cd mediawiki 
bundle install
$(find /opt/chef/embedded/lib/ruby/gems/ | grep bin | grep berks$ | head -1) vendor /cookbooks
chef-client --local-mode -o recipe['mediawiki']



