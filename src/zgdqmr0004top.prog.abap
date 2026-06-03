*----------------------------------------------------------------------*
*   INCLUDE RM07MMHT                                                   *
*----------------------------------------------------------------------*
*   Datendefinitionen zum Report RM07MMHD                              *
*----------------------------------------------------------------------*
REPORT rm07mmhd MESSAGE-ID m7 NO STANDARD PAGE HEADING LINE-SIZE 120.

*------------------------ DATENTYPEN ----------------------------------*

TYPE-POOLS:  imrep,                   " Typen Bestandsführungsreporting
             slis.                    " Typen Listviewer

TYPES: BEGIN OF header_typ.
INCLUDE TYPE imrep_matheader_typ.
TYPES:   lgort LIKE mard-lgort,
         lgobe LIKE t001l-lgobe.
TYPES: END OF header_typ.

TYPES: BEGIN OF bestand_typ.
INCLUDE TYPE imrep_matstamm_typ.
TYPES:   menge LIKE mchb-clabs,
         mhdat LIKE mcha-vfdat,
***added for Tempo
         hsdat LIKE mcha-hsdat,
***end of Tempo addition
         einda(7) TYPE c,                     " für Einheit
         einda_vz(7) TYPE c,                  " für Einheit VZ
         verfa TYPE c,                        " 'MHD abgelaufen' Kennz.
         mhdrz_vz LIKE mara-mhdrz,
         ampel TYPE slis_fieldname,
         farbe TYPE slis_t_specialcol_alv.
TYPES: END OF bestand_typ.

*------------------------- TABELLEN -----------------------------------*

TABLES:   mcha,
          mchb,
          v_mmim_lc,
          marcv,
          t001l.

*--------------------- DATENDEKLARATIONEN -----------------------------*

DATA: organ   TYPE imrep_organ_typ OCCURS 0 WITH HEADER LINE.
DATA: header  TYPE header_typ      OCCURS 0 WITH HEADER LINE.
DATA: bestand TYPE bestand_typ     OCCURS 0 WITH HEADER LINE.

DATA:  BEGIN OF itab OCCURS 0,
*        include structure v_mmim_lc.
         matnr LIKE v_mmim_lc-matnr,
         werks LIKE v_mmim_lc-werks,
         lgort LIKE v_mmim_lc-lgort,
         charg LIKE v_mmim_lc-charg,
*        xchpf like v_mmim_lc-xchpf, "MHD nur für chargenpflichtige Mat.
*        lvorm like v_mmim_lc-lvorm, "evtl. zu löschende Mat. ausschl.
*        lvorm_b like v_mmim_lc-lvorm,
*        lvorm_1 like v_mmim_lc-lvorm,
         vfdat LIKE v_mmim_lc-vfdat,
         vfdat_1 LIKE v_mmim_lc-vfdat_1,
         mhdlp LIKE v_mmim_lc-mhdlp,
         mhdhb LIKE v_mmim_lc-mhdhb,
         mhdrz LIKE v_mmim_lc-mhdrz,
         iprkz LIKE v_mmim_lc-iprkz,
         rdmhd LIKE v_mmim_lc-rdmhd,
         meins LIKE v_mmim_lc-meins,
         labst LIKE v_mmim_lc-labst,
*        insme like v_mmim_lc-insme, "nur frei verwendbarer Bestand
*        speme like v_mmim_lc-speme,
*        einme like v_mmim_lc-einme.
***added for Tempo
         hsdat LIKE mcha-hsdat.
***end of Tempo addition
DATA:  END OF itab.

***added for Tempo -- getting HSDAT
DATA BEGIN OF t_mcha OCCURS 1.
DATA:  matnr LIKE mcha-matnr,
       werks LIKE mcha-werks,
       charg LIKE mcha-charg,
       hsdat LIKE mcha-hsdat.
DATA END OF t_mcha.
***end of Tempo addition

DATA:  BEGIN OF imchb OCCURS 0,
*        include structure mchb.
         matnr LIKE mchb-matnr,
         werks LIKE mchb-werks,
         lgort LIKE mchb-lgort,
         charg LIKE mchb-charg,
         lvorm LIKE mchb-lvorm,
         clabs LIKE mchb-clabs. "nur frei verwendbarer Bestand
*        cumlm like mchb-cumlm,
*        cinsm like mchb-cinsm,
*        ceinm like mchb-ceinm,
*        cspem like mchb-cspem,
*        cretm like mchb-cretm.
DATA:  END OF imchb.

*------------------------- HILFSFELDER --------------------------------*

DATA: index_z LIKE sy-tabix,
      mhdat   LIKE mseg-vfdat,
      mhda1   LIKE mseg-vfdat.

*-------------------- FELDER FÜR LISTVIEWER ---------------------------*

DATA: repid    LIKE sy-repid.
DATA: fieldcat TYPE slis_t_fieldcat_alv.
DATA: xheader  TYPE slis_t_listheader WITH HEADER LINE.
DATA: keyinfo  TYPE slis_keyinfo_alv.
DATA: color    TYPE slis_t_specialcol_alv WITH HEADER LINE.
DATA: layout   TYPE slis_layout_alv.
DATA: print    TYPE slis_print_alv.
DATA: sumsort  TYPE slis_t_sortinfo_alv WITH HEADER LINE.

* Listanzeigevarianten
DATA: variante        LIKE disvariant,                " Anzeigevariante
      def_variante    LIKE disvariant,                " Defaultvariante
      variant_exit(1) TYPE c,
      variant_save(1) TYPE c,
      variant_def(1)  TYPE c.
