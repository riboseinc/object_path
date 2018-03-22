module ObjectPath
  module Mixin

    # available as ActionView helper methods
    def self.included base
      base.send :helper_method, self.instance_methods if base.respond_to?(:helper_method, true)

      require "object_path/route_name_mixin"
      base.send :include, ObjectPath::RouteNameMixin
    end

    # = Object path
    #
    #   Return context independed path to object
    #
    # == Examples:
    #
    #   === For simple resource
    #
    #     class BlogPost < ActiveRecord::Base; end
    #
    #     object_path(@blog_post)
    #     # => '/blog_posts/:id'
    #
    #     object_path(@blog_post, :edit)
    #     # => '/blog_posts/:id/edit'
    #
    #     object_path(@blog_post, :edit, :context => 'next')
    #     # => '/blog_posts/:id/edit?context=next'
    #
    #     object_path(BlogPost.new)
    #     # => '/blog_posts/new'
    #
    #   === For custom named routes or nested resources method :object_path should be defined in model
    #
    #     ==== Custom named routes ( using :route_method param )
    #
    #     class BlogPost < ActiveRecord::Base
    #       def as_object_path
    #         {:route_method => :today_blog_posts}
    #       end
    #     end
    #
    #     object_path(@blog_post)
    #     # => '/today_blog_posts/:id'
    #
    #     ==== Nested resources  ( using :route_params param )
    #
    #     class Meal < ActiveRecord::Base
    #       def as_object_path
    #         {:route_params => [self.restaurant]}
    #       end
    #     end
    #
    #     object_path(@meal)
    #     # => '/restaurants/:restaurant_id/meals/:id'
    #
    #     ==== Singular resources / Collection routes ( using :singular param )
    #
    #     Using the :singular option, the object will not be put in the
    #     route_params.
    #
    #     E.g. model DrinkMenu, controller DrinkMenu, route: resource :drink_menu
    #
    #     class DrinkMenu < ActiveRecord::Base
    #       def as_object_path
    #         {
    #           :singular => true,
    #           :route_method => :widgets_drink_menu
    #         }
    #       end
    #     end
    #
    #     object_path(@drink_menu)
    #     # => 'drink_menu'
    #
    #   === For non-standard resource names method :route_name should be defined in model
    #
    #     E.g. model BlogPostEntity, controller BlogPosts, route resources :blog_posts
    #
    #     class BlogPostEntity < ActiveRecord::Base
    #       def route_name
    #         :blog_post
    #       end
    #     end
    #
    #     object_path(@blog_post)
    #     # => '/blog_posts/:id'
    #

    def object_path(object, action_or_options = nil, options = {})
      do_object_path(object, action_or_options, options) do |route, prefix, route_params, engine|
        method_name = "#{route}_path"
        generate_object_path_or_url(engine, route_params, prefix, method_name)
      end
    end

    # XXX HACK
    def full_path(homepage, object = nil)
      object ||= self
      homepage + object.object_url(object, only_path: true)
    end

    def object_url(object, action_or_options = nil, options = {})
      do_object_path(object, action_or_options, options) do |route, prefix, route_params, engine|
        method_name = "#{route}_url"
        generate_object_path_or_url(engine, route_params, prefix, method_name)
      end
    end

    def object_path_method(object, action_or_options = nil, options = {})
      do_object_path(object, action_or_options, options) do |route, prefix, route_params|
        "#{prefix}#{route}_path"
      end
    end

    def object_url_method(object, action_or_options = nil, options = {})
      do_object_path(object, action_or_options, options) do |route, prefix, route_params|
        "#{prefix}#{route}_url"
      end
    end

  private

    def generate_object_path_or_url(engine, route_params, prefix, method_name)
      base = engine ? engine.constantize.routes.url_helpers : self

      case route_params
      when Hash
        base.send("#{prefix}#{method_name}", route_params)
      when Array
        base.send("#{prefix}#{method_name}", *route_params)
      end
    end

    # +object+ can be a Class, too.
    def do_object_path(object, action_or_options = nil, options = {})
      return unless object

      if action_or_options.is_a?(Hash)
        options = action_or_options
        action = nil
      else
        action = action_or_options
      end

      route_method, route_params, engine, path_prefix = [nil, [], nil, nil]

      singular_route = false
      if object.respond_to?(:as_object_path)
        o = object.as_object_path
        puts "the o..."
        pp o
        route_method = o[:route_method] || nil
        route_params = o[:route_params] || []
        singular_route = o[:singular] || false
        engine = o[:engine] || nil

        if o[:path_prefix]
          p = o[:path_prefix]
          prefix_route_method = p[:route_method] || nil
          prefix_route_params = p[:route_params] || []
          prefix_engine = p[:engine] || nil
          path_prefix = yield prefix_route_method, "", prefix_route_params, prefix_engine
        end
      end

      route_params << object unless singular_route

      route = route_method || try_produce_route(route_params)
      if ! object.is_a?(Class) && object.new_record? || action.to_s == 'new'
        action = :new
        route_params.pop
      end

      prefix = action ? "#{action}_" : ""

      # add options
      case route_params
      when Hash
        route_params.merge!(options)
      when Array
        route_params << options
      end

      [path_prefix, yield(route, prefix, route_params, engine)].compact.join("")
    end

    def try_produce_route(collection)
      "#{collection.map do |o|
        o.respond_to?(:route_name) ?
          o.route_name :
          (o.is_a?(Class) ? o : o.class).name.underscore
      end.join('_')}"
    end

  end
end

