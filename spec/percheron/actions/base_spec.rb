require 'spec_helper'

describe Percheron::Actions::Base do

  class Percheron::Actions::BaseClass

    include Percheron::Actions::Base

    def initialize(container)
      @container = container
    end

    private

      attr_reader :container

  end

  let(:logger) { double('Logger').as_null_object }
  let(:config) { Percheron::Config.new('./spec/support/.percheron_valid.yml') }
  let(:stack) { Percheron::Stack.new(config, 'debian_jessie') }
  let(:container) { Percheron::Container.new(config, stack, 'debian') }
  let(:dependant_containers) { container.dependant_containers }

  before do
    $logger = logger
    Timecop.freeze(Time.local(1990))
    allow(container).to receive(:dependant_containers).and_return(dependant_containers)
  end

  after do
    Timecop.return
    $logger = nil
  end

  subject { Percheron::Actions::BaseClass.new(container) }

  describe '#base_dir' do
    it "returns the Dockerfile's base dir" do
      expect(subject.base_dir).to match(Regexp.new('.+/percheron/spec/support'))
    end
  end

  describe '#in_working_directory' do
    it 'changes the working directory, yields, then returns to previous working directory' do
      expect(Dir).to receive(:pwd).and_return('/tmp/old')
      expect(Dir).to receive(:chdir).with('/tmp')
      expect(Dir).to receive(:chdir).with('/tmp/old')

      subject.in_working_directory('/tmp') { 'testing' }
    end
  end

  describe '#now_timestamp' do
    it 'returns the current time as %Y%m%d%H%M%S' do
      expect(subject.now_timestamp).to eql('19900101000000')
    end
  end

  describe '#insert_files!' do
    let(:docker_image) { double('Docker::Image') }
    let(:docker_image_new) { double('Docker::Image') }

    it 'inserts files into Docker Image' do
      expect(container).to receive(:image).and_return(docker_image)
      expect(docker_image).to receive(:insert_local).with({"localPath"=>"/tmp/blah.sh", "outputPath"=>"/tmp/blah.sh"}).and_return(docker_image_new)
      expect(docker_image_new).to receive(:tag).with({:repo=>"debian", :tag=>"1.0.0", :force=>true})

      subject.insert_files!([ '/tmp/blah.sh' ])
    end
  end

  describe '#stop_containers!' do
    let(:stop_action) { double('Percheron::Actions::Stop') }

    it 'stops containers and returns affected' do
      expect(container).to receive(:running?).and_return(true)
      expect(Percheron::Actions::Stop).to receive(:new).with(container).and_return(stop_action)
      expect(stop_action).to receive(:execute!).and_return(container)

      expect(subject.stop_containers!([ container ])).to eql([ container ])
    end
  end

  describe '#start_containers' do
    let(:start_action) { double('Percheron::Actions::Start') }

    it 'starts containers and returns affected' do
      expect(container).to receive(:running?).and_return(false)
      expect(Percheron::Actions::Start).to receive(:new).with(container, dependant_containers.values).and_return(start_action)
      expect(start_action).to receive(:execute!).and_return(container)

      expect(subject.start_containers!([ container ])).to eql([ container ])
    end
  end
end
