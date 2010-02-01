Factory.sequence(:group_collection_sequence) {|n| "Group Collection ##{n} - #{rand(9999)}"}

Factory.define :group_collection do |f|
  f.name { Factory.next(:group_collection_sequence) }
  f.description { Faker::Lorem.paragraphs(rand(5)+1).join("\n") }
end


Factory.sequence(:product_sequence) {|n| "Product ##{n} - #{rand(9999)}"}

Factory.define :product do |f|
  f.name { Factory.next(:product_sequence) }
  f.description { Faker::Lorem.paragraphs(rand(5)+1).join("\n") }

  # associations:
  f.tax_category {|r| TaxCategory.find(:first) || r.association(:tax_category)}
  f.shipping_category {|r| ShippingCategory.find(:first) || r.association(:shipping_category)}

  f.price 19.99
  f.cost_price 17.00
  f.sku "ABC"
end


Factory.sequence(:product_group_sequence) {|n| "Product Group ##{n} - #{rand(9999)}"}

Factory.define :product_group do |f|
  f.name { Factory.next(:product_group_sequence) }

  f.product_scopes_attributes([
      { :name => "price_between", :arguments => [10,20]},
      {:name => "name_contains", :arguments => ["ruby"]}
  ])
end



Factory.define(:user) do |record|
  record.email { Faker::Internet.email }
  record.login { Factory.next(:login) }
  record.password "spree"
  record.password_confirmation "spree"
end
