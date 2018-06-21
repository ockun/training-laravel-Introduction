#
# Cookbook:: xdebug
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

%w(php-pear php-pecl-xdebug).each do |pkg|
  package pkg do
    action [:install, :upgrade]
    options "--enablerepo=remi-php72"
  end
end

# 設定を反映
template '/etc/php.d/xdebug.ini' do
  source 'xdebug.ini.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :restart, 'service[nginx]'
end

bash "add bashrc" do
  user 'vagrant'
  not_if "grep \"export PHP_IDE_CONFIG='serverName=192.168.33.10'\" /home/vagrant/.bashrc"
  code <<-EOC
    echo "export PHP_IDE_CONFIG='serverName=192.168.33.10'" >> /home/vagrant/.bashrc
  EOC
end
