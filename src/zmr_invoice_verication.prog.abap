REPORT ZTEST no standard page heading line-size  155.

Tables: EKBE, lfa1,ekko.


TYPE-POOLS: SLIS.
Types: Begin of t_itab.
          Include structure EKBE.
Types:    Lifnr  like ekko-lifnr,
          name1   like lfa1-name1,
       End of t_itab.

*------- Mehrfachselektion Lieferschein ------------------------------*
DATA: BEGIN OF ymsel_lifs OCCURS 1.
        INCLUDE STRUCTURE rbsellifs.
DATA: END OF ymsel_lifs.
DATA: BEGIN OF xmsel_lifs OCCURS 1.
        INCLUDE STRUCTURE rbsellifs.
DATA: END OF xmsel_lifs.

*------- selection criteria --------------------------------------------
TYPES: mrm_tab_sellifs LIKE rbsellifs OCCURS 1.        " INS ALRK245986

Types: Begin of t_result,
         lifnr  like ekko-lifnr,
         budat  like ekbe-budat,
         ebeln  like ekbe-ebeln,
         ebelp  like ekbe-ebelp,
         belnr1 like ekbe-belnr,
         belnr2 like ekbe-belnr,
         xblnr  like ekbe-belnr,
         lfbnr  like ekbe-lfbnr,
         belnr  like ekbe-belnr,
         dmbtr  like ekbe-dmbtr,
         REFWR  like ekbe-REFWR,
          name1   like lfa1-name1,
       End of t_result.

Data: Begin of itab occurs 0,
         lifnr  like ekko-lifnr,
         name1   like lfa1-name1,
         budat  like ekbe-budat,
         grdat  like ekbe-budat,
         ebeln  like ekbe-ebeln,
         ebelp  like ekbe-ebelp,
         belnr1 like ekbe-belnr,
         belnr2 like ekbe-belnr,
         belnr3 like ekbe-belnr,
         xblnr  like ekbe-belnr,
         lfbnr  like ekbe-lfbnr,
         belnr  like ekbe-belnr,
         dmbtr  like ekbe-dmbtr,
         dmbtr2 like ekbe-dmbtr,
         REFWR  like ekbe-REFWR,
         werks  like ekbe-werks,
       End of itab.
DATA: TA_SORT TYPE SLIS_T_SORTINFO_ALV.


 Data: i_itab type t_itab occurs 0,
       i_itab1 type t_itab occurs 0,
       i_itab2 type t_itab occurs 0,
       i_itab3 type t_itab occurs 0,
       wa_itab type t_itab,
       wa_itab2 type t_itab,
       i_result type t_result occurs 0,
       wa_Result type t_result,
       va_nou type i,
       vgabe   like ekbe-vgabe,
       lifnr like ekko-lifnr,
       ebeln like ekbe-ebeln,
       ebelp like ekbe-ebelp,
       sw.

DATA: BEGIN OF GT_OUTTAB OCCURS 0.
        INCLUDE STRUCTURE itab.
DATA: END OF GT_OUTTAB,
      GS_LAYOUT TYPE SLIS_LAYOUT_ALV,
      G_EXIT_CAUSED_BY_CALLER,
      GS_EXIT_CAUSED_BY_USER TYPE SLIS_EXIT_BY_USER,
      G_REPID LIKE SY-REPID.

DATA:
    GT_EVENTS      TYPE SLIS_T_EVENT,
    GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
    G_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
    XIT_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV,
    XIS_PRINT      TYPE SLIS_PRINT_ALV.

DATA:  E_SAVE(1) TYPE C,
       ER_SP_GROUP TYPE SLIS_T_SP_GROUP_ALV,
       E_EXIT(1) TYPE C,
       ER_VARIANT LIKE DISVARIANT,
       E_VARIANT LIKE DISVARIANT,
       E_USER_COMMAND TYPE SLIS_FORMNAME VALUE 'USER_COMMAND'.

data:
       v_line_size type i,
       v_line_size_sum type i,
       c1    type i,
       c2    type i,
       c3    type i,
       c4    type i,  w0    type i,
       w1    type i,  w2    type i,  w3    type i,  w4    type i,
       w5    type i,  w6    type i,  w7    type i,  w8    type i,
       w9    type i,  w10   type i,  w11   type i,  w12   type i,
       w13   type i,  w14   type i,  w15   type i,  w16   type i,
       w17   type i,  w18   type i,  w19   type i,  w19a  type i,
       w20   type i,  w17a  type i,
       w21   type i,  w22   type i,  w23   type i,  w24   type i,
       w25   type i,  w26   type i,  w27   type i,  w28   type i,
       w29   type i,  w30   type i,  w31   type i,  w32   type i,
       w33   type i,  w34   type i,  w35   type i.
