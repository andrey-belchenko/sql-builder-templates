<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ora="http://www.oracle.com/XSL/Transform/java">
  <xsl:output omit-xml-declaration="yes"/>
  <xsl:template match="text()"/>
  <xsl:variable name="root" select="//root"/>
  
  
  <xsl:template match="//root/*">
    <xsl:element name="root">
      <xsl:call-template name = "main"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="main">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "self-keys"/>
          <xsl:for-each  select = "child::node()">
            <xsl:call-template name = "main"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="self-keys">
    <xsl:if test="name()='column' and @as">
      <xsl:variable name="col" select="."/>
      <xsl:choose>
        <xsl:when test="../*/@group=1">
          <xsl:attribute name="key">1</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="name(../../from/*[@as=$col/@table])='table' and position()=1">
              <xsl:attribute name="key">1</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  
  <xsl:template name="copy-attr">
          <xsl:for-each  select = "@*">
            <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
  </xsl:template>
  
</xsl:stylesheet>