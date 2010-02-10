Group Collection
=========

Group Collection provides collections of Spree's Product Group class.  This provides the following functionality

- Compose multiple Product Groups into a single named collection with it's own permalink
- Associate Product Group collections with users allowing users to define 'saved searches'
- Composable collections; ObjectGroups can be build from other ObjectGroups
- Polymorphic collection associations allowing scopes defined on multiple object classes to be collected into a single search result

Installation
---------

1. Clone the git repo

        git clone git://github.com/kerinin/spree-group-collection.git

2. Install the gem dependencies

        rake gems:install

3. Set extension load order in config/environment.rb (modify to taste if you're using other extensions)

        config.extensions = [:group_collection, :all, :site]

4. Run database migrations

        rake db:migrate


Usage
---------

Group collections are accessed through a route with the prefix '/c/'.  This is a fairly standard
REST interface, the only significance being the '/c/build' route, which allows users to construct
Group Collections on-the-fly.

For instance, given the following named product groups:

- cheap stuff
- best sellers
- recently updated

and the following named group collections

- dashboard
- suggested

users could build custom group collections using the following URL's

    /c/build?children[]=dashboard&children[]=suggested
    /c/build?product_groups[]=cheap-stuff&product_groups[]=best-sellers
    /c/build?children[]=suggested&product_groups[]=recently-updated

The extension is intended to provide authenticated users with a mechanism for saving custom searches,
so full CRUD controllers are available for authenticated users.  Both ProductGroups and GroupCollections
are automatically associated with the current user on creation, and the user's id is appended to the
permalink.

GroupCollections without associated users can be created through the admin interface, however the views
to do so haven't been written yet.


Extending Associations
---------

GroupCollection associations are polymorphic, so extending the class to handle different types of groups
(ie promotions) should be fairly trivial.  To do so requires defining the association and adding a before_filter
to the controller.  To extend the GroupCollection class to include promotions you would add the following to
your extension activation method:

        GroupCollection.class_eval do
          has_many :promotions, :through => :collecteds, :source => :group, :source_type => "Promotion"

          def all_promotions
            [ self.promotions + self.children.map{ |gc| gc.promotions } ].flatten.uniq
          end
        end

        GroupCollectionsController.class_eval do
          prepend_before_filter :load_promotions, :only => [:build, :create, :update]

          private

          def load_promotions
            params[:group_collection] ||= {}
            params[:group_collection][:promotions] = params[:promotions].to_a.map{|permalink| Promotion.find_by_permalink(permalink) }.compact.uniq
          end
        end


License
----------

Copyright 2010 [Ryan Michael](http://github.com/kerinin)

GroupCollection is licensed under the [GPLv2 license](http://www.gnu.org/licenses/gpl-2.0.html)

