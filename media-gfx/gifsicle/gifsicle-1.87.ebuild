# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit autotools

DESCRIPTION="A command-line tool for creating, editing, and getting information about GIF images and animations"
HOMEPAGE="https://github.com/kohler/gifsicle"

# Use a different name for the tarball than "${P}.tar.gz" to force it to be
# downloaded from GitHub rather than from the Gentoo mirrors.
SRC_URI="https://github.com/kohler/${PN}/archive/v${PV}.tar.gz ->
	${P}-8573.tar.gz"

LICENSE="GPL-2 MIT"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~ppc ~ppc64 ~sparc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos"
IUSE="X"

RDEPEND="X? ( x11-libs/libX11 x11-libs/libXt )"
DEPEND="${RDEPEND}
	X? ( x11-proto/xproto )"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf \
		$(use_enable X gifview)
}
