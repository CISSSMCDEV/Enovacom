
<!-- 
     No. Date       User     Description / commentaires (Optionnel)
     +++ ++++++++++ ++++++++ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 
     1   2020-07-16 TC   Création
     2   2021-04-20 EG   Version normée avec l'équipe de développement
-->
<xsl:stylesheet xmlns:exsl="http://exslt.org/common"
   xmlns:functx="http://www.functx.com"
   xmlns:util="http://whatever"
   xmlns:xp="http://www.w3.org/2005/xpath-functions"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   exclude-result-prefixes="#all"
   extension-element-prefixes="exsl"
   version="3.0">

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
   
</xsl:stylesheet>