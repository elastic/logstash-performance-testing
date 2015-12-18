module Microsite
  class Runner

    attr_reader :releases, :branches, :workspace, :repo_name

    def initialize
      @releases  = ENV.fetch('LSPERF_RUNNER_RELEASES', '1.4.2,1.5.0,1.5.1,1.5.2').to_s.split(',')
      @branches  = ENV.fetch('LSPERF_RUNNER_BRANCHES', 'master,1.5').to_s.split(',')
      @workspace = ENV.fetch('LSPERF_RUNNER_WORKSPACE', 'Users/purbon/work/logstash-perf-testing/workspace')
      @repo_name = ENV.fetch('LSPERF_RUNNER_REPO', 'git@github.com:elastic/logstash.git')
      @ruby      = ENV.fetch('LSPERF_RUNNER_RUBY', 'jruby-1.17.20')
      @gemset    = ENV.fetch('LSPERF_RUNNER_GEMSET', 'lsperf-webapp')
    end

    def perform
      setup_script = ENV.fetch('LSPERF_RUNNER_SETUP', '/Users/purbon/work/logstash-perf-testing/scripts/setup.sh')
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
