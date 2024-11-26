#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   runtest.sh of /CoreOS/distribution/Library/virtual-network
#   Description: Virtual Network (vn) library is used for testing server-client network scenarios.
#   Author: Jaroslav Aster <jaster@redhat.com>
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   Copyright (c) 2018 Red Hat, Inc.
#
#   This program is free software: you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as
#   published by the Free Software Foundation, either version 2 of
#   the License, or (at your option) any later version.
#
#   This program is distributed in the hope that it will be
#   useful, but WITHOUT ANY WARRANTY; without even the implied
#   warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
#   PURPOSE.  See the GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program. If not, see http://www.gnu.org/licenses/.
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1


PACKAGE="iproute"


rlJournalStart
    rlPhaseStartSetup
        rlRun "rlImport virtual-network/virtual-network"
        vnCreateServerClientNetwork
    rlPhaseEnd

    rlPhaseStartTest
        vnRunServer "ip link set ${vnSERVER_IFACE} up"
        vnRunClient "ip link set ${vnCLIENT_IFACE} up"
        vnRunServer "ip addr add 192.168.0.1/24 dev ${vnSERVER_IFACE}"
        vnRunClient "ip addr add 192.168.0.2/24 dev ${vnCLIENT_IFACE}"
        vnRunServer "ping -c 10 192.168.0.2"
        vnRunClient "ping -c 10 192.168.0.1"
    rlPhaseEnd
    
    rlPhaseStartCleanup
        vnRemoveServerClientNetwork
    rlPhaseEnd

    rlJournalPrintText
rlJournalEnd
