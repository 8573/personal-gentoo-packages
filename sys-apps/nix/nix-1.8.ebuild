# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit user

HOMEPAGE="https://nixos.org/nix/"

# <https://nixos.org/nix/>: "Nix is a powerful package manager for Linux and
# other Unix systems that makes package management reliable and reproducible."
DESCRIPTION="A powerful package manager that makes package management reliable and reproducible"

# <https://nixos.org/nix/about.html>, section "License": "Nix is released
# under the terms of the GNU LGPLv2.1 or (at your option) any later version."
LICENSE="LGPL-2.1+"

SRC_URI="https://nixos.org/releases/${PN}/${P}/${P}.tar.xz"

SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+gc"

# Dependencies are based on
# <https://nixos.org/nix/manual/#sec-prerequisites-source>.

# Nix claims to require "A version of GCC or Clang that supports C++11".
#
# According to their C++11 implementation status pages, GCC and Clang acheived
# full C++11 support at versions 4.8.1 and 3.3 respectively.
CXX_DEPEND="
	|| (
		>=sys-devel/gcc-4.8.1
		>=sys-devel/clang-3.3
	)
	!<sys-devel/gcc-4.8.1
	!<sys-devel/clang-3.3
"

# I'm not sure that the Perl modules are required at build-time.
COMMON_DEPEND="
	>=dev-lang/perl-5.8
	app-arch/bzip2
	>=dev-db/sqlite-3.6.19
	dev-perl/DBI
	dev-perl/DBD-SQLite
	gc? ( dev-libs/boehm-gc )
	dev-libs/openssl
"

DEPEND="
	${COMMON_DEPEND}
	${CXX_DEPEND}
	sys-devel/make
	virtual/pkgconfig
"

RDEPEND="
	${COMMON_DEPEND}
"

src_configure() {
	# <https://nixos.org/nix/manual/#sec-prerequisites-source>, item "The
	# Boehm garbage collector [...]": "To enable it [the Boehm garbage
	# collector], [...] pass the flag `--enable-gc` to `configure`."
	econf \
		$(use_enable gc)
}

pkg_setup() {
	# <https://nixos.org/nix/manual/#ssec-multi-user>, section "Setting up the
	# build users"
	enewgroup nixbld
	for n in $(seq 1 10); do
		enewuser "nixbld${n}" -1 -1 -1 nixbld
		# Nix seems to need the nixbld users to be listed as members of the
		# nixbld group in `/etc/group`; `enewuser` does not seem to add the
		# users to `/etc/group`.
		gpasswd -a "nixbld${n}" nixbld
	done

	# <https://nixos.org/nix/manual/#ssec-multi-user>, section "Restricting
	# access"
	enewgroup nix-users
}

src_install() {
	default

	D_NIX_ROOT="${D}/nix"
	mkdir -m 0755   "${D_NIX_ROOT}"
	#chown root:root "${D_NIX_ROOT}"

	# <https://nixos.org/nix/manual/#ch-files>, section on `nix.conf`, item
	# `build-users-group`: "`/nix/store` should be owned by the Nix account
	# [the root user], its group should be the group specified here
	# [`nixbld`], and its mode should be `1775`"
	D_NIX_STORE="${D_NIX_ROOT}/store"
	mkdir -m 1775 "${D_NIX_STORE}"
	chgrp nixbld  "${D_NIX_STORE}"

	# Provide a default Nix configuration file.
	D_NIX_CONF="${D}/etc/nix"
	mkdir -m 0755 -p          "${D_NIX_CONF}"
	cp "${FILESDIR}/nix.conf" "${D_NIX_CONF}"

	# This would usually be `/nix/var/nix`, but Portage overrides it.
	D_NIX_VAR="${D}/var/lib/nix"
	mkdir -m 0755 -p "${D_NIX_VAR}"

	# <https://nixos.org/nix/manual/#ssec-multi-user>, section "Restricting
	# access"
	D_NIX_DAEMONSOCKET="${D_NIX_VAR}/daemon-socket"
	mkdir -m 0770   "${D_NIX_DAEMONSOCKET}"
	chgrp nix-users "${D_NIX_DAEMONSOCKET}"

	# <https://nixos.org/nix/manual/#ssec-multi-user>, section "Running the
	# daemon"
	D_NIX_SHELLENV="${D}/etc/profile.d/nix.sh"
	echo                            >> "${D_NIX_SHELLENV}"
	echo 'export NIX_REMOTE=daemon' >> "${D_NIX_SHELLENV}"

	newinitd "${FILESDIR}/nix-daemon.openrc-init-script" 'nix-daemon'
}

pkg_postinst() {
	elog 'Nix is being installed in a multi-user configuration.'
	elog '(<https://nixos.org/nix/manual/#ssec-multi-user>)'
	elog
	elog 'Users other than the root user will need to be in the `nix-users`'
	elog 'group to use Nix.'
	elog
	elog 'The Nix daemon will need to be running for Nix commands to work:'
	elog '    # rc-service nix-daemon start'
	elog 'To have it start automatically after boot:'
	elog '    # rc-update add nix-daemon default'
	elog
	elog 'Each user that wants to use Nix should run `nix-channel --update`'
	elog 'first, to set up the `~/.nix-defexpr` directory.'
}
