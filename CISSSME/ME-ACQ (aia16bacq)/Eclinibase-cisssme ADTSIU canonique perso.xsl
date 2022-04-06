<!--
     Date        User      Description / commentaires
     ++++++++++  ++++++++  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
     2022-04-01  lest0500  Version initiale
-->

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
        *******************************************************************************************
        Redefinir le template "perso"
        *******************************************************************************************
   -->

   <xsl:template name="perso">
      <perso>
         <xsl:call-template name="SoftLab"/>
      </perso>
   </xsl:template>

   <!-- 
        *******************************************************************************************
        Redefinir le template "SoftLab".
        
        Regles de filtrage:
        
        installation
        ============
        Traiter seulement les messages dont qui sont generes par les installations suivantes:
          * 51229102 - Hopital Hotel-Dieu de Sorel (HDS)
          * 51229193 - Hopital Honore-Mercier (HHM)
          * 51229011 - Hopital Pierre-Boucher (HPB) 
        
        typeMessage
        ===========
        Considerer seulement certains types de messages.
        
        classePatient
        =============
        Pour les messages qui contiennent un segment PV1, traiter seulement les classes de patient
        qui concernent:
          * E: urgence
          * I: hospitalisation
        *******************************************************************************************
   -->
   
   <xsl:template name="SoftLab">
      <systeme nom="SoftLab">
         <reglesFiltrage>
            <xsl:call-template name="SoftLab.reglesFiltrage.installation"/>
            <xsl:call-template name="SoftLab.reglesFiltrage.typeMessage"/>
            <xsl:call-template name="SoftLab.reglesFiltrage.classePatient"/>
         </reglesFiltrage>
      </systeme>
   </xsl:template>
   
   <xsl:template name="SoftLab.reglesFiltrage.installation">
      <installation>
         <xsl:value-of select="matches(//PID.4[1]/PID.4.6, '51229102|51229193|51229011')"/>
      </installation>
   </xsl:template>

   <xsl:template name="SoftLab.reglesFiltrage.typeMessage">
      <typeMessage>
         <xsl:value-of select="matches(//MSH.9.2, 'A01|A02|A03|A04|A05|A08|A12|A13|A23|A28|A29|A31|A45|A48')"/>
      </typeMessage>
   </xsl:template>

   <xsl:template name="SoftLab.reglesFiltrage.classePatient">
      <classePatient>
         <xsl:choose>
            <xsl:when test="not(matches(//PV1.2.1, 'E|I'))">false</xsl:when>
            <xsl:otherwise>true</xsl:otherwise>
         </xsl:choose>
      </classePatient>
   </xsl:template>
   
   
   <!-- 
        *******************************************************************************************
        Modèle de suvi "inputDonnee4"
        *******************************************************************************************
   -->
   <!-- 
   <xsl:template name="modeleSuivi.inputDonnee4">
      <xsl:element name="inputDonnee4">
         [PV1_2_1=<xsl:value-of select="//PV1.2.1"/>]
         [PID.4.6=<xsl:value-of select="//PID.4[1]/PID.4.6"/>]
      </xsl:element>
   </xsl:template>
   -->
   
</xsl:stylesheet>