RANGES: so_BElnr for EKBE-Belnr.

SELECTION-SCREEN BEGIN OF BLOCK AAA WITH FRAME TITLE TEXT-AAA.
select-options : so_EBELN for EKBE-EBELN,
                 so_Blnr1 for EKBE-Belnr,
                 so_blnr2 for EKBE-Belnr,
                 so_xblnr for ekbe-xblnr,
                 so_lifr  for lfa1-lifnr,
                 so_budat for ekbe-budat,
                 so_irdat for ekbe-budat,
                 so_werks for ekbe-werks.
selection-screen skip.

SELECTION-SCREEN BEGIN OF BLOCK BLOCK2 WITH FRAME TITLE TEXT-002.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : radio1 RADIOBUTTON GROUP GRP1 DEFAULT 'X'.
    SELECTION-SCREEN : COMMENT 5(35) TEXT-003.
  SELECTION-SCREEN END OF LINE.
  SELECTION-SCREEN BEGIN OF LINE.
    PARAMETERS : Radio2 RADIOBUTTON GROUP GRP1.
    SELECTION-SCREEN : COMMENT 5(35) TEXT-004.
  SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK BLOCK2.

selection-screen skip.
PARAMETERS: P_VARI LIKE DISVARIANT-VARIANT.

SELECTION-SCREEN END OF BLOCK AAA.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_Blnr1-low.
  PERFORM BELEG_SUCHEN Using so_Blnr1-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_Blnr1-high.
  PERFORM BELEG_SUCHEN Using so_Blnr1-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_Blnr2-low.
  PERFORM F4_MIRO Using so_Blnr2-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_Blnr2-high.
  PERFORM F4_MIRO Using so_Blnr2-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_xblnr-low.
  PERFORM f4_lfsnr.

*AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_xblnr-high.
*  PERFORM f4_lfsnr Using so_xblnr-high.

************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  G_REPID = SY-REPID.
  PERFORM BUILD_FIELDCAT.
  PERFORM LAYOUT_INIT USING GS_LAYOUT.
  PERFORM EVENTTAB_BUILD USING GT_EVENTS[].
  PERFORM FILL_SORT.

  PERFORM SP_GROUP_BUILD USING ER_SP_GROUP[].

  PERFORM reuse_berechtigung_setzen(sapmv75a)
          CHANGING e_save.

  PERFORM VARIANT_INIT.
  ER_VARIANT = E_VARIANT.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
       EXPORTING
            I_SAVE     = E_SAVE
       CHANGING
            CS_VARIANT = ER_VARIANT
       EXCEPTIONS
            NOT_FOUND  = 2.
  IF SY-SUBRC = 0.
    P_VARI = ER_VARIANT-VARIANT.
  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_VARI.
  PERFORM F4_FOR_VARIANT.

AT SELECTION-SCREEN.
  PERFORM PAI_OF_SELECTION_SCREEN.
*********************************** ALV *******************************

END-OF-SELECTION.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
  PERFORM SELECT_DATA.
END-OF-SELECTION.

  PERFORM COMMENT_BUILD USING GT_LIST_TOP_OF_PAGE[].

*"Display List
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
        I_BACKGROUND_ID    = 'ALV_BACKGROUND'
        I_CALLBACK_PROGRAM = G_REPID
        I_CALLBACK_USER_COMMAND  = E_USER_COMMAND
        IS_LAYOUT          = GS_LAYOUT
        IT_FIELDCAT        = XIT_FIELDCAT[]
        IT_SPECIAL_GROUPS  = ER_SP_GROUP
        IT_SORT            = TA_SORT[]
        I_SAVE             = E_SAVE
        IS_VARIANT         = ER_VARIANT
        IT_EVENTS          = GT_EVENTS[]
*        IS_PRINT           = XIS_PRINT
    IMPORTING
        E_EXIT_CAUSED_BY_CALLER = G_EXIT_CAUSED_BY_CALLER
        ES_EXIT_CAUSED_BY_USER  = GS_EXIT_CAUSED_BY_USER
    TABLES
        T_OUTTAB = ITAB
    EXCEPTIONS
        PROGRAM_ERROR = 1
        OTHERS        = 2.


*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       Ereigniss TOP_OF_PAGE                                       *
*       event     TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM TOP_OF_PAGE.
     CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
          EXPORTING
             I_LOGO             = 'ENJOYSAP_LOGO'
             IT_LIST_COMMENTARY = GT_LIST_TOP_OF_PAGE.
