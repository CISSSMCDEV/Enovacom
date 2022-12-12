
   <!--
  No.     Date       User     Description / commentaires (Optionnel)
  +++++   ++++++++++ ++++++++ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  1.01.00 2022-08-29 aitelh01 Gestion d'erreur sur les messges multiples.
          2022-03-07 lajrob01 ajout balise iplAncien
  5       2020-10-23 chejea01 Correction du idRDV(rdvsNo) et resultatNo
  4       2020-10-05 chetas01 Ajustements sur le segment modeleSuivi et les balises soinsType, statut et VisiteNo pour les SIU
  3       2019-11-07 lajrob01 Ajustements sur le segment modeleSuivi pour objetID et inputDonnee3
                              Ajustements la balise patient/ipl et patient/ipm
                              Ajustement pour les types de messages ayant 2 segments PID et / ou 2 segments PV1
                                Pour A17, il y a 2 segments PID et 2 segments PV1. 
                                  Tous les numéros ipm et ipl seront conservés dans le modèle canonique
                                  Le reste des informations des PID et PV1 ne sera pas dans le canonique
                                Pour A24 (Liaison de dossier) et A37 (Déliaison de dossier), il y a 2 segments PID et aucun segment PV1
                                  Le premier PID contient uniquement le numéro qui est lié ou délié du dossier inscrit dans le 2e PID
                                Ne pas confondre le A24 avec A30 (Fusion de dossier)
                                Pour un A30, il y a 1 segment PID. Le dossier fusionné (celui qui devient inactif) est dans le segment MRG.    
                                La balise visite est seulement produite s'il existe 1 seul segment PV1 ou ZS1
  2   2019-09-10     lajrob01 correction / ajustemetns du segment modeleSuivi  
  1                           Version 3.01 normée
