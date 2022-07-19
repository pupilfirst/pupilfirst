require 'rails_helper'

describe ContentBlocks::ResolveEmbedCodeService do
  subject { described_class.new(embed_block) }

  let(:content) {{
    url: "https://vimeo.com/15298502",
    embed_code: nil,
  }}

  let(:embed_block) { create :content_block, block_type: ContentBlock::BLOCK_TYPE_EMBED, content: content  }
  let(:oembed_resolver) {instance_double(::Oembed::Resolver, embed_code: "some code")}

  describe '#execute' do
    it 'attempts to resolve the embed block and updates the embed code block' do
        expect(::Oembed::Resolver).to receive(:new)
          .with("https://vimeo.com/15298502")
          .and_return(oembed_resolver)

        expect(oembed_resolver).to receive(:embed_code)

        subject.execute

        expect(embed_block.content['embed_code']).to eq("some code")
        expect(embed_block.content['last_resolved_at']).to_not eq(nil)
    end

    context 'when an attempt to resolve code less than a minute ago' do
      let(:content) {{
        url: "https://vimeo.com/15298502",
        embed_code: nil,
        last_resolved_at: 30.seconds.ago,
      }}

      it 'does not re-attempt to resolve the embed code' do
        expect(::Oembed::Resolver).to_not receive(:new)

        subject.execute

        expect(embed_block.content['embed_code']).to eq(nil)
      end
    end
  end
end