ENDFORM.


*----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*----------------------------------------------------------------------
*     Statussetzen
*     Status set
*----------------------------------------------------------------------
*    --> EXTAB
*----------------------------------------------------------------------
FORM STANDARD_ER01 USING  EXTAB TYPE SLIS_T_EXTAB.

* DELETE EXTAB WHERE FCODE = '&UMC'.
  DELETE EXTAB WHERE FCODE = '&RNT_PREV'.
  DELETE EXTAB WHERE FCODE = '&LFO'.
  DELETE EXTAB WHERE FCODE = '&NFO'.
*  SET PF-STATUS 'ALVLIST' EXCLUDING EXTAB.

ENDFORM.                    "STANDARD_ER01

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM BUILD_FIELDCAT.
  DATA: XFIELDCAT TYPE SLIS_FIELDCAT_ALV.
****** Buat Column Name
  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'LIFNR'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-FIX_COLUMN   = 'X'.            "TESTING
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 1.
  XFIELDCAT-OUTPUTLEN    = 8.
  XFIELDCAT-KEY          = 'X'.
  XFIELDCAT-REPTEXT_DDIC = 'Vendor No.'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'NAME1'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-FIX_COLUMN   = 'X'.            "TESTING
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 2.
  XFIELDCAT-OUTPUTLEN    = 25.
  XFIELDCAT-REPTEXT_DDIC = 'Vendor Name'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'EBELN'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 3.
  XFIELDCAT-OUTPUTLEN    = 9.
  XFIELDCAT-REPTEXT_DDIC = 'Po No.'.
  XFIELDCAT-KEY          = 'X'.
  XFIELDCAT-hotspot      = 'X'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'EBELP'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 4.
  XFIELDCAT-OUTPUTLEN    = 6.
  XFIELDCAT-KEY          = 'X'.
  XFIELDCAT-REPTEXT_DDIC = 'Item'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'BELNR1'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 5.
  XFIELDCAT-KEY          = 'X'.
  XFIELDCAT-hotspot      = 'X'.
  XFIELDCAT-OUTPUTLEN    = 9.
  XFIELDCAT-REPTEXT_DDIC = 'GR No.'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'BELNR3'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 6.
  XFIELDCAT-KEY          = 'X'.
  XFIELDCAT-hotspot      = 'X'.
  XFIELDCAT-OUTPUTLEN    = 9.
  XFIELDCAT-REPTEXT_DDIC = 'GR Ret No.'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'BELNR2'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 7.
  XFIELDCAT-KEY          = 'X'.
  XFIELDCAT-hotspot      = 'X'.
  XFIELDCAT-OUTPUTLEN    = 8.
  XFIELDCAT-REPTEXT_DDIC = 'Invoice No.'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'XBLNR'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 8.
*  XFIELDCAT-KEY          = 'X'.
  XFIELDCAT-hotspot      = 'X'.
  XFIELDCAT-OUTPUTLEN    = 10.
  XFIELDCAT-REPTEXT_DDIC = 'Delivery'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'GRDAT'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 9.
  XFIELDCAT-OUTPUTLEN    = 8.
  XFIELDCAT-REPTEXT_DDIC = 'GR Date'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'BUDAT'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 10.
  XFIELDCAT-OUTPUTLEN    = 8.
  XFIELDCAT-REPTEXT_DDIC = 'IR Date'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'DMBTR'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
*  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 11.
  XFIELDCAT-OUTPUTLEN    = 17.
  XFIELDCAT-CURRENCY     = 'IDR'.
  XFIELDCAT-REPTEXT_DDIC = 'GR Amount'.
*  XFIELDCAT-do_sum       = 'X'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'DMBTR2'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
*  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 12.
  XFIELDCAT-OUTPUTLEN    = 17.
  XFIELDCAT-CURRENCY     = 'IDR'.
  XFIELDCAT-REPTEXT_DDIC = 'GR Ret Amount'.
*  XFIELDCAT-do_sum       = 'X'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'REFWR'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
*  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 13.
  XFIELDCAT-CURRENCY     = 'IDR'.
  XFIELDCAT-REPTEXT_DDIC = 'Amount Invoice'.
  XFIELDCAT-OUTPUTLEN    = 17.
