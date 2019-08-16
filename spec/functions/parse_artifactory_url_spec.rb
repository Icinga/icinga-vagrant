require 'spec_helper'

describe 'archive::parse_artifactory_url' do
  it { is_expected.not_to eq(nil) }
  it { is_expected.to run.with_params.and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('not_a_url').and_raise_error(ArgumentError) }

  context 'releases' do
    it do
      is_expected.to run.with_params('https://repo.jfrog.org/artifactory/repo1-cache/maven-proxy/maven-proxy-webapp/0.2/maven-proxy-webapp-0.2.war').and_return(
        'base_url'        => 'https://repo.jfrog.org/artifactory',
        'repository'      => 'repo1-cache',
        'org_path'        => 'maven-proxy',
        'module'          => 'maven-proxy-webapp',
        'base_rev'        => '0.2',
        'folder_iteg_rev' => nil,
        'file_iteg_rev'   => nil,
        'classifier'      => nil,
        'ext'             => 'war'
      )
    end
    context 'with classifier' do
      it do
        is_expected.to run.with_params('https://repo.jfrog.org/artifactory/repo1-cache/maven-proxy/maven-proxy-standalone/0.2/maven-proxy-standalone-0.2-app.jar').and_return(
          'base_url'        => 'https://repo.jfrog.org/artifactory',
          'repository'      => 'repo1-cache',
          'org_path'        => 'maven-proxy',
          'module'          => 'maven-proxy-standalone',
          'base_rev'        => '0.2',
          'folder_iteg_rev' => nil,
          'file_iteg_rev'   => nil,
          'classifier'      => 'app',
          'ext'             => 'jar'
        )
      end
    end
  end
  context 'SNAPSHOTs' do
    it do
      is_expected.to run.with_params('https://repo.jfrog.org/artifactory/java.net-cache/com/sun/grizzly/grizzly-framework/2.0.0-SNAPSHOT/grizzly-framework-2.0.0-SNAPSHOT.jar').and_return(
        'base_url'        => 'https://repo.jfrog.org/artifactory',
        'repository'      => 'java.net-cache',
        'org_path'        => 'com/sun/grizzly',
        'module'          => 'grizzly-framework',
        'base_rev'        => '2.0.0',
        'folder_iteg_rev' => 'SNAPSHOT',
        'file_iteg_rev'   => 'SNAPSHOT',
        'classifier'      => nil,
        'ext'             => 'jar'
      )
    end
    context 'with classifiers' do
      it do
        is_expected.to run.with_params('https://repo.jfrog.org/artifactory/java.net-cache/com/sun/grizzly/grizzly-framework/2.0.0-SNAPSHOT/grizzly-framework-2.0.0-SNAPSHOT-javadoc.jar').and_return(
          'base_url'        => 'https://repo.jfrog.org/artifactory',
          'repository'      => 'java.net-cache',
          'org_path'        => 'com/sun/grizzly',
          'module'          => 'grizzly-framework',
          'base_rev'        => '2.0.0',
          'folder_iteg_rev' => 'SNAPSHOT',
          'file_iteg_rev'   => 'SNAPSHOT',
          'classifier'      => 'javadoc',
          'ext'             => 'jar'
        )
      end
      it do
        is_expected.to run.with_params('https://repo.jfrog.org/artifactory/java.net-cache/com/sun/grizzly/grizzly-framework/2.0.0-SNAPSHOT/grizzly-framework-2.0.0-SNAPSHOT-tests.jar').and_return(
          'base_url'        => 'https://repo.jfrog.org/artifactory',
          'repository'      => 'java.net-cache',
          'org_path'        => 'com/sun/grizzly',
          'module'          => 'grizzly-framework',
          'base_rev'        => '2.0.0',
          'folder_iteg_rev' => 'SNAPSHOT',
          'file_iteg_rev'   => 'SNAPSHOT',
          'classifier'      => 'tests',
          'ext'             => 'jar'
        )
      end
    end
  end
end
