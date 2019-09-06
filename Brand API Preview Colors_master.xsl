<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="page" select="0" />
    <xsl:template match="/">
        <xsl:variable name="assetsPerPage" select="20" />
        <xsl:variable name="startRow" select="$assetsPerPage * number($page)" />
        <xsl:variable name="query">
            <query count-rows="true" limit="{$assetsPerPage}" type="asset" offset="{format-number($startRow,'##')}">
                <and>
                    <condition name="censhare:asset.type" op="=" value="brand:color." />
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
            <totalColors>
                <xsl:value-of select="$totalCount" />
            </totalColors>
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
                <colorAsset>
                    <assetId>
                        <xsl:value-of select="@id" />
                    </assetId>
                    <relatedBrands>
                        <xsl:for-each select="cs:parent-rel()[@key='color.']">
                            <brandId>
                                <xsl:value-of select="@id" />
                            </brandId>
                            <brandName>
                                <xsl:value-of select="@name" />
                            </brandName>
                        </xsl:for-each>
                    </relatedBrands>
                    <name>
                        <xsl:value-of select="@name" />
                    </name>
                    <red>
                        <xsl:value-of select="asset_feature[@feature='color:red']/@value_long" />
                    </red>
                    <green>
                        <xsl:value-of select="asset_feature[@feature='color:green']/@value_long" />
                    </green>
                    <blue>
                        <xsl:value-of select="asset_feature[@feature='color:blue']/@value_long" />
                    </blue>
                </colorAsset>
            </xsl:for-each>
        </kwikeeApiV3>
    </xsl:template>
</xsl:stylesheet>