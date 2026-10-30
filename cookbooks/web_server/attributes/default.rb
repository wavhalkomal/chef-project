# The website name displayed on the generated home page.
default['web_server']['app_name'] = 'Komal Chef Demo'

# Dedicated Linux identity used to own the website files.
default['web_server']['app_user'] = 'chefapp'
default['web_server']['app_group'] = 'chefapp'

# Directory from which nginx will serve the website.
default['web_server']['document_root'] = '/var/www/chef-demo'

# Port on which the demonstration website will listen.
default['web_server']['port'] = 8080
