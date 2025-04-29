<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" xmlns:ora="http://www.oracle.com/XSL/Transform/java">
  <xsl:output omit-xml-declaration="yes"/>
  <xsl:template match="text()"/>

  <xsl:template match="//root">
    <xsl:element name="root">
      <xsl:call-template name = "main"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="main">
    <xsl:choose>
      <xsl:when test="name()='text'">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="name(..)='query' or name(../..)='query'">
        <xsl:if test="name()='insert'">
          <xsl:value-of select="'--'"/>
          <xsl:value-of select="../@name"/>
        </xsl:if>
        <xsl:if test="name()='select'">
          <xsl:value-of select="'--'"/>
          <xsl:value-of select="../@name"/>
        </xsl:if>
        <xsl:call-template name = "new-line"/>
      </xsl:when>
    </xsl:choose>

    <xsl:if test="name()='query' and name(..)='root' and @materialize='1'">
      <xsl:call-template name = "new-line"/>
      <xsl:call-template name = "new-line"/>
      <xsl:text>delete from rr_temp where skod='</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>';</xsl:text>
      <xsl:call-template name = "new-line"/>
      <xsl:call-template name = "new-line"/>
    </xsl:if>
    
    
    <xsl:for-each  select = "*">
      <xsl:call-template name = "main"/>
    </xsl:for-each>
    <xsl:if test="name()='query'">
      <xsl:call-template name = "new-line"/>
    </xsl:if>
    
    <xsl:if test="name()='query' and name(..)='root'">
      <xsl:if test="@materialize='1'">
        <xsl:text>;</xsl:text>
      </xsl:if>
      <xsl:call-template name = "new-line"/>
      <xsl:call-template name = "new-line"/>
      <xsl:call-template name = "new-line"/>
    </xsl:if>

    <xsl:if test="name()='query'">
      <xsl:value-of select="'--/'"/>
      <xsl:value-of select="@name"/>
      <xsl:call-template name = "new-line"/>
    </xsl:if>
    
  </xsl:template>


  <xsl:template name="new-line-if">
    <xsl:if test="../../*/*/*">
      <xsl:call-template name = "new-line"/>
    </xsl:if>
  </xsl:template>
  <xsl:template name="new-line">
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:for-each  select = "ancestor::*">
        <xsl:call-template name = "tab"/>
      </xsl:for-each>
  </xsl:template>
  
  
  <xsl:template name="tab">
    <xsl:value-of select="''"/>
    <!--<xsl:text>&#9;</xsl:text>-->
  </xsl:template>

</xsl:stylesheet>