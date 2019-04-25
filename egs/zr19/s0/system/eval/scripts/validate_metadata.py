#!/usr/bin/env python
"""Checks the 'metadata' file in the submission

The 'metadata' file must be in YAML format and have the following
entries (order does not matter):

  author:
    authors of the submission
  affiliation:
    affiliation of the authors (university or company)
  abx distance:
    the ABX distance used for ranking the test embeddings,
    must be 'dtw_cosine', 'dtw_kl' or 'levenshtein'
  auxiliary1 description:
    description of the auxiliary1 embeddings (if used)
  auxiliary2 description:
    description of the auxiliary1 embeddings (if used)
  open source:
    true or false, if true you must provide a 'code' folder in the
    submission archive with the code source or a pointer to a public
    repository (e.g. on github)
  system description:
    a brief description of your system, eventually pointing to a paper
  using parallel train:
    true or false, set to true if you used the parallel train dataset
  using external data: false
    true or false, set to true if you used an external dataset

"""

import argparse
import os
import logging
import sys
import traceback
import yaml


# setup logging
logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.DEBUG)
log = logging.getLogger()


def validate_metadata(filename, do_aux1=True, do_aux2=True):
    """Checks the `metadata` file of a submission is valid"""
    # load the metadata YAML
    if not os.path.isfile(filename):
        log.error('Metadata file not found')
        return False
    try:
        metadata = yaml.load(open(filename, 'r'))
    except yaml.YAMLError:
        log.error('Metadata validation failed: %s', traceback.format_exc())
        return False

    if not metadata:
        log.error('Metadata file is empty')
        return False

    # the list of entries that must be present in the YAML
    text_keys = [
        'author', 'affiliation', 'system description', 'abx distance',
        'auxiliary1 description', 'auxiliary2 description']
    bool_keys = ['open source', 'using parallel train', 'using external data']
    expected_keys = text_keys + bool_keys

    # make sure all the expected keys are here
    missing_keys = set(expected_keys) - set(metadata.keys())
    if missing_keys:
        log.error(
            'Invalid metadata, following entries are missing: %s',
            ', '.join(sorted(missing_keys)))
        return False

    # make sure we have the expected data type for all entries
    try:
        distances = ['dtw_cosine', 'dtw_kl', 'levenshtein']
        assert metadata['abx distance'] in distances, \
            '"abx distance" must be in {}, it is {}'.format(
                distances, metadata['abx distance'])
        for key in text_keys:
            if not metadata[key]:
                log.warning('metadata {} is empty'.format(key))
            else:
                assert isinstance(metadata[key], str), \
                    '"{}" must be a string'.format(key)
        for key in bool_keys:
            assert isinstance(metadata[key], bool), \
                '"{}" must be a boolean'.format(key)
    except AssertionError as err:
        log.error(
            'Invalid metadata: %s', str(err))
        return False

    return metadata


def main():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        description=__doc__)
    parser.add_argument('metadata', help='the metadata file to be validated')
    args = parser.parse_args()

    metadata = validate_metadata(args.metadata)
    if metadata:
        log.info('Metadata validated')
        sys.exit(0)
    else:
        log.error('Metadata invalid')
        sys.exit(1)


if __name__ == '__main__':
    main()
