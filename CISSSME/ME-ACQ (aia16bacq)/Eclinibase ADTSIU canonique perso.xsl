
   <xsl:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions"
                   xmlns:functx="http://www.functx.com"
                   xmlns:util="http://whatever"
                   xmlns:xs="http://www.w3.org/2001/XMLSchema"
                   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                   exclude-result-prefixes="#all"
                   version="3.0">
      <xsl:import href="Eclinibase ADTSIU canonique.xsl"/>
      <xsl:output encoding="UTF-8"
                  indent="yes"
                  method="xml"
                  omit-xml-declaration="yes"
                  version="1.0"/>
   <!-- 
      *********************************************************************************************
      Import des feuilles de styles (perso)
      *********************************************************************************************
   -->
      <xsl:import href="Eclinibase ADTSIU canonique perso.softlab.xsl"/>
   <!-- 
      *********************************************************************************************
      Redefinir le template "perso"
      *********************************************************************************************
   -->
      <xsl:template name="perso">
         <xsl:element name="perso">
            <xsl:element name="systemes">
               <xsl:call-template name="SoftLab"/>
            </xsl:element>
         </xsl:element>
      </xsl:template>
   <!-- 
      *********************************************************************************************
      Modèle de suvi "inputDonnee4"
      *********************************************************************************************
   -->
      <!--
         <xsl:template name="modeleSuivi.inputDonnee4">
            <xsl:element name="inputDonnee4"> [PV1_2_1=<xsl:value-of select="//PV1.2.1"/>] [PID.4.6=<xsl:value-of select="//PID.4[1]/PID.4.6"/>]
      </xsl:element>
         </xsl:template>
      -->
      <!--
         <xsl:template name="modeleSuivi.inputDonnee4">
            <xsl:element name="inputDonnee4">
               <xsl:for-each select="$persoCISSS//reglesFiltrage">
                  <xsl:choose>
                     <xsl:when test="./criteres/*[text() != '']">
                        <xsl:value-of select="concat('(',nom/text(), ': ', ./criteres/*[text() != ''][1], ') ')"/>
                     </xsl:when>
                  </xsl:choose>
               </xsl:for-each>
            </xsl:element>
         </xsl:template>
      -->
   </xsl:stylesheet>
