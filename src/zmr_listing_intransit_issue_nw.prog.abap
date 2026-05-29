************************************************************************
*                                                                      *
*  PROGRAM NAME  :  ZMR_LISTING_INTRANSIT_ISSUE_NEW                    *
*  PROGRAM DESC  :  Listing Intransit                                  *
*  CREATED BY    :  BUDI PRAMONO                                       *
*  CREATED ON    :  06/07/2004 (DMY)                                   *
*  VERSION       :  4.6C                                               *
*                                                                      *
************************************************************************
*                                                                      *
*  MODIFICATION LOG :                                                  *
*                                                                      *
*  DATE        PROGRAMMER        CORRECTION  DESCRIPTION
*
*  ----------  ---------------  ----------  -------------------------  *
*  DD/MM/YYYY  XXXXXXXXXXXXXXX  XXXXXXXXXX  XXXXXXXXXXXXXXXXXXXXXXXXX  *
*                                                                      *
************************************************************************
REPORT zmr_listing_intransit_issue_nw MESSAGE-ID zm
                                      LINE-SIZE 200
                                      LINE-COUNT 65
                                      NO STANDARD PAGE HEADING.

*---------------------------------------------------------------------*
* DEFINITION OF TABLES, TYPES & DATA                                  *
*---------------------------------------------------------------------*
TYPE-POOLS: slis, truxs.

TABLES : sscrfields,
         mkpf,      "Header: Material Document
         mseg.      "Document Segment: Material

RANGES : r_umlgo FOR mseg-umlgo.

DATA   : BEGIN OF itab OCCURS 0,
           bwart  LIKE  mseg-bwart,
           mblnr  LIKE  mseg-mblnr,
           mjahr  LIKE  mseg-mjahr,
           bldat  LIKE  mkpf-bldat,
           budat  LIKE  mkpf-budat,
           xblnr  LIKE  mkpf-xblnr,
           bktxt  LIKE  mkpf-bktxt,
           werks  LIKE  mseg-werks,
           lgort  LIKE  mseg-lgort,
           umwrk  LIKE  mseg-umwrk,
           umlgo  LIKE  mseg-umlgo,
           ebeln  LIKE  mseg-ebeln,
           ebelp  LIKE  mseg-ebelp,
           sgtxt  LIKE  mseg-sgtxt,
           matnr  LIKE  mseg-matnr,
           maktx  LIKE  makt-maktx,
           menge  LIKE  mseg-menge,
           dmbtr  LIKE  mseg-dmbtr,
           nsp    LIKE  mseg-dmbtr,
           bwart1 LIKE  mseg-bwart,
           mblnr1 LIKE  mseg-mblnr,
           matnr1 LIKE  mseg-matnr,
           maktx1 LIKE  makt-maktx,
           menge1 LIKE  mseg-menge,
           dmbtr1 LIKE  mseg-dmbtr,
           kunnr  LIKE  mseg-kunnr,
           name3  LIKE  kna1-name3,
           bbkno  LIKE  zpoittc-bbkno,
           tknum  LIKE  vttp-tknum,
           cpudt1 LIKE  mkpf-cpudt,
           budat1 LIKE  mkpf-budat,
           leadt  TYPE  i,
           erdat  LIKE vttp-erdat,
           etdat  LIKE vttp-erdat,
           daten  LIKE vttk-daten,
           uaten  LIKE vttk-uaten,
           uatenc TYPE char10,
           signi  TYPE signi,
           tpbez  TYPE tpbez,
           route  TYPE routr,
           exti1  TYPE exti1,
           exti2  TYPE exti2,
           bezei  TYPE bezei,
           tdlnr  TYPE vttk-tdlnr,
           name1  TYPE lfa1-name1,

           custo  TYPE kna1-kunnr,
           namec  TYPE kna1-name1,
           lprio  TYPE mepo1331-lprio,
           beze1  TYPE tprit-bezei,
           lprio1 TYPE mepo1331-lprio,
           beze2  TYPE tprit-bezei,
         END OF itab.

DATA   : BEGIN OF i_mkpf OCCURS 0,
           mblnr  LIKE  mkpf-mblnr,
           mjahr  LIKE  mkpf-mjahr,
           bldat  LIKE  mkpf-bldat,
           budat  LIKE  mkpf-budat,
           xblnr  LIKE  mkpf-xblnr,
           bktxt  LIKE  mkpf-bktxt,
           werks  LIKE  mseg-werks,
           lgort  LIKE  mseg-umlgo,
           umwrk  LIKE  mseg-umwrk,
           umlgo  LIKE  mseg-umlgo,
           bwart  LIKE  mseg-bwart,
           ebeln  LIKE  mseg-ebeln,
           ebelp  LIKE  mseg-ebelp,
           kunnr  LIKE  mseg-kunnr,
           tknum  LIKE  vttp-tknum,
           erdat  LIKE  vttp-erdat,
           gesztd LIKE  vttk-gesztd,
           daten  LIKE  vttk-daten,
           uaten  LIKE  vttk-uaten,
           signi  TYPE signi,
           tpbez  TYPE tpbez,
           route  TYPE routr,
           exti1  TYPE exti1,
           exti2  TYPE exti2,
           bezei  TYPE bezei,
           tdlnr  TYPE vttk-tdlnr,
           name1  TYPE lfa1-name1,
         END OF i_mkpf.

DATA   : BEGIN OF i303641 OCCURS 0,
           bwart LIKE  mseg-bwart,
           mblnr LIKE  mseg-mblnr,
           matnr LIKE  mseg-matnr,
           menge LIKE  mseg-menge,
           dmbtr LIKE  mseg-dmbtr,
           zeile LIKE  mseg-zeile,
           ebeln LIKE  mseg-ebeln,
           ebelp LIKE  mseg-ebelp,
         END OF i303641.

DATA   : BEGIN OF i_305 OCCURS 0,
           bwart LIKE  mseg-bwart,
           sgtxt LIKE  mseg-sgtxt,
           matnr LIKE  mseg-matnr,
           mblnr LIKE  mseg-mblnr,
           menge LIKE  mseg-menge,
           dmbtr LIKE  mseg-dmbtr,
           cpudt LIKE  mkpf-cpudt,
           budat LIKE  mkpf-budat,
         END OF i_305.

DATA   : BEGIN OF i_305_detail OCCURS 0,
           bwart LIKE  mseg-bwart,
           sgtxt LIKE  mseg-sgtxt,
           matnr LIKE  mseg-matnr,
           mjahr LIKE  mseg-mjahr,
           mblnr LIKE  mseg-mblnr,
           zeile LIKE  mseg-zeile,
           menge LIKE  mseg-menge,
           dmbtr LIKE  mseg-dmbtr,
         END OF i_305_detail.

DATA   : i_315_detail LIKE i_305_detail OCCURS 0 WITH HEADER LINE,
         i_315        LIKE i_305 OCCURS 0 WITH HEADER LINE.

DATA   : BEGIN OF i_101 OCCURS 0,
           bwart LIKE  ekbe-bwart,
           xblnr LIKE  mkpf-xblnr,
           matnr LIKE  ekbe-matnr,
           belnr LIKE  ekbe-belnr,
           menge LIKE  ekbe-menge,
           dmbtr LIKE  ekbe-dmbtr,
           cpudt LIKE  mkpf-cpudt,
           budat LIKE  mkpf-budat,
           ebeln LIKE  ekbe-ebeln,
           ebelp LIKE  mseg-ebelp,
           lgort TYPE  lgort_d,
         END OF i_101.

DATA   : BEGIN OF i_101_detail OCCURS 0,
           bwart LIKE  ekbe-bwart,
           xblnr LIKE  mkpf-xblnr,
           matnr LIKE  ekbe-matnr,
           gjahr LIKE  ekbe-gjahr,
           belnr LIKE  ekbe-belnr,
           buzei LIKE  ekbe-buzei,
           menge LIKE  ekbe-menge,
           dmbtr LIKE  ekbe-dmbtr,
           ebeln LIKE  ekbe-ebeln,
           ebelp LIKE  mseg-ebelp,
         END OF i_101_detail.

DATA   : BEGIN OF i_kunnr OCCURS 0,
           kunnr LIKE  mseg-kunnr,
         END OF i_kunnr.

DATA   : BEGIN OF i_kna1 OCCURS 0,
           kunnr LIKE  kna1-kunnr,
           name3 LIKE  kna1-name3,
         END OF i_kna1.

DATA   : i_zplbc     LIKE zplbc OCCURS 0 WITH HEADER LINE,
         i_v_t001l_l LIKE v_t001l_l OCCURS 0 WITH HEADER LINE,
         v_name1     LIKE t001w-name1,
         v_line      TYPE i,
         wa_305      LIKE i_305,
         wa_315      LIKE i_315,
         wa_101      LIKE i_101.

DATA: disvariant  LIKE disvariant,
      eventcat    TYPE slis_t_event,
      va_wbwbest  LIKE s032-wbwbest,
      va_mbwbest  LIKE s032-mbwbest,
      va_lgort    LIKE s032-lgort,
      sw          TYPE i,
      va_verpr    LIKE mbew-verpr,
      va_peinh    LIKE mbew-peinh,
      va_nsp      LIKE konp-kbetr,
      v_mblnr     LIKE mseg-mblnr,
      eventcat_ln LIKE LINE OF eventcat,
      fieldcat    TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      ihead       TYPE slis_t_listheader,
      ifoot       TYPE slis_t_listheader,
      ihead_ln    TYPE slis_listheader,
      evtab       TYPE slis_t_event,
      evtab_ln    TYPE slis_alv_event,
      keyinfo     TYPE slis_keyinfo_alv,
      layout      TYPE slis_layout_alv,
      printcat    TYPE slis_print_alv,
      sortcat     TYPE slis_t_sortinfo_alv,
      sortcat_ln  LIKE LINE OF sortcat,
      it_text_ln  TYPE lvc_t_txtp,
      it_text     TYPE lvc_t_txtp WITH HEADER LINE.

