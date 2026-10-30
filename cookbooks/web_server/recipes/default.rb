# Cookbook:: web_server
# Recipe:: default
#
# This recipe describes the final state of our Ubuntu web server.

# Refresh Ubuntu's package list when it has not been refreshed recently.
apt_update 'refresh package information' do
  frequency 86_400
  action :periodic
end

# Install nginx. Chef skips installation when the package is already present.
package 'nginx' do
  action :install
end

# Read reusable values from the attributes file.
app_user = node['web_server']['app_user']
app_group = node['web_server']['app_group']
document_root = node['web_server']['document_root']

# Create a system group for the application files.
group app_group do
  system true
  action :create
end

# Create a service account. It cannot be used for an interactive login.
user app_user do
  gid app_group
  shell '/usr/sbin/nologin'
  system true
  manage_home false
  action :create
end

# Create the directory that stores the website.
directory document_root do
  owner app_user
  group app_group
  mode '0755'
  recursive true
  action :create
end

# Enable nginx at system startup and make sure it is running now.
service 'nginx' do
  action [:enable, :start]
end

# Generate the website from an ERB template.
template "#{document_root}/index.html" do
  source 'index.html.erb'
  owner app_user
  group app_group
  mode '0644'
  variables(
    app_name: node['web_server']['app_name']
  )
end

# Generate our nginx site configuration from a second ERB template.
template '/etc/nginx/sites-available/chef-demo' do
  source 'nginx-site.conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    document_root: document_root,
    port: node['web_server']['port']
  )
  # Reload nginx at the end of the Chef run only when this file changes.
  notifies :reload, 'service[nginx]', :delayed
end

# Enable our site by creating a symbolic link in sites-enabled.
link '/etc/nginx/sites-enabled/chef-demo' do
  to '/etc/nginx/sites-available/chef-demo'
  notifies :reload, 'service[nginx]', :delayed
end

# Remove Ubuntu's default nginx site so it does not conflict with our site.
file '/etc/nginx/sites-enabled/default' do
  action :delete
  notifies :reload, 'service[nginx]', :delayed
end
