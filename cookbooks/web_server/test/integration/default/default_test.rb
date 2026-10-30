# InSpec tests verify the state of the server after Chef runs.

control 'web-server-package' do
  impact 1.0
  title 'nginx is installed'

  describe package('nginx') do
    it { should be_installed }
  end
end

control 'web-server-identity' do
  impact 1.0
  title 'The application user and group exist'

  describe group('chefapp') do
    it { should exist }
  end

  describe user('chefapp') do
    it { should exist }
    its('group') { should eq 'chefapp' }
    its('shell') { should eq '/usr/sbin/nologin' }
  end
end

control 'web-server-content' do
  impact 1.0
  title 'The website directory and page are correct'

  describe directory('/var/www/chef-demo') do
    it { should exist }
    its('owner') { should eq 'chefapp' }
    its('group') { should eq 'chefapp' }
    its('mode') { should cmp '0755' }
  end

  describe file('/var/www/chef-demo/index.html') do
    it { should exist }
    its('content') { should match(/Komal Chef Demo/) }
  end
end

control 'web-server-service' do
  impact 1.0
  title 'nginx is running and responding'

  describe service('nginx') do
    it { should be_enabled }
    it { should be_running }
  end

  describe port(8080) do
    it { should be_listening }
  end

  describe http('http://127.0.0.1:8080/health') do
    its('status') { should cmp 200 }
    its('body') { should match(/healthy/) }
  end
end
