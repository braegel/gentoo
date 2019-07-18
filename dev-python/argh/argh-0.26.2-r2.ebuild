# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python{2_7,3_5,3_6,3_7} pypy )

inherit distutils-r1

DESCRIPTION="A simple argparse wrapper"
HOMEPAGE="https://pythonhosted.org/argh/"
SRC_URI="mirror://pypi/a/${PN}/${P}.tar.gz"

SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc ~x86"
LICENSE="LGPL-3"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND=""
DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]
	test? (
		dev-python/pytest[${PYTHON_USEDEP}]
		dev-python/iocapture[${PYTHON_USEDEP}]
		$(python_gen_cond_dep 'dev-python/mock[${PYTHON_USEDEP}]' -2)
		${RDEPEND}
	)"

python_test() {
	pytest -vv || die "Tests fail with ${EPYTHON}"
}