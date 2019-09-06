<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:censhare="http://www.censhare.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />

<!-- Provides media asset details for Brand Portal API calls
     Bruno Schrappe April 2019
     Returns whitelisted file types -->

<xsl:param name="assetId" />

<xsl:template match="/">
  <xsl:variable name="query">
    <query limit="1">
        <condition name="censhare:asset.id" value="{$assetId}"/>
    </query>
  </xsl:variable>
        
  <xsl:variable name="mediaAsset" select="cs:asset($query)" />
  <brandApi>
    <assetId>
      <xsl:value-of select="$mediaAsset/@id" />
    </assetId>
    <assetName>
      <xsl:value-of select="$mediaAsset/@name" />
    </assetName>
    <previewUrl>
      <!-- Selects url from image, if non-existent, select the default image -->
      <xsl:variable name="possibleurl" select="$mediaAsset/storage_item[@key='preview']/@url"/>
      <xsl:variable name="imageurl">
      <xsl:choose>
        <xsl:when test="$possibleurl">
          <xsl:value-of select="$possibleurl"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'censhare:///service/assets/asset/id/5985362/storage/preview/file/17064689.jpg'"/>
        </xsl:otherwise>
        </xsl:choose>
        </xsl:variable>
        <xsl:variable name="fileName" select="tokenize($imageurl, '/')[last()]" />
        <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
        <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
        <xsl:value-of select="concat('https://brandportal.azure-api.net/cdn/v1/file/',$encodedUrl, $fileName)" />
    </previewUrl>    

    
        <!-- GS1 Image Type -->
    <xsl:variable name="imgTypeKey" select="$mediaAsset/asset_feature[@feature='kwikee:product-asset.imageType']/@value_key"/>
    <xsl:if test="$imgTypeKey">
      <features>
        <featureKey>kwikee:product-asset.imageType</featureKey>
        <name><xsl:value-of select="cs:master-data('feature')[@key='kwikee:product-asset.imageType']/@name"/></name>
        <value>
          <xsl:variable name="keyName" select="cs:master-data('feature_value')[@feature='kwikee:product-asset.imageType' and @value_key=$imgTypeKey]/@name"/>
            <xsl:value-of select="$keyName"/>
        </value>
        <valueKey><xsl:value-of select="$imgTypeKey"/></valueKey>
      </features>
    </xsl:if>
    
    <!-- GS1 Facing -->
    <xsl:variable name="facingKey" select="$mediaAsset/asset_feature[@feature='kwikee:product-asset.facing']/@value_key"/>
    <xsl:if test="$facingKey">
      <features>
        <featureKey>kwikee:product-asset.facing</featureKey>
        <name><xsl:value-of select="cs:master-data('feature')[@key='kwikee:product-asset.facing']/@name"/></name>
        <value>
          <xsl:variable name="keyName" select="cs:master-data('feature_value')[@feature='kwikee:product-asset.facing' and @value_key=$facingKey]/@name"/>
          <xsl:value-of select="$keyName"/>
        </value>
        <valueKey><xsl:value-of select="$facingKey"/></valueKey>
      </features>
    </xsl:if>
          
    <!-- GS1 Angle -->    
    <features censhare:_annotation.multi='true'>
      <xsl:variable name="angleKey" select="$mediaAsset/asset_feature[@feature='kwikee:product-asset.angle']/@value_key"/>
      <xsl:if test="$angleKey">
        <featureKey>kwikee:product-asset.angle</featureKey>
        <name><xsl:value-of select="cs:master-data('feature')[@key='kwikee:product-asset.angle']/@name"/></name>
        <value>
          <xsl:variable name="keyName" select="cs:master-data('feature_value')[@feature='kwikee:product-asset.angle' and @value_key=$angleKey]/@name"/>
          <xsl:value-of select="$keyName"/>
        </value>
        <valueKey><xsl:value-of select="$angleKey"/></valueKey>
      </xsl:if>
    </features>
          
          <!-- GS1 Asset State -->
          <xsl:variable name="stateKey" select="$mediaAsset/asset_feature[@feature='kwikee:product-asset.state']/@value_key"/>
          <xsl:if test="$stateKey">
            <features>
              <featureKey>kwikee:product-asset.state</featureKey>
              <name><xsl:value-of select="cs:master-data('feature')[@key='kwikee:product-asset.state']/@name"/></name>
            <value>
              <xsl:variable name="keyName" select="cs:master-data('feature_value')[@feature='kwikee:product-asset.state' and @value_key=$stateKey]/@name"/>
              <xsl:value-of select="$keyName"/>
            </value>
            <valueKey><xsl:value-of select="$stateKey"/></valueKey>
            </features>
          </xsl:if>
          
          <xsl:if test="$mediaAsset/asset_feature[@feature='kwikee:product-asset.renderedImage']/@value_long">
            <features>
              <featureKey>kwikee:product-asset.renderedImage</featureKey>
              <name><xsl:value-of select="cs:master-data('feature')[@key='kwikee:product-asset.renderedImage']/@name"/></name>
              <value>
              <xsl:value-of select="$mediaAsset/asset_feature[@feature='kwikee:product-asset.renderedImage']/@value_long"/>
            </value>
            </features>
          </xsl:if>
          
          <!-- Kwikee Special Purpose definition -->
          <xsl:variable name="purposeKey" select="$mediaAsset/asset_feature[@feature='kwikee:product-asset.specialPurpose']/@value_key"/>
          <xsl:if test="$purposeKey">
            <features>
              <featureKey>kwikee:product-asset.specialPurpose</featureKey>
              <name><xsl:value-of select="cs:master-data('feature')[@key='kwikee:product-asset.specialPurpose']/@name"/></name>
              <value>
              <xsl:variable name="keyName" select="cs:master-data('feature_value')[@feature='kwikee:product-asset.specialPurpose' and @value_key=$purposeKey]/@name"/>
              <xsl:value-of select="$keyName"/>
            </value>
            <valueKey><xsl:value-of select="$purposeKey"/></valueKey>
            </features>
          </xsl:if>
          
          
        <!-- </assetAttributes> -->
          
         <xsl:variable name="masterMeta" select="$mediaAsset/storage_item[@key='master']" />
              <!--   <masterMetadata censhare:_annotation.multi='true'> 
                    <metadata censhare:_annotation.multi='true'>-->
                    <!-- Mime type 
                    <xsl:variable name="mimeType" select="$masterMeta/@mimetype"/>
                    <xsl:if test="$mimeType">

                      <xsl:variable name="keyName" select="cs:master-data('mimetype')[@mimetype=$mimeType]/@name"/>
                      <name>MIME Type</name>
                      <value><xsl:value-of select="$keyName"/></value>
                  
                    </xsl:if>
                  </metadata>-->
                  
                    <!-- File Length 
                    <xsl:variable name="fileLength" select="$masterMeta/@filelength"/>
                    <xsl:if test="$fileLength">
                    <metadata>
                      <name>File Size</name>-->
                      
                      <!-- Automatic selection of Megabytes (MB) or Kilobytes (KB) based on order of magnitude 
                      <xsl:choose>
                        <xsl:when test="number($fileLength) >= 1000000">
                          <value>
                            <xsl:value-of select="concat(format-number($fileLength div 1000000, '#,###.##'),' MB')"/>
                          </value>
                        </xsl:when>
                        <xsl:otherwise>
                          <value>
                            <xsl:value-of select="concat(format-number($fileLength div 1000, '#,###'),' KB')"/>
                          </value>                          
                        </xsl:otherwise>
                      </xsl:choose>

                    </metadata>
                    </xsl:if> -->
                    
                    <!-- File Height -->
                    <xsl:variable name="fileHeight" select="$masterMeta/@height_px"/>
                    <xsl:if test="$fileHeight">
                    <metadata censhare:_annotation.multi='true'>
                      <name>Height</name>
                      <value><xsl:value-of select="concat(format-number($fileHeight, '#,###'),' pixels')"/></value>
                    </metadata>
                    </xsl:if>
                    
                    <!-- File Width -->
                    <xsl:variable name="fileWidth" select="$masterMeta/@width_px"/>
                    <xsl:if test="$fileWidth">
                      <metadata censhare:_annotation.multi='true'>
                        <name>Width</name>
                        <value><xsl:value-of select="concat(format-number($fileWidth, '#,###'),' pixels')"/></value>
                      </metadata>
                    </xsl:if>
                    
                    <!-- DPI Resolution -->
                    <xsl:variable name="dpi" select="$masterMeta/@dpi"/>
                    <xsl:if test="$dpi">
                      <metadata censhare:_annotation.multi='true'>
                        <name>Resolution</name>
                        <value><xsl:value-of select="concat(format-number($dpi, '#,###'),' DPI')"/></value>
                      </metadata>
                    </xsl:if>
                    
                    <!-- Color Model -->
                    <xsl:variable name="colorModel" select="$masterMeta/@color"/>
                    <xsl:if test="$colorModel">
                      <metadata censhare:_annotation.multi='true'>
                        <name>Color Model</name>
                        <value><xsl:value-of select="upper-case($colorModel)"/></value>
                      </metadata>
                    </xsl:if>
                    
                    
                    <!-- Duration (for video types) -->
                     <xsl:variable name="duration" select="$masterMeta/@duration_sec"/>
                    <xsl:if test="$duration">
                      <metadata>
                        <name>Duration</name>
                        <value><xsl:value-of select="concat(format-number($duration, '#,###'),' seconds')"/></value>
                      </metadata>
                    </xsl:if>
                    
                    <!-- Audio Format (for video types) -->
                     <xsl:variable name="audioFormat" select="$masterMeta/@audio_format"/>
                    <xsl:if test="$audioFormat">
                      <metadata>
                        <name>Audio Format</name>
                        <value><xsl:value-of select="upper-case($audioFormat)"/></value>
                      </metadata>
                    </xsl:if>
                  
                        <!-- Video Format-->
                     <xsl:variable name="videoFormat" select="$masterMeta/@video_format"/>
                    <xsl:if test="$videoFormat">
                      <metadata>
                        <name>Video Format</name>
                        <value><xsl:value-of select="$videoFormat"/></value>
                      </metadata>
                    </xsl:if>
                    
                                  <!-- Frames per second-->
                     <xsl:variable name="framesps" select="$masterMeta/@frames_per_second"/>
                    <xsl:if test="$framesps">
                      <metadata>
                        <name>Frames per Second</name>
                        <value><xsl:value-of select="$framesps"/></value>
                      </metadata>
                    </xsl:if>
                    
                                               <!-- Bit rate Mbit/s-->
                     <xsl:variable name="bitRate" select="$masterMeta/@bitrate_mbps"/>
                    <xsl:if test="$bitRate">
                      <metadata>
                        <name>Bit Rate</name>
                        <value><xsl:value-of select="concat(format-number($bitRate, '#,###'),' Mbps')"/></value>
                      </metadata>
                    </xsl:if>

                  <!-- Storage Items -->
                  <xsl:for-each select="$mediaAsset/storage_item[@key='video-preview_720p' or @key='video-preview_480p' or @key='video-preview_360p' or @key='video-preview_240p' or @key='master' or @key='kwikee:EPS' or @key='kwikee:GS1' or @key='wikee:JPG' or @key='kwikee:LEPS' or @key='kwikee:LZIP' or @key='kwikee:PDF' or @key='kwikee:PNG' or @key='kwikee:psd' or @key='kwikee:TIF' or @key='pdf' ]">
                    <xsl:sort select="number(@filelength)" order="descending"/>
                    
                    <files censhare:_annotation.multi='true'>
                      <fileSid><xsl:value-of select="@sid"/></fileSid>
                      
                      <fileType>
                        <xsl:variable name="keyDef" select="@key"/>
                        <xsl:variable name="keyName" select="cs:master-data('storage_keydef')[@key=$keyDef]/@name"/>
                        <xsl:value-of select="$keyName"/>
                        </fileType>
                      
                    <!-- Mime type -->
                    <xsl:variable name="mimeType" select="@mimetype"/>
                    <xsl:if test="$mimeType">
                      <xsl:variable name="keyName" select="cs:master-data('mimetype')[@mimetype=$mimeType]/@name"/>
                      <mimeType><xsl:value-of select="$keyName"/></mimeType>
                    </xsl:if>
                    
                    <!-- File Size -->
                      <!-- <fileSize><xsl:value-of select="concat(format-number(@filelength, '#,###'),' bytes')"/></fileSize> -->
                      <xsl:variable name="storageItemFileSize" select = "@filelength"/>
                      
                      
                      <!-- Automatic selection of Megabytes (MB) or Kilobytes (KB) based on order of magnitude -->
                      <xsl:choose>
                        <xsl:when test="number($storageItemFileSize) >= 1000000">
                          <fileSize>
                            <xsl:value-of select="concat(format-number($storageItemFileSize div 1000000, '#,###.##'),' MB')"/>
                          </fileSize>
                        </xsl:when>
                        <xsl:otherwise>
                          <fileSize>
                            <xsl:value-of select="concat(format-number($storageItemFileSize div 1000, '#,###'),' KB')"/>
                          </fileSize>                          
                        </xsl:otherwise>
                      </xsl:choose>
                    
                    <!-- File URL link -->
                    <xsl:variable name="imageurl" select="@url" />
                    <xsl:variable name="fileName" select="tokenize($imageurl, '/')[last()]" />
                    <xsl:variable name="url1" select="replace($imageurl,'censhare:///service/assets/asset/id/', '')" />
                    <xsl:variable name="encodedUrl" select="concat(cs:encode-base64($url1), '/')" />
                    <url>
                      <xsl:value-of select="concat('https://brandportal.azure-api.net/cdn/v1/file/',$encodedUrl, $fileName)" />
                    </url>
                      
                    </files>
                  </xsl:for-each>
              <!--  </storageItems> -->
              
              <!-- Permission Group list (channels the asset is published to -->
     
        <xsl:for-each select="$mediaAsset/asset_feature[@feature='censhare:module.oc.permission.group-ref']">
          <xsl:variable name="pgId" select="@value_asset_id"/>
          <xsl:variable name="permGroup" select="cs:get-asset($pgId)"/>
          <xsl:variable name="pgName" select="$permGroup/@name"/>
          <xsl:variable name="pgType" select="$permGroup/@type"/>
          <xsl:variable name="pgIdExtern" select="$permGroup/@id_extern"/>
          
          <xsl:if test="$pgName and $pgType='module.oc.permission-group.kwikee:retailer.' or $pgIdExtern='kwikee:publish-environment:98995'">
            <distributionChannels censhare:_annotation.multi='true'>
            <id>
              <xsl:value-of select="$permGroup/@id"/>
            </id>
            <name>
              <xsl:value-of select="$pgName"/>
            </name>
             
            <thumbnailUrl>
  
              <!-- Selects url from image, if non-existent, select the default image -->
              <xsl:variable name="possibleurl" select="$permGroup/storage_item[@key='thumbnail']/@url"/>
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
            </thumbnailUrl>
              
          </distributionChannels> 
          </xsl:if>
        </xsl:for-each>  
        
              
        </brandApi>
    </xsl:template>
</xsl:stylesheet>