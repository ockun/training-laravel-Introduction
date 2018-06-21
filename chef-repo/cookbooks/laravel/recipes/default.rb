#
# Cookbook:: laravel
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

include_recipe "git::default"

# install for laravel
%w(zip unzip).each do |pkg|
  yum_package pkg do
    action :install
    # options "--enablerepo=remi-php72"
  end
end

# install composer in directory
execute "install-composer" do
  creates "/vagrant/composer.phar"
  cwd '/vagrant'
  command "curl -sS https://getcomposer.org/installer | php "
end

# install Lanavel framework
execute "install-lanavel" do
    command "./composer.phar global require \"laravel/installer=~1.1\""
    cwd '/vagrant'
    not_if { File.exists?("/usr/bin/docbook2x-texi") } # @todo
    action :run
end

# install Lanavel framework
execute "create-lanavel-project" do
    command "./composer.phar create-project laravel/laravel laravelapp --prefer-dist"
    cwd '/vagrant'
    not_if { File.exists?("/vagrant/laravelapp") } # @todo
    action :run
end

directory '/var/app/laravelapp/storage' do
  group                      "vagrant"
  # inherits                   true
  mode                       777
  # notifies                   # see description
  owner                      "vagrant"
  # path                       String # defaults to 'name' if not specified
  recursive                  true
  # rights                     Hash
  # subscribes                 # see description
  action                     :create
end