DATA: e_save(1)               TYPE c,
      er_fieldcat             TYPE slis_t_fieldcat_alv,
      er_layout               TYPE slis_layout_alv,
      er_sp_group             TYPE slis_t_sp_group_alv,
      er_events               TYPE slis_t_event,
      e_default(1)            TYPE c,
      e_exit(1)               TYPE c,g_repid LIKE sy-repid,
      er_variant              LIKE disvariant,
      e_variant               LIKE disvariant,
      l_dataset(50),
      e_status                TYPE slis_formname VALUE 'STANDARD_ER01',
      e_user_command          TYPE slis_formname VALUE 'USER_COMMAND',
      e_top_of_page           TYPE slis_formname VALUE 'TOP_OF_PAGE',
      g_exit_caused_by_caller,
      gs_exit_caused_by_user  TYPE slis_exit_by_user.

DATA : gt_download TYPE truxs_t_text_data,
       gs_download TYPE LINE OF truxs_t_text_data.

*DATA: GT_EVENTS      TYPE SLIS_T_EVENT,
*      GT_LIST_TOP_OF_PAGE TYPE SLIS_T_LISTHEADER,
*      G_STATUS_SET   TYPE SLIS_FORMNAME VALUE 'PF_STATUS_SET',
*      G_TOP_OF_PAGE  TYPE SLIS_FORMNAME VALUE 'TOP_OF_PAGE',
*      G_TOP_OF_LIST  TYPE SLIS_FORMNAME VALUE 'TOP_OF_LIST',
*      G_END_OF_LIST  TYPE SLIS_FORMNAME VALUE 'END_OF_LIST',
*      XIT_FIELDCAT   TYPE SLIS_T_FIELDCAT_ALV,
*      XIS_PRINT      TYPE SLIS_PRINT_ALV.

TYPES : BEGIN OF ty_ekpo,
          ebeln TYPE ekpo-ebeln,
          ebelp TYPE ekpo-ebelp,
          kunnr TYPE ekpo-kunnr,
          name1 TYPE kna1-name1,
        END OF ty_ekpo.

DATA : gt_ekpo    TYPE STANDARD TABLE OF ty_ekpo.

*---------------------------------------------------------------------*
* DEFINITION OF PARAMETER & SELECTION                                 *
*---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS: p_bukrs LIKE t001-bukrs OBLIGATORY DEFAULT '8020',
            p_werks LIKE t001w-werks OBLIGATORY. "default '0201'.
*              P_MJAHR LIKE MSEG-MJAHR OBLIGATORY,
*              P_BWART LIKE MSEG-BWART OBLIGATORY.
SELECT-OPTIONS: p_umwrk FOR mseg-umwrk,
                p_bwart FOR mseg-bwart OBLIGATORY DEFAULT '303'
                                       NO INTERVALS,
                p_lgort FOR mseg-lgort,
*                  P_KUNNR FOR MSEG-KUNNR,
                p_budat FOR mkpf-budat OBLIGATORY DEFAULT sy-datum MODIF ID bud,
                p_bldat FOR mkpf-bldat,
*                  P_CPUDT FOR MKPF-CPUDT,
                p_matnr FOR mseg-matnr.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block2 WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio1 RADIOBUTTON GROUP grp1 USER-COMMAND rad.
SELECTION-SCREEN : COMMENT 5(30) text-003 FOR FIELD p_radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio2 RADIOBUTTON GROUP grp1 DEFAULT 'X'.
SELECTION-SCREEN : COMMENT 5(30) text-004 FOR FIELD p_radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN : COMMENT 5(30) text-005 FOR FIELD p_radio3.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS : p_radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN: COMMENT 4(26) text-007 FOR FIELD p_radio4.
PARAMETERS : p_path TYPE char128 LOWER CASE MODIF ID 004.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK block2.

SELECTION-SCREEN SKIP 1.
SELECTION-SCREEN BEGIN OF BLOCK c WITH FRAME TITLE text-006.
PARAMETERS : pa_vari TYPE slis_vari.
SELECTION-SCREEN END OF BLOCK c.

*
* VALIDATE FOR SELECTION
*------------------------
AT SELECTION-SCREEN ON p_bukrs.
*  IF P_BUKRS = '8020' OR P_BUKRS = '8030'.
*  ELSE.
*    MESSAGE E000(ZM) WITH 'Only for Company Code "8020" "8030"'.
*  ENDIF.
AT SELECTION-SCREEN ON p_werks.
  AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
      ID 'ACTVT' FIELD '03'
      ID 'WERKS' FIELD p_werks.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with Plant'
     p_werks.
  ENDIF.
*  IF P_BUKRS = '8020'.
*    IF P_WERKS NP '02*'.
*      MESSAGE E000(ZM) WITH 'Plant Must be entry "02xx"'.
*    ENDIF.
*  ELSE.
*    IF P_WERKS NP '03*'.
*      MESSAGE E000(ZM) WITH 'Plant Must be entry "03xx"'.
*    ENDIF.
*  ENDIF.
AT SELECTION-SCREEN ON p_bwart.
  LOOP AT p_bwart.
    IF p_bwart-low NE '303' AND
       p_bwart-low NE '313' AND
       p_bwart-low NE '641' AND
       p_bwart-low NE '907' AND
       p_bwart-low NE '351'.
      MESSAGE e000(zm) WITH 'Only for Movement Type "303" "313" "641" "907" "351"'.
    ENDIF.
  ENDLOOP.
*  Select single * from zplbc
*    where werks = p_werks and live = 'X'.
*  if sy-subrc ne 0.
*      MESSAGE E000(ZM) WITH 'Only For SAP Branch'.
*  endif.
*AT SELECTION-SCREEN ON P_BWART.
*  IF P_BWART-LOW = '303' OR P_BWART-LOW = '641'.
*  ELSE.
*    MESSAGE E000(ZM) WITH 'Only for Movement type "303" "641"'.
*  ENDIF.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_vari.
  PERFORM f4_for_variant.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'XXX'.
      screen-input = '0'.
      MODIFY SCREEN.
    ENDIF.
    IF p_radio4 IS INITIAL.
      IF screen-group1 = '004'.
        screen-active = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*---------------------------------------------------------------------*
* PROGRAM                                                             *
*---------------------------------------------------------------------*
INITIALIZATION.
  CLEAR : itab.
  REFRESH : itab.
  PERFORM variant_init.

* Get default variant
  er_variant = e_variant.
  e_save = 'A'.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = e_save
    CHANGING
      cs_variant = er_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 0.
    pa_vari = er_variant-variant.
  ENDIF.

  IF sy-opsys = 'AIX'.
    p_path = '/interface/ZM60/'.
  ELSE.
    p_path = '\\tdsdev01\interface\ZM60\'.
  ENDIF.

START-OF-SELECTION.
  PERFORM f_get_data.
  PERFORM f_add_customer.
  PERFORM f_process_data.
  DESCRIBE TABLE itab LINES v_line.
  MESSAGE s000(zm) WITH v_line 'Record Selected'.

  IF p_radio4 IS INITIAL.
    PERFORM append_structure_alv.
    PERFORM eventtab_build USING evtab[].
  ELSE.
    PERFORM f_download_with_separator USING '|'.
  ENDIF.

END-OF-SELECTION.

  IF p_radio4 IS INITIAL.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        i_callback_program      = 'ZMR_LISTING_INTRANSIT_ISSUE_NW'
        i_callback_user_command = e_user_command
        i_background_id         = 'ALV_BACKGROUND'
        is_variant              = disvariant
        it_fieldcat             = fieldcat[]
        it_events               = evtab[]
        i_save                  = 'A'
      IMPORTING
        e_exit_caused_by_caller = g_exit_caused_by_caller
        es_exit_caused_by_user  = gs_exit_caused_by_user
      TABLES
        t_outtab                = itab
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.
  ENDIF.

*---------------------------------------------------------------------*
*       FORM USER_COMMAND                                             *
*---------------------------------------------------------------------*
*       Ereigniss USER_COMMAND                                        *
*       event     USER_COMMAND
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                  rs_selfield TYPE slis_selfield.
  DATA feld(10) TYPE c.
  rs_selfield-refresh = 'X'.
  CASE r_ucomm.
    WHEN  'FEHL' OR '&IC1'.
      READ TABLE itab INDEX rs_selfield-tabindex.
      IF rs_selfield-sel_tab_field EQ 'ITAB-MBLNR'.
        IF itab-bwart = '303'.
          SET PARAMETER ID 'MBN' FIELD itab-mblnr.
          SET PARAMETER ID 'MJA' FIELD itab-mjahr.
          CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
        ELSEIF itab-bwart = '641' OR itab-bwart = '907'.
          SET PARAMETER ID 'VL' FIELD itab-mblnr.
          CALL TRANSACTION 'VL03N' AND SKIP FIRST SCREEN.
*          elseif itab-bwart = '161'.
*            set parameter id 'BES' field itab-ebeln.
*            CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
        ENDIF.
      ENDIF.
  ENDCASE.
ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.

  DATA : l_fyear LIKE mkpf-mjahr,
         l_tyear LIKE mkpf-mjahr,
         l_bwart LIKE mseg-bwart,
         l_sw    LIKE sy-subrc,
         l_mblnr LIKE mseg-mblnr.

  DATA: BEGIN OF i_mblnr OCCURS 0,
          mblnr LIKE mseg-mblnr,
        END OF i_mblnr.

  DATA: BEGIN OF i_xblnr OCCURS 0,
          xblnr LIKE mkpf-xblnr,
        END OF i_xblnr.

  DATA: BEGIN OF i_ebeln OCCURS 0,
          ebeln TYPE ebeln,
        END OF i_ebeln.

  DATA: BEGIN OF i_sgtxt OCCURS 0,
          sgtxt LIKE mseg-sgtxt,
        END OF i_sgtxt.

  DATA: BEGIN OF i_umwrk OCCURS 0,
          umwrk LIKE mseg-umwrk,
        END OF i_umwrk.

  DATA   : i303641_detail LIKE i303641 OCCURS 0.

  CONSTANTS : lc_101  TYPE bwart VALUE '101'.
  DATA : po_hist  LIKE bapiekbe OCCURS 0 WITH HEADER LINE,
         po_items LIKE bapiekpo OCCURS 0 WITH HEADER LINE.
  DATA : BEGIN OF lt_kna1 OCCURS 0,
           kunnr TYPE kunnr,
         END OF lt_kna1.

  l_fyear = p_budat-low(4).
  l_tyear = p_budat-high(4).

