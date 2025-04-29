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
          <xsl:call-template name = "used"/>
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

  <xsl:template name="used">
    <xsl:if test="name(..)='from'">
      <xsl:attribute name="used">
        <xsl:call-template name = "get-used"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-used">
      <xsl:variable name="qry" select="."/>
      <xsl:variable name="parent-qry" select="$qry/../.."/>
      <xsl:choose>
        <xsl:when test="$parent-qry/@name">
          <xsl:variable name="use" select="$parent-qry/*[not(name()='from')]//column[@table=$qry/@as and ancestor-or-self::*[@as][1]/@used=1]"/>
          <xsl:choose>
            <xsl:when test="$use/@column">
              <xsl:for-each  select = "$parent-qry">
                <xsl:call-template name = "get-used"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="0"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="1"/>
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

</xsl:stylesheet>