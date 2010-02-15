Factory.sequence(:role_sequence) {|n| "Role ##{n}"}

Factory.define(:role) do |record|
  record.name { Factory.next(:role_sequence) }
end

Factory.define(:user_role, :parent => :role) do |r|
  r.name "user"
end

Factory.define(:admin_role, :parent => :role) do |r|
  r.name "admin"
end

Factory.sequence :login do |n|
  Faker::Internet.user_name + n.to_s
end

Factory.define(:user) do |record|
  record.email { Faker::Internet.email }
  record.login { Factory.next(:login) }
  record.password "spree"
  record.password_confirmation "spree"
  record.roles { [Role.find_by_name("user") || Factory(:user_role) ] }
end

Factory.define(:admin_user, :parent => :user) do |u|
  u.roles { [Role.find_by_name("admin") || Factory(:admin_role)]}
end

Factory.sequence(:group_collection_sequence) {|n| "Group Collection ##{n} - #{rand(9999)}"}

Factory.define :group_collection do |f|
  f.name { Factory.next(:group_collection_sequence) }
end

Factory.sequence(:product_sequence) {|n| "Product ##{n} - #{rand(9999)}"}

Factory.define :product do |f|
  f.name { Factory.next(:product_sequence) }
  f.description { Faker::Lorem.paragraphs(rand(5)+1).join("\n") }

  f.price 19.99
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

