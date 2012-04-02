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

# Set attributes for the git user
default['gitlab']['gitlab_user_name'] = "gitlab"
default['gitlab']['gitlab_user_group_name'] = "gitlab"
default['gitlab']['gitlab_user_comment'] = "Gitlab User"
default['gitlab']['gitlab_user_home_dir'] = "/home/gitlab"
default['gitlab']['gitlab_user_default_shell'] = "/bin/bash"
default['gitlab']['gitlab_user_password'] = ""
default['gitlab']['gitlab_user_mode'] = "0755"