*  XFIELDCAT-do_sum       = 'X'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.

  CLEAR XFIELDCAT.
  XFIELDCAT-FIELDNAME    = 'WERKS'.
  XFIELDCAT-TABNAME      = 'GT_OUTTAB'.
  XFIELDCAT-REF_TABNAME   = 'ITAB'.
  XFIELDCAT-ROW_POS      = 1.
  XFIELDCAT-COL_POS      = 14.
  XFIELDCAT-OUTPUTLEN    = 5.
  XFIELDCAT-REPTEXT_DDIC = 'Plant'.
  APPEND XFIELDCAT TO XIT_FIELDCAT.


ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM LAYOUT_INIT USING RS_LAYOUT TYPE SLIS_LAYOUT_ALV.
*  RS_LAYOUT-DETAIL_POPUP      = 'X'.
*  RS_LAYOUT-COLWIDTH_OPTIMIZE = 'X'.
  RS_LAYOUT-ZEBRA             = 'X'.

ENDFORM.                    " LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM EVENTTAB_BUILD USING RT_EVENTS TYPE SLIS_T_EVENT.
*"Registration of events to happen during list display
  DATA: LS_EVENT TYPE SLIS_ALV_EVENT.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
      EXPORTING
           I_LIST_TYPE = 0
      IMPORTING
           ET_EVENTS   = RT_EVENTS.

  READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_TOP_OF_PAGE
                           INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE G_TOP_OF_PAGE TO LS_EVENT-FORM.
    APPEND LS_EVENT TO RT_EVENTS.
  ENDIF.

  READ TABLE RT_EVENTS WITH KEY NAME = SLIS_EV_USER_COMMAND
                           INTO LS_EVENT.
  IF SY-SUBRC = 0.
    MOVE E_USER_COMMAND TO LS_EVENT-FORM.
    APPEND LS_EVENT TO RT_EVENTS.
  ENDIF.

ENDFORM.                    " EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*&      Form  FILL_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM FILL_SORT.
  DATA: FIELDSORT TYPE SLIS_SORTINFO_ALV.
***** Sort Data
  FIELDSORT-SPOS = '1'.
  FIELDSORT-FIELDNAME = 'WERKS'.
  FIELDSORT-UP   = 'X'.
  FIELDSORT-SUBTOT = 'X'.
  FIELDSORT-EXPA   = 'X'.
  APPEND FIELDSORT TO TA_SORT.

  FIELDSORT-SPOS = '2'.
  FIELDSORT-FIELDNAME = 'LIFNR'.
  FIELDSORT-UP   = 'X'.
  FIELDSORT-SUBTOT = 'X'.
  FIELDSORT-EXPA   = 'X'.
  APPEND FIELDSORT TO TA_SORT.

  FIELDSORT-SPOS = '3'.
  FIELDSORT-FIELDNAME = 'NAME1'.
  FIELDSORT-UP   = 'X'.
  FIELDSORT-SUBTOT = 'X'.
  FIELDSORT-EXPA   = 'X'.
  APPEND FIELDSORT TO TA_SORT.

  FIELDSORT-SPOS = '4'.
  FIELDSORT-FIELDNAME = 'EBELN'.
  FIELDSORT-UP   = 'X'.
  FIELDSORT-SUBTOT = 'X'.
  FIELDSORT-EXPA   = 'X'.
  APPEND FIELDSORT TO TA_SORT.

  FIELDSORT-SPOS = '5'.
  FIELDSORT-FIELDNAME = 'EBELP'.
  FIELDSORT-UP   = 'X'.
  FIELDSORT-SUBTOT = 'X'.
  FIELDSORT-EXPA   = 'X'.
  APPEND FIELDSORT TO TA_SORT.

  FIELDSORT-SPOS = '6'.
  FIELDSORT-FIELDNAME = 'BELNR1'.
  FIELDSORT-UP   = 'X'.
  FIELDSORT-SUBTOT = 'X'.
  FIELDSORT-EXPA   = 'X'.
  FIELDSORT-comp   = 'X'.
  FIELDSORT-expa   = 'X'.
  FIELDSORT-obligatory   = 'X'.
  APPEND FIELDSORT TO TA_SORT.
ENDFORM.                    " FILL_SORT
*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
FORM SELECT_DATA.
Data : t_buzei like MSEG-ZEILE,
       t_gjahr like MSEG-MJAHR.

IF SO_BLNR1 IS INITIAL.
ELSE.
    APPEND lines of SO_BLNR1 TO SO_BELNR.
ENDIF.
IF SO_BLNR2 IS INITIAL.
ELSE.
    APPEND lines of SO_BLNR2 TO SO_BELNR.
