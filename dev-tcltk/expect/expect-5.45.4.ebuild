# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit autotools eutils

MY_P="${PN}${PV}"
DESCRIPTION="tool for automating interactive applications"
HOMEPAGE="https://core.tcl-lang.org/expect/"
SRC_URI="mirror://sourceforge/${PN}/${MY_P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="alpha amd64 ~arm arm64 hppa ia64 ~m68k ~mips ppc ppc64 ~riscv s390 ~sh ~sparc x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~x64-macos ~x86-macos ~m68k-mint ~x64-solaris ~x86-solaris"
IUSE="debug doc threads"

# We need dejagnu for src_test, but dejagnu needs expect
# to compile/run, so we cant add dejagnu to DEPEND :/
DEPEND=">=dev-lang/tcl-8.2:0[threads?]"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}

PATCHES=( "${FILESDIR}"/${P}-examples.patch )

src_prepare() {
	default
	sed -i "s:/usr/local/bin:${EPREFIX}/usr/bin:" expect.man || die

	epatch "${FILESDIR}"/${PN}-5.45-gfbsd.patch
	epatch "${FILESDIR}"/${PN}-5.44.1.15-ldflags.patch
	epatch "${FILESDIR}"/${PN}-5.45-headers.patch #337943
	epatch "${FILESDIR}"/${PN}-5.45-format-security.patch
	sed -i 's:ifdef HAVE_SYS_WAIT_H:ifndef NO_SYS_WAIT_H:' *.c

	# fix install_name on darwin
	[[ ${CHOST} == *-darwin* ]] && \
		epatch "${FILESDIR}"/${P}-darwin-install_name.patch

	mv configure.{in,ac} || die

	eautoconf
}

src_configure() {
	# the 64bit flag is useless ... it only adds 64bit compiler flags
	# (like -m64) which the target toolchain should already handle
	econf \
		--with-tcl="${EPREFIX}/usr/$(get_libdir)" \
		--disable-64bit \
		--enable-shared \
		$(use_enable threads) \
		$(use_enable debug symbols mem)
}

src_test() {
	# we need dejagnu to do tests ... but dejagnu needs
	# expect ... so don't do tests unless we have dejagnu
	type -p runtest || return 0
	emake test
}

expect_make_var() {
	touch pkgIndex.tcl-hand
	printf 'all:;echo $('$1')\ninclude Makefile' | emake --no-print-directory -s -f -
	rm -f pkgIndex.tcl-hand || die
}

src_install() {
	default

	if use doc ; then
		docinto examples
		echo dodoc \
			example/README \
			$(printf 'example/%s ' $(expect_make_var _SCRIPTS)) \
			$(printf 'example/%s.man ' $(expect_make_var _SCRIPTS_MANPAGES))
		dodoc \
			example/README \
			$(printf 'example/%s ' $(expect_make_var _SCRIPTS)) \
			$(printf 'example/%s.man ' $(expect_make_var _SCRIPTS_MANPAGES))
	fi
}
