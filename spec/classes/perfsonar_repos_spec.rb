require 'spec_helper'

describe 'perfsonar::repos' do

  let(:facts) do
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
    }
  end

  it "should manage GPG key" do
    should contain_file('RPM-GPG-KEY-Internet2').with({
      :ensure => 'present',
      :source => 'puppet:///modules/perfsonar/RPM-GPG-KEY-Internet2',
      :path   => '/etc/pki/rpm-gpg/RPM-GPG-KEY-Internet2',
    })
  end

  it "should manage Yumrepo Internet2" do
    should contain_yumrepo('Internet2').with({
      :baseurl  => 'http://software.internet2.edu/rpms/el6/$basearch/main',
      :gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Internet2',
      :descr    => 'Internet2 RPM Repository - software.internet2.edu - main',
      :enabled  => '1',
      :gpgcheck => '1',
    })
  end

  it "should not manage Yumrepo Internet2-web100" do
    should_not contain_yumrepo('Internet2-web100')
  end

  context "when enable_web100 => true" do
    let(:params) {{ :enable_web100 => true }}

    it "should not manage Yumrepo Internet2-web100" do
      should contain_yumrepo('Internet2-web100').with({
        :baseurl  => 'http://software.internet2.edu/web100_kernel/rpms/el6/$basearch/main',
        :gpgkey   => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-Internet2',
        :descr    => 'Internet2 web100 Kernel RPM Repository - software.internet2.edu - main',
        :enabled  => '1',
        :gpgcheck => '1',
      })
    end
  end
end