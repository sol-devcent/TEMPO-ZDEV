REPORT zm_estimasi_stock MESSAGE-ID zm
                         LINE-SIZE 255 LINE-COUNT 65
                         NO STANDARD PAGE HEADING.

INCLUDE zghmmalv001.
INCLUDE zghmmtop003.

DATA : t_ebeln TYPE ekko-ebeln OCCURS 0,
       d_ebeln TYPE ekko-ebeln.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE text-001.
PARAMETERS     : p_spmon LIKE s931-spmon DEFAULT sy-datum(6) OBLIGATORY.
SELECT-OPTIONS : s_werks FOR mard-werks OBLIGATORY,
                 s_matkl FOR mara-matkl,
                 s_matnr FOR mard-matnr.

SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE text-003.
SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS : radio90 RADIOBUTTON GROUP grp9 USER-COMMAND rad
             DEFAULT 'X'.
SELECTION-SCREEN: COMMENT 4(26) text-f01 FOR FIELD radio90.
PARAMETERS : p_vari LIKE disvariant-variant MODIF ID 001.
" ALV Variant
SELECTION-SCREEN: END OF LINE,

                  BEGIN OF LINE.
PARAMETERS : radio91 RADIOBUTTON GROUP grp9.
SELECTION-SCREEN: COMMENT 4(26) text-f02 FOR FIELD radio91.
PARAMETERS : p_filenm LIKE rlgrap-filename MODIF ID 002.
SELECTION-SCREEN: END OF LINE,

                  BEGIN OF LINE.
PARAMETERS : radio92 RADIOBUTTON GROUP grp9.
SELECTION-SCREEN: COMMENT 4(26) text-f03 FOR FIELD radio92.
PARAMETERS : p_path TYPE char128 LOWER CASE MODIF ID 003.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN END OF BLOCK block4.

PARAMETERS: p_grid  AS CHECKBOX DEFAULT 'X' MODIF ID 001.
PARAMETERS: p_incsut  AS CHECKBOX.

INCLUDE zghmmalvf03.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_filenm = 'C:\'.
  PERFORM f_init_path.

*------------------------------------------------------
* AT SELECTION-SCREEN OUTPUT
*------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  IF radio90 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = '002' OR screen-group1 = '003'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF radio91 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = '001' OR screen-group1 = '003'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ELSEIF radio92 = 'X'.
    LOOP AT SCREEN.
      IF screen-group1 = '001' OR screen-group1 = '002'.
        screen-active = '0'.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*------------------------------------------------------
* AT SELECTION SCREEN
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON s_werks.
  SELECT werks name1 INTO TABLE i_werks
    FROM t001w WHERE werks IN s_werks AND
                     spras EQ sy-langu.
  LOOP AT i_werks.
    AUTHORITY-CHECK OBJECT 'M_MSEG_WWE'
                    ID 'WERKS' FIELD i_werks-werks.
    IF sy-subrc NE 0.
      MESSAGE e000(zm) WITH 'You are not authorized with Plant'
                            i_werks-werks.
    ENDIF.
  ENDLOOP.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f_f4_for_variant_alv USING p_vari.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_filenm.
  PERFORM f_f4_for_file_name USING p_filenm.
*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data_sac7_united.
  PERFORM f_get_data.
  CASE 'X'.
    WHEN radio90.
      PERFORM f_print_data.
    WHEN radio91.
      PERFORM f_download_local.
    WHEN radio92.
*      PERFORM f_download_server.
      PERFORM f_download_with_separator USING '|'.
  ENDCASE.
*  PERFORM f_list_update_data.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

TOP-OF-PAGE.
  PERFORM f_write_header.

*&---------------------------------------------------------------------*
*&      Form  f_f4_for_variant_alv
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_VARI  text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv USING fc_variant.

  DATA: ld_variant LIKE disvariant.
  DATA: ld_repid   LIKE sy-repid.
  ld_repid = sy-repid.
  ld_variant-report   = ld_repid.
  ld_variant-username = sy-uname.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = ld_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ld_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    fc_variant = ld_variant-variant.
  ENDIF.

ENDFORM.                    " f_f4_for_variant_alv

*&---------------------------------------------------------------------*
*&      Form  f_init_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_init_data.

ENDFORM.                    " f_init_data

*&---------------------------------------------------------------------*
*&      Form  f_get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data.
  DATA : l_year   LIKE  mard-lfgja,
         l_month  LIKE  mard-lfmon,
         l_date1  LIKE  mb_mdbs-bedat,
         l_date2  LIKE  mb_mdbs-bedat,
         l_year2  LIKE  mard-lfgja,
         l_month2 LIKE  mard-lfmon,
         l_spmon  LIKE  s039-spmon,
         l_filename(125),
         l_tabix  LIKE  sy-tabix,
         l_opnsto LIKE  i_main-opnsto,
         lw_main  LIKE  i_main,
         cw       TYPE  c,
         l_period(6).
  RANGES: ns_werks FOR mard-werks,
          lr_lgort  FOR mard-lgort.

** Sloc Include SUT, KIM, TNS   Change on 31/08/2012
  lr_lgort-low     = '1100'.
  lr_lgort-sign    = 'I'.
  lr_lgort-option  = 'EQ'.
  APPEND lr_lgort.
  lr_lgort-low     = '1101'.
  lr_lgort-sign    = 'I'.
  lr_lgort-option  = 'EQ'.
  APPEND lr_lgort.
  lr_lgort-low     = '1102'.
  lr_lgort-sign    = 'I'.
  lr_lgort-option  = 'EQ'.
  APPEND lr_lgort.

