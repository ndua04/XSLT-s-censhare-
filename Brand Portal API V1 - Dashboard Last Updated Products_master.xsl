<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:censhare="http://www.censhare.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
  
    <!-- Brand Portal XSLT returning Products list for Brand API portal based on related permission group and many, many other parameters...
          April 2019 - Bruno Schrappe
     -->

    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />

    <xsl:template match="/">
        <xsl:variable name="assetsPerPage" select="6" />
        <xsl:variable name="query">
            <query count-rows="true" limit="{$assetsPerPage}" type="asset">
              <sortorders>
						    <!-- <order by="kwikee:update.product-update-date" ascending="false"/> -->
						    <order by="censhare:asset.modified_date" ascending="false"/>
					    </sortorders>
                <and>
                    <condition name="censhare:asset.type" value="product." />
                    <!-- requires the product to be current -->
                    <condition name="kwikee:interface.product-is-current" value="true"/>
                    
                </and>
                <not>
                  <!--
                  
                  PLEASE REMOVE THIS AFTER THE DEMO 
                  
                  -->
                  
                  <condition name="censhare:asset.id" value="6006332"/>
                </not>
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

                <current>

                    <xsl:for-each select="cs:asset($query)">
                        <products>
                        		<modifiedDate><xsl:value-of select="asset_feature[@feature='kwikee:update.product-update-date']/@value_timestamp"/></modifiedDate>
                            <brandId>
                                <xsl:variable name="brandId" select="asset_feature[@feature='kwikee:product.brand']/@value_asset_id" />
                                <xsl:value-of select="$brandId" />
                            </brandId>
                            <brandName>
                                <xsl:variable name="brandName" select="cs:feature-ref-reverse()[@key = 'kwikee:product.brand']/@name" />
                                <xsl:value-of select="$brandName" />
                            </brandName>
                            <id>
                                <xsl:value-of select="@id" />
                            </id>
                            <gtin>
                                <xsl:value-of select="asset_feature[@feature='kwikee:product.gtin']/@value_string" />
                            </gtin>
                            <name>
                              <!-- Selects simple product name if available, otherwise chooses the asset name -->  
                              
                              <xsl:variable name="productName" select="asset_feature[@feature='kwikee:product.productName']/@value_string"/>
                              <xsl:choose>
                                <xsl:when test="$productName != ''">
                                  <xsl:value-of select="$productName" />
                                </xsl:when>
                                <xsl:otherwise>
                                  <xsl:value-of select="@name" />
                                </xsl:otherwise>
                              </xsl:choose>
                            
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

                        </products>
                    </xsl:for-each>
                </current>
         
        </brandPortalAPI>
    </xsl:template>
</xsl:stylesheet>