
<xsl:stylesheet xmlns:exsl="http://exslt.org/common" xmlns:functx="http://www.functx.com"
    xmlns:util="http://whatever" xmlns:xp="http://www.w3.org/2005/xpath-functions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all" extension-element-prefixes="exsl" version="3.0">
    <!-- Inclusion du xsl de base -->
    <xsl:import href="Eclinibase ADT Silp.xsl"/>

    <!-- ************************************************************************************************************************* -->
    <!--                                          Déclaration des variables perso                                                  -->
    <!-- ************************************************************************************************************************* -->
    <!--balise xml à définir dans le perso pour identifier le dcml, établissement et installation-->
    <xsl:variable name="persoDcmlXml">
        <dcml nom="DCML Montérégie" code="K" abrege="DCML Montérégie">
            <etablissement nom="CISSS de la Montérégie-Est" code="KC" mne="ME" msss="11045309" aiq="16b" aiqOMPrecision="ME">
                <installation code4="K560" code5="KC560" nom="Hôpital Pierre-Boucher" mne="HPB" msss="51229011" niu="1000018810">
                    <prefixe type="ADT">KCAH</prefixe>
                </installation>
                <installation code4="K561" code5="KC561" nom="Hôtel-Dieu de Sorel" mne="HDS" msss="51229102" niu="1000018620">
                    <prefixe type="ADT">KCBH</prefixe>
                </installation>
                <installation code4="K562" code5="KC562" nom="Hôpital Honoré-Mercier" mne="HHM" msss="51229193" niu="1000019719">
                    <prefixe type="ADT">KCCH</prefixe>
                </installation>
            </etablissement>
        </dcml>
    </xsl:variable>
    
    
    <!-- 
        *******************************************************************************************
        Regles de filtrage: dossier permanent (filtre effectuer dans la transformation!)
        
        Le code norme du COI genere autant de msg qu'il y a d'occurence du PID.4 pour les A31 et 
        A28. Puisqu'on veut filtrer les dossiers temporaire, on empeche la creation de l'element 
        XML "HL7" pour les dossiers temporaire.
        *******************************************************************************************
    -->
    <xsl:variable name="persoDossierPermanent">
        <installation nom="HPB" msss="51229011" max="3999999"/>
        <installation nom="HHM" msss="51229193" max="4999999"/>
        <installation nom="HDS" msss="51229102" max="999999999"/>
    </xsl:variable>
    
    <xsl:template match="/">
        <xsl:element name="MSG_LIST">
            <xsl:choose>
                <!-- Si evntCode = A31 alors construire autant de msg qu'il y a d'installation défini dans le fichier xml de config du silp -->
                <!-- Si evntCode = A28, en mode "live", il va y avoir un seul pid.4
                    en mode "chargement", il faut générer autant de A28 selon persoDcmlXml-->
                <xsl:when test="contains('A28 A31', $mshEventCode)">
                    <xsl:for-each select="/HL7/PID/PID.4">
                        <xsl:variable name="inst-pid" select="PID.4.6"/>
                        <xsl:variable name="persoValeurMaxDosPermanent" select="number($persoDossierPermanent/installation[@msss = $inst-pid]/@max)"/>
                        
                        <xsl:choose>
                            <xsl:when test="PID.4.5 = 'PRI' and $dcml/dcml/etablissement/installation[@msss = $inst-pid] != ''">
                                
                                <xsl:if test="string(number(PID.4.1)) != 'NaN' and PID.4.1 &lt;= $persoValeurMaxDosPermanent">
                                    <xsl:variable name="position" select="position()" as="xs:integer"/>
                                    <xsl:call-template name="HL7">
                                        <xsl:with-param name="position" select="$position"/>
                                    </xsl:call-template>
                                </xsl:if>
                            </xsl:when>
                            <xsl:when test="PID.4.5 = 'PRI' and $dcml/dcml/etablissement/installation/sousInstallation[@msss = $inst-pid] != ''">
                                <xsl:if test="string(number(PID.4.1)) != 'NaN' and PID.4.1 &lt;= $persoValeurMaxDosPermanent">
                                    <xsl:variable name="position" select="position()" as="xs:integer"/>
                                    <xsl:call-template name="HL7">
                                        <xsl:with-param name="position" select="$position"/>
                                    </xsl:call-template>
                                </xsl:if>
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
                <xsl:when
                    test="$mshEventCode = 'A17' and $dcml/dcml/etablissement/installation/sousInstallation[@msss = $noInstallation] != ''">
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
       
	   
	   
	<!-- 
        *******************************************************************************************
        Transformation: Ajout de la date d'expiration RAMQ (PID.19.2)
        *******************************************************************************************
    -->	   
	   
	   <!-- *** Debut du code du CO-I - provient d'un nouvelle version du CO-I *** -->
	   <xsl:template name="PID.19">
        <xsl:call-template name="PID.19.1"/>
        <xsl:call-template name="PID.19.2"/>
    </xsl:template>
    <xsl:template name="PID.19.1">
        <xsl:element name="PID.19.1">
            <xsl:choose>
                <xsl:when test="contains('A01 A04 A08 A28 A29 A31', $mshEventCode) and string-length(/HL7/ZI1/ZI1.2.1) = 0">""</xsl:when>
                <xsl:when test="contains('A01 A04 A08 A28 A29 A31', $mshEventCode) and /HL7/ZI1/ZI1.3.1 != 'QUE' and /HL7/ZI1/ZI1.3.1 != 'QC' and /HL7/ZI1/ZI1.3.1 != '79'">""</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="/HL7/ZI1/ZI1.2.1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template name="PID.19.2">
        <xsl:element name="PID.19.2">
            <xsl:choose>
                <xsl:when test="contains('A01 A04 A08 A28 A29 A31', $mshEventCode) and string-length(/HL7/ZI1/ZI1.2.1) = 0">""</xsl:when>
                <xsl:when test="contains('A01 A04 A08 A28 A29 A31', $mshEventCode) and /HL7/ZI1/ZI1.3.1 != 'QUE' and /HL7/ZI1/ZI1.3.1 != 'QC' and /HL7/ZI1/ZI1.3.1 != '79'">""</xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="/HL7/ZI1/ZI1.5.1 != ''">
                            <xsl:value-of select="replace(/HL7/ZI1/ZI1.5.1, '/', '')"/>
                        </xsl:when>
                        <xsl:otherwise>""</xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
	<!-- *** Debut du code du CO-I - provient d'un nouvelle version du CO-I *** -->
	   
	   
    <!-- 
        *******************************************************************************************
        Transformation: Personne Contact (NK1 – Père)
        *******************************************************************************************
    -->
    <xsl:variable name="persoInclureNk1Pere">True</xsl:variable>
    
    <!-- 
        *******************************************************************************************
        Transformation: Localisation du patient (PV1.3.1)
        *******************************************************************************************
    -->
    <xsl:template name="PV1.3.1">
        <xsl:element name="PV1.3.1">
            <xsl:choose>
                <xsl:when test="/HL7/PID/PID.4[1]/PID.4.6 = '51229011' and /HL7/PV1/PV1.2.1 = 'E'">
                    <xsl:choose>
                        <xsl:when test="matches(/HL7/MSH/MSH.9.2, 'A03|A23') or (/HL7/MSH/MSH.9.2 = 'A08' and string(/HL7/PV1/PV1.45.1) != '')">KCAHARU</xsl:when>
                        <xsl:when test="substring(substring-after(/HL7/PV1/PV1.3.3, '-'), 1, 1) = 'A'">KCAHURG-A</xsl:when>
                        <xsl:when test="substring(substring-after(/HL7/PV1/PV1.3.3, '-'), 1, 1) = 'B'">KCAHURG-B</xsl:when>
                        <xsl:when test="substring(substring-after(/HL7/PV1/PV1.3.3, '-'), 1, 1) = 'C'">KCAHURG-C</xsl:when>
                        <xsl:when test="substring(substring-after(/HL7/PV1/PV1.3.3, '-'), 1, 1) = 'D'">KCAHURG-D</xsl:when>
                        <xsl:when test="substring(substring-after(/HL7/PV1/PV1.3.3, '-'), 1, 1) = 'E'">KCAHURG-E</xsl:when>
                        <xsl:when test="substring(substring-after(/HL7/PV1/PV1.3.3, '-'), 1, 2) = 'RZ'">KCAHURG-ZER</xsl:when>
                        <xsl:otherwise>KCAHURG</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
                <xsl:when test="/HL7/PID/PID.4[1]/PID.4.6 = '51229011' and /HL7/PV1/PV1.2.1 = 'I' and (matches(/HL7/MSH/MSH.9.2, 'A03|A23') or (/HL7/MSH/MSH.9.2 = 'A08' and string(/HL7/PV1/PV1.45.1) != ''))">KCAHARC</xsl:when>
                
                <xsl:when test="/HL7/PID/PID.4[1]/PID.4.6 = '51229102' and /HL7/PV1/PV1.2.1 = 'I' and matches(/HL7/MSH/MSH.9.2, 'A03|A23')">KCBHARCH</xsl:when>
                
                <xsl:when test="/HL7/PID/PID.4[1]/PID.4.6 = '51229102' and /HL7/PV1/PV1.2.1 = 'E'">
                    <xsl:choose>
                        <xsl:when test="matches(/HL7/PV1/PV1.3.2, 'P7|P8|P9')">KCBHURG1</xsl:when>
                        <xsl:otherwise>KCBHURG</xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
                <xsl:when test="/HL7/PID/PID.4[1]/PID.4.6 = '51229193' and /HL7/PV1/PV1.2.1 = 'I' and matches(/HL7/MSH/MSH.9.2, 'A03|A23')">KCCHARCHV</xsl:when>
                
                <xsl:when test="/HL7/PID/PID.4[1]/PID.4.6 = '51229193' and /HL7/PV1/PV1.2.1 = 'E'">
                    <xsl:choose>
                        <xsl:when test="matches(/HL7/MSH/MSH.9.2, 'A03|A23')">KCCHARCHU</xsl:when>
                        
                        <xsl:when test="string-length(/HL7/PV1/PV1.3.2) > 0">
                            <xsl:value-of select="concat('KCCH', upper-case(/HL7/PV1/PV1.3.2))"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat('KCCH', upper-case(/HL7/PV1/PV1.3.1))"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
                <xsl:otherwise>
                    <!-- *** Debut du code du CO-I original *** -->
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
                    <!-- *** Fin du code du CO-I original *** -->
                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- 
        *******************************************************************************************
        Transformation: Localisation du patient (PV1.3.2)
        *******************************************************************************************
    -->
    <xsl:template name="PV1.3.2">
        <xsl:element name="PV1.3.2">
            <xsl:choose>
                <xsl:when test="matches(/HL7/PID/PID.4[1]/PID.4.6, '51229011|51229102|51229193') and /HL7/PV1/PV1.2.1 = 'E'">
                    <xsl:choose>
                        <xsl:when test="string-length(/HL7/PV1/PV1.3.3) = 0">""</xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring-after(/HL7/PV1/PV1.3.3, '-')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                
                <xsl:otherwise>
                    <!-- *** Debut du code du CO-I original *** -->
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
                                <xsl:when  test="PV1.2.1 = 'E' and PV1.3.3 != '' and $persoIsCiviereGT3d = 'TRUE'">
                                    <xsl:value-of select="PV1.3.3"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="PV1.3.2"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- *** Fin du code du CO-I original *** -->
                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- 
        *******************************************************************************************
        Transformation: Localisation du patient (PV1.3.3)
        *******************************************************************************************
    -->
    <xsl:template name="PV1.3.3">
        <xsl:element name="PV1.3.3">
            <xsl:choose>
                <xsl:when test="matches(/HL7/PID/PID.4[1]/PID.4.6, '51229011|51229102|51229193') and /HL7/PV1/PV1.2.1 = 'E'">""</xsl:when>
                
                <xsl:otherwise>
                    <!-- *** Debut du code du CO-I original *** -->
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
                    <!-- *** Fin du code du CO-I original *** -->
                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- 
        *******************************************************************************************
        Transformation: Medecin traitant (PV1.7.1)
        *******************************************************************************************
    -->
    <xsl:template name="PV1.7.1">
        <xsl:element name="PV1.7.1">
            <xsl:choose>
                <xsl:when test="/HL7/PV1/PV1.2.1 = 'E' and string-length(/HL7/PV1/PV1.7.1) = 0">
                    <xsl:value-of select="'MDGARURG'"/>
                </xsl:when>
                <xsl:when test="string-length(/HL7/PV1/PV1.7.1) = 6">                   
                    <xsl:choose>
                        <xsl:when test="substring(/HL7/PV1/PV1.7.1, 1, 1) != '1'">
                            <xsl:value-of select="/HL7/PV1/PV1.7.1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring(/HL7/PV1/PV1.7.1, 2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="string-length(/HL7/PV1/PV1.7.1) = 7">
                    <xsl:choose>
                        <xsl:when test="substring(/HL7/PV1/PV1.7.1, 1, 1) != '1'">
                            <xsl:value-of select="substring(/HL7/PV1/PV1.7.1, 1, 6)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring(/HL7/PV1/PV1.7.1, 2, 5)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="/HL7/PV1/PV1.7.1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- 
        *******************************************************************************************
        Transformation: Medecin traitant (PV1.7.2)
        *******************************************************************************************
    -->
    <xsl:template name="PV1.7.2">
        <xsl:element name="PV1.7.2">
            <xsl:choose>
                <xsl:when test="/HL7/PV1/PV1.2.1 = 'E' and string-length(/HL7/PV1/PV1.7.1) = 0">
                    <xsl:value-of select="'URGENCE, MEDECIN DE GARDE'"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <!-- *** Debut du code du CO-I original *** -->
                    <xsl:choose>
                        <xsl:when test="string-length(/HL7/PV1/PV1.7.2) = 0 or /HL7/PV1/PV1.7.2 = ', '"/>
                        <!-- vide -->
                        <xsl:otherwise>
                            <xsl:value-of select="substring-before(/HL7/PV1/PV1.7.2, ',')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <!-- *** Fin du code du CO-I original *** -->
                    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!-- 
        *******************************************************************************************
        Transformation: Medecin traitant (PV1.17.1)
        *******************************************************************************************
    -->
    <xsl:template name="PV1.17.1">
        <xsl:element name="PV1.17.1">
            <xsl:choose>
                <xsl:when test="/HL7/PV1/PV1.2.1 = 'E' and string-length(/HL7/PV1/PV1.17.1) = 0">""</xsl:when>
                <xsl:when test="string-length(/HL7/PV1/PV1.17.1) = 6">                   
                    <xsl:choose>
                        <xsl:when test="substring(/HL7/PV1/PV1.17.1, 1, 1) != '1'">
                            <xsl:value-of select="/HL7/PV1/PV1.17.1"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring(/HL7/PV1/PV1.17.1, 2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="string-length(/HL7/PV1/PV1.17.1) = 7">
                    <xsl:choose>
                        <xsl:when test="substring(/HL7/PV1/PV1.17.1, 1, 1) != '1'">
                            <xsl:value-of select="substring(/HL7/PV1/PV1.17.1, 1, 6)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="substring(/HL7/PV1/PV1.17.1, 2, 5)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="/HL7/PV1/PV1.17.1"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>


</xsl:stylesheet>
