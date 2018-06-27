# Installs and configures a minimal MATE environment
#
# @param configure
#   Use the module to configure MATE
#
#   @see data/common.yaml
#
# @param dconf_hash
#   Settings specific to dconf and MATE
#
#   @see data/common.yaml
#   @see https://wiki.gnome.org/Projects/dconf/SystemAdministrators
#
# @param dconf_profile_hierarchy
#   Dconf db priority
#
#   @see https://help.gnome.org/admin/system-admin-guide/stable/dconf.html.en
#   @see https://wiki.gnome.org/Projects/dconf/SystemAdministrators
#
# @param packages
#   A Hash of packages to be installed
#
#   * NOTE: Setting this will *override* the default package list
#   * The ensure value can be set in the hash of each package, like the example
#     below:
#
#   @example Override packages
#     { 'gedit' => { 'ensure' => '3.14.3' } }
#
#   @see data/common.yaml
#
# @param package_ensure
#   The SIMP global catalyst to set the default `ensure` settings for packages
#   managed with this module. Will be overwitten by $packages.
#
class mate (
  Boolean                              $configure,
  Hash[String[1], Dconf::SettingsHash] $dconf_hash,
  Dconf::DBSettings                    $dconf_profile_hierarchy,
  Hash[String[1], Optional[Hash]]      $packages,
  Simplib::PackageEnsure               $package_ensure           = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
) {
  simplib::assert_metadata($module_name)

  simplib::install { 'mate':
    packages => $packages,
    defaults => { 'ensure' => $package_ensure }
  }

  if $configure {
    include 'mate::config'

    Simplib::Install['mate'] -> Class['mate::config']
  }
}
