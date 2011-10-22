require 'capistrano/patch/strategy/git'

module Capistrano
  module Patch
    module Strategy
      class GitServer < Git

        def patch_location
          File.join configuration.fetch(:patch_base_url), patch_file
        end

        def create
          command = "mkdir -p #{patch_directory} && "
          command << source.scm('diff-tree', "--binary #{revision_from}..#{revision_to} > #{patch_path}")

          run(command, {
            :hosts => [server],
            :env => { 'GIT_DIR' => patch_repository }
          })
        end

        def deliver
          command = "cd #{current_path} && "
          command << "wget -N -q #{patch_location}"
          run(command)
        end

        protected

        def server
          ServerDefinition.new(
            configuration.fetch(:patch_server_host),
            configuration.fetch(:patch_server_options, {})
          )
        end

      end
    end
  end
end
