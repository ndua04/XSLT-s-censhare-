<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:censhare="http://www.censhare.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
    <!-- Brand Portal XSLT returning Products list for Brand API portal based on a list of product codes posted as Data object
          June 2019 - Bruno Schrappe, Gregory Fonkatz
     -->
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="data" />
    <!-- root match -->
    <xsl:template match="/">
        <xsl:variable name="values">
            <xsl:copy-of select="$data" />
        </xsl:variable>
        <xsl:variable name="assetIds" select="string-join($values/assets/asset_id, ',')" />
        <xsl:variable name="query">
            <!-- Greg, I added a limit of 500 here, for safety. We may want to revise this later -->
            <!-- Bruno, I had to remove the limit because now we use this call for bulk cart and might exceed the limit -->
            <query type="asset">
                <and>
                    <condition name="censhare:asset.id" op="IN" value="{$assetIds}" sepchar="," />
                </and>
            </query>
        </xsl:variable>
        <brandApi>
            <xsl:for-each select="cs:asset($query)">
                <assets censhare:_annotation.multi="true">
                    <!--Generic asset data that applies to products and assets-->
                    <asset_id>
                        <xsl:value-of select="/@id" />
                    </asset_id>
                    <asset_name>
                        <xsl:value-of select="/@name" />
                    </asset_name>
                    <asset_type>
                        <xsl:value-of select="/@type" />
                    </asset_type>
                    <thumbnail_url>
                        <!-- Selects url from image, if non-existent, select the default image -->
                        <xsl:variable name="possibleurl" select="/storage_item[@key='thumbnail']/@url" />
                        <xsl:variable name="imageurl">
                            <xsl:choose>
                                <xsl:when test="$possibleurl">
                                    <xsl:value-of select="$possibleurl" />
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'censhare:///service/assets/asset/id/5985362/storage/thumbnail/file/17064689.jpg'" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="fileName" select="tokenize($imageurl, '/')[last()]" />
                        <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
                        <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
                        <xsl:value-of select="concat('https://brandportal.azure-api.net/cdn/v1/file/',$encodedUrl, $fileName)" />
                        <!--  
            <xsl:variable name="thumbnail" select="/storage_item[@key='thumbnail']" />
            <xsl:variable name="fileName" select="tokenize($thumbnail/@relpath, '/')[last()]" />
            <xsl:variable name="imageurl" select="$thumbnail/@url" />
            <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
            <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
            -->
                        <!-- Greg, I changed the URL so it uses a dedicated one. The GS1 url only grants access to public files, which prevents some files from being displayed on the brand portal (Bruno)
            <xsl:value-of select="concat('https://api.kwikee.com/public/gs1/V4/asset/',$encodedUrl, $fileName)" /> -->
                        <!-- <xsl:value-of select="concat('https://brandportal.azure-api.net/cdn/v1/file/',$encodedUrl, $fileName)" /> -->
                    </thumbnail_url>
                    <!-- Asset related data -->
                    <xsl:if test="/@type != 'product.'">
                        <parent_product>
                            <xsl:variable name="parent_id" select="/parent_asset_rel[@key='user.media.']/@parent_asset" />
                            <xsl:variable name="parent" select="cs:get-asset($parent_id[1])" />
                            <parent_asset_id>
                                <xsl:value-of select="$parent_id[1]" />
                            </parent_asset_id>
                            <parent_name>
                                <xsl:value-of select="$parent/@name" />
                            </parent_name>
                        </parent_product>
                    </xsl:if>
                    <!-- SIDS -->
                    <xsl:for-each select="/storage_item[@key='video-preview_720p' or @key='video-preview_480p' or @key='video-preview_360p' or @key='video-preview_240p' or @key='master' or @key='kwikee:EPS' or @key='kwikee:GS1' or @key='wikee:JPG' or @key='kwikee:LEPS' or @key='kwikee:LZIP' or @key='kwikee:PDF' or @key='kwikee:PNG' or @key='kwikee:psd' or @key='kwikee:TIF' or @key='pdf' ]">
                        <storage_items censhare:_annotation.multi="true">
                            <sid>
                                <xsl:value-of select="@sid" />
                            </sid>
                            <xsl:variable name="mimeType" select="@mimetype" />
                            <xsl:if test="$mimeType">
                                <xsl:variable name="keyName" select="cs:master-data('mimetype')[@mimetype=$mimeType]/@name" />
                                <mimeType>
                                    <xsl:value-of select="$keyName" />
                                </mimeType>
                            </xsl:if>
                            <fileType>
                                <xsl:variable name="keyDef" select="@key" />
                                <xsl:variable name="keyName" select="cs:master-data('storage_keydef')[@key=$keyDef]/@name" />
                                <xsl:value-of select="$keyName" />
                            </fileType>
                        </storage_items>
                    </xsl:for-each>
                </assets>
            </xsl:for-each>
        </brandApi>
    </xsl:template>
</xsl:stylesheet>