<xsl:stylesheet xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:functx="http://www.functx.com"
    xmlns:util="http://whatever"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" exclude-result-prefixes="#all" version="3.0">
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" omit-xml-declaration="yes" version="1.0"/>
    
    
    <!-- 
        *******************************************************************************************
        Redefinir le template "SoftLab".
        
        Contient les differentes regles de filtrages pour ce systeme.
        *******************************************************************************************
    -->
    <xsl:template name="SoftLab">
        <systeme nom="SoftLab">
            <xsl:variable name="Filtres">
                <xsl:element name="reglesFiltrage">
                    <xsl:call-template name="SoftLab.reglesFiltrage.installation"/>
                    <xsl:call-template name="SoftLab.reglesFiltrage.typeMessage"/>
                    <xsl:call-template name="SoftLab.reglesFiltrage.classePatient"/>
                    <xsl:call-template name="SoftLab.reglesFiltrage.dossierPermanent"/>
                </xsl:element>
            </xsl:variable>
            <xsl:copy-of select="$Filtres"/>
            <xsl:element name="isFiltered">
                <xsl:choose>
                    <xsl:when test="count($Filtres/reglesFiltrage/*[text() = 'false']) > 0">true</xsl:when>
                    <xsl:otherwise>false</xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </systeme>
    </xsl:template>
    
    <!-- 
        *******************************************************************************************
        Regles de filtrage: installations
        *******************************************************************************************
    -->
    <xsl:template name="SoftLab.reglesFiltrage.installation">
        <xsl:element name="installation">
            <xsl:value-of select="matches(/HL7/PID/PID.4[1]/PID.4.6, '51229102|51229193|51229011')" />
        </xsl:element>
    </xsl:template>
    
    <!-- 
        *******************************************************************************************
        Regles de filtrage: type de message
        *******************************************************************************************
    -->
    <xsl:template name="SoftLab.reglesFiltrage.typeMessage">
        <xsl:element name="typeMessage">
            <xsl:value-of select="matches(/HL7/MSH/MSH.9.2, 'A01|A02|A03|A04|A05|A08|A12|A13|A23|A28|A29|A31|A45|A48')" />
        </xsl:element>
    </xsl:template>
    
    <!-- 
        *******************************************************************************************
        Regles de filtrage: classe de patient
        *******************************************************************************************
    -->
    <xsl:template name="SoftLab.reglesFiltrage.classePatient">
        <xsl:element name="classePatient">
            <xsl:choose>
                <xsl:when test="exists(/HL7/PV1) and not(matches(/HL7/PV1/PV1.2.1, 'E|I'))">false</xsl:when>
                <xsl:otherwise>true</xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <!-- 
        *******************************************************************************************
        Regles de filtrage: dossier permanent
        *******************************************************************************************
    -->
    <xsl:variable name="persoDossierPermanent">
        <installation nom="HPB" msss="51229011" dosPermanentMax="3999999"></installation>
        <installation nom="HHM" msss="51229193" dosPermanentMax="4999999"></installation>
        <installation nom="HDS" msss="51229102" dosPermanentMax="999999999"></installation>
    </xsl:variable>
    
    <xsl:variable name="noInstallation" select="/HL7/PID/PID.4[1]/PID.4.6"/>
    <xsl:variable name="valeurMaxDosPermanent" select="number($persoDossierPermanent/installation[@msss = $noInstallation]/@dosPermanentMax)"/>
    
    <xsl:template name="SoftLab.reglesFiltrage.dossierPermanent">
        <xsl:element name="dossierPermanent">
            <xsl:choose>
                <xsl:when test="/HL7/PID/PID.4[1]/PID.4.1 != '' and string(number(/HL7/PID/PID.4[1]/PID.4.1)) != 'NaN' and number(/HL7/PID/PID.4[1]/PID.4.1) &lt;= $valeurMaxDosPermanent">true</xsl:when>
                <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>
