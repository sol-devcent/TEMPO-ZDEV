REPORT zmr_do_monitor_t.

INCLUDE <icon>.

DATA : cr_gi_tm          TYPE t,
       gi_vs_pk_tm       TYPE t,
       gi_create_tm      TYPE t,
       pk_create_tm      TYPE t,
       pod_vs_gi_tm      TYPE t,
       cr_gi_dt(004)     TYPE p  DECIMALS 00,
       gi_create_dt(004) TYPE p  DECIMALS 00,
       gi_vs_pk_dt(004)  TYPE p  DECIMALS 00,
       pk_create_dt(004) TYPE p  DECIMALS 00,
       pod_vs_gi_dt(004) TYPE p  DECIMALS 00.

TABLES: likp, knvv.

TYPE-POOLS: slis.

TYPES: BEGIN OF t_objectid,
         objectid LIKE cdhdr-objectid,
         changenr LIKE cdpos-changenr,
       END OF t_objectid,

       BEGIN OF t_cdpos,
         objectid LIKE cdpos-objectid,
         changenr LIKE cdpos-changenr,
         fname    LIKE cdpos-fname,
         udate    LIKE cdhdr-udate,
         utime    LIKE cdhdr-utime,
       END OF t_cdpos,

       BEGIN OF t_cdhdr,
         objectid LIKE cdhdr-objectid,
         changenr LIKE cdhdr-changenr,
         udate    LIKE cdhdr-udate,
         utime    LIKE cdhdr-utime,
       END OF t_cdhdr.

DATA: BEGIN OF wa_result,
        lfart        LIKE likp-lfart,
        vstel        LIKE likp-vstel,
        vbeln        LIKE likp-vbeln,
        kunnr        LIKE likp-kunnr,
        erdat        LIKE likp-erdat,
        erzet        LIKE likp-erzet,
        podat        LIKE likp-podat,
        potim        LIKE likp-potim,
        wadat_ist    LIKE likp-wadat_ist,
        crdat        LIKE zmm_cust_rec-crdat,
        crtim        LIKE zmm_cust_rec-crtim,
        kdgrp        LIKE knvv-kdgrp,
        name1        LIKE kna1-name1,
        kostk        LIKE vbuk-kostk,
        wbstk        LIKE vbuk-wbstk,
        pdstk        LIKE vbuk-pdstk,
        gi_time      LIKE likp-erzet,
        kodat        LIKE likp-kodat,
        kouhr        LIKE likp-kouhr,
        pk_create_dt LIKE pk_create_dt,
        pk_create_tm LIKE pk_create_tm,
        gi_vs_pk_dt  LIKE gi_vs_pk_dt,
        gi_vs_pk_tm  LIKE gi_vs_pk_tm,
        gi_create_dt LIKE gi_create_dt,
        gi_create_tm LIKE gi_create_tm,
        pod_vs_gi_dt LIKE pod_vs_gi_dt,
        pod_vs_gi_tm LIKE pod_vs_gi_tm,
        cr_vs_gi_dt  LIKE cr_gi_dt,
        cr_vs_gi_tm  LIKE cr_gi_tm,
        cnt_dn(006)  TYPE p  DECIMALS 00,
        sign(004)    TYPE c,
        gistat(004)  TYPE c,
        podat1       LIKE likp-podat,
        potim1       LIKE likp-potim,
      END OF wa_result.

DATA: BEGIN OF wa_dataset,
        lfart(4),
        vstel(4),
        vbeln(10),
        kunnr(10),
        erdat(8),
        erzet(6),
        podat(8),
        potim(6),
        wadat_ist(8),
        crdat(8),
        crtim(6),
        kdgrp(2),
        kvgr3(3),
        ort01(35),
        kostk(1),
        wbstk(1),
        pdstk(1),
        gi_time(6),
        kodat(8),
        kouhr(6),
        pk_create_dt(4),
        pk_create_tm(6),
        gi_vs_pk_dt(4),
        gi_vs_pk_tm(6),
        cr_create_dt(4),
        cr_create_tm(6),
        pod_vs_gi_dt(4),
        pod_vs_gi_tm(6),
        space1(20),
        city1(40),
        dlk(2),
        pkdo(4),
        gipk(4),
        podgi(4),
        space2(4),
        cnt_dn(4),
        lgort(4),
        space3(34),
        podat1(8),
        potim1(6),
      END OF wa_dataset.

DATA: i_cdhdr   TYPE t_cdhdr  OCCURS 0,
      wa_cdhdr  TYPE t_cdhdr,
      i_cdpos   TYPE t_cdpos OCCURS 0,
      wa_cdpos  TYPE t_cdpos,
      i_result  LIKE wa_result OCCURS 0,
      i_result2 LIKE wa_result OCCURS 0.

DATA: BEGIN OF i_spmon OCCURS 0,
        spmon LIKE s031-spmon,
      END OF i_spmon.

DATA: BEGIN OF i_vbeln OCCURS 0,
        vbeln LIKE likp-vbeln,
      END OF i_vbeln.

DATA: BEGIN OF i_tvst OCCURS 0,
        vstel LIKE tvst-vstel,
      END OF i_tvst.

DATA: BEGIN OF i_kna1 OCCURS 0,
        kunnr LIKE kna1-kunnr,
        name1 LIKE kna1-name1,
      END OF i_kna1.

DATA: ta_sort TYPE slis_t_sortinfo_alv.

DATA: gs_layout               TYPE slis_layout_alv,
      g_exit_caused_by_caller,
      gs_exit_caused_by_user  TYPE slis_exit_by_user,
      g_repid                 LIKE sy-repid.

DATA:
  gt_events           TYPE slis_t_event,
  gt_list_top_of_page TYPE slis_t_listheader,
  g_top_of_page       TYPE slis_formname VALUE 'TOP_OF_PAGE',
  xit_fieldcat        TYPE slis_t_fieldcat_alv,
  xis_print           TYPE slis_print_alv.

