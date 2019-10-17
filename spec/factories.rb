FactoryBot.define do

  factory :document do
    name { "My Foo Document" }
    account_id { 885563 }

    trait :with_file_upload do
      after :create do |document|
        file_path = Rails.root.join('app', 'assets', 'images', 'koda.jpg')
        file = fixture_file_upload(file_path, 'image/png')
        document.file_upload.attach(file)
      end
    end

    trait :without_name do
      after :create do |document|
        document.name = ""
      end

    end
  end

end