** Select Nama Cabang
  SELECT SINGLE name1 FROM t001w INTO v_name1
    WHERE werks = p_werks.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '00'
      text       = 'Data is being read...'.
*------------------------------------------------------*
** Select Live Flag
  SELECT * FROM zplbc
    INTO CORRESPONDING FIELDS OF TABLE i_zplbc
    WHERE bukrs = p_bukrs AND
*          werks = p_werks and
          lgort = '1000'.
*          lgort = p_lgort.

** Select Nomor Transaksi
  SELECT DISTINCT a~mblnr a~mjahr a~budat a~bldat a~xblnr
                  a~bktxt b~umwrk b~umlgo b~werks b~lgort
                  b~bwart b~ebeln b~kunnr b~ebelp
    FROM mkpf AS a JOIN mseg AS b ON a~mblnr = b~mblnr AND
                                     a~mjahr = b~mjahr
    INTO CORRESPONDING FIELDS OF TABLE i_mkpf
    WHERE a~budat IN p_budat AND
          a~bldat IN p_bldat AND
          b~bukrs = p_bukrs  AND
          b~bwart IN p_bwart AND
          b~umwrk IN p_umwrk  AND
          ( b~mjahr GE l_fyear AND b~mjahr LE l_tyear ) AND
          b~matnr IN p_matnr AND
          b~werks = p_werks  AND
          b~lgort IN p_lgort AND
          b~xauto = space
    ORDER BY b~bwart a~mblnr.

  IF sy-subrc <> 0.
    MESSAGE s260(aq).
    LEAVE LIST-PROCESSING.
  ENDIF.

  CALL FUNCTION 'VIEW_GET_DATA'
    EXPORTING
      view_name = 'V_T001L_L'
    TABLES
      data      = i_v_t001l_l.
  DELETE i_v_t001l_l WHERE werks NOT IN p_umwrk.

  LOOP AT i_mkpf.

    SELECT SINGLE mblnr FROM mseg INTO l_mblnr
      WHERE smbln = i_mkpf-mblnr AND
            sjahr = i_mkpf-mjahr.

    IF sy-subrc = 0.
      DELETE i_mkpf WHERE bwart = i_mkpf-bwart AND
                          mblnr = i_mkpf-mblnr AND
                          mjahr = i_mkpf-mjahr.
      CONTINUE.
    ENDIF.

** Append Range MBLNR
    i_mblnr-mblnr = i_mkpf-mblnr.
    APPEND i_mblnr.

** Append EBELN.
    IF i_mkpf-bwart EQ '351'.
      i_ebeln-ebeln = i_mkpf-ebeln.
      APPEND i_ebeln.
    ENDIF.

    CASE i_mkpf-bwart.
      WHEN '303' OR '313'.
** Append Range SGTXT
        CONCATENATE i_mkpf-mblnr '/' i_mkpf-mjahr INTO i_sgtxt-sgtxt.
        APPEND i_sgtxt.
        IF i_mkpf-kunnr IS NOT INITIAL.
          i_kunnr-kunnr = i_mkpf-kunnr.
          COLLECT i_kunnr. CLEAR i_kunnr.
        ELSE.
          CLEAR: i_v_t001l_l.
          READ TABLE i_v_t001l_l WITH KEY werks = i_mkpf-umwrk
                                          lgort = i_mkpf-umlgo.
          i_kunnr-kunnr = i_v_t001l_l-kunnr.
          COLLECT i_kunnr. CLEAR i_kunnr.
        ENDIF.
      WHEN '641' OR '907' OR '351'.
** Append Range XBLNR
        i_xblnr-xblnr = i_mkpf-xblnr.
        APPEND i_xblnr.
        CLEAR: i_mkpf-tknum, i_mkpf-erdat, i_mkpf-gesztd.
*        SELECT SINGLE tknum erdat FROM vttp INTO (i_mkpf-tknum, i_mkpf-erdat)
        SELECT SINGLE tknum FROM vttp INTO i_mkpf-tknum
          WHERE vbeln = i_mkpf-xblnr.
        IF sy-subrc = 0.
          SELECT SINGLE datbg gesztd daten uaten signi tpbez route exti1 exti2
                        tdlnr
            FROM vttk
            INTO (i_mkpf-erdat, i_mkpf-gesztd, i_mkpf-daten, i_mkpf-uaten,
                  i_mkpf-signi, i_mkpf-tpbez, i_mkpf-route, i_mkpf-exti1,
                  i_mkpf-exti2, i_mkpf-tdlnr)
            WHERE tknum = i_mkpf-tknum.
          SELECT SINGLE bezei
            FROM tvrot
            INTO i_mkpf-bezei
            WHERE route = i_mkpf-route.
          IF sy-subrc = 0.
            SELECT SINGLE name1 INTO i_mkpf-name1
              FROM lfa1 WHERE lifnr = i_mkpf-tdlnr.
          ENDIF.
        ENDIF.
        IF i_mkpf-kunnr IS NOT INITIAL.
          i_kunnr-kunnr = i_mkpf-kunnr.
          COLLECT i_kunnr. CLEAR i_kunnr.
        ELSE.
          CLEAR: i_v_t001l_l.
          READ TABLE i_v_t001l_l WITH KEY werks = i_mkpf-umwrk
                                          lgort = i_mkpf-umlgo.
          i_kunnr-kunnr = i_v_t001l_l-kunnr.
          COLLECT i_kunnr. CLEAR i_kunnr.
        ENDIF.
    ENDCASE.

** Append Range UMWRK
    i_umwrk-umwrk = i_mkpf-umwrk.
    APPEND i_umwrk.
** Append Range UMLGO
    r_umlgo-sign = 'I'.
    r_umlgo-option = 'EQ'.
    r_umlgo-low = i_mkpf-umlgo.
    APPEND r_umlgo.

    MODIFY i_mkpf.

  ENDLOOP.

  SORT i_ebeln BY ebeln.
  DELETE ADJACENT DUPLICATES FROM i_ebeln COMPARING ebeln.

  IF i_kunnr[] IS NOT INITIAL.
    SELECT kunnr name3
      INTO CORRESPONDING FIELDS OF TABLE i_kna1
      FROM kna1
      FOR ALL ENTRIES IN i_kunnr
      WHERE kunnr = i_kunnr-kunnr.
  ENDIF.

  SORT i_umwrk BY umwrk.
  DELETE ADJACENT DUPLICATES FROM i_umwrk COMPARING umwrk.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '20'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  DESCRIBE TABLE i_mblnr LINES l_sw.
  IF l_sw > 0.
** Select Data 303 & 641
    IF i_mblnr[] IS NOT INITIAL.
      SELECT bwart mblnr matnr menge dmbtr zeile ebeln ebelp
        FROM mseg INTO TABLE i303641_detail
        FOR ALL ENTRIES IN i_mblnr
        WHERE
*            bukrs = p_bukrs                           and
*            bwart in p_bwart                          and
              umwrk IN p_umwrk                          AND
              mblnr = i_mblnr-mblnr                     AND
              ( mjahr GE l_fyear AND mjahr LE l_tyear ) AND
              matnr IN p_matnr                          AND
*            werks = p_werks                           and
*            lgort in p_lgort                          and
              xauto = space
*      group by bwart mblnr matnr.
      %_HINTS DB6 'USE_OPTLEVEL 0'.
      SORT i303641_detail BY bwart mblnr ebeln matnr.
*    Sort i303641_detail by bwart mblnr matnr.

      LOOP AT i303641_detail INTO i303641.
        IF i303641-bwart EQ '351'.
        ELSE.
* Double record 641
*          CLEAR i303641-ebelp.
        ENDIF.
        i303641-zeile = ''.
*      i303641-ebeln = ''.
        COLLECT i303641.
      ENDLOOP.
    ENDIF.

    REFRESH : i303641_detail.

  ENDIF.
  IF sy-subrc <> 0.
    MESSAGE s260(aq).
    LEAVE LIST-PROCESSING.
  ENDIF.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '40'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  LOOP AT p_bwart.
    CASE p_bwart-low.

      WHEN '303'.
** Select Data 305
        LOOP AT i_umwrk.
          IF i_sgtxt[] IS NOT INITIAL.
            SELECT bwart sgtxt matnr mjahr mblnr zeile menge dmbtr
              FROM mseg APPENDING TABLE i_305_detail
              FOR ALL ENTRIES IN i_sgtxt
              WHERE werks = i_umwrk-umwrk AND
                    bwart = '305'    AND
                    xauto = ''       AND
                    sgtxt = i_sgtxt-sgtxt AND
                    matnr IN p_matnr.
          ENDIF.
        ENDLOOP.
        LOOP AT i_305_detail.
          SELECT SINGLE mblnr INTO v_mblnr FROM mseg
          WHERE sjahr = i_305_detail-mjahr AND
                smbln = i_305_detail-mblnr AND
                smblp = i_305_detail-zeile.
          IF sy-subrc <> 0.
            MOVE-CORRESPONDING i_305_detail TO i_305.
            SELECT SINGLE cpudt budat FROM mkpf
              INTO CORRESPONDING FIELDS OF i_305
              WHERE mblnr = i_305-mblnr.
            COLLECT i_305.
          ENDIF.
        ENDLOOP.
        SORT i_305 BY bwart sgtxt matnr mblnr.
        REFRESH i_305_detail.

      WHEN '313'.