-->
   <xsl:stylesheet xmlns:cdoi="http://www.chumontreal.qc.ca/cdoi"
                   xmlns:exsl="http://exslt.org/common"
                   xmlns:functx="http://www.functx.com"
                   xmlns:xp="http://www.w3.org/2005/xpath-functions"
                   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                   exclude-result-prefixes="#all"
                   extension-element-prefixes="exsl"
                   version="3.0">
      <!-- Inclusion des Templates  -->
      <xsl:include href="util-Templates.xsl"/>
      <!-- format de sortie (par defaut XML) -->
      <xsl:output encoding="UTF-8"
                  indent="yes"
                  method="xml"
                  omit-xml-declaration="yes"
                  version="1.0"/>
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
      <!-- archiveMode (valeur possible: N, B, R) (explication: N:Non, B:Batch, R:Temps reel) -->
      <xsl:variable name="paramPersoArchiveMode" select="'R'"/>
      <!-- paramPersoIdentifiantTypePourIpoDansPid4 (exemple: IPO, IPR) -->
      <xsl:variable name="paramPersoIdentifiantTypePourIpoDansPid4" select="'IPO'"/>
      <!-- paramPersoIdentifiantTypePourNiuDansPid4 (exemple: NIU) -->
      <xsl:variable name="paramPersoIdentifiantTypePourNiuDansPid4" select="'NIU'"/>
      <!-- ************************************************************************************************************************* -->
      <!--                                               Déclaration des variables                                                   -->
      <!-- ************************************************************************************************************************* -->
      <xsl:variable name="visiteStatut">
         <xsl:choose>
            <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'"/>
            <xsl:when test="contains('A24 A37', /HL7/MSH/MSH.9.2) = true()">
               <xsl:choose>
                  <xsl:when test="/HL7/PV1[2]/PV1.2.1 = 'I' and /HL7/PV1[2]/PV1.45.1 = '' and not(/HL7/MSH/MSH.9.2 = 'A11')">ADM</xsl:when>
                  <xsl:when test="/HL7/PV1[2]/PV1.2.1 = 'I' and not(/HL7/PV1[2]/PV1.45.1 = '') and not(/HL7/MSH/MSH.9.2 = 'A11')">DEP</xsl:when>
                  <xsl:when test="/HL7/PV1[2]/PV1.2.1 = 'E' and /HL7/PV1[2]/PV1.45.1 = '' and not(/HL7/MSH/MSH.9.2 = 'A11')">ADM</xsl:when>
                  <xsl:when test="/HL7/PV1[2]/PV1.2.1 = 'E' and not(/HL7/PV1[2]/PV1.45.1 = '') and not(/HL7/MSH/MSH.9.2 = 'A11')">DEP</xsl:when>
                  <xsl:when test="/HL7/PV1[2]/PV1.2.1 = 'P' and not(/HL7/MSH/MSH.9.2 = 'A38')">PRE</xsl:when>
                  <xsl:otherwise>INS</xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:choose>
                  <xsl:when test="/HL7/PV1/PV1.2.1 = 'I' and /HL7/PV1/PV1.45.1 = '' and not(/HL7/MSH/MSH.9.2 = 'A11')">ADM</xsl:when>
                  <xsl:when test="/HL7/PV1/PV1.2.1 = 'I' and not(/HL7/PV1/PV1.45.1 = '') and not(/HL7/MSH/MSH.9.2 = 'A11')">DEP</xsl:when>
                  <xsl:when test="/HL7/PV1/PV1.2.1 = 'E' and /HL7/PV1/PV1.45.1 = '' and not(/HL7/MSH/MSH.9.2 = 'A11')">ADM</xsl:when>
                  <xsl:when test="/HL7/PV1/PV1.2.1 = 'E' and not(/HL7/PV1/PV1.45.1 = '') and not(/HL7/MSH/MSH.9.2 = 'A11')">DEP</xsl:when>
                  <xsl:when test="/HL7/PV1/PV1.2.1 = 'P' and not(/HL7/MSH/MSH.9.2 = 'A38')">PRE</xsl:when>
                  <xsl:when test="/HL7/MSH/MSH.9.2 = 'A11' or /HL7/MSH/MSH.9.2 = 'A23' or /HL7/MSH/MSH.9.2 = 'A38' or /HL7/MSH/MSH.9.2 = 'S15'">ANN</xsl:when>
                  <xsl:when test="/HL7/MSH/MSH.9.2 = 'S17'">DEL</xsl:when>
                  <xsl:otherwise>INS</xsl:otherwise>
               </xsl:choose>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="countPID" select="count(/HL7/PID)"/>
      <xsl:variable name="countPV1" select="count(/HL7/PV1)"/>
      <!-- ************************************************************************************************************************* -->
      <!--                                                       Principal                                                  -->
      <!-- ************************************************************************************************************************* -->
      <xsl:template match="/">
         <xsl:choose>
            <xsl:when test="count(//MSH) &gt; 1">
               <xsl:message terminate="yes">Erreur message avec multiple HL7 !!!</xsl:message>
            </xsl:when>
            <xsl:otherwise>
               <xsl:element name="canonique">
                  <xsl:call-template name="context"/>
                  <xsl:call-template name="patient"/>
                  <xsl:call-template name="visite"/>
                  <xsl:call-template name="service"/>
                  <xsl:call-template name="modeleSuivi"/>
                  <xsl:call-template name="perso"/>
               </xsl:element>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:template>
      <!-- ************************************************************************************************************************* -->
      <!--                                                       Context                                                    -->
      <!-- ************************************************************************************************************************* -->
      <xsl:template name="context">
         <xsl:element name="context">
            <xsl:call-template name="context.archiveMode"/>
            <xsl:call-template name="context.siEmetteur"/>
            <xsl:call-template name="context.etablissementCode"/>
            <xsl:call-template name="context.installationCode"/>
            <xsl:call-template name="context.msgEventType"/>
            <xsl:call-template name="context.msgEventCode"/>
            <xsl:call-template name="context.msgCtrlId"/>
            <xsl:call-template name="context.objetMetier"/>
            <xsl:call-template name="context.siRecepteurAuDepart"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="context.archiveMode">
         <xsl:element name="archiveMode">
            <xsl:value-of select="$paramPersoArchiveMode"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="context.siEmetteur">
         <xsl:element name="siEmetteur"/>
      </xsl:template>
      <xsl:template name="context.etablissementCode">
         <xsl:element name="etablissementCode">
            <xsl:value-of select="/HL7/MSH/MSH.4.1"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="context.installationCode">
         <xsl:element name="installationCode">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT' and /HL7/PV1[1]/PV1.3.4">
                  <xsl:value-of select="/HL7/PV1[1]/PV1.3.4"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT' and /HL7/ZVN/ZVN.1.1">
                  <xsl:value-of select="/HL7/ZVN/ZVN.1.1"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="/HL7/ZS1/ZS1.3.1"/>
               </xsl:when>
               <xsl:otherwise>
                  <installationCode/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="context.msgEventType">
         <xsl:element name="msgEventType">
            <xsl:value-of select="/HL7/MSH/MSH.9.1"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="context.msgEventCode">
         <xsl:element name="msgEventCode">
            <xsl:value-of select="/HL7/MSH/MSH.9.2"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="context.msgCtrlId">
         <xsl:element name="msgCtrlId">
            <xsl:value-of select="/HL7/MSH/MSH.10.1"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="context.objetMetier">
         <xsl:element name="objetMetier">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="'objMetier.SIU'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="'objMetier.ADT'"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="context.siRecepteurAuDepart">
         <xsl:element name="siRecepteurAuDepart"/>
      </xsl:template>
      <!-- ************************************************************************************************************************* -->
      <!--                                                       Patient                                                    -->
      <!-- ************************************************************************************************************************* -->
      <xsl:template name="patient">
         <xsl:element name="patient">
            <xsl:call-template name="patient.archiveFlag"/>
            <xsl:call-template name="patient.ipl"/>
            <xsl:call-template name="patient.ipm"/>
            <xsl:call-template name="patient.ipo"/>
            <xsl:call-template name="patient.niu"/>
            <xsl:call-template name="patient.ramq"/>
            <xsl:call-template name="patient.nom"/>
            <xsl:call-template name="patient.prenom"/>
            <xsl:call-template name="patient.sexe"/>
            <xsl:call-template name="patient.dateNaissance"/>
            <xsl:call-template name="patient.patientDeathIndicator"/>
            <xsl:call-template name="patient.iplAncien"/>
            <xsl:call-template name="patient.ipmAncien"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.archiveFlag">
         <xsl:element name="archiveFlag">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT'">
                  <xsl:value-of select="'M'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="'C'"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.ipl">
         <xsl:for-each select="/HL7/PID">
            <xsl:for-each select="PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']">
               <xsl:element name="ipl">
                  <xsl:call-template name="ipl.dossierNo"/>
                  <xsl:call-template name="ipl.etablissementCode"/>
                  <xsl:call-template name="ipl.installationCode"/>
                  <xsl:call-template name="ipl.autorite"/>
                  <xsl:call-template name="ipl.identifiantType"/>
                  <xsl:call-template name="ipl.principal"/>
                  <xsl:call-template name="ipl.statut"/>
               </xsl:element>
            </xsl:for-each>
         </xsl:for-each>
         <xsl:variable name="countPid4"
                       select="count(/HL7/PID[PID.4/PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4/PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4/PID.4.5 != ''])"/>
         <xsl:if test="$countPid4 = 0">
            <xsl:element name="ipl"/>
         </xsl:if>
      </xsl:template>
      <xsl:template name="ipl.dossierNo">
         <xsl:element name="dossierNo">
            <xsl:value-of select="PID.4.1"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="ipl.etablissementCode">
         <!--également appelé institutionCode-->
         <xsl:element name="etablissementCode">
            <xsl:value-of select="preceding-sibling::PID.3.6[1]"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="ipl.installationCode">
         <!--également appelé siteCode-->
         <xsl:element name="installationCode">
            <xsl:value-of select="PID.4.6"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="ipl.autorite">
         <xsl:element name="autorite">
            <xsl:value-of select="PID.4.4"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="ipl.identifiantType">
         <xsl:element name="identifiantType">
            <xsl:value-of select="PID.4.5"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="ipl.principal">
         <xsl:variable name="noDossier" select="PID.4.6"/>
         <xsl:element name="principal">
            <xsl:choose>
               <xsl:when test="PID.4.6 = /HL7/ZVN/ZVN.1.1 or PID.4.6 = /HL7/ZS1/ZS1.3.1 or PID.4.6 = /HL7/PV1[PV1.3.4 = $noDossier][1]/PV1.3.4">
                  <xsl:value-of select="'1'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="'0'"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="ipl.statut">
         <xsl:element name="statut">
            <xsl:choose>
               <xsl:when test="PID.4.6 = /HL7/ZVN/ZVN.1.1 and /HL7/MSH/MSH.9.2 = 'A29'">
                  <xsl:value-of select="'I'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="'A'"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.ipm">
         <xsl:for-each select="/HL7/PID">
            <xsl:element name="ipm">
               <xsl:call-template name="patient.ipm.dossierNo">
                  <xsl:with-param name="dossierNo" select="PID.3.1"/>
               </xsl:call-template>
               <xsl:call-template name="patient.ipm.etablissementCode">
                  <xsl:with-param name="etablissementCode" select="PID.3.6"/>
               </xsl:call-template>
            </xsl:element>
         </xsl:for-each>
         <!--ipm autre-->
         <xsl:for-each select="/HL7/PID">
            <xsl:for-each select="PID.4[PID.4.5 = '']">
               <xsl:element name="ipm">
                  <xsl:call-template name="patient.ipm.dossierNo">
                     <xsl:with-param name="dossierNo" select="PID.4.1"/>
                  </xsl:call-template>
                  <xsl:call-template name="patient.ipm.etablissementCode">
                     <xsl:with-param name="etablissementCode" select="PID.4.6"/>
                  </xsl:call-template>
               </xsl:element>
            </xsl:for-each>
         </xsl:for-each>
      </xsl:template>
      <xsl:template name="patient.ipm.dossierNo">
         <xsl:param name="dossierNo"/>
         <xsl:element name="dossierNo">
            <xsl:value-of select="$dossierNo"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.ipm.etablissementCode">
         <xsl:param name="etablissementCode"/>
         <xsl:element name="etablissementCode">
            <xsl:value-of select="$etablissementCode"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.ipo">
         <xsl:element name="ipo"/>
      </xsl:template>
      <xsl:template name="patient.niu">
         <xsl:element name="niu">
            <xsl:choose>
               <!--Générer une balise vide pour une trasaction A17 (échange de lit)-->
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'"/>
               <xsl:when test="$countPID = 1">
                  <xsl:value-of select="/HL7/PID/PID.4[PID.4.5 = $paramPersoIdentifiantTypePourNiuDansPid4][1]/PID.4.1"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/PID[2]/PID.4[PID.4.5 = $paramPersoIdentifiantTypePourNiuDansPid4][1]/PID.4.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.ramq">
         <xsl:element name="ramq">
            <xsl:choose>
               <!--Générer une balise vide pour une trasaction A17 (échange de lit)-->
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'"/>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/ZI1/ZI1.2.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.nom">
         <xsl:element name="nom">
            <xsl:choose>
               <!--Générer une balise vide pour une trasaction A17 (échange de lit)-->
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'"/>
               <xsl:when test="$countPID = 1">
                  <xsl:value-of select="/HL7/PID/PID.5.1"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/PID[2]/PID.5.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.prenom">
         <xsl:element name="prenom">
            <xsl:choose>
               <!--Générer une balise vide pour une trasaction A17 (échange de lit)-->
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'"/>
               <xsl:when test="$countPID = 1">
                  <xsl:value-of select="/HL7/PID/PID.5.2"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/PID[2]/PID.5.2"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.sexe">
         <xsl:element name="sexe">
            <xsl:choose>
               <!--Générer une balise vide pour une trasaction A17 (échange de lit)-->
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'"/>
               <xsl:when test="$countPID = 1">
                  <xsl:value-of select="/HL7/PID/PID.8.1"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/PID[2]/PID.8.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.dateNaissance">
         <xsl:element name="dateNaissance">
            <xsl:choose>
               <!--Générer une balise vide pour une trasaction A17 (échange de lit)-->
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'"/>
               <xsl:when test="$countPID = 1">
                  <xsl:value-of select="/HL7/PID/PID.7.1"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/PID[2]/PID.7.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.patientDeathIndicator">
         <xsl:element name="patientDeathIndicator">
            <xsl:choose>
               <!--Générer une balise vide pour une trasaction A17 (échange de lit)-->
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'"/>
               <xsl:when test="$countPID = 1">
                  <xsl:value-of select="/HL7/PID/PID.30.1"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/PID[2]/PID.30.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.iplAncien">
         <xsl:element name="iplAncien">
            <xsl:if test="/HL7/MSH/MSH.9.2 = 'A48'">
               <xsl:element name="noDossier">
                  <xsl:value-of select="/HL7/MRG/MRG.2.1"/>
               </xsl:element>
               <xsl:element name="autorite">
                  <xsl:value-of select="/HL7/MRG/MRG.2.4"/>
               </xsl:element>
               <xsl:element name="identifiantType">
                  <xsl:value-of select="/HL7/MRG/MRG.2.5"/>
               </xsl:element>
               <xsl:element name="installationCode">
                  <xsl:value-of select="/HL7/MRG/MRG.2.6"/>
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:template>
      <xsl:template name="patient.ipmAncien">
         <xsl:element name="ipmAncien">
            <xsl:if test="/HL7/MSH/MSH.9.2 = 'A30'">
               <xsl:element name="noDossier">
                  <xsl:value-of select="/HL7/MRG/MRG.1.1"/>
               </xsl:element>
               <xsl:element name="installationCode">
                  <xsl:value-of select="/HL7/MRG/MRG.1.6"/>
               </xsl:element>
            </xsl:if>
         </xsl:element>
      </xsl:template>
      <!-- ************************************************************************************************************************* -->
      <!--                                                       visite                                                     -->
      <!-- ************************************************************************************************************************* -->
      <xsl:template name="visite">
         <xsl:element name="visite">
            <!--La trasaction A17 (échange de lit) contient 2 segments PV1 ce qui n'est pas supporté par l'archivage-->
            <xsl:if test="count(/HL7/PV1) = 1 or count(/HL7/ZS1) = 1">
               <xsl:call-template name="visite.archiveFlag"/>
               <xsl:call-template name="visite.visiteType"/>
               <xsl:call-template name="visite.installationCode"/>
               <xsl:call-template name="visite.visiteNo"/>
               <xsl:call-template name="visite.rdvsNo"/>
               <xsl:call-template name="visite.soinsType"/>
               <xsl:call-template name="visite.statut"/>
               <xsl:call-template name="visite.pavillon"/>
               <xsl:call-template name="visite.unite"/>
               <xsl:call-template name="visite.local"/>
               <xsl:call-template name="visite.lit"/>
               <xsl:call-template name="visite.admDHre"/>
               <xsl:call-template name="visite.depDHre"/>
            </xsl:if>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.archiveFlag">
         <xsl:element name="archiveFlag">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A04' and /HL7/ZV2/ZV2.10.1 &gt; 0">
                  <xsl:value-of select="'C'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="'M'"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.visiteType">
         <xsl:element name="visiteType">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT'">
                  <xsl:value-of select="/HL7/PV1/PV1.2.1"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="'C'"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.installationCode">
         <xsl:element name="installationCode">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT'">
                  <xsl:value-of select="/HL7/PV1/PV1.3.4"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="/HL7/ZS1/ZS1.3.1"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.visiteNo">
         <xsl:element name="visiteNo">
            <xsl:choose>
               <xsl:when test="/HL7/PV1/PV1.2.1 = 'P'">
                  <xsl:value-of select="/HL7/PV1/PV1.5.1"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/PV1/PV1.19.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.rdvsNo">
         <xsl:element name="rdvsNo">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT'">
                  <xsl:value-of select="/HL7/ZV2/ZV2.10.1"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="/HL7/SCH/SCH.2.1"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.soinsType">
         <xsl:element name="soinsType">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT'">
                  <xsl:value-of select="/HL7/PV1/PV1.18.1"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="/HL7/SCH/SCH.8.1"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.statut">
         <xsl:element name="statut">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="/HL7/SCH/SCH.25.2"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'ANN'">
                  <xsl:value-of select="'Annulé'"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'ADM'">
                  <xsl:value-of select="'Présent'"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'DEP'">
                  <xsl:value-of select="'Parti'"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'INS'">
                  <xsl:value-of select="'Inscrit'"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'PRE'">
                  <xsl:value-of select="'En attente'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$visiteStatut"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.pavillon">
         <xsl:element name="pavillon"/>
      </xsl:template>
      <xsl:template name="visite.unite">
         <xsl:element name="unite">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT'">
                  <xsl:value-of select="/HL7/PV1/PV1.3.1"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="/HL7/ZS4/ZS4.4.1"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.local">
         <xsl:element name="local">
            <xsl:value-of select="/HL7/PV1/PV1.3.2"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.lit">
         <xsl:element name="lit">
            <xsl:value-of select="replace(/HL7/PV1/PV1.3.3, concat(/HL7/PV1/PV1.3.2, '-'), '')"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.admDHre">
         <xsl:element name="admDHre">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT'">
                  <xsl:value-of select="/HL7/PV1/PV1.44.1"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="/HL7/SCH/SCH.11.4"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="visite.depDHre">
         <xsl:element name="depDHre">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT'">
                  <xsl:value-of select="/HL7/PV1/PV1.45.1"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="/HL7/SCH/SCH.11.5"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <!-- ************************************************************************************************************************* -->
      <!--                                                       Service                                                    -->
      <!-- ************************************************************************************************************************* -->
      <xsl:template name="service">
         <xsl:element name="service">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:call-template name="service.archiveFlag"/>
                  <xsl:call-template name="service.requeteAutorite"/>
                  <xsl:call-template name="service.requeteNo"/>
                  <xsl:call-template name="service.requeteParentNo"/>
                  <xsl:call-template name="service.resultatAutorite"/>
                  <xsl:call-template name="service.resultatNo"/>
                  <xsl:call-template name="service.resultatParentNo"/>
                  <xsl:call-template name="service.accessionAutorite"/>
                  <xsl:call-template name="service.accessionNo"/>
                  <xsl:call-template name="service.serviceType"/>
                  <xsl:call-template name="service.serviceSousType"/>
                  <xsl:call-template name="service.serviceCode"/>
                  <xsl:call-template name="service.serviceStatut"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'ADT' and count(/HL7/PV1) = 1">
                  <xsl:call-template name="service.archiveFlag"/>
                  <xsl:call-template name="service.serviceType"/>
                  <xsl:call-template name="service.serviceCode"/>
                  <xsl:call-template name="service.serviceStatut"/>
               </xsl:when>
               <xsl:otherwise/>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="service.archiveFlag">
         <xsl:element name="archiveFlag">
            <xsl:value-of select="'M'"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="service.requeteAutorite">
         <xsl:element name="requeteAutorite"/>
      </xsl:template>
      <xsl:template name="service.requeteNo">
         <xsl:element name="requeteNo"/>
      </xsl:template>
      <xsl:template name="service.requeteParentNo">
         <xsl:element name="requeteParentNo"/>
      </xsl:template>
      <xsl:template name="service.resultatAutorite">
         <xsl:element name="resultatAutorite">
            <xsl:value-of select="'ERDVS'"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="service.resultatNo">
         <xsl:element name="resultatNo">
            <xsl:value-of select="/HL7/SCH/SCH.2.1"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="service.resultatParentNo">
         <xsl:element name="resultatParentNo"/>
      </xsl:template>
      <xsl:template name="service.accessionAutorite">
         <xsl:element name="accessionAutorite"/>
      </xsl:template>
      <xsl:template name="service.accessionNo">
         <xsl:element name="accessionNo"/>
      </xsl:template>
      <xsl:template name="service.serviceType">
         <xsl:element name="serviceType">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="'RDVS'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="'ADT'"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="service.serviceSousType">
         <xsl:element name="serviceSousType">
            <xsl:value-of select="concat(/HL7/SCH/SCH.8.1, '^', /HL7/SCH/SCH.8.2)"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="service.serviceCode">
         <xsl:element name="serviceCode">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="concat(/HL7/AIS/AIS.3.1, '^', /HL7/AIS/AIS.3.2)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="/HL7/PV1/PV1.10.1"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="service.serviceStatut">
         <xsl:element name="serviceStatut">
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="concat(/HL7/SCH/SCH.25.1, '^', /HL7/SCH/SCH.25.2)"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'ANN'">
                  <xsl:value-of select="'ANN^Annulé'"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'ADM'">
                  <xsl:value-of select="'ADM^Présent'"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'DEP'">
                  <xsl:value-of select="'DEP^Parti'"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'INS'">
                  <xsl:value-of select="'INS^Inscrit'"/>
               </xsl:when>
               <xsl:when test="$visiteStatut = 'PRE'">
                  <xsl:value-of select="'PRE^En attente'"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="$visiteStatut"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <!-- ************************************************************************************************************************* -->
      <!--                                                       modeleSuivi                                                -->
      <!-- ************************************************************************************************************************* -->
      <xsl:template name="modeleSuivi">
         <xsl:element name="modeleSuivi">
            <xsl:call-template name="modeleSuivi.objetID"/>
            <xsl:call-template name="modeleSuivi.inputDonnee2"/>
            <xsl:call-template name="modeleSuivi.inputDonnee3"/>
            <xsl:call-template name="modeleSuivi.inputDonnee4"/>
            <xsl:call-template name="modeleSuivi.inputDonnee5"/>
            <xsl:call-template name="modeleSuivi.inputDonnee6"/>
         </xsl:element>
      </xsl:template>
      <xsl:template name="modeleSuivi.objetID">
         <!--Contient toutes les informations nécessaires pour bloquer un message-->
         <xsl:element name="objetID">
            <xsl:variable name="recMrg">
               <xsl:choose>
                  <xsl:when test="/HL7/MRG/MRG.1.1 != ''">
                     <xsl:value-of select="concat(' ', /HL7/MRG/MRG.1.1, '^', /HL7/MRG/MRG.1.6)"/>
                  </xsl:when>
                  <xsl:when test="/HL7/MRG/MRG.2.1 != ''">
                     <xsl:value-of select="concat(' ', /HL7/MRG/MRG.2.1, '^', /HL7/MRG/MRG.2.6)"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="''"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:choose>
               <xsl:when test="/HL7/MSH/MSH.9.1 = 'SIU'">
                  <xsl:value-of select="                      concat('rdv:', /HL7/ZS1/ZS1.2.1)"/>
               </xsl:when>
               <xsl:when test="count(/HL7/PV1) = 1 and /HL7/PV1/PV1.2.1 = 'P'">
                  <xsl:value-of select="                      concat('vis:', /HL7/PV1/PV1.5.1)"/>
               </xsl:when>
               <xsl:when test="count(/HL7/PV1) = 1">
                  <xsl:value-of select="                      concat('vis:', /HL7/PV1/PV1.19.1)"/>
               </xsl:when>
               <xsl:when test="/HL7/MSH/MSH.9.2 = 'A17'">
                  <xsl:variable name="recNumberIpm1" select="/HL7/PID[1]/PID.3.1"/>
                  <xsl:variable name="recInstitutionIpm1" select="/HL7/PID[1]/PID.3.6"/>
                  <xsl:variable name="recNumberIpm2" select="/HL7/PID[2]/PID.3.1"/>
                  <xsl:variable name="recInstitutionIpm2" select="/HL7/PID[2]/PID.3.6"/>
                  <xsl:value-of select="                      concat('ipm:', $recNumberIpm1, '^', $recInstitutionIpm1, ' ', $recNumberIpm2, '^', $recInstitutionIpm2)"/>
               </xsl:when>
               <xsl:when test="$countPID = 1">
                  <xsl:variable name="recNumberIpm" select="/HL7/PID/PID.3.1"/>
                  <xsl:variable name="recInstitutionIpm" select="/HL7/PID/PID.3.6"/>
                  <xsl:variable name="countNumberIpmAutre" select="count(/HL7/PID/PID.4[PID.4.5 = ''])"/>
                  <xsl:variable name="recNumberIpmAutre" select="/HL7/PID/PID.4[PID.4.5 = '']/PID.4.1"/>
                  <xsl:variable name="recInstitutionIpmAutre"
                                select="/HL7/PID/PID.4[PID.4.5 = '']/PID.4.6"/>
                  <xsl:variable name="countNumberIpo"
                                select="count(/HL7/PID/PID.4[PID.4.5 = $paramPersoIdentifiantTypePourIpoDansPid4])"/>
                  <xsl:variable name="recNumberIpo"
                                select="/HL7/PID/PID.4[PID.4.5 = $paramPersoIdentifiantTypePourIpoDansPid4]/PID.4.1"/>
                  <xsl:variable name="countNumberIpl"
                                select="count(/HL7/PID/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != ''])"/>
                  <xsl:variable name="recNumberIpl"
                                select="/HL7/PID/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']/PID.4.1"/>
                  <xsl:variable name="recAssAuthorityIpl"
                                select="/HL7/PID/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']/PID.4.4"/>
                  <xsl:variable name="recEtablissementIpl"
                                select="/HL7/PID/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']/PID.4.6"/>
                  <xsl:variable name="recTypeIpl"
                                select="/HL7/PID/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']/PID.4.5"/>
                  <xsl:choose>
                     <xsl:when test="$countNumberIpo &gt; 0 and $countNumberIpmAutre &gt; 0 and $countNumberIpl &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ' ', normalize-space(string-join(for $pos in 1 to count($recNumberIpmAutre)                            return                               concat($recNumberIpmAutre[$pos], '^', $recInstitutionIpmAutre[$pos], ' '))), ', ipl:', normalize-space(string-join(for $pos in 1 to count($recNumberIpl)                            return                               concat($recNumberIpl[$pos], '^', $recAssAuthorityIpl[$pos], '^', $recTypeIpl[$pos], '^', $recEtablissementIpl[$pos], ' '))), ', ipo:', $recNumberIpo)"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpo &gt; 0 and $countNumberIpl &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ', ipl:', normalize-space(string-join(for $pos in 1 to count($recNumberIpl)                            return                               concat($recNumberIpl[$pos], '^', $recAssAuthorityIpl[$pos], '^', $recTypeIpl[$pos], '^', $recEtablissementIpl[$pos], ' '))), ', ipo:', $recNumberIpo)"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpo &gt; 0 and $countNumberIpmAutre &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ' ', normalize-space(string-join(for $pos in 1 to count($recNumberIpmAutre)                            return                               concat($recNumberIpmAutre[$pos], '^', $recInstitutionIpmAutre[$pos], ' '))), ', ipo:', $recNumberIpo)"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpo &gt; 0">
                        <xsl:value-of select="concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ', ipo:', $recNumberIpo)"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpmAutre &gt; 0 and $countNumberIpl &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ' ', normalize-space(string-join(for $pos in 1 to count($recNumberIpmAutre)                            return                               concat($recNumberIpmAutre[$pos], '^', $recInstitutionIpmAutre[$pos], ' '))), ', ipl:', normalize-space(string-join(for $pos in 1 to count($recNumberIpl)                            return                               concat($recNumberIpl[$pos], '^', $recAssAuthorityIpl[$pos], '^', $recTypeIpl[$pos], '^', $recEtablissementIpl[$pos], ' '))))"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpmAutre &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ' ', normalize-space(string-join(for $pos in 1 to count($recNumberIpmAutre)                            return                               concat($recNumberIpmAutre[$pos], '^', $recInstitutionIpmAutre[$pos], ' '))))"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpl &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ', ipl:', normalize-space(string-join(for $pos in 1 to count($recNumberIpl)                            return                               concat($recNumberIpl[$pos], '^', $recAssAuthorityIpl[$pos], '^', $recTypeIpl[$pos], '^', $recEtablissementIpl[$pos], ' '))))"/>
                     </xsl:when>
                     <!--On veut le numéro fusionné dans les 2 balises (ipm et mrg). Ipm pour la gestion des messages bloqués-->
                     <xsl:when test="/HL7/MRG/MRG.1.1 != ''">
                        <xsl:value-of select="concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ', mrg:', functx:left-trim($recMrg))"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm)"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:variable name="recNumberIpm" select="/HL7/PID[2]/PID.3.1"/>
                  <xsl:variable name="recInstitutionIpm" select="/HL7/PID[2]/PID.3.6"/>
                  <xsl:variable name="countNumberIpmAutre"
                                select="count(/HL7/PID[2]/PID.4[PID.4.5 = ''])"/>
                  <xsl:variable name="recNumberIpmAutre"
                                select="/HL7/PID[2]/PID.4[PID.4.5 = '']/PID.4.1"/>
                  <xsl:variable name="recInstitutionIpmAutre"
                                select="/HL7/PID[2]/PID.4[PID.4.5 = '']/PID.4.6"/>
                  <xsl:variable name="countNumberIpo"
                                select="count(/HL7/PID[2]/PID.4[PID.4.5 = $paramPersoIdentifiantTypePourIpoDansPid4])"/>
                  <xsl:variable name="recNumberIpo"
                                select="/HL7/PID[2]/PID.4[PID.4.5 = $paramPersoIdentifiantTypePourIpoDansPid4]/PID.4.1"/>
                  <xsl:variable name="countNumberIpl"
                                select="count(/HL7/PID[2]/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != ''])"/>
                  <xsl:variable name="recNumberIpl"
                                select="/HL7/PID[2]/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']/PID.4.1"/>
                  <xsl:variable name="recAssAuthorityIpl"
                                select="/HL7/PID[2]/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']/PID.4.4"/>
                  <xsl:variable name="recEtablissementIpl"
                                select="/HL7/PID[2]/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']/PID.4.6"/>
                  <xsl:variable name="recTypeIpl"
                                select="/HL7/PID[2]/PID.4[PID.4.5 != $paramPersoIdentifiantTypePourIpoDansPid4 and PID.4.5 != $paramPersoIdentifiantTypePourNiuDansPid4 and PID.4.5 != '']/PID.4.5"/>
                  <xsl:choose>
                     <xsl:when test="$countNumberIpo &gt; 0 and $countNumberIpmAutre &gt; 0 and $countNumberIpl &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ' ', normalize-space(string-join(for $pos in 1 to count($recNumberIpmAutre)                            return                               concat($recNumberIpmAutre[$pos], '^', $recInstitutionIpmAutre[$pos], ' '))), ', ipl:', normalize-space(string-join(for $pos in 1 to count($recNumberIpl)                            return                               concat($recNumberIpl[$pos], '^', $recAssAuthorityIpl[$pos], '^', $recTypeIpl[$pos], '^', $recEtablissementIpl[$pos], ' '))), ', ipo:', $recNumberIpo)"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpo &gt; 0 and $countNumberIpl &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ', ipl:', normalize-space(string-join(for $pos in 1 to count($recNumberIpl)                            return                               concat($recNumberIpl[$pos], '^', $recAssAuthorityIpl[$pos], '^', $recTypeIpl[$pos], '^', $recEtablissementIpl[$pos], ' '))), ', ipo:', $recNumberIpo)"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpo &gt; 0 and $countNumberIpmAutre &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ' ', normalize-space(string-join(for $pos in 1 to count($recNumberIpmAutre)                            return                               concat($recNumberIpmAutre[$pos], '^', $recInstitutionIpmAutre[$pos], ' '))), ', ipo:', $recNumberIpo)"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpo &gt; 0">
                        <xsl:value-of select="concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ', ipo:', $recNumberIpo)"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpmAutre &gt; 0 and $countNumberIpl &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ' ', normalize-space(string-join(for $pos in 1 to count($recNumberIpmAutre)                            return                               concat($recNumberIpmAutre[$pos], '^', $recInstitutionIpmAutre[$pos], ' '))), ', ipl:', normalize-space(string-join(for $pos in 1 to count($recNumberIpl)                            return                               concat($recNumberIpl[$pos], '^', $recAssAuthorityIpl[$pos], '^', $recTypeIpl[$pos], '^', $recEtablissementIpl[$pos], ' '))))"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpmAutre &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ' ', normalize-space(string-join(for $pos in 1 to count($recNumberIpmAutre)                            return                               concat($recNumberIpmAutre[$pos], '^', $recInstitutionIpmAutre[$pos], ' '))))"/>
                     </xsl:when>
                     <xsl:when test="$countNumberIpl &gt; 0">
                        <xsl:value-of select="                            concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ', ipl:', normalize-space(string-join(for $pos in 1 to count($recNumberIpl)                            return                               concat($recNumberIpl[$pos], '^', $recAssAuthorityIpl[$pos], '^', $recTypeIpl[$pos], '^', $recEtablissementIpl[$pos], ' '))))"/>
                     </xsl:when>
                     <xsl:when test="/HL7/MRG/MRG.1.1 != ''">
                        <xsl:value-of select="concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm, $recMrg, ', mrg:', /HL7/MRG/MRG.1.1, '^', /HL7/MRG/MRG.1.6)"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="concat('ipm:', $recNumberIpm, '^', $recInstitutionIpm)"/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:element>
      </xsl:template>
      <xsl:template name="modeleSuivi.inputDonnee2">
         <xsl:element name="inputDonnee2"/>
      </xsl:template>
      <xsl:template name="modeleSuivi.inputDonnee3">
         <xsl:element name="inputDonnee3"/>
      </xsl:template>
      <!--Vous pouvez apportez vos modifications sur cette donnée dans le fichier perso -->
      <xsl:template name="modeleSuivi.inputDonnee4">
         <xsl:element name="inputDonnee4"/>
      </xsl:template>
      <xsl:template name="modeleSuivi.inputDonnee5">
         <xsl:element name="inputDonnee5"/>
      </xsl:template>
      <xsl:template name="modeleSuivi.inputDonnee6">
         <xsl:element name="inputDonnee6"/>
      </xsl:template>
      <!-- ************************************************************************************************************************* -->
      <!--                                                       Perso                                                      -->
      <!-- ************************************************************************************************************************* -->
      <xsl:template name="perso">
         <xsl:element name="perso"/>
      </xsl:template>
   </xsl:stylesheet>

