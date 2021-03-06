#
# Cookbook Name:: subversion
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

include_recipe "apache"

package "subversion"

site_name = "svn.openstreetmap.org"
repository_directory = "/var/lib/subversion/repos/openstreetmap"

remote_directory "#{repository_directory}/hooks" do
  source "hooks"
  owner "www-data"
  group "www-data"
  mode 0755
  files_owner "www-data"
  files_group "www-data"
  files_mode 0755
  purge false
end

apache_module "dav" do
  package "apache2"
end

apache_module "dav_fs" do
  package "apache2"
end

apache_module "dav_svn" do
  package "libapache2-svn"
end

apache_module "authz_svn" do
  package "libapache2-svn"
end

apache_site site_name do
  template "apache.erb"
  directory repository_directory
  variables :realm => "Subversion Repository", :password_file => "/etc/apache2/svn.passwd"
end

template "/etc/cron.daily/svn-backup" do
  source "backup.cron.erb"
  owner "root"
  group "root"
  mode 0755
end
