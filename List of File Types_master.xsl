<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:censhare="http://www.censhare.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
  
    <!-- Brand Portal XSLT returning Assets list for Brand API portal 
          August 2019 - Nikita Dua
     -->

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="mediaType" />
    <xsl:param name="domains" />
    <xsl:param name="searchText" />
   
    <!-- root match -->
    <xsl:template match="/">
        <!-- get values -->
  
        
        <xsl:variable name="query" >
            <query  type="asset" limit="1000">
                <and>
                
                    <!-- Immediately removes deleted assets from results -->
                    <condition name="censhare:asset.deletion" value="0"/>
                     <!-- filters out stupid legacy logo products -->
                    <condition name="kwikee:product.functionalName" op="!=" value="Logo" />
                     <xsl:choose>
                        <xsl:when test="$mediaType != ''">
                          <condition name="censhare:asset.type" value="{$mediaType}"/>
                        </xsl:when>
                        <xsl:otherwise>
                           <or>
                            <condition name="censhare:asset.type" value="video." />
                           <condition name="censhare:asset.type" value="picture." />
                          </or>
                            
                        </xsl:otherwise>
                    </xsl:choose>
                    
                    
                    
              
                    <xsl:if test="$domains != ''">
                       <condition name="censhare:asset.domain" op="IN" value="{$domains}" sepchar=","/>
                    </xsl:if>
                   
                                    
                     <!--Uses search text keyworkd,  part of asset names, both coming from indices with fuzzy logic implemented -->
                    <xsl:if test="$searchText != ''">
                         <!--This is a special search attribute (index) in censhare, which optimizes queries -->
                        <condition name="censhare:text.name" value="{$searchText}" />
                    </xsl:if>
     
                </and>
            </query>
        </xsl:variable>
        
        
        <!-- output report header -->
        <brandPortalAPI>
                    <xsl:for-each select="distinct-values(cs:asset($query)//storage_item[@key='master']/@mimetype)">
  
                            <filetypes censhare:_annotation.multi='true'>
                              <xsl:value-of select="."/>
                            </filetypes>
                
                    </xsl:for-each>
              
        </brandPortalAPI>
    </xsl:template>
</xsl:stylesheet>