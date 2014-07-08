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
    "${boxen::config::home}/homebrew/bin",
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
  include osx::global::enable_keyboard_control_access
  include osx::global::expand_print_dialog
  include osx::global::expand_save_dialog
  include osx::global::tap_to_click
  include osx::dock::autohide
  include osx::dock::icon_size
  include osx::finder::show_all_on_desktop
  include osx::finder::empty_trash_securely
  include osx::finder::unhide_library
  include osx::software_update
  include osx::keyboard::capslock_to_control
  include osx::no_network_dsstores

  class { 'osx::dock::hot_corners':
    bottom_left => "Put Display to Sleep",
  }

  git::config::global { 'user.email':
    value  => 'douglasnomizo@outlook.com'
  }

  git::config::global { 'user.name':
    value  => 'Douglas Nomizo'
  }

  
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  include nodejs::v0_6
  include nodejs::v0_8
  include nodejs::v0_10
 
  nodejs::module { 'coffee-script':
    node_version => 'v0.10',
    ensure => '1.6.3',
  }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }
  
  class { 'ruby::global':
    version => '2.1.2'
  }


  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar',
      'nmap'
    ]:
  }

  file { "${boxen::config::srcdir}/myboxen":
    ensure => link,
    target => $boxen::config::repodir
  }
  
  include java
  include python

  include chrome
  include chrome::dev
  include firefox

  include vagrant
  include virtualbox
  include heroku
  class { 'intellij':
    edition => 'ultimate',
    version => '13'
  }

  include postgresql
  include mysql
  include mongodb

  include sublime_text_2

  include alfred
  include caffeine
  include sizeup
  include onepassword
  include keyremap4macbook
  include zsh
  include screen
  include wget
  include autojump
  include ctags
  include tmux

  include steam
  include evernote
  include omnigraffle::pro
  include dropbox
  include googledrive
  include skype
  include adium
  include vlc
  include hipchat
}
