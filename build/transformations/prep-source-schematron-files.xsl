<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    xmlns:mdc="http://mdc"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="1"/>
    <xsl:mode on-no-match="shallow-copy"/>
   
    <xsl:param name="schema" select="'eac'"/>
    
    <xsl:variable name="tab" select="'&#x9;'"/>
    <xsl:variable name="newline" select="'&#xA;'"/>
    
    <xsl:variable name="filename" select="$schema || '.sch'" as="xs:string"/>
    <xsl:variable name="source-file" select="document('../../src/eas-shared-rules.sch')" as="document-node()"/>
    
    <xsl:variable name="ietf-bcp-47-file" select="unparsed-text('https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry')"/>
    <xsl:variable name="iso-639-1-file" select="document('https://id.loc.gov/vocabulary/iso639-1.rdf')"/>
    <xsl:variable name="iso-639-2b-file" select="unparsed-text('https://www.loc.gov/standards/iso639-2/ISO-639-2_utf-8.txt')"/>
    <xsl:variable name="iso-639-3-file" select="unparsed-text('https://iso639-3.sil.org/sites/iso639-3/files/downloads/iso-639-3.tab')"/>
    <xsl:variable name="iso-3166-file" select="document('../../src/external-lists/iso-3166.xml')"/>
    <xsl:variable name="iso-15924-file" select="unparsed-text('https://www.unicode.org/iso15924/iso15924.txt')"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>For now, the initial template is called by our external build scripts.</xd:p>
            <xd:p>All that it does is take the "eas-shared-rules.sch" file, update a few regexes from external codes lists -- such as the IETF BCP 47 subtag registry -- and, finally, copy the resulting schematron file to the schematron directory.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="xsl:initial-template">
        <xsl:for-each select="$source-file">
            <xsl:result-document href="../schematron/{$filename}">
                <xsl:copy>
                    <xsl:comment expand-text="true">
<xsl:text>
This schematron file has been generated automatically, and was last updated at: 
{current-dateTime()}
                        
If you would like to contribute to this project, please see: 
https://github.com/SAA-SDT/TS-EAS-subteam-notes/wiki/Contributing-to-the-EAS-standards
                        