ENDIF.
* Select GR Data
Select  * INTO CORRESPONDING FIELDS OF TABLE i_itab1
           From EKBE as a join ekko as b on a~ebeln eq b~ebeln
                join lfa1 as c on b~lifnr eq c~lifnr
                join ekpo as d on d~ebeln  eq a~ebeln and
                                  d~ebelp eq a~ebelp
           Where a~EBELN in so_EBELN and
                 a~zekkn eq '00'     and
                 a~belnr in so_belnr and
                 a~Budat in so_budat and
                 a~werks in so_werks and
                 a~bwart ne '102'    and
                 a~bwart ne '162'    and
                 a~bwart ne '122'    and
                 a~bwart ne '123'    and
                 b~lifnr in so_lifr  and
                 a~xblnr in so_xblnr and
                 a~vgabe eq '1' and
                 d~loekz eq space
           Order by b~lifnr a~ebeln a~ebelp a~lfbnr.
* Select IR Data
Select  * INTO CORRESPONDING FIELDS OF TABLE i_itab2
           From EKBE as a join ekko as b on a~ebeln eq b~ebeln
                join lfa1 as c on b~lifnr eq c~lifnr
                join ekpo as d on d~ebeln  eq a~ebeln and
                                  d~ebelp eq a~ebelp
           Where a~EBELN in so_EBELN and
                 a~zekkn eq '00'     and
                 a~belnr in so_belnr and
                 a~Budat in so_irdat and
                 a~werks in so_werks and
                 b~lifnr in so_lifr  and
                 a~xblnr in so_xblnr and
                 a~vgabe eq '2' and
                 d~loekz eq space
           Order by b~lifnr a~ebeln a~ebelp a~lfbnr.

Loop at i_itab2 into wa_itab.

Move-corresponding wa_itab to wa_itab2.

* Cek apakah invoice sudah di cancel
     Select single stblg stjah into (wa_itab-belnr, wa_itab-gjahr)
            from rbkp
            where  belnr = wa_itab-belnr and
                   gjahr = wa_itab-gjahr and
                   lifnr = wa_itab-lifnr and
                   rbstat = '5'.

* Jika ya
     if wa_itab-belnr ne space and wa_itab-gjahr ne space.
* Delete data yang udah di cancel
         delete i_itab2.
* Add by MKO on 15-04-2003 to correct cancel GR
     else.
* Cek apakah material document sudah di cancel
     Select single mblnr zeile into (wa_itab-belnr,  wa_itab-buzei)
            from mseg
             where smbln eq wa_itab2-lfbnr and
                   sjahr eq wa_itab2-lfgja and
                   smblp eq wa_itab2-buzei and
                   matnr eq wa_itab2-matnr.
* Jika ya
    if sy-subrc eq 0.
         Select BELNR into wa_itab2-lfbnr
         from EKBE
         where ebeln = wa_itab2-ebeln and
               ebelp = wa_itab2-ebelp and
               zekkn = '00'   and
               vgabe = '1'    and
               bwart = '101' and
               xblnr = wa_itab2-xblnr and
               lfgja = wa_itab2-lfgja.
         Endselect.
         modify i_itab2 from wa_itab2.
     endif.
     endif.
     Clear wa_itab.
Endloop.

Clear i_itab3.
Loop at i_itab1 into wa_itab.
* Cek apakah material document sudah di cancel
     Select single mblnr zeile into (wa_itab-belnr,  wa_itab-buzei)
            from mseg
             where smbln eq wa_itab-Belnr and
                   sjahr eq wa_itab-gjahr and
                   smblp eq wa_itab-buzei and
                   matnr eq wa_itab-matnr.

* Jika ya
    if sy-subrc eq 0.
* Masukkan ke tabel data cancel
         Append  wa_itab to i_itab3.
         Continue.
    endif.
* Baca internal tabel data invoice
*    READ TABLE I_ITAB2 INTO WA_ITAB2
*    WITH KEY LIFNR = wa_itab-lifnr
*             EBELN = wa_itab-EBELN
*             EBELP = wa_itab-EBELP
*             LFBNR = wa_itab-Belnr
*    BINARY SEARCH.
    Loop at I_ITAB2 INTO WA_ITAB2
    Where LIFNR = wa_itab-lifnr and
          EBELN = wa_itab-EBELN and
          EBELP = wa_itab-EBELP and
          LFBNR = wa_itab-Belnr.
    Endloop.

* Jika tidak ada
    if sy-subrc ne 0.
        Append  wa_itab to i_itab .
    Endif.
Endloop.

Loop at i_itab3 into wa_itab.
    Loop at i_itab into wa_itab2 where lifnr = wa_itab-lifnr and
                                       belnr = wa_itab-belnr and
                                       buzei = wa_itab-buzei.
           delete i_itab.
    Endloop.
    Clear wa_itab.

