<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:censhare="http://www.censhare.com/" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cs="http://www.censhare.com/xml/3.0.0/xpath-functions" exclude-result-prefixes="cs">
  
    <!-- API V1 XSLT returning products and assets data for brandapi exports
          April 2019 - Gregory Fonkatz
          Ruthlessly although slightly changed to provide WIP thumbnail if asset has no thumbnail of its own
     -->
    <!-- output -->
    <xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" />
    <xsl:param name="assetIds" />
    <!-- root match -->

    <xsl:template match="/">
      <xsl:variable name="query">
            <!-- Greg, I added a limit of 500 here, for safety. We may want to revise this later -->
            <query type="asset" limit='500'>
                <and>
                    <condition name="censhare:asset.id" op="IN" value="{$assetIds}" sepchar="," />
                </and>
            </query>
        </xsl:variable>
        
    </xsl:template>
</xsl:stylesheet>