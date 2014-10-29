require 'spec_helper'

describe 'perfsonar::firewall::ipv6' do

  let(:facts) do
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
    }
  end

  it "should allow ICMP" do
    should contain_firewall('200 IN allow perfsonar PS specific ICMP v6').with({
      :provider => 'ip6tables',
      :proto    => 'ipv6-icmp',
      :icmp     => '255',
      :chain    => 'INPUT',
      :action   => 'accept',
    })
  end

  it "should allow OWAMP TCP" do
    should contain_firewall('200 IN allow perfsonar PS specific TCP ports (1)(stateless) v6').with({
      :provider => 'ip6tables',
      :proto    => 'tcp',
      :port     => '861',
      :chain    => 'INPUT',
      :action   => 'accept',
    })
  end

  it "should allow BWCTL TCP" do
    should contain_firewall('200 IN allow perfsonar PS specific TCP ports (2)(stateless) v6').with({
      :provider => 'ip6tables',
      :proto    => 'tcp',
      :port     => ['4823', '6001-6200', '5000-5900'],
      :chain    => 'INPUT',
      :action   => 'accept',
    })
  end

  it "should allow OWAMP UDP" do
    should contain_firewall('200 IN allow perfsonar PS specific UDP ports (1)(stateless) v6').with({
      :provider => 'ip6tables',
      :proto    => 'udp',
      :port     => '8760-9960',
      :chain    => 'INPUT',
      :action   => 'accept',
    })
  end

  it "should allow BWCTL UDP" do
    should contain_firewall('200 IN allow perfsonar PS specific UDP ports (2)(stateless) v6').with({
      :provider => 'ip6tables',
      :proto    => 'udp',
      :port     => ['6001-6200', '5000-5900'],
      :chain    => 'INPUT',
      :action   => 'accept',
    })
  end

  it "should allow traceroute UDP" do
    should contain_firewall('200 IN allow perfsonar PS specific UDP ports (3)(stateless) v6').with({
      :provider => 'ip6tables',
      :proto    => 'udp',
      :port     => '33434-33634',
      :chain    => 'INPUT',
      :action   => 'accept',
    })
  end
end