Endloop.
if radio1 = 'X'.
   append lines of i_itab2 to i_itab.
Endif.

   DESCRIBE TABLE i_itab LINES c1.
   if c1 <= 0.
         Exit.
   endif.
sw = 0.
Loop at i_itab into wa_itab.
Clear : itab-belnr3, itab-dmbtr2, t_buzei, t_gjahr.
    Move wa_itab-lifnr to ITAB-lifnr.
    Move wa_itab-ebeln to ITAB-ebeln.
    Move wa_itab-ebelp to ITAB-ebelp.

    Move wa_itab-werks to ITAB-werks.
    Move wa_itab-lifnr to lifnr.
    Move wa_itab-ebeln to ebeln.
    Move wa_itab-ebelp to ebelp.
    move wa_itab-xblnr to ITAB-xblnr.
    Move wa_itab-name1 to ITAB-name1.
    move wa_itab-REFWR to ITAB-REFWR.
    if not ( wa_itab-lfbnr is initial ) and wa_itab-vgabe = '2'.
         Move wa_itab-lfbnr to ITAB-belnr1.
         Select single BUDAT from MKPF into ITAB-grdat
         Where MBLNR = wa_itab-lfbnr and MJAHR = wa_itab-lfgja.
* Select GR Value for Invoice data
         Select single DMBTR from EKBE into ITAB-dmbtr
         Where ebeln = wa_itab-ebeln and
               ebelp = wa_itab-ebelp and
               zekkn = '00'   and
               vgabe = '1'    and
               bwart ne '102' and
               bwart ne '162' and
               bwart ne '122' and
               bwart ne '123' and
               gjahr = wa_itab-lfgja and
               belnr = wa_itab-lfbnr and
               buzei = wa_itab-lfpos and
               xblnr = wa_itab-xblnr.
    Else.
        move wa_itab-dmbtr to ITAB-dmbtr.
    Endif.
    if wa_itab-shkzg = 'H'.
        ITAB-REFWR = ITAB-REFWR * -1.
        ITAB-dmbtr = ITAB-dmbtr * -1.
    Endif.
    Sw = 1.
    Move wa_itab-vgabe to vgabe.
    Case wa_itab-vgabe.
       When '1'.
          Move wa_itab-belnr to ITAB-belnr1.
          Move wa_itab-budat to ITAB-grdat.
       When '2'.
          Move wa_itab-belnr to ITAB-belnr2.
          Move wa_itab-budat to ITAB-budat.
       When Others.
          Move wa_itab-belnr to ITAB-belnr.
    Endcase.
    If wa_itab-bwart = '101' or wa_itab-bwart = ''.
       Select BELNR BUZEI GJAHR DMBTR
       into (itab-belnr3 , t_buzei , t_gjahr , itab-dmbtr2)
       from EKBE
       where ebeln = wa_itab-ebeln and
             ebelp = wa_itab-ebelp and
             zekkn = '00'   and
             vgabe = '1'    and
             bwart = '122' and
             xblnr = wa_itab-xblnr and
             lfbnr = wa_itab-lfbnr and
             lfgja = wa_itab-lfgja and
             lfpos = wa_itab-lfpos.
        Endselect.

       If SY-SUBRC = 0.
* Cek apakah material document sudah di cancel
       Select single smbln into itab-belnr3
       from mseg
       where smbln eq itab-belnr3 and
             sjahr eq t_gjahr and
             smblp eq t_buzei.
       If SY-SUBRC = 0.
           Clear : itab-belnr3, itab-dmbtr2.
       Else.
           ITAB-dmbtr2 = ITAB-dmbtr2 * -1.
       Endif.
       Endif.
    Endif.
    append itab.
  Clear wa_result.
Endloop.
ENDFORM.                    " SELECT_DATA
*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM COMMENT_BUILD USING LT_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER.
  DATA: LS_LINE TYPE SLIS_LISTHEADER.
  DATA: U_DATE(15) TYPE C.
****** Buat Header Line


  write sy-datum  to  u_date.

  WRITE SY-DATUM to u_date.
* LIST HEADING LINE: TYPE H
  CLEAR LS_LINE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = TEXT-100.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.

  CLEAR LS_LINE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = u_date.
  APPEND LS_LINE TO LT_TOP_OF_PAGE.

  CLEAR LS_LINE.
  LS_LINE-TYP  = 'H'.
  LS_LINE-INFO = SY-UNAME .
  APPEND LS_LINE TO LT_TOP_OF_PAGE.
