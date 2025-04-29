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
          <xsl:call-template name = "source-keys"/>
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

  <xsl:template name="source-keys">
    <xsl:if test="name()='select' and not(./column[@key=1])">
      <xsl:for-each  select = "..">
        <xsl:call-template name = "get-keys">
          <xsl:with-param name="table-pname" select="from/query[not(@join)]/@as"></xsl:with-param>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-keys">
    <xsl:param name="table-pname"></xsl:param>
    <xsl:for-each  select = "from/query[not(@join)]">
      <xsl:choose>
        <xsl:when test="select/column/@key=1">
          <xsl:for-each  select = "select/column[@key=1]">
            <xsl:element name="column">
              <xsl:attribute name="table">
                <xsl:value-of select="$table-pname"/>
              </xsl:attribute>
              <xsl:attribute name="column">
                <xsl:value-of select="@column"/>
              </xsl:attribute>
              <xsl:attribute name="as">
                <xsl:value-of select="'k_'"/>
                <xsl:value-of select="@column"/>
              </xsl:attribute>
              <xsl:attribute name="key">
                <xsl:value-of select="1"/>
              </xsl:attribute>
            </xsl:element>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name = "get-keys">
            <xsl:with-param name="table-pname" select="$table-pname"></xsl:with-param>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="copy-attr">
    <xsl:for-each  select = "@*">
      <xsl:attribute name="{name()}">
        <xsl:value-of select="."/>
      </xsl:attribute>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>