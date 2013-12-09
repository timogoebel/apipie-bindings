module ApipieBindings

  class Action

    def initialize(resource, name, api)
      @resource = resource
      @name = name
      @api = api
    end

    def call(params={}, headers={})
      @api.call(@resource, @name, params, headers)
    end

    def action_doc
      methods = @api.apidoc[:docs][:resources][@resource][:methods].select do |action|
        action[:name].to_sym == @name
      end
      methods.first
    end

    def routes
      action_doc[:apis].map do |api|
        ApipieBindings::Route.new(
          api[:api_url], api[:http_method], api[:short_description])
      end
    end

    def find_route(params={})
      sorted_routes = routes.sort_by { |r| [-1 * r.params_in_path.count, r.path] }

      suitable_route = sorted_routes.find do |route|
        route.params_in_path.all? { |path_param| params.keys.map(&:to_s).include?(path_param) }
      end

      suitable_route ||= sorted_routes.last
      return suitable_route
    end

    def validate!(params)
      # return unless params.is_a?(Hash)

      # invalid_keys = params.keys.map(&:to_s) - (rules.is_a?(Hash) ? rules.keys : rules)
      # raise ArgumentError, "Invalid keys: #{invalid_keys.join(", ")}" unless invalid_keys.empty?

      # if rules.is_a? Hash
      #   rules.each do |key, sub_keys|
      #     validate_params!(params[key], sub_keys) if params[key]
      #   end
      # end
    end
  end
end
