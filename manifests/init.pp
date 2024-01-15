# See README.md for usage information
class nvm (
  String $user,
  Optional[Stdlib::AbsolutePath] $home            = undef,
  Optional[Stdlib::AbsolutePath] $nvm_dir         = undef,
  Optional[Stdlib::AbsolutePath] $profile_path    = undef,
  String $version                                 = $nvm::params::version,
  Boolean $manage_user                            = $nvm::params::manage_user,
  Boolean $manage_dependencies                    = $nvm::params::manage_dependencies,
  Boolean $manage_profile                         = $nvm::params::manage_profile,
  String $nvm_repo                                = $nvm::params::nvm_repo,
  Boolean $refetch                                = $nvm::params::refetch,
  Optional[String] $install_node                  = $nvm::params::install_node,
  Optional[Hash[String[1], Hash]] $node_instances = undef,
) inherits ::nvm::params {
  if $home == undef and $user == 'root' {
    $final_home = '/root'
  }
  elsif $home == undef {
    $final_home = "/home/${user}"
  }
  else {
    $final_home = $home
  }

  if $nvm_dir == undef {
    $final_nvm_dir = "/home/${user}/.nvm"
  }
  else {
    $final_nvm_dir = $nvm_dir
  }

  if $profile_path == undef {
    $final_profile_path = "/home/${user}/.bashrc"
  }
  else {
    $final_profile_path = $profile_path
  }

  Exec {
    path => '/bin:/sbin:/usr/bin:/usr/sbin',
  }

  if $manage_user {
    user { $user:
      ensure     => present,
      home       => $final_home,
      managehome => true,
      before     => Class['nvm::install']
    }
  }

  class { 'nvm::install':
    user         => $user,
    home         => $final_home,
    version      => $version,
    nvm_dir      => $final_nvm_dir,
    nvm_repo     => $nvm_repo,
    dependencies => $manage_dependencies,
    refetch      => $refetch,
  }

  if $manage_profile {
    file { "ensure ${final_profile_path}":
      ensure => file,
      path   => $final_profile_path,
      owner  => $user,
    } ->

    file_line { 'add NVM_DIR to profile file':
      path => $final_profile_path,
      line => "export NVM_DIR=${final_nvm_dir}",
    } ->

    file_line { 'add . ~/.nvm/nvm.sh to profile file':
      path => $final_profile_path,
      line => "[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"\$NVM_DIR/nvm.sh\"  # This loads nvm",
    }
  }

  if $install_node {
    $final_node_instances = merge($node_instances, {
      "${install_node}" => {
        set_default => true,
      },
    })
  }
  else {
    $final_node_instances = $node_instances
  }

  if $final_node_instances {
    create_resources(::nvm::node::install, $final_node_instances, {
      user    => $user,
      nvm_dir => $final_nvm_dir,
    })
  }
}
