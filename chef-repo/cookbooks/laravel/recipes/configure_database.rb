#
# Cookbook:: laravel
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# create database
execute "create database" do
 command <<-EOH
  mysql -u root -p#{node['mariadb']['root_pass']} -e "CREATE DATABASE IF NOT EXISTS #{node['laravel']['database_name']} DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
 EOH
end

execute "create-user" do
  command <<-EOH
    mysql -u root -p#{node['mariadb']['root_pass']} -e "GRANT ALL ON #{node['laravel']['database_name']}.* TO '#{node['laravel']['database_user']}'@'localhost' IDENTIFIED BY '#{node['laravel']['database_pass']}'"
  EOH
end

# 上記別方法 検討のため保留
# execute "create-user" do
#   command "mysql -u root -p#{node['mariadb']['root_pass']} #{node['laravel']['database_name']} < /tmp/grants.sql"
#   user "root"
#   action :nothing
# end
#

# configure database.php file
template "/vagrant/laravelapp/config/database.php" do
    source "database_dev.php.erb"
end

# configure .env file
template "/vagrant/laravelapp/.env" do
    source ".env.erb"
end
