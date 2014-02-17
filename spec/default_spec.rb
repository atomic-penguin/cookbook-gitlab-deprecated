require 'spec_helper'

describe 'gitlab::default' do

  before do
    stub_command('git --version >/dev/null').and_return(true)
  end

  context 'on Centos 6.4 with mysql and https' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.override['gitlab']['database']['type'] = 'mysql'
        node.override['gitlab']['https'] = true
        node.override['gitlab']['web_fqdn'] = 'gitlab.example.com'
      end.converge(described_recipe)
    end

    it 'includes gitlab::mysql' do
      expect(chef_run).to include_recipe('gitlab::mysql')
    end

    it 'renders gitlab-shell/config.yml with https://.*:443' do
      expect(chef_run).to render_file('/srv/git/gitlab-shell/config.yml').with_content(%r{gitlab_url: "https://.*:443/"})
    end

    it 'renders config/gitlab.yml with https: true' do
      expect(chef_run).to render_file('/srv/git/gitlab/config/gitlab.yml').with_content(/https: true/)
    end

    it 'renders database.yml with mysql2 adapter and utf8 encoding' do
      expect(chef_run).to render_file('/srv/git/gitlab/config/database.yml').with_content(/adapter:\s+mysql2/)
      expect(chef_run).to render_file('/srv/git/gitlab/config/database.yml').with_content(/encoding:\s+utf8/)
    end

    it 'runs execute without postgres' do
      expect(chef_run).to run_execute(/bundle install --deployment --without.*postgres.*/)
    end

    it 'ISSUE #67 does not include cookbook sudo' do
      expect(chef_run).to_not include_recipe('sudo')
    end

    it 'ISSUE #67 includes package sudo' do
      expect(chef_run).to install_package('sudo')
    end

    it 'ISSUE #69 renders gitlab shell config with gitlab_url' do
      expect(chef_run).to render_file('/srv/git/gitlab-shell/config.yml').with_content(%r{gitlab_url:.*https://gitlab.example.com})
    end

    it 'ISSUE #69 does not render gitlab shell config with boolean' do
      expect(chef_run).to_not render_file('/srv/git/gitlab-shell/config.yml').with_content(%r{gitlab_url:.*https://(true|false)})
    end
  end

  context 'on Centos 6.4 with postgres and http' do
    let(:chef_run) do
      ChefSpec::Runner.new(platform: 'centos', version: 6.4) do |node|
        node.override['gitlab']['database']['type'] = 'postgres'
        node.override['gitlab']['web_fqdn'] = 'gitlab.example.com'
      end.converge(described_recipe)
    end

    it 'includes gitlab::postgres' do
      expect(chef_run).to include_recipe('gitlab::postgres')
    end

    it 'renders gitlab-shell/config.yml with gitlab_url: http://*:80' do
      expect(chef_run).to render_file('/srv/git/gitlab-shell/config.yml').with_content(%r{gitlab_url: "http://.*:80/"})
    end

    it 'renders config/gitlab.yml with https: false' do
      expect(chef_run).to render_file('/srv/git/gitlab/config/gitlab.yml').with_content(/https: false/)
    end

    it 'renders database.yml with postgresql adapter and unicode encoding' do
      expect(chef_run).to render_file('/srv/git/gitlab/config/database.yml').with_content(/adapter:\s+postgresql/)
      expect(chef_run).to render_file('/srv/git/gitlab/config/database.yml').with_content(/encoding:\s+unicode/)
    end

    it 'runs execute without postgres' do
      expect(chef_run).to run_execute(/bundle install --deployment --without.*mysql.*/)
    end

    it 'ISSUE #67 does not include cookbook sudo' do
      expect(chef_run).to_not include_recipe('sudo')
    end

    it 'ISSUE #67 includes package sudo' do
      expect(chef_run).to install_package('sudo')
    end

    it 'ISSUE #69 renders gitlab shell config with gitlab_url' do
      expect(chef_run).to render_file('/srv/git/gitlab-shell/config.yml').with_content(%r{gitlab_url:.*http://gitlab.example.com})
    end

    it 'ISSUE #69 does not render gitlab shell config with boolean' do
      expect(chef_run).to_not render_file('/srv/git/gitlab-shell/config.yml').with_content(%r{gitlab_url:.*http://(true|false)})
    end
  end
end