** Select Data 305
        LOOP AT i_umwrk.
          IF i_sgtxt[] IS NOT INITIAL.
            SELECT bwart sgtxt matnr mjahr mblnr zeile menge dmbtr
              FROM mseg APPENDING TABLE i_315_detail
              FOR ALL ENTRIES IN i_sgtxt
              WHERE werks = i_umwrk-umwrk AND
                    bwart = '315'    AND
                    xauto = ''       AND
                    sgtxt = i_sgtxt-sgtxt AND
                    matnr IN p_matnr.
          ENDIF.
        ENDLOOP.
        LOOP AT i_315_detail.
          SELECT SINGLE mblnr INTO v_mblnr FROM mseg
          WHERE sjahr = i_315_detail-mjahr AND
                smbln = i_315_detail-mblnr AND
                smblp = i_315_detail-zeile.
          IF sy-subrc <> 0.
            MOVE-CORRESPONDING i_315_detail TO i_315.
            SELECT SINGLE cpudt budat FROM mkpf
              INTO CORRESPONDING FIELDS OF i_315
              WHERE mblnr = i_315-mblnr.
            COLLECT i_315.
          ENDIF.
        ENDLOOP.
        SORT i_315 BY bwart sgtxt matnr mblnr.
        REFRESH i_315_detail.

      WHEN '641' OR '907'.
** Select Data 101
        IF p_bwart-low = '641'.
          LOOP AT i_umwrk.
            IF i_xblnr[] IS NOT INITIAL.
              SELECT bwart xblnr matnr gjahr belnr buzei menge dmbtr ebeln "ebelp
                FROM ekbe APPENDING TABLE i_101_detail
                FOR ALL ENTRIES IN i_xblnr
                WHERE werks = i_umwrk-umwrk AND
                      bwart = '101'    AND
                      xblnr = i_xblnr-xblnr AND
                      matnr IN p_matnr.
            ENDIF.
          ENDLOOP.
        ELSEIF p_bwart-low = '907'.
          IF i_xblnr[] IS NOT INITIAL.
            SELECT bwart xblnr matnr gjahr belnr buzei menge dmbtr ebeln "ebelp
              FROM ekbe APPENDING TABLE i_101_detail
              FOR ALL ENTRIES IN i_xblnr
              WHERE "werks = i_umwrk-umwrk AND
                    bwart = '101'    AND
                    xblnr = i_xblnr-xblnr AND
                    matnr IN p_matnr.
          ENDIF.
        ENDIF.

        LOOP AT i_101_detail.
          SELECT SINGLE mblnr INTO v_mblnr FROM mseg
          WHERE sjahr = i_101_detail-gjahr AND
                smbln = i_101_detail-belnr AND
                smblp = i_101_detail-buzei.
          IF sy-subrc <> 0.
            MOVE-CORRESPONDING i_101_detail TO i_101.
            SELECT SINGLE cpudt budat FROM mkpf
              INTO CORRESPONDING FIELDS OF i_101
              WHERE mblnr = i_101-belnr.
            COLLECT i_101.
          ENDIF.
        ENDLOOP.
        SORT i_101 BY bwart xblnr matnr ebeln belnr. "ebelp.
        REFRESH i_101_detail.

      WHEN '351'.
        LOOP AT i_ebeln.
          CLEAR : po_hist, po_hist[], po_items, po_items[].
          CALL FUNCTION 'BAPI_PO_GETDETAIL'
            EXPORTING
              purchaseorder   = i_ebeln-ebeln
              history         = 'X'
            TABLES
              po_items        = po_items
              po_item_history = po_hist.

          DELETE po_hist WHERE move_type NE lc_101.
          SORT po_hist BY po_item mat_doc DESCENDING.
          DELETE ADJACENT DUPLICATES FROM po_hist COMPARING po_item.

          LOOP AT po_hist.
            i_101-bwart   = po_hist-move_type.
            i_101-xblnr   = po_hist-ref_doc_no.
            i_101-matnr   = po_hist-material.
            i_101-belnr   = po_hist-mat_doc.
            i_101-menge   = po_hist-quantity.
            i_101-dmbtr   = po_hist-val_loccur.
            i_101-budat   = po_hist-pstng_date.
            i_101-cpudt   = po_hist-entry_date.
            i_101-ebeln   = i_ebeln-ebeln.
            i_101-ebelp   = po_hist-po_item.
            READ TABLE po_items WITH KEY po_number = i_101-ebeln
                                         po_item   = i_101-ebelp.
            IF po_items-del_compl IS NOT INITIAL.
              i_101-lgort   = po_items-store_loc.
              APPEND i_101.
            ENDIF.
          ENDLOOP.
        ENDLOOP.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.

  DATA : l_bwart LIKE mseg-bwart,
         l_live  LIKE zplbc-live,
         l_sw    LIKE sy-subrc,
         a       LIKE sy-tabix,
         b       LIKE sy-tabix,
         c       LIKE sy-tabix,
         sw_1(1), sw_2(1).

  DATA : ls_ekpo  LIKE LINE OF gt_ekpo.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '80'
      text       = 'Data is being read...'.
*------------------------------------------------------*
  LOOP AT i_mkpf.

    CLEAR itab.
    MOVE-CORRESPONDING i_mkpf TO itab.

    CLEAR ls_ekpo.
    READ TABLE gt_ekpo INTO ls_ekpo
                       WITH KEY ebeln = itab-ebeln
                                ebelp = itab-ebelp.
    IF sy-subrc = 0.
      itab-custo  = ls_ekpo-kunnr.
      itab-namec  = ls_ekpo-name1.
    ENDIF.

    IF i_mkpf-kunnr(3) = 'TBA'.
      CLEAR: i_kna1,i_v_t001l_l.
      READ TABLE i_kna1 WITH KEY kunnr = i_mkpf-kunnr.
      READ TABLE i_v_t001l_l WITH KEY kunnr = i_mkpf-kunnr
                                      werks = i_mkpf-umwrk.
      itab-name3 = i_kna1-name3.
      itab-umlgo = i_v_t001l_l-lgort.
    ELSEIF i_mkpf-kunnr IS INITIAL.
      CLEAR: i_kna1,i_v_t001l_l.
      READ TABLE i_v_t001l_l WITH KEY werks = i_mkpf-umwrk
                                      lgort = i_mkpf-umlgo.
      READ TABLE i_kna1 WITH KEY kunnr = i_v_t001l_l-kunnr.
      itab-name3 = i_kna1-name3.
      itab-kunnr = i_v_t001l_l-kunnr.
    ENDIF.

*  if itab-kunnr not in p_kunnr.
*    continue.
*  endif.

    IF itab-erdat IS NOT INITIAL.
      itab-etdat = itab-erdat + ( i_mkpf-gesztd / 240000 ).
    ENDIF.
    itab-daten = i_mkpf-daten.

    IF i_mkpf-uaten IS INITIAL.
      CLEAR itab-uatenc.
    ELSE.
*      itab-uaten = i_mkpf-uaten.
      WRITE i_mkpf-uaten TO itab-uatenc.
    ENDIF.


** Baca Table ZPLBC
    CLEAR l_live.
    READ TABLE i_zplbc WITH KEY bukrs = p_bukrs
                                werks = i_mkpf-umwrk.
*                              lgort = i_mkpf-umlgo.
    l_live = i_zplbc-live.

** Baca Table 303 &  641
    IF i_mkpf-bwart EQ '351'.
      READ TABLE i303641 WITH KEY bwart = i_mkpf-bwart
                                  mblnr = i_mkpf-mblnr
                                  ebeln = i_mkpf-ebeln
                                  ebelp = i_mkpf-ebelp.
    ELSE.
* Double record 641
      READ TABLE i303641 WITH KEY bwart = i_mkpf-bwart
                                  mblnr = i_mkpf-mblnr
                                  ebeln = i_mkpf-ebeln
                                  ebelp = i_mkpf-ebelp.

*      READ TABLE i303641 WITH KEY bwart = i_mkpf-bwart
*                                  mblnr = i_mkpf-mblnr
*                                  ebeln = i_mkpf-ebeln BINARY SEARCH.
**                              ebelp = i_mkpf-ebelp binary search.
    ENDIF.

    a = sy-tabix.

    LOOP AT i303641 FROM a.

      IF i303641-bwart EQ '351'.
        IF i303641-bwart = i_mkpf-bwart AND
           i303641-mblnr = i_mkpf-mblnr AND
           i303641-ebeln = i_mkpf-ebeln AND
           i303641-ebelp = i_mkpf-ebelp.
        ELSE.
          EXIT.
        ENDIF.
      ELSE.
* Double record 641
        IF i303641-bwart = i_mkpf-bwart AND
           i303641-mblnr = i_mkpf-mblnr AND
           i303641-ebeln = i_mkpf-ebeln AND
           i303641-ebelp = i_mkpf-ebelp.
*    if i303641-bwart = i_mkpf-bwart and
*       i303641-mblnr = i_mkpf-mblnr.
        ELSE.
          EXIT.
        ENDIF.

