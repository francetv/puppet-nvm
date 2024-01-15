# See README.md for usage information
class nvm::install (
  $user,
  $home,
  $version,
  $nvm_dir,
  $nvm_repo,
  Boolean $dependencies,
  Boolean $refetch,
) {

  if $dependencies {
    $nvm_install_require = Package['git', 'wget', 'make']
    ensure_packages(['git', 'wget', 'make'])
  }
  else {
    $nvm_install_require = undef
  }

  exec { "git clone ${nvm_repo} ${nvm_dir}":
    command => "git clone ${nvm_repo} ${nvm_dir}",
    cwd     => $home,
    user    => $user,
    unless  => "/usr/bin/test -d ${nvm_dir}/.git",
    require => $nvm_install_require,
    notify  => Exec["git checkout ${nvm_repo} ${version}"],
  }

  if $refetch {
    exec { "git fetch ${nvm_repo} ${nvm_dir}":
      command => 'git fetch',
      cwd     => $nvm_dir,
      user    => $user,
      require => Exec["git clone ${nvm_repo} ${nvm_dir}"],
      notify  => Exec["git checkout ${nvm_repo} ${version}"],
    }
  }

  exec { "git checkout ${nvm_repo} ${version}":
    command     => "git checkout --quiet ${version}",
    cwd         => $nvm_dir,
    user        => $user,
    refreshonly => true,
  }
}
