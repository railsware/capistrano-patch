require 'capistrano/recipes/deploy/strategy/base'

module Capistrano
  module Patch
    module Strategy
      class Base < Deploy::Strategy::Base

        def initialize(*)
          super

          if ENV['PATCH']
            ENV['FROM'], ENV['TO'] = File.basename(ENV['PATCH'], '.patch').split('-', 2)
          end

          ENV['FROM'] or abort "Please specify FROM revision environment variable"
          ENV['TO']   or abort "Please specify TO revision environment variable"

          @revision_from = normalize_revision(ENV['FROM'])
          @revision_to   = normalize_revision(ENV['TO'])
        end

        #
        # Configuration
        #

        attr_reader :revision_from, :revision_to

        def patch_file
          @patch_file ||= "#{revision_from}-#{revision_to}.patch"
        end

        def patch_directory
          raise NotImplementedError, "`patch_directory' is not implemented by #{self.class.name}"
        end

        def patch_path
          File.join patch_directory, patch_file
        end

        def patch_location
          raise NotImplementedError, "`patch_location' is not implemented by #{self.class.name}"
        end

        #
        # Actions
        #

        def create
          raise NotImplementedError, "`create' is not implemented by #{self.class.name}"
        end

        def deliver
          raise NotImplementedError, "`deliver' is not implemented by #{self.class.name}"
        end

        def check_apply
          raise NotImplementedError, "`check_apply' is not implemented by #{self.class.name}"
        end

        def check_revert
          raise NotImplementedError, "`check_revert' is not implemented by #{self.class.name}"
        end

        def apply
          raise NotImplementedError, "`apply' is not implemented by #{self.class.name}"
        end

        def revert
          raise NotImplementedError, "`revert' is not implemented by #{self.class.name}"
        end

        def mark_apply
          mark(revision_to)
        end

        def mark_revert
          mark(revision_from)
        end

        protected

        def normalize_revision(revision)
          source.local.query_revision(revision) { |cmd| run_locally(cmd) }
        end

        def mark(revision)
          command = "echo #{revision} > #{configuration.current_path}/REVISION"
          run(command) 
        end

      end
    end
  end
end
