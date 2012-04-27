require 'capistrano/patch/strategy'

Capistrano::Configuration.instance(true).load do

  set(:patch_strategy) { Capistrano::Patch::Strategy.new(fetch(:patch_via, scm), self) }

  namespace :patch do

    desc "Create, deliver and apply patch"
    task :default, :except => { :no_release => true } do
      top.patch.create
      top.patch.deliver
      top.patch.apply
    end

    desc "Create patch"
    task :create, :except => { :no_release => true }  do
      patch_strategy.create
      Capistrano::CLI.ui.say "Patch location: #{patch_strategy.patch_location}"
      abort unless Capistrano::CLI.ui.ask("Is created patch ok? (y/n)") == 'y'
    end

    desc "Deliver patch"
    task :deliver, :except => { :no_release => true }  do
      patch_strategy.deliver
    end

    desc "Apply patch"
    task :apply, :except => { :no_release => true }  do
      abort unless Capistrano::CLI.ui.ask("Apply #{patch_strategy.patch_file} ? (y/n)") == 'y'
      patch_strategy.check_apply
      patch_strategy.apply
      patch_strategy.mark_apply
    end

    desc "Revert patch"
    task :revert, :except => { :no_release => true }  do
      abort unless Capistrano::CLI.ui.ask("Revert #{patch_strategy.patch_file} ? (y/n)") == 'y'
      patch_strategy.check_revert
      patch_strategy.revert
      patch_strategy.mark_revert
    end
  end
end