DATA: e_save(1)      TYPE c VALUE 'A',
      er_sp_group    TYPE slis_t_sp_group_alv,
      e_exit(1)      TYPE c,
      er_variant     LIKE disvariant,
      e_variant      LIKE disvariant,
      e_user_command TYPE slis_formname VALUE 'USER_COMMAND'.

SELECTION-SCREEN: BEGIN OF BLOCK prog WITH FRAME TITLE TEXT-f58.

PARAMETER :
    dc LIKE knvv-vtweg  DEFAULT '10' NO-DISPLAY,
    div LIKE knvv-spart DEFAULT '00' NO-DISPLAY,
    pa_path(52) DEFAULT '\\tdsdev01\interface\DO-Monitor\' LOWER CASE
NO-DISPLAY.

SELECT-OPTIONS :
   ship_pnt FOR likp-vstel OBLIGATORY MEMORY ID vst,
   ship_to FOR likp-kunnr,
   del_num FOR likp-vbeln,
   crt_date FOR likp-erdat OBLIGATORY DEFAULT sy-datum,
   ent_time FOR likp-erzet,
   pickdate FOR wa_result-kodat MODIF ID xxx,
   gi_date FOR likp-wadat_ist   MODIF ID yyy,
   pod_date FOR likp-podat      MODIF ID zzz.

SELECTION-SCREEN : SKIP,

BEGIN OF BLOCK lb1 WITH FRAME TITLE TEXT-080,
  BEGIN OF LINE.
PARAMETERS all RADIOBUTTON GROUP grp USER-COMMAND outbut.
SELECTION-SCREEN : COMMENT 3(35) TEXT-003,
END OF LINE,
BEGIN OF LINE.
PARAMETERS gi  RADIOBUTTON GROUP grp .
SELECTION-SCREEN : COMMENT 3(35) TEXT-004,
END OF LINE,
BEGIN OF LINE.
PARAMETERS pod RADIOBUTTON GROUP grp .
SELECTION-SCREEN : COMMENT 3(35) TEXT-005,
END OF LINE,
BEGIN OF LINE.
PARAMETERS own RADIOBUTTON GROUP grp DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 3(35) TEXT-006,
END OF LINE,
END OF BLOCK lb1,

SKIP 1,

BEGIN OF BLOCK direct WITH FRAME TITLE TEXT-f59,
BEGIN OF LINE.
PARAMETERS: %alv RADIOBUTTON GROUP func USER-COMMAND outbut
                         DEFAULT 'X' .
SELECTION-SCREEN: COMMENT 4(26) TEXT-f72 FOR FIELD %alv.
PARAMETERS: p_vari LIKE disvariant-variant.
SELECTION-SCREEN:
PUSHBUTTON 72(4) pb%exco USER-COMMAND expcol,
END OF LINE,

BEGIN OF LINE.
PARAMETERS: %nofunc RADIOBUTTON GROUP func MODIF ID old.
SELECTION-SCREEN:
COMMENT 4(26) TEXT-f66 FOR FIELD %nofunc MODIF ID old,
END OF LINE,
END OF BLOCK direct,

END OF BLOCK prog,

SKIP.

PARAMETERS: p_buff AS CHECKBOX DEFAULT 'X' USER-COMMAND outbut.
************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.

*  IF sy-opsys EQ 'AIX'.
  pa_path = '/interface/DO-Monitor/'.
*  ENDIF.
  g_repid = sy-repid.
  PERFORM build_fieldcat.
  PERFORM layout_init USING gs_layout.
  PERFORM eventtab_build USING gt_events[].
*  PERFORM FILL_SORT.

  PERFORM sp_group_build USING er_sp_group[].

* Untuk protect maintain variant berdasarkan otorisasi di PID
  PERFORM reuse_berechtigung_setzen(sapmv75a)
          CHANGING e_save.
* Cuma boleh maintain local variant
  IF e_save = ''.
    e_save = 'U'.
  ENDIF.
  PERFORM variant_init.
  er_variant = e_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = e_save
    CHANGING
      cs_variant = er_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    p_vari = er_variant-variant.
  ENDIF.

************************************************************************
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.

AT SELECTION-SCREEN.
  IF all = 'X'.
    REFRESH gi_date.
    REFRESH pod_date.
  ENDIF.

  SELECT vstel FROM tvst
  INTO CORRESPONDING FIELDS OF TABLE i_tvst
  WHERE vstel IN ship_pnt.

  LOOP AT i_tvst.
    AUTHORITY-CHECK OBJECT 'V_LIKP_VST'
        ID 'ACTVT' FIELD '03'
        ID 'VSTEL' FIELD i_tvst-vstel.
    IF sy-subrc NE 0.
      MESSAGE e002(zz) WITH 'You are not authorized with Ship. Point'
       i_tvst-vstel.
    ENDIF.
  ENDLOOP.

  IF p_buff = ''.
    MESSAGE i002(zz) WITH
    'You must run in background if buffer switch off'.
  ENDIF.

  PERFORM pai_of_selection_screen.

AT SELECTION-SCREEN OUTPUT .
  LOOP AT SCREEN.
    IF all = 'X' AND ( screen-group1 = 'XXX' OR
       screen-group1 = 'YYY' OR screen-group1 = 'ZZZ' ).
      screen-input = '0'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF gi = 'X' AND ( screen-group1 = 'YYY' OR
       screen-group1 = 'ZZZ' ).
      screen-input = '0'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF pod = 'X' AND screen-group1 = 'ZZZ'.
      screen-input = '0'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
* Dummy icon query
  PERFORM set_expcol(rsaqexce) USING %alv pb%exco.

************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
  IF sy-uname <> 'MMMKO' AND p_buff = '' AND
     sy-batch <> 'X' AND sy-uzeit < '170000'.
    MESSAGE i014(zz).
    LEAVE LIST-PROCESSING.
  ENDIF.
  PERFORM calc_spmon.
  PERFORM select_data.
  PERFORM process_data_from_text.
  PERFORM process_data_from_db.

