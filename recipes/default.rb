#
# Cookbook Name:: git_to_chef
# Recipe:: default
#
# Copyright 2012, Clif Smith
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

# Retrieve git_to_chef's config from it's data bag
gtc_cfg_db = node['git_to_chef']['gtc_cfg_db']
gtc_cfg_dbi = node['git_to_chef']['gtc_cfg_dbi']
gtc_cfg = data_bag_item(:"#{gtc_cfg_db}", "#{gtc_cfg_dbi}")

# If we're using Graphite, retrieve git_to_chef's config from it's data bag
if node.git_to_chef.attribute?("graphite_cfg_db")
  graphite_cfg_db = node['git_to_chef']['graphite_cfg_db']
  graphite_cfg_dbi = node['git_to_chef']['graphite_cfg_dbi']
  graphite_cfg = data_bag_item(:"#{graphite_cfg_db}", "#{graphite_cfg_dbi}")
  carbon_port = graphite_cfg['carbon']['port']
  graphite_server = graphite_cfg['server']
end

# Build out the script
script_path = gtc_cfg['script_path']
template "#{script_path}/git_to_chef.rb" do
  source "git_to_chef.rb.erb"
  mode "0755"
  variables(:emailee => gtc_cfg['emailee'],
            :carbon_port => "#{carbon_port}",
            :graphite_server => "#{graphite_server}",
            :hostname => node['hostname'],
            :scratch_dir => gtc_cfg['scratch_dir'])
end

# Setup log rotation, if warranted
log_rotate_frequency = gtc_cfg['log']['rotate_frequency']
if "#{log_rotate_frequency}" != ""
  log_path = gtc_cfg['log']['path']
  logrotate_app "git_to_chef.log" do
    cookbook "logrotate"
    path "#{log_path}/git_to_chef.log"
    frequency "#{log_rotate_frequency}"
    create "644 root logs"
    rotate gtc_cfg['log']['rotate_count']
  end
end

# Setup our crontab, if warranted
chef_repo_path = gtc_cfg['chef_repo_path']
cron_hour = gtc_cfg['cron']['hour']
cron_minute = gtc_cfg['cron']['minute']
environment = gtc_cfg['environment']
if "#{cron_minute}" != ""
  cron "git_to_chef" do
    hour "#{cron_hour}"
    minute "#{cron_minute}"
    user gtc_cfg['cron']['user']
    command "#{script_path}/git_to_chef.rb -f report -c #{chef_repo_path} -e #{environment} 2>&1 | logger -t git_to_chef.log -p local7.info"
  end
end
