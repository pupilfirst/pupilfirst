require "rails_helper"

feature "Bottom navigation bar" do
  let!(:school) { create :school, :current }

  let!(:custom_link_1) do
    create :school_link, :footer, school: school, sort_index: 1
  end
  let!(:custom_link_2) do
    create :school_link, :footer, school: school, sort_index: 0
  end
  let!(:custom_link_3) do
    create :school_link, :footer, school: school, sort_index: 2
  end
  let!(:custom_link_4) do
    create :school_link, :footer, school: school, sort_index: 3
  end

  it "displays custom links on the bottom navbar", js: true do
    visit root_path

    # All four links should be visible.
    expect(page).to have_link(custom_link_4.title, href: custom_link_4.url)
    expect(page).to have_link(custom_link_3.title, href: custom_link_3.url)
    expect(page).to have_link(custom_link_2.title, href: custom_link_2.url)
    expect(page).to have_link(custom_link_1.title, href: custom_link_1.url)

    # Links should be ordered based on their sort_index.

    titles = page.all("div#bottom-nav-container div a")

    expect(titles.map(&:text)).to eq(
      [
        custom_link_2.title,
        custom_link_1.title,
        custom_link_3.title,
        custom_link_4.title
      ]
    )
  end
end