END-OF-SELECTION.

*********************************** ALV *******************************
  PERFORM comment_build USING gt_list_top_of_page[].

*"Display List
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
*  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
      i_background_id         = 'ALV_BACKGROUND'
      i_callback_program      = g_repid
      i_grid_title            = 'DO Monitor (Header Level)'
      i_callback_user_command = e_user_command
      is_layout               = gs_layout
      it_fieldcat             = xit_fieldcat[]
      it_special_groups       = er_sp_group
      it_sort                 = ta_sort[]
      i_save                  = e_save      "Untuk setting maintain variant
      is_variant              = er_variant
*     IT_EVENTS               = GT_EVENTS[] "Untuk menampilkan logo ALV
*     IS_PRINT                = XIS_PRINT
    IMPORTING
      e_exit_caused_by_caller = g_exit_caused_by_caller
      es_exit_caused_by_user  = gs_exit_caused_by_user
    TABLES
      t_outtab                = i_result
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.

  REFRESH i_result.

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       Ereigniss TOP_OF_PAGE                                       *
*       event     TOP_OF_PAGE
*---------------------------------------------------------------------*
FORM top_of_page.
  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      i_logo             = 'ENJOYSAP_LOGO'
      it_list_commentary = gt_list_top_of_page.
ENDFORM.                    "TOP_OF_PAGE


*----------------------------------------------------------------------
*    FORM PF_STATUS_SET
*----------------------------------------------------------------------
*     Statussetzen
*     Status set
*----------------------------------------------------------------------
*    --> EXTAB
*----------------------------------------------------------------------
FORM standard_er01 USING  extab TYPE slis_t_extab.

* DELETE EXTAB WHERE FCODE = '&UMC'.
  DELETE extab WHERE fcode = '&RNT_PREV'.
  DELETE extab WHERE fcode = '&LFO'.
  DELETE extab WHERE fcode = '&NFO'.
*  SET PF-STATUS 'ALVLIST' EXCLUDING EXTAB.

ENDFORM.                    "STANDARD_ER01

*&---------------------------------------------------------------------*
*&      Form  BUILD_FIELDCAT
*&---------------------------------------------------------------------*
FORM build_fieldcat.
  DATA: xfieldcat TYPE slis_fieldcat_alv.
****** Buat Column Name
  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'VSTEL'.
  xfieldcat-fix_column   = 'X'.            "Key
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 1.
  xfieldcat-outputlen    = 5.
*  XFIELDCAT-KEY          = 'X'.
  xfieldcat-reptext_ddic = 'ShPt'.
  xfieldcat-emphasize    = 'C700'.         "Color
  xfieldcat-rollname     = 'VSTEL'.
  xfieldcat-ref_fieldname = 'VSTEL'.
  xfieldcat-ref_tabname  = 'LIKP'.
  xfieldcat-reprep       = 'X'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'VBELN'.
  xfieldcat-fix_column   = 'X'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 2.
  xfieldcat-outputlen    = 10.
*  XFIELDCAT-hotspot      = 'X'.
  xfieldcat-reptext_ddic = 'Delivery'.
  xfieldcat-emphasize    = 'C300'.
  xfieldcat-rollname     = 'VBELN_VL'.
  xfieldcat-ref_fieldname = 'VBELN'.
  xfieldcat-ref_tabname  = 'LIKP'.
  xfieldcat-reprep       = 'X'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KUNNR'.
  xfieldcat-fix_column   = 'X'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 3.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Ship-to'.
  xfieldcat-emphasize    = 'C600'.
  xfieldcat-rollname     = 'KUNWE'.
  xfieldcat-ref_fieldname = 'KUNNR'.
  xfieldcat-ref_tabname  = 'LIKP'.
  xfieldcat-reprep       = 'X'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'NAME1'.
  xfieldcat-fix_column   = 'X'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 4.
  xfieldcat-outputlen    = 25.
  xfieldcat-reptext_ddic = 'Ship-to party'.
  xfieldcat-emphasize    = 'C410'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'ERDAT'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 5.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Entry Date'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'DATS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'ERZET'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 6.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Ent. Time'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KODAT'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 7.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Pick. Date'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'DATS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KOUHR'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 8.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Pick. Time'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'WADAT_IST'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 9.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Act GI Date'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'DATS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'GI_TIME'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 10.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'GI Time'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'CRDAT'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 11.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Cust. Rec Date'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'DATS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'CRTIM'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 12.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Cust. Rec Time'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'PODAT'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 13.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'POD Date'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'DATS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'POTIM'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 14.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'POD Time'.
