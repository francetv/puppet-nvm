require 'spec_helper'

describe 'nvm::node::install', :type => :define do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:title) { 'foo' }
      let(:facts) do
        os_facts
      end
      let(:title) { '0.12.7' }
      let(:pre_condition) do
        [
          'class { "nvm": user => "foo" }'
        ]
      end

      context 'with set_default => false' do
        let :params do
          {
            user: 'foo',
            nvm_dir: '/nvm_dir',
            set_default: false,
          }
        end

        it { is_expected.to contain_exec('nvm install node version 0.12.7')
                              .with_cwd('/nvm_dir')
                              .with_command('. /nvm_dir/nvm.sh && nvm install  0.12.7')
                              .with_user('foo')
                              .with_unless('. /nvm_dir/nvm.sh && nvm which 0.12.7')
                              .that_requires('Class[nvm::install]')
                              .with_provider('shell')
        }
        it { is_expected.not_to contain_exec('nvm set node version 0.12.7 as default') }
      end

      context 'with set_default => true' do
        let :params do
          {
            user: 'foo',
            nvm_dir: '/nvm_dir',
            set_default: true,
          }
        end

        it { is_expected.to contain_exec('nvm install node version 0.12.7')
                              .with_cwd('/nvm_dir')
                              .with_command('. /nvm_dir/nvm.sh && nvm install  0.12.7')
                              .with_user('foo')
                              .with_unless('. /nvm_dir/nvm.sh && nvm which 0.12.7')
                              .that_requires('Class[nvm::install]')
                              .with_provider('shell')
        }
        it { is_expected.to contain_exec('nvm set node version 0.12.7 as default')
                              .with_cwd('/nvm_dir')
                              .with_command('. /nvm_dir/nvm.sh && nvm alias default 0.12.7')
                              .with_user('foo')
                              .with_unless('. /nvm_dir/nvm.sh && nvm which default | grep 0.12.7')
                              .with_provider('shell')
        }
      end

      context 'with from_source => true' do
        let :params do
          {
            user: 'foo',
            nvm_dir: '/nvm_dir',
            from_source: true
          }
        end

        it { is_expected.to contain_exec('nvm install node version 0.12.7')
                              .with_cwd('/nvm_dir')
                              .with_command('. /nvm_dir/nvm.sh && nvm install  -s  0.12.7')
                              .with_user('foo')
                              .with_unless('. /nvm_dir/nvm.sh && nvm which 0.12.7')
                              .that_requires('Class[nvm::install]')
                              .with_provider('shell')
        }
        it { is_expected.not_to contain_exec('nvm set node version 0.12.7 as default') }
      end

      context 'without required param user' do
        it { expect { catalogue }.to raise_error }
      end
    end
  end
end
