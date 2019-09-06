<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
    xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
    xmlns:csc="http://www.censhare.com/censhare-custom"
    xmlns:censhare="http://www.censhare.com/"
    exclude-result-prefixes="cs corpus csc">
    
     <!-- Brand Portal API V1 XSLT returning a list of all available brands in Kwikee, given user constraints
          April 2019 - Bruno Schrappe
     -->
    
  <!-- output -->
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no"/>
    <xsl:param name="page">0</xsl:param>

    <!-- root match -->
    <xsl:template match="/">
        <!-- get values -->
        
        <xsl:variable name="mfgQuery">
            <query limit='1' type="asset">
              <and>
                <condition name="censhare:asset.type" value="kwikee:manufacturer."/>
                <condition name="censhare:asset.name" op="!=" value="Kwikee Manufacturer - Template"/>
              </and>
            </query>
        </xsl:variable>
        
        <xsl:variable name="assetsPerPage" select="200"/>

        <xsl:variable name="startRow" select="$assetsPerPage * number($page)"/>
        <xsl:variable name="query">
            <query count-rows="true" limit="{$assetsPerPage}" type="asset" offset="{format-number($startRow,'##')}">
              <and>
                <condition name="censhare:asset.type" value="brand."/>
                <condition name="censhare:asset.name" op="!=" value="Kwikee Brand - Template"/>
              </and>
            </query>
        </xsl:variable>
        <xsl:variable name="result">
            <cs:command name="asset.query" return-slot="result" returning="result">
                <cs:param name="data" select="$query"/>
            </cs:command>
        </xsl:variable>
        
        <!-- output report header -->
        <xsl:variable name="pages" select="ceiling(number($result/result/assets/@row-count) div $assetsPerPage)"/>
        <xsl:variable name="totalCount" select="$result/result/assets/@row-count"/>
        <brandApi>
          <totalAssets><xsl:value-of select="$totalCount"/></totalAssets>
          <pageIndex><xsl:value-of select="$page"/></pageIndex>
          <totalPages><xsl:value-of select="format-number($pages,'##')"/></totalPages>
          <startRow><xsl:value-of select="format-number($startRow,'##')"/></startRow>
    
          <xsl:for-each select="cs:asset($mfgQuery)">
            <manufacturers censhare:_annotation.multi='true'>
              <id>
                <xsl:value-of select="@id"/>
              </id>
              <name>
                <xsl:value-of select="@name"/>
              </name>
              <domain>
                <xsl:value-of select="@domain"/>
              </domain>
            </manufacturers>
          </xsl:for-each>
          
          <!-- Loops through brands -->
          <xsl:for-each select="cs:asset($query)/cs:order-by()[@censhare:asset.name]">
            <brands censhare:_annotation.multi='true'>
              <id>
                <xsl:value-of select="@id"/>
              </id>
              <name>
                <xsl:value-of select="@name"/>
              </name>
              <domain>
                <xsl:value-of select="@domain"/>
              </domain>
              <xsl:variable name="imageurl" select="storage_item[@key='thumbnail']/@url" />
              <xsl:if test="$imageurl !=''">
                <thumbNail>
                  <xsl:variable name="fileName" select="myfile.jpg" />
                  <!-- encoding the freaking URL extension -->
                  <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
                  <xsl:variable name="encodedUrl" select="cs:encode-base64($url1)" />
                  <xsl:value-of name="url2" select="concat('https://brandportal.azure-api.net/cdn/v1/file/',$encodedUrl,'/thumbnail.jpg')" />
                </thumbNail>
              </xsl:if>
            </brands>
          </xsl:for-each>
        </brandApi>
      </xsl:template>
  
</xsl:stylesheet>