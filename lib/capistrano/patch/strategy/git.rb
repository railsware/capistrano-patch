require 'capistrano/patch/strategy/base'

module Capistrano
  module Patch
    module Strategy
      class Git < Base

        def patch_repository
          configuration.fetch(:patch_repository, '.git')
        end

        def patch_directory
          configuration.fetch(:patch_directory, '.')
        end

        def patch_location
          patch_path
        end

        def create
          command = "env GIT_DIR=#{patch_repository} "
          command << source.local.scm('diff-tree', "--binary #{revision_from}..#{revision_to} > #{patch_path}")
          system(command)
        end

        def deliver
          top.upload patch_path, "#{configuration.current_path}/#{patch_file}"
        end

        def check_apply
          command = "cd #{configuration.current_path} && "
          command << source.scm('apply', "--binary --check #{patch_file}")
          run(command)
        end

        def check_revert
          command = "cd #{configuration.current_path} && "
          command << source.scm('apply', "-R --binary --check #{patch_file}")
          run(command)
        end

        def apply
          command = "cd #{configuration.current_path} && "
          command << source.scm('apply', "--binary #{patch_file}")
          run(command)
        end

        def revert
          command = "cd #{configuration.current_path} && "
          command << source.scm('apply', "-R --binary #{patch_file}")
          run(command)
        end

      end
    end
  end
end
