from setuptools import setup

setup(name='read_zrsc2019',
      version='0.1',
      description='Read and verify embedding files for ZeroSpeech2019',
      url='https://gitlab.coml.lscp.ens.fr/zerospeech2019/read_zrsc2019',
      author='Lucie',
      author_email='lucie.miskic@laposte.net',
      license='MIT',
      packages=['read_zrsc2019'],
      scripts=['bin/validate'],
      zip_safe=False)
