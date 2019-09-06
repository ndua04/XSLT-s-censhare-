<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
    <!-- API V3 XSLT returning Products list for Brand API portal based on related permission group
          September 2018 - Bruno Schrappe, Gregory Fonkatz
     -->
    <!-- output -->
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="page" select="0" />

    <!-- root match -->
    <xsl:template match="/">
        <!-- get values -->
        <xsl:variable name="assetsPerPage" select="20" />
        <xsl:variable name="startRow" select="$assetsPerPage * number($page)" />
        <xsl:variable name="query">
            <query count-rows="true" limit="{$assetsPerPage}" type="asset" offset="{format-number($startRow,'##')}">
                <and>
                    <condition name="censhare:asset.type" value="brand." />

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
            <xsl:if test="number($totalCount)=number($totalCount)">
                <xsl:variable name="pages" select="ceiling(number($result/result/assets/@row-count) div $assetsPerPage)" />
                <totalAssets>
                    <xsl:value-of select="$totalCount" />
                </totalAssets>
                <pageIndex>
                    <xsl:value-of select="$page" />
                </pageIndex>
                <totalPages>
                    <xsl:value-of select="format-number($pages,'##')" />
                </totalPages>
                <xsl:variable name="csAssetQuery">
                    <query limit="{$assetsPerPage}" offset="{format-number($startRow,'##')}">
                        <and>
                            <condition name="censhare:asset.type" value="brand." />

                        </and>
                    </query>
                </xsl:variable>
                <brands>
                    <xsl:for-each select="cs:asset($csAssetQuery)">
                      <xsl:variable name="brandName" select="@name" />
                      <xsl:variable name="displayName" select="asset_feature[@feature='kwikee:brand.displayName']/@value_string"/>
                       <brand>
                        <name>
                                  <xsl:choose>
                                    <xsl:when test="$displayName">
                                      <xsl:value-of select="$displayName" />
                                    </xsl:when>
                                    <xsl:otherwise>
                                      <xsl:value-of select="$brandName" />
                                    </xsl:otherwise>
                                  </xsl:choose>
                          </name>
                                

                        
                        <xsl:variable name="brandId" select="@id" />
                        <xsl:variable name="logoId" select="child_asset_rel[@key='user.logo.']/@child_asset" />
                        <xsl:for-each select="$logoId">
                            <xsl:variable select="." name="current" />
                            <xsl:variable name="logoAsset" select="cs:asset()[@censhare:asset.id=$current]" />
                              <xsl:variable name="thumbNailUrl" select="$logoAsset/storage_item[@key='thumbnail']/@url" />
                              <xsl:variable name="url1" select="replace($thumbNailUrl,'censhare:///service/assets/asset/id/', '')" />
                              <xsl:variable name="encodedUrl" select="cs:encode-base64($url1)" />
                              <xsl:variable name="logoUrl" select="concat('https://api.kwikee.com/public/gs1/V4/asset/',$encodedUrl,'/thumbnail.jpg')" />
                             
                              <logos>
                                <id>
                                    <xsl:value-of select="$current" />
                                </id>
  

                                <thumbNail>
                                    <xsl:value-of select="$logoUrl" />
                                </thumbNail>
                              </logos>
                        </xsl:for-each>
                        </brand>
                    </xsl:for-each>
                </brands>
            </xsl:if>
        </kwikeeApiV3>
    </xsl:template>
</xsl:stylesheet>