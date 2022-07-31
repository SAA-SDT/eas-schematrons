# eas-schematrons

## Overview 

This is the official repository for the Schematron files managed by TS-EAS. The Schematron that are managed in this repository specify additional tests that should be performed on documents associated with TS-EAS schemas, such as EAC-CPF 2.0, to ensure consistent encoding practices.

The tests included in the output files of this repository (e.g. eac.sch) should be considered as a required extension of the base schema (e.g. eac.rng). For guidance how how to associate both the Schematron and base schema files, see (link to BPG).

Implementers might also choose to add additional tests, depending on their own local or consortium requirements. For guidance on how to do this, see [https://github.com/SAA-SDT/TS-EAS-subteam-notes/wiki/Schematron].

## Summary of Tests Provided

The TS-EAS Schematron files currently specify the following tests:

- If and only if a language encoding of iso639-1, iso639-2b, iso639-3, or ietf-bcp-47, then every languageOfElement
 and languageCode attribute in the document will be tested against a regular expression pattern that adheres to that specific standard.
  - For example, if either iso639-1 or ietf-bcp-47 is set in the control section, then a value of "fr" will validate because those two characters are found in the regular expression pattern.

- The countryCode attribute will be validated against ISO 3166-1, unless eac:control/@contryEncoding is set to "otherCountryEncoding".

- All scriptCode and scriptOfElement attributes will be validated against ISO 15924, unless eac:control/@scriptEncoding is set to "otherScriptEncoding".

- The text value of the agencyCode element will be validated against a expression value that adheres to the ISO 15511 standard, unless eac:control/@repostioryEncoding is set to "otherRepositoryEncoding". The regular expression requires a prefix, a dash ("-"), and an identifier. 
    - The prefix must either match a country code from ISO 3166-1, or it must include three to four characters, with a mix of cases (e.g. "oclc", "EUR", and "SzB" would all be valid). 
    - The identifier that follows the dash, can be 1 to 11 characters long and include a mix of A-Z characters in either case, numeric characters from 0-9, as well as any of the additional three characters: ":", "/", and "-".

- Every '@id' attribute will be tested in the document to ensure that each id only occurs once. This test is already carried out by the XSD version of the schema, but it is not enforced by the RNG version due to how RNG treats the xsd:ID datatype.

- Every reference-related (e.g. '@sourceReference') and target attribute present will be tested to ensure that the attribute is linked elsewhere in the current file.
    - @conventionDeclarationReference: must be linked to an @id found in a conventionDeclaration element.
    - @localTypeDeclarationReference: must be linked to an @id found in a localTypeDeclaration element.
    - @maintenanceEventReference: must be linked to an @Id found in a maintenanceEvent element.
    - @sourceReference:  must be linked either to an @id found in a source element or a citedRange element.
    - @target: must be linked to an @id found somewhere within the current document.
    
- The maintanceAgency element within the control section must include either a non-empty agencyCode element or a non-empty agencyName element. It can also have both, but it needs one of the two at a minimum.

- The eventDateTime element must include either a @standardDateTime attribute or text.

- Any use of the @era attribute should be restricted to either 'ce' or 'bce'. 

- Unless the dateEncoding within the control section is set to "otherDateEncoding", then a sub-profile of dates allowable by ISO 8601:2019, parts 1 and 2 (which included EDTF dates), will be enforced. The Schematron file includes the following restrictions on the @notAfter, @notBefore, @standardDate attributes:
    1. Valid dates within all three attributes may be composed of the following:
        - a Year
            - which may optionally start with a "+" or "-". 
            - contain no less than 4 characters (e.g. year 100 must be encoded as 0100), and no more than 10 characters.
            - contains numeric characters, or an X to indicate an unknown value, according to the new EDTF features provided in ISO 8601:2019. e.g. "192X" is valid.
        - a Year, a hyphen separtor (intended to not be optional in our subprofile of ISO 8601), and a Season, which must have a value of 21 to 41, according to ISO 8601:2019
        - a Year, a hyphen separator, and a Month, which must include a value from 01 (for January) to 12 (for December). Unknown values can optionally be indicated with an "X".
        - a Year, a hyphen separator, a Month, a hyphen seprator, and a Day, which must be include two characters in the range of 01 to 31, with an optional X to indicate an unknown value. February-specifc and valid leap days are not currently tested.
        - a Year, a hyphen seprator, a Month, a hyphen seprator, a Day, and a Time, which can either start with a "T" or a " ".
        - a qualifier that precedes or follows any of those parts. The valid qualifiers are "?" (i.e. uncertain), "~" (i.e. approximate), and "%" (i.e. uncertain and approximate). 
    1. @notAfter and @notBefore must not contain any date ranges, which may be specified with ".." and "/". If date ranges are required, then those should only be encoded within a @standardDate attribute that is present on a date element (not a fromDate or toDate element). 
    1. Further, though date ranges may start and end with "..", they should not start or end with a "/".
    1. Last, regarding date ranges, only one range can be specified in our profile. In other words: 1800/1820 is valid, but 1800/1820..1830 would not be. Similarly, a single attribute that encodes a date set and range (e.g. 1800,1802,1807,1810..1820) would also not be valid. For that case, the dateSet element should be utlized instead.


## GitHub Repository Structure

Currently, this repository includes a few files in the root, such as a data license and this README.  Additionally, there are four different directories:
- build
    - This directory currently contains both a shell script and Windows command file that can be utilized to regenerate a copy of the Schematron file, which will be posted in the "schematron" directory. To do that, either scripts will call the XSLT transformation in the "build/transformations" directory, which in turn will take the files in the "src" directory and use those to generate the Schematron file. One reason for this extra step is that the automated process makes it easier, for example, to update the regular expression pattern used in our validation of IETF BCP 47 Language codes.
- schematron
    - This directory contains the final deliverable of the Schematron file, which is currently delivered in a single file (i.e. a single file for each base TS-EAS schema, since those currently have separate namespaces). 
- src
    - This directory contains the source file, which the build directory utilzes to create the output in the schematron directory. Therefore, if any additional tests are added, then those tests will be added in this directory.
- vendor
    - For the time being we are including the necessary XSLT processor to generate the resulting schema file directly in this GitHub repository. Until we have an automated build process baked in, this makes things easier to share the current build process. As it stands now, the only requirement is having a working installation of JAVA on your computer.



