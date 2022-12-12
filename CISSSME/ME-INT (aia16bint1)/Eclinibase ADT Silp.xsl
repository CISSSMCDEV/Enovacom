<?xml version="1.0" encoding="UTF-8"?>
<!--
   No. Date       User     Description / commentaires
  +++++++ ++++++++++ ++++++++ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  1.00.03 2022-08-09 lajrob   Ajustement sur fichier dcml avec la notion de sousInstallation
                              Ajout du paramètre persoInclureNk1Pere
                              Correction du segment MRG.1 ... devait être MRG.1.1
  1.00.02 2022-03-08 lajrob   Ajustement sur le traitement des A28 pour que ça puisse fonctionner même lors des chargements
                              Ajustement de certain template pour avoir les sous-template
  1.00.01 2021-02-01 TC       Modification du prenom lors d un patient inconnu - Ajout des residents dans PV1.7.1 et PV1.17.1 - Modification des numeros de telephones PID.13 et PID.14
  1.00.00 2021-11-04 TC       Version initiale                       
-->
<xsl:stylesheet version="3.0"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:exsl="http://exslt.org/common"
   xmlns:xp="http://www.w3.org/2005/xpath-functions"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:functx="http://www.functx.com"
   xmlns:util="http://whatever"
   extension-element-prefixes="exsl"
   exclude-result-prefixes="#all">
   <!-- Inclusion des Templates  -->
   <xsl:include href="util-Templates.xsl"/>
   <!-- format de sortie (par defaut XML) -->
   <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" omit-xml-declaration="yes"/>
   <!-- options, format de sortie -->
   <xsl:strip-space elements="*"/>
   <!-- ************************************************************************************************************************* -->
   <!--                                               Déclaration des paramètres                                                  -->
   <!-- ************************************************************************************************************************* -->
   <xsl:param name="varParam1"/>
   <xsl:param name="varParam2"/>
   <xsl:param name="varParam3"/>
   <xsl:param name="varParam4"/>
   <xsl:param name="varParam5"/>
   <xsl:param name="varParam6"/>
   <xsl:param name="varParam7"/>
   <xsl:param name="varParam8"/>
   <xsl:param name="varParam9"/>
   <!-- ************************************************************************************************************************* -->
   <!--                                          Déclaration des variables perso                                                  -->
   <!-- ************************************************************************************************************************* -->
   <!--balise xml à définir dans le perso pour identifier le dcml, établissement et installation-->
   <xsl:variable name="persoDcmlXml"><dcml/></xsl:variable>
   <!--Ind si le #civiere est plus grand que 3 car. [TRUE|FALSE] alors mettre PV1.3.3 dans PV1.3.2 -->
   <xsl:variable name="persoIsCiviereGT3d">FALSE</xsl:variable>   
   <!--Liste des prénoms qui devront être préfixé par prefixeDossier+noDossier(alpha) pour les rendre unique provincialement. 
       Les spaces ont été retirés du prénom pour la recherche dans la liste-->
   <xsl:variable name="persoListPrenomInc">BB~BBI~BBII~BBIII~BBIV~BBV~INCONNU~INCONNUE~</xsl:variable>
   <!--Inclure le NK1 père, par défaut, ne pas l'inclure-->
   <xsl:variable name="persoInclureNk1Pere">False</xsl:variable>
   <!-- ************************************************************************************************************************* -->
   <!--                                     Déclaration des variables de travail                                                  -->
   <!-- ************************************************************************************************************************* -->
   <xsl:variable name="dcml" select="exsl:node-set($persoDcmlXml)"/>
   <xsl:variable name="mshEventCode" select="/HL7/MSH/MSH.9.2"/>
   <xsl:variable name="noInstallation" select="/HL7/ZVN/ZVN.1.1"/>
   <!-- ************************************************************************************************************************* -->
   <!--                                                        Principal                                                          -->
   <!-- ************************************************************************************************************************* -->
   <xsl:template match="/">
      <xsl:element name="MSG_LIST">
         <xsl:choose>
            <!-- Si evntCode = A31 alors construire autant de msg qu'il y a d'installation défini dans le fichier xml de config du silp -->
            <!-- Si evntCode = A28, en mode "live", il va y avoir un seul pid.4
                                    en mode "chargement", il faut générer autant de A28 selon persoDcmlXml-->
            <xsl:when test="contains('A28 A31', $mshEventCode)">
               <xsl:for-each select="/HL7/PID/PID.4">
                  <xsl:variable name="inst-pid" select="PID.4.6"/>
                  <xsl:choose>
                     <xsl:when test="PID.4.5 = 'PRI' and $dcml/dcml/etablissement/installation[@msss = $inst-pid] != ''">
                        <xsl:variable name="position" select="position()" as="xs:integer"/>
                        <xsl:call-template name="HL7">
                           <xsl:with-param name="position" select="$position"/>
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:when test="PID.4.5 = 'PRI' and $dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-pid] != ''">
                        <xsl:variable name="position" select="position()" as="xs:integer"/>
                        <xsl:call-template name="HL7">
                           <xsl:with-param name="position" select="$position"/>
                        </xsl:call-template>
                     </xsl:when>
                     <xsl:otherwise/>
                  </xsl:choose>
               </xsl:for-each>
            </xsl:when>
            <!-- Si eventCode = A17 et que l'installation est défini dans le silp alors construire génère 2 msg A08 -->
            <xsl:when test="$mshEventCode = 'A17' and $dcml/dcml/etablissement/installation[@msss = $noInstallation] != ''">
               <xsl:call-template name="HL7">
                  <xsl:with-param name="position" select="1"/>
               </xsl:call-template>
               <xsl:call-template name="HL7">
                  <xsl:with-param name="position" select="2"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="$mshEventCode = 'A17' and $dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation] != ''">
               <xsl:call-template name="HL7">
                  <xsl:with-param name="position" select="1"/>
               </xsl:call-template>
               <xsl:call-template name="HL7">
                  <xsl:with-param name="position" select="2"/>
               </xsl:call-template>
            </xsl:when>
            <!-- Si evntCode accepté par SILP et que l'installation est défini dans le silp alors construire 1 msg -->
            <xsl:when test="contains('A01 A02 A03 A04 A05 A08 A12 A13 A23 A24 A37 A38 A48', $mshEventCode) and $dcml/dcml/etablissement/installation[@msss = $noInstallation] != ''">
               <xsl:call-template name="HL7">
                  <xsl:with-param name="position" select="1"/>
               </xsl:call-template>
            </xsl:when>
            <xsl:when test="contains('A01 A02 A03 A04 A05 A08 A12 A13 A23 A24 A37 A38 A48', $mshEventCode) and $dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation] != ''">
               <xsl:call-template name="HL7">
                  <xsl:with-param name="position" select="1"/>
               </xsl:call-template>
            </xsl:when>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!-- ************************************************************************************************************************* -->
   <!--                                                       Segment HL7                                                         -->
   <!-- ************************************************************************************************************************* -->
   <xsl:template name="HL7">
      <xsl:param name="position"/>
      <xsl:element name="MSG_ELEMENT">
         <xsl:element name="HL7">
            <xsl:call-template name="MSH">
               <xsl:with-param name="position" select="$position"/>
            </xsl:call-template>
            <xsl:call-template name="EVN"/>
            <xsl:choose>
               <xsl:when test="contains('A28 A31', $mshEventCode)">
                  <xsl:for-each select="/HL7/PID[1]">
                     <xsl:call-template name="PID">
                        <xsl:with-param name="posMRN" select="$position"/>
                     </xsl:call-template>
                  </xsl:for-each>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:for-each select="/HL7/PID[$position]">
                     <xsl:call-template name="PID">
                        <xsl:with-param name="posMRN" select="0"/>
                     </xsl:call-template>
                  </xsl:for-each>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="NK1"/>
            <xsl:call-template name="PV1"/>
            <xsl:call-template name="MRG"/>
         </xsl:element>
      </xsl:element>
   </xsl:template>
   <!-- ************************************************************************************************************************* -->
   <!--                                                       Segment MSH                                                         -->
   <!-- ************************************************************************************************************************* -->
   <xsl:template name="MSH">
      <xsl:param name="position"/>
      <xsl:element name="MSH">
         <xsl:call-template name="MSH.1"/>
         <xsl:call-template name="MSH.2"/>
         <xsl:call-template name="MSH.3"/>
         <xsl:call-template name="MSH.4">
            <xsl:with-param name="position" select="$position"/>
         </xsl:call-template>
         <xsl:call-template name="MSH.5"/>
         <xsl:call-template name="MSH.6"/>
         <xsl:call-template name="MSH.7"/>
         <xsl:call-template name="MSH.9"/>
         <xsl:call-template name="MSH.10">
            <xsl:with-param name="position" select="$position"/>
         </xsl:call-template>
         <xsl:call-template name="MSH.11"/>
         <xsl:call-template name="MSH.12"/>
      </xsl:element>
   </xsl:template>
   <!--Field Separator-->
   <xsl:template name="MSH.1">
      <xsl:element name="MSH.1.1">
         <xsl:value-of select="/HL7/MSH/MSH.1.1"/>
      </xsl:element>
   </xsl:template>
   <!--Encoding Characters -->
   <xsl:template name="MSH.2">
      <xsl:element name="MSH.2.1">
         <xsl:value-of select="/HL7/MSH/MSH.2.1"/>
      </xsl:element>
   </xsl:template>
   <!--Sending Application -->
   <xsl:template name="MSH.3">
      <xsl:call-template name="MSH.3.1"/>
      <xsl:call-template name="MSH.3.2"/>
      <xsl:call-template name="MSH.3.3"/>
   </xsl:template>
   <!--Namespace ID -->
   <xsl:template name="MSH.3.1">
      <xsl:element name="MSH.3.1">
         <xsl:value-of select="/HL7/MSH/MSH.3.1"/>
      </xsl:element>
   </xsl:template>
   <!--Universal ID -->
   <xsl:template name="MSH.3.2">
      <xsl:element name="MSH.3.2">
         <xsl:value-of select="'ISO'"/>
      </xsl:element>
   </xsl:template>
   <!--Universal ID Type -->
   <xsl:template name="MSH.3.3">
      <xsl:element name="MSH.3.3">
         <xsl:value-of select="'L'"/>
      </xsl:element>
   </xsl:template>
   <!--Sending Facility -->
   <xsl:template name="MSH.4">
      <xsl:param name="position"/>
      <xsl:choose>
         <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/@mne != ''">
            <!--Namespace ID -->
            <xsl:element name="MSH.4.1">
               <xsl:value-of select="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/@mne"/>
            </xsl:element>
            <!--Universal ID -->
            <xsl:element name="MSH.4.2">
               <xsl:value-of select="$noInstallation"/>
            </xsl:element>
            <!--Universal ID Type -->
            <xsl:element name="MSH.4.3">
               <xsl:value-of select="'L'"/>
            </xsl:element>
         </xsl:when>
         <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/@mne != ''">
            <!--Namespace ID -->
            <!--???? à tester-->
            <xsl:element name="MSH.4.1">
               <xsl:value-of select="$dcml/dcml/etablissement/installation[sousInstallation[@msss = $noInstallation]]/@mne"/>
            </xsl:element>
            <!--Universal ID -->
            <xsl:element name="MSH.4.2">
               <xsl:value-of select="$dcml/dcml/etablissement/installation[sousInstallation[@msss = $noInstallation]]/@msss"/>
            </xsl:element>
            <!--Universal ID Type -->
            <xsl:element name="MSH.4.3">
               <xsl:value-of select="'L'"/>
            </xsl:element>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="inst-pid" select="/HL7/PID/PID.4[$position]/PID.4.6"/>
            <!--Namespace ID -->
            <xsl:element name="MSH.4.1">
               <xsl:value-of select="$dcml/dcml/etablissement/installation[@msss = $inst-pid]/@mne"/>
            </xsl:element>
            <!--Universal ID -->
            <xsl:element name="MSH.4.2">
               <xsl:value-of select="$inst-pid"/>
            </xsl:element>
            <!--Universal ID Type -->
            <xsl:element name="MSH.4.3">
               <xsl:value-of select="'L'"/>
            </xsl:element>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--Receiving Application -->
   <xsl:template name="MSH.5">
      <xsl:call-template name="MSH.5.1"/>
      <xsl:call-template name="MSH.5.2"/>
      <xsl:call-template name="MSH.5.3"/>
   </xsl:template>
   <!--Namespace ID -->
   <xsl:template name="MSH.5.1">
      <xsl:element name="MSH.5.1">SOFTLAB</xsl:element>
   </xsl:template>
   <!--Universal ID -->
   <xsl:template name="MSH.5.2">
      <xsl:element name="MSH.5.2">2.16.124.10.101.1.60.1.2020.8.25.500.1</xsl:element>
   </xsl:template>
   <!--Universal ID Type -->
   <xsl:template name="MSH.5.3">
      <xsl:element name="MSH.5.3">ISO</xsl:element>
   </xsl:template>
   <!--Receiving Facility -->
   <xsl:template name="MSH.6">
      <xsl:call-template name="MSH.6.1"/>
      <xsl:call-template name="MSH.6.2"/>
      <xsl:call-template name="MSH.6.3"/>
   </xsl:template>
   <!--Namespace ID -->
   <xsl:template name="MSH.6.1">
      <xsl:element name="MSH.6.1">
         <xsl:choose>
            <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/@mne != ''">
               <xsl:value-of select="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/@mne"/>               
            </xsl:when>
            <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/@mne != ''">
               <xsl:value-of select="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/@mne"/>               
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>         
      </xsl:element>
   </xsl:template>
   <!--Universal ID -->
   <xsl:template name="MSH.6.2">
      <xsl:element name="MSH.6.2">
         <xsl:value-of select="$noInstallation"/>
      </xsl:element>
   </xsl:template>
   <!--Universal ID Type -->
   <xsl:template name="MSH.6.3">
      <xsl:element name="MSH.6.3">
         <xsl:value-of select="'L'"/>
      </xsl:element>
   </xsl:template>
   <!--Date/Time of Message -->
   <xsl:template name="MSH.7">
      <xsl:element name="MSH.7.1">
         <xsl:value-of select="/HL7/MSH/MSH.7.1"/>
      </xsl:element>
   </xsl:template>
   <!--Message Type et Event Code -->
   <xsl:template name="MSH.9">
      <xsl:call-template name="MSH.9.1"/>
      <xsl:call-template name="MSH.9.2"/>
   </xsl:template>
   <!--Message Type -->
   <xsl:template name="MSH.9.1">
      <xsl:element name="MSH.9.1">
         <xsl:value-of select="/HL7/MSH/MSH.9.1"/>
      </xsl:element>
   </xsl:template>
   <!--Event Code -->
   <xsl:template name="MSH.9.2">
      <xsl:element name="MSH.9.2">
         <xsl:choose>
            <xsl:when test="$mshEventCode = 'A01'">A01</xsl:when>
            <xsl:when test="$mshEventCode = 'A02'">A02</xsl:when>
            <xsl:when test="$mshEventCode = 'A03'">A03</xsl:when>
            <xsl:when test="$mshEventCode = 'A04'">A04</xsl:when>
            <xsl:when test="$mshEventCode = 'A05'">A05</xsl:when>
            <xsl:when test="$mshEventCode = 'A08'">A08</xsl:when>
            <xsl:when test="$mshEventCode = 'A12'">A02</xsl:when>
            <xsl:when test="$mshEventCode = 'A13'">A13</xsl:when>
            <xsl:when test="$mshEventCode = 'A17'">A02</xsl:when>
            <xsl:when test="$mshEventCode = 'A23'">A11</xsl:when>
            <xsl:when test="$mshEventCode = 'A24'">A08</xsl:when>
            <xsl:when test="$mshEventCode = 'A28'">A28</xsl:when>
            <xsl:when test="$mshEventCode = 'A31'">A31</xsl:when>
            <xsl:when test="$mshEventCode = 'A37'">A35</xsl:when>
            <xsl:when test="$mshEventCode = 'A38'">A11</xsl:when>
            <xsl:when test="$mshEventCode = 'A48'">A18</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$mshEventCode"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Message Control ID -->
   <xsl:template name="MSH.10">
      <xsl:param name="position"/>
      <xsl:element name="MSH.10.1">
         <xsl:choose>
            <xsl:when test="$position = 1">
               <xsl:value-of select="/HL7/MSH/MSH.10.1"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="concat(/HL7/MSH/MSH.10.1, '.', $position)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Processing ID -->
   <xsl:template name="MSH.11">
      <xsl:element name="MSH.11.1">
         <!--SCC ne veut que les code P ou D-->
         <xsl:choose>
            <xsl:when test="/HL7/MSH/MSH.11.1 = 'P'">P</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="'D'"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Version ID -->
   <xsl:template name="MSH.12">
      <xsl:element name="MSH.12.1">2.5.1</xsl:element>
   </xsl:template>
   <!-- ************************************************************************************************************************* -->
   <!--                                                       Segment EVN                                                         -->
   <!-- ************************************************************************************************************************* -->
   <xsl:template name="EVN">
      <xsl:element name="EVN">
         <xsl:call-template name="EVN.1"/>
         <xsl:call-template name="EVN.2"/>
      </xsl:element>
   </xsl:template>
   <!--Event Code = MSH.9.2 -->
   <xsl:template name="EVN.1">
      <xsl:element name="EVN.1.1">
         <xsl:choose>
            <xsl:when test="$mshEventCode = 'A01'">A01</xsl:when>
            <xsl:when test="$mshEventCode = 'A02'">A02</xsl:when>
            <xsl:when test="$mshEventCode = 'A03'">A03</xsl:when>
            <xsl:when test="$mshEventCode = 'A04'">A04</xsl:when>
            <xsl:when test="$mshEventCode = 'A05'">A05</xsl:when>
            <xsl:when test="$mshEventCode = 'A08'">A08</xsl:when>
            <xsl:when test="$mshEventCode = 'A12'">A02</xsl:when>
            <xsl:when test="$mshEventCode = 'A13'">A13</xsl:when>
            <xsl:when test="$mshEventCode = 'A17'">A02</xsl:when>
            <xsl:when test="$mshEventCode = 'A23'">A11</xsl:when>
            <xsl:when test="$mshEventCode = 'A24'">A08</xsl:when>
            <xsl:when test="$mshEventCode = 'A28'">A28</xsl:when>
            <xsl:when test="$mshEventCode = 'A31'">A31</xsl:when>
            <xsl:when test="$mshEventCode = 'A37'">A35</xsl:when>
            <xsl:when test="$mshEventCode = 'A38'">A11</xsl:when>
            <xsl:when test="$mshEventCode = 'A48'">A18</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$mshEventCode"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Event Date/Time -->
   <xsl:template name="EVN.2">
      <xsl:element name="EVN.2.1">
         <xsl:value-of select="/HL7/EVN/EVN.2.1"/>
      </xsl:element>
   </xsl:template>
   <!-- ************************************************************************************************************************* -->
   <!--                                                       Segment PID                                                         -->
   <!-- ************************************************************************************************************************* -->
   <xsl:template name="PID">
      <xsl:param name="posMRN"/>
      <xsl:element name="PID">
         <xsl:call-template name="PID.1"/>
         <xsl:call-template name="PID.3">
            <xsl:with-param name="posMRN" select="$posMRN"/>
         </xsl:call-template>
         <xsl:call-template name="PID.4"/>
         <xsl:call-template name="PID.5">
            <xsl:with-param name="posMRN" select="$posMRN"/>
         </xsl:call-template>
         <xsl:call-template name="PID.6"/>
         <xsl:call-template name="PID.7"/>
         <xsl:call-template name="PID.8"/>
         <xsl:call-template name="PID.11"/>
         <xsl:call-template name="PID.13"/>
         <xsl:call-template name="PID.14"/>
         <xsl:call-template name="PID.18"/>
         <xsl:call-template name="PID.19"/>
         <xsl:call-template name="PID.29"/>
         <xsl:call-template name="PID.30"/>
      </xsl:element>
   </xsl:template>
   <!--Set ID - PID-used only for Swap event A17 to separate PID#1   -->
   <xsl:template name="PID.1">
      <xsl:element name="PID.1.1">1</xsl:element>
   </xsl:template>
   <!--Patient Identifier  -->
   <xsl:template name="PID.3">
      <xsl:param name="posMRN"/>
      <xsl:choose>
         <xsl:when test="contains('A28 A31', $mshEventCode)">
            <xsl:for-each select="PID.4[$posMRN]">
               <xsl:call-template name="PID.3.1"/>
               <xsl:call-template name="PID.3.4"/>
               <xsl:call-template name="PID.3.6"/>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="PID.4[PID.4.6 = $noInstallation and PID.4.5 = 'PRI']">
               <xsl:call-template name="PID.3.1"/>
               <xsl:call-template name="PID.3.4"/>
               <xsl:call-template name="PID.3.6"/>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--Patient ID (Internal ID) -->
   <xsl:template name="PID.3.1">
      <xsl:variable name="inst-pid" select="PID.4.6"/>
      <xsl:element name="PID.3.1">
         <xsl:choose>
            <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text() != ''">
               <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text(), PID.4.1)"/>               
            </xsl:when>
            <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text() != ''">
               <xsl:value-of select="concat($dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text(), PID.4.1)"/>               
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>         
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.3.4">
      <!--Patient Id Assigning Authority -->
      <xsl:element name="PID.3.4"/>
   </xsl:template>
   <xsl:template name="PID.3.6">
      <!--Patient Id Assigning Facility -->
      <xsl:element name="PID.3.6">
         <xsl:value-of select="'&amp;&amp;L'"/>
      </xsl:element>
   </xsl:template>
   <!--Pièce étatique  -->
   <xsl:template name="PID.4">
      <xsl:call-template name="PID.4.1"/>
      <xsl:call-template name="PID.4.2"/>
   </xsl:template>
   <xsl:template name="PID.4.1">
      <xsl:element name="PID.4.1">
         <xsl:if test="contains('A01 A04 A08 A28 A31', $mshEventCode)">
            <xsl:choose>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'QUE'">""</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '79'">""</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'QC'">""</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'ALB'">CARTE_AB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'CBR'">CARTE_BC</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'IPE'">CARTE_PE</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'MAN'">CARTE_MB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NBR'">CARTE_NB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NEC'">CARTE_NS</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NUM'">CARTE_NU</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'ONT'">CARTE_ON</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'SAS'">CARTE_SK</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'TNE'">CARTE_NL</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'TNO'">CARTE_NT</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'YUK'">CARTE_YT</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '80'">CARTE_AB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '81'">CARTE_BC</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '82'">CARTE_PE</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '83'">CARTE_MB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '84'">CARTE_NB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '85'">CARTE_NS</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '93'">CARTE_NU</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '86'">CARTE_ON</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '87'">CARTE_SK</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '88'">CARTE_NL</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '89'">CARTE_NT</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = '90'">CARTE_YT</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'AB'">CARTE_AB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'BC'">CARTE_BC</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'CB'">CARTE_BC</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'PE'">CARTE_PE</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'MB'">CARTE_MB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NB'">CARTE_NB</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NE'">CARTE_NS</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NS'">CARTE_NS</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NU'">CARTE_NU</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'ON'">CARTE_ON</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'SK'">CARTE_SK</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NL'">CARTE_NL</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'NT'">CARTE_NT</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'TN'">CARTE_NT</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'YT'">CARTE_YT</xsl:when>
               <xsl:otherwise>""</xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.4.2">
      <xsl:element name="PID.4.2">
         <xsl:if test="contains('A01 A04 A08 A28 A31', $mshEventCode)">
            <xsl:choose>
               <xsl:when test="string-length(/HL7/ZI1/ZI1.2.1) = 0">""</xsl:when>
               <xsl:when test="/HL7/ZI1/ZI1.3.1 = 'QUE' or /HL7/ZI1/ZI1.3.1 = 'QC' or /HL7/ZI1/ZI1.3.1 = '79'">""</xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/ZI1/ZI1.2.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
      </xsl:element>
   </xsl:template>
   <!--Patient Name Information -->
   <xsl:template name="PID.5">
      <xsl:param name="posMRN"/>
      <xsl:call-template name="PID.5.1"/>
      <xsl:call-template name="PID.5.2">
         <xsl:with-param name="posMRN" select="$posMRN"/>
      </xsl:call-template>
      <xsl:call-template name="PID.5.7"/>
   </xsl:template>
   <!-- Patient Family Name Surname  -->
   <xsl:template name="PID.5.1">
      <xsl:element name="PID.5.1">
         <xsl:value-of select="upper-case(util:removeAccent(PID.5[1]/PID.5.1))"/>
      </xsl:element>
   </xsl:template>
   <!--Patient Given Name -->
   <xsl:template name="PID.5.2">
      <xsl:param name="posMRN"/>
      <xsl:element name="PID.5.2">
         <xsl:variable name="prenom" select="upper-case(util:removeAccent(PID.5[1]/PID.5.2))"/>
         <xsl:choose>
            <xsl:when test="contains($persoListPrenomInc, concat(replace(replace($prenom, ' ', ''), '-', ''), '~'))">
               <xsl:choose>
                  <xsl:when test="contains('A28 A31', $mshEventCode)">
                     <xsl:variable name="inst-pid" select="PID.4[$posMRN]/PID.4.6"/>
                     <xsl:variable name="mrn-pid" select="translate(PID.4[$posMRN]/PID.4.1, '0123456789', 'ABCDEFGHIJ')"/>
                     <xsl:choose>
                        <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text() != ''">
                           <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text(), '-', $mrn-pid, ' ', $prenom)"/>
                        </xsl:when>
                        <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text() != ''">
                           <xsl:value-of select="concat($dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text(), '-', $mrn-pid, ' ', $prenom)"/>
                        </xsl:when>
                        <xsl:otherwise/>
                     </xsl:choose>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:variable name="inst-pid" select="PID.4[PID.4.6 = $noInstallation and PID.4.5 = 'PRI']/PID.4.6"/>
                     <xsl:variable name="mrn-pid" select="translate(PID.4[PID.4.6 = $noInstallation and PID.4.5 = 'PRI']/PID.4.1, '0123456789', 'ABCDEFGHIJ')"/>
                     <xsl:choose>
                        <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text() != ''">
                           <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text(), '-', $mrn-pid, ' ', $prenom)"/>
                        </xsl:when>
                        <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text() != ''">
                           <xsl:value-of select="concat($dcml/dcml/etablissement/installation/SousInstallation[@msss = $inst-pid]/prefixe[@type = 'ADT']/text(), '-', $mrn-pid, ' ', $prenom)"/>
                        </xsl:when>
                        <xsl:otherwise/>
                     </xsl:choose>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$prenom"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.5.7">
      <xsl:element name="PID.5.7">
         <xsl:value-of select="'L'"/>
      </xsl:element>
   </xsl:template>
   <!-- Mother Information -->
   <xsl:template name="PID.6">
      <xsl:call-template name="PID.6.1"/>
      <xsl:call-template name="PID.6.2"/>
      <xsl:call-template name="PID.6.7"/>
   </xsl:template>
   <!-- Mother Family Name Surname  -->
   <xsl:template name="PID.6.1">
      <xsl:element name="PID.6.1">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(/HL7/NK1[NK1.1.1 = '0004']/NK1.2.1[1]) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="upper-case(util:removeAccent(/HL7/NK1[NK1.1.1 = '0004']/NK1.2.1[1]))"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Mother Given Name -->
   <xsl:template name="PID.6.2">
      <xsl:element name="PID.6.2">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(/HL7/NK1[NK1.1.1 = '0004']/NK1.2.2[1]) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="upper-case(util:removeAccent(/HL7/NK1[NK1.1.1 = '0004']/NK1.2.2[1]))"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.6.7">
      <xsl:element name="PID.6.7">
         <xsl:value-of select="'M'"/>
      </xsl:element>
   </xsl:template>
   <!--Patient Date of Birth -->
   <xsl:template name="PID.7">
      <xsl:element name="PID.7.1">
         <xsl:value-of select="PID.7.1"/>
      </xsl:element>
   </xsl:template>
   <!--Patient Administrative Sex -->
   <xsl:template name="PID.8">
      <xsl:element name="PID.8.1">
         <xsl:choose>
            <!-- Enlevé arborescence, sinon prend la valeur du premier PID -->
            <xsl:when test="PID.8.1 = 'M'">M</xsl:when>
            <xsl:when test="PID.8.1 = 'F'">F</xsl:when>
            <xsl:otherwise>U</xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Patient Address -->
   <xsl:template name="PID.11">
      <xsl:call-template name="PID.11.1"/>
      <xsl:call-template name="PID.11.2"/>
      <xsl:call-template name="PID.11.3"/>
      <xsl:call-template name="PID.11.4"/>
      <xsl:call-template name="PID.11.5"/>
      <xsl:call-template name="PID.11.6"/>
      <xsl:call-template name="PID.11.7"/>
      <xsl:call-template name="PID.11.9"/>
   </xsl:template>
   <!-- Address line 1 or (Street or Mailing Address)  -->
   <xsl:template name="PID.11.1">
      <xsl:element name="PID.11.1">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.11[1]/PID.11.1) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.11[1]/PID.11.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Address line 2 -->
   <xsl:template name="PID.11.2">
      <xsl:element name="PID.11.2">
         <xsl:value-of>""</xsl:value-of>
      </xsl:element>
   </xsl:template>
   <!-- City -->
   <xsl:template name="PID.11.3">
      <xsl:element name="PID.11.3">
         <!--mettre le pid.11.2 dans le pid.11.3-->
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.11[1]/PID.11.2) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.11[1]/PID.11.2"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!-- State -->
   <xsl:template name="PID.11.4">
      <xsl:element name="PID.11.4">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.11[1]/PID.11.4) = 0">""</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'ALB'">AB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'CBR'">BC</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'IPE'">PE</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'MAN'">MB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NBR'">NB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NEC'">NS</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NUN'">NU</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'ONT'">ON</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'QUE'">QC</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'SAS'">SK</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'TNE'">NL</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'TNO'">NT</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'YUK'">YT</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '80'">AB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '81'">BC</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '82'">PE</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '83'">MB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '84'">NB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '85'">NS</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '93'">NU</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '86'">ON</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '79'">QC</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '87'">SK</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '88'">NL</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '89'">NT</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = '90'">YT</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'AB'">AB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'BC'">BC</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'CB'">BC</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'PE'">PE</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'MB'">MB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NB'">NB</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NE'">NS</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NS'">NS</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NU'">NU</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'ON'">ON</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'QC'">QC</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'SK'">SK</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NL'">NL</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'NT'">NT</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'TN'">NT</xsl:when>
            <xsl:when test="PID.11[1]/PID.11.4 = 'YT'">YT</xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!-- Postal Code or Zip Code -->
   <xsl:template name="PID.11.5">
      <xsl:element name="PID.11.5">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.11[1]/PID.11.5) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="translate(normalize-space(PID.11[1]/PID.11.5), ' ', '')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!-- Country -->
   <xsl:template name="PID.11.6">
      <xsl:element name="PID.11.6">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.11[1]/PID.11.6) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.11[1]/PID.11.6"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!-- Address Type -->
   <xsl:template name="PID.11.7">
      <xsl:element name="PID.11.7">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.11[1]/PID.11.7) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.11[1]/PID.11.7"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!-- County Code -->
   <xsl:template name="PID.11.9">
      <xsl:element name="PID.11.9">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.11[1]/PID.11.9) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.11[1]/PID.11.9"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Home Phone Number -->
   <xsl:template name="PID.13">
      <xsl:call-template name="PID.13.1"/>
      <xsl:call-template name="PID.13.2"/>
      <xsl:call-template name="PID.13.6"/>
      <xsl:call-template name="PID.13.7"/>
      <xsl:call-template name="PID.13.9"/>
   </xsl:template>
   <xsl:template name="PID.13.1">
      <xsl:element name="PID.13.1">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.13.1) = 0">""</xsl:when>
            <xsl:when test="contains(PID.13.1, 'C')">
               <xsl:value-of select="substring-before(PID.13.1, 'C')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.13.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.13.2">
      <xsl:element name="PID.13.2">
         <xsl:value-of select="'PRN'"/>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.13.6">
      <xsl:element name="PID.13.6">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.13.6) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.13.6"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.13.7">
      <xsl:element name="PID.13.7">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.13.7) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.13.7"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.13.9">
      <xsl:element name="PID.13.9">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.13.9) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.13.9"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Phone Number - Business -->
   <xsl:template name="PID.14">
      <xsl:call-template name="PID.14.1"/>
      <xsl:call-template name="PID.14.2"/>
      <xsl:call-template name="PID.14.6"/>
      <xsl:call-template name="PID.14.7"/>
      <xsl:call-template name="PID.14.8"/>
      <xsl:call-template name="PID.14.9"/>
   </xsl:template>
   <xsl:template name="PID.14.1">
      <xsl:element name="PID.14.1">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.14.1) = 0">""</xsl:when>
            <xsl:when test="contains(PID.14.1, 'X')">
               <xsl:value-of select="substring-before(PID.14.1, 'X')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.14.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.14.2">
      <xsl:element name="PID.14.2">
         <xsl:value-of select="'WPN'"/>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.14.6">
      <xsl:element name="PID.14.6">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.14.6) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.14.6"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.14.7">
      <xsl:element name="PID.14.7">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.14.7) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.14.7"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.14.8">
      <xsl:element name="PID.14.8">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.14.8) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.14.8"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PID.14.9">
      <xsl:element name="PID.14.9">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(PID.14.9) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PID.14.9"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Account number -->
   <xsl:template name="PID.18">
      <xsl:if test="/HL7/PV1/PV1.19.1">
         <xsl:element name="PID.18.1">
            <xsl:choose>
               <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
                  <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), /HL7/PV1/PV1.19.1)"/>
               </xsl:when>
               <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
                  <xsl:value-of select="concat($dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), /HL7/PV1/PV1.19.1)"/>
               </xsl:when>
            </xsl:choose>            
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!-- NAM -->
   <xsl:template name="PID.19">
      <xsl:element name="PID.19.1">
         <xsl:choose>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and string-length(/HL7/ZI1/ZI1.2.1) = 0">""</xsl:when>
            <xsl:when test="contains('A01 A04 A08 A28 A31', $mshEventCode) and /HL7/ZI1/ZI1.3.1 != 'QUE' and /HL7/ZI1/ZI1.3.1 != 'QC' and /HL7/ZI1/ZI1.3.1 != '79'">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="/HL7/ZI1/ZI1.2.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Patient Death Date/Time -->
   <xsl:template name="PID.29">
      <!--Only date is stored -->
      <xsl:element name="PID.29.1">
         <xsl:choose>
            <xsl:when test="contains('A31', $mshEventCode) and string-length(PID.29.1) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="substring(PID.29.1, 1, 12)"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Patient Death Indicator -->
   <xsl:template name="PID.30">
      <xsl:element name="PID.30.1">
         <xsl:choose>
            <xsl:when test="contains('A31', $mshEventCode) and PID.30.1 != 'Y'">""</xsl:when>
            <xsl:when test="PID.30.1 = 'Y'">Y</xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!-- ************************************************************************************************************************* -->
   <!--                                                       Segment NK1                                                        -->
   <!-- ************************************************************************************************************************* -->
   <xsl:template name="NK1">
      <xsl:if test="$persoInclureNk1Pere = 'True'">
         <xsl:if test="contains('A01 A04 A08 A28 A31', $mshEventCode)">
            <xsl:element name="NK1">
               <xsl:call-template name="NK1.2"/>
               <xsl:call-template name="NK1.3"/>
            </xsl:element>
         </xsl:if>
      </xsl:if>
   </xsl:template>
   <!--Next-of-Kin Name -->
   <xsl:template name="NK1.2">
      <xsl:call-template name="NK1.2.1"/>
      <xsl:call-template name="NK1.2.2"/>
   </xsl:template>
   <xsl:template name="NK1.2.1">
      <xsl:element name="NK1.2.1">
         <xsl:choose>
            <xsl:when test="string-length(/HL7/NK1[NK1.1.1 = '0001']/NK1.2.1) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="upper-case(util:removeAccent(/HL7/NK1[NK1.1.1 = '0001']/NK1.2.1))"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="NK1.2.2">
      <xsl:element name="NK1.2.2">
         <xsl:choose>
            <xsl:when test="string-length(/HL7/NK1[NK1.1.1 = '0001']/NK1.2.2) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="upper-case(util:removeAccent(/HL7/NK1[NK1.1.1 = '0001']/NK1.2.2))"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--NoK Relationship - only FTH -->
   <xsl:template name="NK1.3">
      <!--Relationship Identifier -->
      <xsl:element name="NK1.3.1">FTH</xsl:element>
   </xsl:template>
   <!-- ************************************************************************************************************************* -->
   <!--                                                       Segment PV1                                                         -->
   <!-- ************************************************************************************************************************* -->
   <xsl:template name="PV1">
      <xsl:for-each select="/HL7/PV1[1]">
         <xsl:element name="PV1">
            <xsl:call-template name="PV1.1"/>
            <xsl:call-template name="PV1.2"/>
            <xsl:call-template name="PV1.3"/>
            <xsl:call-template name="PV1.4"/>
            <xsl:call-template name="PV1.7"/>
            <xsl:call-template name="PV1.10"/>
            <xsl:call-template name="PV1.17"/>
            <xsl:call-template name="PV1.19"/>
            <xsl:call-template name="PV1.36"/>
            <xsl:call-template name="PV1.44"/>
            <xsl:call-template name="PV1.45"/>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   <!--Set ID  PV1  -->
   <xsl:template name="PV1.1">
      <xsl:element name="PV1.1.1">1</xsl:element>
   </xsl:template>
   <!--Patient Class -->
   <xsl:template name="PV1.2">
      <xsl:element name="PV1.2.1">
         <xsl:choose>
            <!-- Enlevé arborescence, sinon prend la valeur du premier PID -->
            <xsl:when test="PV1.2.1 = 'I'">I</xsl:when>
            <xsl:when test="PV1.2.1 = 'E'">E</xsl:when>
            <xsl:when test="PV1.2.1 = 'P'">O</xsl:when>
            <!-- Pré-admission considéré OutPatient -->
            <xsl:otherwise>O</xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Assigned Patient Location -->
   <xsl:template name="PV1.3">
      <!--Unit OR Location OR Clinic -->
      <xsl:call-template name="PV1.3.1"/>
      <xsl:call-template name="PV1.3.2"/>
      <xsl:call-template name="PV1.3.3"/>
   </xsl:template>
   <xsl:template name="PV1.3.1">
      <xsl:element name="PV1.3.1">
         <xsl:choose>
            <xsl:when test="$mshEventCode = 'A12' and string-length(PV1.6.1) > 0">
               <xsl:choose>
                  <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
                     <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), PV1.6.1)"/>
                  </xsl:when>
                  <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
                     <xsl:value-of select="concat($dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), PV1.6.1)"/>
                  </xsl:when>
                  <xsl:otherwise/>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="$mshEventCode = 'A23' or $mshEventCode = 'A38'">
               <xsl:choose>
                  <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
                     <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), 'XSA')"/>
                  </xsl:when>
                  <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
                     <xsl:value-of select="concat($dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), 'XSA')"/>
                  </xsl:when>
                  <xsl:otherwise/>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="string-length(PV1.3.1) > 0">
               <xsl:choose>
                  <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
                     <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), PV1.3.1)"/>
                  </xsl:when>
                  <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
                     <xsl:value-of select="concat($dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), PV1.3.1)"/>
                  </xsl:when>
                  <xsl:otherwise/>
               </xsl:choose>
            </xsl:when>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Room if the room-Bed are not valued, these components should be sent as double quotes-->
   <xsl:template name="PV1.3.2">
      <xsl:element name="PV1.3.2">
         <xsl:choose>
            <xsl:when test="$mshEventCode = 'A12'">
               <xsl:choose>
                  <xsl:when test="PV1.6.2 = ''">""</xsl:when>
                  <xsl:when test="PV1.2.1 = 'E' and PV1.6.3 != '' and $persoIsCiviereGT3d = 'TRUE'">
                     <xsl:value-of select="PV1.6.3"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="PV1.6.2"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="$mshEventCode = 'A23' or $mshEventCode = 'A38'"/>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="PV1.3.2 = ''">""</xsl:when>
                  <xsl:when test="PV1.2.1 = 'E' and PV1.3.3 != '' and $persoIsCiviereGT3d = 'TRUE'">
                     <xsl:value-of select="PV1.3.3"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="PV1.3.2"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>   
   <!--Bed -->
   <xsl:template name="PV1.3.3">
      <xsl:element name="PV1.3.3">
         <xsl:choose>
            <xsl:when test="$mshEventCode = 'A12'">
               <xsl:choose>
                  <xsl:when test="PV1.6.3 = ''">""</xsl:when>
                  <xsl:when test="PV1.2.1 = 'E' and $persoIsCiviereGT3d = 'TRUE'">""</xsl:when>
                  <xsl:when test="util:getStringInList(PV1.6.3, '-', 2, '') = ''">
                     <xsl:value-of select="PV1.6.3"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="util:getStringInList(PV1.6.3, '-', 2, PV1.6.3)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="$mshEventCode = 'A23' or $mshEventCode = 'A38'"/>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="PV1.3.3 = ''">""</xsl:when>
                  <xsl:when test="PV1.2.1 = 'E' and $persoIsCiviereGT3d = 'TRUE'">""</xsl:when>
                  <xsl:when test="util:getStringInList(PV1.3.3, '-', 2, '') = ''">
                     <xsl:value-of select="PV1.3.3"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="util:getStringInList(PV1.3.3, '-', 2, PV1.3.3)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Admission Type -->
   <xsl:template name="PV1.4">
      <xsl:element name="PV1.4.1">
         <xsl:choose>
            <xsl:when test="PV1.4.1 = '4'">L</xsl:when>
            <xsl:when test="PV1.4.1 = '3'">R</xsl:when>
            <xsl:when test="PV1.4.1 = '1'">U</xsl:when>
            <xsl:when test="PV1.4.1 = '5'">N</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PV1.4.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Attending Doctor -->
   <xsl:template name="PV1.7">
      <xsl:call-template name="PV1.7.1"/>
      <xsl:call-template name="PV1.7.2"/>
      <xsl:call-template name="PV1.7.3"/>
   </xsl:template>
   <xsl:template name="PV1.7.1">
      <xsl:element name="PV1.7.1">
         <xsl:choose>
            <xsl:when test="string-length(PV1.7.1) = 0">""</xsl:when>
            <xsl:when test="string-length(PV1.7.1) = 6">
               <xsl:choose>
                  <xsl:when test="substring(PV1.7.1, 1, 1) = '2'">
                     <!--dentiste-->
                     <xsl:value-of select="PV1.7.1"/>
                  </xsl:when>
                  <xsl:when test="substring(PV1.7.1, 1, 1) = '5'">
                     <!--resident-->
                     <xsl:value-of select="PV1.7.1"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="substring(PV1.7.1, 2, 5)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PV1.7.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PV1.7.2">
      <xsl:element name="PV1.7.2">
         <xsl:choose>
            <xsl:when test="string-length(PV1.7.2) = 0 or PV1.7.2 = ', '"/>
            <!-- vide -->
            <xsl:otherwise>
               <xsl:value-of select="substring-before(PV1.7.2, ',')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PV1.7.3">
      <xsl:element name="PV1.7.3">
         <xsl:choose>
            <xsl:when test="string-length(PV1.7.2) = 0 or PV1.7.2 = ', '"/>
            <!-- vide -->
            <xsl:otherwise>
               <xsl:value-of select="substring-after(PV1.7.2, ', ')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Hospital Service -->
   <xsl:template name="PV1.10">
      <xsl:element name="PV1.10.1">
         <xsl:choose>
            <xsl:when test="PV1.10.1 = ''">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PV1.10.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Admitting Doctor -->
   <xsl:template name="PV1.17">
      <xsl:call-template name="PV1.17.1"/>
      <xsl:call-template name="PV1.17.2"/>
      <xsl:call-template name="PV1.17.3"/>
   </xsl:template>   
   <xsl:template name="PV1.17.1">
      <xsl:element name="PV1.17.1">
         <xsl:choose>
            <xsl:when test="string-length(PV1.17.1) = 0">""</xsl:when>
            <xsl:when test="string-length(PV1.17.1) = 6">
               <xsl:choose>
                  <xsl:when test="substring(PV1.17.1, 1, 1) = '2'">
                     <!--dentiste-->
                     <xsl:value-of select="PV1.17.1"/>
                  </xsl:when>
                  <xsl:when test="substring(PV1.17.1, 1, 1) = '5'">
                     <!--resident-->
                     <xsl:value-of select="PV1.17.1"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="substring(PV1.17.1, 2, 5)"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PV1.17.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PV1.17.2">
      <xsl:element name="PV1.17.2">
         <xsl:choose>
            <xsl:when test="string-length(PV1.17.2) = 0 or PV1.17.2 = ', '"/>
            <!-- vide -->
            <xsl:otherwise>
               <xsl:value-of select="substring-before(PV1.17.2, ',')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <xsl:template name="PV1.17.3">
      <xsl:element name="PV1.17.3">
         <xsl:choose>
            <xsl:when test="string-length(PV1.17.2) = 0 or PV1.17.2 = ', '"/>
            <!-- vide -->
            <xsl:otherwise>
               <xsl:value-of select="substring-after(PV1.17.2, ', ')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Visit Number -->
   <xsl:template name="PV1.19">
      <xsl:element name="PV1.19.1">
         <xsl:choose>
            <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
               <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), PV1.19.1)"/>
            </xsl:when>
            <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text() != ''">
               <xsl:value-of select="concat($dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation]/prefixe[@type = 'ADT']/text(), PV1.19.1)"/>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>         
      </xsl:element>
   </xsl:template>
   <!--Discharge Disposition -->
   <!-- *** Indicateur de décès pour SoftLab *** -->
   <xsl:template name="PV1.36">
      <xsl:element name="PV1.36.1">
         <xsl:choose>
            <xsl:when test="/HL7/PID[1]/PID.30.1 = 'Y'">Y</xsl:when>
            <xsl:otherwise/>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!--Admit Date and Time -->
   <xsl:template name="PV1.44">
      <xsl:element name="PV1.44.1">
         <xsl:value-of select="PV1.44.1"/>
      </xsl:element>
   </xsl:template>
   <!--Discharge Date/Time -->
   <xsl:template name="PV1.45">
      <xsl:element name="PV1.45.1">
         <xsl:choose>
            <xsl:when test="string-length(PV1.45.1) = 0">""</xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="PV1.45.1"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
   <!-- ************************************************************************************************************************* -->
   <!--                                                       Segment MRG                                                         -->
   <!-- ************************************************************************************************************************* -->
   <xsl:template name="MRG">
      <!-- Si MRG et si -->
      <xsl:if test="/HL7/MRG != ''">
         <xsl:element name="MRG">
            <xsl:call-template name="MRG.1"/>
         </xsl:element>
      </xsl:if>
   </xsl:template>
   <!--Prior Patient ID  -->
   <xsl:template name="MRG.1">
      <xsl:variable name="inst-mrg" select="/HL7/MRG/MRG.2.6"/>
      <xsl:element name="MRG.1.1">
         <xsl:choose>
            <xsl:when test="$dcml/dcml/etablissement/installation[@msss = $inst-mrg]/prefixe[@type = 'ADT']/text()">
               <xsl:value-of select="concat($dcml/dcml/etablissement/installation[@msss = $inst-mrg]/prefixe[@type = 'ADT']/text(), /HL7/MRG/MRG.2.1)"/>
            </xsl:when>
            <xsl:when test="$dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-mrg]/prefixe[@type = 'ADT']/text()">
               <xsl:value-of select="concat($dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-mrg]/prefixe[@type = 'ADT']/text(), /HL7/MRG/MRG.2.1)"/>
            </xsl:when>
         </xsl:choose>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
