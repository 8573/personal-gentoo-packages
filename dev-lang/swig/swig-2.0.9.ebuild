# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/swig/swig-2.0.9.ebuild,v 1.13 2014/04/06 14:59:01 vapier Exp $

EAPI=5

inherit autotools

DESCRIPTION="Simplified Wrapper and Interface Generator"
HOMEPAGE="https://github.com/swig/swig"
SRC_URI="https://github.com/${PN}/${PN}/archive/rel-${PV}.tar.gz
	-> ${P}-8573.tar.gz"

LICENSE="GPL-3+ BSD BSD-2"
SLOT="0"
KEYWORDS="alpha amd64 arm arm64 hppa ia64 ~mips ppc ppc64 s390 sh sparc x86 ~ppc-aix ~amd64-fbsd ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ccache doc pcre"
RESTRICT="test"

DEPEND="pcre? ( dev-libs/libpcre )
	ccache? ( sys-libs/zlib )"
RDEPEND="${DEPEND}"

S="${WORKDIR}/${PN}-rel-${PV}"

DOCS=( ANNOUNCE CHANGES CHANGES.current README TODO )

src_prepare() {
	mv configure.{in,ac}
	mv CCache/configure.{in,ac}

	# `./autogen.sh`, but with `e*` functions.
	mkdir -p Tools/config
	eaclocal -I Tools/config
	eautoheader
	eautomake --add-missing --copy --force-missing
	eautoconf
	(cd CCache && eautoreconf)
}

src_configure() {
	econf \
		$(use_enable ccache) \
		$(use_with pcre)
}

src_install() {
	default

	if use doc ; then
		dohtml -r Doc/{Devel,Manual}
	fi
}
