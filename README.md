# scripts
Helpful scripts I've written for various reasons

- aws-r53-dynamic-update.sh
    + Use to automatically update a record set in AWS Route 53 whenever your IP changes (good for home-based domains that use DHCP (Verizon FIOS, Comcast, etc))
- brew-cask-upgrade.sh
    + Upgrades brew casks
- brew-full-upgrade.sh
    + Updates brew and then upgrades any updated formulae and casks
- compare-json.sh
    + Compares the contents of two JSON files, and the results are displayed in vimdiff (or diff if vimdiff not available).
