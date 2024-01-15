require 'spec_helper'

describe 'nvm::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with refectch => false' do
        let :params do
          {
            user: 'foo',
            home: '/home/foo',
            version: 'version',
            nvm_dir: 'nvm_dir',
            nvm_repo: 'nvm_repo',
            dependencies: true,
            refetch: false
          }
        end

        it { is_expected.to contain_exec('git clone nvm_repo nvm_dir')
                              .with_command('git clone nvm_repo nvm_dir')
                              .with_user('foo')
                              .with_cwd('/home/foo')
                              .with_unless('/usr/bin/test -d nvm_dir/.git')
                              .with_require('[Package[git]{:name=>"git"}, Package[wget]{:name=>"wget"}, Package[make]{:name=>"make"}]')
                              .that_notifies('Exec[git checkout nvm_repo version]')
        }
        it { is_expected.not_to contain_exec('git fetch nvm_repo nvm_dir') }
        it { is_expected.to contain_exec('git checkout nvm_repo version')
                              .with_command('git checkout --quiet version')
                              .with_user('foo')
                              .with_cwd('nvm_dir')
                              .with_refreshonly(true)
        }
      end

      context 'with refetch => true' do
        let :params do
          {
            user: 'foo',
            home: '/home/foo',
            version: 'version',
            nvm_dir: 'nvm_dir',
            nvm_repo: 'nvm_repo',
            dependencies: true,
            refetch: true
          }
        end

        it { is_expected.to contain_exec('git fetch nvm_repo nvm_dir')
                              .with_command('git fetch')
                              .with_cwd('nvm_dir')
                              .with_user('foo')
                              .with_require('Exec[git clone nvm_repo nvm_dir]')
                              .that_notifies('Exec[git checkout nvm_repo version]')
        }
      end

      context 'without required param user' do
        it { is_expected.to compile.and_raise_error(%r{expects a value for parameter 'user'}) }
      end
    end
  end
end
