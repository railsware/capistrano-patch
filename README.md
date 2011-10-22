# Capistrano patch recipes

## Concept

Usual deployment procedure is pretty good. 
But real project are big and offen have several megabytes of code. So standard deployment is not so fast.
You need chekout new code, prepare all symplinks, etc ... It takes the time.

Sometimes you need to *quickly* apply hostfix that fixes critical bug. 
Usually such fix is small and may contain only several lines of code.
Doing it manual it's not good from any point of view.

So that's why *capistrano patch recipes* appears. They are extracted from real big project.

It's automated solution for safely code patching on any stage.

Depending on patch strategy `cap patch` :

* creates patch file
* delivers patch file to all application servers
* checks patch
* applies patch
* updates REVISION

If something went wrong your also able to quickly revert patch with `cap patch:revert`. See recipes below.


## Installation

    gem install capistrano-patch

Add to `Capfile`

    # load standard capistrano recipes
    load 'deploy' 

    # load patch recipes
    require 'capistrano/patch' 

## Configuration

* *:patch_via* - patch strategy (default `:git`)
* *:patch_repository* - SCM repository that will be using for generating diffs (default `.git`)
* *:patch_directory* - directory for storing generated patches (default `.`)
* *:patch_base_url* - base url for patch download ( default `nil`)
* *:patch_server_host* - server host for patch generating ( default `nil`)
* *:patch_server_options* -server host options ( default `{}`)

## Patch strategies

Patch strategy is about how to process code patching on stage. It also depends on patch source (or scm).

Currently implemented patch strategies:

* git
* git_server

## Git strategy

It's simple strategy that is suitable for almost all git projects.

### Integrated deployment

When you use capistrano directly into your application you need zero configuration.

### Separated deployment

When you have separated deployment repository you need to specify patch repository and directory.

Example:

    set(:patch_repository) { "../#{application}.git" }
    set(:patch_directory)  { "/tmp/patches/#{application}" }

## GitServer strategy

For big projects offen is required to generate patch using some certain or origin repository and store generated patch in some directory there. Thus patch can be accessible from directory server via http and delivered to application servers from the same host where repository is located.

Example:

    set :patch_via, :git_server

    set(:patch_repository) { "/var/git/repositories/#{application}.git" }
    set(:patch_directory)  { "/var/www/patches/#{application}" }
    set(:patch_base_url)   { "http://scm.example.com/patches/#{application}" }  

    set :patch_server_host, "scm.example.com"

### Extra options

Patch server is not in global capistrano servers list.
So any other task will not affect your server. And this is good.
But offen you need to specify different options to patch server instead of global values.

When you want to specify just another `user` or `port` you can do it in `patch_server_host` variable:

    set :patch_server_host, "USER@scm.example.com:PORT"

or using `patch_server_options` variable:

    set :patch_server_options, {
      :user => 'patcher',
      :port => 2222
    }

Also you are able to specify another ssh keys:

    set :patch_server_options, {
      :ssh_options => { :auth_methods => %w(publickey), :keys => %w(keys/patcher.pem) }
    }

## Recipes

### Create deliver and apply patch

    $ cap patch FROM=v0.0.1 TO=v0.0.2

or

    $ cap patch PATCH=v0.0.1-v0.0.2

or

    $ cap patch FROM=development TO=master


* It will create patch file like `sha1-sha2.patch`
* It will deliver patch file to all application servers
* It will check patch before applying
* It will apply check
* It will update REVISION after applying


### Create patch

    $ cap patch:create FROM=v0.0.1 TO=v0.0.2

Create file like: `6c5923863a288b089a6a2bc11e560f0d28dabfb6-92e018dbda8a91c442e40257b81097ceeb150876.patch`

### Deliver patch

If patch file is missing on some server you can manualy deliver it with

    $ cap patch:deliver FROM=v0.0.1 TO=v0.0.2 HOSTFILTER='app1'

### Apply patch

If may manualy apply patch on some server:

    $ cap patch:apply FROM=v0.0.1 TO=v0.0.2 HOSTFILTER='app1'

### Revert patch


If something went bad you may revert patch

    $ cap patch:revert FROM=v0.0.1 TO=v0.0.2
    # or
    $ cap patch:revert PATCH=v0.0.1-v0.0.2
    # or
    $ cap patch:revert PATCH=6c5923863a288b089a6a2bc11e560f0d28dabfb6-92e018dbda8a91c442e40257b81097ceeb150876.patch

