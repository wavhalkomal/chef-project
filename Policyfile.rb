# Give this Chef policy a readable name.
name 'web_server_policy'

# Declare Chef Supermarket as the source for community cookbooks.
# Our web_server cookbook is local, but declaring a source is standard Policyfile practice.
default_source :supermarket

# Tell Chef which recipe should run on the target server.
run_list 'web_server::default'

# Tell Chef where our local cookbook is located.
cookbook 'web_server', path: 'cookbooks/web_server'
