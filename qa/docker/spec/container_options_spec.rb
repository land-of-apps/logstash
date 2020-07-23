require_relative 'spec_helper'

compatible_image_flavors.each do | flavor|
  describe "Running #{flavor} containers, setting environment variables" do
    before(:all) do
      @image = find_image(flavor)
    end

    before(:each) do
      @container = start_container(@image, { 'ENV' => env})
    end

    after(:each) do
      cleanup_container(@container)
    end

    context 'when setting pipeline workers shell style' do
      let(:env) { ['PIPELINE_WORKERS=32'] }

      it "should correctly set the number of pipeline workers" do
        expect(get_node_info['pipelines']['main']['workers']).to eq 32
      end
    end

    context 'when setting pipeline workers dot style' do
      let(:env) { ['pipeline.workers=64'] }

      it "should correctly set the number of pipeline workers" do
        expect(get_node_info['pipelines']['main']['workers']).to eq 64
      end
    end

    context 'when setting pipeline batch size' do
      let(:env) {['pipeline.batch.size=123']}

      it "should correctly set the batch size" do
        expect(get_node_info['pipelines']['main']['batch_size']).to eq 123
      end
    end

    context 'when setting pipeline batch delay' do
      let(:env) {['pipeline.batch.delay=36']}

      it 'should correctly set batch delay' do
        expect(get_node_info['pipelines']['main']['batch_delay']).to eq 36
      end
    end

    context 'when setting unsafe shutdown to true shell style' do
      let(:env) {['pipeline.unsafe_shutdown=true']}

      it 'should set unsafe shutdown to true' do
        expect(get_settings['pipeline.unsafe_shutdown']).to be_truthy
      end
    end

    context 'when setting unsafe shutdown to true dot style' do
      let(:env) {['pipeline.unsafe_shutdown=true']}

      it 'should set unsafe shutdown to true' do
        expect(get_settings['pipeline.unsafe_shutdown']).to be_truthy
      end
    end

    unless is_oss?(flavor)
      context 'when disabling xpack monitoring' do
        let(:env) {['xpack.monitoring.enabled=false']}

        it 'should set monitoring to false' do
          expect(get_settings['xpack.monitoring.enabled']).to be_falsey
        end
      end

      context 'when enabling xpack monitoring' do
        let(:env) {['xpack.monitoring.enabled=true']}

        it 'should set monitoring to false' do
          expect(get_settings['xpack.monitoring.enabled']).to be_truthy
        end
      end

      context 'when setting elasticsearch urls as an array' do
        let(:env) { ['xpack.monitoring.elasticsearch.hosts=["http://node1:9200","http://node2:9200"]']}

        it 'should set set the hosts property correctly' do
          expect(get_settings['xpack.monitoring.elasticsearch.hosts']).to be_an(Array)
          expect(get_settings['xpack.monitoring.elasticsearch.hosts']).to include('http://node1:9200')
          expect(get_settings['xpack.monitoring.elasticsearch.hosts']).to include('http://node2:9200')
        end
      end
    end
  end
end
