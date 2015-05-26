require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include git
  include brewcask

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { 'v0.10': }

  # default ruby versions
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar',
    ]:
  }

  package { 'owncloud': 
    provider => 'brewcask' 
  }

  package { 'keepassx':
    provider => 'brewcask'
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }

  include chrome
  include python
  include iterm2::stable
  include virtualbox
  include wireshark

  include iterm2::colors::arthur
  include iterm2::colors::piperita
  include iterm2::colors::saturn
  include iterm2::colors::solarized_light
  include iterm2::colors::solarized_dark
  include iterm2::colors::zenburn

  include vim
  vim::bundle {[
    'godlygeek/tabular',
    'rodjek/vim-puppet',
    'tpope/vim-sensible',
  ]:}

  include osx::global::tap_to_click
  include osx::finder::show_hidden_files

  include osx::global::disable_remote_control_ir_receiver
  include osx::global::disable_autocorrect

  class { 'osx::dock::hot_corners':
    top_right => "Start Screen Saver",
  }

  class { 'osx::global::natural_mouse_scrolling':
    enabled => false
  }

}
