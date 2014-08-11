# Panamax: Docker Management for Humans

[Panamax](http://panamax.io) is a containerized app creator with an open-source app marketplace hosted in GitHub. Panamax provides a friendly interface for users of Docker, Fleet & CoreOS. With Panamax, you can easily create, share, and deploy any containerized app no matter how complex it might be. Learn more at [Panamax.io](http://panamax.io) or browse the [Panamax Wiki](https://github.com/CenturyLinkLabs/panamax-ui/wiki).

# panamax-coreos

panamax-coreos installs the Panamax application, which is made up of the [panamax-ui](https://github.com/CenturyLinkLabs/panamax-ui) and [panamax-api](https://github.com/CenturyLinkLabs/panamax-api) codebases.

## Installation

1. Clone the repo to the local desktop/coreos.
2. To use on desktop, run ./panamax {init|up|pause|restart|download|info|reinstall|delete} [-ppUi=<panamax UI port>] [-ppApi=<panamax API port>] [--dev|stable]
3. To use on coreos VM, run ./coreos &lt;install/resintall/restart/stop&gt;
