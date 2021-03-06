# v3.0.0 (2021-02-25)

* Feature: add middleware in production/staging to maintain second-level domain, e.g. planningcenter.com when generating URLs
* Chore: test on more modern versions of Ruby and Rails

# v2.1.3 (2020-01-14)

* Chore: no code changes; just bumping the version and rebuilding the gem file with proper file permissions [Tim Morgan]

# v2.1.2 (2020-01-13)

* Fix: Always use pco.test in test environment [Tim Morgan]

# v2.1.1 (2019-12-10)

* Chore: A bunch of maintenance [Shane Bonham]
* Fix: `NameError` raised by `aci_delete_org` [Shane Bonham]

# v2.1.0 (2019-11-05)

* Feature: Add support in dev for any TLD [Tim Morgan]

# v2.0.2 (2019-01-21)

* Fix: Repair downcased encrypted params even better

# v2.0.1 (2013-01-21)

* Fix: Repair downcased encrypted params

# v2.0.0 (2018-09-21)

* Chore: inline URLcrypt for threadsafety

# 1.9.0

* Chore: Update URL for local dev to use pco.test and churchcenter.test

# 1.8.0

* Chore: Update URL for churchcenter.com

# 1.7.1

* Fix: Allow `_e` encrypted param to be accompanied by unencrypted params [Geo Lessel]

# 1.7.0

* Feature: Add support for Church Center [Tim Morgan]
* Fix: Remove https from get site URLs [Daniel Murphy]

# 1.6.0

* Feature: Add support for custom domains [James Miller]

# 1.5.0

* Fix: Ensure URLs don't have double-slashes between hostname and path [James Miller]

# 1.4.0

* Feature: Refactor to allow instantiating a PCO::URL object, add encrypted query parameters functionality [James Miller]
* Feature: Add .parse method to parse PCO::URL strings [Geo Lessel]
* Feature: Add support for partial encrypted query strings [James Miller]

# 1.3.0

* Feature: Allow people to specificy path [Jeff Berg]

# 1.2.0

* Feature: Convert any method call to a URL instead of having a whitelist [James Miller]

# 1.1.0

* Feature: Make applications list a changeable array [James Miller]

# 1.0.0

Initial release [James Miller]