*  XFIELDCAT-EMPHASIZE    = 'C200'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'PK_CREATE_DT'.
  xfieldcat-just         = 'R'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 15.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'Pick. Vs Ent. date'.
  xfieldcat-datatype      = 'DEC'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'PK_CREATE_TM'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 16.
  xfieldcat-outputlen    = 8.
  xfieldcat-reptext_ddic = 'Pick. Vs Ent. Time'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'GI_VS_PK_DT'.
  xfieldcat-just         = 'R'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 17.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'GI Vs Pick. Date'.
  xfieldcat-datatype      = 'DEC'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'GI_VS_PK_TM'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 18.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'GI Vs Pick. Time'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'GI_CREATE_DT'.
  xfieldcat-just         = 'R'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 19.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'GI Vs Ent. Date'.
  xfieldcat-datatype      = 'DEC'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'GI_CREATE_TM'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 20.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'GI Vs Ent. Time'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'CR_VS_GI_DT'.
  xfieldcat-just         = 'R'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 21.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'CR Vs GI Date'.
  xfieldcat-datatype      = 'DEC'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'CR_VS_GI_TM'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 22.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'CR Vs GI Time'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'POD_VS_GI_DT'.
  xfieldcat-just         = 'R'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 23.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'POD Vs GI Date'.
  xfieldcat-datatype      = 'DEC'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'POD_VS_GI_TM'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 24.
  xfieldcat-outputlen    = 10.
  xfieldcat-reptext_ddic = 'POD Vs GI Time'.
  xfieldcat-datatype      = 'TIMS'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'KDGRP'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 25.
  xfieldcat-outputlen    = 4.
  xfieldcat-reptext_ddic = 'Type Outlet'.
  xfieldcat-rollname     = 'KDGRP'.
  xfieldcat-ref_fieldname = 'KDGRP'.
  xfieldcat-ref_tabname  = 'KNVV'.
  xfieldcat-reprep       = 'X'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'CNT_DN'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 26.
  xfieldcat-outputlen    = 6.
  xfieldcat-reptext_ddic = 'Total DN'.
  xfieldcat-datatype     = 'DEC'.
  xfieldcat-do_sum       = 'X'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'SIGN'.
  xfieldcat-icon         = 'X'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 27.
  xfieldcat-outputlen    = 4.
  xfieldcat-reptext_ddic = 'Sign'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'GISTAT'.
  xfieldcat-icon         = 'X'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 28.
  xfieldcat-outputlen    = 4.
  xfieldcat-reptext_ddic = 'GI status'.
  APPEND xfieldcat TO xit_fieldcat.

  CLEAR xfieldcat.
  xfieldcat-fieldname    = 'LFART'.
  xfieldcat-row_pos      = 1.
  xfieldcat-col_pos      = 29.
  xfieldcat-outputlen    = 4.
  xfieldcat-reptext_ddic = 'DlvTy'.
  xfieldcat-rollname     = 'LFART'.
  xfieldcat-ref_fieldname = 'LFART'.
  xfieldcat-ref_tabname  = 'LIKP'.
  xfieldcat-reprep       = 'X'.
  APPEND xfieldcat TO xit_fieldcat.
ENDFORM.                    " BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.
  rs_layout-detail_popup      = 'X'.
  rs_layout-colwidth_optimize = 'X'.
  rs_layout-zebra             = 'X'.
  rs_layout-window_titlebar   = 'DO Monitor (Header Level)'.
  rs_layout-reprep            = 'X'.
*  RS_layout-f2code            = '&EB9'.
  rs_layout-group_change_edit = 'X'.

ENDFORM.                    " LAYOUT_INIT
*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build USING rt_events TYPE slis_t_event.
*"Registration of events to happen during list display
  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.

  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE g_top_of_page TO ls_event-form.
    APPEND ls_event TO rt_events.
  ENDIF.

  READ TABLE rt_events WITH KEY name = slis_ev_user_command
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE e_user_command TO ls_event-form.
    APPEND ls_event TO rt_events.
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
FORM fill_sort.
  DATA: fieldsort TYPE slis_sortinfo_alv.
***** Sort Data
  fieldsort-spos = '1'.
  fieldsort-fieldname = 'VSTEL'.
  fieldsort-up   = 'X'.
  fieldsort-subtot = 'X'.
  fieldsort-expa   = 'X'.
  APPEND fieldsort TO ta_sort.

  fieldsort-spos = '2'.
  fieldsort-fieldname = 'VBELN'.
  fieldsort-up   = 'X'.
  fieldsort-subtot = 'X'.
  fieldsort-expa   = 'X'.
  APPEND fieldsort TO ta_sort.

ENDFORM.                    " FILL_SORT

*&---------------------------------------------------------------------*
*&      Form  COMMENT_BUILD
*&---------------------------------------------------------------------*
FORM comment_build USING lt_top_of_page TYPE slis_t_listheader.
  DATA: ls_line TYPE slis_listheader.
  DATA: u_date(15) TYPE c.
****** Buat Header Line

  WRITE sy-datum TO u_date.
* LIST HEADING LINE: TYPE H
  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = TEXT-100.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = u_date.
  APPEND ls_line TO lt_top_of_page.

  CLEAR ls_line.
  ls_line-typ  = 'H'.
  ls_line-info = sy-uname .
  APPEND ls_line TO lt_top_of_page.
ENDFORM.                    " COMMENT_BUILD
*&---------------------------------------------------------------------*
*&      Form  SP_GROUP_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_SP_GROUP[]  text
*----------------------------------------------------------------------*
FORM sp_group_build USING u_er_sp_group TYPE slis_t_sp_group_alv.

  DATA: ls_sp_group TYPE slis_sp_group_alv.
  CLEAR  ls_sp_group.
  ls_sp_group-sp_group = 'A'.
  ls_sp_group-text     = 'Standart'.
  APPEND ls_sp_group TO u_er_sp_group.

ENDFORM.                               " SP_GROUP_BUILD
*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM variant_init.
  CLEAR e_variant.
  e_variant-report = g_repid.
ENDFORM.                    " VARIANT_INIT
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
FORM f4_for_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = e_variant
      i_save     = e_save
*     it_default_fieldcat =
    IMPORTING
      e_exit     = e_exit
      es_variant = er_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF e_exit = space.
      p_vari = er_variant-variant.
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
FORM pai_of_selection_screen.
  IF NOT p_vari IS INITIAL.
    MOVE e_variant TO er_variant.
    MOVE p_vari TO er_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE' " Überpr. des Ex. einer
      EXPORTING                     " Vari. auf der DB.
        i_save     = e_save
      CHANGING
        cs_variant = er_variant.
    e_variant = er_variant.
  ELSE.
    PERFORM variant_init.
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
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.
  DATA: feld(10) TYPE c, d_lgort LIKE mseg-lgort.

  rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN  'FEHL' OR '&IC1'.
      CASE rs_selfield-sel_tab_field.
        WHEN '1-VBELN'.
          SET PARAMETER ID  'VL' FIELD rs_selfield-value.
          CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
      ENDCASE.
      rs_selfield-col_stable = 'X'.
      rs_selfield-row_stable = 'X'.
      gs_layout-info_fieldname    = 'i_result'.
  ENDCASE.

