#!/usr/bin/env python
"""Scan files for certain words."""

import logging

import requests

import time
import datetime


logger = logging.getLogger(f"filescanner")
session = requests.Session()

FILES_TO_SEARCH = [
    "https://ce-codechallenge.s3.eu-west-2.amazonaws.com/1.txt",
    "https://ce-codechallenge.s3.eu-west-2.amazonaws.com/2.txt",
]

WORDS_TO_FIND = ["wind", "solar"]


def search_file_for_words(file_to_search):
    """Search the contents of files for key words."""
    resp = session.get(file_to_search)
    resp.raise_for_status()
    file_contents = resp.text
    for word in WORDS_TO_FIND:
        if word in file_contents:
            logger.info(f'Found "{word}"')


def main():
    """Main function."""
    for file_url in FILES_TO_SEARCH:
        logger.info(f"Scanning {file_url}")
        search_file_for_words(file_url)


if __name__ == "__main__":
    logging.basicConfig(
        level=logging.INFO, format="[%(levelname)8s] %(name)s: %(message)s"
    )
    main()
    # while True:
    #     main()
    #     time.sleep(60*60)

   

