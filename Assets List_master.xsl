<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:censhare="http://www.censhare.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
  
    <!-- Brand Portal XSLT returning Assets list for Brand API portal 
          August 2019 - Nikita Dua
     -->

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="page" select="0" />
    <xsl:param name="mediaType" />
    <xsl:param name="domains" />
     <xsl:param name="fileTypes" />
    <xsl:param name="searchText" />
   
    <!-- root match -->
    <xsl:template match="/">
        <!-- get values -->
        <xsl:variable name="assetsPerPage" select="21" />
        <xsl:variable name="startRow" select="$assetsPerPage * number($page)" />
        
        <xsl:variable name="query">
            <query count-rows="true" limit="{$assetsPerPage}" type="asset" offset="{format-number($startRow,'##')}">
                	  <sortorders>
						          <order by="censhare:asset.modified_date" ascending="false"/>
					          </sortorders>
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
                    
                    
                    
                    <xsl:if test="$fileTypes != ''">
                      <condition name="censhare:storage_item.mimetype" op="IN" value="{$fileTypes}" sepchar=","/>
                    </xsl:if>                
                    
                    <xsl:if test="$domains != ''">
                       <condition name="censhare:asset.domain" op="IN" value="{$domains}" sepchar=","/>
                    </xsl:if>
                   
                                    
                    <!-- Uses search text keyworkd,  part of asset names, both coming from indices with fuzzy logic implemented -->
                    <xsl:if test="$searchText != ''">
                         <!--This is a special search attribute (index) in censhare, which optimizes queries -->
                        <condition name="censhare:text.name" value="{$searchText}" />
                    </xsl:if>
     
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
        <brandPortalAPI>

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
                <startRow>
                    <xsl:value-of select="format-number($startRow,'##')" />
                </startRow>
                <assets>

                    <xsl:for-each select="cs:asset($query)">
  
                        <asset>
                          
                            <type>
                                <xsl:value-of select="@type" />
                            </type>
                
                            <id>
                                <xsl:value-of select="@id" />
                            </id>
                            <name>
                                <xsl:value-of select="@name" />
                            </name>
                                                            
                            <thumbNail>
                            <!-- Selects url from image, if non-existent, select the default image -->
                                  <xsl:variable name="possibleurl" select="storage_item[@key='thumbnail']/@url"/>
                                  <xsl:variable name="imageurl">
                                    <xsl:choose>
                                      <xsl:when test="$possibleurl">
                                        <xsl:value-of select="$possibleurl"/>
                                      </xsl:when>
                                      <xsl:otherwise>
                                        <xsl:value-of select="'censhare:///service/assets/asset/id/5985362/storage/thumbnail/file/17064690.jpg'"/>
                                      </xsl:otherwise>
                                    </xsl:choose>
                                  </xsl:variable>
                                  <xsl:variable name="fileName" select="tokenize($imageurl, '/')[last()]" />
                                  <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
                                  <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
                                  <xsl:value-of select="concat('https://brandportal.azure-api.net/cdn/v1/file/',$encodedUrl, $fileName)" />
                            </thumbNail>
                        </asset>
                    </xsl:for-each>
                </assets>
            </xsl:if>
            <xsl:if test="number($totalCount)!=number($totalCount)">
                <totalAssets>0</totalAssets>
                <pageIndex>
                    <xsl:value-of select="$page" />
                </pageIndex>
                <totalPages>0</totalPages>
                <startRow>
                    <xsl:value-of select="format-number($startRow,'##')" />
                </startRow>
            </xsl:if>
        </brandPortalAPI>
    </xsl:template>
</xsl:stylesheet>