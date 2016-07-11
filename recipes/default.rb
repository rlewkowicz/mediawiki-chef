#
# Cookbook Name:: mediawiki
# Recipe:: default
#
# Maintainer: ryan.lewkowicz@spindance.com
#

#Initialize some varibles
def random_password
  require 'securerandom'
  SecureRandom.base64
end

password = random_password
datadir = node['mediawiki']['data_home']
sitehome = node['mediawiki']['site_home']

#create user for nginx/hhvm
user node['mediawiki']['hhvm']['user']

#create base dirs
directory datadir do
  recursive true
end

directory sitehome do
  recursive true
end

#Set up Docker
docker_installation 'default' do
  repo 'test'
  action :create
end

service "docker" do
  action [ :enable, :start ]
end

docker_service 'default' do
  daemon
  action [:create, :start]
end

#Set up Maria 

#So we have the client outside of the container
package 'mariadb' 

file '/root/.my.cnf' do
  if !node['mycnf_set']
    content lazy { "[mysql]\nuser=root\npassword=#{password}\n\n[mysqldump]\nuser=root\npassword=#{password}\n[client]\nprotocol=tcp" }
    mode 0600
    sensitive true
  end
end
  
ruby_block 'mycnf_set' do
  block do
    node.normal['mycnf_set'] = true
    node.save
  end
end 

docker_image "mariadb" do
  action :pull
  tag "#{node['mediawiki']['mariadb']['tag']}"
end

docker_container node['mediawiki']['mariadb']['container_name'] do
  repo 'mariadb'
  tag "#{node['mediawiki']['mariadb']['tag']}"
  action :redeploy 
  tty true
  network_mode 'host'
  env ["MYSQL_ROOT_PASSWORD=#{password}", "MYSQL_USER=root@#{node['ipaddress']}", "MYSQL_PASSWORD=#{password}"]
  volumes [ "#{datadir}:#{datadir}", '/root/.my.cnf:/etc/mysql/conf.d/.my.cnf' ]
  ignore_failure true
end

#Setup Nginx
remote_directory '/etc/nginx'

docker_image "nginx" do
  action :pull
  tag node['mediawiki']['nginx']['tag']
end

docker_container node['mediawiki']['nginx']['container_name'] do
  repo 'nginx'
  tag node['mediawiki']['nginx']['tag']
  network_mode 'host'
  volumes [ "#{sitehome}:#{sitehome}", '/etc/nginx:/etc/nginx' ]
  action :redeploy
  ignore_failure true
end

#Setup HHVM
docker_image 'fpm' do
  repo 'rlewkowicz/php-fpm'
  action :pull
  tag 'latest'
end

docker_container 'fpm' do
  repo 'rlewkowicz/php-fpm'
  tag 'latest'
  action :redeploy
  network_mode 'host'
  volumes "#{sitehome}:#{sitehome}" 
  command 'php-fpm'
  ignore_failure true
  signal 'SIGKILL'
end

#Setup MediaWiki
docker_image "rlewkowicz/mediawiki" do
  action :pull
  tag node['mediawiki']['tag']
end
  
execute 'init_mediawiki' do
    command 'docker cp mediawiki:/var/www/mediawiki /var/www/&&chown -R nginx.nginx /var/www/mediawiki'
    action :nothing
end

docker_container "initalize media wiki" do
  container_name node['mediawiki']['container_name']
  repo 'rlewkowicz/mediawiki'
  tag node['mediawiki']['tag']
  action :redeploy
  network_disabled true
  tty true
  command '/bin/bash'
  ignore_failure true
  notifies :run, 'execute[init_mediawiki]', :immediately
  not_if { node['mediawiki_init'] }
end  

ruby_block 'mediawiki_init_set' do
  block do
    node.normal['mediawiki_init'] = true
    node.save
  end
end 

docker_container "media wiki continuence" do
  container_name node['mediawiki']['container_name']
  repo 'rlewkowicz/mediawiki'
  tag node['mediawiki']['tag']
  network_disabled true
  action :redeploy
  tty true
  command '/bin/bash'
  ignore_failure true
  volumes "#{sitehome}:/var/www/mediawiki"
  only_if { node['mediawiki_init'] }
end  
