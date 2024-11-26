#!/bin/bash
# vim: dict+=/usr/share/beakerlib/dictionary.vim cpt=.,w,b,u,t,i,k
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   lib.sh of /CoreOS/distribution/Library/virtual-network
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
#   library-prefix = vn
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 NAME

distribution/virtual-network - Virtual Network.

=head1 DESCRIPTION

Virtual Network (vn) library is used for testing server-client network scenarios
on a singlehost machine. It uses network namespaces and virtual ethernet for
creating server-client network.

=cut


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Variables
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 VARIABLES

=over

=item vnSIDE

Name of the side on which vnRun runs set command.
It can be set manually to values 'server' or
'client'. Default is 'server'.

=item vnSERVER_IFACE

Name of the server side network interface.

=item vnCLIENT_IFACE

Name of the client side network interface.

=item vnSERVER_NAMESPACE

Name of the server side network namespace.

=item vnCLIENT_NAMESPACE

Name of the client side network namespace.

=back

=cut
vnSIDE='server'
vnSERVER_IFACE='VNS'
vnCLIENT_IFACE='VNC'
vnSERVER_NAMESPACE='vns'
vnCLIENT_NAMESPACE='vnc'


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 FUNCTIONS

=cut

true <<'=cut'
=pod

=head2 vnCreateServerClientNetwork

Function creates server-client network.

=cut
vnCreateServerClientNetwork()
{
    rlRun "ip link add ${vnSERVER_IFACE} type veth peer name ${vnCLIENT_IFACE}" 0 "Creating network ifaces for SERVER: '${vnSERVER_IFACE}' and CLIENT: '${vnCLIENT_IFACE}'."

    rlRun "ip netns add ${vnSERVER_NAMESPACE}" 0 "Creating SERVER namespace: '${vnSERVER_NAMESPACE}'."
    rlRun "ip netns add ${vnCLIENT_NAMESPACE}" 0 "Creating CLIENT namespace: '${vnCLIENT_NAMESPACE}'."

    rlRun "ip link set ${vnSERVER_IFACE} netns ${vnSERVER_NAMESPACE}" 0 "Adding iface: '${vnSERVER_IFACE}' into the namespace: '${vnSERVER_NAMESPACE}'."
    rlRun "ip link set ${vnCLIENT_IFACE} netns ${vnCLIENT_NAMESPACE}" 0 "Adding iface: '${vnCLIENT_IFACE}' into the namespace: '${vnCLIENT_NAMESPACE}'."
}

true <<'=cut'
=pod

=head2 vnRemoveServerClientNetwork

Function removes server-client network.

=cut
vnRemoveServerClientNetwork()
{
    rlRun "ip netns exec ${vnSERVER_NAMESPACE} ip link del ${vnSERVER_IFACE}" 0 "Removing network for SERVER and CLIENT."

    rlRun "ip netns del ${vnSERVER_NAMESPACE}" 0 "Removing SERVER namespace: '${vnSERVER_NAMESPACE}'."
    rlRun "ip netns del ${vnCLIENT_NAMESPACE}" 0 "Removing CLIENT namespace: '${vnCLIENT_NAMESPACE}'."
}

true <<'=cut'
=pod

=head2 vnRunServer

Function runs command, which is added as a first parameter, on server side.

=cut
vnRunServer()
{
    local command="$1"
    local ret_val="${2:-0}"
    local message="${3:-Running command on the SERVER: '${command}'}"
    
    rlRun "ip netns exec ${vnSERVER_NAMESPACE} ${command}" "$ret_val" "$message"
}

true <<'=cut'
=pod

=head2 vnRunClient

Function runs command, which is added as a first parameter, on client side.

=cut
vnRunClient()
{
    local command="$1"
    local ret_val="${2:-0}"
    local message="${3:-Running command on the CLIENT: '${command}'}"

    rlRun "ip netns exec ${vnCLIENT_NAMESPACE} ${command}" "$ret_val" "$message"
}

true <<'=cut'
=pod

=head2 vnRun

Function runs command, which is added as a first parameter. Side is choosen by vnSIDE variable.

=cut
vnRun()
{
    if [ "$vnSIDE" = 'server' ]; then
        vnRunServer "$1" "$2" "$3"
    elif [ "$vnSIDE" = 'client' ]; then
        vnRunClient "$1" "$2" "$3"
    else
        rlLogError "'vnSIDE' variable is not set properly."
    fi
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Execution
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 EXECUTION

This library supports direct execution. When run as a task, phases
provided in the PHASE environment variable will be executed.
Supported phases are:

=cut


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Verification
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
#   This is a verification callback which will be called by
#   rlImport after sourcing the library to make sure everything is
#   all right. It makes sense to perform a basic sanity test and
#   check that all required packages are installed. The function
#   should return 0 only when the library is ready to serve.

vnLibraryLoaded() {
    return 0
}


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Authors
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

true <<'=cut'
=pod

=head1 AUTHORS

=over

=item *

Jaroslav Aster <jaster@redhat.com>

=back

=cut