Comments, questions, and suggestions may be addressed to: 
ts-eas@archivists.org
</xsl:text>
                    </xsl:comment>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    

    <xd:doc>
        <xd:desc>
            <xd:p>Replace source values of "*" with relevant schema info, e.g. eac (for document element name or namespace prefix)</xd:p>
            <xd:p>This is an admittedly bad approach, so update this later :)</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@value[contains(., '*')]|@context[contains(., '*')]|@test[contains(., '*')]" priority="2">
        <xsl:attribute name="{local-name()}"
            select="replace(., '//\*/', '//' || $schema || ':*/')
            => replace('\*:', $schema || ':')
            => replace('\*\[', $schema || ':*[')
            "/>
    </xsl:template>
    

    <xd:doc>
        <xd:desc>
            <xd:p>Removes comments from source files.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="comment()"/>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Removes unused namespace prefix declarations.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="sch:ns[not(@prefix = $schema)]"/>
    
    <!-- works, for now, but change this approach later.-->
    <xsl:template match="sch:let[@xml:id = ('iso15511', 'iso639-1', 'iso639-2b', 'iso639-3', 'iso3166', 'iso15924')]">
        <xsl:variable name="regex-function-for-current-iso-code" select="'mdc:create-' || @xml:id || '-regex'"/>       
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="value">
                <xsl:text>'</xsl:text>
                <xsl:value-of select="function-lookup(xs:QName($regex-function-for-current-iso-code), 0)()"/>
                <xsl:text>'</xsl:text>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>
    
    <xsl:function name="mdc:get-countryCode-regex" as="xs:string">
        <xsl:variable name="values" as="item()*">
            <xsl:sequence select="$iso-3166-file//iso_3166_entry/@alpha_2_code"/>
        </xsl:variable>
        <xsl:variable name="prepared-values" as="item()*">
            <xsl:sequence select="for $code in $values return '(' || $code || ')'"/>
        </xsl:variable>
        <xsl:value-of select="string-join($prepared-values, '|')"/>
    </xsl:function>

    <!-- combine similar functions (at least the next two) and update to use a parameter, instead -->
    <xsl:function name="mdc:create-iso15511-regex" as="xs:string">
        <xsl:value-of select="concat('^(', mdc:get-countryCode-regex(), '|([a-zA-Z]{1})|([a-zA-Z]{3,4}))(-[a-zA-Z0-9:/\-]{1,11})$')"/>
    </xsl:function>
    
    <xsl:function name="mdc:create-iso639-1-regex" as="xs:string">
        <xsl:variable name="sorted-values" as="item()*">
            <xsl:sequence select="sort($iso-639-1-file//*:Authority[not(matches(*:authoritativeLabel[1], '^Reserved', 'i'))]/tokenize(@*:about, '/')[last()])"/>
        </xsl:variable>
        <xsl:variable name="prepared-values" as="item()*">
            <xsl:sequence select="for $code in $sorted-values return '(' || $code || ')'"/>
        </xsl:variable>
        <xsl:value-of select="concat('^(', string-join($prepared-values, '|'), ')$')"/>
    </xsl:function>
    
    <xsl:function name="mdc:create-iso639-2b-regex" as="xs:string">
        <xsl:variable name="lines">
            <xsl:for-each select="tokenize($iso-639-2b-file, $newline)[not(contains(., 'local use'))]">
                <code>
                    <bib-code>
                        <xsl:value-of select="tokenize(., '\|')[1]"/> 
                    </bib-code>
                    <!--
                        Removing the term codes for now, as discussed in 2022-11 meeting.
                        If we keep those later, we should change the attribute value to just "iso-639-2b"
                    <term-code>
                        <xsl:value-of select="tokenize(., '\|')[2]"/> 
                    </term-code>
                    -->
                </code>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="sorted-values" as="item()*">
            <!-- EAD3 also included the terminological codes, but since we state 639-2b, we should not, right? -->
            <!-- the previous EAS schematron file was even more "wrong", since it utilized "https://id.loc.gov/vocabulary/iso639-2.rdf" as its source file...
                but that output only includes, say, "deu" for German, not the bibliographic / anglicised "ger" code.
            if we go with the EAD3 way, which is more permissive for the codes, then we should change the controlled value from 639-2b to just 639-2.
            for now, let's just add 'em all, so the validation will include both B&T codes.
            --> 
            <xsl:sequence select="sort($lines//code/*[normalize-space()])"/>
        </xsl:variable>
        <xsl:variable name="prepared-values" as="item()*">
            <xsl:sequence select="for $code in $sorted-values return '(' || $code || ')'"/>
        </xsl:variable>
        <xsl:value-of select="concat('^(', string-join($prepared-values, '|'), ')$')"/>
    </xsl:function>
    
    <xsl:function name="mdc:create-iso639-3-regex" as="xs:string">
        <xsl:variable name="lines">
            <xsl:for-each select="tokenize($iso-639-3-file, $newline)[position() gt 1]">
                <code>
                    <xsl:value-of select="tokenize(., $tab)[1]"/> 
                </code>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="prepared-values" as="item()*">
            <xsl:sequence select="for $code in $lines//code return '(' || $code || ')'"/>
        </xsl:variable>
        <xsl:value-of select="concat('^(', string-join($prepared-values, '|'), ')$')"/>
    </xsl:function>
    
    <xsl:function name="mdc:create-iso3166-regex" as="xs:string">
        <xsl:value-of select="concat('^(', mdc:get-countryCode-regex(), ')$')"/>
    </xsl:function>
    
    <xsl:function name="mdc:create-iso15924-regex" as="xs:string">
        <xsl:variable name="lines">
            <xsl:for-each select="tokenize($iso-15924-file, $newline)[matches(., '^\w{4};')][not(contains(., 'private use'))]">
                <code>
                    <xsl:value-of select="tokenize(., ';')[1]"/> 
                </code>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="prepared-values" as="item()*">
            <xsl:sequence select="for $code in $lines//code return '(' || $code || ')'"/>
        </xsl:variable>
        <xsl:value-of select="concat('^(', string-join($prepared-values, '|'), ')$')"/>
    </xsl:function>
    
    
        
    <xd:doc>
        <xd:desc>
            <xd:p>Adds a very lengthy regex expression for our IETF validation step.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template match="sch:let[@xml:id eq 'ietf']">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="value">
                <xsl:text>'</xsl:text>
                <xsl:value-of select="hcmc:createXmlLangRegex()"/>
                <xsl:text>'</xsl:text>
            </xsl:attribute>
        </xsl:copy>
    </xsl:template>

    <xd:doc>
        <xd:desc>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>Quick transformer to generate XML from the IANA Language Subtag Registry. Updated slightly to filter out local codes, such as 'qaa'.</xd:p>
            <xd:p><xd:b>Source:</xd:b>  https://github.com/projectEndings/diagnostics/tree/dev/utilities</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:createXmlLangRegex" as="xs:string">
        <!-- update to output the date from the file? -->
        <!-- First, get the file (and XML, in order) -->
        <xsl:variable name="entries">
            <xsl:for-each select="tokenize($ietf-bcp-47-file, '\s*%+\s*')[starts-with(., 'Type')]">
                <xsl:variable name="commentsCollapsed" select="replace(., '\n\s+', ' ')"/>
                <entry>
                    <xsl:for-each select="tokenize($commentsCollapsed, '\s*\n\s*')[contains(., ':')]">
                        <xsl:element name="{normalize-space(substring-before(., ':'))}"><xsl:value-of select="normalize-space(substring-after(., ':'))"/></xsl:element>
                    </xsl:for-each>
                </entry>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="registry">
            <registry>
                <!-- added a filter to remove those entries that are reserved for "Private use".  Cannot rely on the scope element, since that isn't always present -->
                <xsl:for-each select="distinct-values($entries//Type)">
                    <xsl:variable name="thisType" select="."/>
                    <xsl:element name="{concat(., 's')}">
                        <xsl:copy-of select="$entries//entry[Type = $thisType][Description[not(matches(., '^Private', 'i'))]]"/>
                    </xsl:element>
                </xsl:for-each>
            </registry>
        </xsl:variable>
        <!--  Then, concat all the possible language values.     -->
        <xsl:variable name="lang" select="concat('^((', string-join($registry//entry[Type='language']/Subtag, ')|('), '))')"/>
        <xsl:variable name="extLang" select="concat('(\-((', string-join($registry//entry[Type='extlang']/Subtag, ')|('), ')))?')"/>
        <xsl:variable name="script" select="concat('(\-((', string-join($registry//entry[Type='script']/Subtag, ')|('), ')))?')"/>
        <xsl:variable name="region" select="concat('(\-((', string-join($registry//entry[Type='region']/Subtag, ')|('), ')))?')"/>
        <xsl:variable name="variant" select="concat('(\-((', string-join($registry//entry[Type='variant']/Subtag, ')|('), ')))?')"/>
        <xsl:value-of select="concat($lang, $extLang, $script, $region, $variant, '($|\-)')"/>
    </xsl:function>
    
</xsl:stylesheet>