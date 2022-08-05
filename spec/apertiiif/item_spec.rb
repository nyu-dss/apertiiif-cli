# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Apertiiif::Item do
  before(:context) do
    @conf_opts = {
      'label' => 'my batch label',
      'presentation_api_url' => 'https://example.com/presentation'
    }
    @defaults = {
      'records' => {
        'defaults' => { 'test_default' => 'here!' }
      }
    }
    @id         = 'test'
    @source     = 'spec/fixtures/valid.jpeg'
    @conf_opts  = {
      'label' => 'my batch label',
      'presentation_api_url' => 'https://example.com/presentation',
      'image_api_url' => 'https://example.com/presentation'
    }
    @config = Apertiiif::Config.new @conf_opts
    @asset  = Apertiiif::Asset.new @id, @source, @config
    @item   = Apertiiif::Item.new @id, [@asset], @config
  end

  describe '.new' do
    context 'when not given requisite configuration'
    it 'raises custom errors' do
      @config = Apertiiif::Config.new({ 'label' => 'my batch label' })
      expect { Apertiiif::Item.new(@id, @assets, @config) }.to raise_error(Apertiiif::Error)
    end

    context 'when given requisite configuration'
    it 'returns asset object' do
      expect(@item).to be_an(Apertiiif::Item)
    end
  end

  describe '.record' do
    context 'when no record has been given' do
      it 'creates and returns a default record' do
        expect(@item.record).to be_an(Apertiiif::Record)
      end
    end
  end

  describe '.default_record' do
    context 'when config defaults have not been set' do
      it 'returns record with id key only' do
        expect(@item.record.id).to eq('test')
        expect { @item.record.test_default }.to raise_error(KeyError)
      end
    end
    context 'when config defaults have been set' do
      it 'returns record with id key and defaults added' do
        @config = Apertiiif::Config.new(@conf_opts.merge(@defaults))
        @item = Apertiiif::Item.new(@id, @assets, @config)
        expect(@item.record.test_default).to eq('here!')
      end
    end
  end

  describe '.manifest' do
    it 'returns a iiif manifest' do
      expect(@item.manifest).to be_a(IIIF::Presentation::Manifest)
    end
  end

  describe '.label' do
  end

  describe '.manifest_url' do
    it 'returns url' do
      expect(@item.manifest_url).to start_with('https://')
      expect(@item.manifest_url).to end_with('.json')
    end
  end

  describe '.thumbnail_url' do
    context 'with no valid assets' do
      it 'returns empty string' do
        @item = Apertiiif::Item.new @id, [], @config
        expect(@item.thumbnail_url).to be_empty
      end
    end
    context 'with valid assets' do
      it 'returns first valid url' do
        expect(@item.thumbnail_url).to start_with('https://')
      end
    end
  end

  describe '.viewpoint_url' do
  end

  describe '.seed' do
    it 'returns compacted hash' do
      expect(@item.seed).to be_a(Hash)
    end
  end

  describe '.build_manifest' do
    it 'returns a iiif manifest' do
      expect(@item.build_manifest).to be_a(IIIF::Presentation::Manifest)
    end
  end

  describe '.manifest_file' do
    it 'returns a filepath string' do
      expect(@item.manifest_file).to end_with('.json')
    end
  end

  describe '.write_presentation_json' do
    it 'writes a manifest json file' do
      FileUtils.rm(@item.manifest_file) if File.file?(@item.manifest_file)
      @item.write_presentation_json
      expect(File.file?(@item.manifest_file)).to be(true)
    end
  end

  describe '.to_hash' do
    it 'returns a valid hash' do
      expect(@item.to_hash).to be_a(Hash)
    end
  end

  describe '.to_html_list_item' do
    it 'returns html partial string' do
      expect(@item.to_html_list_item).to include(@item.viewpoint_url)
    end
  end
end
