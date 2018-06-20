require 'spec_helper_acceptance'

test_name 'MATE'

describe 'MATE' do
  let(:manifest) {
    <<-EOS
      include '::mate'
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      context 'default parameters' do
        it 'should work with no errors' do
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be idempotent' do
          apply_manifest_on(host, manifest, {:catch_changes => true})
        end

        it 'should have MATE installed' do
          host.check_for_command('mate-session').should be true
        end
      end
    end
  end
end