ENDFORM.                    "USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  SELECT_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_data.
  DATA    : i_objectid     TYPE t_objectid OCCURS 0,
            wa_objectid    TYPE t_objectid,
            l_dataset1(70),
            n              TYPE i,
            BEGIN OF i_kunnr OCCURS 0,
              kunnr LIKE kna1-kunnr,
            END OF i_kunnr.
  REFRESH : i_objectid, i_cdpos, i_cdhdr, i_result.
  CLEAR   : wa_objectid, wa_cdpos, wa_cdhdr, wa_result.

*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '10'
      text       = 'Data is being read...'.
*-----------------------------------------------------*
  IF p_buff = 'X'.
*----------------------*
* Ambil data dari text
*----------------------*
    LOOP AT i_tvst.
      LOOP AT i_spmon.
        CONCATENATE pa_path i_tvst-vstel '-'
                      i_spmon-spmon+4(2) '_' i_spmon-spmon(4) '-DO.TXT'
                INTO l_dataset1.
        OPEN DATASET l_dataset1 FOR INPUT IN TEXT MODE ENCODING DEFAULT.
        IF sy-subrc EQ 0.
          DO.
            READ DATASET l_dataset1 INTO wa_dataset.
            IF sy-subrc <> 0.
              EXIT.
            ENDIF.
* Correction for read dataset file created using NT
            IF wa_dataset-lgort EQ space.
              wa_dataset-cnt_dn = '1'.
            ENDIF.

            MOVE-CORRESPONDING wa_dataset TO wa_result.
            CHECK wa_result-erdat IN crt_date
              AND wa_result-kunnr IN ship_to
              AND wa_result-vbeln IN del_num
              AND wa_result-erzet IN ent_time
              AND wa_result-kodat IN pickdate
              AND wa_result-wadat_ist IN gi_date
              AND wa_result-podat IN pod_date.

            IF gi = 'X'.
              CHECK wa_result-wbstk <> 'C'.
            ENDIF.
            IF pod = 'X'.
              CHECK wa_result-pdstk <> 'C'.
            ENDIF.
            i_kunnr-kunnr = wa_result-kunnr.
            APPEND i_kunnr.
            APPEND wa_result TO i_result.
          ENDDO.
        ENDIF.
        CLOSE DATASET l_dataset1.
      ENDLOOP.
    ENDLOOP.
    SORT i_kunnr BY kunnr.
    DELETE ADJACENT DUPLICATES FROM i_kunnr COMPARING kunnr.

* Baca data nama customer.
    SELECT kunnr name1 FROM kna1 INTO TABLE i_kna1
    FOR ALL ENTRIES IN i_kunnr WHERE kunnr = i_kunnr-kunnr.
    REFRESH i_kunnr.

    LOOP AT i_result INTO wa_result WHERE kostk <> 'C'
                                       OR wbstk <> 'C'
                                       OR pdstk <> 'C'.
*Untuk data hari ini jangan dimasukkan karena akan dibaca lagi
      IF wa_result-erdat <> sy-datum.
        i_vbeln-vbeln = wa_result-vbeln.
        APPEND i_vbeln.
      ENDIF.
      DELETE TABLE i_result FROM wa_result.
    ENDLOOP.

* Baca data DO yang belum completed
    DESCRIBE TABLE i_vbeln LINES n.
    IF n > 0.
      SELECT likp~lfart likp~vstel likp~vbeln likp~kunnr likp~erdat
                likp~erzet likp~podat likp~potim likp~wadat_ist
                zmm_cust_rec~crdat zmm_cust_rec~crtim
                knvv~kdgrp kna1~name1
                vbuk~kostk vbuk~wbstk vbuk~pdstk
         INTO CORRESPONDING FIELDS OF TABLE i_result2
         FROM ( likp
                LEFT JOIN zmm_cust_rec
                ON zmm_cust_rec~vbeln = likp~vbeln
                INNER JOIN knvv
                ON knvv~kunnr = likp~kunnr
                AND knvv~vkorg = likp~vkorg
                INNER JOIN kna1
                ON kna1~kunnr = knvv~kunnr
                INNER JOIN vbuk
                ON vbuk~vbeln = likp~vbeln )
         FOR ALL ENTRIES IN i_vbeln
                WHERE likp~vbeln = i_vbeln-vbeln
                  AND knvv~vtweg EQ dc
                  AND knvv~spart EQ div.
    ENDIF.
    REFRESH i_vbeln.

* Cek apakah ada data hari ini yang akan ditampilkan
    IF sy-datum IN crt_date.
      SELECT likp~lfart likp~vstel likp~vbeln likp~kunnr likp~erdat
             likp~erzet likp~podat likp~potim likp~wadat_ist
             zmm_cust_rec~crdat zmm_cust_rec~crtim
             knvv~kdgrp kna1~name1
             vbuk~kostk vbuk~wbstk vbuk~pdstk
      APPENDING CORRESPONDING FIELDS OF TABLE i_result2
      FROM ( likp
             LEFT JOIN zmm_cust_rec
             ON zmm_cust_rec~vbeln = likp~vbeln
             INNER JOIN knvv
             ON knvv~kunnr = likp~kunnr
             AND knvv~vkorg = likp~vkorg
             INNER JOIN kna1
             ON kna1~kunnr = knvv~kunnr
             INNER JOIN vbuk
             ON vbuk~vbeln = likp~vbeln )
             WHERE likp~vstel IN ship_pnt
               AND likp~kunnr IN ship_to
               AND likp~vbeln IN del_num
               AND likp~erdat EQ sy-datum
               AND likp~erzet IN ent_time
               AND likp~wadat_ist IN gi_date
               AND likp~podat IN pod_date
               AND knvv~vtweg EQ dc
               AND knvv~spart EQ div.
    ENDIF.
  ELSE.
