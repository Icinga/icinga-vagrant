require 'spec_helper'

describe 'docker::image', type: :define do
  let(:title) { 'base' }
  let(:facts) do
    {
      architecture: 'amd64',
      osfamily: 'windows',
      operatingsystem: 'windows',
      kernelrelease: '10.0.14393',
      operatingsystemrelease: '2016',
      operatingsystemmajrelease: '2016',
      docker_program_data_path: 'C:/ProgramData',
      docker_program_files_path: 'C:/Program Files',
      docker_systemroot: 'C:/Windows',
      docker_user_temp_path: 'C:/Users/Administrator/AppData/Local/Temp',
      os: { family: 'windows', name: 'windows', release: { major: '2016', full: '2016' } },
    }
  end

  context 'with ensure => present' do
    let(:params) { { 'ensure' => 'present' } }

    it { is_expected.to contain_file('C:/Users/Administrator/AppData/Local/Temp/update_docker_image.ps1') }
    it { is_expected.to contain_exec('& C:/Users/Administrator/AppData/Local/Temp/update_docker_image.ps1 -DockerImage base') }
  end

  context 'with docker_file => Dockerfile' do
    let(:params) { { 'docker_file' => 'Dockerfile' } }

    it { is_expected.to contain_exec('Get-Content Dockerfile -Raw | docker build -t base -') }
  end

  context 'with ensure => present and docker_file => Dockerfile' do
    let(:params) { { 'ensure' => 'present', 'docker_file' => 'Dockerfile' } }

    it { is_expected.to contain_exec('Get-Content Dockerfile -Raw | docker build -t base -') }
  end

  context 'with ensure => present and image_tag => nanoserver' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'nanoserver' } }

    it { is_expected.to contain_exec('& C:/Users/Administrator/AppData/Local/Temp/update_docker_image.ps1 -DockerImage base:nanoserver') }
  end

  context 'with ensure => present and image_digest => sha256:deadbeef' do
    let(:params) { { 'ensure' => 'present', 'image_digest' => 'sha256:deadbeef' } }

    it { is_expected.to contain_exec('& C:/Users/Administrator/AppData/Local/Temp/update_docker_image.ps1 -DockerImage base@sha256:deadbeef') }
  end

  context 'with ensure => present and image_tag => nanoserver and docker_file => Dockerfile' do
    let(:params) { { 'ensure' => 'present', 'image_tag' => 'nanoserver', 'docker_file' => 'Dockerfile' } }

    it { is_expected.to contain_exec('Get-Content Dockerfile -Raw | docker build -t base:nanoserver -') }
  end

  context 'with ensure => latest' do
    let(:params) { { 'ensure' => 'latest' } }

    it { is_expected.to contain_exec('& C:/Users/Administrator/AppData/Local/Temp/update_docker_image.ps1 -DockerImage base') }
    it { is_expected.to contain_exec("echo 'Update of base complete'") }
  end
end
