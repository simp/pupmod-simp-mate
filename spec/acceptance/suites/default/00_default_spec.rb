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
        it 'works with no errors' do
          apply_manifest_on(host, manifest, catch_failures: true)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, { catch_changes: true })
        end

        it 'has MATE installed' do
          host.check_for_command('mate-session').should be true
        end
      end
    end
  end
end