*        IF i303641-bwart = i_mkpf-bwart AND
*           i303641-mblnr = i_mkpf-mblnr AND
*           i303641-ebeln = i_mkpf-ebeln.
**       i303641-ebelp = i_mkpf-ebelp.
**    if i303641-bwart = i_mkpf-bwart and
**       i303641-mblnr = i_mkpf-mblnr.
*        ELSE.
*          EXIT.
*        ENDIF.
      ENDIF.

      CLEAR: itab-matnr, itab-maktx, itab-menge, itab-dmbtr, itab-nsp,
             itab-bwart1, itab-mblnr1, itab-matnr1, itab-maktx1,
             itab-menge1, itab-dmbtr1, itab-bbkno, itab-cpudt1,
             itab-budat1, itab-leadt.

      MOVE-CORRESPONDING i303641 TO itab.
      itab-nsp = ( itab-dmbtr * 100 / itab-menge ).
      CONCATENATE itab-mblnr '/' itab-mjahr INTO itab-sgtxt.
      SELECT SINGLE maktx FROM makt INTO itab-maktx
        WHERE matnr = itab-matnr.

      IF itab-umlgo IS INITIAL.
        SELECT SINGLE lgort FROM ekpo INTO itab-umlgo
          WHERE ebeln = itab-ebeln
            AND ebelp = itab-ebelp.
      ENDIF.

      CASE i303641-bwart.

* Mvt Type 303
        WHEN '303'.
          CLEAR i_305.
          IF p_bukrs EQ '8070'.
            itab-bbkno = i_mkpf-bktxt+3(5).
          ELSE.
            itab-bbkno = i_mkpf-bktxt+7(5).
          ENDIF.
          READ TABLE i_305 WITH KEY bwart = '305'
                                    sgtxt = itab-sgtxt
                                    matnr = itab-matnr BINARY SEARCH.
          b = sy-tabix.

          IF p_radio1 = 'X' OR p_radio4 = 'X'.
            itab-bwart1 = i_305-bwart.
            itab-mblnr1 = i_305-mblnr.
            itab-matnr1 = i_305-matnr.
            itab-menge1 = i_305-menge.
            itab-dmbtr1 = i_305-dmbtr.
            itab-cpudt1 = i_305-cpudt.
            itab-budat1 = i_305-budat.
            IF i_305-cpudt > 0.
              IF l_live = 'X'.
                itab-leadt = itab-cpudt1 - itab-budat.
              ELSE.
                itab-leadt = itab-budat1 - itab-budat.
              ENDIF.
            ENDIF.
            IF itab-matnr1 NE space.
              itab-maktx1 = itab-maktx.
            ENDIF.
            APPEND itab.
          ENDIF.

          IF p_radio2 = 'X'.
            CLEAR sw_1.
            LOOP AT i_305 FROM b.
              IF i_305-bwart = '305'      AND
                 i_305-sgtxt = itab-sgtxt AND
                 i_305-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_305.
              MOVE-CORRESPONDING i_305 TO wa_305.

              itab-menge1 = itab-menge1 + wa_305-menge.
              sw_1 = '1'.

            ENDLOOP.
            IF sw_1 IS INITIAL.
              APPEND itab. CLEAR itab-menge1.
            ELSE.
              IF itab-menge1 LT itab-menge.
                itab-bwart1 = wa_305-bwart.
                itab-mblnr1 = wa_305-mblnr.
                itab-matnr1 = wa_305-matnr.
                itab-dmbtr1 = wa_305-dmbtr.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                APPEND itab. CLEAR itab-menge1.
              ENDIF.
            ENDIF.
          ENDIF.

          IF p_radio3 = 'X'.
            CLEAR sw_2.
            LOOP AT i_305 FROM b.
              IF i_305-bwart = '305'      AND
                 i_305-sgtxt = itab-sgtxt AND
                 i_305-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_305.
              MOVE-CORRESPONDING i_305 TO wa_305.

              itab-menge1 = itab-menge1 + wa_305-menge.

            ENDLOOP.

            IF itab-menge1 GE itab-menge.
              itab-bwart1 = wa_305-bwart.
              itab-mblnr1 = wa_305-mblnr.
              itab-matnr1 = wa_305-matnr.
              itab-dmbtr1 = wa_305-dmbtr.
              itab-cpudt1 = wa_305-cpudt.
              itab-budat1 = wa_305-budat.
              IF wa_305-cpudt > 0.
                IF l_live = 'X'.
                  itab-leadt = itab-cpudt1 - itab-budat.
                ELSE.
                  itab-leadt = itab-budat1 - itab-budat.
                ENDIF.
              ENDIF.
              IF itab-matnr1 NE space.
                itab-maktx1 = itab-maktx.
              ENDIF.
              APPEND itab. CLEAR itab-menge1.
            ENDIF.

          ENDIF.

* Mvt Type 313
        WHEN '313'.
          CLEAR i_315.
          IF p_bukrs EQ '8070'.
            itab-bbkno = i_mkpf-bktxt+3(5).
          ELSE.
            itab-bbkno = i_mkpf-bktxt+7(5).
          ENDIF.
          READ TABLE i_315 WITH KEY bwart = '315'
                                    sgtxt = itab-sgtxt
                                    matnr = itab-matnr BINARY SEARCH.
          b = sy-tabix.

          IF p_radio1 = 'X' OR p_radio4 = 'X'.
            itab-bwart1 = i_315-bwart.
            itab-mblnr1 = i_315-mblnr.
            itab-matnr1 = i_315-matnr.
            itab-menge1 = i_315-menge.
            itab-dmbtr1 = i_315-dmbtr.
            itab-cpudt1 = i_315-cpudt.
            itab-budat1 = i_315-budat.
            IF i_315-cpudt > 0.
              IF l_live = 'X'.
                itab-leadt = itab-cpudt1 - itab-budat.
              ELSE.
                itab-leadt = itab-budat1 - itab-budat.
              ENDIF.
            ENDIF.
            IF itab-matnr1 NE space.
              itab-maktx1 = itab-maktx.
            ENDIF.
            APPEND itab.
          ENDIF.

          IF p_radio2 = 'X'.
            CLEAR sw_1.
            LOOP AT i_315 FROM b.
              IF i_315-bwart = '315'      AND
                 i_315-sgtxt = itab-sgtxt AND
                 i_315-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_315.
              MOVE-CORRESPONDING i_315 TO wa_315.

              itab-menge1 = itab-menge1 + wa_315-menge.
              sw_1 = '1'.

            ENDLOOP.
            IF sw_1 IS INITIAL.
              APPEND itab. CLEAR itab-menge1.
            ELSE.
              IF itab-menge1 LT itab-menge.
                itab-bwart1 = wa_315-bwart.
                itab-mblnr1 = wa_315-mblnr.
                itab-matnr1 = wa_315-matnr.
                itab-dmbtr1 = wa_315-dmbtr.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                APPEND itab. CLEAR itab-menge1.
              ENDIF.
            ENDIF.
          ENDIF.

          IF p_radio3 = 'X'.
            CLEAR sw_2.
            LOOP AT i_315 FROM b.
              IF i_315-bwart = '315'      AND
                 i_315-sgtxt = itab-sgtxt AND
                 i_315-matnr = itab-matnr.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_315.
              MOVE-CORRESPONDING i_315 TO wa_315.

              itab-menge1 = itab-menge1 + wa_315-menge.

            ENDLOOP.

            IF itab-menge1 GE itab-menge.
              itab-bwart1 = wa_315-bwart.
              itab-mblnr1 = wa_315-mblnr.
              itab-matnr1 = wa_315-matnr.
              itab-dmbtr1 = wa_315-dmbtr.
              itab-cpudt1 = wa_315-cpudt.
              itab-budat1 = wa_315-budat.
              IF wa_315-cpudt > 0.
                IF l_live = 'X'.
                  itab-leadt = itab-cpudt1 - itab-budat.
                ELSE.
                  itab-leadt = itab-budat1 - itab-budat.
                ENDIF.
              ENDIF.
              IF itab-matnr1 NE space.
                itab-maktx1 = itab-maktx.
              ENDIF.
              APPEND itab. CLEAR itab-menge1.
            ENDIF.

          ENDIF.

* Mvt Type 641
        WHEN '641' OR '907' OR '351'.
          CLEAR i_101.
          IF itab-bwart NE '351'.
            itab-mblnr = itab-xblnr.
          ENDIF.
*        read table i_101 with key bwart = '101'
*                                  xblnr = itab-mblnr
*                                  matnr = itab-matnr binary search.
          CLEAR l_sw.
          IF itab-bwart EQ '351'.
            READ TABLE i_101 WITH KEY bwart = '101'
                                      xblnr = itab-mblnr
                                      matnr = itab-matnr
                                      ebeln = itab-ebeln
                                      ebelp = itab-ebelp.  "BINARY SEARCH.
            IF sy-subrc <> 0.
              READ TABLE i_101 WITH KEY bwart = '101'
                                        matnr = itab-matnr
                                        ebeln = itab-ebeln
                                        ebelp = itab-ebelp.  "BINARY SEARCH.
            ENDIF.
          ELSE.
            READ TABLE i_101 WITH KEY bwart = '101'
                                      xblnr = itab-mblnr
                                      matnr = itab-matnr
                                      ebeln = itab-ebeln.  "BINARY SEARCH.
