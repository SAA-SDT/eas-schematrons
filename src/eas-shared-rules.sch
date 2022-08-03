<?xml version="1.0" encoding="UTF-8"?>
<sch:schema xmlns:sch="http://purl.oclc.org/dsdl/schematron" queryBinding="xslt2"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:sqf="http://www.schematron-quickfix.com/validator/process">
    
    <sch:ns uri="https://archivists.org/ns/eac/v2" prefix="eac"/>
    <sch:ns uri="http://ead3.archivists.org/schema/" prefix="ead"/>
    
    <sch:let name="languageEncoding-of-document" value="(*/*:control/@languageEncoding)"/>
      
    <!-- until we have a better way with dealing with "other" as a value, etc.-->
    <sch:let name="check-language-codes" value="if ($languageEncoding-of-document = ('iso639-1', 'iso639-2b', 'iso639-3')) then true() else false()"/>
    <sch:let name="check-ietf-codes" value="if ($languageEncoding-of-document eq 'ietf-bcp-47') then true() else false()"/>
    <sch:let name="check-country-codes" value="if (*/*:control/@countryEncoding eq 'otherCountryEncoding') then false() else true()"/>
    <sch:let name="check-script-codes" value="if (*/*:control/@scriptEncoding eq 'otherScriptEncoding') then false() else true()"/>
    <sch:let name="check-repository-codes" value="if (*/*:control/@repositoryEncoding eq 'otherRepositoryEncoding') then false() else true()"/>
    <sch:let name="check-date-attributes" value="if (*/*:control/@dateEncoding eq 'otherDateEncoding') then false() else true()"/>
    
    <!-- LANGUAGE CODE TESTS (in process) -->
    <sch:pattern>
        
        <sch:rule context="*[@languageCode | @languageOfElement][$languageEncoding-of-document eq 'iso639-1']">
            <!-- for every @lang or @langcode attribute, test that it is equal to a value in the relevant language code list -->
            <sch:assert test="every $l in (@languageCode | @languageOfElement) satisfies matches($l, $iso639-1-regex)">The <sch:name/> element's languageOfElement or languageCode attribute should contain a value from the <xsl:value-of select="$languageEncoding-of-document"/> code list.</sch:assert>
        </sch:rule>
        
        <sch:rule context="*[@languageCode | @languageOfElement][$languageEncoding-of-document eq 'iso639-2b']">
            <!-- for every @lang or @langcode attribute, test that it is equal to a value in the relevant language code list -->
            <sch:assert test="every $l in (@languageCode | @languageOfElement) satisfies matches($l, $iso639-2b-regex)">The <sch:name/> element's languageOfElement or languageCode attribute should contain a value from the <xsl:value-of select="$languageEncoding-of-document"/> code list.</sch:assert>
        </sch:rule>
        
        <sch:rule context="*[@languageCode | @languageOfElement][$languageEncoding-of-document eq 'iso639-3']">
            <!-- for every @lang or @langcode attribute, test that it is equal to a value in the relevant language code list -->
            <sch:assert test="every $l in (@languageCode | @languageOfElement) satisfies matches($l, $iso639-3-regex)">The <sch:name/> element's languageOfElement or languageCode attribute should contain a value from the <xsl:value-of select="$languageEncoding-of-document"/> code list.</sch:assert>
        </sch:rule>
        
        <sch:rule context="*[@languageCode | @languageOfElement][$languageEncoding-of-document eq 'ietf-bcp-47']">
            <!-- for every @lang or @langcode attribute, test that it is equal to a value in the relevant language code list -->
            <sch:assert test="every $l in (@languageCode | @languageOfElement) satisfies matches($l, $ietf-regex)">The <sch:name/> element's languageOfElement or languageCode attribute should contain a value from the 'ietf-bcp-47' code list.</sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- COUNTRY CODES -->
    <sch:pattern>
        <sch:rule context="*[@countryCode][$check-country-codes]">
            <sch:assert test="matches(@countryCode, $iso3166-regex)">The countryCode attribute should contain a code from the ISO 3166-1 code list.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- SCRIPT CODES -->
    <sch:pattern>
        <sch:rule context="*[@scriptCode | @scriptOfElement][$check-script-codes]">
            <sch:assert test="every $s in (@scriptCode | @scriptOfElement) satisfies matches($s, $iso15924-regex)">The scriptOfElement or scriptCode attribute should contain a code from the ISO 15924 code list.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- REPOSITORY CODES (also need a test for agency codes and ISIL?) -->
    <sch:pattern>
        <sch:rule context="*:agencyCode[$check-repository-codes]">
            <sch:assert test="matches(normalize-space(.), $iso15511-regex)">If the repositoryEncoding is set to ISO 15511, then the format of the value of the <sch:emph>agencyCode</sch:emph> element is constrained to that of the International Standard Identifier for Libraries and Related Organizations (ISIL: ISO 15511): a prefix, a hyphen, and an identifier.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    
    <!-- ID UNIQUENESS / IDREF CONSTRAINTS, for RNG -->
    <sch:pattern>
        <sch:rule context="*[@id]">
            <sch:assert test="count(//*/@id[. = current()/@id]) = 1">This element does not have a unique value for its 'id' attribute.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- REFERENCE + TARGET ATTRIBUTE TESTS -->
    <sch:pattern>
        <sch:rule context="*[@conventionDeclarationReference]">
            <sch:assert test="every $ref in tokenize(@conventionDeclarationReference, ' ') satisfies $ref = (/*/*:control[1]/*:conventionDeclaration/@id)">
                When you use the conventionDeclarationReference attribute, it must be linked to a conventionDeclaration element.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@localTypeDeclarationReference]">
            <sch:assert test="every $ref in tokenize(@localTypeDeclarationReference, ' ') satisfies $ref = (/*/*:control[1]/*:localTypeDeclaration/@id)">
                When you use the localTypeDeclarationReference attribute, it must be linked to a localTypeDeclaration element.
            </sch:assert>
        </sch:rule>  
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@maintenanceEventReference]">
            <sch:assert test="every $ref in tokenize(@maintenanceEventReference, ' ') satisfies $ref = (/*/*:control[1]/*:maintenanceHistory[1]/*:maintenanceEvent/@id)">
                When you use the maintenanceEventReference attribute, it must be linked to a maintenanceEvent element.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@sourceReference]">
            <sch:assert test="every $ref in tokenize(@sourceReference, ' ') satisfies $ref = (/*/*:control[1]/*:sources[1]/*:source/@id, /*/*:control[1]/*:sources[1]/*:source/*:citedRange/@id)">
                When you use the sourceReference attribute, it must be linked to a source or citedRange element.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern>
        <sch:rule context="*[@target]">
            <sch:assert test="every $target in tokenize(@target, ' ') satisfies $target = (//*/@id)">
                When you use the target attribute, it must be linked to another element by means of the id attribute.
            </sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- CO-OCCURENCE CONSTRAINTS -->
    <sch:pattern id="maintenanceAgency-constraints">
        <sch:rule context="*:maintenanceAgency[*:agencyCode[not(normalize-space())]] | *:maintenanceAgency[not(*:agencyCode)]">
            <sch:assert test="*:agencyName[normalize-space()]">The maintenanceAgency element requires either an agencyCode or agencyName element that cannot be empty.</sch:assert>
        </sch:rule>
        <sch:rule context="*:maintenanceAgency[*:agencyName[not(normalize-space())]] | *:maintenanceAgency[not(*:agencyName)]">
            <sch:assert test="*:agencyCode[normalize-space()]">The maintenanceAgency element requires either an agencyCode or agencyName element that cannot be empty.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <sch:pattern id="eventDateTime">
        <sch:rule context="/*/*:control/*:maintenanceHistory/*:maintenanceEvent/*:eventDateTime[not(@standardDateTime)]">
            <sch:assert test="normalize-space()">The eventDateTime element requires either a standardDateTime attribute or text.</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    <!-- DATES -->
    <sch:pattern>
        <sch:rule context="*:date[@era] | *:toDate[@era] | *:fromDate[@era]">
            <sch:assert test="@era = ('ce', 'bce')">Suggested values for the era attribute are 'ce' or 'bce'</sch:assert>
        </sch:rule>
    </sch:pattern>
    
    
    
    
    <!-- DATE NORMALIZATION -->
    <!-- 
        ISO 8601:2019 possiblities are quite different...
        
        also, we will need to be clear that we don't support all values of iso 8601.  
        
        for instance, we do not currently provide support support decade, week, dayo, dayk, 
        date sets, etc.
        
        [T]([01][1-9]|[2][0-3])[:]([0-5][0-9])[:]([0-5][0-9])([+|-]([01][0-9]|[2][0-3])[:]([0-5][0-9])){0,1}
        
        ranges:
            ..
            /
            
            e.g. 
             /1899 is valid.
             as is ..1899
             as is 1899..2999
             as is 1899/2999
             
             what about?
                1899..0009    
                1899/0009
             
          
         date
            @notBefore | @notAfter | @standardDate
         
         fromDate
            @notBefore | @notAfter | @standardDate
         toDate
            @notBefore | @notAfter | @standardDate
            
         only date/@standardDate should permit ranges, right? right.
         
        -->
    
    <!-- should switch to a grammar based approach for dates, eventually...
         definitely.
        -->
            
    <sch:pattern id="dates">
        <sch:let name="qualifier" value="'[~%?]?'"/>   
        <sch:let name="months" value="1 to 12"/>
        <sch:let name="seasons" value="21 to 41"/>
        <!-- 
        this keeps Y limited to 10 digits since the saxon parser for xs:gYear does the same.
        but it also allows Y to start with '+', even though that is not permitted by Saxon...
        but it is by ISO:8601:2019...right? 
        -->
        <sch:let name="Y" value="'[+-]?(([0-9X])([0-9X]{3})|([1-9X])([0-9X]{4,9}))'"/>   
        <sch:let name="M" value="'(' || (string-join(for $x in ($months) return format-number($x, '00'), '|')) || '|([0-1]X)|' || 'X[0-9])'"/>
        <sch:let name="M_S" value="'(' || (string-join(for $x in ($months, $seasons) return format-number($x, '00'), '|')) || '|([0-1]X)|' || 'X[0-9])'"/>
        <sch:let name="D" value="'(([0X][1-9X])|([012X][0-9X])|([3X][0-1X]))'"/>
        <sch:let name="T" value="'[T| ](0[0-9]|1[0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9]|60)(?:Z|[+-](?:2[0-3]|[01][0-9]):[0-5][0-9])$'"/>
        
        <sch:let name="iso8601-regex" value="concat('^', $qualifier, $Y, $qualifier, '$','|', '^', $qualifier, $Y, $qualifier, '-', $qualifier, $M_S, $qualifier, '$', '|', '^', $qualifier, $Y, $qualifier, '-', $qualifier, $M, $qualifier, '-', $qualifier, $D, $qualifier, '$', '|', '^', $qualifier, $Y, $qualifier, '-', $qualifier, $M, $qualifier, '-', $qualifier, $D, $qualifier, $T, '$')"/>
        
        <sch:rule context="*:date[$check-date-attributes][exists(@notBefore | @notAfter | @standardDate[not(matches(., '\.\.|/'))])] | *:toDate[$check-date-attributes][exists(@notBefore | @notAfter | @standardDate)] | *:fromDate[$check-date-attributes][exists(@notBefore | @notAfter | @standardDate)]">
            <sch:assert test="every $d in (@notBefore, @notAfter, @standardDate) satisfies matches($d, $iso8601-regex)">The <sch:emph>notBefore</sch:emph>, <sch:emph>notAfter</sch:emph>, and <sch:emph>standardDate</sch:emph> attributes of <sch:name/> must match the TS-EAS subprofile of valid ISO 8601 dates.</sch:assert>
        </sch:rule>
        
        <!-- and for date ranges -->
        <sch:rule context="*:date[$check-date-attributes][@standardDate[matches(., '\.\.|/')]]">
            <sch:assert test="every $d in (tokenize(@standardDate, '(\.\.)|(/)')[normalize-space()]) satisfies matches($d, $iso8601-regex)">All <sch:emph>standardDate</sch:emph> attributes in a valid date range must match the TS-EAS subprofile of valid ISO 8601 dates.</sch:assert>
            <sch:report test="count(tokenize(@standardDate, '(\.\.)|(/)'))>=3">This date expression has too many range operators. Only a single "/" or ".." is permitted.</sch:report>
            <sch:report test="matches(normalize-space(@standardDate), '^/|/$')">The date expression should not start or end with a "/" character.</sch:report>
        </sch:rule>
       
    </sch:pattern>
    
    <!-- combine all three into a function, but for now, let's get this to work -->
    <sch:pattern id="notAfter-leap-year-tests">
        <!-- notAfter -->
        <sch:rule context="*[$check-date-attributes][matches(replace(@notAfter, '[%~?]', ''), '-02-')]">
            <sch:let name="year-string" value="substring-before(@notAfter, '-') => replace('[+%~?]', '')"/>
            <sch:let name="year" value="if ($year-string castable as xs:gYear) then xs:integer($year-string) else false()"/>
            <sch:let name="leap-year" value="if ($year) then (($year mod 4 = 0 and
                $year mod 100 != 0) or
                $year mod 400 = 0) else false()"/>
            <sch:report test="matches(replace(@notAfter, '[%~?]', ''), '-02-30|-02-31')">February dates cannot have a day value of 30 or 31. Check the value of "notAfter" attribute.</sch:report>
            <sch:report test="$year and not($leap-year) and matches(replace(@notAfter, '[%~?]', ''), '-02-29')">February 29th may only be encoded for leap years. The year encoded in the "notAfter" attribute, <xsl:value-of select="$year-string"/>, however, is not a valid leap year.</sch:report>
        </sch:rule>   
    </sch:pattern>
    <sch:pattern id="notBefore-leap-year-tests">
        <!-- notBefore -->
        <sch:rule context="*[$check-date-attributes][matches(replace(@notBefore, '[%~?]', ''), '-02-')]">
            <sch:let name="year-string" value="substring-before(@notBefore, '-') => replace('[+%~?]', '')"/>
            <sch:let name="year" value="if ($year-string castable as xs:gYear) then xs:integer($year-string) else false()"/>
            <sch:let name="leap-year" value="if ($year) then (($year mod 4 = 0 and
                $year mod 100 != 0) or
                $year mod 400 = 0) else false()"/>
            <sch:report test="matches(replace(@notBefore, '[%~?]', ''), '-02-30|-02-31')">February dates cannot have a day value of 30 or 31. Check the value of "notBefore" attribute.</sch:report>
            <sch:report test="$year and not($leap-year) and matches(replace(@notBefore, '[%~?]', ''), '-02-29')">February 29th may only be encoded for leap years. The year encoded in the "notBefore" attribute, <xsl:value-of select="$year-string"/>, however, is not a valid leap year.</sch:report>
        </sch:rule>
    </sch:pattern>
    <sch:pattern id="standardDate-leap-year-tests">
        <!-- standardDate (but no attempt, currently, to tokenize) -->
        <sch:rule context="*[$check-date-attributes][matches(replace(@standardDate, '[%~?]', ''), '-02-')]">
            <sch:let name="year-string" value="substring-before(@standardDate, '-') => replace('[+%~?]', '')"/>
            <sch:let name="year" value="if ($year-string castable as xs:gYear) then xs:integer($year-string) else false()"/>
            <sch:let name="leap-year" value="if ($year) then (($year mod 4 = 0 and
                $year mod 100 != 0) or
                $year mod 400 = 0) else false()"/>
            <sch:report test="matches(replace(@standardDate, '[%~?]', ''), '-02-30|-02-31')">February dates cannot have a day value of 30 or 31. Check the value of the "standardDate" attribute.</sch:report>
            <sch:report test="$year and not($leap-year) and matches(replace(@standardDate, '[%~?]', ''), '-02-29')">February 29th may only be encoded for leap years. The year encoded in the "standardDate" attribute, <xsl:value-of select="$year-string"/>, however, is not a valid leap year.</sch:report>
        </sch:rule>
    </sch:pattern>


    <sch:pattern id="simple-date-range-comparisons">
        <sch:rule context="*:date[$check-date-attributes][matches(@standardDate, '[0-9]/[0-9]')]">
            <sch:let name="begin_date" value="substring-before(@standardDate, '/')"/>
            <sch:let name="end_date" value="substring-after(@standardDate, '/')"/>
            <sch:let name="testable_dates" value="every $d in ($begin_date, $end_date) satisfies ($d castable as xs:date or $d castable as xs:dateTime or $d castable as xs:gYear or $d castable as xs:gYearMonth)"/>  
            <sch:assert test="if ($testable_dates) then $end_date gt $begin_date else true()">
                The standardDate attribute value for this field needs to be updated. The first date, <xsl:value-of select="$begin_date"/>, is encoded as occurring <sch:emph>before</sch:emph> the end date, <xsl:value-of select="$end_date"/>
            </sch:assert>
        </sch:rule>
        <sch:rule context="*:date[$check-date-attributes][matches(@standardDate, '[0-9]\.\.[0-9]')]">
            <sch:let name="begin_date" value="substring-before(@standardDate, '..')"/>
            <sch:let name="end_date" value="substring-after(@standardDate, '..')"/>         
            <sch:let name="testable_dates" value="every $d in ($begin_date, $end_date) satisfies ($d castable as xs:date or $d castable as xs:dateTime or$d castable as xs:gYear or $d castable as xs:gYearMonth)"/>
            <sch:assert test="if ($testable_dates) then $end_date gt $begin_date else true()">
                The standardDate attribute value for this field needs to be updated. The first date, <xsl:value-of select="$begin_date"/>, is encoded as occurring <sch:emph>before</sch:emph> the end date, <xsl:value-of select="$end_date"/>
            </sch:assert>
        </sch:rule>
    </sch:pattern>

    <!-- REGEX patterns -->
    <sch:let name="iso15511-regex" xml:id="iso15511"/>
    <sch:let name="ietf-regex" xml:id="ietf"/>
    <sch:let name="iso639-1-regex" xml:id="iso639-1"/>
    <sch:let name="iso639-2b-regex" xml:id="iso639-2b"/>
    <sch:let name="iso639-3-regex" xml:id="iso639-3"/>
    <sch:let name="iso3166-regex" xml:id="iso3166"/>
    <sch:let name="iso15924-regex" xml:id="iso15924"/>
    
</sch:schema>
