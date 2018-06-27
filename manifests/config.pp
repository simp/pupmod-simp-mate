# Set MATE configuration items
#
# @api private
class mate::config {
  assert_private()

  dconf::profile { 'mate_user':
    entries => $mate::dconf_profile_hierarchy
  }

  $mate::dconf_hash.each |String $profile_name, Hash $settings| {
    dconf::settings { "MATE dconf settings: ${profile_name}":
      profile       => $profile_name,
      settings_hash => $settings
    }
  }
}