*                                  ebelp = itab-ebelp binary search.
          ENDIF.
          c = sy-tabix.
          l_sw = sy-subrc.

          IF p_radio1 = 'X' OR p_radio4 = 'X'.
            IF l_sw IS INITIAL.
              IF itab-bwart EQ '351'.
                itab-umlgo  = i_101-lgort.
                CLEAR: i_v_t001l_l.
                READ TABLE i_v_t001l_l WITH KEY werks = itab-umwrk
                                                lgort = i_101-lgort.
                itab-name3 = i_v_t001l_l-name1_werk.
              ENDIF.
            ENDIF.
            itab-bwart1 = i_101-bwart.
            itab-mblnr1 = i_101-belnr.
            itab-matnr1 = i_101-matnr.
            itab-menge1 = i_101-menge.
            itab-dmbtr1 = i_101-dmbtr.
            itab-cpudt1 = i_101-cpudt.
            itab-budat1 = i_101-budat.
            IF i_101-cpudt > 0.
              IF l_live = 'X'.
                itab-leadt = itab-cpudt1 - itab-budat.
              ELSE.
                itab-leadt = itab-budat1 - itab-budat.
              ENDIF.
            ENDIF.
            IF itab-matnr1 NE space.
              itab-maktx1 = itab-maktx.
            ENDIF.
            APPEND itab.
          ENDIF.

          IF p_radio2 = 'X'.
            CLEAR sw_1.
            LOOP AT i_101 FROM c.
              IF i_101-bwart = '101'      AND
                 i_101-xblnr = itab-mblnr AND
                 i_101-matnr = itab-matnr AND
                 i_101-ebeln = itab-ebeln.
              ELSEIF i_101-bwart = '101'  AND
                 i_101-matnr = itab-matnr AND
                 i_101-ebeln = itab-ebeln.
              ELSE.
                EXIT.
              ENDIF.
              CLEAR wa_101.
              MOVE-CORRESPONDING i_101 TO wa_101.

              IF l_sw IS INITIAL.
                IF itab-bwart EQ '351'.
                  itab-umlgo  = wa_101-lgort.
                  CLEAR: i_v_t001l_l.
                  READ TABLE i_v_t001l_l WITH KEY werks = itab-umwrk
                                                  lgort = i_101-lgort.
                  itab-name3 = i_v_t001l_l-name1_werk.
                ENDIF.
              ENDIF.

              itab-menge1 = itab-menge1 + wa_101-menge.
              sw_1 = '1'.
            ENDLOOP.

            IF sw_1 IS INITIAL.
              APPEND itab. CLEAR itab-menge1.
            ELSE.
              IF itab-menge1 LT itab-menge.
                itab-bwart1 = wa_101-bwart.
                itab-mblnr1 = wa_101-belnr.
                itab-matnr1 = wa_101-matnr.
                itab-dmbtr1 = wa_101-dmbtr.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                IF itab-bwart EQ '351'.
                ELSE.
                  APPEND itab. CLEAR itab-menge1.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.

          IF p_radio3 = 'X'.
            CLEAR sw_2.
            LOOP AT i_101 FROM c.
              IF itab-bwart EQ '351'.
                IF i_101-bwart = '101'      AND
                   i_101-xblnr = itab-mblnr AND
                   i_101-matnr = itab-matnr AND
                   i_101-ebeln = itab-ebeln AND
                   i_101-ebelp = itab-ebelp.
                ELSEIF i_101-bwart = '101'  AND
                   i_101-matnr = itab-matnr AND
                   i_101-ebeln = itab-ebeln AND
                   i_101-ebelp = itab-ebelp.
                ELSE.
                  EXIT.
                ENDIF.
              ELSE.
                IF i_101-bwart = '101'      AND
                   i_101-xblnr = itab-mblnr AND
                   i_101-matnr = itab-matnr AND
                   i_101-ebeln = itab-ebeln.
                ELSE.
                  EXIT.
                ENDIF.
              ENDIF.

              CLEAR wa_101.
              MOVE-CORRESPONDING i_101 TO wa_101.

              IF l_sw IS INITIAL.
                IF itab-bwart EQ '351'.
                  itab-umlgo  = wa_101-lgort.
                  CLEAR: i_v_t001l_l.
                  READ TABLE i_v_t001l_l WITH KEY werks = itab-umwrk
                                                  lgort = i_101-lgort.
                  itab-name3 = i_v_t001l_l-name1_werk.
                ENDIF.
              ENDIF.

              sw_2 = 1.
              itab-menge1 = itab-menge1 + wa_101-menge.
            ENDLOOP.

            IF itab-bwart EQ '351'.
              IF sw_2 IS NOT INITIAL.
                itab-bwart1 = wa_101-bwart.
                itab-mblnr1 = wa_101-belnr.
                itab-matnr1 = wa_101-matnr.
                itab-dmbtr1 = wa_101-dmbtr.
                itab-cpudt1 = wa_101-cpudt.
                itab-budat1 = wa_101-budat.
                APPEND itab. CLEAR itab-menge1.
              ENDIF.
            ELSE.
              IF itab-menge1 GE itab-menge.
                itab-bwart1 = wa_101-bwart.
                itab-mblnr1 = wa_101-belnr.
                itab-matnr1 = wa_101-matnr.
                itab-dmbtr1 = wa_101-dmbtr.
                itab-cpudt1 = wa_101-cpudt.
                itab-budat1 = wa_101-budat.
                IF wa_101-cpudt > 0.
                  IF l_live = 'X'.
                    itab-leadt = itab-cpudt1 - itab-budat.
                  ELSE.
                    itab-leadt = itab-budat1 - itab-budat.
                  ENDIF.
                ENDIF.
                IF itab-matnr1 NE space.
                  itab-maktx1 = itab-maktx.
                ENDIF.
                APPEND itab. CLEAR itab-menge1.
              ENDIF.
            ENDIF.
          ENDIF.
      ENDCASE.
    ENDLOOP.
  ENDLOOP.

  PERFORM f_modify_data.

*------------------------------------------------------*
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = '100'
      text       = 'Data is being process...'.
*------------------------------------------------------*
  REFRESH : i_mkpf, i303641.
ENDFORM.                    " f_process_data

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
  e_variant-report = sy-repid.

ENDFORM.                    " VARIANT_INIT

*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_for_variant.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = e_variant
      i_save     = e_save
*     it_default_fieldcat =
    IMPORTING
      e_exit     = e_exit
      es_variant = disvariant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF e_exit = space.
      pa_vari = disvariant-variant.
    ENDIF.
  ENDIF.

ENDFORM.                    " F4_FOR_VARIANT

*&---------------------------------------------------------------------*
*&      Form  append_structure_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM append_structure_alv.
  DATA : lv_col   TYPE sy-cucol.

* col 1
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'WERKS'. fieldcat-ref_fieldname = 'WERKS'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 7. fieldcat-just = 'L'.
  fieldcat-seltext_s = 'Spl Pln'.
  fieldcat-seltext_m = 'Spl Plant'.
  fieldcat-seltext_l = 'Supply Plant'.
  APPEND fieldcat. "clear fieldcat.

* col 2
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'LGORT'. fieldcat-ref_fieldname = 'LGORT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 7. fieldcat-just = 'L'.
  fieldcat-seltext_s = 'Spl Sloc'.
  fieldcat-seltext_m = 'Spl Sloc'.
  fieldcat-seltext_l = 'Supply Sloc'.
  APPEND fieldcat. "clear fieldcat.

* col 3
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MBLNR'. fieldcat-ref_fieldname = 'MBLNR'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 10. fieldcat-just = 'L'.
  fieldcat-seltext_s = 'Doc No.'.
  fieldcat-seltext_m = 'Doc No.'.
  fieldcat-seltext_l = 'Doc Number'.
  fieldcat-hotspot = 'X'.
  APPEND fieldcat. "clear fieldcat.

* col 4
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BWART'. fieldcat-ref_fieldname = 'BWART'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col. fieldcat-key = 'X'.
  fieldcat-outputlen = 7. fieldcat-just = 'L'.
  fieldcat-seltext_s = 'Mvt'.
  fieldcat-seltext_m = 'Mvt'.
  fieldcat-seltext_l = 'Movement Type'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

  CLEAR fieldcat-key.
*  fieldcat-just = 'R'.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'LPRIO1'. fieldcat-ref_fieldname = 'LPRIO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 2.
  fieldcat-seltext_s = 'STO Prio'.
  fieldcat-seltext_m = 'STO Prio'.
  fieldcat-seltext_l = 'STO Priority'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BEZE2'. fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Desc'.
  fieldcat-seltext_m = 'Desc'.
  fieldcat-seltext_l = 'Description'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'LPRIO'. fieldcat-ref_fieldname = 'LPRIO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 2.
  fieldcat-seltext_s = 'DN Prio'.
  fieldcat-seltext_m = 'DN Prio'.
  fieldcat-seltext_l = 'DN Priority'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BEZE1'. fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Desc'.
  fieldcat-seltext_m = 'Desc'.
  fieldcat-seltext_l = 'Description'.
  fieldcat-hotspot = ' '.
  APPEND fieldcat. "clear fieldcat.

* col 5
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MATNR'. fieldcat-ref_fieldname = 'MATNR'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Supl Material'.
  fieldcat-seltext_m = 'Supl Material'.
  fieldcat-seltext_l = 'Supl Material'.
  APPEND fieldcat. "clear fieldcat.

* col 6
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MAKTX'. fieldcat-ref_fieldname = 'MAKTX'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Supl Mat Desc'.
  fieldcat-seltext_m = 'Supl Material Desc'.
  fieldcat-seltext_l = 'Supl Material Description'.
  APPEND fieldcat. "clear fieldcat.

* col 7
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MENGE'. fieldcat-ref_fieldname = 'MENGE'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 15.
  fieldcat-decimals_out = '2'.
  fieldcat-just = 'R'.
  fieldcat-seltext_s = 'Supl Qty'.
  fieldcat-seltext_m = 'Supl Quantity'.
  fieldcat-seltext_l = 'Supl Quantity'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR fieldcat-currency.

* col 8
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'DMBTR'. fieldcat-ref_fieldname = 'DMBTR'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 15.
  fieldcat-decimals_out = '0'.
  fieldcat-just = 'R'.
  fieldcat-currency = 'IDR'.
  fieldcat-seltext_s = 'Supl Value'.
  fieldcat-seltext_m = 'Supl Value'.
  fieldcat-seltext_l = 'Supl Posting Value'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR fieldcat-currency.

* col 9
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BUDAT'. fieldcat-ref_fieldname = 'BUDAT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-just = ' '.
  fieldcat-seltext_s = 'Post Dt'.
  fieldcat-seltext_m = 'Post Date'.
  fieldcat-seltext_l = 'Posting Date'.
  APPEND fieldcat. "clear fieldcat.

