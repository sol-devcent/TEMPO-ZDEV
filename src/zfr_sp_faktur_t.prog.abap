*----------------------------------------------------------------------*
*   INCLUDE ZFR_SP_FAKTUR_T                                            *
*----------------------------------------------------------------------*
TABLES :  tvkbt,      "Organizational Unit: Sales Offices: Texts
          tspat,      "Organizational Unit: Sales Divisions: Texts
          vbfa,
          vbak,
          knvv,
          tvkol,
          zsl_hsales,
          zplbc,
          zfvato.     "VAT-Out   PRINT  DOCUMENT

TYPES  :  BEGIN OF ttab1,
            vkbur  LIKE  zfvato-vkbur,
            bezei  LIKE  tvkbt-bezei,
            spart  LIKE  zfvato-spart,
            vtext  LIKE  tspat-vtext,
            zuonr  LIKE  zfvato-zuonr,
            kunde  LIKE  zfvato-kunde,
            erdat  LIKE  zfvato-erdat,
            fkdat  LIKE  zfvato-fkdat,
            dudat  LIKE  zfvato-dudat,
            ihrez  LIKE  zfvato-ihrez,
            kunrg  LIKE  zfvato-kunrg,
            name_co  LIKE  zfvato-name_co,
            stceg  LIKE  zfvato-stceg,
            cityc  LIKE  zfvato-cityc,
            vatpr  LIKE  zfvato-vatpr,
            tkwert LIKE  zfvato-tkwert,
            mwsbk  LIKE  zfvato-mwsbk,
            netwr  LIKE  zfvato-netwr,
            fkart  LIKE  zfvato-fkart,
            vbeln  LIKE  zfvato-vbeln,
            vbtyp  LIKE  zfvato-vbtyp,
            vbelv  LIKE  vbfa-vbelv,
            auart  LIKE  vbak-auart,
            vkbur1  LIKE  zfvato-vkbur,
            ktgrd  LIKE  vbrk-ktgrd,
          END OF ttab1.

TYPES  :  BEGIN OF ttab2,
            bezei  LIKE  tvkbt-bezei,
            erdat  LIKE  zfvato-erdat,
            fkdat  LIKE  zfvato-fkdat,
            fkart  LIKE  zfvato-fkart,
            ermon(2),
            spart  LIKE  zfvato-spart,
            ihrez  LIKE  zfvato-ihrez,
            zuonr  LIKE  zfvato-zuonr,
            kunde  LIKE  zfvato-kunde,
            kunrg  LIKE  zfvato-kunrg,
            tkwert LIKE  zfvato-tkwert,
            mwsbk  LIKE  zfvato-mwsbk,
            netwr  LIKE  zfvato-netwr,
          END OF ttab2.

TYPES  :  BEGIN OF ttab3,
            spfno(30),
            bezei  LIKE  tvkbt-bezei,
            vtext  LIKE  tspat-vtext,
            erdat  LIKE  zfvato-erdat,
            fkdat  LIKE  zfvato-fkdat,
            zuonr  LIKE  zfvato-zuonr,
            vatpr  LIKE  zfvato-vatpr,
            kunde  LIKE  zfvato-kunde,
            dudat  LIKE  zfvato-dudat,
            kunrg  LIKE  zfvato-kunrg,
            name_co  LIKE  zfvato-name_co,
            stceg  LIKE  zfvato-stceg,
            cityc  LIKE  zfvato-cityc,
            tkwert LIKE  zfvato-tkwert,
            mwsbk  LIKE  zfvato-mwsbk,
            netwr  LIKE  zfvato-netwr,
            prefx(2),
          END OF ttab3.

DATA   :  BEGIN OF i_tvkbt OCCURS 0,
            vkbur LIKE tvkbt-vkbur,
            bezei LIKE tvkbt-bezei,
          END OF i_tvkbt.

DATA   :  itab1 TYPE ttab1 OCCURS 0 WITH HEADER LINE,
          itab2 TYPE ttab2 OCCURS 0,
          itab3 TYPE ttab3 OCCURS 0,
          va_aubel LIKE vbrp-aubel,
          va_vbeln LIKE vbak-vbeln,
          va_auart LIKE vbak-auart,
          watab1 TYPE ttab1,
          watab2 TYPE ttab2,
          watab3 TYPE ttab3.

DATA   :  vtype(2),
          page  TYPE  i,
          valid(1),
          v_live  LIKE zplbc-live.

DATA   :  val(1) TYPE c,
          pripar TYPE pri_params,
          arcpar TYPE arc_params,
          vplist LIKE pri_params-plist,
          vprtxt LIKE pri_params-prtxt.

CONSTANTS : vlinct LIKE pri_params-linct VALUE 80,
            vlinsz LIKE pri_params-linsz VALUE 202.
