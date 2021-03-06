#
# Cookbook Name:: chef
# Definition:: ohai_plugin
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

define :ohai_plugin, :action => [ :create, :delete ] do
  plugin_name = params[:name]
  plugin_action = params[:action]

  if plugin_action.include?(:create)
    ohai plugin_name do
      action :nothing
    end

    template "/etc/chef/ohai/#{plugin_name}.rb" do
      source params[:template]
      owner "root"
      group "root"
      mode 0644
      notifies :reload, "ohai[#{plugin_name}]"
    end
  elsif plugin_action.include?(:delete)
    template "/etc/chef/ohai/#{plugin_name}.rb" do
      action :delete
    end
  end
end