ENDFORM.                    " COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  SP_GROUP_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_SP_GROUP[]  text
*----------------------------------------------------------------------*
FORM SP_GROUP_BUILD USING U_ER_SP_GROUP TYPE SLIS_T_SP_GROUP_ALV.

  DATA: LS_SP_GROUP TYPE SLIS_SP_GROUP_ALV.
  CLEAR  LS_SP_GROUP.
  LS_SP_GROUP-SP_GROUP = 'A'.
  LS_SP_GROUP-TEXT     = 'Standart'.
  APPEND LS_SP_GROUP TO U_ER_SP_GROUP.

ENDFORM.                               " SP_GROUP_BUILD
*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VARIANT_INIT.
  CLEAR E_VARIANT.
  E_VARIANT-REPORT = G_REPID.
ENDFORM.                    " VARIANT_INIT
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
FORM F4_FOR_VARIANT.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
       EXPORTING
            IS_VARIANT          = E_VARIANT
            I_SAVE              = E_SAVE
*           it_default_fieldcat =
       IMPORTING
            E_EXIT              = E_EXIT
            ES_VARIANT          = ER_VARIANT
       EXCEPTIONS
            NOT_FOUND = 2.
  IF SY-SUBRC = 2.
    MESSAGE ID SY-MSGID TYPE 'S'      NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    IF E_EXIT = SPACE.
      P_VARI = ER_VARIANT-VARIANT.
    ENDIF.
  ENDIF.

ENDFORM.                    " F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*&      Form  PAI_OF_SELECTION_SCREEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM PAI_OF_SELECTION_SCREEN.
  IF NOT P_VARI IS INITIAL.
    MOVE E_VARIANT TO ER_VARIANT.
    MOVE P_VARI TO ER_VARIANT-VARIANT.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE' " Überpr. des Ex. einer
         EXPORTING                     " Vari. auf der DB.
              I_SAVE     = E_SAVE
         CHANGING
              CS_VARIANT = ER_VARIANT.
    E_VARIANT = ER_VARIANT.
  ELSE.
    PERFORM VARIANT_INIT.
  ENDIF.
ENDFORM.                    " PAI_OF_SELECTION_SCREEN


*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       AT USER COMMAND                                               *
*---------------------------------------------------------------------*
*       --> R_UCOMM                                                   *
*       --> RS_SELFIELD                                               *
*---------------------------------------------------------------------*
FORM USER_COMMAND USING R_UCOMM LIKE SY-UCOMM
                  RS_SELFIELD TYPE SLIS_SELFIELD.
  DATA: FELD(10) TYPE C, V_MJAHR(4).

  RS_SELFIELD-REFRESH = 'X'.
  CASE R_UCOMM.
    WHEN  'FEHL' OR '&IC1'.
       case RS_SELFIELD-SEL_TAB_FIELD.
               when 'GT_OUTTAB-EBELN'.
                   set parameter id  'BES' field RS_SELFIELD-VALUE.
                   call transaction 'ME23' and skip first screen.
               when 'GT_OUTTAB-BELNR1'.
                   set parameter id  'MBN' field RS_SELFIELD-VALUE.
                   Clear V_MJAHR.
                   Select single max( MJAHR ) into V_MJAHR
                   from MKPF where MBLNR = RS_SELFIELD-VALUE.
                   set parameter id  'MJA' field V_MJAHR.
                   call transaction 'MB03' and skip first screen.
               when 'GT_OUTTAB-BELNR2'.
                   set parameter id  'RBN' field RS_SELFIELD-VALUE.
                   call transaction 'MIR4' and skip first screen.
               when 'GT_OUTTAB-BELNR3'.
                   set parameter id  'MBN' field RS_SELFIELD-VALUE.
                   Clear V_MJAHR.
                   Select single max( MJAHR ) into V_MJAHR
                   from MKPF where MBLNR = RS_SELFIELD-VALUE.
                   set parameter id  'MJA' field V_MJAHR.
                   call transaction 'MB03' and skip first screen.
               when 'GT_OUTTAB-XBLNR'.
                   set parameter id  'VL' field RS_SELFIELD-VALUE.
                   call transaction 'VL03N' and skip first screen.
       Endcase.
      RS_SELFIELD-COL_STABLE = 'X'.
      RS_SELFIELD-ROW_STABLE = 'X'.
      GS_LAYOUT-INFO_FIELDNAME    = 'ITAB-COL'.
  ENDCASE.

ENDFORM.                    "USER_COMMAND