** Hitung Tanggal
  l_year = p_spmon(4).
  l_month = p_spmon+4(2).
  CONCATENATE p_spmon '01' INTO l_date1.
  CONCATENATE p_spmon '31' INTO l_date2.
  l_month2 = l_month - 1.
  IF l_month2 LE 0.
    l_year2 = l_year - 1.
    l_month2 = l_month2 + 12.
  ELSE.
    l_year2 = l_year.
  ENDIF.
  CONCATENATE l_year2 l_month2 INTO l_spmon.

** Select MAKT
  SELECT a~matkl a~matnr a~meins b~maktx
    INTO CORRESPONDING FIELDS OF TABLE i_makt
    FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
    WHERE a~matkl IN s_matkl  AND
          a~matnr IN s_matnr  AND
          b~spras = sy-langu.

  IF i_makt[] IS INITIAL.
    MESSAGE i000(zm) WITH 'No Material Selected'.
    STOP.
  ENDIF.

** Select MARC
  SELECT matnr werks kausf
    INTO CORRESPONDING FIELDS OF TABLE i_marc
    FROM marc
    WHERE matnr IN s_matnr  AND
          werks IN s_werks.

** Select MARD
  SELECT matnr werks lgort labst insme speme
    INTO CORRESPONDING FIELDS OF TABLE i_mard
    FROM mard
    WHERE matnr IN s_matnr  AND
          werks IN s_werks  AND
        ( lgort NE '10D0' AND lgort NE '10U0' ).

** Select MB_MDBS
  SELECT * FROM t001w WHERE werks IN s_werks.
    CHECK t001w-werks = '0200'.
    cw = 'X'.
    EXIT.
  ENDSELECT.

  IF cw = 'X'.
    SELECT a~matnr a~werks a~lgort a~bstyp a~ebeln
           a~ebelp a~menge a~wemng a~wamng a~glmng
           b~bedat b~bsart
      INTO CORRESPONDING FIELDS OF TABLE i_mdbs
      FROM mb_mdbs AS a JOIN ekko AS b ON a~ebeln = b~ebeln
      WHERE a~matnr IN s_matnr  AND
*          a~werks IN s_werks  AND
            a~bstyp = 'F'       AND
            a~loekz = ' '       AND
*          a~elikz = ' '       AND
           ( b~bedat GE l_date1  AND b~bedat LE l_date2 ) AND
           ( b~bsart = 'OB' OR b~bsart = 'NB' OR
             b~bsart = 'UB' OR b~bsart = 'ZB' OR
             b~bsart = 'ZSUT' OR b~bsart = 'ZICO' ).
  ELSE.
    SELECT a~matnr a~werks a~lgort a~bstyp a~ebeln
           a~ebelp a~menge a~wemng a~wamng a~glmng
           b~bedat b~bsart
      INTO CORRESPONDING FIELDS OF TABLE i_mdbs
      FROM mb_mdbs AS a JOIN ekko AS b ON a~ebeln = b~ebeln
      WHERE a~matnr IN s_matnr  AND
            a~werks IN s_werks  AND
            a~bstyp = 'F'       AND
            a~loekz = ' '       AND
*          a~elikz = ' '       AND
           ( b~bedat GE l_date1  AND b~bedat LE l_date2 ) AND
           ( b~bsart = 'OB' OR b~bsart = 'NB' OR
             b~bsart = 'UB' OR b~bsart = 'ZB' OR
             b~bsart = 'ZSUT' OR b~bsart = 'ZICO' ).
  ENDIF.

** Select S039
  SELECT matnr werks lgort gsbest mbwbest
    INTO CORRESPONDING FIELDS OF TABLE i_s039
    FROM s039
    WHERE ssour = ''         AND
          vrsio = '000'      AND
          spmon = l_spmon    AND
          sptag = '00000000' AND
          spwoc = '000000'   AND
          spbup = '000000'   AND
          werks IN s_werks   AND
          matnr IN s_matnr.  "AND
*         ( lgort NE '10D0' AND lgort NE '10U0' ).

** Select S611
  SELECT matnr werks ummenge gumenge
    INTO CORRESPONDING FIELDS OF TABLE i_s611
    FROM s611
    WHERE ssour = ''        AND
          vrsio = '000'     AND
          spmon = p_spmon   AND
          sptag = '00000000' AND
          spwoc = '000000'   AND
          spbup = '000000'   AND
          matnr IN s_matnr  AND
          werks IN s_werks.

  IF p_incsut = ''.
** Select S603 for exclude SUT
    SELECT matnr vkbur ummenge gumenge
      INTO CORRESPONDING FIELDS OF TABLE i_s603
      FROM s603
      WHERE ssour = ''        AND
            vrsio = '000'     AND
            spmon = p_spmon   AND
            sptag = '00000000' AND
            spwoc = '000000'   AND
            spbup = '000000'   AND
* Change on 31/08/2012
*          ( pkunwe = 'TSB8070' OR
*            pkunwe = 'TSB8071' ) AND
            pkunwe IN ('TSB8070','TSB8071','TSB8351','TSB8341') AND
* End change 31/08/2012
            matnr IN s_matnr  AND
            vkbur IN s_werks.
  ENDIF.


** Select S912
  SELECT spmon matnr werks zqnetsls zrunrate zavg_sls
    INTO CORRESPONDING FIELDS OF TABLE i_s912
    FROM s912
    WHERE ssour = ''        AND
          vrsio = '000'     AND
          spmon = p_spmon   AND
          sptag = '00000000' AND
          spwoc = '000000'   AND
          spbup = '000000'   AND
          matnr IN s_matnr  AND
          werks IN s_werks.

