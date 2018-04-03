#
# Cookbook:: mariadb
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.
#
#rm -rf /var/lib/mysql

# install mariadb repo
# reference: https://downloads.mariadb.org/mariadb/repositories/#mirror=yamagata-university&distro=CentOS&distro_release=centos7-amd64--centos7&version=10.2
# 設定を反映
template '/etc/yum.repos.d/mariadb.repo' do
  source 'mariadb.repo.erb'
  owner 'root'
  group 'root'
  #mode 0644
end

# 本体のインストール
%w(mariadb mariadb-server).each do |pkg|
  yum_package pkg do
    action :install
    options "--enablerepo=mariadb"
  end
end

service 'nginx' do
  action [:enable, :start]
  supports status: true, restart: true, reload: true
end

package 'php-fpm' do
   flush_cache [:before]
   action [:install, :upgrade]
   options "--enablerepo=remi --enablerepo=remi-php72"
   notifies :reload, 'service[nginx]'
 end

package 'php-mysqlnd' do
  flush_cache [:before]
  action [:install, :upgrade]
  options "--enablerepo=remi --enablerepo=remi-php72"
  notifies :reload, 'service[nginx]'
end

service 'mariadb' do
  action [:enable, :start]
  supports :status => true, :restart => true, :reload => true
end

# mysql_secure_install とほぼ同じ事を実施
# reference https://easyramble.com/chef-mysql-install-config.html
execute "mysql_secure_install emulate" do
  # 念のため127.0.0.1 & ::1 は削除 戻す場合には "AND Host NOT IN ('localhost');"に追記して
  command <<-EOC
    mysql -u root -e "DELETE FROM mysql.user WHERE User='';"
    mysql -u root -e "DROP DATABASE test;"
    mysql -u root -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';"
    mysql -u root -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '::1', '127.0.0.1');"

    mysql -u root -e "SET PASSWORD FOR 'root'@'localhost' = PASSWORD('#{node['mariadb']['root_pass']}');" -D mysql
    mysql -u root -p#{node['mariadb']['root_pass']} -e "SET PASSWORD FOR 'root'@'127.0.0.1' = PASSWORD('#{node['mariadb']['root_pass']}');" -D mysql
    mysql -u root -p#{node['mariadb']['root_pass']} -e "SET PASSWORD FOR 'root'@'::1' = PASSWORD('#{node['mariadb']['root_pass']}');" -D mysql

    mysql -u root -p#{node['mariadb']['root_pass']} -e "FLUSH PRIVILEGES;"
  EOC
  only_if "mysql -u root -e 'show databases;'"
end

# 設定を反映
template '/etc/my.cnf.d/server.cnf' do
  source 'server.cnf.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[mariadb]'
end