*--------------------------------------------------------*
* Jika tidak menggunakan buffer ambil data dari database
*--------------------------------------------------------*
    SELECT likp~lfart likp~vstel likp~vbeln likp~kunnr likp~erdat
           likp~erzet likp~podat likp~potim likp~wadat_ist
           zmm_cust_rec~crdat zmm_cust_rec~crtim
           knvv~kdgrp kna1~name1
           vbuk~kostk vbuk~wbstk vbuk~pdstk
    INTO CORRESPONDING FIELDS OF TABLE i_result2
    FROM ( likp
           LEFT JOIN zmm_cust_rec
           ON zmm_cust_rec~vbeln = likp~vbeln
           INNER JOIN knvv
           ON knvv~kunnr = likp~kunnr
           AND knvv~vkorg = likp~vkorg
           INNER JOIN kna1
           ON kna1~kunnr = knvv~kunnr
           INNER JOIN vbuk
           ON vbuk~vbeln = likp~vbeln )
           WHERE likp~vstel IN ship_pnt
             AND likp~kunnr IN ship_to
             AND likp~vbeln IN del_num
             AND likp~erdat IN crt_date
             AND likp~erzet IN ent_time
             AND likp~wadat_ist IN gi_date
             AND likp~podat IN pod_date
             AND knvv~vtweg EQ dc
             AND knvv~spart EQ div.
*     Jika tidak ada data, keluar
    IF sy-subrc <> 0.
      MESSAGE s260(aq).
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.

  IF gi = 'X'.
    DELETE i_result2 WHERE wbstk = 'C'.
  ENDIF.
  IF pod = 'X'.
    DELETE i_result2 WHERE pdstk = 'C'.
  ENDIF.

  LOOP AT i_result2 INTO wa_result WHERE kostk = 'C'.
    wa_objectid-objectid = wa_result-vbeln.
    APPEND wa_objectid TO i_objectid.
  ENDLOOP.

  DESCRIBE TABLE i_objectid LINES n.
*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '30'
      text       = 'Data is being read...'.
*-----------------------------------------------------*
  IF n > 0.
    SELECT objectid changenr fname FROM cdpos
    INTO CORRESPONDING FIELDS OF TABLE i_cdpos
    FOR ALL ENTRIES IN i_objectid
    WHERE objectclas = 'LIEFERUNG' AND
          objectid = i_objectid-objectid AND
          tabname = 'VBUK' AND
        ( fname = 'KOQUK' OR
          fname = 'WBSTK' ) AND
          value_new = 'C'.

    SORT i_cdpos BY objectid fname changenr DESCENDING.
    DELETE ADJACENT DUPLICATES FROM i_cdpos COMPARING objectid fname.

    REFRESH i_objectid.
    APPEND LINES OF i_cdpos TO i_objectid.
    DELETE ADJACENT DUPLICATES FROM i_objectid COMPARING changenr.

*-----------------------------------------------------*
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = '50'
        text       = 'Data is being read...'.
*-----------------------------------------------------*
    SELECT objectid changenr udate utime FROM cdhdr
    INTO CORRESPONDING FIELDS OF TABLE i_cdhdr
    FOR ALL ENTRIES IN i_objectid
    WHERE objectclas = 'LIEFERUNG' AND
          objectid = i_objectid-objectid AND
          changenr = i_objectid-changenr.

    REFRESH i_objectid.
  ENDIF.
ENDFORM.                    " SELECT_DATA

*&---------------------------------------------------------------------*
*&      Form  PROCESS_data_from_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data_from_text.
*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '70'
      text       = 'Data is being process...'.
*-----------------------------------------------------*
* Proses additional data for data from text
  SORT i_kna1 BY kunnr.
  LOOP AT i_result INTO wa_result.
    CLEAR i_kna1.
    wa_result-podat = wa_result-podat1.
    wa_result-potim = wa_result-potim1.

    IF wa_result-wadat_ist <> '00000000'.
      IF wa_result-podat <> '00000000'.
        wa_result-pod_vs_gi_dt = wa_result-podat - wa_result-wadat_ist.
        IF wa_result-potim < wa_result-gi_time.
          wa_result-pod_vs_gi_dt = wa_result-pod_vs_gi_dt - 1.
        ENDIF.
      ELSE.
        wa_result-pod_vs_gi_dt = 999.
      ENDIF.
    ELSE.
      wa_result-pod_vs_gi_dt = 999.
    ENDIF.

    IF wa_result-pod_vs_gi_dt < 0.
      wa_result-pod_vs_gi_dt = 0.
    ENDIF.

    READ TABLE i_kna1 WITH KEY kunnr = wa_result-kunnr BINARY SEARCH.
    wa_result-name1 = i_kna1-name1.
*------------------*
* Hitung lead time
*------------------*

* Hitung jam
    IF wa_result-gi_time <> '000000'.
      wa_result-gi_create_tm = wa_result-gi_time - wa_result-erzet.
    ENDIF.
    IF wa_result-crtim <> '000000'.
      wa_result-cr_vs_gi_tm = wa_result-crtim - wa_result-gi_time.
    ENDIF.
    IF wa_result-potim <> '000000'.
      wa_result-pod_vs_gi_tm = wa_result-potim - wa_result-gi_time.
    ENDIF.

* Hitung hari
    IF wa_result-wadat_ist <> '00000000'.
      wa_result-gi_create_dt = wa_result-wadat_ist - wa_result-erdat.
      IF wa_result-gi_time < wa_result-erzet.
        wa_result-gi_create_dt = wa_result-gi_create_dt - 1.
      ENDIF.
      IF wa_result-crdat <> '00000000' .
        wa_result-cr_vs_gi_dt = wa_result-crdat - wa_result-wadat_ist.
        IF wa_result-crtim < wa_result-gi_time.
          wa_result-cr_vs_gi_dt = wa_result-cr_vs_gi_dt - 1.
        ENDIF.
      ELSE.
        wa_result-cr_vs_gi_dt = 999.
      ENDIF.
    ELSE.
      wa_result-gi_create_dt = sy-datum - wa_result-erdat.
      wa_result-cr_vs_gi_dt = 999.
    ENDIF.

    IF wa_result-cr_vs_gi_dt < 0.
      wa_result-cr_vs_gi_dt = 0.
    ENDIF.

