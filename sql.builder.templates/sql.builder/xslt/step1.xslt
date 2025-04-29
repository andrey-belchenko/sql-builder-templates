<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt"  xmlns:dyn="http://exslt.org/dynamic"
                extension-element-prefixes="dyn">
  <xsl:output omit-xml-declaration="yes"/>
  <xsl:template match="text()"/>
  <xsl:variable name="root" select="//root"/>
  <xsl:variable name="query-name">
    <xsl:text>22837-test</xsl:text>
  </xsl:variable>
  <xsl:variable name="report-name">
    <xsl:text>10653(38)</xsl:text>
  </xsl:variable>
  <xsl:variable name="item-type">
    <xsl:text>query</xsl:text>
  </xsl:variable>
  <xsl:template match="//root">
    <xsl:element name="root">
      <xsl:call-template name = "root"/>
    </xsl:element>
  </xsl:template>

  <xsl:template name="root">
    <xsl:choose>
      <xsl:when test="$item-type='query'">
        <xsl:for-each select="$root/queries/query[@name=$query-name]">
          <xsl:call-template name="main"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$root/reports/report[@name=$report-name]">
          <xsl:call-template name="report"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="report">
    <xsl:variable name="report-params" select="params"/>
    
    
    <xsl:variable name="v">
      <xsl:call-template name = "apply-params"/>
    </xsl:variable>
    <xsl:variable name="v1">
      <xsl:for-each  select = "msxsl:node-set($v)/*">
        <xsl:call-template name = "apply-part"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="report1">
      <xsl:for-each select="msxsl:node-set($v1)/*/queries//query">
        <xsl:call-template name="report-query"/>
      </xsl:for-each>
      <xsl:for-each select="msxsl:node-set($v1)/*/queries//query">
        <xsl:call-template name="report-query-sel">
          <xsl:with-param name="report-params" select="$report-params"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>


    <!-- НУЖНО СДЕЛАТЬ МАТЕРИАЛИЗАЦИЮ УНИКАЛЬНЫХ С УЧЕТОМ РАЗЛИЧНОГО НАБОРА ПАРАМЕТРОВ-->
    <xsl:variable name="mat-queries-set">
      <xsl:for-each select="msxsl:node-set($report1)/*/*//query[@materialize='1' and not(ancestor::query[@materialize='2'])]">
        <xsl:element name="query">
          <xsl:attribute name="name">
            <xsl:value-of select="@name"/>
          </xsl:attribute>
          <xsl:copy-of select="withparams"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:variable>

    
    
    <xsl:for-each select="msxsl:node-set($mat-queries-set)/*">
      <xsl:variable name="query-name1" select="@name"/>
      
      <xsl:if test="not(preceding-sibling::*[@name=$query-name1])">
        <xsl:variable name="params" select="withparams"/>
        <xsl:for-each select="$root/queries/query[@name=$query-name1]">
        
            <xsl:call-template name="main-materialized">
              <xsl:with-param name = "params" select = "$params"/>
            </xsl:call-template>
         
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
    
    
    <xsl:copy-of select="$report1"/>
    
    
  </xsl:template>




  <xsl:template name="main">
    <xsl:variable name="query">
      <xsl:element name="query">
        <xsl:attribute name="name">
          <xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:if test="@order">
          <xsl:attribute name="order">
            <xsl:value-of select="@order"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@hint">
          <xsl:attribute name="hint">
            <xsl:value-of select="@hint"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name = "get-query"/>
      </xsl:element>
    </xsl:variable>
    <xsl:call-template name = "main-common">
      <xsl:with-param name="query" select="$query"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="main-materialized">
    <xsl:param name="params"></xsl:param>
    <xsl:variable name="query">
      <xsl:element name="query">
        <xsl:attribute name="name">
          <xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:attribute name="materialize">
          <xsl:value-of select="'1'"/>
        </xsl:attribute>
        <xsl:call-template name = "get-query">
          <xsl:with-param name = "params" select = "$params"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:variable>
    <xsl:call-template name = "main-common">
      <xsl:with-param name="query" select="$query"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="report-query">
    <xsl:variable name="query">
      <xsl:element name="query">
        <xsl:attribute name="name">
          <xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:attribute name="materialize">
          <xsl:value-of select="'1'"/>
        </xsl:attribute>
        <xsl:call-template name = "get-report-query"/>
      </xsl:element>
    </xsl:variable>
    <xsl:call-template name = "main-common">
      <xsl:with-param name="query" select="$query"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="report-query-sel">
    <xsl:param name="report-params"/>
    <xsl:variable name="query">
      <xsl:element name="query">
        <xsl:attribute name="name">
          <xsl:value-of select="@name"/>
        </xsl:attribute>
        <xsl:call-template name = "get-report-query-sel">
           <xsl:with-param name="report-params" select="$report-params"/>
        </xsl:call-template>
      </xsl:element>
    </xsl:variable>
    <xsl:call-template name = "main-common">
      <xsl:with-param name="query" select="$query"/>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="get-query">
    <xsl:param name="params" select="withparams"/>
    <xsl:variable name="queryName" select="@name"/>

    <xsl:for-each  select = "$root/queries/query[@name=$queryName]">
      <xsl:call-template name = "get-query-common">
        <xsl:with-param name = "params" select = "$params"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="get-report-query">
    <xsl:variable name="queryName" select="@name"/>
    <xsl:variable name="params" select="withparams"/>
    <xsl:variable name="query-call" select="."/>
    
    <xsl:variable name="query">
      <xsl:for-each  select = "$root/queries/query[@name=$queryName]">
        <xsl:choose>
          <xsl:when test="name($query-call/..)='query'">
            
            <xsl:element name="query">
              <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
                <xsl:value-of select="'-rep'"/>
              </xsl:attribute>
              <xsl:if test="@order">
                <xsl:attribute name="order">
                  <xsl:value-of select="@order"/>
                </xsl:attribute>
              </xsl:if>
              <xsl:element name="select">
                <xsl:element name="column">
                  <xsl:attribute name="table">
                    <xsl:value-of select="$query-call/@as"/>
                  </xsl:attribute>
                  <xsl:attribute name="column">
                    <xsl:value-of select="'*'"/>
                  </xsl:attribute>
                </xsl:element>
                <xsl:element name="column">
                  <xsl:attribute name="table">
                    <xsl:value-of select="$query-call/../@as"/>
                  </xsl:attribute>
                  <xsl:attribute name="column">
                    <xsl:value-of select="'sid'"/>
                  </xsl:attribute>
                  <xsl:attribute name="as">
                    <xsl:value-of select="'sparentid'"/>
                  </xsl:attribute>
                </xsl:element>
              </xsl:element>
              <xsl:element name="from">
                <xsl:element name="query">
                  <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                  </xsl:attribute>
                  <xsl:attribute name="as">
                    <xsl:value-of select="$query-call/@as"/>
                  </xsl:attribute>
                  <xsl:copy-of select="$query-call/withparams"/>
                </xsl:element>
                <xsl:element name="query">
                  <xsl:attribute name="name">
                    <xsl:value-of select="$query-call/../@name"/>
                  </xsl:attribute>
                  <xsl:attribute name="as">
                    <xsl:value-of select="$query-call/../@as"/>
                  </xsl:attribute>
                  <xsl:attribute name="join">
                    <xsl:value-of select="'inner'"/>
                  </xsl:attribute>
                  <xsl:attribute name="materialize">
                    <xsl:value-of select="'2'"/>
                  </xsl:attribute>
                  <xsl:copy-of select="$query-call/../withparams"/>
                  <xsl:copy-of select="$query-call/call"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
            
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>
    
    
    <xsl:for-each  select = "msxsl:node-set($query)/*">
      <xsl:call-template name = "get-query-common">
        <xsl:with-param name = "params" select = "$params"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>
  
  
  <xsl:template name="get-report-query-sel">
    <xsl:param name="report-params"></xsl:param>
    <xsl:variable name="queryName" select="@name"/>
    <xsl:variable name="params" select="withparams"/>
    <xsl:variable name="query-call" select="."/>
    
    <xsl:variable name="query">
      <xsl:for-each  select = "$root/queries/query[@name=$queryName]">
            <xsl:element name="query">
              <xsl:attribute name="name">
                <xsl:value-of select="@name"/>
                <xsl:value-of select="'-rep'"/>
              </xsl:attribute>
              <xsl:element name="select">


                <xsl:element name="column">
                  <xsl:attribute name="table">
                    <xsl:value-of select="$query-call/@as"/>
                  </xsl:attribute>
                  <xsl:attribute name="column">
                    <xsl:value-of select="'sid'"/>
                  </xsl:attribute>
                </xsl:element>

                <xsl:element name="column">
                  <xsl:attribute name="table">
                    <xsl:value-of select="$query-call/@as"/>
                  </xsl:attribute>
                  <xsl:attribute name="column">
                    <xsl:value-of select="'sparentid'"/>
                  </xsl:attribute>
                </xsl:element>
                
                <xsl:element name="column">
                  <xsl:attribute name="table">
                    <xsl:value-of select="$query-call/@as"/>
                  </xsl:attribute>
                  <xsl:attribute name="column">
                    <xsl:value-of select="'*'"/>
                  </xsl:attribute>
                </xsl:element>

                
              </xsl:element>
              <xsl:element name="from">
                <xsl:element name="query">
                  <xsl:attribute name="name">
                    <xsl:value-of select="@name"/>
                  </xsl:attribute>
                  <xsl:attribute name="as">
                    <xsl:value-of select="$query-call/@as"/>
                  </xsl:attribute>
                  <xsl:attribute name="materialize">
                    <xsl:value-of select="'2'"/>
                  </xsl:attribute>
                  <xsl:copy-of select="$params"/>
                </xsl:element>
              </xsl:element>
            </xsl:element>
      </xsl:for-each>
    </xsl:variable>
    
    
    <xsl:for-each  select = "msxsl:node-set($query)/*">
      <xsl:call-template name = "get-query-common">
        <xsl:with-param name = "params" select = "$report-params"/>
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>


  <xsl:template name="get-query-common">
    <xsl:param name="params"/>
    <xsl:variable name="v">
        <xsl:call-template name = "apply-params">
          <xsl:with-param name = "params" select = "$params"/>
        </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="v1">
      <xsl:for-each  select = "msxsl:node-set($v)/*">
        <xsl:call-template name = "apply-part"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:for-each  select = "msxsl:node-set($v1)/*">
      <xsl:call-template name = "query"/>
    </xsl:for-each>
  </xsl:template>
  
  
 


  <xsl:template name="main-common">
    <xsl:param name="query"/>
    <xsl:variable name="query1">
      <xsl:for-each  select = "msxsl:node-set($query)/*">
        <xsl:call-template name = "loop"/>
      </xsl:for-each>
    </xsl:variable>


    <xsl:variable name="query1-1">
      <xsl:for-each  select = "msxsl:node-set($query1)/*">
        <xsl:call-template name = "copy-add-path"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="query2">
      <xsl:for-each  select = "msxsl:node-set($query1-1)/*">
        <xsl:call-template name = "copy2"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="query3">
      <xsl:for-each  select = "msxsl:node-set($query2)/*">
        <xsl:call-template name = "copy3"/>
      </xsl:for-each>
    </xsl:variable>

    <!--добавление типов-->
    <xsl:variable name="query4">
      <xsl:for-each  select = "msxsl:node-set($query3)/*">
        <xsl:call-template name = "copy-add-types"/>
      </xsl:for-each>
    </xsl:variable>

    <!--добавление into-->
    <xsl:variable name="query5">
      <xsl:for-each  select = "msxsl:node-set($query4)/*">
        <xsl:call-template name = "copy-add-col-into"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="query6">
      <xsl:for-each  select = "msxsl:node-set($query5)/*">
        <xsl:call-template name = "copy-check-keys"/>
      </xsl:for-each>
    </xsl:variable>


    <!-- НУЖНО СДЕЛАТЬ МАТЕРИАЛИЗАЦИЮ УНИКАЛЬНЫХ С УЧЕТОМ РАЗЛИЧНОГО НАБОРА ПАРАМЕТРОВ-->
    <!-- перенес в report
    <xsl:variable name="mat-queries-set">
      <xsl:for-each select="msxsl:node-set($query6)/*/*//query[@materialize='1' and not(ancestor::query[@materialize='2'])]">
        <xsl:element name="query">
          <xsl:attribute name="name">
            <xsl:value-of select="@name"/>
          </xsl:attribute>
          <xsl:copy-of select="withparams"/>
        </xsl:element>
      </xsl:for-each>
    </xsl:variable>

    
    
    <xsl:for-each select="msxsl:node-set($mat-queries-set)/*">
      <xsl:variable name="query-name1" select="@name"/>
      
      <xsl:if test="not(preceding-sibling::*[@name=$query-name1])">
        <xsl:variable name="params" select="withparams"/>
        <xsl:for-each select="$root/queries/query[@name=$query-name1]">
        
            <xsl:call-template name="main-materialized">
              <xsl:with-param name = "params" select = "$params"/>
            </xsl:call-template>
         
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each>
-->
    <xsl:copy-of select="$query6"/>


    <!--
    
 

     <xsl:copy-of select="$query"/>
    <xsl:call-template name = "functions">
      <xsl:with-param name="query" select="$query"/>
    </xsl:call-template>
    -->
  </xsl:template>
  <xsl:template name="loop">
    
    
    <xsl:variable name="query4">
        <xsl:call-template name = "copy-this-columns"/>
    </xsl:variable>

    <xsl:variable name="query4-1">
      <xsl:for-each  select = "msxsl:node-set($query4)/*">
        <xsl:call-template name = "copy4"/>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="query4-2">
      <xsl:for-each  select = "msxsl:node-set($query4-1)/*">
        <xsl:call-template name = "copy-add-path"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="query5">
      <xsl:for-each  select = "msxsl:node-set($query4-2)/*">
        <xsl:call-template name = "copy5"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="query6">
      <xsl:for-each  select = "msxsl:node-set($query5)/*">
        <xsl:call-template name = "copy6"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="query">
      <xsl:for-each  select = "msxsl:node-set($query6)/*">
        <xsl:call-template name = "copy"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test=".//query[not(select) and not(query)]">
        <xsl:for-each  select = "msxsl:node-set($query)/*">
          <xsl:call-template name = "loop"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$query"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- this-columns-->
  <xsl:template name="copy-this-columns">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:choose>
          <xsl:when test="name()='column' and @table='this'">
            <xsl:call-template name="this-column"></xsl:call-template>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="{name()}">
              <xsl:call-template name = "copy-attr"/>
              <xsl:for-each  select = "child::node()">
                <xsl:call-template name = "copy-this-columns"/>
              </xsl:for-each>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

 
  <!-- /this-columns-->

  <!-- step2-->
  
  
  <!-- add path-->
  <xsl:template name="copy-add-path">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "add-path"/>
          <xsl:for-each  select = "child::node()">
            <xsl:call-template name = "copy-add-path"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="add-path">
    <xsl:if test="name()='query'">
      <xsl:attribute name="path">
        <xsl:for-each  select = "ancestor-or-self::query[not(position()=last())]">
          <xsl:sort order="descending"/>
          <xsl:value-of select="'/'"/>
          <xsl:value-of select="@as"/>
        </xsl:for-each>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  <!-- /add path-->
  
  <!-- step2-->

  <xsl:template name="copy2">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "self-keys"/>
          <xsl:for-each  select = "child::node()">
            <xsl:call-template name = "copy2"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="self-keys">
    <xsl:if test="(name()='column'or name()='const')  and @as">
      <xsl:variable name="col" select="."/>
      <xsl:choose>
        <xsl:when test="@group=1">
          <xsl:attribute name="key">1</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="(name(../../from/*[@as=$col/@table])='table'  or  name(../../..)='query') and position()=1">
              <xsl:attribute name="key">1</xsl:attribute>
            </xsl:when>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  <!-- /step2-->




  <!-- step3-->
  <xsl:template name="copy3">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "source-key"/>
          <xsl:for-each  select = "child::node()[not(name()='keys')]">
            <xsl:call-template name = "copy3"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="source-key">
    <xsl:if test="name(..)='select' and not(../*[@key=1])">
      <xsl:variable name="key-info">
        <xsl:call-template name = "key-info"/>
      </xsl:variable>
      <xsl:if test="msxsl:node-set($key-info)/*/@key=1">
        <xsl:attribute name="key">
          <xsl:value-of select="msxsl:node-set($key-info)/*/@key"/>
        </xsl:attribute>
        <xsl:attribute name="keypath">
          <xsl:value-of select="msxsl:node-set($key-info)/*/@table"/>
          <xsl:value-of select="'.'"/>
          <xsl:value-of select="msxsl:node-set($key-info)/*/@column"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template name="key-info">
    <xsl:variable name="table" select="@table"/>
    <xsl:variable name="column" select="@column"/>
    <xsl:variable name="sorce-query" select="../../from/query[@as=$table and select] | ../../from/query[@as=$table]/query[position()=1]"/>
    <xsl:choose>
      <xsl:when test="$sorce-query/*">
        <xsl:for-each  select = "$sorce-query/select/*[@as=$column]">
          <xsl:choose>
            <xsl:when test="@key=1">
              <xsl:element name="key-info">
                <xsl:attribute name="key">
                  <xsl:value-of select="@key"/>
                </xsl:attribute>
                <xsl:attribute name="table">
                  <xsl:value-of select="$sorce-query/@path"/>
                </xsl:attribute>
                <xsl:attribute name="column">
                  <xsl:value-of select="@as"/>
                </xsl:attribute>
              </xsl:element>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name = "key-info"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="key-info">
          <xsl:attribute name="key">
            <xsl:value-of select="0"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- /step3-->

  <!-- add-types-->
  <xsl:template name="copy-add-types">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "add-type"/>
          <xsl:for-each  select = "child::node()">
            <xsl:call-template name = "copy-add-types"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>




  <xsl:template name="add-type">
    <xsl:if test="name()='column' and name(..)='select' and  not(@type)">
      <xsl:variable name="type">
        <xsl:call-template name="get-type"/>
      </xsl:variable>
      <xsl:if test="not($type='')">
        <xsl:attribute name="type">
          <xsl:value-of select="$type"/>
        </xsl:attribute>
      </xsl:if>
     
      <xsl:variable name="title">
        <xsl:call-template name="get-title"/>
      </xsl:variable>
      <xsl:if test="not($title='')">
        <xsl:attribute name="title">
          <xsl:value-of select="$title"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="get-type">
    <xsl:variable name="table" select="@table"/>
    <xsl:variable name="column" select="@column"/>
    <xsl:variable name="src-query" select="../../from/query[@as=$table and select] | ../../from/query[@as=$table]/query[position()=1]"/>
    <xsl:variable name="src-column" select="$src-query/select/*[@as=$column]"/>
    <xsl:choose>
      <xsl:when test="$src-column/@type">
          <xsl:value-of select="$src-column/@type"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="name($src-column)='column'">
          <xsl:for-each select="$src-column">
            <xsl:call-template name="get-type"/>
          </xsl:for-each>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-title">

    <xsl:choose>
      <xsl:when test="@title">
        <xsl:value-of select="@title"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="table" select="@table"/>
        <xsl:variable name="column" select="@column"/>
        <xsl:variable name="src-query" select="../../from/query[@as=$table and select] | ../../from/query[@as=$table]/query[position()=1]"/>
        <xsl:variable name="src-column" select="$src-query/select/*[@as=$column]"/>
        <xsl:choose>
          <xsl:when test="$src-column/@title">
            <xsl:value-of select="$src-column/@title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if test="name($src-column)='column'">
              <xsl:for-each select="$src-column">
                <xsl:call-template name="get-title"/>
              </xsl:for-each>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
    
    
    
  </xsl:template>



  <!-- /add-types-->



  <!-- add-col-into-->
  <xsl:template name="copy-add-col-into">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "add-col-into"/>
          <xsl:for-each  select = "child::node()">
            <xsl:call-template name = "copy-add-col-into"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>




 <!-- <xsl:template name="add-col-into">
    <xsl:if test="name(..)='select' and  (../../@materialize='1' or ../../@materialize='2')">
      <xsl:variable name="type" select="@type"/>
      <xsl:if test="not($type='')">
        <xsl:attribute name="into">
          <xsl:choose>
            <xsl:when test="@as='sparentid'">
              <xsl:value-of select="'sparentid'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="$type='number'">
                  <xsl:value-of select="'n'"/>
                </xsl:when>
                <xsl:when test="$type='string'">
                  <xsl:value-of select="'s'"/>
                </xsl:when>
                <xsl:when test="$type='date'">
                  <xsl:value-of select="'d'"/>
                </xsl:when>
              </xsl:choose>
              <xsl:value-of select="count(preceding-sibling::*[@type=$type])+1"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
        
        
      </xsl:if>
    </xsl:if>
  </xsl:template>-->


  <xsl:template name="add-col-into">
    <xsl:if test="name(..)='select' and  ../../@materialize">
      <xsl:attribute name="into">
        <xsl:choose>
          <xsl:when test="../../@materialize='1'">
            <xsl:variable name="type" select="@type"/>
            <xsl:if test="not($type='')">
              <xsl:choose>
                <xsl:when test="@as='sparentid'">
                  <xsl:value-of select="'sparentid'"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:choose>
                    <xsl:when test="$type='number'">
                      <xsl:value-of select="'n'"/>
                    </xsl:when>
                    <xsl:when test="$type='string'">
                      <xsl:value-of select="'s'"/>
                    </xsl:when>
                    <xsl:when test="$type='date'">
                      <xsl:value-of select="'d'"/>
                    </xsl:when>
                  </xsl:choose>
                  <xsl:value-of select="count(preceding-sibling::*[@type=$type])+1"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:when>
          <xsl:otherwise>
             <xsl:value-of select="''"/>
             
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>



  <!-- /add-col-into-->


  <!-- check-keys-->
  <xsl:template name="copy-check-keys">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "check-keys"/>
          <xsl:for-each  select = "child::node()[not(name()='keys')]">
            <xsl:call-template name = "copy-check-keys"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>




  <xsl:template name="check-keys">
    <xsl:if test="name()='select' and  not(./*[@key=1  and not(@keypath)])">
      <xsl:variable name="keys">
        <xsl:for-each  select = "..">
          <xsl:call-template name = "get-keys">
            <xsl:with-param name="table-pname" select="from/query[not(@join)]/@as"></xsl:with-param>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:variable>
      <xsl:variable name="select" select="."/>
      <xsl:for-each  select = "msxsl:node-set($keys)/*">
        <xsl:variable name="keypath" select="@keypath"/>
        <xsl:if test="not($select/*[@keypath=$keypath])">
          <xsl:element name="text">
            <xsl:text>Внимание! Отсутствует ключ:</xsl:text>
            <xsl:value-of select="@keypath"/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>


  <xsl:template name="get-keys">
    <xsl:param name="table-pname"></xsl:param>

    <xsl:for-each  select = "from/query[not(@join) or @join='cross'] | from/query/query[position()=1]">
      <xsl:variable name="query" select="."/>
      <xsl:choose>
        <xsl:when test="select/*[@key=1 and not(@keypath)]">
          <xsl:for-each  select = "select/*[@key=1]">
            <xsl:element name="column">
              <xsl:attribute name="keypath">
                <xsl:value-of select="$query/@path"/>
                <xsl:value-of select="'.'"/>
                <xsl:value-of select="@as"/>
              </xsl:attribute>
            </xsl:element>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name = "get-keys"></xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <!-- /check-keys-->


  <!-- step4-->
  <xsl:template name="copy4">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "used"/>
          <xsl:for-each  select = "child::node()">
            <xsl:call-template name = "copy4"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="used">
    <xsl:if test="name(..)='select'">

      <!-- <xsl:variable name="used1">
          <xsl:call-template name = "get-used"/>
      </xsl:variable>
     
      <xsl:if test="@column='kod_dog' and ../../from/*[1]/@name='sr_facopl' and $used1='1'">
        <xsl:variable name="used2">
          <xsl:call-template name = "get-used"/>
        </xsl:variable>
      </xsl:if> -->
      
      <xsl:attribute name="used">
        <xsl:variable name="used">
          <xsl:call-template name = "get-used"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when  test="$used='0'">
            <xsl:value-of select="0"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-used">
    <xsl:variable name="col" select="ancestor-or-self::*[@as][1]"/>
    <xsl:variable name="qry" select="$col/../.."/>
    <xsl:variable name="qry-as" select="$qry/ancestor-or-self::query[@as][1]/@as"/>
    <xsl:variable name="col-name" select="$col[1]/@as"/>
    <xsl:variable name="parent-qry" select="$qry/ancestor::query[select][1]"/>

    <xsl:choose>
      <xsl:when test="@fixed='1'">
        <xsl:value-of select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$parent-qry/@name">
            <xsl:variable name="col-use-in-join" select="$qry/call//column[@table=$qry/@as and @column=$col-name] | $parent-qry/from/query[not(@as=$qry/@as)]/call//column[@table=$qry/@as and @column=$col-name] | $parent-qry/where//column[@table=$qry/@as and @column=$col-name] "/>
            <xsl:choose>
              <xsl:when test="$col-use-in-join/@column">
                <xsl:value-of select="1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="$col-name='date_isp'">
                  <xsl:value-of select="''"/>
                </xsl:if>
                <!-- <xsl:variable name="col-use-other" select="$parent-qry/*[not(name()='from')]//column[@table=$qry/@as and @column=$col-name]"/> -->
                <xsl:variable name="col-use-other" select="$parent-qry/*[not(name()='from')]//column[@table=$qry-as and @column=$col-name]"/>
                <xsl:choose>
                  <xsl:when test="$col-use-other/@column">
                    <xsl:for-each  select = "$col-use-other">
                      <xsl:call-template name = "get-used"/>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="0"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="1"/>
          </xsl:otherwise>
        </xsl:choose>

      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  <!-- /step4-->
  
  
  <!-- step5-->
  <xsl:template name="copy5">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "used-tbl"/>
          <xsl:for-each  select = "child::node()">
            <xsl:call-template name = "copy5"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="used-tbl">
    <xsl:if test="name(..)='from' and name()='query'">
      <xsl:attribute name="used">
        <xsl:call-template name = "get-used-tbl">
          <xsl:with-param name="call-stack">
            <xsl:element name="stack-item">
              <xsl:attribute name="path">
                <xsl:value-of select="@path"/>
              </xsl:attribute>
            </xsl:element>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-used-tbl">
    <xsl:param name="call-stack"></xsl:param>
    <xsl:variable name="qry" select="."/>
    <xsl:variable name="parent-qry" select="$qry/ancestor::query[select][1]"/>
    <xsl:choose>
      <xsl:when test="$parent-qry/@name">
        <xsl:variable name="use" select="$parent-qry[select//column[@table=$qry/@as and ancestor-or-self::*[@as and name(..)='select'][1]/@used=1]] | $parent-qry/from/query[(not(@as=$qry/@as)) and call//column[@table=$qry/@as]] |  $parent-qry[$qry[@join='inner' or @join='cross']] | $parent-qry[where//column[@table=$qry/@as]]"/>
        <xsl:choose>
          <xsl:when test="$use/@name">
            <xsl:for-each  select = "$use">
              <xsl:variable name="path" select="@path"/>
              <xsl:if test="not(msxsl:node-set($call-stack)/*[@path=$path])">
                <xsl:call-template name = "get-used-tbl">
                  <xsl:with-param name="call-stack">
                    <xsl:copy-of select="msxsl:node-set($call-stack)/*"/>
                    <xsl:element name="stack-item">
                      <xsl:attribute name="path">
                        <xsl:value-of select="$path"/>
                      </xsl:attribute>
                    </xsl:element>
                  </xsl:with-param>
                </xsl:call-template>
              </xsl:if>
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
  <!-- /step5-->
  
  <!-- step6-->
  <xsl:template name="copy6">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:for-each  select = "child::node()[not(@used=0) or name()='column']">
            <xsl:call-template name = "copy6"/>
          </xsl:for-each>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- /step6-->
  
  
  
  <xsl:template name="copy">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:call-template name = "self-keys"/>
          <xsl:for-each  select = "child::node()">
            <xsl:choose>
              <xsl:when test="name()='query'  and not(select) and not(query)">
                <xsl:call-template name = "query-full"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name = "copy"/>
              </xsl:otherwise>
            </xsl:choose>
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

 
  <xsl:template name="functions">
    <xsl:param name="query"/>
    <xsl:element name="functions">
      <xsl:for-each  select = "//functions/function">
        <xsl:variable name="functionName" select="@name"/>
        <xsl:if test="msxsl:node-set($query)/*//call[@function=$functionName]">
          <xsl:copy-of select="."></xsl:copy-of>
        </xsl:if>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>
  

  <xsl:template name="query">
    <xsl:if test="@materialize">
      <xsl:attribute name="materialize">
        <xsl:value-of select="@materialize"/>
      </xsl:attribute>
      <xsl:copy-of select="withparams"/>
    </xsl:if>
    <xsl:if test="@order">
      <xsl:attribute name="order">
        <xsl:value-of select="@order"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@hint">
      <xsl:attribute name="hint">
        <xsl:value-of select="@hint"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="union">
        <xsl:call-template name = "union-query"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name = "non-union-query"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="union-query">
    <xsl:for-each  select = "union/*">
      <xsl:call-template name = "source-main"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="columns">
    <xsl:for-each  select = "select/*">
      <xsl:call-template name = "expression"/>
    </xsl:for-each>
  </xsl:template>
  
  
  <xsl:template name="non-union-query">
    <xsl:element name="select">
      <xsl:call-template name = "columns"/>
    </xsl:element>
    <xsl:element name="from">
      <xsl:for-each  select = "from/*">
        <xsl:call-template name = "source"/>
      </xsl:for-each>
    </xsl:element>
    <xsl:for-each  select = "where/*">
      <xsl:element name="where">
        <xsl:call-template name = "expression"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>
 




  <xsl:template name="source">
    <xsl:choose>
      <xsl:when test="name() = 'table'">
        <xsl:call-template name = "table"/>
      </xsl:when>
      <xsl:when test="name() = 'usepart'">
        <xsl:call-template name = "usepart"/>
      </xsl:when>
      <xsl:when test="name() = 'query'">
        <xsl:call-template name = "source-main"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="table-as">
    <xsl:variable name="as" select="ancestor-or-self::query[@as][1]"/>
    <xsl:if test="$as/@as">
      <xsl:attribute name="as">
        <xsl:value-of select="$as/@as"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="source-main">
    <xsl:element name="query">
      <xsl:if test="@materialize">
        <xsl:attribute name="materialize">
          <xsl:value-of select="@materialize"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="name">
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      
      <xsl:call-template name = "table-as"/>
      <xsl:if test="@join">
        <xsl:attribute name="join">
          <xsl:value-of select="@join"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="name(..)='union' or @union">
        <xsl:attribute name="union">
          <xsl:value-of select="1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:copy-of select="withparams"/>
      <!--<xsl:call-template name = "source-query"/>-->

      <xsl:choose>
        <xsl:when test="select">
          <xsl:call-template name = "query"/>
        </xsl:when>
      </xsl:choose>
      
      <xsl:for-each  select = "*">
        <xsl:call-template name = "expression"/>
      </xsl:for-each>

     
    </xsl:element>
  </xsl:template>

  <xsl:template name="query-full">
    <xsl:param name="owner"/>
    <xsl:element name="query">
      <xsl:attribute name="name">
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <xsl:if test="@materialize">
        <xsl:attribute name="materialize">
          <xsl:value-of select="@materialize"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name = "table-as"/>
      <xsl:if test="@join">
        <xsl:attribute name="join">
          <xsl:value-of select="@join"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="name(..)='union' or @union">
        <xsl:attribute name="union">
          <xsl:value-of select="1"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name = "get-query"/>
      <xsl:if test="@materialize">
        <xsl:copy-of select="withparams"/>
      </xsl:if>
      <xsl:for-each  select = "*">
        <xsl:call-template name = "expression"/>
      </xsl:for-each>
    </xsl:element>
  </xsl:template>


  
  
  

  <xsl:template name="table">
    <xsl:element name="table">
      <xsl:attribute name="name">
        <xsl:value-of select="@name"/>
      </xsl:attribute>
      <xsl:attribute name="as">
        <xsl:value-of select="@as"/>
      </xsl:attribute>
      <xsl:if test="@join">
        <xsl:attribute name="join">
          <xsl:value-of select="@join"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@view=1">
        <xsl:attribute name="view">
          <xsl:value-of select="@view"/>
        </xsl:attribute>
        <xsl:variable name="name" select="@name"/>
        <xsl:for-each  select = "$root/views/view[@name=$name]">
          <xsl:element name="text">
            <xsl:text>(</xsl:text>
            <xsl:value-of select="text()"/>
            <xsl:text>)</xsl:text>
          </xsl:element>
        </xsl:for-each>
      </xsl:if>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="expression">
    <xsl:param name="parent-columns"/>
    
    <xsl:choose>
      <xsl:when test="name() = 'column'">
        <xsl:call-template name = "column"/>
      </xsl:when>
      <xsl:when test="name() = 'call'">
        <xsl:call-template name = "call"/>
      </xsl:when>
      <xsl:when test="name() = 'const'">
        <xsl:call-template name = "const"/>
      </xsl:when>
      <xsl:when test="name() = 'usepart'">
        <xsl:call-template name = "usepart"/>
      </xsl:when>
      <xsl:when test="name() = 'query'">
        <xsl:call-template name = "source"/>
      </xsl:when>
      <xsl:when test="name() = 'group'">
        <xsl:copy-of select="."/>
      </xsl:when>
      <xsl:when test="name() = 'union'">
        <xsl:variable name="v1">
          <xsl:for-each  select = ".">
            <xsl:call-template name = "apply-part"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:for-each  select = "msxsl:node-set($v1)/*/*">
          <xsl:call-template name = "source-main"/>
        </xsl:for-each>
      </xsl:when>
      
    </xsl:choose>
  </xsl:template>

  <xsl:template name="usepart">
    <xsl:variable name="partId" select="@part"/>
   
   
    <!--
     <xsl:variable name="partId2" select="@fromparam"/>
    <xsl:if test="$partId='test5'">
      <xsl:value-of select="''"/>
    </xsl:if>-->

    <xsl:if test="./content">
      <xsl:value-of select="''"/>
    </xsl:if>
    
    <xsl:variable name="usepart" select="."/>
    <xsl:variable name="part" select="$root/parts/part[@id=$partId] | ./content/*"/>
   
    <xsl:variable name="fact-params1">
      <xsl:element name="fact-params">
        <xsl:copy-of select="$usepart/*[not(name()='content')]"/>
      </xsl:element>
    </xsl:variable>
    <xsl:variable name="fact-params">
        <xsl:for-each  select = "msxsl:node-set($fact-params1)/*">
          <xsl:call-template name = "apply-part"/>
        </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="v">
      <xsl:choose>
        <xsl:when test="$part/params/param[@multiple=1]">
          <xsl:for-each  select = "msxsl:node-set($fact-params)/*/*[1]/*">
            <xsl:variable name="index" select="position()"/>
            <xsl:variable name="params">
                <xsl:copy-of select="."/>
                <xsl:for-each  select = "msxsl:node-set($fact-params)/*/*[not(position()=1)]">
                  <xsl:copy-of select="."/>
                </xsl:for-each>
            </xsl:variable>
            <xsl:for-each  select = "$part">
              <xsl:call-template name = "apply-params-to-part">
                <xsl:with-param name = "params" select = "$params"/>
                <xsl:with-param name="index" select="$index"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each  select = "$part">
            <xsl:call-template name = "apply-params-to-part">
              <xsl:with-param name = "params" select = "msxsl:node-set($fact-params)/*"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="v1">
      <xsl:choose>
        <xsl:when test="not(@as)">
          <xsl:copy-of select="$v"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="as" select="@as"/>
          <xsl:for-each  select = "msxsl:node-set($v)/*">
            <xsl:element name="{name()}">
              <xsl:call-template name="copy-attr"/>
              <xsl:attribute name="as">
                <xsl:value-of select="$as"/>
              </xsl:attribute>
              <xsl:for-each  select = "child::node()">
                <xsl:copy-of select="."/>
              </xsl:for-each>
            </xsl:element>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:for-each  select = "msxsl:node-set($v1)/*">
      <xsl:call-template name = "expression"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="apply-params-to-part">
    <xsl:param name="params" />
    <xsl:param name="index"/>
    <xsl:variable name="formal-params" select="./params"/>
    
    <xsl:choose>
      <xsl:when test="$formal-params/*">
        <xsl:for-each select="./*[not(name()='params')]">
          <xsl:call-template name="apply-params-next">
            <xsl:with-param name = "params" select = "$params"/>
            <xsl:with-param name = "formal-params" select = "$formal-params"/>
            <xsl:with-param name ="index" select="$index"/>
          </xsl:call-template>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="./*"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="apply-params">
    <xsl:param name="params" />
   
    <xsl:variable name="formal-params" select="./params"/>
    
    <xsl:choose>
      <xsl:when test="$formal-params/*">
        <xsl:call-template name="apply-params-next">
          <xsl:with-param name = "params" select = "$params"/>
          <xsl:with-param name = "formal-params" select = "$formal-params"/>
         
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  
  <xsl:template name="apply-params-next">
    <xsl:param name="params" />
    <xsl:param name="formal-params" />
    <xsl:param name="index" />
    <xsl:choose>
      <xsl:when test="name()='useparam'">
        <xsl:call-template name = "apply-param-to-node">
          <xsl:with-param name = "params" select = "$params"/>
          <xsl:with-param name = "formal-params" select = "$formal-params"/>
          <xsl:with-param name = "index" select = "$index"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{name()}">
          
       
          <xsl:for-each  select = "@*">
            <xsl:attribute name="{name()}">
              <xsl:call-template name = "apply-param-to-attr">
                <xsl:with-param name = "params" select = "$params"/>
                <xsl:with-param name = "formal-params" select = "$formal-params"/>
              </xsl:call-template>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:for-each  select = "child::node()">
            <xsl:choose>
              <xsl:when test="name()">
                <xsl:call-template name = "apply-params-next">
                  <xsl:with-param name = "params" select = "$params"/>
                  <xsl:with-param name = "formal-params" select = "$formal-params"/>
                  <xsl:with-param name = "index" select = "$index"/>
                </xsl:call-template>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="."/>
              </xsl:otherwise>
             </xsl:choose>
          </xsl:for-each>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  
  
  
  <xsl:template name="apply-param-to-node">
    <xsl:param name="params" />
    <xsl:param name="formal-params" />
    <xsl:param name="index" />
    <xsl:variable name="par-full-name" select="@name"/>
    <xsl:variable name="par-full-index" select="substring-before(substring-after($par-full-name,'['),']')"/>

    <xsl:variable name="par-name">
      <xsl:choose>
        <xsl:when test="$par-full-index=''">
          <xsl:value-of select="$par-full-name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before($par-full-name,'[')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    
    
    
    <xsl:variable name="formal-param" select="$formal-params/*[@name=$par-name]"/>
    <xsl:variable name="formal-param-pos"  select="count($formal-param/preceding-sibling::*) + 1"/>
    <xsl:variable name="param1"  select="msxsl:node-set($params)/*[position()=$formal-param-pos]"/>

    <xsl:variable name="param">
      <xsl:choose>
        <xsl:when test="$par-full-index=''">
          <xsl:copy-of  select="$param1"/>
        </xsl:when>
        <xsl:when test="contains($par-full-index,'@')">
          <xsl:variable name="attr-name">
            <xsl:value-of select="substring-after($par-full-index,'@')"/>
          </xsl:variable>
          <xsl:variable name="attr-val">
            <xsl:value-of select ="msxsl:node-set($param1)/@*[name()=$attr-name]"/>
          </xsl:variable>
          <xsl:element name="const">
            <xsl:value-of select ="$attr-val"/>
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          
          <xsl:variable name="par-beg-index1">
            <xsl:choose>
              <xsl:when test="contains($par-full-index,'..')">
                <xsl:value-of select="substring-before($par-full-index,'..')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$par-full-index"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="par-beg-index">
            <xsl:choose>
              <xsl:when test="$par-beg-index1=':index'">
                <xsl:value-of select="$index"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$par-beg-index1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="par-end-index1">
            <xsl:choose>
              <xsl:when test="contains($par-full-index,'..')">
                <xsl:value-of select="substring-after($par-full-index,'..')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$par-full-index"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          <xsl:variable name="par-end-index">
            <xsl:choose>
              <xsl:when test="$par-end-index1=':index'">
                <xsl:value-of select="$index"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$par-end-index1"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

          
          <xsl:variable name="param2">
            <xsl:choose>
              <xsl:when test="$param1">
                <xsl:copy-of select="$param1"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:copy-of select="$formal-param/*"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>

         <!-- <xsl:element name="nodes">  -->
            <xsl:for-each select="msxsl:node-set($param2)/*">
              <xsl:if test="(position()&gt;=$par-beg-index and (position()&lt;=$par-end-index or $par-end-index='*')) or ($par-beg-index='*' and (position()&gt;=$par-end-index  or position()=last()))">
                <xsl:copy-of select="."/>
              </xsl:if>
            </xsl:for-each>
         <!-- </xsl:element>-->
      
          
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>


    <xsl:choose>
      <xsl:when test="not(name(msxsl:node-set($param)/*)='')">
        <xsl:copy-of select="$param"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$formal-param/node()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="apply-param-to-attr">
    <xsl:param name="params" />
    <xsl:param name="formal-params" />
    <xsl:variable name="var-pr" select="substring(.,1,1)"/>
    <xsl:choose>
      <xsl:when test="$var-pr=':'">
        <xsl:variable name="par-full-name" select="substring(.,2,string-length(.)-1)"/>
        <xsl:variable name="par-child-name" select="substring-after($par-full-name,'.')"/>
        <xsl:variable name="par-name">
          <xsl:choose>
            <xsl:when test="$par-child-name=''">
              <xsl:value-of select="$par-full-name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="substring-before($par-full-name,'.')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:variable name="formal-param" select="$formal-params/*[@name=$par-name]"/>
        
        <xsl:variable name="formal-param-pos"  select="count($formal-param/preceding-sibling::*) + 1"/>

        <xsl:variable name="param">
          <xsl:choose>
            <xsl:when test="$par-child-name=''">
              <xsl:copy-of select="msxsl:node-set($params)/*[position()=$formal-param-pos]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="attr">
                
                <xsl:value-of select="msxsl:node-set($params)/*[position()=$formal-param-pos]/@*[name()=$par-child-name]"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>        
        
       
        <xsl:choose>
          
          <xsl:when test="msxsl:node-set($param)/node()">
           <!-- <xsl:variable name="ttt" select="$formal-params/node()"/>-->
            <xsl:value-of select="$param"/>
          </xsl:when>
          <xsl:otherwise>
          <!--  <xsl:variable name="ttt">
               <xsl:value-of select="$formal-params/node()"/>
            
            </xsl:variable>
                <xsl:if test="$ttt='2013.01'">
                  <xsl:value-of select="''"/>
                </xsl:if>-->
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="const">
    <xsl:element name="const">
      <xsl:call-template name = "as"/>
      <xsl:if test="@type">
        <xsl:attribute name="type">
          <xsl:value-of select="@type"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@title">
        <xsl:attribute name="title">
          <xsl:value-of select="@title"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:call-template name = "group"/>
      <xsl:choose>
        <xsl:when test="not(text)">
       
          <xsl:element name="text">
            <xsl:value-of select=".//text()"/>
          </xsl:element>
       
        </xsl:when>
        <xsl:otherwise>
          <xsl:copy-of select="child::node()"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
    
  </xsl:template>

  <xsl:template name="column">
    <xsl:choose>
      <xsl:when test="@column='*'">
        <xsl:call-template name = "all-columns"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name = "single-column"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-col-source">
    <xsl:variable name="queryName" select="@name"/>
    <xsl:variable name="source-query" select="self::node()[select or union or query] | $root/queries/query[@name=$queryName]"/>
    <xsl:choose>
      <xsl:when test="$source-query/union or $source-query/query">
        <xsl:for-each select = "$source-query/union/*[1] | $source-query/query[1]">
          <xsl:call-template name = "get-col-source"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="$source-query"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <xsl:template name="all-columns">
    <xsl:variable name="queryPname" select="@table"/>
    <xsl:variable name="params" select="../../from/query[@as=$queryPname]/withparams"/>
    <xsl:variable name="col-source">
      <xsl:for-each select = "../../from/query[@as=$queryPname]">
        <xsl:call-template name = "get-col-source"/>
      </xsl:for-each>
    </xsl:variable>


    <xsl:variable name="col-source-processed1">
      <xsl:for-each  select = "msxsl:node-set($col-source)/*">
        <xsl:call-template name = "apply-params">
          <xsl:with-param name = "params" select = "$params"/>
        </xsl:call-template>
      </xsl:for-each>
    </xsl:variable>
    
    <xsl:variable name="col-source-processed">
      <xsl:for-each  select = "msxsl:node-set($col-source-processed1)/*">
        <xsl:call-template name = "apply-part"/>
      </xsl:for-each>
    </xsl:variable>

    

   
    
    <xsl:variable name="columns">
      <xsl:element name="select">
        <!--<xsl:variable name="query">
          <xsl:for-each select = "$root/queries/query[@name=$queryName]">
            <xsl:call-template name = "query-full"/>
          </xsl:for-each>
        </xsl:variable> -->
        <xsl:for-each select = "msxsl:node-set($col-source-processed)/*">
          <xsl:call-template name = "columns"/>
        </xsl:for-each>
      </xsl:element>
    </xsl:variable>
    <xsl:for-each select = "msxsl:node-set($columns)/select/*">
      <xsl:element name="column">
        <xsl:attribute name="table">
          <xsl:value-of select="$queryPname"/>
        </xsl:attribute>
        <xsl:attribute name="column"> 
          <xsl:call-template name = "column-pname-val"/>
        </xsl:attribute>
       
        <xsl:call-template name = "column-pname"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>



  <xsl:template name="this-column">
    <xsl:variable name="col-name" select ="@column"/>
    <xsl:variable name="query-sub" select ="(ancestor::query | ancestor::select | ancestor::where)[position()=last()]"/>
    <xsl:variable name="query" select ="$query-sub/ancestor::query[select and position()=1]"/>
    <xsl:if test="$query/select">
      <xsl:variable name="source-col3" select ="'qwr'"/>
    </xsl:if>
    <xsl:variable name="source-col1" select ="$query/select/*[@as=$col-name]"/>
    <xsl:variable name="source-col">
      <xsl:choose>
        <xsl:when test="$source-col1 and not(ancestor::withparams)">
          <xsl:for-each select="$source-col1">
            <xsl:call-template name = "expression"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="source-col2" select ="$query/select/*[@column=$col-name]"/>
          <xsl:choose>
            <xsl:when test="$source-col2 and not(ancestor::withparams)">
              <xsl:for-each select="$source-col2">
                <xsl:call-template name = "expression"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="column">
                <xsl:attribute name="table">
                  <xsl:value-of select="@table"/>
                </xsl:attribute>
                <xsl:attribute name="column">
                  <xsl:value-of select="@column"/>
                </xsl:attribute>
                <xsl:call-template name = "column-pname"/>
                <xsl:call-template name = "group"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy-of select ="$source-col"/>
  </xsl:template>

  <!--<xsl:template name="this-column">
    <xsl:variable name="col-name" select ="@column"/>    
    <xsl:variable name="query" select ="ancestor-or-self::query[select and position()=1]"/>
    <xsl:if test="$query/select">
      <xsl:variable name="source-col3" select ="'qwr'"/>
    </xsl:if>
    <xsl:variable name="source-col1" select ="$query/select/*[@as=$col-name]"/>
    <xsl:variable name="source-col">
      <xsl:choose>
        <xsl:when test="$source-col1">
          <xsl:for-each select="$source-col1">
            <xsl:call-template name = "expression"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="source-col2" select ="$query/select/*[@column=$col-name]"/>
          <xsl:choose>
            <xsl:when test="$source-col2">
              <xsl:for-each select="$source-col2">
                <xsl:call-template name = "expression"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="column">
                <xsl:attribute name="table">
                  <xsl:value-of select="@table"/>
                </xsl:attribute>
                <xsl:attribute name="column">
                  <xsl:value-of select="@column"/>
                </xsl:attribute>
                <xsl:call-template name = "column-pname"/>
                <xsl:call-template name = "group"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy-of select ="$source-col"/>
  </xsl:template>-->
    
  <xsl:template name="single-column">
    <!--<xsl:choose>
      <xsl:when test="@table='this'">
        <xsl:call-template name="this-column"/>
      </xsl:when>
      <xsl:otherwise>-->
          <xsl:element name="column">
            <xsl:attribute name="table">
              <xsl:value-of select="@table"/>
            </xsl:attribute>
            <xsl:attribute name="column">
              <xsl:value-of select="@column"/>
            </xsl:attribute>
            <xsl:if test="@nvl">
              <xsl:attribute name="nvl">
                <xsl:value-of select="@nvl"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:if test="@fixed">
              <xsl:attribute name="fixed">
                <xsl:value-of select="@fixed"/>
              </xsl:attribute>
            </xsl:if>
            <xsl:call-template name = "column-pname"/>
            <xsl:call-template name = "group"/>
          </xsl:element>
     <!-- </xsl:otherwise>
    </xsl:choose>-->
  </xsl:template>

  <xsl:template name="group">
    <xsl:if test="@group">
      <xsl:attribute name="group">
        <xsl:value-of select="@group"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="as">
    <xsl:if test="@as">
      <xsl:attribute name="as">
        <xsl:value-of select="@as"/>
      </xsl:attribute>
      
    </xsl:if>
      
   
  </xsl:template>

  <xsl:template name="column-pname">
      <xsl:if test="name(..) = 'select' or @as">
          <xsl:attribute name="as">
            <xsl:call-template name = "column-pname-val"/>
          </xsl:attribute>
      </xsl:if>
      <xsl:if test="@type">
        <xsl:attribute name="type">
          <xsl:value-of select="@type"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@title">
        <xsl:attribute name="title">
          <xsl:value-of select="@title"/>
        </xsl:attribute>
      </xsl:if>
  </xsl:template>

  <xsl:template name="column-pname-val">
        <xsl:choose>
          <xsl:when test="@as">
            <xsl:value-of select="@as"/>
          </xsl:when>
          <xsl:when test="not(@as)">
            <xsl:value-of select="@column"/>
          </xsl:when>
        </xsl:choose>
  </xsl:template>


  <xsl:template name="copy-apply-part">
    <xsl:choose>
      <xsl:when test="name()">
        <xsl:choose>
          <xsl:when test="name() = 'usepart'">
            <xsl:call-template name = "usepart"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:element name="{name()}">
              <xsl:call-template name = "copy-attr"/>
              <xsl:for-each  select = "child::node()">
                <xsl:call-template name = "copy-apply-part"/>
              </xsl:for-each>
            </xsl:element>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="apply-part">
    <xsl:choose>
      <xsl:when test=".//usepart">
        <xsl:variable name="elem">
          <xsl:call-template name="copy-apply-part"/>
        </xsl:variable>
        <xsl:for-each select="msxsl:node-set($elem)/*">
          <xsl:call-template name="apply-part"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template name="call">
    <xsl:for-each select=".">
      <xsl:element name="call">
        <xsl:attribute name="function">
          <xsl:value-of select="@function"/>
        </xsl:attribute>
        <xsl:if test="@type">
          <xsl:attribute name="type">
            <xsl:value-of select="@type"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:if test="@title">
          <xsl:attribute name="title">
            <xsl:value-of select="@title"/>
          </xsl:attribute>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="name(..) = 'select'">
            <xsl:attribute name="as">
              <xsl:value-of select="@as"/>
            </xsl:attribute>
          </xsl:when>
          <xsl:otherwise>
            <xsl:if  test="@as and name(..)=''">
              <xsl:attribute name="as">
                <xsl:value-of select="@as"/>
              </xsl:attribute>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name = "group"/>
        <!--
      <xsl:for-each  select = "*">
        <xsl:call-template name = "expression"/>
      </xsl:for-each>
      -->
        <xsl:call-template name = "function"/>
      </xsl:element>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="function">
    <xsl:variable name="functionName" select="@function"/>
    <xsl:variable name="function" select="$root/functions/function[@name=$functionName]"></xsl:variable>
    <xsl:attribute name="pth">
      <xsl:choose>
        <xsl:when test="@pth">
            <xsl:value-of select="@pth"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$function/@pth"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:if test="$function/@type and not(@type)">
      <xsl:attribute name="type">
        <xsl:value-of select="$function/@type"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:variable name="text1" select="$function/child::node()[1]/self::text()"/>
    <xsl:if test="not($text1)=''">
      <xsl:element name="text">
        <xsl:value-of select="' '"/>
        <xsl:value-of select="normalize-space($text1)"/>
        <xsl:value-of select="' '"/>
      </xsl:element>
    </xsl:if>
    <xsl:for-each  select = "*[not(name()='text')]">
      <xsl:variable name="indx" select="position()"/>
      <xsl:variable name="param" select="$function/*[position()=$indx] | $function/*[position()=last()]"/>
      <xsl:variable name="text2" select="$param[1]/child::node()[1]/self::text()"/>
      <xsl:if test="not($text2)=''">
        <xsl:element name="text">
          <xsl:value-of select="' '"/>
          <xsl:value-of select="normalize-space($text2)"/>
          <xsl:value-of select="' '"/>
        </xsl:element>
      </xsl:if>
      <xsl:call-template name = "expression"/>
      <xsl:variable name="text3" select="$param[1]/child::node()[position()=last()]/self::text()"/>
      <!--<xsl:variable name="text3" select="$function/*[position()=$indx]/child::node()[position()=last()]/self::text()"/> -->
      <xsl:if test="not($text3)=''">
        <xsl:element name="text">
          <xsl:value-of select="' '"/>
          <xsl:value-of select="normalize-space($text3)"/>
          <xsl:value-of select="' '"/>
        </xsl:element>
      </xsl:if>
    </xsl:for-each>
    <xsl:variable name="text4" select="$function/child::node()[position()=last()]/self::text()"/>
    <xsl:if test="not($text4)=''">
      <xsl:element name="text">
        <xsl:value-of select="' '"/>
        <xsl:value-of select="normalize-space($text4)"/>
        <xsl:value-of select="' '"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>