<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
    <!-- output -->
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="groupId" />
    <xsl:template match="/">
        <xsl:variable name="query">
            <query>
                <and>
                    <condition name="censhare:asset.type" op="=" value="video." />
                    <condition name="censhare:module.oc.permission.group-ref" value="{$groupId}" />
                </and>
            </query>
        </xsl:variable>
        <kwikeeApiV3>
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
                    <xsl:for-each select="$video/storage_item[starts-with(@mimetype, 'video')]">
                        <files>
                            <type>
                                <xsl:value-of select="@mimetype" />
                            </type>
                            <video-mode>
                                <xsl:if test="@height_px">
                                    <xsl:value-of select="concat(@height_px, 'p')" />
                                </xsl:if>
                            </video-mode>
                            <key>
                                <xsl:value-of select="@key" />
                            </key>
                            <width>
                                <xsl:if test="@width_px">
                                    <xsl:value-of select="concat(@width_px, ' px')" />
                                </xsl:if>
                            </width>
                            <height>
                                <xsl:if test="@height_px">
                                    <xsl:value-of select="concat(@height_px, ' px')" />
                                </xsl:if>
                            </height>
                            <duration>
                                <xsl:value-of select="concat(@duration_sec, ' sec')" />
                            </duration>
                            <audioFormat>
                                <xsl:value-of select="@audio_format" />
                            </audioFormat>
                            <framerate>
                                <xsl:value-of select="concat(@frames_per_second, ' fps')" />
                            </framerate>
                            <bitrate>
                                <xsl:value-of select="concat(@bitrate_mbps, ' mbps')" />
                            </bitrate>
                            <fileSize>
                                <xsl:value-of select="concat(@filelength, ' bytes')" />
                            </fileSize>
                            <videoUrl>
                                <xsl:variable name="fileName" select="tokenize(@relpath, '/')[last()]" />
                                <xsl:variable name="imageurl" select="@url" />
                                <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
                                <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
                                <xsl:value-of select="concat('https://api.kwikee.com/public/gs1/V4/video/',$encodedUrl, $fileName)" />
                            </videoUrl>
                        </files>
                    </xsl:for-each>
                </video>
            </xsl:for-each>
        </kwikeeApiV3>
    </xsl:template>
</xsl:stylesheet>