* Fill ICON  indicator
    IF wa_result-wbstk = 'C' .
      wa_result-gistat = icon_checked .
    ELSE.
      wa_result-gistat = icon_incomplete .
    ENDIF.
    IF wa_result-gi_create_dt < 3 .
      wa_result-sign = icon_green_light .
    ELSEIF wa_result-gi_create_dt >= 3 AND wa_result-gi_create_dt <= 7 .
      wa_result-sign = icon_yellow_light .
    ELSEIF wa_result-gi_create_dt > 7 .
      wa_result-sign = icon_red_light .
    ENDIF.
    MODIFY i_result FROM wa_result.
  ENDLOOP.
ENDFORM.                    " PROCESS_data_from_text

*&---------------------------------------------------------------------*
*&      Form  PROCESS_data_from_DB
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM process_data_from_db.

  SORT i_cdhdr BY objectid changenr.
  LOOP AT i_cdpos INTO wa_cdpos.
    CLEAR wa_cdhdr.
    READ TABLE i_cdhdr INTO wa_cdhdr
       WITH KEY objectid = wa_cdpos-objectid
                changenr = wa_cdpos-changenr
       BINARY SEARCH.
    wa_cdpos-udate = wa_cdhdr-udate.
    wa_cdpos-utime = wa_cdhdr-utime.
    MODIFY i_cdpos FROM wa_cdpos.
  ENDLOOP.

  REFRESH i_cdhdr. CLEAR wa_cdhdr.

  LOOP AT i_result2 INTO wa_result.
*-------------------------*
* Baca Piking date & time
*-------------------------*
    CLEAR wa_cdpos.
* Jika Pick status = C, baca data
    IF wa_result-kostk = 'C'.
      READ TABLE i_cdpos INTO wa_cdpos
         WITH KEY objectid = wa_result-vbeln
                  fname    = 'KOQUK'
         BINARY SEARCH.
      IF sy-subrc = 0.
        wa_result-kodat = wa_cdpos-udate.
        wa_result-kouhr = wa_cdpos-utime.
      ENDIF.
      CHECK pickdate.
    ENDIF.

*---------------------*
* Baca GI date & time
*---------------------*
    CLEAR wa_cdpos.
* Jika GI status = C, baca data
    IF wa_result-wbstk = 'C'.
      READ TABLE i_cdpos INTO wa_cdpos
         WITH KEY objectid = wa_result-vbeln
                  fname    = 'WBSTK'
         BINARY SEARCH.
      IF sy-subrc = 0.
        wa_result-wadat_ist = wa_cdpos-udate.
        wa_result-gi_time   = wa_cdpos-utime.
      ENDIF.
    ELSE.
      CLEAR : wa_result-wadat_ist, wa_result-gi_time.
    ENDIF.
*------------------*
* Hitung lead time
*------------------*

* Hitung jam
    IF wa_result-kouhr <> '000000'.
      wa_result-pk_create_tm = wa_result-kouhr - wa_result-erzet.
    ENDIF.
    IF wa_result-gi_time <> '000000'.
      wa_result-gi_create_tm = wa_result-gi_time - wa_result-erzet.
      IF wa_result-kouhr <> '000000'.
        wa_result-gi_vs_pk_tm = wa_result-gi_time - wa_result-kouhr.
      ENDIF.
    ENDIF.
    IF wa_result-crtim <> '000000'.
      wa_result-cr_vs_gi_tm = wa_result-crtim - wa_result-gi_time.
    ENDIF.
    IF wa_result-potim <> '000000'.
      wa_result-pod_vs_gi_tm = wa_result-potim - wa_result-gi_time.
    ENDIF.


* Hitung hari
    IF wa_result-kodat <> '00000000'.
      wa_result-pk_create_dt = wa_result-kodat - wa_result-erdat.
      IF wa_result-kouhr < wa_result-erzet.
        wa_result-pk_create_dt = wa_result-pk_create_dt - 1.
      ENDIF.
    ELSE.
      wa_result-pk_create_dt = sy-datum - wa_result-erdat.
    ENDIF.

    IF wa_result-wadat_ist <> '00000000'.
      wa_result-gi_create_dt = wa_result-wadat_ist - wa_result-erdat.
      IF wa_result-gi_time < wa_result-erzet.
        wa_result-gi_create_dt = wa_result-gi_create_dt - 1.
      ENDIF.
      IF wa_result-kodat <> '00000000'.
        wa_result-gi_vs_pk_dt = wa_result-wadat_ist - wa_result-kodat.
        IF wa_result-gi_time < wa_result-kouhr.
          wa_result-gi_vs_pk_dt = wa_result-gi_vs_pk_dt - 1.
        ENDIF.
      ENDIF.
      IF wa_result-crdat <> '00000000' .
        wa_result-cr_vs_gi_dt = wa_result-crdat - wa_result-wadat_ist.
        IF wa_result-crtim < wa_result-gi_time.
          wa_result-cr_vs_gi_dt = wa_result-cr_vs_gi_dt - 1.
        ENDIF.
      ELSE.
        wa_result-cr_vs_gi_dt = 999.
      ENDIF.
      IF wa_result-podat <> '00000000'.
        wa_result-pod_vs_gi_dt = wa_result-podat - wa_result-wadat_ist.
        IF wa_result-potim < wa_result-gi_time.
          wa_result-pod_vs_gi_dt = wa_result-pod_vs_gi_dt - 1.
        ENDIF.
      ELSE.
        wa_result-pod_vs_gi_dt = 999.
      ENDIF.
    ELSE.
      wa_result-gi_create_dt = sy-datum - wa_result-erdat.
      wa_result-gi_vs_pk_dt  = sy-datum - wa_result-kodat.
      IF wa_result-kodat = '00000000'.
        wa_result-gi_vs_pk_dt = 0.
      ENDIF.
      wa_result-cr_vs_gi_dt = 999.
      wa_result-pod_vs_gi_dt = 999.
    ENDIF.

    IF wa_result-cr_vs_gi_dt < 0.
      wa_result-cr_vs_gi_dt = 0.
    ENDIF.
    IF wa_result-pod_vs_gi_dt < 0.
      wa_result-pod_vs_gi_dt = 0.
    ENDIF.

