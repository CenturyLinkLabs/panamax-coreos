# Changelog
All notable changes to this project will be documented in this file.

0.3.0 - 2014-10-07
-----------------
### Added
- Updated cAdvisor to 0.4.1 ([Issue #54](https://github.com/CenturyLinkLabs/panamax-coreos/issues/54)) 
- Updated brew setup script to use standard brew setup paths.

0.2.3 - 2014-10-02
-----------------
### Added
- Updated CoreOS version to 410.2.0 to further address Shellshock vulnerability

0.2.2 - 2014-09-29
-----------------
### Added 
- Updated CoreOS version to 410.1.0 to address Shellshock vulnerability 

0.2.1 - 2014-09-22
-----------------
### Added - (Desktop version only)
- Entry to vagrant file to create Private IP for CoreOS VM via Host-Only adaptor.
  - Panamax now runs on `http://10.0.0.200:3000`
  - All applications that have a host port assigned, run via that IP. Example: `http://10.0.0.200:8080`
- Option for Panamax to create alias, `panamax.local`, for private IP - requires Admin password
  - Panamax and applications can be accessed using alias rather than IP. Example: `http://panamax.local:3000`

0.2.0 - 2014-09-09
-----------------
### Added
- Core OS 410.0.0
- CAdvisor 0.2.2
  - Reduces Panamax Download Size by about ~70%


0.1.4 - 2014-09-03
-----------------
### Added
- Debug feature
  - Dumps environment values for Panamax to aid in debugging
  - Use: $ panamax debug

### Fixed
- Port forwarding being reset. (Thanks to rwfowler@gmail.com for issue #39)
- Image tag 'stable' does not exist. (Thanks to @justinsb for issue #35)

0.1.3 - 2014-08-27 
-----------------

### Fixed
- Fix for home-directories with whitespaces (Thanks to @timoabend for pull request #34)
- Updated default RAM to 1.5 GB

0.1.2 - 2014-08-21
------------------

### Added
- License

### Fixed
- Fix CoreOS endpoint

0.1.1 - 2014-08-12
------------------

Initial beta release


