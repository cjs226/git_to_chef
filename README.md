## Description

git_to_chef will compare the cookbooks in Git to those in a Chef Environment.
If there are new and/or updated cookbooks in Git, it'll either log it or
upload/freeze the affected cookbooks, update the stated environment, upload
databags, upload roles then send an email notification.  Note, if you run as an
upload, it will upload all data bags and roles no matter the status of
cookbooks.

## Longer Description

The Chef workflow that's currently working for us is:
  * Edit cookbooks, etc. in a non-master branch in Git
  * Test in a non-production environment
  * Commit/Push changes
  * Send a Pull Request and collaborate
  * Edit/test more, if needed
  * Merge the Pull Request to Master
  * Manually run git_to_push as an upload that will:
    * Pull from Git
    * Upload new(er) cookbooks
    * Freeze new(er) cookbooks
    * Update the Production environment with the cookbook versions from Git
    * Graph the upload in Graphite
    * Upload ALL databags from Git
    * Upload ALL roles from Git
    * Send an email notification of the proceedings
  * git_to_push runs hourly in report mode to nag us of changes that haven't
    been uploaded to Chef

## Requirements

### Platform

Tested on Ubuntu.

### Dependencies

Requires Opscode's logrotate cookbook.

### Setup

You need to setup a data bag to store settings needed.  By default, it expects a
data bag named "configs" and a data bag item named "git_to_chef" but the names
can be overridden in the role.  The following are the settings that need to be
set in the data bag item:

	"chef_repo_path": "~/github/score/chef-repo",
	"emailee":	"changeme@foo.com",
	"environment":	"production",
	"log": {
		"path": "/var/log/foo"
	},
	"scratch_dir":	"/tmp",
	"script_path":	"/opt/foo/bin"

If you want to run the report via cron, add the following:

	"cron": {
		"hour":		"*",
		"minute":	"15",
		"run_as_user":	"root"
	},

If you want to use logrotate, add the following to the log stanza:

		"rotate_count": "14",
		"rotate_frequency": "daily"

## Extra Credit

If you want to graph uploads in Graphite, you'll need to store 'graphite_server'
and 'carbon_port' in a(nother) data bag.  I again use my "configs" data bag and
a data bag item named "graphite":

	override_attributes(
	  "git_to_chef"  => {
	    "graphite_cfg_db" => "configs",
	    "graphite_cfg_dbi" => "graphite"
	  }
	)

And use the following data:

	"carbon": {
		"port":		"2003"
	},
	"server":	"graphite.foo.com"

## License and Author

Author: Clif Smith(clif@texicans.us)

Copyright 2012, Clif Smith

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
