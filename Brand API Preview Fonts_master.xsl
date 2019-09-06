<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
    <!-- output -->
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="page" select="0" />
    <xsl:param name="groupId" />
    <xsl:template match="/">
        <xsl:variable name="assetsPerPage" select="20" />
        <xsl:variable name="startRow" select="$assetsPerPage * number($page)" />
        <xsl:variable name="query">
            <query count-rows="true" limit="{$assetsPerPage}" type="asset" offset="{format-number($startRow,'##')}">
                <and>
                    <condition name="censhare:asset.type" op="=" value="module.font." />
                    <condition name="censhare:module.oc.permission.group-ref" value="{$groupId}" />
                </and>
            </query>
        </xsl:variable>
        <xsl:variable name="result">
            <cs:command name="asset.query" return-slot="result" returning="result">
                <cs:param name="data" select="$query" />
            </cs:command>
        </xsl:variable>
        <!-- output report header -->
        <xsl:variable name="totalCount" select="$result/result/assets/@row-count" />
        <kwikeeApiV3>
            <xsl:variable name="pages" select="ceiling(number($result/result/assets/@row-count) div $assetsPerPage)" />
            <totalFonts>
                <xsl:value-of select="$totalCount" />
            </totalFonts>
            <pageIndex>
                <xsl:value-of select="$page" />
            </pageIndex>
            <totalPages>
                <xsl:value-of select="format-number($pages,'##')" />
            </totalPages>
            <startRow>
                <xsl:value-of select="format-number($startRow,'##')" />
            </startRow>
            <xsl:for-each select="cs:asset($query)">
                <xsl:variable name="font" select="." />
                <font>
                    <assetId>
                        <xsl:value-of select="$font/@id" />
                    </assetId>
                    <fontName>
                        <xsl:value-of select="$font/@name" />
                    </fontName>
                    <xsl:variable name="master" select="$font/storage_item[@key='master']" />
                    <xsl:variable name="fileName" select="tokenize($master/@relpath, '/')[last()]" />
                    <xsl:variable name="imageurl" select="$master/@url" />
                    <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
                    <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
                    <fontUrl>
                        <xsl:value-of select="concat('https://api.kwikee.com/public/gs1/V4/font/',$encodedUrl, $fileName)" />
                    </fontUrl>
                </font>
            </xsl:for-each>
        </kwikeeApiV3>
    </xsl:template>
</xsl:stylesheet>