<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions"
  xmlns:corpus="http://www.censhare.com/xml/3.0.0/corpus"
  xmlns:csc="http://www.censhare.com/censhare-custom"
  xmlns:myfn="local-functions"
  exclude-result-prefixes="#all"
  >

  <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no"/>

  <xsl:template match="/">

    <!-- accept parameters -->

    <xsl:param name="red"/>
    <xsl:param name="green"/>
    <xsl:param name="blue"/>
    <xsl:param name="rgbProfile"/>
    <xsl:param name="pantone"/>
    <xsl:param name="cyan"/>
    <xsl:param name="magenta"/>
    <xsl:param name="yellow"/>
    <xsl:param name="black"/>
    <xsl:param name="cmykProfile"/>
    <xsl:param name="hexValue"/>
    <xsl:param name="colorName"/>
    <xsl:param name="parentAssetId"/>

    <xsl:variable name="finalHex">
      <xsl:choose>
       <xsl:when test="not(starts-with($hexValue, '#'))">
         <xsl:value-of select="concat('#', $hexValue)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$hexValue" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

                <xsl:variable name="asset_xml">
                  <asset name="{$colorName}" type="brand:color." domain="root.kwikee.content.client.22649288.300004.603623.">
                    <asset_feature feature="color:red"  value_long="{$red}"/>
                    <asset_feature feature="color:green" value_long="{$green}"/>
                    <asset_feature feature="color:blue" value_long="{$blue}"/>
                    <asset_feature feature="color:rbgprofile" value_key="{$rgbProfile}"/>
                    <asset_feature feature="color:pantone" value_string="{$pantone}"/>
                    <asset_feature feature="color:cyan" value_long="{$cyan}"/>
                    <asset_feature feature="color:magenta" value_long="{$magenta}"/>
                    <asset_feature feature="color:yellow" value_long="{$yellow}"/>
                    <asset_feature feature="color:black" value_long="{$black}"/>
                    <asset_feature feature="color:cmykprofile" value_key="{$cmykProfile}"/>
                    <asset_feature feature="color:hexvalue" value_string="{$finalHex}"/>
                    <parent_asset_rel parent_asset="{$parentAssetId}" key="color."/>
                  </asset>
                </xsl:variable>
                
           
           
                <xsl:variable name="color_asset_output"/>
     
                <cs:command name="com.censhare.api.assetmanagement.CheckInNew" returning="color_asset_output">
                  <cs:param name="source" select="$asset_xml"/>
                </cs:command>

<output>
  Success
</output>

  </xsl:template>



</xsl:stylesheet>