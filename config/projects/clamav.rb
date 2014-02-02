
name 'clamav'
maintainer 'Jonathan Hartman'
homepage 'https://github.com/RoboticCheese/clamav-omnibus'

replaces        'clamav'
install_path    '/opt/clamav'
build_version   '0.98.1'
build_iteration 1

# creates required build directories
dependency 'preparation'

# clamav dependencies/components
dependency 'clamav'

# version manifest file
dependency 'version-manifest'

exclude '\.git*'
exclude 'bundler\/git'
