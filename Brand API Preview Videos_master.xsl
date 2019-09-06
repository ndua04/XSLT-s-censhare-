<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
    <!-- output -->
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="groupId" />
    <xsl:param name="page" select="0" />
    <xsl:template match="/">
        <xsl:variable name="assetsPerPage" select="20" />
        <xsl:variable name="startRow" select="$assetsPerPage * number($page)" />
        <xsl:variable name="query">
            <query count-rows="true" limit="{$assetsPerPage}" type="asset" offset="{format-number($startRow,'##')}">
                <and>
                    <condition name="censhare:asset.type" op="=" value="video." />
                    <condition name="censhare:module.oc.permission.group-ref" value="{$groupId}" />
                </and>
            </query>
        </xsl:variable>
        <xsl:variable name="result">
            <cs:command name="asset.query" return-slot="result" returning="result">
                <cs:param name="data" select="$query" />
            </cs:command>
        </xsl:variable>
        <kwikeeApiV3>
            <xsl:variable name="pages" select="ceiling(number($result/result/assets/@row-count) div $assetsPerPage)" />
            <xsl:variable name="totalCount" select="$result/result/assets/@row-count" />
            <xsl:variable name="pages" select="ceiling(number($result/result/assets/@row-count) div $assetsPerPage)" />
            <totalVideos>
                <xsl:value-of select="$totalCount" />
            </totalVideos>
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
                <xsl:variable name="video" select="." />
                <video>
                    <assetId>
                        <xsl:value-of select="$video/@id" />
                    </assetId>
                    <videoName>
                        <xsl:value-of select="$video/@name" />
                    </videoName>
                    <thumbnailUrl>
                        <xsl:variable name="thumbnail" select="$video/storage_item[@key='thumbnail']" />
                        <xsl:variable name="fileName" select="tokenize($thumbnail/@relpath, '/')[last()]" />
                        <xsl:variable name="imageurl" select="$thumbnail/@url" />
                        <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
                        <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
                        <xsl:value-of select="concat('https://api.kwikee.com/public/gs1/V4/asset/',$encodedUrl, $fileName)" />
                    </thumbnailUrl>
                    <previewUrl>
                        <xsl:variable name="preview" select="$video/storage_item[@key='preview']" />
                        <xsl:variable name="fileName" select="tokenize($preview/@relpath, '/')[last()]" />
                        <xsl:variable name="imageurl" select="$preview/@url" />
                        <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
                        <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
                        <xsl:value-of select="concat('https://api.kwikee.com/public/gs1/V4/asset/',$encodedUrl, $fileName)" />
                    </previewUrl>
                    <brandName>
                        <xsl:value-of select="$video/cs:parent-rel()[@key='user.media.']/@name" />
                    </brandName>
                    <brandAssetId>
                        <xsl:value-of select="$video/cs:parent-rel()[@key='user.media.']/@id" />
                    </brandAssetId>
                </video>
            </xsl:for-each>
        </kwikeeApiV3>
    </xsl:template>
</xsl:stylesheet>