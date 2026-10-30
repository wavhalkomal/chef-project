# The cookbook name must match the cookbook directory and run list.
name 'web_server'

# Identify the person maintaining the cookbook.
maintainer 'Komal Wavhal'

# State how others may use this learning project.
license 'MIT'

# Explain the cookbook's purpose in one sentence.
description 'Installs and configures a beginner nginx web server using Chef'

# Cookbook versions help teams track and release changes.
version '1.0.0'

# This project uses modern Chef syntax.
chef_version '>= 18.0'

# The recipe is written and tested for Ubuntu systems.
supports 'ubuntu', '>= 20.04'