* added by idub, 20060130
* according to leo request, add 2 additional fields
*--------------------------------------------------
  SELECT matnr werks ktmng
    INTO CORRESPONDING FIELDS OF TABLE i_s912cm
    FROM s912
    WHERE ssour = ''        AND
          vrsio = '000'     AND
          spmon = p_spmon   AND
          sptag = '00000000' AND
          spwoc = '000000'   AND
          spbup = '000000'   AND
          matnr IN s_matnr  AND
          werks IN s_werks.

  LOOP AT i_s912cm.
    MOVE-CORRESPONDING i_s912cm TO i_s912cmsum.
    COLLECT i_s912cmsum.
  ENDLOOP.

  l_period = p_spmon.
  ADD 1 TO l_period.

  SELECT matnr werks ktmng
    INTO CORRESPONDING FIELDS OF TABLE i_s912nm
    FROM s912
    WHERE ssour = ''        AND
          vrsio = '000'     AND
          spmon = l_period   AND
          sptag = '00000000' AND
          spwoc = '000000'   AND
          spbup = '000000'   AND
          matnr IN s_matnr  AND
          werks IN s_werks.

  LOOP AT i_s912nm.
    MOVE-CORRESPONDING i_s912nm TO i_s912nmsum.
    COLLECT i_s912nmsum.
  ENDLOOP.
*--------------------------------------------------



*** ----------------------
*** Collect Itab Main
*** ----------------------

** Collect From MARD
  LOOP AT i_mard.
    READ TABLE i_makt WITH KEY matnr = i_mard-matnr.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.

* additional to exclude SUT Stock
    IF p_incsut = '' AND
*       i_mard-werks = '0201' AND i_mard-lgort = '1100'.
       i_mard-werks = '0201' AND i_mard-lgort IN lr_lgort.
      CONTINUE.
    ENDIF.
    i_main-matkl = i_makt-matkl.
    i_main-maktx = i_makt-maktx.
    i_main-meins = i_makt-meins.
    i_main-matnr = i_mard-matnr.
    i_main-werks = i_mard-werks.
    i_main-stkcr = i_mard-labst + i_mard-insme.
    i_main-blstkcr = i_mard-speme.
    READ TABLE i_werks WITH KEY werks = i_main-werks.
    i_main-name1 = i_werks-name1.
    COLLECT i_main. CLEAR i_main.
  ENDLOOP.

** Collect From MD_MDBS

  IF p_incsut = ''.
*    DELETE i_mdbs WHERE werks = '0201' AND lgort = '1100'.
    DELETE i_mdbs WHERE werks = '0201' AND lgort IN lr_lgort.
  ENDIF.

  LOOP AT i_mdbs.
    READ TABLE i_makt WITH KEY matnr = i_mdbs-matnr.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    i_main-matkl = i_makt-matkl.
    i_main-maktx = i_makt-maktx.
    i_main-meins = i_makt-meins.
    i_main-matnr = i_mdbs-matnr.
    i_main-werks = i_mdbs-werks.
    i_main-grsto = i_mdbs-wemng.
    i_main-totpo = i_mdbs-menge.
    READ TABLE i_werks WITH KEY werks = i_main-werks.
    i_main-name1 = i_werks-name1.
    CASE i_mdbs-bsart.
      WHEN 'UB'.
        IF i_main-werks = '0200'.
        ELSE.
          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnsto = i_mdbs-glmng - i_mdbs-wamng.
          i_main-opnsto1 = i_mdbs-menge.
          i_main-opnpo = i_mdbs-menge - i_mdbs-glmng.
        ENDIF.
      WHEN 'NB' OR 'OB'.
        IF i_main-werks = '0200'.
          i_main-opnsto = i_mdbs-menge.
          i_main-opnpo = i_mdbs-menge - i_mdbs-wemng.
        ELSE.
          i_main-opnpo = i_mdbs-menge - i_mdbs-wemng.
        ENDIF.
      WHEN 'ZB' OR 'ZICO'.
        IF i_main-werks = '0200'.
          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnsto = i_mdbs-menge.
          i_main-opnpo = i_mdbs-menge - i_mdbs-wemng.
        ELSE.
          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnpo = i_mdbs-menge - i_mdbs-glmng.
        ENDIF.
      WHEN 'ZSUT'.
        IF i_main-werks = '0200'.
          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnsto = i_mdbs-menge.
          i_main-opnpo = i_mdbs-menge - i_mdbs-wemng.
        ELSE.
          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnpo = i_mdbs-menge - i_mdbs-glmng.
        ENDIF.
    ENDCASE.
    COLLECT i_main. CLEAR i_main.
    d_ebeln = i_mdbs-ebeln.
    COLLECT d_ebeln INTO t_ebeln.
  ENDLOOP.

** Collect From S039
  LOOP AT i_s039.
    READ TABLE i_makt WITH KEY matnr = i_s039-matnr.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    IF p_incsut = '' AND
*       i_s039-werks = '0201' AND i_s039-lgort = '1100'.
       i_s039-werks = '0201' AND i_s039-lgort IN lr_lgort.
      CONTINUE.
    ENDIF.
    i_main-matkl = i_makt-matkl.
    i_main-maktx = i_makt-maktx.
    i_main-meins = i_makt-meins.
    i_main-matnr = i_s039-matnr.
    i_main-werks = i_s039-werks.
    READ TABLE i_werks WITH KEY werks = i_main-werks.
    i_main-name1 = i_werks-name1.
*    i_main-stkls = i_s039-gsbest.
    i_main-stkls = i_s039-mbwbest.
    COLLECT i_main. CLEAR i_main.
  ENDLOOP.

