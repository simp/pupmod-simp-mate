require 'spec_helper_acceptance'

test_name 'MATE'

describe 'MATE' do
  let(:manifest) do
    <<-EOS
      include '::mate'
    EOS
  end

  hosts.each do |host|
    context "on #{host}" do
      context 'default parameters' do
        it 'enables EPEL (provides MATE packages)' do
          enable_epel_on(host)
        end

        it 'works with no errors' do
          apply_manifest_on(host, manifest, catch_failures: true)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, { catch_changes: true })
        end

        it 'has MATE installed' do
          # Check the binary directly rather than via `which`, which is not
          # present in minimal containers.
          on(host, 'test -x /usr/bin/mate-session')
        end
      end
    end
  end
end
