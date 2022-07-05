require 'rails_helper'

describe Vimeo::ResolveEmbedCodeJob do
  subject { described_class }

  let(:content) do
    {
      url: 'https://vimeo.com/15298502',
      embed_code: nil,
      request_source: ContentBlock::EMBED_REQUEST_SOURCE_VIMEO
    }
  end

  let(:vimeo_embed_block) do
    create :content_block,
           block_type: ContentBlock::BLOCK_TYPE_EMBED,
           content: content
  end

  let(:resolve_embed_code_service) do
    instance_double(
      ContentBlocks::ResolveEmbedCodeService,
      execute: 'some code'
    )
  end

  describe '#perform' do
    it 'does not schedule another job on successful resolution' do
      expect(ContentBlocks::ResolveEmbedCodeService).to receive(:new)
        .with(vimeo_embed_block)
        .and_return(resolve_embed_code_service)

      expect(resolve_embed_code_service).to receive(:execute)

      expect { subject.perform_now(vimeo_embed_block.id, 1) }.to_not(
        change { ActiveJob::Base.queue_adapter.enqueued_jobs.size }
      )
    end

    context 'resolution is unsuccessful in first attempt' do
      let(:resolve_embed_code_service) do
        instance_double(ContentBlocks::ResolveEmbedCodeService, execute: nil)
      end

      it 'schedules another job to resolve embed code if maximum attempts have not reached' do
        expect(ContentBlocks::ResolveEmbedCodeService).to receive(:new)
          .with(vimeo_embed_block)
          .and_return(resolve_embed_code_service)

        expect do
          subject.perform_now(vimeo_embed_block.id, 1)
        end.to have_enqueued_job(Vimeo::ResolveEmbedCodeJob).with(
          vimeo_embed_block.id,
          2
        )
      end

      it 'does not schedule another job to resolve embed code if attempt is above allowed maximum attempts' do
        expect(ContentBlocks::ResolveEmbedCodeService).to receive(:new)
          .with(vimeo_embed_block)
          .and_return(resolve_embed_code_service)

        expect do
          subject.perform_now(vimeo_embed_block.id, 5)
        end.to_not have_enqueued_job(Vimeo::ResolveEmbedCodeJob)
      end
    end
  end
end