** Collect From S611
  LOOP AT i_s611.
    READ TABLE i_makt WITH KEY matnr = i_s611-matnr.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    i_main-matkl = i_makt-matkl.
    i_main-maktx = i_makt-maktx.
    i_main-meins = i_makt-meins.
    i_main-matnr = i_s611-matnr.
    i_main-werks = i_s611-werks.
    READ TABLE i_werks WITH KEY werks = i_main-werks.
    i_main-name1 = i_werks-name1.
    i_main-sales = i_s611-ummenge + i_s611-gumenge.
    COLLECT i_main. CLEAR i_main.
  ENDLOOP.

* Collect From S603 - exclude SUT
  LOOP AT i_s603 INTO i_s603.
    READ TABLE i_makt WITH KEY matnr = i_s603-matnr.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    i_main-matkl = i_makt-matkl.
    i_main-maktx = i_makt-maktx.
    i_main-meins = i_makt-meins.
    i_main-matnr = i_s603-matnr.
    i_main-werks = i_s603-vkbur.
    READ TABLE i_werks WITH KEY werks = i_main-werks.
    i_main-name1 = i_werks-name1.
    i_main-sales = ( i_s603-ummenge + i_s603-gumenge ) * -1.
    COLLECT i_main. CLEAR i_main.
  ENDLOOP.

** Collect From S931
*  LOOP AT i_s931.
*    READ TABLE i_makt WITH KEY matnr = i_s931-matnr.
*    i_main-maktx = i_makt-maktx.
*    i_main-meins = i_makt-meins.
*    i_main-matnr = i_s931-matnr.
*    i_main-werks = i_s931-werks.
*    i_main-grsto = i_s931-menge.
*    READ TABLE i_werks WITH KEY werks = i_main-werks.
*    i_main-name1 = i_werks-name1.
*    IF i_s931-bwart = '102'.
*      MULTIPLY i_main-grsto BY -1.
*    ENDIF.
*    COLLECT i_main. CLEAR i_main.
*  ENDLOOP.

** Completed i_main
  SORT i_main BY matnr werks.
  SORT i_outpl BY matnr werks.
  LOOP AT i_main.

    IF i_main-werks = '0200'.
      l_tabix = sy-tabix.
      lw_main = i_main.
    ELSE.
      ADD i_main-opnsto1 TO l_opnsto.
    ENDIF.

    READ TABLE i_marc WITH KEY matnr = i_main-matnr
                               werks = i_main-werks.
    IF sy-subrc = 0.
      i_main-stdrt = i_marc-kausf.
    ENDIF.
    READ TABLE i_s912 WITH KEY matnr = i_main-matnr
                               werks = i_main-werks.
    IF sy-subrc = 0.
      i_main-avrsl = i_s912-zavg_sls.
    ENDIF.

    "Average Qty United
    CLEAR i_outpl.
    READ TABLE i_outpl WITH KEY matnr = i_main-matnr
                                werks = i_main-werks BINARY SEARCH.
    i_main-avrslutd = i_outpl-avqty.

* added by idub, 20060130
* according to leo request, add 2 additional fields
*--------------------------------------------------
    READ TABLE i_s912cmsum WITH KEY matnr = i_main-matnr
                                    werks = i_main-werks.
    IF sy-subrc = 0.
      i_main-tacm = i_s912cmsum-ktmng.
    ENDIF.

    READ TABLE i_s912nmsum WITH KEY matnr = i_main-matnr
                                    werks = i_main-werks.
    IF sy-subrc = 0.
      i_main-tanm = i_s912nmsum-ktmng.
    ENDIF.
*--------------------------------------------------


    IF i_s912-zavg_sls NE 0.
      i_main-actrt =  i_main-stkls / i_s912-zavg_sls.
      i_main-actrt1 =  i_main-stkcr / i_s912-zavg_sls.
    ENDIF.
*    MODIFY i_main TRANSPORTING stdrt avrsl actrt actrt1.


* added by idub, 20060130
* according to leo request, add 2 additional fields
*--------------------------------------------------
    MODIFY i_main TRANSPORTING stdrt avrsl avrslutd actrt actrt1 tacm tanm.
*--------------------------------------------------


    AT END OF matnr.
      IF NOT l_tabix IS INITIAL.
        SUBTRACT l_opnsto FROM lw_main-opnsto.
        MODIFY i_main FROM lw_main INDEX l_tabix.
      ENDIF.
      CLEAR: i_main,lw_main,l_tabix,l_opnsto.
    ENDAT.

    CLEAR: i_main.
  ENDLOOP.

  LOOP AT s_werks INTO ns_werks.
    IF ns_werks-sign = 'I'.
      ns_werks-sign = 'E'.
    ELSE.
      ns_werks-sign = 'I'.
    ENDIF.
    APPEND ns_werks.
  ENDLOOP.
  DELETE i_main WHERE werks IN ns_werks.

ENDFORM.                    " f_get_data

*&---------------------------------------------------------------------*
*&      Form  f_print_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_data.
  DATA : p_func(22) TYPE c,
         title      TYPE lvc_title.
  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  i_main.
*  PERFORM f_build_fieldcat1.
  PERFORM f_build_layout      USING   d_layout.
  PERFORM f_build_sortfield   USING   t_alv_isort[].

  PERFORM f_build_event_exit.
  PERFORM f_build_print       USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  IF p_grid = 'X'.
    p_func = 'REUSE_ALV_GRID_DISPLAY'.
    title  = 'Stock Monitoring Report'.
  ELSE.
    PERFORM f_build_event       TABLES  t_alv_event[].
    p_func = 'REUSE_ALV_LIST_DISPLAY'.
  ENDIF.

  CALL FUNCTION p_func
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
*    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
    i_grid_title                   = title
    is_layout                      = d_layout
    it_fieldcat                    = t_alv_fieldcat[]
