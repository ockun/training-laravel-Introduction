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
  supports :status => true, :restart => true, :reload => true
end

execute "set_root_pass" do
  command "mysqladmin -u root password '#{node['mariadb']['root_pass']}'"
  only_if "mysql -u root -e 'show databases;'"
end

template '/etc/my.cnf.d/server.cnf' do
  source 'server.cnf.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[mariadb]'
end
