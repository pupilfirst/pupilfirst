require 'rails_helper'

describe 'locales' do
  it 'use our locale if defined' do
    expect(I18n.t('shared.level')).to eq('Chapter')
  end

  it 'use original locale if our is not defined' do
    expect(I18n.t('shared.cancel')).to eq('Cancel')
  end
end