*   IT_EXCLUDING                   =
*   IT_SPECIAL_GROUPS              =
    it_sort                        = t_alv_isort[]
*   IT_FILTER                      =
*   IS_SEL_HIDE                    =
    i_default                      = 'X'
    i_save                         = 'A'
    is_variant                     = d_alv_variant
    it_events                      = t_alv_event[]
    it_event_exit                  = t_event_exit[]
    is_print                       = d_print
*   IS_REPREP_ID                   =
*   I_SCREEN_START_COLUMN          = 0
*   I_SCREEN_START_LINE            = 0
*   I_SCREEN_END_COLUMN            = 0
*   I_SCREEN_END_LINE              = 0
* IMPORTING
*   E_EXIT_CAUSED_BY_CALLER        =
*   ES_EXIT_CAUSED_BY_USER         =
    TABLES
      t_outtab                       = i_main
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " f_print_data

*&---------------------------------------------------------------------*
*&      Form  f_save_to_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_save_to_table.

ENDFORM.                    " f_save_to_table

*&---------------------------------------------------------------------*
*&      Form  f_write_header
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_write_header.

  WRITE: /(125) 'Listing Update ZSCUSTOPP' CENTERED.
  WRITE: /      'Date/Time :', sy-datum, '/', sy-uzeit,
          112   'Page :', sy-pagno.

  WRITE: / sy-uline(125).
  WRITE: /     '|',
          (6)  'Sl.Org' CENTERED, '|',
          (6)  'Dis.ch' CENTERED, '|',
          (6)  'Sl.Off' CENTERED, '|',
          (12) 'Customer' CENTERED, '|',
          (35) 'Customer Name', '|',
          (5)  'Curr' CENTERED, '|',
          (5)  'Class' CENTERED, '|',
          (17) 'Value Target' CENTERED, '|',
          (5)  'Freq' CENTERED, '|'.
  WRITE: / sy-uline(125).

ENDFORM.                    " f_write_header

*&---------------------------------------------------------------------*
*&      Form  f_list_update_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_list_update_data.
  SET PF-STATUS 'STATUS_100'.
ENDFORM.                    " f_list_update_data

*&---------------------------------------------------------------------*
*&      Form  f_refresh_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_refresh_data.

ENDFORM.                    " f_refresh_data

*&---------------------------------------------------------------------*
*&      Form  f_f4_for_file_name
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_FILE  text
*----------------------------------------------------------------------*
FORM f_f4_for_file_name USING fc_file.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = ' '
      def_path         = 'C:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = text-011
    IMPORTING
      filename         = fc_file
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

ENDFORM.                    " f_f4_for_file_name

*&---------------------------------------------------------------------*
*&      Form  f_download_local
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_download_local.
  TYPES   :  BEGIN OF t_dwn_field,
               txt_field(10),
             END OF t_dwn_field.
  DATA:   canc(1),
          size         TYPE i,
          dwn_field    TYPE t_dwn_field OCCURS 0,
          wa_dwn_field TYPE t_dwn_field,
          filename     TYPE rlgrap-filename,
          wa_main      LIKE i_main,
          sw.

  DATA count TYPE i.

*Begin insert Unicode conversion - DEVK965554
*26.02.2020 - SOL_FELIX
  data: lv_p_filenm TYPE string,
        lv_filename TYPE string.
  clear: lv_p_filenm, lv_filename.
  lv_p_filenm = p_filenm.
*End insert Unicode conversion - DEVK965554

  CLEAR count.
  DO 24 TIMES.
    CLEAR wa_dwn_field.
    ADD 1 TO count.
    CASE count.
      WHEN '1'.
        wa_dwn_field-txt_field = 'Mat. Number'.
      WHEN '2'.
        wa_dwn_field-txt_field = 'Mat. Desc'.
      WHEN '3'.
        wa_dwn_field-txt_field = 'Mat. Group'.
      WHEN '4'.
        wa_dwn_field-txt_field = 'UoM'.
      WHEN '5'.
        wa_dwn_field-txt_field = 'Plant'.
      WHEN '6'.
        wa_dwn_field-txt_field = 'Plant Name'.
      WHEN '7'.
        wa_dwn_field-txt_field = 'Curr. Stock'.
      WHEN '8'.
        wa_dwn_field-txt_field = 'CurBlkStock'.
      WHEN '9'.
        wa_dwn_field-txt_field = 'Intransit'.
      WHEN '10'.
        wa_dwn_field-txt_field = 'Open PO'.
      WHEN '11'.
        wa_dwn_field-txt_field = 'Open STO/DN'.
      WHEN '12'.
        wa_dwn_field-txt_field = 'Tot. PO/STO'.
      WHEN '13'.
        wa_dwn_field-txt_field = ''.
      WHEN '14'.
        wa_dwn_field-txt_field = 'Opng Stock'.
      WHEN '15'.
        wa_dwn_field-txt_field = 'GR PO/STO'.
      WHEN '16'.
        wa_dwn_field-txt_field = 'Av. Sales'.
      WHEN '17'.
        wa_dwn_field-txt_field = 'AvrgSls.Utd'.
      WHEN '18'.
        wa_dwn_field-txt_field = 'Stdt. T'.
      WHEN '19'.
        wa_dwn_field-txt_field = 'Opng. T'.
      WHEN '20'.
        wa_dwn_field-txt_field = 'Curr. T'.
      WHEN '21'.
        wa_dwn_field-txt_field = 'Sales MTD'.
      WHEN '22'.
        wa_dwn_field-txt_field = ''.
      WHEN '23'.
        wa_dwn_field-txt_field = 'TotAlloCurr Month'.
      WHEN '24'.
        wa_dwn_field-txt_field = 'TotAlloNext Month'.
    ENDCASE.
    APPEND wa_dwn_field TO dwn_field.
  ENDDO.

  SORT i_main BY werks matnr.
  sw = ''.
  LOOP AT i_main INTO i_main.
    ON CHANGE OF i_main-werks.

