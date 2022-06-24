require 'rails_helper'

describe Vimeo::ResolveEmbedCodeJob do
  subject { described_class }

  let(:content) {{
    url: "https://vimeo.com/15298502",
    embed_code: nil,
    request_source: ContentBlock::EMBED_REQUEST_SOURCE_VIMEO
  }}

  let(:vimeo_embed_block) { create :content_block, block_type: ContentBlock::BLOCK_TYPE_EMBED, content: content  }

  let(:resolve_embed_code_service) {instance_double(ContentBlocks::ResolveEmbedCodeService, execute: "some code")}

  describe '#perform' do
    it 'returns the embed code of the content block on successful resolution' do
      expect(ContentBlocks::ResolveEmbedCodeService).to receive(:new)
        .with(vimeo_embed_block)
        .and_return(resolve_embed_code_service)

      expect(resolve_embed_code_service).to receive(:execute)

      embed_code = subject.perform_now(vimeo_embed_block, 1)

      expect(embed_code).to eq("some code")

      # Check another job is not scheduled on successful resolution
      expect(Vimeo::ResolveEmbedCodeJob).to_not have_been_enqueued
    end

    context 'resolution is unsuccessful in first attempt' do
      let(:resolve_embed_code_service) {instance_double(ContentBlocks::ResolveEmbedCodeService, execute: nil)}

      it 'schedules another job to resolve embed code if maximum attempts have not reached' do
        expect(ContentBlocks::ResolveEmbedCodeService).to receive(:new)
          .with(vimeo_embed_block)
          .and_return(resolve_embed_code_service)


        expect do
          subject.perform_now(vimeo_embed_block, 1)
        end.to have_enqueued_job(Vimeo::ResolveEmbedCodeJob).with(vimeo_embed_block, 2)
      end

      it 'does not schedule another job to resolve embed code if attempt is above allowed maximum attempts' do
        expect(ContentBlocks::ResolveEmbedCodeService).to receive(:new)
          .with(vimeo_embed_block)
          .and_return(resolve_embed_code_service)


        expect do
          subject.perform_now(vimeo_embed_block, 5)
        end.to_not have_enqueued_job(Vimeo::ResolveEmbedCodeJob)
      end
    end
  end
end
