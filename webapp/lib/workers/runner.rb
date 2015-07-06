require File.join(File.dirname(__FILE__), "../app/config" )

module Microsite
  class Runner

    attr_reader :config, :releases, :branches, :workspace, :repo_name

    def initialize
      @config    = Microsite::Config.load
      @releases  = config["runner"]["releases"]
      @branches  = config["runner"]["branches"]
      @workspace = config["runner"]["workspace"]
      @repo_name = config["runner"]["repo"]
      @ruby      = config["runner"]["rvm"]["ruby"]
      @gemset    = config["runner"]["rvm"]["gemset"]
    end

    def perform
      setup_script = config["runner"]["setup"]
      cmd = "#{setup_script} #{workspace}"
      system(cmd)
    end

    def update_releases
      releases.each do |release|
        filename       = "logstash-#{release}.tar.gz"
        download_url   = "https://download.elasticsearch.org/logstash/logstash/#{filename}"
        source_file    = "#{workspace}/#{filename}"
        next if File.exist?(source_file)
        `wget #{download_url} -O #{source_file}`
        `tar -xvzf #{source_file} -C #{workspace}`
        install_perftool File.join(workspace, "logstash-#{release}")
      end
      true
    end

    def update_gitrepo
      repo_path = File.join(workspace, "logstash")
      `rm -rf #{repo_path}`
      `git clone #{repo_name} #{repo_path}`
      install_perftool repo_path
    end

    def install_perftool(base_path)
      File.write(File.join(base_path, ".ruby-version"),@ruby)
      File.write(File.join(base_path, ".ruby-gemset"),@gemset)
      `cd #{base_path}; gem install logstash-perftool; cd -`
    end

  end
end
