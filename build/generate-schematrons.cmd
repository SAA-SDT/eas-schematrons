@echo off

rem still need to update for when we switch between EAD / EAC transformations, which we can do by passing parameters
rem and, of course, just switch these files out for another automated option

set parameters=-Xmx1024m
set CP=-cp ..\vendor\SaxonHE10-1J\saxon-he-10.1.jar

:: check if Java is installed
where java >nul 2>nul
if %errorlevel%==1 (
    @echo Java not found in path.
    exit
)

@echo Getting started.

java %parameters% %CP% net.sf.saxon.Transform -t -xsl:transformations\prep-source-schematron-files.xsl -it schema='eac'
java %parameters% %CP% net.sf.saxon.Transform -t -xsl:transformations\prep-source-schematron-files.xsl -it schema='ead'


@echo All done.

pause
