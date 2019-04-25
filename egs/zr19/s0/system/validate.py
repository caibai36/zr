#!/usr/bin/env python
"""Checks if a submission to the ZeroSpeech 2019 challenge is valid"""

import argparse
import atexit
import os
import logging
import shutil
import sys
import tempfile
import traceback
import zipfile

import read_zrsc2019
import yaml


# setup logging
logging.basicConfig(
    format='%(asctime)s - %(levelname)s - %(message)s',
    level=logging.DEBUG)
log = logging.getLogger()


class Validation(object):
    def __init__(self, language):
        # make sure the language is valid
        if language not in ['english', 'surprise']:
            raise ValueError(
                'language must be "english" or "surprise", it is "{}"'
                .format(language))
        self.language = language

        # get the files needed for the validation
        self.required_list = self._get_file('required')
        self.bitrate_list = self._get_file('bitrate')
        self.embedding_list = self._get_file('embedding')

        # the list of error must remains empty for the submission to
        # be validated
        self.errors = []

        # may be used for unzipping the submission
        self.tmpdir = None

    def _get_file(self, name):
        filename = os.path.join(
            os.environ['HOME'], 'system', 'info_test',
            self.language, '{}_filelist.txt'.format(name))
        assert os.path.isfile(filename), filename
        return filename

    def _check_exists(self, directory, files_list):
        root_dir = os.path.basename(directory)
        existing_files = set(os.listdir(directory))
        expected_files = set(
            os.path.basename(f.strip().split(' ')[0])
            for f in open(files_list, 'r'))

        missing_files = expected_files - existing_files
        for f in missing_files:
            self.errors.append(
                'Missing file {}/{}/{}'.format(self.language, root_dir, f))

    def _check_embedding(self, directory, files_list):
        read_zrsc2019.read_all(files_list, directory, False, log=log)

    def _validate_directory(self, directory, exist_list, embedding_list):
        log.info(
            'Validating "%s/%s" directory...',
            self.language, os.path.basename(directory))
        self._check_exists(directory, exist_list)
        self._check_embedding(directory, embedding_list)

    def validate(self, submission):
        """Returns True is the `submission` is valid, False otherwise

        The `submission` can be a zip archive (in that case it will be
        uncompressed in a temporary directory) or a directory

        """
        self.errors = []

        # the submissions directories to validate
        test_dir = os.path.join(
            submission, self.language, 'test')
        aux1_dir = os.path.join(
            submission, self.language, 'auxiliary_embedding1')
        aux2_dir = os.path.join(
            submission, self.language, 'auxiliary_embedding2')

        # If aux2_dir is here, make sure aux1_dir is here as well
        if os.path.isdir(aux2_dir) and not os.path.isdir(aux1_dir):
            self.errors.append(
                'Found auxiliary_embedding2 but not auxiliary_embedding1')
            return False

        # validate the test_dir with final embeddings
        self._validate_directory(
            test_dir, self.required_list, self.embedding_list)

        # validate aux1_dir and aux2_dir if they are here
        for directory in (aux1_dir, aux2_dir):
            if os.path.isdir(directory):
                self._validate_directory(
                    directory, self.embedding_list, self.bitrate_list)

        # Fails if we fount any error during validation
        if self.errors:
            log.error(
                'Found %s validation errors for %s',
                len(self.errors), self.language)
            return False

        return True


