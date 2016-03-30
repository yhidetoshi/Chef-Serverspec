require 'spec_helper'

=begin
describe package('httpd') do
  it { should be_installed }
end
=end

=begin
describe service('httpd') do
  it { should be_enabled   }
  it { should be_running   }
end
=end

describe port(80) do
  it { should be_listening }
end

=begin
describe file('/etc/httpd/conf/httpd.conf') do
  it { should be_file }
  it { should contain "ServerName www.example.jp" }
end

=end

describe package('python') do
 it { should be_installed }
end


describe command('which httpd') do
 its(:exit_status) {should eq 0}
end
