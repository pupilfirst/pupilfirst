pdf_path = 'spec/support/uploads/resources/pdf-sample.pdf'
thumbnail_path = 'spec/support/uploads/resources/pdf-thumbnail.png'

Resource.create!(
  file: Rails.root.join(pdf_path).open,
  thumbnail: Rails.root.join(thumbnail_path).open,
  title: 'Public PDF File',
  description: 'This is a public PDF file, meant to be accessible by everyone!',
  share_status: Resource::SHARE_STATUS_PUBLIC
)

Resource.create!(
  file: Rails.root.join(pdf_path).open,
  title: 'Public PDF File',
  description: 'This is a restricted PDF file, meant to be accessible by approved startups!',
  share_status: Resource::SHARE_STATUS_APPROVED
)

Resource.create!(
  file: Rails.root.join(pdf_path).open,
  thumbnail: Rails.root.join(thumbnail_path).open,
  title: 'Public PDF File',
  description: 'This is a restricted PDF file, meant to be accessible by approved startups of batch 1.',
  share_status: Resource::SHARE_STATUS_APPROVED,
  shared_with_batch: 1
)
