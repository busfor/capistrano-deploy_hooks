# frozen_string_literal: true
module Capistrano
  module DeployHooks
    module Messengers
      class Mattermost
        GREEN = '#00FF00'
        YELLOW = '#FFFF00'
        RED = '#FF0000'

        extend Forwardable
        def_delegators :@cap, :fetch

        attr_reader :opts

        def initialize(cap, opts)
          @cap  = cap
          @opts = opts
        end

        def payloads_for(action)
          binding.pry
          method = "payload_for_#{action}"
          return if !respond_to?(method)

          pl = (opts[:payload] || {}).merge(username: "Capistrano").merge(send(method))

          channels = Array(opts[:channels])

          payloads = channels.map{ |c| pl.merge(channel: c) }
          payloads = [pl] if payloads.empty?
          payloads
        end

        def payload_for_updating
          text = "#{deployer} has started deploying branch `#{branch}` of #{application} to **#{stage}** :call_me_hand:"
          {
            attachments: [
              {
                "color": GREEN,
                "fallback": text,
                "text": "Capistrano says:",
                "fields": [
                  {
                    "short": false,
                    "value": text,
                  },
                ]
              },
            ],
          }
        end

        def payload_for_reverting
          text = "#{deployer} has started rolling back branch `#{branch}` of #{application} to **#{stage}** :hushed:"
          {
            attachments: [
              {
                "color": YELLOW,
                "fallback": text,
                "text": "Capistrano says:",
                "fields": [
                  {
                    "short": false,
                    "value": text,
                  },
                ]
              },
            ],
          }
        end

        def payload_for_updated
          text = "#{deployer} has finished deploying back branch `#{branch}` of #{application} to **#{stage}** :white_check_mark:"
          {
            attachments: [
              {
                "color": GREEN,
                "fallback": text,
                "text": "Capistrano says:",
                "fields": [
                  {
                    "short": false,
                    "value": text,
                  },
                ]
              },
            ],
          }
        end

        def payload_for_reverted
          text = "#{deployer} has finished rolling back branch `#{branch}` of #{application} to **#{stage}** :suspect:"
          {
            attachments: [
              {
                "color": YELLOW,
                "fallback": text,
                "text": "Capistrano says:",
                "fields": [
                  {
                    "short": false,
                    "value": text,
                  },
                ]
              },
            ],
          }
        end

        def payload_for_failed
          text = "#{deployer} has failed to #{deploying? ? 'deploy' : 'rollback'} branch `#{branch}` of #{application} to **#{stage}** :scream:"
          {
            attachments: [
              {
                "color": RED,
                "fallback": text,
                "text": "Capistrano says:",
                "fields": [
                  {
                    "short": false,
                    "value": text,
                  },
                ]
              },
            ],
          }
        end

        def webhook_for(_)
          opts[:webhook_uri]
        end

        def deployer
          ENV["USER"] || ENV["USERNAME"]
        end

        def branch
          fetch(:branch)
        end

        def application
          fetch(:application)
        end

        def stage
          fetch(:stage, '')
        end
      end
    end
  end
end
