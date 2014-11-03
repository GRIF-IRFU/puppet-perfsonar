require 'spec_helper'

def packages
  {
    'unspecificied-deps' => [
      'perl-Params-Validate',
      'perl-Class-Accessor',
    ],
    'deps' => [
      'libgomp',
      'httpd',
      'php',
      'php-gd',
      'php-xml',
      'php-snmp',
      'mysql',
      'mysql-devel',
      'perl-DBI',
      'perl-DBD-MySQL',
    ],
    '3.4' => {
      'iperf'   =>  'iperf3',
      'pkglist' => [
        'web100_userland',
        'owamp-client',
        'owamp-server',
        'bwctl-client',
        'bwctl-server',
        'ndt',
        'npad',
        'nuttcp',
        'perl-perfSONAR_PS-Toolkit',
        'perl-perfSONAR_PS-Toolkit-SystemEnvironment',
        'perl-perfSONAR_PS-LSCacheDaemon',
        'perl-perfSONAR_PS-LSRegistrationDaemon',
        'perl-perfSONAR_PS-MeshConfig-Agent',
        'perl-perfSONAR_PS-PingER-server',
        'perl-perfSONAR_PS-SimpleLS-BootStrap-client',
        'perl-perfSONAR_PS-SNMPMA',
        'perl-perfSONAR_PS-TracerouteMA-client',
        'perl-perfSONAR_PS-TracerouteMA-config',
        'perl-perfSONAR_PS-TracerouteMA-server',
        'perl-perfSONAR_PS-perfSONARBUOY-client',
        'perl-perfSONAR_PS-perfSONARBUOY-config',
        'perl-perfSONAR_PS-perfSONARBUOY-server',
        'tcptrace',
        'xplot-tcptrace',
        'tcpdump',
        'perl-Try-Tiny',
      ],
    }
  }
end