def validate_metadata(filename, do_aux1=False, do_aux2=False):
    """Checks if the `metadata` file of a submission is valid"""
    # load the metadata YAML
    if not os.path.isfile(filename):
        log.error('Metadata file not found: %s', filename)
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
    text_keys = ['author', 'affiliation', 'system description', 'abx distance']
    if do_aux1:
        text_keys += ['auxiliary1 description']
    if do_aux2:
        text_keys += ['auxiliary2 description']
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
        # check abx distance
        distances = ['dtw_cosine', 'dtw_kl', 'levenshtein']
        assert metadata['abx distance'] in distances, \
            '"abx distance" must be in {}, it is {}'.format(
                distances, metadata['abx distance'])

        # check mandatory text keys are here non empty strings
        for key in text_keys:
            if not metadata[key]:
                log.error('metadata entry "{}" is empty'.format(key))
                return False
            else:
                assert isinstance(metadata[key], str), \
                    '"{}" must be a string'.format(key)

        # check boolean keys are booleans
        for key in bool_keys:
            assert isinstance(metadata[key], bool), \
                '"{}" must be a boolean'.format(key)
    except AssertionError as err:
        log.error(
            'Invalid metadata: %s', str(err))
        return False

    return metadata


def detect_auxiliary(submission, languages, name):
    aux_dirs = [os.path.isdir(os.path.join(
        submission, l, name)) for l in languages]
    if aux_dirs == [True] * len(languages):
        return True
    elif aux_dirs == [False] * len(languages):
        return False
    else:
        raise ValueError(
            '{} is present for one language but '
            'not for the other'.format(name))


def validate(submission, language):
    """Returns metadata if the submission is valid, False otherwise"""
    # unzip the subnmission if this is a zip archive
    if zipfile.is_zipfile(submission):
        # create a temp directory and delete it at exit
        tmpdir = tempfile.mkdtemp()
        atexit.register(lambda: shutil.rmtree(tmpdir))

        # unzip the submission into this temp directory
        log.info('Unzip submission to %s', tmpdir)
        zipfile.ZipFile(submission, 'r').extractall(tmpdir)
        submission = tmpdir

    # prepare the languages to validate
    if language == 'both':
        languages = ['english', 'surprise']
    elif language == 'english':
        languages = ['english']
    else:
        languages = ['surprise']
    log.info('Validating submission for %s', ', '.join(languages))

    # detect if we have auxiliary 1 and 2 embeddings (because in this
    # case we must check they are described in metadata)
    try:
        do_aux1 = detect_auxiliary(
            submission, languages, 'auxiliary_embedding1')
        do_aux2 = detect_auxiliary(
            submission, languages, 'auxiliary_embedding2')
    except ValueError as err:
        log.error(str(err))
        return False

    # check the metadata file
    metadata = validate_metadata(
        os.path.join(submission, 'metadata.yaml'),
        do_aux1=do_aux1, do_aux2=do_aux2)

    if metadata:
        log.info('Metadata validated')
    else:
        log.error('Submission invalid')
        return False

    # check for a non-empty 'code' folder
    if metadata['open source'] is True:
        code_dir = os.path.join(submission, 'code')
        if os.path.isdir(code_dir) and os.listdir(code_dir):
            log.info('Found a non-empty "code" directory, it will be manually '
                     'inspected to confirm the submission is open source')
        else:
            log.error('Metadata pretend the submission to be open source '
                      'but no code provided!')
            return False
    else:
        log.warning(
            'Code not found! You are strongly encouraged to submit '
            'your code as open source')

    # validate the submission
    errors = []
    for language in languages:
        val = Validation(language)
        val.validate(submission)
        errors += val.errors

    # display errors if any is fount
    if errors:
        log.error('Validation errors detected:')
        for error in errors:
            log.error('    %s', error)
        log.error(
            'Invalid submission, found %s errors (see above)', len(errors))
        return False
    else:
        log.info('Submission validated!')
        return metadata


def main():
    # parse command line options
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawTextHelpFormatter,
        description=__doc__,
        epilog='See https://zerospeech.com/2019 for complete documentation')
    parser.add_argument(
        'submission',
        help='path to submission (can be a directory or a zip archive)')
    parser.add_argument(
        'language', choices={'english', 'surprise', 'both'},
        help='language to validate the submission on '
        '(if you trained with english_small, choose english here)')
    args = parser.parse_args()

    if validate(args.submission, args.language):
        sys.exit(0)
    else:
        sys.exit(1)


if __name__ == '__main__':
    main()
