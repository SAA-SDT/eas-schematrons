#!/bin/bash

set -eo pipefail

# needs to be run from within the build directory for now (and still needs to be updated with an EAD build example)
# and we should replace these scripts with GitHub actions eventually.

saxon="../vendor/SaxonHE10-1J/saxon-he-10.1.jar"

echo "Getting started."

java -cp $saxon net.sf.saxon.Transform -t -xsl:transformations/prep-source-schematron-files.xsl -it schema='eac'
java -cp $saxon net.sf.saxon.Transform -t -xsl:transformations/prep-source-schematron-files.xsl -it schema='ead'

echo "All done."