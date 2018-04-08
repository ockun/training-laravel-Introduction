#
# Cookbook:: git
# Recipe:: default
#
# Copyright:: 2018, The Authors, All Rights Reserved.

# install packages for git
%w(curl-devel expat-devel gettext-devel openssl-devel perl-devel zlib-devel asciidoc xmlto docbook2X make gcc tcl perl-ExtUtils-MakeMaker autoconf).each do |pkg|
  yum_package pkg do
    action :install
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