* Counter
    wa_result-cnt_dn = 1.

* Fill ICON  indicator
    IF wa_result-wbstk = 'C' .
      wa_result-gistat = icon_checked .
    ELSE.
      wa_result-gistat = icon_incomplete .
    ENDIF.
    IF wa_result-gi_create_dt < 3 .
      wa_result-sign = icon_green_light .
    ELSEIF wa_result-gi_create_dt >= 3 AND wa_result-gi_create_dt <= 7 .
      wa_result-sign = icon_yellow_light .
    ELSEIF wa_result-gi_create_dt > 7 .
      wa_result-sign = icon_red_light .
    ENDIF.
    MODIFY i_result2 FROM wa_result.
  ENDLOOP.

  APPEND LINES OF i_result2 TO i_result.

  IF NOT pickdate IS INITIAL.
    DELETE i_result WHERE kodat = '00000000'.
  ENDIF.

* Completed
*-----------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '100'
      text       = 'Data is being process...'.
*-----------------------------------------------------*
  REFRESH : i_cdpos, i_result2.
  CLEAR   : wa_cdpos, wa_result.
ENDFORM.                    " PROCESS_data_from_DB


*&---------------------------------------------------------------------*
*&      Form  calc_spmon
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM calc_spmon.
  DATA : spmon_low  LIKE s031-spmon,
         spmon_high LIKE s031-spmon.

* Jika range date tidak kosong
  IF NOT crt_date IS INITIAL.
    SORT crt_date BY sign option low.
*-------------------------*
* Proses untuk data range
*-------------------------*
    LOOP AT crt_date WHERE ( sign = 'I' AND option = 'BT'
                       AND high <> '00000000' ) OR
                           ( sign = 'E' AND option = 'NB'
                       AND high <> '00000000' ).
      i_spmon-spmon = crt_date-low(6).
      APPEND i_spmon.
      i_spmon-spmon = crt_date-high(6).
      APPEND i_spmon.
    ENDLOOP.

    SORT i_spmon.
    DELETE ADJACENT DUPLICATES FROM i_spmon COMPARING spmon.
* Baca minimum range
    READ TABLE i_spmon INDEX 1.
    spmon_low = i_spmon.
    IF spmon_low = '000000'.
      spmon_low = '200301'.
    ENDIF.

* Baca maximum range
    SORT i_spmon DESCENDING.
    READ TABLE i_spmon INDEX 1.
    spmon_high = i_spmon.
    REFRESH i_spmon.

    WHILE spmon_low <= spmon_high.
      APPEND spmon_low TO i_spmon.
      spmon_low = spmon_low + 1.
      IF spmon_low+4(2) = '13'.
        spmon_low+4(2) = '01'.
        spmon_low(4)   = spmon_low(4) + 1.
      ENDIF.
    ENDWHILE.

*--------------------------*
* Proses untuk data single
*--------------------------*
    LOOP AT crt_date WHERE ( sign = 'I' AND option = 'EQ'
                       AND high = '00000000' ) OR
                           ( sign = 'E' AND option = 'NE'
                       AND high = '00000000' ).
      i_spmon-spmon = crt_date-low(6).
      APPEND i_spmon.
    ENDLOOP.

*--------------------------------*
* Proses untuk data greater than
*--------------------------------*
    spmon_low  = '999912'.
    spmon_high = sy-datum(6).
    LOOP AT crt_date WHERE sign = 'I' AND
                         ( option = 'GT' OR option = 'GE' ).
      IF spmon_low > crt_date-low(6).
        spmon_low = crt_date-low(6).
      ENDIF.
    ENDLOOP.

    WHILE spmon_low <= spmon_high.
      APPEND spmon_low TO i_spmon.
      spmon_low = spmon_low + 1.
      IF spmon_low+4(2) = '13'.
        spmon_low+4(2) = '01'.
        spmon_low(4)   = spmon_low(4) + 1.
      ENDIF.
    ENDWHILE.

*--------------------------------*
* Proses untuk data less than
*--------------------------------*
    spmon_low  = '200301'.
    spmon_high = '000000'.
    LOOP AT crt_date WHERE sign = 'I' AND
                         ( option = 'LT' OR option = 'LE' ).
      IF spmon_high < crt_date-low(6).
        spmon_high = crt_date-low(6).
      ENDIF.
    ENDLOOP.

    WHILE spmon_low <= spmon_high.
      APPEND spmon_low TO i_spmon.
      spmon_low = spmon_low + 1.
      IF spmon_low+4(2) = '13'.
        spmon_low+4(2) = '01'.
        spmon_low(4)   = spmon_low(4) + 1.
      ENDIF.
    ENDWHILE.

    SORT i_spmon.
    DELETE ADJACENT DUPLICATES FROM i_spmon COMPARING spmon.
  ELSE.

*--------------------------------*
* Proses untuk data blank
*--------------------------------*
    spmon_low  = '200301'.
    spmon_high = sy-datum(6).
    WHILE spmon_low <= spmon_high.
      APPEND spmon_low TO i_spmon.
      spmon_low = spmon_low + 1.
      IF spmon_low+4(2) = '13'.
        spmon_low+4(2) = '01'.
        spmon_low(4)   = spmon_low(4) + 1.
      ENDIF.
    ENDWHILE.
  ENDIF.

ENDFORM.                    " CALC_SPMON
