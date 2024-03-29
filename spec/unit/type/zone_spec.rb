#! /usr/bin/env ruby
require 'spec_helper'

describe Puppet::Type.type(:zone), type: :type do
  let(:zone)     { described_class.new(name: 'dummy', path: '/dummy', provider: :solaris, ip: 'if:1.2.3.4:2.3.4.5', inherit: '/', dataset: 'tank') }
  let(:provider) { zone.provider }
  let(:ip)      { zone.property(:ip) }
  let(:inherit) { zone.property(:inherit) }
  let(:dataset) { zone.property(:dataset) }

  parameters = [:create_args, :install_args, :sysidcfg, :realhostname]

  parameters.each do |parameter|
    it "has a #{parameter} parameter" do
      expect(described_class.attrclass(parameter).ancestors).to be_include(Puppet::Parameter)
    end
  end

  properties = [:ip, :iptype, :autoboot, :pool, :shares, :inherit, :path]

  properties.each do |property|
    it "has a #{property} property" do
      expect(described_class.attrclass(property).ancestors).to be_include(Puppet::Property)
    end
  end

  describe 'when trying to set a property that is empty' do
    it 'verifies that property.insync? of nil or :absent is true' do
      [inherit, ip, dataset].each do |prop|
        allow(prop).to receive(:should).and_return []
      end
      expect([inherit, ip, dataset]).to all(be_insync(nil))
      expect([inherit, ip, dataset]).to all(be_insync(:absent))
    end
  end
  describe 'when trying to set a property that is non empty' do
    it 'verifies that property.insync? of nil or :absent is false' do
      [inherit, ip, dataset].each do |prop|
        allow(prop).to receive(:should).and_return ['a', 'b']
      end
      [inherit, ip, dataset].each do |prop|
        expect(prop).not_to be_insync(nil)
      end
      [inherit, ip, dataset].each do |prop|
        expect(prop).not_to be_insync(:absent)
      end
    end
  end
  describe 'when trying to set a property that is non empty' do
    it 'insync? should return true or false depending on the current value, and new value' do
      [inherit, ip, dataset].each do |prop|
        allow(prop).to receive(:should).and_return ['a', 'b']
      end
      expect([inherit, ip, dataset]).to all(be_insync(['b', 'a']))
      [inherit, ip, dataset].each do |prop|
        expect(prop).not_to be_insync(['a'])
      end
    end
  end

  it 'accepts a path' do
    described_class.new(name: 'dummy', path: '/dummy', provider: :solaris)
  end

  it 'is invalid when :ip is missing a ":" and iptype is :shared' do
    expect {
      described_class.new(name: 'dummy', ip: 'if', path: '/dummy', provider: :solaris)
    }.to raise_error(Puppet::Error, %r{ip must contain interface name and ip address separated by a ":"})
  end

  it 'is invalid when :ip has a ":" and iptype is :exclusive' do
    expect {
      described_class.new(name: 'dummy', ip: 'if:1.2.3.4', iptype: :exclusive, provider: :solaris)
    }.to raise_error(Puppet::Error, %r{only interface may be specified when using exclusive IP stack})
  end

  it 'is invalid when :ip has two ":" and iptype is :exclusive' do
    expect {
      described_class.new(name: 'dummy', ip: 'if:1.2.3.4:2.3.4.5', iptype: :exclusive, provider: :solaris)
    }.to raise_error(Puppet::Error, %r{only interface may be specified when using exclusive IP stack})
  end

  it 'is valid when :iptype is :shared and using interface and ip' do
    described_class.new(name: 'dummy', path: '/dummy', ip: 'if:1.2.3.4', provider: :solaris)
  end

  it 'is valid when :iptype is :shared and using interface, ip and default route' do
    described_class.new(name: 'dummy', path: '/dummy', ip: 'if:1.2.3.4:2.3.4.5', provider: :solaris)
  end

  it 'is valid when :iptype is :exclusive and using interface' do
    described_class.new(name: 'dummy', path: '/dummy', ip: 'if', iptype: :exclusive, provider: :solaris)
  end

  it 'auto-requires :dataset entries' do
    fs = 'random-pool/some-zfs'

    catalog = Puppet::Resource::Catalog.new
    relationship_graph = Puppet::Graph::RelationshipGraph.new(Puppet::Graph::SequentialPrioritizer.new)
    zfs = Puppet::Type.type(:zfs).new(name: fs)
    catalog.add_resource zfs

    zone = described_class.new(name: 'dummy',
                               path: '/foo',
                               ip: 'en1:1.0.0.0',
                               dataset: fs,
                               provider: :solaris)
    catalog.add_resource zone

    relationship_graph.populate_from(catalog)
    expect(relationship_graph.dependencies(zone)).to eq([zfs])
  end
  describe Puppet::Zone::StateMachine do
    let(:sm) { described_class.new }

    before :each do
      sm.insert_state :absent, down: :destroy
      sm.insert_state :configured, up: :configure, down: :uninstall
      sm.insert_state :installed, up: :install, down: :stop
      sm.insert_state :running, up: :start
    end

    context ':insert_state' do
      it 'inserts state in correct order' do
        sm.insert_state :dummy, left: :right
        expect(sm.index(:dummy)).to eq(4)
      end
    end
    context ':alias_state' do
      it 'aliases state' do
        sm.alias_state :dummy, :running
        expect(sm.name(:dummy)).to eq(:running)
      end
    end
    context ':name' do
      it 'gets an aliased state correctly' do
        sm.alias_state :dummy, :running
        expect(sm.name(:dummy)).to eq(:running)
      end
      it 'gets an un aliased state correctly' do
        expect(sm.name(:dummy)).to eq(:dummy)
      end
    end
    context ':index' do
      it 'returns the state index correctly' do
        sm.insert_state :dummy, left: :right
        expect(sm.index(:dummy)).to eq(4)
      end
    end
    context ':sequence' do
      it 'correctlies return the actions to reach state specified' do
        expect(sm.sequence(:absent, :running).map { |p| p[:up] }).to eq([:configure, :install, :start])
      end
      it 'correctlies return the actions to reach state specified(2)' do
        expect(sm.sequence(:running, :absent).map { |p| p[:down] }).to eq([:stop, :uninstall, :destroy])
      end
    end
    context ':cmp' do
      it 'correctlies compare state sequence values' do
        expect(sm.cmp?(:absent, :running)).to eq(true)
        expect(sm.cmp?(:running, :running)).to eq(false)
        expect(sm.cmp?(:running, :absent)).to eq(false)
      end
    end
  end
end
