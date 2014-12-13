# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
# $Header: $
EAPI="5"

# [2014-12-13 07:41Z] <c74d> I'm copying this ebuild from the `chromiumos`
# package repository,
# <https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay>,
# at commit `ed59fa7abce39764180679f3d8427f9626fdd69a` of that Git repository.
#
# I tried using the `chromiumos` repository itself, via Layman, but that
# resulted in error spam from Portage.

inherit font

DESCRIPTION="Noto fonts developed by Monotype"
# [2014-12-13 07:47Z] <c74d> I'm also changing this URI's scheme from `http`
# to `https`.
SRC_URI="https://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.bz2"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""

FONT_SUFFIX="ttc ttf"
FONT_S="${S}"
FONTDIR="/usr/share/fonts/noto"


# Only installs fonts
RESTRICT="strip binchecks"

src_install() {
        # call src_install() in font.eclass.
	font_src_install
}
