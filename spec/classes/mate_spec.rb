require 'spec_helper'

packages = [
  'caja-open-terminal',
  'caja',
  'gnome-terminal',
  'marco',
  'mate-desktop',
  'mate-polkit',
  'mate-power-manager',
  'mate-session-manager',
  'mate-settings-daemon',
  'mate-themes',
]

describe 'mate' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('mate') }

        packages.each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('installed') }
        end

        it do
          is_expected.to create_dconf__settings('MATE dconf settings: simp_mate')
            .with(
              ensure: 'present',
              profile: 'simp_mate',
              settings_hash: {
                'org/mate/media-handling' => {
                  'automount'      => { 'value' => false },
                  'automount-open' => { 'value' => false },
                  'autorun-never'  => { 'value' => true },
                },
                'org/mate/SettingsDaemon/plugins/media-keys' => {
                  'logout' => { 'value' => "''" },
                },
                'org/mate/power-manager' => {
                  'button-power' => { 'value' => "'nothing'" },
                },
                'org/mate/session' => {
                  'idle-delay' => { 'value' => 'uint32 900' },
                },
                'org/mate/screensaver' => {
                  'idle-activation-enabled' => { 'value' => true },
                  'lock-enabled'            => { 'value' => true },
                  'lock-delay'              => { 'value' => 0 },
                },
              },
            )
        end
      end
    end
  end
end