*Begin remark Unicode conversion - DEVK965554
*26.02.2020 - SOL_FELIX
*      IF sw = 'X'.
**    CALL FUNCTION 'DOWNLOAD'
*        CALL FUNCTION 'WS_DOWNLOAD'
*          EXPORTING
*            filename         = filename
*            filetype         = 'DBF'
*          IMPORTING
*            cancel           = canc
*            filesize         = size
*          TABLES
*            data_tab         = i_original
*            fieldnames       = dwn_field
*          EXCEPTIONS
*            file_open_error  = 1
*            file_write_error = 2.
*        REFRESH i_original.
*      ELSE.
*        sw = 'X'.
*      ENDIF.
*    ENDON.
*    i_original = i_main.
*    APPEND i_original.
*    CONCATENATE p_filenm 'Alokasi ' i_main-werks
*             '.xls' INTO filename.
*End remark Unicode conversion - DEVK965554
*Begin insert Unicode conversion - DEVK965554
*26.02.2020 - SOL_FELIX
      IF sw = 'X'.
*    CALL FUNCTION 'DOWNLOAD'
        CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
          EXPORTING
            FILENAME                = lv_filename
            FILETYPE                = 'DBF'
            FIELDNAMES              = dwn_field
          CHANGING
            DATA_TAB                = i_original[].
        REFRESH i_original.
      ELSE.
        sw = 'X'.
      ENDIF.
    ENDON.
    i_original = i_main.
    APPEND i_original.
    CONCATENATE lv_p_filenm 'Alokasi ' i_main-werks
             '.xls' INTO lv_filename.
*End insert Unicode conversion - DEVK965554
  ENDLOOP.

*Begin remark Unicode conversion - DEVK965554
*26.02.2020 - SOL_FELIX
*  CALL FUNCTION 'WS_DOWNLOAD'
*    EXPORTING
*      filename         = filename
*      filetype         = 'DBF'
*    IMPORTING
*      cancel           = canc
*      filesize         = size
*    TABLES
*      data_tab         = i_original
*      fieldnames       = dwn_field
*    EXCEPTIONS
*      file_open_error  = 1
*      file_write_error = 2.
*End remark Unicode conversion - DEVK965554
*Begin insert Unicode conversion - DEVK965554
*26.02.2020 - SOL_FELIX
  CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
    EXPORTING
      FILENAME                = lv_filename
      FILETYPE                = 'DBF'
      FIELDNAMES              = dwn_field
    CHANGING
      DATA_TAB                = i_original[]
    EXCEPTIONS
      FILE_WRITE_ERROR        = 1
      NO_BATCH                = 2
      GUI_REFUSE_FILETRANSFER = 3
      INVALID_TYPE            = 4
      NO_AUTHORITY            = 5
      UNKNOWN_ERROR           = 6
      HEADER_NOT_ALLOWED      = 7
      SEPARATOR_NOT_ALLOWED   = 8
      FILESIZE_NOT_ALLOWED    = 9
      HEADER_TOO_LONG         = 10
      DP_ERROR_CREATE         = 11
      DP_ERROR_SEND           = 12
      DP_ERROR_WRITE          = 13
      UNKNOWN_DP_ERROR        = 14
      ACCESS_DENIED           = 15
      DP_OUT_OF_MEMORY        = 16
      DISK_FULL               = 17
      DP_TIMEOUT              = 18
      FILE_NOT_FOUND          = 19
      DATAPROVIDER_EXCEPTION  = 20
      CONTROL_FLUSH_ERROR     = 21
      NOT_SUPPORTED_BY_GUI    = 22
      ERROR_NO_GUI            = 23
      others                  = 24.
  IF SY-SUBRC <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*End insert Unicode conversion - DEVK965554
ENDFORM.                    " f_download_local

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_ITABDWN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_write_itabdwn.

