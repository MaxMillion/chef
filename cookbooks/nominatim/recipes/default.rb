#
# Cookbook Name:: nominatim
# Recipe:: default
#
# Copyright 2012, OpenStreetMap Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apache::ssl"
include_recipe "postgresql"
include_recipe "git"

package "php5"
package "php5-cli"
package "php5-pgsql"
package "php5-fpm"
package "php-pear"
package "php-apc"

apache_module "rewrite"

if node[:lsb][:release].to_f >= 14.04
  apache_module "proxy"
  apache_module "proxy_fcgi"
else
  apache_module "fastcgi-handler"
end

home_directory = data_bag_item("accounts", "nominatim")["home"]
source_directory = "#{home_directory}/nominatim"
email_errors = data_bag_item("accounts", "lonvia")["email"]

database_cluster = node[:nominatim][:database][:cluster]
database_version = database_cluster.sub(/\/.*/, "")
database_name = node[:nominatim][:database][:dbname]

postgis_version = node[:nominatim][:database][:postgis]

service "php5-fpm" do
  if node[:lsb][:release].to_f >= 14.04
    provider Chef::Provider::Service::Upstart
  end
  action [ :enable, :start ]
  supports :status => true, :restart => true, :reload => true
end

apache_site "nominatim.openstreetmap.org" do
  template "apache.erb"
  directory source_directory
  variables :pools => node[:nominatim][:fpm_pools]
end

apache_site "default" do
  action [ :disable ]
end

node[:nominatim][:fpm_pools].each do |name,data|
  template "/etc/php5/fpm/pool.d/#{name}.conf" do
    source "fpm.conf.erb"
    owner "root"
    group "root"
    mode 0644
    variables data.merge(:name => name, :port => data[:port])
    notifies :reload, "service[php5-fpm]"
  end
end

postgresql_user "tomh" do
  cluster database_cluster
  superuser true
end

postgresql_user "lonvia" do
  cluster database_cluster
  superuser true
end

postgresql_user "twain" do
  cluster database_cluster
  superuser true
end

postgresql_user "nominatim" do
  cluster database_cluster
  superuser true
end

postgresql_user "www-data" do
  cluster database_cluster
end

postgresql_munin "nominatim" do
  cluster database_cluster
  database database_name
end

directory "/var/log/nominatim" do
  owner "nominatim"
  group "nominatim"
  mode 0755
end

template "/etc/logrotate.d/nominatim" do
  source "logrotate.nominatim.erb"
  owner "root"
  group "root"
  mode 0644
end


package "osmosis"
package "gcc"
package "proj-bin"
package "libgeos-c1"
package "postgresql-#{database_version}-postgis-#{postgis_version}"
package "postgresql-server-dev-#{database_version}"
package "build-essential"
package "libxml2-dev"
package "libgeos-dev"
package "libgeos++-dev"
package "libpq-dev"
package "libbz2-dev"
package "libtool"
package "automake"
package "libproj-dev"
package "libprotobuf-c0-dev"
package "protobuf-c-compiler"
package "python-psycopg2"

execute "php-pear-db" do
  command "pear install DB"
  not_if { File.exists?("/usr/share/php/DB") }
end

execute "compile_nominatim" do
  action :nothing
  command "cd #{source_directory} && ./autogen.sh && ./configure && make"
  user "nominatim"
end

git source_directory do
  action :checkout
  repository node[:nominatim][:repository]
  enable_submodules true
  user "nominatim"
  group "nominatim"
  notifies :run, "execute[compile_nominatim]"
end

directory "#{source_directory}/log" do
  owner "nominatim"
  group "nominatim"
  mode 0755
end


template "#{source_directory}/.git/hooks/post-merge" do
  source "update_source.erb"
  owner  "nominatim"
  group  "nominatim"
  mode   0755
  variables :source_directory => source_directory
end

template "#{source_directory}/settings/local.php" do
  source "nominatim.erb"
  owner "nominatim"
  group "nominatim"
  mode 0664
end

template "#{source_directory}/settings/ip_blocks.conf" do
  action :create_if_missing
  source "ipblocks.erb"
  owner "nominatim"
  group "nominatim"
  mode 0664
end

file "#{source_directory}/settings/apache_blocks.conf" do
  action :create_if_missing
  owner "nominatim"
  group "nominatim"
  mode 0664
end

file "#{source_directory}/settings/ip_blocks.map" do
  action :create_if_missing
  owner "nominatim"
  group "nominatim"
  mode 0664
end

if node[:nominatim][:enabled]
  cron_action = :create
else
  cron_action = :delete
end

cron "nominatim_logrotate" do
  action cron_action
  hour "5"
  minute "30"
  weekday "0"
  command "#{source_directory}/utils/cron_logrotate.sh"
  user "nominatim"
  mailto email_errors
end

cron "nominatim_banip" do
  action cron_action
  command "#{source_directory}/utils/cron_banip.py"
  user "nominatim"
  mailto email_errors
end

cron "nominatim_vacuum" do
  action cron_action
  hour "2"
  minute "00"
  command "#{source_directory}/utils/cron_vacuum.sh"
  user "nominatim"
  mailto email_errors
end

template "#{source_directory}/utils/nominatim-update" do
  source "updater.erb"
  user   "nominatim"
  group  "nominatim"
  mode   0755
end

template "/etc/init.d/nominatim-update" do
  source "updater.init.erb"
  user   "nominatim"
  group  "nominatim"
  mode   0755
  variables :source_directory => source_directory
end

munin_plugin_conf "nominatim" do
  template "munin.erb"
end

munin_plugin "nominatim_importlag" do
  target "#{source_directory}/munin/nominatim_importlag"
end

munin_plugin "nominatim_query_speed" do
  target "#{source_directory}/munin/nominatim_query_speed"
end

munin_plugin "nominatim_requests" do
  target "#{source_directory}/munin/nominatim_requests"
end

munin_plugin "nominatim_throttled_ips" do
  target "#{source_directory}/munin/nominatim_throttled_ips"
end

template "/usr/local/bin/backup-nominatim" do
  source "backup-nominatim.erb"
  owner "root"
  group "root"
  mode 0755
end

cron "nominatim_backup" do
  action cron_action
  hour "3"
  minute "00"
  day "1"
  command "/usr/local/bin/backup-nominatim"
  user "nominatim"
  mailto email_errors
end