*---------------------------------------------------------------------*
*       FORM BELEG_SUCHEN                                             *
*---------------------------------------------------------------------*
*       AT SELECTION SCREEEN                                          *
*---------------------------------------------------------------------*
FORM BELEG_SUCHEN USING pa_mblnr like MSEG-MBLNR.
  DATA: FLAG(1), MVMT like MSEG-BWART.
  FLAG  = 'X'.
  MVMT  = '101'.
  EXPORT FLAG TO MEMORY ID 'MB51_FLAG'.
  SET PARAMETER ID 'BWA' FIELD MVMT.
  CALL TRANSACTION 'MB51'.
  GET PARAMETER ID 'MBN' FIELD pa_mblnr.
*  GET PARAMETER ID 'MJA' FIELD pa_mjahr-low.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM F4_MIRO                                                  *
*---------------------------------------------------------------------*
*       AT SELECTION SCREEEN                                          *
*---------------------------------------------------------------------*
FORM F4_MIRO USING pa_BELNR like RBKP-BELNR.
  DATA: FLAG(1).
  FLAG  = 'X'.
  EXPORT FLAG TO MEMORY ID 'MIR6_FLAG'.
  CALL TRANSACTION 'ZM46'.
  GET PARAMETER ID 'RBN' FIELD pa_BELNR.
ENDFORM.

*---------------------------------------------------------------------*
*       FORM F4_LFSNR                                                *
*---------------------------------------------------------------------*
*       AT SELECTION SCREEEN                                          *
*---------------------------------------------------------------------*
FORM f4_lfsnr.

DATA: counter TYPE i.

CLEAR xmsel_lifs.
REFRESH xmsel_lifs.

    PERFORM rm08rl80_aufrufen TABLES xmsel_lifs.   "<--->

      If so_xblnr is initial.
         append so_xblnr.
*      Else.
*         READ TABLE pa_xblnr INDEX 1.
*         Append pa_xblnr.
      Endif.
      Loop at xmsel_lifs.
        so_xblnr-SIGN = 'I'.
        so_xblnr-OPTION = 'EQ'.
        so_xblnr-low = xmsel_lifs-lfsnr.
        Append so_xblnr.
      Endloop.
*     DESCRIBE TABLE pa_xblnr LINES Counter.
*     Delete pa_xblnr INDEX Counter.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  RM08RL80_AUFRUFEN
*&---------------------------------------------------------------------*
*       Ruft den Report RM08RL80 auf, der Lieferscheine selektiert.
*       Die selektierten Belege werden mit der Tabelle IT_LIFS
*       abgemischt.
*----------------------------------------------------------------------*
* <---> IT_LIFS:  (bereits) selektierte EKBelege
*----------------------------------------------------------------------*
FORM rm08rl80_aufrufen TABLES it_lifs TYPE mrm_tab_sellifs.

  RANGES: rg_werks   FOR rm08m-werks,
          rg_lifnr   FOR ekko-lifnr.
  DATA:   t_sellifs  TYPE mrm_tab_sellifs,
          s_lifs     LIKE rbsellifs,
          anz_zeilen TYPE i.

  rg_werks-sign   = 'I'.
  rg_werks-option = 'EQ'.
  Get Parameter ID 'WRK' field rg_werks-low.
  APPEND rg_werks.

  rg_lifnr-sign   = 'I'.
  rg_lifnr-option = 'EQ'.
  Get Parameter ID ' LIF' field rg_lifnr-low.
  APPEND rg_lifnr.

* Report aufrufen
  SUBMIT rm08rl80 VIA SELECTION-SCREEN AND RETURN
                  WITH so_lifnr in rg_lifnr
*                  WITH pa_bukrs eq '8020'
                  WITH so_werks IN rg_werks.

* Einträge importieren
  CLEAR t_sellifs[].
  IMPORT t_sellifs FROM MEMORY ID 'RM08RL80_SEL'.
  IF ( sy-subrc <> 0 ).                "keine Belege selektiert
    REFRESH xmsel_lifs.
    DESCRIBE TABLE ymsel_lifs LINES anz_zeilen.
    IF anz_zeilen = 0.
      EXIT.
    ENDIF.
    APPEND ymsel_lifs TO xmsel_lifs.   "restore original situation..
    EXIT.
  ENDIF.
  FREE MEMORY ID 'RM08RL80_SEL'.

* bereits selektierte Einträge mit importierten abmischen
  LOOP AT t_sellifs INTO s_lifs.
    APPEND s_lifs TO it_lifs.
  ENDLOOP.

ENDFORM.                               "RM08RL80_AUFRUFEN
