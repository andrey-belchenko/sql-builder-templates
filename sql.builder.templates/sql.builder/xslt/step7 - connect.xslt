<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ora="http://www.oracle.com/XSL/Transform/java">
  <xsl:output omit-xml-declaration="yes"/>
  <xsl:template match="text()"/>
  <xsl:variable name="root" select="//root"/>


  <xsl:template match="//root">
    <xsl:element name="root">
       <xsl:call-template name = "main"/>
    </xsl:element>
     
    
  </xsl:template>

  <xsl:template name="main">
    
    <xsl:if test="//insert">
      <xsl:variable name="all-into">
        <xsl:for-each select="//select/*[@into]">
          <xsl:element name="column">
            <xsl:attribute name="into">
              <xsl:value-of select="@into"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="dist-into">
        <xsl:for-each select="msxsl:node-set($all-into)/*">
          <xsl:variable name="into" select="@into"/>
          <xsl:if test="not(preceding-sibling::*[@into=$into]) and not(@into='sparentid')">
            <xsl:copy-of select="."/>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>

      <xsl:text>select level,skod,sid,sparentid</xsl:text>
      <xsl:for-each select="msxsl:node-set($dist-into)/*">
        <xsl:value-of select="','"/>
        <xsl:value-of select="@into"/>
      </xsl:for-each>
      <xsl:text> from rr_temp connect by prior sid=sparentid start with sparentid is null</xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>