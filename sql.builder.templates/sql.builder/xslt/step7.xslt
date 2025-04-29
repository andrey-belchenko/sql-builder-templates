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

        <xsl:variable name="special-type">
          <xsl:choose>
            <xsl:when test="(../@materialize='1' or ../@materialize='2') and name()='select' and not(name(../..)='root')">
              <xsl:value-of select="'1'"/>
            </xsl:when>
            <xsl:when test="(../@materialize='1' or ../@materialize='2') and name()='call'  and not(name(../..)='root')">
              <xsl:value-of select="'0'"/>
            </xsl:when>
            <xsl:when test="(../@materialize='1' or ../@materialize='2') and not(name(../..)='root')">
              <xsl:value-of select="'2'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="'0'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <!-- <xsl:if test="../@materialize='1'">
          <xsl:variable name="is-special" select="ancestor-or-self::query[not(name(..)='root') and @materialize='1'][1]/@materialize"/>
        </xsl:if> -->


        <xsl:choose>
          <xsl:when test="$special-type='0'">
            <xsl:if test="not(name()='order')">
              <xsl:element name="{name()}">
                <xsl:call-template name = "copy-attr"/>
                <xsl:call-template name = "text-bef"/>
                <xsl:for-each  select = "child::node()">
                  <xsl:call-template name = "main"/>
                </xsl:for-each>
                <xsl:call-template name = "text-aft"/>
              </xsl:element>
            </xsl:if>
          </xsl:when>
          <xsl:when test="$special-type='1'">
            <xsl:element name="text">
              <xsl:text>select sid,sparentid,rn</xsl:text>
              <xsl:for-each select="*">
                <xsl:value-of select="','"/>
                <xsl:variable name="qry-name" select="../../@name"/>
                <xsl:variable name="col-name" select="@as"/>
                <xsl:value-of select="//query[@name=$qry-name and @materialize='1']/select/*[@as=$col-name]/@into"/>
                <!--<xsl:value-of select="@into"/>-->
                <xsl:value-of select="' as '"/>
                <xsl:value-of select="@as"/>
              </xsl:for-each>
              <xsl:text> from rr_temp where skod='</xsl:text>
              <xsl:value-of select="../@name"/>
              <xsl:text>'</xsl:text>
            </xsl:element>
          </xsl:when>
        </xsl:choose>

        <!--<xsl:variable name="is-special" select="ancestor-or-self::query[not(name(..)='root') and @materialize='1'][1]/@materialize"/>
        <xsl:element name="{name()}">
          <xsl:call-template name = "copy-attr"/>
          <xsl:if test="not($is-special='1')">
            <xsl:call-template name = "text-bef"/>
            <xsl:for-each  select = "child::node()">
              <xsl:call-template name = "main"/>
            </xsl:for-each>
            <xsl:call-template name = "text-aft"/>
          </xsl:if>
          <xsl:if test="$is-special='1'">
            <xsl:element name="text">
              <xsl:text>(</xsl:text>
              <xsl:text>)</xsl:text>
            </xsl:element>
          </xsl:if>
        </xsl:element>-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="text-bef">
    <xsl:variable name="text">
      <xsl:call-template name="text-content-bef"/>
    </xsl:variable>
    <xsl:if test="not($text='')">
      <xsl:element name="text">
        <xsl:value-of select="$text"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>


  <xsl:template name="text-aft">
    <xsl:variable name="text">
      <xsl:call-template name="text-content-aft"/>
    </xsl:variable>
    <xsl:if test="not($text='')">
      <xsl:element name="text">
        <xsl:value-of select="$text"/>
      </xsl:element>
    </xsl:if>
  </xsl:template>

  <xsl:template name="text-content-bef">
    <!--<xsl:if test="@optional">
      <xsl:text>{</xsl:text>
    </xsl:if>-->
    <xsl:if test="self::query[name(..)='with']">
      <xsl:value-of select="@as"/>
      <xsl:text> as </xsl:text>
    </xsl:if>
    <xsl:if test="self::query[insert]">
      <xsl:text>begin</xsl:text>
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:text>for rec in (</xsl:text>
    </xsl:if>



    <xsl:if test="self::query[@union=1] and not(position()=1)">
      <xsl:text> union all </xsl:text>
    </xsl:if>
    <xsl:if test="self::query[@union=2] and not(position()=1)">
      <xsl:text> union </xsl:text>
    </xsl:if>
    <xsl:choose>

      <xsl:when test="self::query[not(name(..)='root')]">
        <xsl:if test="@mp">
          <xsl:text> ( </xsl:text>
        </xsl:if>
        <xsl:if test="@nvl">
          <xsl:text>nvl(</xsl:text>
        </xsl:if>
       <xsl:if test="@nullif">
          <xsl:text>nullif(</xsl:text>
        </xsl:if>
        <xsl:if test="@join and preceding-sibling::*">
          <xsl:value-of select="' '"/>
          <xsl:choose>
            <xsl:when test="@join='left inner'">
              <xsl:text> inner </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@join"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> join </xsl:text>
        </xsl:if>
        <xsl:text>(</xsl:text>
      </xsl:when>

      <xsl:when test="self::table">
        <xsl:if test="@join and preceding-sibling::*">
          <xsl:value-of select="' '"/>
          <xsl:choose>
            <xsl:when test="@join='left inner'">
              <xsl:text> inner </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@join"/>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:text> join </xsl:text>
        </xsl:if>
        <xsl:if test="not(@view=1)">
          <xsl:value-of select="@name"/>
        </xsl:if>

      </xsl:when>

      <xsl:when test="self::select">
        <xsl:choose>
          <xsl:when test="../@materialize='1' and  name(../..)='root'">
            <xsl:text> select '</xsl:text>
            <xsl:value-of select="../@name"/>
            <xsl:text>' as skod, </xsl:text>


            <xsl:text>'</xsl:text>
            <xsl:value-of select="../@name"/>
            <!--не совсем корректно, имя может повторяться path и as тоже не подошли-->
            <xsl:text>|'</xsl:text>

            <xsl:for-each select ="*[@key='1']">
              <xsl:text>|| '#' || mtr.</xsl:text>
              <xsl:value-of select="@as"/>
            </xsl:for-each>
            <xsl:text> as sid,rownum as rn,  </xsl:text>
            <xsl:text> mtr.* from ( select </xsl:text>
            <!--<xsl:choose>
              <xsl:when test="*[@group]">
                <xsl:text> select max(rownum) as rn, </xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text> select rownum as rn, </xsl:text>
              </xsl:otherwise>
            </xsl:choose>-->

          </xsl:when>
          <xsl:otherwise>
            <xsl:text> select </xsl:text>
            <!--<xsl:if test="not(../@materialize='1') and  name(../..)='root'">
              <xsl:text> rownum as rn, </xsl:text>
            </xsl:if>-->
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="../@hint">
          <xsl:text> /*+ </xsl:text>
          <xsl:value-of select="../@hint"/>
          <xsl:text>*/ </xsl:text>
        </xsl:if>

      </xsl:when>
      <xsl:when test="self::from">
        <xsl:text> from </xsl:text>
      </xsl:when>
      <xsl:when test="self::with">
        <xsl:text> with </xsl:text>
      </xsl:when>
      <xsl:when test="self::where">
        <xsl:text> where </xsl:text>
      </xsl:when>
      <xsl:when test="self::connect">
        <xsl:text> connect by nocycle </xsl:text>
      </xsl:when>

      <xsl:when test="self::start">

        <xsl:text> start with </xsl:text>
      </xsl:when>

      <xsl:when test="self::group">

        <xsl:choose>
          <xsl:when test="@gset='first'">
            <xsl:text> group by grouping sets ((</xsl:text>
          </xsl:when>
          <xsl:when test="@gset">
            <xsl:text> (</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text> group by </xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="self::having">
        <xsl:text> having </xsl:text>
      </xsl:when>
      <xsl:when test="self::dimension">
        <xsl:text> model dimension by (</xsl:text>
      </xsl:when>
      <xsl:when test="self::measures">
        <xsl:text>measures (</xsl:text>
      </xsl:when>
      <!--<xsl:when test="self::insert">
        <xsl:text> insert into </xsl:text>
        <xsl:value-of select="@into"/>
        <xsl:text> ( </xsl:text>
      </xsl:when>-->

      <xsl:when test="self::column and not(name(..)='insert')">
        <xsl:if test="@group and not(@group=1) and  (ancestor::select or ancestor::having)">
          <xsl:call-template name="arg-func-beg"/>
        </xsl:if>
        <xsl:if test="@mp">
          <xsl:text>(</xsl:text>
        </xsl:if>
        <xsl:if test="@nvl">
          <xsl:text>nvl(</xsl:text>
        </xsl:if>
        <xsl:if test="@nullif">
          <xsl:text>nullif(</xsl:text>
        </xsl:if>
        <xsl:if test="@prior">
          <xsl:text> prior </xsl:text>
        </xsl:if>
        <xsl:if test="not(@table='') and @table">
          <xsl:value-of select="@table"/>
          <xsl:text>.</xsl:text>
        </xsl:if>
        <xsl:value-of select="@column"/>
        <xsl:if test="@nvl">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="@nvl"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
        <xsl:if test="@nullif">
          <xsl:text>,</xsl:text>
          <xsl:value-of select="@nullif"/>
          <xsl:text>)</xsl:text>
        </xsl:if>
        <xsl:if test="@mp">
          <xsl:text>*power(10,</xsl:text>
          <xsl:value-of select="@mp"/>
          <xsl:text>))</xsl:text>
        </xsl:if>
        <xsl:if test="@group and not(@group=1) and (ancestor::select or ancestor::having)">
          <xsl:call-template name="arg-func-end"/>
        </xsl:if>
      </xsl:when>
      <!--<xsl:when test="self::column and name(..)='insert'">
        <xsl:value-of select="@column"/>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>-</xsl:text>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@info"/>
      </xsl:when> -->

    </xsl:choose>
    <xsl:if test="self::call[name(..)='query' or name(..)='table']">
      <xsl:if test="../@materialize='1' and name(../..)='root'">
        <xsl:text> ) mtr </xsl:text>
      </xsl:if>
      <xsl:if test="../@order and not(../@materialize='2')">
        <xsl:element name="order">
          <xsl:text> order by </xsl:text>
          <xsl:value-of select="../@order"/>
        </xsl:element>
      </xsl:if>
      <xsl:value-of select="' '"/>
      <xsl:if test="name(..)='query'">
        <xsl:text>) </xsl:text>
      </xsl:if>
      <xsl:value-of select="' '"/>
      <xsl:value-of select="../@as"/>
      <xsl:text> on </xsl:text>
    </xsl:if>

    <xsl:if test="self::call">
      <xsl:if test="@mp">
        <xsl:text>(</xsl:text>
      </xsl:if>
      <xsl:if test="@nvl">
        <xsl:text>nvl(</xsl:text>
      </xsl:if>
      <xsl:if test="@nullif">
        <xsl:text>nullif(</xsl:text>
      </xsl:if>
    </xsl:if>

    <xsl:if test="self::call[@group and not(@group=1)]">
      <xsl:call-template name="arg-func-beg"/>
    </xsl:if>
    <xsl:if test="self::call[name(..)='call']">
      <xsl:if test="not(@pth=0)">
        <xsl:text>(</xsl:text>
      </xsl:if>
    </xsl:if>

  </xsl:template>

  <xsl:template name="arg-func-beg">
    <xsl:choose>
      <xsl:when test="@group='sumnvl'">
        <xsl:value-of select="'sum(nvl'"/>
      </xsl:when>
      <xsl:when test="@group='count_dist'">
        <xsl:text> count </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="@group"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>(</xsl:text>
    <xsl:choose>
      <xsl:when test="@group='count_dist'">
        <xsl:text> distinct </xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="arg-func-end">
    <xsl:choose>
      <xsl:when test="@group='sumnvl'">
        <xsl:value-of select="',0)'"/>
      </xsl:when>
    </xsl:choose>
    <xsl:text>)</xsl:text>
  </xsl:template>


  <xsl:template name="text-content-aft">


    <xsl:if test="self::query  and name(..)='root'">
      <xsl:if test="@order">
        <xsl:element name="order">
          <xsl:choose>
            <xsl:when test="./connect">
              <xsl:text> order siblings by </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> order  by </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="@order"/>
        </xsl:element>
      </xsl:if>

    </xsl:if>

    <xsl:if test="self::query  and name(..)='root' and @materialize='1'">
      <xsl:text> ) mtr </xsl:text>
    </xsl:if>



    <xsl:if test="self::query[not(call) and not(name(..)='root') ]">

      <xsl:if test="@order">
        <xsl:element name="order">
          <xsl:choose>
            <xsl:when test="./connect">
              <xsl:text> order siblings by </xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> order  by </xsl:text>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:value-of select="@order"/>
        </xsl:element>
      </xsl:if>

      <xsl:text>)</xsl:text>
      <xsl:if test="@nvl">
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@nvl"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="@nullif">
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@nullif"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="@mp">
        <xsl:text>*power(10,</xsl:text>
        <xsl:value-of select="@mp"/>
        <xsl:text>))</xsl:text>
      </xsl:if>
      <xsl:if test="name(..)='from'">
        <xsl:value-of select="' '"/>
        <xsl:value-of select="@as"/>
      </xsl:if>
    </xsl:if>
    <xsl:if test="self::table[not(call)]">
      <xsl:value-of select="' '"/>
      <xsl:value-of select="@as"/>
    </xsl:if>
    <!--<xsl:if test="self::insert">
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:text> ) </xsl:text>
    </xsl:if>-->


    <xsl:if test="self::call[@group and not(@group=1)]">

      <xsl:call-template name="arg-func-end"/>

    </xsl:if>

    <xsl:if test="self::call[name(..)='call']">
      <xsl:if test="not(@pth=0)">
        <xsl:text>)</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="self::call">
      <xsl:if test="@nvl">
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@nvl"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="@nullif">
        <xsl:text>,</xsl:text>
        <xsl:value-of select="@nullif"/>
        <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="@mp">
        <xsl:text>*power(10,</xsl:text>
        <xsl:value-of select="@mp"/>
        <xsl:text>))</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:if test="self::*[@as and (name(..)='select' or name(..)='dimension' or name(..)='measures')]">
      <xsl:text> as</xsl:text>
      <xsl:value-of select="' '"/>
      <xsl:value-of select="@as"/>
    </xsl:if>
    <xsl:if test="self::*[name(..)='select' or name(..)='group' or name(..)='dimension' or name(..)='measures']">
      <xsl:if test="not(position()=last())">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:if test="@title">
        <xsl:text>/*</xsl:text>
        <xsl:value-of select="@title"/>
        <xsl:text>*/</xsl:text>
      </xsl:if>
      <xsl:if test="@type">
        <xsl:text>/*</xsl:text>
        <xsl:value-of select="@type"/>
        <xsl:text>*/</xsl:text>
      </xsl:if>
      <xsl:if test="@key='1'">
        <xsl:text>/*</xsl:text>
        <xsl:text>key</xsl:text>
        <xsl:text>*/</xsl:text>
      </xsl:if>
    </xsl:if>





    <xsl:if test="self::query[insert]">
      <xsl:text>) loop</xsl:text>
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:text> insert into </xsl:text>
      <xsl:value-of select="insert/@into"/>
      <xsl:text> ( </xsl:text>
      <xsl:for-each select="insert/column">
        <xsl:value-of select="@column"/>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>-</xsl:text>
        <xsl:text>-</xsl:text>
        <xsl:value-of select="@info"/>
        <xsl:text>&#13;&#10;</xsl:text>
      </xsl:for-each>
      <xsl:text> ) </xsl:text>
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:text>values (</xsl:text>
      <xsl:for-each select="insert/column">
        <xsl:text>rec.</xsl:text>
        <xsl:value-of select="@info"/>
        <xsl:if test="not(position()=last())">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>&#13;&#10;</xsl:text>
      </xsl:for-each>
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:text> ); </xsl:text>
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:text>end loop;</xsl:text>
      <xsl:text>&#13;&#10;</xsl:text>
      <xsl:text>end</xsl:text>
    </xsl:if>
    <!--<xsl:if test="@optional">
      <xsl:text>{</xsl:text>
    </xsl:if>-->
    <xsl:choose>

      <xsl:when test="self::dimension">
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="self::measures">
        <xsl:text>)</xsl:text>
      </xsl:when>
      <xsl:when test="self::group">
        <xsl:choose>
          <xsl:when test="@gset='last'">
            <xsl:text> )) </xsl:text>
          </xsl:when>
          <xsl:when test="@gset">
            <xsl:text>) ,</xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:when>

    </xsl:choose>


    <xsl:if test="self::query[name(..)='with'] and not(position()=last())">

      <xsl:text> , </xsl:text>
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