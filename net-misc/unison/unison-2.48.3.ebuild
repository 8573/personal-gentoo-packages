# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/unison/unison-2.45.4.ebuild,v 1.2 2013/04/01 10:32:20 heroxbd Exp $

# [2015-01-03 19:30 PST] <c74d> I'm copying unison-2.45.4.ebuild from the
# Portage tree to update it to 2.48.3 (latest upstream stable).

EAPI="5"

inherit eutils versionator

IUSE="gtk doc static debug threads +ocamlopt test"

DESCRIPTION="Two-way cross-platform file synchronizer"
HOMEPAGE="https://www.cis.upenn.edu/~bcpierce/unison/"
LICENSE="GPL-2"
SLOT="$(get_version_component_range 1-2 ${PV})"
KEYWORDS="~amd64 ~arm ~ppc ~x86 ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~sparc-solaris"

# ocaml version so we are sure it has ocamlopt use flag
DEPEND=">=dev-lang/ocaml-3.10.2[ocamlopt?]
	gtk? ( >=dev-ml/lablgtk-2.2 )
	test? ( || ( dev-util/ctags virtual/emacs ) )"

RDEPEND="gtk? ( >=dev-ml/lablgtk-2.2
	|| ( net-misc/x11-ssh-askpass net-misc/ssh-askpass-fullscreen ) )
	!net-misc/unison:0
	app-admin/eselect-unison"

#PDEPEND="gtk? ( media-fonts/font-schumacher-misc )"

SRC_URI="https://www.cis.upenn.edu/~bcpierce/unison/download/releases/${P}/${P}.tar.gz
	doc? ( https://www.cis.upenn.edu/~bcpierce/unison/download/releases/${P}/${P}-manual.pdf
		https://www.cis.upenn.edu/~bcpierce/unison/download/releases/${P}/${P}-manual.html )"

src_compile() {
	local myconf

	if use threads; then
		myconf="$myconf THREADS=true"
	fi

	if use static; then
		myconf="$myconf STATIC=true"
	fi

	if use debug; then
		myconf="$myconf DEBUGGING=true"
	fi

	if use gtk; then
		myconf="$myconf UISTYLE=gtk2"
	else
		myconf="$myconf UISTYLE=text"
	fi

	use ocamlopt || myconf="$myconf NATIVE=false"

	# Discard cflags as it will try to pass them to ocamlc...
	emake $myconf CFLAGS="" buildexecutable
}

src_test() {
	emake selftest
}

src_install () {
	# install manually, since it's just too much
	# work to force the Makefile to do the right thing.
	newbin unison unison-${SLOT}
	dodoc BUGS.txt CONTRIB INSTALL NEWS \
		  README ROADMAP.txt TODO.txt

	if use doc; then
		dohtml "${DISTDIR}/${P}-manual.html"
		dodoc "${DISTDIR}/${P}-manual.pdf"
	fi
	use ocamlopt || export STRIP_MASK="*/bin/*"
}

pkg_postinst() {
	elog "Unison now uses SLOTs, so you can specify servercmd=/usr/bin/unison-${SLOT}"
	elog "in your profile files to access exactly this version over ssh."
	elog "Or you can use 'eselect unison' to set the version."
}