describe 'perfsonar' do

  let(:base_params) do
    {
      :web_pass => 'some_sha1_hash',
      :admin_name => 'Foo Bar',
      :site_name  => 'Site',
      :site_location  => 'Location',
      :site_projects => ['Internet2', 'OSG'],
      :administrator_email  => 'foobar@example.com',
      :city => 'City',
      :state  => 'TX',
      :country => 'US',
      :zipcode => '00000',
      :latitude => '0.000',
      :longitude => '0.000',
    }
  end

  let(:params) { base_params }

  let(:facts) do
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
    }
  end

  it "should enable_repos" do
    should contain_class('perfsonar::repos').with_enable_web100('false')
  end

  packages['unspecificied-deps'].each do |p|
    it { should contain_package(p).with_ensure('present') }
  end

  packages['deps'].each do |p|
    it { should contain_package(p).with_ensure('present') }
  end

  it { should contain_package(packages['3.4']['iperf']).with_ensure('present') }

  packages['3.4']['pkglist'].each do |p|
    it { should contain_package(p).with_ensure('present').that_notifies('Service[httpd]') }
  end

  it "should manage Service[httpd]" do
    should contain_service('httpd').with({
      :ensure     => 'running',
      :enable     => 'true',
      :hasrestart => 'true',
      :hasstatus  => 'true'
    })
  end

  it "should manage ipv4 firewall" do
    should contain_class('perfsonar::firewall::ipv4')
  end

  it "should manage ipv6 firewall" do
    should contain_class('perfsonar::firewall::ipv6')
  end

  it "should manage /opt/perfsonar_ps/mesh_config/etc/agent_configuration.conf" do
    should contain_file('/opt/perfsonar_ps/mesh_config/etc/agent_configuration.conf').with({
      :ensure   => 'present',
      :mode     => '0750',
      :owner    => 'perfsonar',
      :group    => 'perfsonar',
      :require  => 'Package[perl-perfSONAR_PS-MeshConfig-Agent]',
    })
  end

  it "should manage web login User" do
    should contain_user('admin').with({
      :ensure   => 'present',
      :shell    => '/bin/false',
      :gid      => 'admin',
      :groups   => 'psadmin',
      :password => params[:web_pass],
    })
  end

  it "should manage psadmin Group" do
    should contain_group('psadmin').with({
      :ensure => 'present',
      :require  => 'Package[perl-perfSONAR_PS-Toolkit]',
    })
  end

  it "should manage ls_cache_daemon Service" do
    should contain_service('ls_cache_daemon').with({
      :ensure     => 'running',
      :hasstatus  => 'false',
      :hasrestart => 'true',
      :require    => 'Package[perl-perfSONAR_PS-LSCacheDaemon]',
      :before     => 'Service[httpd]',
    })
  end

  it "should manage ls_registration_daemon Service" do
    should contain_service('ls_registration_daemon').with({
      :ensure     => 'running',
      :hasstatus  => 'false',
      :hasrestart => 'true',
      :require    => 'Package[perl-perfSONAR_PS-LSRegistrationDaemon]',
      :before     => 'Service[httpd]',
    })
  end

  it "should manage cassandra Service" do
    should contain_service('cassandra').with({
      :ensure     => 'running',
      :hasstatus  => 'true',
      :hasrestart => 'true',
      :require    => 'Package[perl-perfSONAR_PS-Toolkit]',
      :before     => 'Service[httpd]',
    })
  end

  it "should manage config_daemon Service" do
    should contain_service('config_daemon').with({
      :ensure     => 'running',
      :hasstatus  => 'false',
      :hasrestart => 'true',
      :require    => 'Package[perl-perfSONAR_PS-Toolkit]',
      :before     => 'Service[httpd]',
    })
  end

  [
    {:param => 'admin_name', :line => 'full_name'},
    {:param => 'site_name', :line => 'site_name'},
    {:param => 'site_location', :line => 'site_location'},
    {:param => 'administrator_email', :line => 'administrator_email'},
    {:param => 'city', :line => 'city'},
    {:param => 'state', :line => 'state'},
    {:param => 'country', :line => 'country'},
    {:param => 'zipcode', :line => 'zipcode'},
    {:param => 'latitude', :line => 'latitude'},
    {:param => 'longitude', :line => 'longitude'},
  ].each do |admin_info|
    it "should set #{admin_info[:line]}" do
      should contain_file_line(admin_info[:param]).with({
        :path     => '/opt/perfsonar_ps/toolkit/etc/administrative_info',
        :require  => 'Package[perl-perfSONAR_PS-Toolkit]',
        :notify   => 'Exec[/opt/perfsonar_ps/toolkit/scripts/update_administrative_info.pl]',
        :line     => "#{admin_info[:line]}=#{params[admin_info[:param].to_sym]}",
        :match    => "\^#{admin_info[:line]}",
      })
    end
  end

  it "should not contain File[/opt/perfsonar_ps/toolkit/etc/administrative_info]" do
    should_not contain_file('/opt/perfsonar_ps/toolkit/etc/administrative_info')
  end

  it "should have Exec for update_administrative_info.pl" do
    should contain_exec('/opt/perfsonar_ps/toolkit/scripts/update_administrative_info.pl').with({
      :refreshonly  => 'true',
      :require      => 'Package[perl-perfSONAR_PS-Toolkit]',
    })
  end

  context 'when enforce_admin_info => true' do
    let(:params) { base_params.merge({:enforce_admin_info => true}) }

    it { should have_file_line_resource_count(0) }

    it "should manage /opt/perfsonar_ps/toolkit/etc/administrative_info" do
      should contain_file('/opt/perfsonar_ps/toolkit/etc/administrative_info').with({
        :ensure => 'file',
        :owner  => 'root',
        :group  => 'root',
        :mode   => '0644',
        :notify => 'Exec[/opt/perfsonar_ps/toolkit/scripts/update_administrative_info.pl]',
      })
    end

    it "should have valid contents for /opt/perfsonar_ps/toolkit/etc/administrative_info" do
      verify_contents(catalogue, '/opt/perfsonar_ps/toolkit/etc/administrative_info', [
        "full_name=#{params[:admin_name]}",
        "site_name=#{params[:site_name]}",
        "site_location=#{params[:site_location]}",
        "site_project=Internet2",
        "site_project=OSG",
        "administrator_email=#{params[:administrator_email]}",
        "city=#{params[:city]}",
        "state=#{params[:state]}",
        "country=#{params[:country]}",
        "zipcode=#{params[:zipcode]}",
        "latitude=#{params[:latitude]}",
        "longitude=#{params[:longitude]}",
      ])
    end
  end
end