ENDFORM.                    " F_WRITE_ITABDWN

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_SAC7_UNITED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_sac7_united .
  DATA: lv_path(52),
        lv_path2(52),
        lv_flnam(125),
        lv_flnam2(125),
        lv_date  TYPE datum,
        lv_spmon TYPE spmon.

  DATA: lt_outpl LIKE i_outpl OCCURS 0 WITH HEADER LINE,
        lv_year  TYPE i,
        lv_percen   LIKE i_outpl-stratio.

  "Get Plant SUT
  SELECT * INTO TABLE i_zplbc
    FROM zplbc WHERE reswk NE space.

  "Get server path
  IF sy-opsys = 'AIX'.
    lv_path = '/interface/SAC7/Monthly/'.
    lv_path2 = '/interface/SAC7/sut/monthly/'.
  ELSE.
    lv_path = '\\tdsdev01\interface\SAC7\MONTHLY\'.
    lv_path2 = '\\tdsdev01\interface\SAC7\sut\monthly\'.
  ENDIF.

  " Get last month
  CONCATENATE p_spmon '01' INTO lv_date.
  SUBTRACT 1 FROM lv_date.
  lv_spmon = lv_date(6).

  "Get textfile PTT
  CLEAR: itabline,itabline[].
  CONCATENATE lv_path lv_spmon '_N.txt' INTO lv_flnam.
  OPEN DATASET lv_flnam FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc EQ 0.
    DO.
      READ DATASET lv_flnam INTO wa_itabline.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      APPEND wa_itabline TO itabline.
    ENDDO.
  ENDIF.
  CLOSE DATASET lv_flnam.

  "Get textfile SUT
  CLEAR: itabline_sut,itabline_sut[].
  CONCATENATE lv_path2 lv_spmon '_N.txt' INTO lv_flnam2.
  OPEN DATASET lv_flnam2 FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc EQ 0.
    DO.
      READ DATASET lv_flnam2 INTO wa_itabline_sut.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      APPEND wa_itabline_sut TO itabline_sut.
    ENDDO.
  ENDIF.
  CLOSE DATASET lv_flnam2.

  "Process PTT
  LOOP AT itabline INTO wa_itabline.
    i_dataset = wa_itabline.
    PERFORM f_cek_aix.

    MOVE-CORRESPONDING i_dataset TO i_outpl.

    IF i_outpl-werks IN s_werks AND
       i_outpl-matnr IN s_matnr.

      i_outpl-qdocn_ip = i_outpl-qdo_ip - ABS( i_outpl-qcn_ip ).
      i_outpl-vdocn_ip = i_outpl-vdo_ip - ABS( i_outpl-vcn_ip ).
      i_outpl-stkdocn_ip =  ABS( i_outpl-stkcn_ip ) - i_outpl-stkdo_ip.
      i_outpl-varsls = i_outpl-estsls - i_outpl-netsamt.

      READ TABLE i_zplbc WITH KEY bukrs = '8070'
                                  reswk = i_outpl-werks TRANSPORTING NO FIELDS.
      IF sy-subrc EQ 0.
        CLEAR: i_outpl-ratid,i_outpl-region.
      ENDIF.

      APPEND i_outpl.
    ENDIF.
  ENDLOOP.
  CLEAR: itabline,itabline[].

  "Process SUT
  LOOP AT itabline_sut INTO wa_itabline_sut.
    CLEAR: i_dataset,i_outpl.
    i_dataset = wa_itabline_sut.

    READ TABLE i_zplbc WITH KEY bukrs = '8070'
                                werks = i_dataset-werks.
    IF sy-subrc EQ 0.
      PERFORM f_cek_aix.
      i_dataset-werks = i_zplbc-reswk.

      MOVE-CORRESPONDING i_dataset TO i_outpl.

      IF i_outpl-werks IN s_werks AND
         i_outpl-matnr IN s_matnr.

        i_outpl-qdocn_ip = i_outpl-qdo_ip - ABS( i_outpl-qcn_ip ).
        i_outpl-vdocn_ip = i_outpl-vdo_ip - ABS( i_outpl-vcn_ip ).
        i_outpl-stkdocn_ip =  ABS( i_outpl-stkcn_ip ) - i_outpl-stkdo_ip.
        i_outpl-varsls = i_outpl-estsls - i_outpl-netsamt.

        gv_utd = abap_on.
        CLEAR: i_outpl-nsp,i_outpl-kausf,i_outpl-region,i_outpl-ratid.

        COLLECT i_outpl.
      ENDIF.
    ENDIF.
  ENDLOOP.
  CLEAR: itabline_sut,itabline_sut[].

  "Get Average United
  IF gv_utd IS NOT INITIAL.
    lt_outpl[] = i_outpl[].
    SORT lt_outpl BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_outpl COMPARING matnr.

    IF lt_outpl[] IS NOT INITIAL.
      SELECT a~matnr a~prodh b~zeinr
        INTO TABLE i_matnr
        FROM mvke AS a JOIN mara AS b ON a~matnr EQ b~matnr
        FOR ALL ENTRIES IN lt_outpl
        WHERE a~matnr EQ lt_outpl-matnr AND
              a~vkorg EQ '8020'         AND
              a~vtweg EQ '10'.
    ENDIF.

    SORT i_outpl BY matnr werks.
    SORT i_matnr BY matnr.

    LOOP AT i_outpl.
      READ TABLE i_zplbc WITH KEY bukrs = '8070'
                                  reswk = i_outpl-werks.
      IF sy-subrc = 0.
        IF i_outpl-peran IS INITIAL.
          CLEAR: i_matnr,lv_year.
          READ TABLE i_matnr WITH KEY matnr = i_outpl-matnr BINARY SEARCH.

          IF sy-subrc = 0 AND i_matnr-zeinr NE space.
            CONCATENATE i_matnr-zeinr+6(4) i_matnr-zeinr+3(2) INTO i_outpl-zeinr.
            lv_year = ( p_spmon(4) - i_outpl-zeinr(4) ) * 12.
            i_outpl-peran = lv_year + ( p_spmon+4(2) - i_outpl-zeinr+4(2) ).
          ELSE.
            i_outpl-peran = 6.
          ENDIF.

          IF p_spmon EQ sy-datum(6).
            i_outpl-peran = i_outpl-peran - 1.
          ENDIF.

          IF i_outpl-peran > 6.
            i_outpl-peran = 6.
          ENDIF.

          CASE i_outpl-prodh1.
            WHEN 'BHR'.
              IF i_outpl-peran > 5.
                i_outpl-peran = 5.
              ENDIF.
            WHEN 'RCH' OR 'PHR' OR 'AVT'.
              IF i_outpl-peran > 4.
                i_outpl-peran = 4.
              ENDIF.
            WHEN 'ALC'.
              IF i_outpl-peran > 3.
                i_outpl-peran = 3.
              ENDIF.
            WHEN 'TSP'.
              IF i_outpl-prodh2 = 'ELY'.
                IF i_outpl-peran > 3.
                  i_outpl-peran = 3.
                ENDIF.
              ENDIF.
          ENDCASE.
        ENDIF.

        CASE i_outpl-peran.
          WHEN 6.
            i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
                              i_outpl-x4 + i_outpl-x5 + i_outpl-x6 ) /
                              i_outpl-peran.
          WHEN 5.
            i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
                              i_outpl-x4 + i_outpl-x5 ) /
                              i_outpl-peran.
          WHEN 4.
            i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 +
                              i_outpl-x4 ) /
                              i_outpl-peran.
          WHEN 3.
            i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 + i_outpl-x3 ) /
                              i_outpl-peran.
          WHEN 2.
            i_outpl-avqty = ( i_outpl-x1 + i_outpl-x2 ) /
                              i_outpl-peran.
          WHEN 1.
            i_outpl-avqty = ( i_outpl-x1 ) / i_outpl-peran.
        ENDCASE.

        i_outpl-avamt = i_outpl-avqty * i_outpl-nsp.

        MODIFY i_outpl TRANSPORTING zeinr peran avqty avamt.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_SAC7_UNITED

