#!/bin/bash
set -e
echo -------------------------------------------------------------------------------
echo Architecture: ${ARCH}
echo Mirror: ${MIRROR}
echo Skip SSL certificate check: ${WGET_NO_CHECK_CERTIFICATE}
echo -------------------------------------------------------------------------------
if [ -n $MIRROR ]; then
		echo "$MIRROR" > /etc/slackpkg/mirrors
fi
if [ "$WGET_NO_CHECK_CERTIFICATE" = 'true' ]; then
		echo 'check_certificate = off' >> /root/.wgetrc
fi

# Test update
slackpkg update || ( echo 'ERROR: Updating Slackpkg failed!'; exit 99 )

# Test base image being up to date with mirror
slackpkg check-updates && echo 'INFO: No updates available.' || ( if [ $? -eq 100 ]; then
		echo 'ERROR: Packages are not up to date!'
else
		echo 'ERROR: Checking for updates failed!'
fi ; exit 99 )
slackpkg upgrade-all && ( echo 'ERROR: Upgrades available!'; exit 99 ) || if [ $? -eq 20 ]; then
		echo 'INFO: Packages are fully upgraded.'
else
		echo 'ERROR: Checking for upgradeable packages failed!'
		exit 99
fi

# Test installation of glibc
slackpkg install glibc || exit 99

# Test LONG_BIT
case $ARCH in
		i686 | i586 | i486 | i386)
				LONG_BIT='32'
		;;
		x86_64)
				LONG_BIT='64'
		;;
		*)
				echo "ERROR: Unable to determine expected long bit! Expected ARCH to be one of [ x86_64 | i686 | i586 | i486 | i386 ] but got ${ARCH} instead."
				exit 98
		;;
esac
echo "INFO: Long bit `getconf LONG_BIT`, expected $LONG_BIT"
test `getconf LONG_BIT` = "$LONG_BIT" || exit 98

# Test umask
test `umask` = 0022 || exit 97

echo 'INFO: All test completed successfully.'
exit 0