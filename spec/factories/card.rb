FactoryBot.define do
  factory :card do
    sequence(:name) { |n| "Card_#{n}" }
    cost {"0"}
    converted_mana_cost {0}
    card_text {"{T}, Sacrifice Black Lotus: Add three mana of any one color."}
    layout {"normal"}
    default_image {"https://img.scryfall.com/cards/normal/front/b/d/bd8fa327-dd41-4737-8f19-2cf5eb1f7cdd.jpg?1562933099"}
    color_identity {"C"}
    default_set {"LEB"}
    type_line {"Artifact"}
  end
end