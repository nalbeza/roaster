require_relative './band'

FactoryGirl.define do
  factory :album do
    title "Album Title"
    band

    factory :animals_album do
      title 'Animals'
    end

    factory :the_wall_album do
      title 'The Wall'
    end

    factory :meddle_album do
      title 'Meddle'
    end

  end
end
