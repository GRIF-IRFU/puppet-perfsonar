require 'spec_helper'

describe 'perfsonar::firewall::ipv4' do

  let(:facts) do
    {
      :osfamily => 'RedHat',
      :operatingsystemrelease => '6.5',
      :operatingsystemmajrelease => '6',
    }
  end

  it "should allow ICMP" do
    should contain_firewall('200 IN allow perfsonar PS specific ICMP').with({
      :proto  => 'icmp',
      :icmp   => '255',
      :chain  => 'INPUT',
      :action => 'accept',
    })
  end

  it "should allow OWAMP TCP" do
    should contain_firewall('200 IN allow perfsonar PS specific TCP ports (1)(stateless)').with({
      :proto  => 'tcp',
      :port   => '861',
      :chain  => 'INPUT',
      :action => 'accept',
    })
  end

  it "should allow BWCTL TCP" do
    should contain_firewall('200 IN allow perfsonar PS specific TCP ports (2)(stateless)').with({
      :proto  => 'tcp',
      :port   => ['4823', '6001-6200', '5000-5900'],
      :chain  => 'INPUT',
      :action => 'accept',
    })
  end

  it "should allow OWAMP UDP" do
    should contain_firewall('200 IN allow perfsonar PS specific UDP ports (1)(stateless)').with({
      :proto  => 'udp',
      :port   => '8760-9960',
      :chain  => 'INPUT',
      :action => 'accept',
    })
  end

  it "should allow BWCTL UDP" do
    should contain_firewall('200 IN allow perfsonar PS specific UDP ports (2)(stateless)').with({
      :proto  => 'udp',
      :port   => ['6001-6200', '5000-5900'],
      :chain  => 'INPUT',
      :action => 'accept',
    })
  end

  it "should allow traceroute UDP" do
    should contain_firewall('200 IN allow perfsonar PS specific UDP ports (3)(stateless)').with({
      :proto  => 'udp',
      :port   => '33434-33634',
      :chain  => 'INPUT',
      :action => 'accept',
    })
  end

  it "should allow web interface access" do
    should contain_firewall('200 IN allow perfsonar PS web interface access (stateless) from 129.79.53.0/24').with({
      :proto  => 'tcp',
      :dport  => ['80','443'],
      :source => '129.79.53.0/24',
      :chain  => 'INPUT',
      :action => 'accept',
    })

    should contain_firewall('200 IN allow perfsonar PS web interface access (stateless) from 192.41.231.110/32').with({
      :proto  => 'tcp',
      :dport  => ['80','443'],
      :source => '192.41.231.110/32',
      :chain  => 'INPUT',
      :action => 'accept',
    })
  end
end