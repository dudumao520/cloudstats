require "cloudstack_client"
require "cloudstack_client/configuration"
require "yaml"

module CloudstackStats
  class Collect

    def initialize(settings)
      @settings = settings.dup
      @config ||= CloudstackClient::Configuration.load(@settings)
      @cs ||= CloudstackClient::Client.new(
        @config[:url],
        @config[:api_key],
        @config[:secret_key]
      )
      @cs.debug = true if @settings[:debug]
      @cs
    end

    def account_stats
      {
        type: "account",
        stats: @cs.list_accounts(client_options)
      }
    end

    def project_stats
      {
        type: "project",
        stats: @cs.list_projects(client_options)
      }
    end

    private

    def client_options
      { listall: true, isrecursive: true }.merge(
       resolve_domain(@settings)
      )
    end

    def resolve_domain(opts)
      if opts[:domain]
        if domain = @cs.list_domains(name: opts[:domain]).first
          opts[:domainid] = domain['id']
        else
          raise "Domain #{opts[:domain]} not found."
        end
      end
      opts
    end

  end
end
