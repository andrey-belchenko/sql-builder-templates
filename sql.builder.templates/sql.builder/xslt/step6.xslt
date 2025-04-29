<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ora="http://www.oracle.com/XSL/Transform/java">
  <xsl:output omit-xml-declaration="yes"/>
  <xsl:template match="text()"/>
  <xsl:variable name="root" select="//root"/>


  <xsl:template match="//root">
      <xsl:call-template name = "main"/>
  </xsl:template>

  <xsl:template name="main">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "add-insert"/>
          <xsl:for-each  select = "child::node()[not(@used=0)]">
            <xsl:call-template name = "add-group-by-bef"/>
            <xsl:call-template name = "main"/>
            <xsl:call-template name = "add-group-by-aft"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="copy-attr">
    <xsl:for-each  select = "@*">
      <xsl:attribute name="{name()}">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="add-insert">
    <xsl:if test="name(..)='root' and @materialize='1'">
      <xsl:element name="insert">
        <xsl:attribute name="into">
          <xsl:value-of select="'rr_temp'"/>
        </xsl:attribute>
        <xsl:element name="column">
          <xsl:attribute name="column">
            <xsl:value-of select="'skod'"/>
          </xsl:attribute>
          <xsl:attribute name="info">
            <xsl:value-of select="'skod'"/>
          </xsl:attribute>
        </xsl:element>
        <xsl:element name="column">
          <xsl:attribute name="column">
            <xsl:value-of select="'sid'"/>
          </xsl:attribute>
          <xsl:attribute name="info">
            <xsl:value-of select="'sid'"/>
          </xsl:attribute>
        </xsl:element>
        <xsl:element name="column">
          <xsl:attribute name="column">
            <xsl:value-of select="'rn'"/>
          </xsl:attribute>
          <xsl:attribute name="info">
            <xsl:value-of select="'rn'"/>
          </xsl:attribute>
        </xsl:element>
        <xsl:for-each select="select/*">
          <xsl:element name="column">
            <xsl:attribute name="column">
              <xsl:value-of select="@into"/>
            </xsl:attribute>
            <xsl:attribute name="info">
              <xsl:value-of select="@as"/>
            </xsl:attribute>
          </xsl:element>
        </xsl:for-each>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
  
  <xsl:template name="add-group-by-bef">
    <xsl:if test="name(..)='query'">
      <xsl:if test="name()='call' and position()=last()">
        <xsl:call-template name = "add-group-by"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="add-group-by-aft">
    <xsl:if test="name(..)='query'">
      <xsl:if test="not(name()='call') and position()=last()">
        <xsl:call-template name = "add-group-by"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>


  <xsl:template name="add-group-by">
    <xsl:if test="../select/*[@group=1]">
        <xsl:element name="group">
          <xsl:for-each  select = "../select//*[@group=1 and not(@used=0)]">
            <xsl:copy-of select="."/>
          </xsl:for-each>
        </xsl:element>
    </xsl:if>
  </xsl:template>


</xsl:stylesheet>