* col 10
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BLDAT'. fieldcat-ref_fieldname = 'BLDAT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Doc Date'.
  fieldcat-seltext_m = 'Doc Date'.
  fieldcat-seltext_l = 'Document Date'.
  APPEND fieldcat. "clear fieldcat.

* col 11
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'UMWRK'. fieldcat-ref_fieldname = 'UMWRK'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Rcv Pln'.
  fieldcat-seltext_m = 'Rcv Plant'.
  fieldcat-seltext_l = 'Receiving Plant'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 7.
  APPEND fieldcat. "clear fieldcat.
  CLEAR fieldcat-currency.

* col 12
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'UMLGO'. fieldcat-ref_fieldname = 'UMLGO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 7.
  fieldcat-seltext_s = 'Rcv Sloc'.
  fieldcat-seltext_m = 'Rcv Sloc'.
  fieldcat-seltext_l = 'Receiving Sloc'.
  fieldcat-decimals_out = '0'.
  APPEND fieldcat. "clear fieldcat.

* col 2.1
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'NAME3'. fieldcat-ref_fieldname = 'NAME3'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 20.
  fieldcat-seltext_s = 'Rcv Cust'.
  fieldcat-seltext_m = 'Rcv Cust'.
  fieldcat-seltext_l = 'Receiving Cust'.
  APPEND fieldcat. "clear fieldcat.

* col 13
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MBLNR1'. fieldcat-ref_fieldname = 'MBLNR1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Recv. Doc'.
  fieldcat-seltext_m = 'Recv. Doc'.
  fieldcat-seltext_l = 'Receiving Doc'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 14
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BWART1'. fieldcat-ref_fieldname = 'BWART1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 7.
  fieldcat-seltext_s = 'Rcv Mvt'.
  fieldcat-seltext_m = 'Rcv Mvt'.
  fieldcat-seltext_l = 'Receiving Mvt'.
  APPEND fieldcat. "clear fieldcat.

* col 15
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MATNR1'. fieldcat-ref_fieldname = 'MATNR1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  fieldcat-seltext_s = 'Recv Material'.
  fieldcat-seltext_m = 'Recv Material'.
  fieldcat-seltext_l = 'Recv Material'.
  APPEND fieldcat. "clear fieldcat.

* col 16
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MAKTX1'. fieldcat-ref_fieldname = 'MAKTX1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 25.
  fieldcat-seltext_s = 'Recv Mat Desc'.
  fieldcat-seltext_m = 'Recv Material Desc'.
  fieldcat-seltext_l = 'Recv Material Description'.
  APPEND fieldcat. "clear fieldcat.

* col 17
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'MENGE1'. fieldcat-ref_fieldname = 'MENGE1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 15.
  fieldcat-decimals_out = '2'.
  fieldcat-just = 'R'.
  fieldcat-seltext_s = 'Recv Qty'.
  fieldcat-seltext_m = 'Recv Quantity'.
  fieldcat-seltext_l = 'Recv Quantity'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR fieldcat-currency.

* col 18
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'DMBTR1'. fieldcat-ref_fieldname = 'DMBTR1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 15.
  fieldcat-decimals_out = '0'.
  fieldcat-just = 'R'.
  fieldcat-currency = 'IDR'.
  fieldcat-seltext_s = 'Recv Value'.
  fieldcat-seltext_m = 'Recv Value'.
  fieldcat-seltext_l = 'Recv Posting Value'.
  APPEND fieldcat. "clear fieldcat.
  CLEAR: fieldcat-just,fieldcat-currency.

* col 19
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BUDAT1'. fieldcat-ref_fieldname = 'BUDAT1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Recv Date'.
  fieldcat-seltext_m = 'Recv Date'.
  fieldcat-seltext_l = 'Recv Date'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 20
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'CPUDT1'. fieldcat-ref_fieldname = 'CPUDT1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Entry Date'.
  fieldcat-seltext_m = 'Entry Date'.
  fieldcat-seltext_l = 'Entry Date'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 21
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'LEADT'. fieldcat-ref_fieldname = 'LEADT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-just = 'R'.
  fieldcat-seltext_s = 'Lead Time'.
  fieldcat-seltext_m = 'Lead Time'.
  fieldcat-seltext_l = 'Lead Time'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.
  CLEAR fieldcat-just.

* col 22
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'EBELN'. fieldcat-ref_fieldname = 'EBELN'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'PO Number'.
  fieldcat-seltext_m = 'PO Number'.
  fieldcat-seltext_l = 'PO Number'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 23
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BBKNO'. fieldcat-ref_fieldname = 'BBKNO'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'BBK Number'.
  fieldcat-seltext_m = 'BBK Number'.
  fieldcat-seltext_l = 'BBK Number'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 24
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'TKNUM'. fieldcat-ref_fieldname = 'TKNUM'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Ship No'.
  fieldcat-seltext_m = 'Ship No'.
  fieldcat-seltext_l = 'Ship No'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 25
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'ERDAT'. fieldcat-ref_fieldname = 'ERDAT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Ship Date/ETD'.
  fieldcat-seltext_m = 'Ship Date/ETD'.
  fieldcat-seltext_l = 'Ship Date/ETD'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 13.
  APPEND fieldcat. "clear fieldcat.

* col 26
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'ETDAT'. fieldcat-ref_fieldname = 'ETDAT'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'ETA'.
  fieldcat-seltext_m = 'ETA'.
  fieldcat-seltext_l = 'ETA'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 27
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'DATEN'. fieldcat-ref_fieldname = 'DATEN'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'ShpActDate'.
  fieldcat-seltext_m = 'ShpActDate'.
  fieldcat-seltext_l = 'ShpActDate'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 28
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'UATENC'. fieldcat-ref_fieldname = 'UATENC'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'ShpActTime'.
  fieldcat-seltext_m = 'ShpActTime'.
  fieldcat-seltext_l = 'ShpActTime'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 29
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'KUNNR'. fieldcat-ref_fieldname = 'KUNNR'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'ShptoParty'.
  fieldcat-seltext_m = 'Ship-to party'.
  fieldcat-seltext_l = 'Ship-to party'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 29
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'SIGNI'. fieldcat-ref_fieldname = 'SIGNI'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Container ID'.
  fieldcat-seltext_m = 'Container ID'.
  fieldcat-seltext_l = 'Container ID'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 20.
  APPEND fieldcat. "clear fieldcat.

* col 29
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'TPBEZ'. fieldcat-ref_fieldname = 'TPBEZ'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Description of Shipment'.
  fieldcat-seltext_m = 'Description of Shipment'.
  fieldcat-seltext_l = 'Description of Shipment'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 20.
  APPEND fieldcat. "clear fieldcat.

* col 29
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'ROUTE'. fieldcat-ref_fieldname = 'ROUTE'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Shipment route'.
  fieldcat-seltext_m = 'Shipment route'.
  fieldcat-seltext_l = 'Shipment route'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'BEZEI'. fieldcat-ref_fieldname = 'BEZEI'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Route Description'.
  fieldcat-seltext_m = 'Route Description'.
  fieldcat-seltext_l = 'Route Description'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

* col 29
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'EXTI1'. fieldcat-ref_fieldname = 'EXTI1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'External identification 1'.
  fieldcat-seltext_m = 'External identification 1'.
  fieldcat-seltext_l = 'External identification 1'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 20.
  APPEND fieldcat. "clear fieldcat.

* col 29
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'EXTI2'. fieldcat-ref_fieldname = 'EXTI2'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'External identification 2'.
  fieldcat-seltext_m = 'External identification 2'.
  fieldcat-seltext_l = 'External identification 2'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 20.
  APPEND fieldcat. "clear fieldcat.

* col 30
  ADD 1 TO lv_col.
  fieldcat-fieldname = 'NAME1'. fieldcat-ref_fieldname = 'NAME1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Name Of Service Provider'.
  fieldcat-seltext_m = 'Name Of Service Provider'.
  fieldcat-seltext_l = 'Name Of Service Provider'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 40.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'CUSTO'. fieldcat-ref_fieldname = 'KUNNR'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Customer'.
  fieldcat-seltext_m = 'Customer'.
  fieldcat-seltext_l = 'Customer'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 10.
  APPEND fieldcat. "clear fieldcat.

  ADD 1 TO lv_col.
  fieldcat-fieldname = 'NAMEC'. fieldcat-ref_fieldname = 'NAME1'.
  fieldcat-tabname = 'ITAB'.
  fieldcat-seltext_s = 'Customer Name'.
  fieldcat-seltext_m = 'Customer Name'.
  fieldcat-seltext_l = 'Customer Name'.
  fieldcat-col_pos = lv_col.
  fieldcat-outputlen = 20.
  APPEND fieldcat. "clear fieldcat.

*  refresh evtab.
*  evtab_ln-name = 'TOP_OF_PAGE'.
*  evtab_ln-form = 'TOP_OF_PAGE'.
*  append evtab_ln to evtab.

ENDFORM.                    " append_structure_alv

*---------------------------------------------------------------------*
*       FORM TOP_OF_PAGE                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM top_of_page.

  DATA : v_budatlow(10),
         v_budathigh(10),
         v_time(8),
         separator(10) VALUE space.

  ihead_ln-typ = 'H'.
  ihead_ln-key = 'Title'.
  ihead_ln-info = 'Listing Intransit By Supply Plant'.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Period'.
  WRITE p_budat-low TO v_budatlow.
  WRITE p_budat-high TO v_budathigh.
  CONCATENATE v_budatlow 'TO' v_budathigh INTO ihead_ln-info
                          SEPARATED BY space.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Branch'.
  CONCATENATE p_werks '-' v_name1 INTO ihead_ln-info
                          SEPARATED BY space.
  APPEND ihead_ln TO ihead.

  ihead_ln-typ = 'S'.
  ihead_ln-key = 'Process Time'.
  WRITE sy-datum TO ihead_ln-info.
  WRITE sy-uzeit TO v_time.
  CONCATENATE ihead_ln-info '/' v_time '/' sy-uname INTO ihead_ln-info
                          SEPARATED BY space.
  APPEND ihead_ln TO ihead.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = ihead.
  REFRESH ihead.

