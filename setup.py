from distutils.core import Extension, setup
from Cython.Build import cythonize
import numpy

# define an extension that will be cythonized and compiled
ext = Extension(name="clobber_1d_cy", sources=["clobber_1d_cy.pyx" ], include_dirs=[numpy.get_include()], language='c++')
ext_2 = Extension(name="boolean_negamax_tt_cy", sources=["boolean_negamax_tt_cy.pyx"], include_dirs=[numpy.get_include()], language='c++')
ext_3 = Extension(name="transposition_table_simple_cy", sources=["transposition_table_simple_cy.pyx"], include_dirs=[numpy.get_include()], language='c++')


setup(ext_modules=cythonize(ext))
setup(ext_modules=cythonize(ext_2))
setup(ext_modules=cythonize(ext_3))