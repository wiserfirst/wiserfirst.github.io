# frozen_string_literal: true

group :red_green_refactor, halt_on_fail: true do
  guard 'process',
        command: ['markdownlint', '_posts', '_drafts', '_pages', 'README.md'],
        name: 'markdownlint' do
    watch(%r{\A_posts/.+\.md\z})
    watch(/\A.+\.md\z/)
  end
end
