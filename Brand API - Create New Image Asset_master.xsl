<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus" xmlns:csc="http://www.censhare.com/censhare-custom" xmlns:myfn="local-functions" exclude-result-prefixes="#all">
    <!-- Create an asset for a product image for a BAPI product image upload
    Gregory Fonkatz
    May 2019
    TODO: Name should be constructed differently
    DONE: Fixed name construction (Bruno)
     -->
    <!-- output -->
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="productAssetId" />
    <xsl:param name="type" />
    <xsl:param name="language" />
    <xsl:param name="facing" />
    <xsl:param name="angle" />
    <xsl:param name="state" />
    <xsl:param name="specialPurpose" />
    <xsl:param name="rendered" />
    <xsl:variable name="product_asset_id" select="$productAssetId" />
    <xsl:variable name="promotion" select="'Default'" />
    <!-- root match -->
    <xsl:template match="/">
        <xsl:variable name="product_asset_result" select="cs:asset()[@censhare:asset.id = xs:long($product_asset_id) and @censhare:asset.type = 'product.']" />
        <xsl:variable name="gtin" select="string($product_asset_result//asset_feature[@feature='kwikee:product.gtin']/@value_string)" />
       
        <!-- Oh the sadness of having to support legacy... view code needs to be included on the name... -->
        <xsl:variable name="view_code">
        <xsl:choose>
          <xsl:when test="$angle='R'">CR</xsl:when>
          <xsl:when test="$angle='L'">CL</xsl:when>
          <xsl:otherwise>CF</xsl:otherwise>
        </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="asset_name">
            <xsl:value-of select="string-join(($promotion, $gtin, $view_code), '_')" />
        </xsl:variable>
        <xsl:variable name="asset_xml">
            <asset name="{$asset_name}" type="picture." promotion="{$promotion}" domain="{$product_asset_result/@domain}" domain2="{$product_asset_result/@domain2}">
                <asset_feature feature="kwikee:product-asset.promotion" value_string="{$promotion}" />
                <asset_feature feature="kwikee:product-asset.view_code" value_string="{$view_code}"/>
                <asset_feature feature="kwikee:product-asset.imageType" value_key="{$type}" />
                <asset_feature feature="censhare:asset.language" value_string="{$language}" />
                <asset_feature feature="kwikee:product-asset.facing" value_key="{$facing}" />
                <asset_feature feature="kwikee:product-asset.angle" value_key="{$angle}" />
                <asset_feature feature="kwikee:product-asset.state" value_key="{$state}" />
                <asset_feature feature="kwikee:product-asset.specialPurpose" value_key="{$specialPurpose}" />
                <asset_feature feature="kwikee:product-asset.renderedImage" value_long="{$rendered}" />
                <parent_asset_rel parent_asset="{$product_asset_id}" key="user.media." />
            </asset>
        </xsl:variable>
        <!-- <asset_xml><xsl:copy-of select="$asset_xml"/></asset_xml> -->
        <xsl:variable name="image_asset_output" />
        <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="image_asset_output">
            <cs:param name="source" select="$asset_xml" />
        </cs:command>
        <!-- add parent product. relationship -->
        <!-- return output -->
        <xsl:for-each select="$image_asset_output">
            <xsl:apply-templates select="$image_asset_output" mode="image_asset_output" />
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="asset" mode="image_asset_output">
        <status>success</status>
        <responseData>
            <assetId>
                <xsl:value-of select="@id" />
            </assetId>
            <name>
                <xsl:value-of select="@name" />
            </name>
            <language>
                <xsl:for-each select="asset_feature[@feature='censhare:asset.language']">
                    <xsl:value-of select="@value_string" />
                </xsl:for-each>
            </language>
            <imageType>
                <xsl:for-each select="asset_feature[@feature='kwikee:product-asset.imageType']">
                    <xsl:value-of select="@value_key" />
                </xsl:for-each>
            </imageType>
            <facing>
                <xsl:for-each select="asset_feature[@feature='kwikee:product-asset.facing']">
                    <xsl:value-of select="@value_key" />
                </xsl:for-each>
            </facing>
            <angle>
                <xsl:for-each select="asset_feature[@feature='kwikee:product-asset.angle']">
                    <xsl:value-of select="@value_key" />
                </xsl:for-each>
            </angle>
            <state>
                <xsl:for-each select="asset_feature[@feature='kwikee:product-asset.state']">
                    <xsl:value-of select="@value_key" />
                </xsl:for-each>
            </state>
            <specialPurpose>
                <xsl:for-each select="asset_feature[@feature='kwikee:product-asset.specialPurpose']">
                    <xsl:value-of select="@value_key" />
                </xsl:for-each>
            </specialPurpose>
            <renderedImage>
                <xsl:for-each select="asset_feature[@feature='kwikee:product-asset.renderedImage']">
                    <xsl:value-of select="@value_long" />
                </xsl:for-each>
            </renderedImage>
        </responseData>
    </xsl:template>
</xsl:stylesheet>