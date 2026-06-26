require 'spec_helper_acceptance'

test_name 'MATE'

describe 'MATE' do
  let(:manifest) do
    <<-EOS
      include '::mate'
    EOS
  end

  hosts.each do |host|
    # The MATE desktop is shipped via EPEL. As of EL10, EPEL does not yet
    # package MATE (caja, marco, mate-desktop, etc. are all absent, even with
    # CRB enabled), so the module cannot install its packages there. Skip the
    # package-dependent examples on EL10 until EPEL provides MATE for it; the
    # examples still run on EL8/EL9 where the packages exist.
    os_major = fact_on(host, 'os.release.major').to_i
    mate_packaged = os_major < 10

    context "on #{host}" do
      context 'default parameters' do
        it 'enables EPEL (provides MATE packages)' do
          enable_epel_on(host)
        end

        it 'works with no errors' do
          skip('MATE is not packaged in EPEL for EL10 yet') unless mate_packaged
          apply_manifest_on(host, manifest, catch_failures: true)
        end

        it 'is idempotent' do
          skip('MATE is not packaged in EPEL for EL10 yet') unless mate_packaged
          apply_manifest_on(host, manifest, { catch_changes: true })
        end

        it 'has MATE installed' do
          skip('MATE is not packaged in EPEL for EL10 yet') unless mate_packaged
          # Check the binary directly rather than via `which`, which is not
          # present in minimal containers.
          on(host, 'test -x /usr/bin/mate-session')
        end
      end
    end
  end
end
