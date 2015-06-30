# Changelog
All notable changes to this project will be documented in this file.

0.6.4 - 2015-06-30
-----------------
###Added
- Updated CoreOS to latest stable release (681.2.0)

0.6.3 - 2015-05-29
-----------------
###Added
- Updated CoreOS to latest stable release (647.2.0)
- Updated cadvisor to 0.13.0

0.6.2 - 2015-05-13
-----------------
###Added
- Updated CoreOS to latest stable release (647.0.0)

0.6.0 - 2015-04-28
-----------------
###Added
- Bundling panamax remote cli (pmxcli) with panamax brew  and  ubuntu installers. 

0.5.2 - 2015-04-15
-----------------
###Added
- Updated CoreOS to latest stable release (633.1.0)

0.4.0 - 2015-03-19
-----------------
###Added
- Updated CoreOS to latest stable release (607.0.0)

0.3.6 - 2015-02-04
-----------------
### Added
- Added environment variables for API and Dray linkage

0.3.5 - 2015-01-29
-----------------
### Added
- Updated CoreOS to latest stable release (522.6.0).
- Added additional images/containers for future features

### Fixed
- [Issue 494](https://github.com/CenturyLinkLabs/panamax-ui/issues/494) by adding `config.ssh.insert_key = false` to Vagrantfile

0.3.4 - 2014-12-17
-----------------
### Added
- Updated CoreOS to latest stable release (494.5.0).
- Updated cAdvisor 0.6.2

0.3.3 - 2014-12-05
-----------------
### Added
- Updated CoreOS to latest stable release (494.4.0).

0.3.2 - 2014-10-17
-----------------
### Added
- Updated CoreOS to latest stable release (444.5.0).
- Updated panamax configuration to run cadvisor on static port 3002.

0.3.1 - 2014-10-13
-----------------
### Added
- Updated CoreOS to latest stable release (444.4.0).

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


