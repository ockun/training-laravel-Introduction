#
# Cookbook:: mariadb
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
%w(mariadb mariadb-server).each do |pkg|
  yum_package pkg do
    action :install
    # options "--enablerepo=remi --enablerepo=remi-php72"
  end
end

service 'mariadb' do
  action [:enable, :start]
end

# template '/etc/nginx/nginx.conf' do
#   source 'nginx.conf.erb'
#   owner 'root'
#   group 'root'
#   mode 0644
#   notifies :reload, 'service[nginx]'
# end
