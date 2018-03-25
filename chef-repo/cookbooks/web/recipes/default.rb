#
# Cookbook:: web
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

yum_package "yum-fastestmirror" do
  action :install
end

execute "yum-update" do
  user "root"
  command "yum -y update"
  action :run
end


# package "httpd"
#
# service 'httpd' do
#   action [:enable, :start]
# end
# epel
package 'epel-release.noarch' do
  action :install
end

# remi-release-7
remote_file "#{Chef::Config[:file_cache_path]}/remi-release-7.rpm" do
    source "http://rpms.famillecollet.com/enterprise/remi-release-7.rpm"
    not_if "rpm -qa | grep -q '^remi-release'"
    action :create
    # notifies :install, "rpm_package[remi-release]", :immediately
end

# remi-release-7
rpm_package 'remi-release-7' do
  not_if "rpm -qa | grep -q '^remi-release'"
  source "#{Chef::Config[:file_cache_path]}/remi-release-7.rpm"
  action :install # defaults to :install if not specified
end

# php7
package 'php' do
  flush_cache [:before]
  action :install
  options "--enablerepo=remi --enablerepo=remi-php72"
end

%w(php-openssl php-common php-mbstring php-xml).each do |pkg|
  package pkg do
    action :install
    options "--enablerepo=remi --enablerepo=remi-php72"
  end
end

# install for git
%w(curl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel asciidoc xmlto docbook2X make gcc tcl perl-ExtUtils-MakeMaker autoconf).each do |pkg|
  yum_package pkg do
    action :install
    # options "--enablerepo=remi --enablerepo=remi-php72"
  end
end

# link for git
execute "ln-link" do
    user "root"
    command "ln -s /usr/bin/db2x_docbook2texi /usr/bin/docbook2x-texi"
    not_if { File.exists?("/usr/bin/docbook2x-texi") }
    action :run
end

# git install
bash "install_git" do
  not_if { File.exists?("/usr/bin/git") }
  user 'root'
  cwd '/tmp'
  code <<-EOH
    wget https://github.com/git/git/archive/v2.17.0-rc0.tar.gz
    tar -zxf v2.17.0-rc0.tar.gz
    cd git-2.17.0-rc0
    make configure
    ./configure --prefix=/usr
    make all doc info
    make install install-doc install-html install-info
  EOH
end

directory '/vagrant' do
  action :create
  owner  "vagrant"
  group "vagrant"
end

# install composer global
execute "install-composer" do
  creates "/vagrant/composer.phar"
  cwd '/vagrant'
  command "curl -sS https://getcomposer.org/installer | php "
end

# execute "remane-composer" do
#   creates "/vagrant/composer"
#   cwd '/vagrant'
#   command "mv composer.phar composer"
# end

# install for laravel
%w(zip unzip).each do |pkg|
  yum_package pkg do
    action :install
    # options "--enablerepo=remi --enablerepo=remi-php72"
  end
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

# link for git
# execute "ln-document-root" do
#     user "root"
#     command "ln -s /vagrant /vagrant"
#     creates "/vagrant"
#     action :run
# end

package "nginx"

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
end

service 'nginx' do
  action [:enable, :start]
end