ENDFORM.                    "TOP_OF_PAGE

*&---------------------------------------------------------------------*
*&      Form  EVENTTAB_BUILD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EVENTS[]  text
*----------------------------------------------------------------------*
FORM eventtab_build USING rt_events TYPE slis_t_event.

  DATA: ls_event TYPE slis_alv_event.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = rt_events.
  READ TABLE rt_events WITH KEY name = slis_ev_top_of_page
                           INTO ls_event.
  IF sy-subrc = 0.
    MOVE e_top_of_page TO ls_event-form.
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
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  IF p_budat-high IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = 'BUD'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH 'Posting Date harus diisi di dalam ranges'.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_WITH_SEPARATOR
*&---------------------------------------------------------------------*
FORM f_download_with_separator  USING    fu_separator.
  DATA : lv_menge(20),
         lv_dmbtr(20),
         lv_bbkno(5),
         lv_erdatc(10),
         lv_etdatc(10),
         lv_datec(10).

  PERFORM f_concatenate USING :  fu_separator 'Spl Pln' '1' '',
                                 fu_separator 'Spl Sloc' '' '',
                                 fu_separator 'Doc Number' '' '',
                                 fu_separator 'Mvt' '' '',
                                 fu_separator 'Supl Mater' '' '',
                                 fu_separator 'Supl Material Description' '' '',
                                 fu_separator 'Supl Qty' '' '',
                                 fu_separator 'Supl Value' '' '',
                                 fu_separator 'Post Date' '' '',
                                 fu_separator 'Doc Date' '' '',
                                 fu_separator 'Rcv Pln' '' '',
                                 fu_separator 'Rcv Sloc' '' '',
                                 fu_separator 'Receiving Cust' '' '',
                                 fu_separator 'Lead Time' '' '',
                                 fu_separator 'PO Number' '' '',
                                 fu_separator 'BBK Number' '' '',
                                 fu_separator 'Ship No' '' '',
                                 fu_separator 'Ship Date' '' '',
                                 fu_separator 'ETA' '' '',
                                 fu_separator 'ShpActDate' '' '',
                                 fu_separator 'ShpActTime' '' '',
                                 fu_separator 'ShptoParty' '2' ''.

  APPEND gs_download TO gt_download.
  CLEAR gs_download.

  LOOP AT itab.
    IF itab-tknum IS INITIAL.
      itab-erdat = itab-daten = sy-datum.
      itab-uatenc = '10:00:00'.
      itab-etdat = itab-erdat + itab-leadt.
    ENDIF.
    CLEAR lv_datec.
    IF itab-daten IS NOT INITIAL.
      WRITE itab-daten TO lv_datec.
    ENDIF.
    CLEAR lv_erdatc.
    IF itab-erdat IS NOT INITIAL.
      WRITE itab-erdat TO lv_erdatc.
    ENDIF.
    CLEAR lv_etdatc.
    IF itab-etdat IS NOT INITIAL.
      WRITE itab-etdat TO lv_etdatc.
    ENDIF.
    CLEAR lv_bbkno.
    IF itab-bbkno IS NOT INITIAL.
      WRITE itab-bbkno TO lv_bbkno.
    ENDIF.
    PERFORM f_concatenate USING :  fu_separator itab-werks '1' '',
                                   fu_separator itab-lgort '' '',
                                   fu_separator itab-mblnr '' '',
                                   fu_separator itab-bwart '' '',
                                   fu_separator itab-matnr '' '',
                                   fu_separator itab-maktx '' '',
                                   fu_separator itab-menge '' 'U',
                                   fu_separator itab-dmbtr '' 'C',
                                   fu_separator itab-budat '' 'D',
                                   fu_separator itab-bldat '' 'D',
                                   fu_separator itab-umwrk '' '',
                                   fu_separator itab-umlgo '' '',
                                   fu_separator itab-name3 '' '',
                                   fu_separator itab-leadt '' '',
                                   fu_separator itab-ebeln '' '',
*                                   fu_separator itab-bbkno '' '',
                                   fu_separator lv_bbkno '' '',
                                   fu_separator itab-tknum '' '',
*                                   fu_separator itab-erdat '' 'D',
*                                   fu_separator itab-etdat '' 'D',
*                                   fu_separator itab-daten '' 'D',
*                                   fu_separator itab-uaten '' 'D',
                                   fu_separator lv_erdatc '' '',
                                   fu_separator lv_etdatc '' '',
                                   fu_separator lv_datec '' '',
                                   fu_separator itab-uatenc '' '',
                                   fu_separator itab-kunnr '2' ''.

    APPEND gs_download TO gt_download.
    CLEAR gs_download.
  ENDLOOP.

* Get filename
  CONCATENATE p_path 'ETA-' sy-datum '.txt' INTO p_path.

* Download to server
  CALL METHOD zcl_util=>m_delete_file
    EXPORTING
      param_name = p_path.

  CALL METHOD zcl_util=>m_download_dataset
    EXPORTING
      param_name = p_path
      pti_data   = gt_download[].
ENDFORM.                    " F_DOWNLOAD_WITH_SEPARATOR

*&---------------------------------------------------------------------*
*&      Form  F_CONCATENATE
*&---------------------------------------------------------------------*
FORM f_concatenate  USING    fu_separator fu_value fu_flag fu_modif.
  DATA : lv_value(255).

  CASE fu_modif.
    WHEN 'C'.
      WRITE fu_value TO lv_value CURRENCY 'IDR'.
      REPLACE ALL OCCURRENCES OF '.' IN lv_value WITH space.
    WHEN 'D'.
      WRITE fu_value TO lv_value DD/MM/YYYY.
    WHEN 'U'.
      lv_value  = fu_value.
      REPLACE ALL OCCURRENCES OF '.000' IN lv_value WITH space.
    WHEN space.
      lv_value  = fu_value.
  ENDCASE.
  CONDENSE lv_value NO-GAPS.

  CASE fu_flag.
    WHEN '1'.
      CONCATENATE lv_value fu_separator INTO gs_download.
    WHEN '2'.
      CONCATENATE gs_download lv_value INTO gs_download.
    WHEN OTHERS.
      CONCATENATE gs_download lv_value fu_separator INTO gs_download.
  ENDCASE.
ENDFORM.                    " F_CONCATENATE

*&---------------------------------------------------------------------*
*&      Form  F_ADD_CUSTOMER
*&---------------------------------------------------------------------*
FORM f_add_customer .
  IF i_mkpf[] IS NOT INITIAL.
    SELECT ebeln ebelp ekpo~kunnr name1
      FROM ekpo JOIN kna1 ON ekpo~kunnr = kna1~kunnr
      INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
      FOR ALL ENTRIES IN i_mkpf
      WHERE ebeln = i_mkpf-ebeln
        AND ebelp = i_mkpf-ebelp.
  ENDIF.
ENDFORM.                    " F_ADD_CUSTOMER

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data .
  TYPES : BEGIN OF ty_likp,
            vbeln TYPE likp-vbeln,
            lprio TYPE likp-lprio,
          END OF ty_likp.

  DATA : xitab    LIKE itab OCCURS 0,
         lt_likp  TYPE STANDARD TABLE OF ty_likp,
         ls_likp  LIKE LINE OF lt_likp,
         lt_tprit TYPE STANDARD TABLE OF tprit,
         ls_tprit LIKE LINE OF lt_tprit,
         lt_ekpv  TYPE STANDARD TABLE OF ekpv,
         ls_ekpv  LIKE LINE OF lt_ekpv.

  SELECT *
    FROM tprit
    INTO CORRESPONDING FIELDS OF TABLE lt_tprit
    WHERE spras = sy-langu.

  xitab[] = itab[].
  SORT xitab BY mblnr.
  DELETE ADJACENT DUPLICATES FROM xitab COMPARING mblnr.
  IF xitab[] IS NOT INITIAL.
    SELECT vbeln lprio
      FROM likp
      INTO TABLE lt_likp
      FOR ALL ENTRIES IN xitab
      WHERE vbeln EQ xitab-mblnr.
  ENDIF.

  xitab[] = itab[].
  SORT xitab BY ebeln.
  DELETE ADJACENT DUPLICATES FROM xitab COMPARING ebeln.
  IF xitab[] IS NOT INITIAL.
    SELECT *
      FROM ekpv
      INTO CORRESPONDING FIELDS OF TABLE lt_ekpv
      FOR ALL ENTRIES IN xitab
      WHERE ebeln = xitab-ebeln.
  ENDIF.

  LOOP AT itab.
    CLEAR ls_likp.
    READ TABLE lt_likp INTO ls_likp
                       WITH KEY vbeln = itab-mblnr.
    IF sy-subrc = 0.
      CLEAR ls_tprit.
      READ TABLE lt_tprit INTO ls_tprit
                          WITH KEY lprio = ls_likp-lprio.
      IF sy-subrc = 0.
        itab-lprio    = ls_tprit-lprio.
        itab-beze1    = ls_tprit-bezei.
      ENDIF.
    ENDIF.

    CLEAR ls_ekpv.
    READ TABLE lt_ekpv INTO ls_ekpv
                       WITH KEY ebeln = itab-ebeln.
    IF sy-subrc = 0.
      CLEAR ls_tprit.
      READ TABLE lt_tprit INTO ls_tprit
                          WITH KEY lprio = ls_ekpv-lprio.
      IF sy-subrc = 0.
        itab-lprio1    = ls_tprit-lprio.
        itab-beze2     = ls_tprit-bezei.
      ENDIF.
    ENDIF.

    MODIFY itab TRANSPORTING lprio beze1 lprio1 beze2.
    CLEAR itab.
  ENDLOOP.
ENDFORM.                    " F_MODIFY_DATA
