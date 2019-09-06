<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:censhare="http://www.censhare.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
  
    <!-- Brand Portal XSLT returning a list of non-paginated GPC categories with names and IDs that can be used to populate a filtering combobox on Brand Portals.
          April 2019 - Bruno Schrappe, Gregory Fonkatz
     -->

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="groupId" />
    <xsl:param name="containerType" />
    <xsl:param name="brandIds" />
    <xsl:param name="searchText" />
    <xsl:variable name="brandIdList" select="str:tokenize($brandIds,',')" />
   
    <!-- root match -->
    <xsl:template match="/">
      <brandPortalAPI>
        <xsl:variable name="query">
          <!--
               Freaking expensive query after joining, I am limiting it to 500 assets to avoid overloading the server. This should suffice for a fairly long list of container types.
               Products should be filtered by other parameters anyway,reducing the resultset.
          -->
          <query type="asset" limit="500">
            <and>
              <condition name="censhare:asset.type" value="product." />
              <!-- requires the product to be current -->
              <condition name="kwikee:interface.product-is-current" value="true"/>
              <!-- filters out stupid legacy logo products -->
              <condition name="kwikee:product.functionalName" op="!=" value="Logo" />
              <!-- permission group ID (optional) does not need an IF clause if null-->
              <condition name="censhare:module.oc.permission.group-ref" value="{$groupId}" />
              <!-- container type key (optional) -->
              <xsl:if test="$containerType !=''">
                <condition name="kwikee:product.containerType" value="{$containerType}" />
              </xsl:if>
              <!-- Uses search text keyworkd, whcih can be GTIN in all formats OR part of product names, both coming from indices with fuzzy logic implemented -->
              <xsl:if test="$searchText != ''">
                <or>
                  <!-- This is a special search attribute (index) in censhare, which optimizes queries -->
                  <condition name="censhare:text.name" value="{$searchText}" />
                  <!-- Same thing here... -->
                  <condition name="kwikee:text.gtin" value="{$searchText}" />
                </or>
              </xsl:if>
              <xsl:if test="$brandIdList != ''">
                <or>
                  <xsl:for-each select="$brandIdList">
                    <xsl:variable name="brandId" select="." />
                    <condition name="kwikee:product.brand" value="{$brandId}" />
                  </xsl:for-each>
                </or>
              </xsl:if>
            </and>
          </query>
        </xsl:variable>
        <!--  Returns GPC category assets by joining product query with asset reference feature -->
        <xsl:for-each select="(cs:asset($query))/cs:feature-ref-reverse()[@key = 'kwikee:product.gpcCategory']/cs:order-by()[@censhare:asset.name]" >
          <gpcBricks censhare:_annotation.multi='true'>
            <id><xsl:value-of select="@id"/></id>
            <name><xsl:value-of select="@name"/></name>
          </gpcBricks>
        </xsl:for-each>
        </brandPortalAPI>
    </xsl:template>
</xsl:stylesheet>