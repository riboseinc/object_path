module ObjectPath
  module RouteNameMixin

    def self.included base
      base.class_eval do
        class << self
          @route_name_prefix = ""
          @route_name        = ""

          # specify prefix for the route name
          #
          # An underscore character is automatically appended.
          # The part after the underscore is automatically inferred from the
          # Model name.
          #
          # See: #route_name
          #
          # E.g.,
          #   class User
          #     include RouteNameMixin
          #
          #     route_name_prefix "people"
          #   end
          #
          #   u = User.new        # => #<User: ... >
          #   u.route_name        # => "people_user"
          #   User.route_name     # => "people_user"
          #
          def route_name_prefix prefix
            @route_name_prefix = prefix
          end

          # overloaded getter & setter for route_name
          #
          # Use this instead of #route_name_prefix to set the route_name if it
          # can't be inferred from the Model name.
          #
          # E.g.,
          #   class CustomerContact
          #     include RouteNameMixin
          #
          #     route_name "client_contact"
          #   end
          #
          #   cc = CustomerContact.new    # => #<CustomerContact: ... >
          #   cc.route_name               # => "client_contact"
          #   CustomerContact.route_name  # => "client_contact"
          #
          def route_name new_route_name=nil

            # getter
            if new_route_name.nil? || new_route_name.empty?
              if @route_name.nil? || @route_name.empty?

              (@route_name_prefix.to_s.empty? ? "" : "#{@route_name_prefix}_") +
                self.name.underscore
              else
                @route_name
              end

            # setter
            else
              @route_name = new_route_name
            end
          end
        end

        def route_name
          self.class.route_name
        end
      end
    end

  end
end
