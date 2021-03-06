# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-lang/swig/swig-1.3.40-r2.ebuild,v 1.13 2013/07/02 07:42:01 ago Exp $

EAPI="5"

inherit autotools

DESCRIPTION="Simplified Wrapper and Interface Generator"
HOMEPAGE="https://github.com/swig/swig"
SRC_URI="https://github.com/${PN}/${PN}/archive/rel-${PV}.tar.gz
	-> ${P}-8573.tar.gz"

LICENSE="BSD BSD-2"
SLOT="1"
KEYWORDS="alpha amd64 arm hppa ia64 ppc ppc64 s390 sh sparc x86 ~ppc-aix ~x86-fbsd ~ia64-hpux ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"
IUSE="ccache doc"
RESTRICT="test"
DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PN}-rel-${PV}"

src_prepare () {
	mv configure.{in,ac}
	mv CCache/configure.{in,ac}

	# `./autogen.sh`, but with `e*` functions.
	mkdir -p Tools/config
	eaclocal -I Tools/config
	eautoheader
	eautomake --add-missing --copy --force-missing
	eautoconf
	(cd CCache && eautoreconf)

	# Use swig1.3 as binary instead of swig
	sed -i -e 's:TARGET_NOEXE= swig:TARGET_NOEXE= swig1.3:' Makefile.in
	sed -i -e 's:/swig@EXEEXT@:/swig1.3@EXEEXT@:g' Source/Makefile.{am,in}
	sed -i -e "s:PACKAGE_NAME='ccache-swig':PACKAGE_NAME='ccache-swig1.3':" CCache/configure
	mv CCache/ccache-swig.1 CCache/ccache-swig1.3.1
}

src_configure () {
	econf \
		$(use_enable ccache)
}

src_install() {
	emake DESTDIR="${D}" install || die "target install failed"
	dodoc ANNOUNCE CHANGES CHANGES.current FUTURE NEW README TODO || die "dodoc failed"
	if use doc; then
		dohtml -r Doc/{Devel,Manual} || die "Failed to install html documentation"
	fi
}