*&---------------------------------------------------------------------*
*&      Form  f_cek_aix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_cek_aix.
  IF sy-opsys = 'AIX'.
    IF i_dataset-stkcn_ip+12(1) = ' ' OR
       i_dataset-stkcn_ip+12(1) = '-'.
    ELSE.
      REPLACE i_dataset-stkcn_ip+12(1) WITH space
         INTO i_dataset-stkcn_ip.
    ENDIF.
    IF i_dataset-ratms+12(1) = ' ' OR
       i_dataset-ratms+12(1) = '-'.
    ELSE.
      REPLACE i_dataset-ratms+12(1) WITH space INTO i_dataset-ratms.
    ENDIF.
  ENDIF.
ENDFORM.                    " f_cek_aix

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_WITH_SEPARATOR
*&---------------------------------------------------------------------*
FORM f_download_with_separator  USING    fu_separator.
  DATA : lv_totpo(20),
         lv_opnsto(20),
         lv_grsto(20).

* Convert itab to string
  SORT i_main BY matnr werks.

  PERFORM f_concatenate USING : fu_separator 'Material' '1',
                                fu_separator 'Material Description' '',
                                fu_separator 'Material Group' '',
                                fu_separator 'Unit' '',
                                fu_separator 'Plant' '',
                                fu_separator 'Plant Description' '',
                                fu_separator 'Total CW Alloc.' '',
                                fu_separator 'Open DN' '',
                                fu_separator 'Good Receipt' '2'.
  APPEND gs_download TO gt_download.
  CLEAR gs_download.

  LOOP AT i_main.
    PERFORM f_value_modify USING i_main-totpo i_main-meins
                           CHANGING lv_totpo.
    PERFORM f_value_modify USING i_main-opnsto i_main-meins
                           CHANGING lv_opnsto.
    PERFORM f_value_modify USING i_main-grsto i_main-meins
                           CHANGING lv_grsto.

    PERFORM f_concatenate USING : fu_separator i_main-matnr '1',
                                  fu_separator i_main-maktx '',
                                  fu_separator i_main-matkl '',
                                  fu_separator i_main-meins '',
                                  fu_separator i_main-werks '',
                                  fu_separator i_main-name1 '',
                                  fu_separator lv_totpo '',
                                  fu_separator lv_opnsto '',
                                  fu_separator lv_grsto '2'.
    APPEND gs_download TO gt_download.
    CLEAR gs_download.
  ENDLOOP.

* Get filename
  CONCATENATE p_path 'ALO-' sy-datum '.txt' INTO p_path.

* Download to server
  CALL METHOD zcl_util=>m_download_dataset
    EXPORTING
      param_name = p_path
      pti_data   = gt_download[].

  IF sy-subrc = 0.
    MESSAGE 'Download sukses' TYPE 'S'.
  ELSE.
    MESSAGE 'Download gagal' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_DOWNLOAD_WITH_SEPARATOR

*&---------------------------------------------------------------------*
*&      Form  F_CONCATENATE
*&---------------------------------------------------------------------*
FORM f_concatenate  USING    fu_separator fu_value fu_flag.
  CASE fu_flag.
    WHEN '1'.
      CONCATENATE fu_value fu_separator INTO gs_download.
    WHEN '2'.
      CONCATENATE gs_download fu_value INTO gs_download.
    WHEN OTHERS.
      CONCATENATE gs_download fu_value fu_separator INTO gs_download.
  ENDCASE.
ENDFORM.                    " F_CONCATENATE

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_MODIFY
*&---------------------------------------------------------------------*
FORM f_value_modify  USING    fu_value fu_meins
                     CHANGING fc_value.
  IF fu_meins IS NOT INITIAL.
    WRITE fu_value TO fc_value UNIT fu_meins.
  ELSE.
    WRITE fu_value TO fc_value.
  ENDIF.
  CONDENSE fc_value NO-GAPS.
  REPLACE ALL OCCURRENCES OF '.' IN fc_value WITH space.
  REPLACE ALL OCCURRENCES OF ',' IN fc_value WITH '.'.
  CONDENSE fc_value.
ENDFORM.                    " F_VALUE_MODIFY
