shared_examples "a recreate action" do

  context 'and the container was not running' do
    let(:running) { false }

    it 'recreates the container' do
      subject.execute!
    end
  end

  context 'and the container was running' do
    let(:running) { true }

    before do
      expect(Percheron::Container::Actions::Stop).to receive(:new).with(container).and_return(stop_double)
    end

    it 'stops the container, recreates the container and then starts it back up' do
      expect(stop_double).to receive(:execute!)
      expect(container).to receive(:start!)
      subject.execute!
    end
  end

end
