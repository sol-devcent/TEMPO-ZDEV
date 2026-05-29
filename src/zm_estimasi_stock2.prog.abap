*--------------------------------------------------------------------*
* Copy from ZM_ESTIMASI_STOCK dg penambahan sales office
*--------------------------------------------------------------------*

REPORT zm_estimasi_stock2 MESSAGE-ID zm
                          LINE-SIZE 255 LINE-COUNT 65
                          NO STANDARD PAGE HEADING.

INCLUDE zm_estimasi_stock2_001.
INCLUDE zm_estimasi_stock2_002.
INCLUDE zm_estimasi_stock2_003.

DATA : t_ebeln  TYPE ekko-ebeln OCCURS 0,
       d_ebeln  TYPE ekko-ebeln,
       gr_lgort TYPE RANGE OF lgort_d.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS     : p_spmon LIKE s931-spmon DEFAULT sy-datum(6) OBLIGATORY.
SELECT-OPTIONS : s_werks FOR mard-werks OBLIGATORY,
                 s_vkbur FOR s603-vkbur,
                 s_matkl FOR mara-matkl,
                 s_matnr FOR mard-matnr.

SELECTION-SCREEN SKIP.
PARAMETERS : pa_path LIKE rlgrap-filename LOWER CASE MODIF ID gry.
SELECTION-SCREEN END OF BLOCK block1.

SELECTION-SCREEN BEGIN OF BLOCK block4 WITH FRAME TITLE TEXT-003.
SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS : radio90 RADIOBUTTON GROUP grp9 USER-COMMAND rad
             DEFAULT 'X'.
SELECTION-SCREEN: COMMENT 4(26) TEXT-f01 FOR FIELD radio90.
PARAMETERS : p_vari LIKE disvariant-variant MODIF ID 001.
" ALV Variant
SELECTION-SCREEN: END OF LINE,

                  BEGIN OF LINE.
PARAMETERS : radio91 RADIOBUTTON GROUP grp9.
SELECTION-SCREEN: COMMENT 4(26) TEXT-f02 FOR FIELD radio91.
PARAMETERS : p_filenm LIKE rlgrap-filename MODIF ID 002.
SELECTION-SCREEN: END OF LINE.

SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS : radio92 RADIOBUTTON GROUP grp9.
SELECTION-SCREEN: COMMENT 4(26) TEXT-f03 FOR FIELD radio92.
PARAMETERS : p_flnmsv LIKE rlgrap-filename MODIF ID 004.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN END OF BLOCK block4.

PARAMETERS: p_grid  AS CHECKBOX DEFAULT 'X' MODIF ID 001.
PARAMETERS: p_incsut  AS CHECKBOX.
PARAMETERS: p_united  AS CHECKBOX MODIF ID 003 DEFAULT 'X'.
PARAMETERS: p_incdel  AS CHECKBOX MODIF ID 003.
PARAMETERS: p_incuns  AS CHECKBOX MODIF ID 003.

INCLUDE zm_estimasi_stock2_f03.
*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  p_filenm = 'C:\'.
  IF sy-opsys = 'AIX'
    OR sy-opsys = 'LINUX'
    OR sy-opsys = 'Linux'.
    pa_path = '/interface/SAC7/SLOFF/'.
    p_flnmsv = '/interface3/DSP/ZM68N/'.
  ELSE.
    pa_path = '\\tdsdev01\interface\SAC7\SLOFF\MONTHLY\'.
    p_flnmsv = '\\tdsdev01\interface3\DSP\ZM68N\'.
  ENDIF.

*------------------------------------------------------
* AT SELECTION-SCREEN OUTPUT
*------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  CASE 'X'.
    WHEN radio90.
      LOOP AT SCREEN.
        IF screen-group1 = '002'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = '004'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'GRY'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN radio91.
      LOOP AT SCREEN.
        IF screen-group1 = '001'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = '004'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'GRY'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN radio92.
      LOOP AT SCREEN.
        IF screen-group1 = '001'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = '002'.
          screen-active = '0'.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'GRY'.
          screen-input = '0'.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN
*------------------------------------------------------
* for alv variant
AT SELECTION-SCREEN ON s_werks.
  SELECT werks name1 INTO TABLE i_werks
    FROM t001w WHERE werks IN s_werks AND
                     spras EQ sy-langu.
  SORT i_werks BY werks.
  LOOP AT i_werks.
    AUTHORITY-CHECK OBJECT 'M_MSEG_WWE'
                    ID 'WERKS' FIELD i_werks-werks.
    IF sy-subrc NE 0.
      MESSAGE e000(zm) WITH 'You are not authorized with Plant'
                            i_werks-werks.
    ENDIF.
  ENDLOOP.

AT SELECTION-SCREEN ON RADIOBUTTON GROUP grp9.
  IF radio92 = 'X'.
    AUTHORITY-CHECK OBJECT 'ZROFO'
              ID 'ACTVT' FIELD '60'.
    IF sy-subrc <> 0.
      MESSAGE i000(zab)
              WITH 'You are not authorized to load SAP data'.
      STOP.
    ENDIF.
  ENDIF.

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
  PERFORM f_get_data.
  PERFORM f_get_data_sac7.
  PERFORM f_get_data_sac7_united.
  CASE 'X'.
    WHEN radio90.
      PERFORM f_print_data.
    WHEN radio91.
      PERFORM f_download_local.
    WHEN radio92.
      PERFORM f_download_server.
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
  DATA : lt_001l  TYPE STANDARD TABLE OF t001l,
         ls_001l  LIKE LINE OF lt_001l,
         ls_lgort LIKE LINE OF gr_lgort.

  SELECT *
    FROM t001l
    INTO CORRESPONDING FIELDS OF TABLE lt_001l
    WHERE werks IN s_werks.

  SORT lt_001l BY lgort.
  DELETE ADJACENT DUPLICATES FROM lt_001l COMPARING lgort.
  LOOP AT lt_001l INTO ls_001l.
    IF ls_001l-werks(2) = '02'.
      IF ls_001l-lgort+2(1) = 'D' OR
        ls_001l-lgort+2(1) = 'U' OR
        ls_001l-lgort = '1099'.
        ls_lgort-low    = ls_001l-lgort.
        ls_lgort-sign   = 'E'.
        ls_lgort-option = 'EQ'.
        APPEND ls_lgort TO gr_lgort.
        CLEAR ls_lgort.
      ENDIF.
    ELSE.
      IF ls_001l-lgort+2(1) = 'D' OR
        ls_001l-lgort+2(1) = 'U'.
        ls_lgort-low    = ls_001l-lgort.
        ls_lgort-sign   = 'E'.
        ls_lgort-option = 'EQ'.
        APPEND ls_lgort TO gr_lgort.
        CLEAR ls_lgort.
      ENDIF.
    ENDIF.
  ENDLOOP.
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
  DATA : l_year          LIKE  mard-lfgja,
         l_month         LIKE  mard-lfmon,
         l_date1         LIKE  mb_mdbs-bedat,
         l_date2         LIKE  mb_mdbs-bedat,
         l_year2         LIKE  mard-lfgja,
         l_month2        LIKE  mard-lfmon,
         l_spmon         LIKE  s039-spmon,
         f_spmon         LIKE  s039-spmon,
         l_filename(125),
         l_date          LIKE  sy-datum,
         l_day           TYPE p,
         l_day1(2)       TYPE n,
         l_tabix         LIKE  sy-tabix,
         l_opnsto        LIKE  i_main-opnsto,
         lw_main         LIKE  i_main,
         lw_march        LIKE  i_march,
         l_lgort         LIKE  tvkol-lgort,
         l_werksvkbur    TYPE  char8,
         l_keyfl         TYPE  char8,
         cw              TYPE  c,
         l_period(6).
  RANGES: ns_werks FOR mard-werks,
          lr_lgort  FOR mard-lgort.

  DATA: BEGIN OF i_s933s OCCURS 0,
          matnr LIKE s933-matnr,
          werks LIKE s933-werks,
          lgort LIKE s933-lgort,
          menge LIKE s933-menge,
        END OF i_s933s.

  DATA: i_s933t   LIKE i_s933s OCCURS 0 WITH HEADER LINE,
        i_s933x   LIKE i_s933s OCCURS 0 WITH HEADER LINE,
        i_s933int LIKE i_s933s OCCURS 0 WITH HEADER LINE,
        i_s931t   LIKE i_s931 OCCURS 0 WITH HEADER LINE.

  DATA: i_tvkol2 TYPE TABLE OF tvkol WITH HEADER LINE.

  DATA: BEGIN OF i_s801 OCCURS 0.
          INCLUDE STRUCTURE s801.
        DATA: END OF i_s801.

  DATA: lv_menge  TYPE s933-menge.

  TYPES : BEGIN OF ty_mara,
            matnr TYPE mara-matnr,
          END OF ty_mara.
  DATA : lt_mara TYPE STANDARD TABLE OF ty_mara,
         ls_mara LIKE LINE OF lt_mara.

  DATA : lt_x039 LIKE i_s039 OCCURS 0,
         ls_x039 LIKE LINE OF lt_x039.

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
*  CONCATENATE p_spmon '31' INTO l_date2.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = l_date1
    IMPORTING
      last_day_of_month = l_date2.

  l_month2 = l_month - 1.
  IF l_month2 LE 0.
    l_year2 = l_year - 1.
    l_month2 = l_month2 + 12.
  ELSE.
    l_year2 = l_year.
  ENDIF.
  CONCATENATE l_year2 l_month2 INTO l_spmon.

  SELECT * INTO TABLE i_tvkol FROM tvkol
    WHERE werks IN s_werks.

  SELECT * INTO TABLE i_mat_b2b
    FROM zsmat_b2b WHERE kvgr4 IN ('101','107')
                     AND valid_to GE l_date2
                     AND valid_fr LE l_date1
                     AND lvorm EQ space.

*-----------------------------------------------------*
* Process to get stock point already go live with SAP
* i_tvkol2 contain not yet SAP go live
*-----------------------------------------------------*
  SELECT vstel werks lgort
    INTO CORRESPONDING FIELDS OF TABLE i_tvkol2
    FROM t001l
    WHERE werks IN s_werks
      AND lgort <> '1000'
      AND vstel <> ''.

  SORT i_tvkol BY werks lgort.
  LOOP AT i_tvkol2.
    READ TABLE i_tvkol WITH KEY werks = i_tvkol2-werks
                                lgort = i_tvkol2-lgort
    BINARY SEARCH.
    IF sy-subrc = 0.
      DELETE i_tvkol2.
    ENDIF.
  ENDLOOP.
  APPEND LINES OF i_tvkol2 TO i_tvkol.
*-----------------------------------------------------*

  SELECT vkbur bezei INTO TABLE i_vkbur
    FROM tvkbt WHERE vkbur IN s_vkbur AND
                     spras EQ sy-langu.
  SORT i_vkbur BY vkbur.

** Select MAKT
  IF p_incdel = ''.
    SELECT a~matkl a~matnr a~meins a~zeinr a~zeiar b~maktx
           c~nfmat c~kzaus
      INTO CORRESPONDING FIELDS OF TABLE i_makt
      FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
                     JOIN marc AS c ON a~matnr = c~matnr
      WHERE a~matkl IN s_matkl  AND
            a~matnr IN s_matnr  AND
            a~lvorm = ''        AND
          ( a~mtart = 'ZPHA' OR a~mtart = 'ZCGB' OR
            a~mtart = 'ZCGN' )  AND
            b~spras = sy-langu  AND
            c~werks = '0200'.
  ELSE.
    SELECT a~matkl a~matnr a~meins a~zeinr a~zeiar b~maktx
           c~nfmat c~kzaus
      INTO CORRESPONDING FIELDS OF TABLE i_makt
      FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
                     JOIN marc AS c ON a~matnr = c~matnr
      WHERE a~matkl IN s_matkl  AND
            a~matnr IN s_matnr  AND
          ( a~mtart = 'ZPHA' OR a~mtart = 'ZCGB' OR
            a~mtart = 'ZCGN' )  AND
            b~spras = sy-langu  AND
            c~werks = '0200'.
  ENDIF.

  SELECT matnr
    FROM mara
    INTO TABLE lt_mara
    WHERE matnr IN s_matnr.

  READ TABLE lt_mara INTO ls_mara
                     WITH KEY matnr = 'Z03-00-00'.
  IF sy-subrc = 0.
    SELECT a~matkl a~matnr a~meins a~zeinr a~zeiar b~maktx
           c~nfmat c~kzaus
      APPENDING CORRESPONDING FIELDS OF TABLE i_makt
      FROM mara AS a JOIN makt AS b ON a~matnr = b~matnr
                     JOIN marc AS c ON a~matnr = c~matnr
      WHERE a~matkl IN s_matkl
        AND a~matnr = 'Z03-00-00'
        AND b~spras = sy-langu
        AND c~werks = '0200'.
  ENDIF.

  LOOP AT i_makt WHERE nfmat = 'Z00-00-00'.
    CLEAR i_makt-nfmat.
    MODIFY i_makt.
  ENDLOOP.
  IF i_makt[] IS INITIAL.
    MESSAGE i000(zm) WITH 'No Material Selected'.
    STOP.
  ENDIF.
  SORT i_makt BY matnr.

  CONCATENATE p_spmon(4) p_spmon+4(2) '01' INTO l_date.
  CALL FUNCTION 'HR_E_NUM_OF_DAYS_OF_MONTH'
    EXPORTING
      p_fecha        = l_date
    IMPORTING
      number_of_days = l_day.
  l_day1 = l_day.
  CONCATENATE p_spmon(4) p_spmon+4(2) l_day1 INTO l_date.

  IF p_spmon+4(2) NE sy-datum+4(2).
    SELECT a~matnr a~knumh b~kbetr
    INTO CORRESPONDING FIELDS OF TABLE i_nsp
    FROM a510 AS a JOIN konp AS b ON a~knumh = b~knumh
    FOR ALL ENTRIES IN i_makt
    WHERE a~kappl EQ 'V'           AND
          a~kschl EQ 'ZN01'        AND
          a~matnr EQ i_makt-matnr  AND
          a~datbi GE l_date        AND
          a~datab LE l_date        AND
          b~loevm_ko NE 'X'.

  ELSE.
    SELECT a~matnr a~knumh b~kbetr
    INTO CORRESPONDING FIELDS OF TABLE i_nsp
    FROM a510 AS a JOIN konp AS b ON a~knumh = b~knumh
    FOR ALL ENTRIES IN i_makt
    WHERE a~kappl EQ 'V'           AND
          a~kschl EQ 'ZN01'        AND
          a~matnr EQ i_makt-matnr  AND
          a~datab LT sy-datum      AND
          a~datbi GE sy-datum      AND
          b~loevm_ko NE 'X'.
  ENDIF.

** Select MARC
  IF p_incdel = ''.
    SELECT matnr werks umlmc kausf lfgja lfmon maabc
      INTO CORRESPONDING FIELDS OF TABLE i_marc
      FROM marc
      FOR ALL ENTRIES IN i_makt
      WHERE matnr = i_makt-matnr  AND
            lvorm = ''        AND
            werks IN s_werks.
  ELSE.
    SELECT matnr werks umlmc kausf lfgja lfmon maabc
      INTO CORRESPONDING FIELDS OF TABLE i_marc
      FROM marc
      FOR ALL ENTRIES IN i_makt
      WHERE matnr = i_makt-matnr  AND
            werks IN s_werks.
  ENDIF.
  IF i_marc[] IS INITIAL.
    MESSAGE i000(zm) WITH 'No Material Selected'.
    STOP.
  ENDIF.

  SORT i_marc BY matnr werks.

** Select MARCH
  DATA : v_lfmon LIKE mardh-lfmon,
         v_lfgja LIKE mard-lfgja.
  v_lfmon = p_spmon+4(2) - 1.
  v_lfgja = p_spmon(4).
  IF v_lfmon = '00'.
    v_lfmon = '12'.
    v_lfgja = p_spmon(4) - 1.
  ENDIF.

  SELECT matnr werks umlmc lfgja lfmon
    FROM march
    INTO CORRESPONDING FIELDS OF TABLE i_march
     FOR ALL ENTRIES IN i_marc
   WHERE matnr = i_marc-matnr
     AND werks = i_marc-werks
      AND ( lfgja > v_lfgja
       OR lfgja = v_lfgja AND lfmon => v_lfmon ).
*     AND lfgja EQ v_lfgja
*     AND lfmon EQ v_lfmon.
  SORT i_march BY matnr werks lfgja lfmon.
  CLEAR lw_march.
  LOOP AT i_march.
    IF lw_march-matnr <> i_march-matnr OR
       lw_march-werks <> i_march-werks.
      lw_march-matnr = i_march-matnr.
      lw_march-werks = i_march-werks.
      i_march-lfmon = v_lfmon.
      i_march-lfgja = v_lfgja.
      MODIFY i_march.
    ELSE.
      DELETE i_march.
    ENDIF.
  ENDLOOP.
  BREAK mmfm.

  PERFORM get_intransit TABLES i_marc
                               i_s933s
                        USING  p_spmon.

  f_spmon = p_spmon.
  f_spmon = f_spmon + 1.
  IF f_spmon+4(2) = '13'.
    f_spmon+4(2) = '01'.
    f_spmon(4) = f_spmon(4) + 1.
  ENDIF.

  PERFORM get_intransit TABLES i_marc
                               i_s933t
                        USING  f_spmon.

  "ADD condition for Intransit Mvt 313    20.10.2023
  PERFORM f_get_intransit_313 TABLES i_s933int.

  i_s933t-lgort = '1000'.
  MODIFY i_s933t TRANSPORTING lgort WHERE lgort(1) = '1'.
  DELETE i_s933t WHERE menge = 0.

** Select MARD
  SELECT matnr werks lgort labst insme speme exppg
    INTO CORRESPONDING FIELDS OF TABLE i_mard
    FROM mard
    FOR ALL ENTRIES IN i_marc
    WHERE matnr = i_marc-matnr  AND
          werks = i_marc-werks  AND
          lgort IN gr_lgort.
*        ( lgort NE '10D0' AND lgort NE '10U0' ).

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
*      FOR ALL ENTRIES IN i_marc
      WHERE a~matnr IN s_matnr  AND
*          a~werks IN s_werks  AND
            a~bstyp = 'F'       AND
            a~loekz = ' '       AND
*          a~elikz = ' '       AND
           ( b~bedat GE l_date1  AND b~bedat LE l_date2 ) AND
           ( b~bsart = 'OB' OR b~bsart = 'NB' OR
             b~bsart = 'UB' OR b~bsart = 'ZB' OR
             b~bsart = 'ZSUT' OR b~bsart = 'ZICO' OR
             b~bsart = 'ZRL' ).
  ELSE.
    SELECT a~matnr a~werks a~lgort a~bstyp a~ebeln
           a~ebelp a~menge a~wemng a~wamng a~glmng
           b~bedat b~bsart
      INTO CORRESPONDING FIELDS OF TABLE i_mdbs
      FROM mb_mdbs AS a JOIN ekko AS b ON a~ebeln = b~ebeln
      FOR ALL ENTRIES IN i_marc
      WHERE a~matnr = i_marc-matnr  AND
            a~werks = i_marc-werks  AND
            a~bstyp = 'F'       AND
            a~loekz = ' '       AND
*          a~elikz = ' '       AND
           ( b~bedat GE l_date1  AND b~bedat LE l_date2 ) AND
           ( b~bsart = 'OB' OR b~bsart = 'NB' OR
             b~bsart = 'UB' OR b~bsart = 'ZB' OR
             b~bsart = 'ZSUT' OR b~bsart = 'ZICO' OR
             b~bsart = 'ZRL' ).
  ENDIF.

** Select S039
  SELECT matnr werks lgort gsbest mbwbest
    INTO CORRESPONDING FIELDS OF TABLE i_s039
    FROM s039
    FOR ALL ENTRIES IN i_marc
    WHERE ssour = ''         AND
          vrsio = '000'      AND
          spmon = l_spmon    AND
          sptag = '00000000' AND
          spwoc = '000000'   AND
          spbup = '000000'   AND
          werks = i_marc-werks   AND
          matnr = i_marc-matnr.  "AND

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

  IF p_spmon = sy-datum(6). "For current month select sales data from LIS
    SELECT matnr werks lgort SUM( menge ) "Select sum can not use corresponding field
      INTO TABLE i_s931t
      FROM s931
      WHERE ssour = ''         AND
            vrsio = '000'      AND
            spmon = p_spmon    AND
            sptag = '00000000' AND
            spwoc = '000000'   AND
            spbup = '000000'   AND
            matnr IN s_matnr   AND
            werks IN s_werks   AND
            lgort <> '10U0'    AND
            bwart IN ('601', '602', '645', '646', '909', '910', '907', '908', 'Z07', 'Z08')
      GROUP BY matnr werks lgort.
    LOOP AT i_s931t.
      IF i_s931t-lgort(1) = 1.
        i_s931t-lgort = '1000'.
      ENDIF.
      i_s931t-menge =  i_s931t-menge * -1.
      COLLECT i_s931t INTO i_s931.
    ENDLOOP.
    SORT i_s931 BY matnr werks lgort.
  ENDIF.

** Select S912
*  SELECT spmon matnr werks zqnetsls zrunrate zavg_sls
*    INTO CORRESPONDING FIELDS OF TABLE i_s912
*    FROM s912
*    WHERE ssour = ''        AND
*          vrsio = '000'     AND
*          spmon = p_spmon   AND
*          sptag = '00000000' AND
*          spwoc = '000000'   AND
*          spbup = '000000'   AND
*          matnr IN s_matnr  AND
*          werks IN s_werks.
*  SORT i_s912 BY matnr werks.
* added by idub, 20060130
* according to leo request, add 2 additional fields
*--------------------------------------------------
*  SELECT matnr werks ktmng
*    INTO CORRESPONDING FIELDS OF TABLE i_s912cm
*    FROM s912
*    WHERE ssour = ''        AND
*          vrsio = '000'     AND
*          spmon = p_spmon   AND
*          sptag = '00000000' AND
*          spwoc = '000000'   AND
*          spbup = '000000'   AND
*          matnr IN s_matnr  AND
*          werks IN s_werks.

*  LOOP AT i_s912cm.
*    MOVE-CORRESPONDING i_s912cm TO i_s912cmsum.
*    COLLECT i_s912cmsum.
*  ENDLOOP.
*  SORT i_s912cmsum BY matnr werks.

  l_period = p_spmon.
  ADD 1 TO l_period.

*  SELECT matnr werks ktmng
*    INTO CORRESPONDING FIELDS OF TABLE i_s912nm
*    FROM s912
*    WHERE ssour = ''        AND
*          vrsio = '000'     AND
*          spmon = l_period   AND
*          sptag = '00000000' AND
*          spwoc = '000000'   AND
*          spbup = '000000'   AND
*          matnr IN s_matnr  AND
*          werks IN s_werks.
*
*  LOOP AT i_s912nm.
*    MOVE-CORRESPONDING i_s912nm TO i_s912nmsum.
*    COLLECT i_s912nmsum.
*  ENDLOOP.
*  SORT i_s912nmsum BY matnr werks.
*--------------------------------------------------

  SORT i_tvkol BY werks lgort.
  SORT i_mard  BY werks lgort.
*  IF sy-uname = 'MMFM' OR sy-uname = 'PMETP' OR
*     sy-uname(5) = 'SOMAM' OR sy-uname = 'MMIMG'.
  PERFORM get_forecast TABLES i_mard
                              i_marm
                              i_tvkol
                              i_s801
                       USING  p_spmon.
*  ENDIF.

*** ----------------------
*** Collect Itab Main
*** ----------------------
  SORT i_march BY matnr werks lfgja lfmon.
  SORT i_marc  BY matnr werks.
  SORT i_mdbs BY werks lgort.
  SORT i_s039 BY werks lgort.
  SORT i_s801 BY matnr vkbur spmon.

* Filter data in i_mard to improve processing time
* and eliminate not necessary data
  DELETE i_mard WHERE labst = 0 AND
                      insme = 0 AND
                      speme = 0 AND
  lgort <> '1000' AND lgort <> '2000' AND
  lgort <> '2100' AND lgort <> '2200' AND
  lgort <> '2300' AND lgort <> '2400'.
  LOOP AT i_mard.
    READ TABLE i_tvkol2 WITH KEY werks = i_mard-werks
                                 lgort = i_mard-lgort
    BINARY SEARCH.
    IF sy-subrc = 0 AND i_mard-lgort(1) = '2'.
      DELETE i_mard.
    ENDIF.
  ENDLOOP.

** Collect From MARD
  SORT i_mard BY matnr werks lgort.
  LOOP AT i_mard.
    READ TABLE i_makt WITH KEY matnr = i_mard-matnr BINARY SEARCH.
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
    i_main-nfmat = i_makt-nfmat.
    i_main-kzaus = i_makt-kzaus.
    i_main-meins = i_makt-meins.
    i_main-zeiar = i_makt-zeiar.
    i_main-nfmat = i_makt-nfmat.
    i_main-kzaus = i_makt-kzaus.
    i_main-matnr = i_mard-matnr.
    i_main-werks = i_mard-werks.
    i_main-stkcr = i_mard-labst + i_mard-insme.
*    i_main-maabc = i_mard-exppg.
    READ TABLE i_marm WITH KEY matnr = i_main-matnr
                               meinh = 'PAL'
    BINARY SEARCH.
    IF sy-subrc = 0.
      i_main-stkcrpl = i_main-stkcr * i_marm-umren / i_marm-umrez.
    ENDIF.

    i_main-blstkcr = i_mard-speme.
    READ TABLE i_werks WITH KEY werks = i_main-werks BINARY SEARCH.
    i_main-name1 = i_werks-name1.

    CLEAR: l_lgort,i_tvkol.
* Intransit count as main branch stock
    IF i_mard-lgort IS INITIAL.
      l_lgort = '1000'.
    ELSE.
      CONCATENATE i_mard-lgort(2) '00' INTO l_lgort.
    ENDIF.

* Set canvas stock as main branch stock test
    IF l_lgort(1) = '1'.
      l_lgort = '1000'.
    ENDIF.

    READ TABLE i_tvkol WITH KEY werks = i_mard-werks
                                lgort = l_lgort BINARY SEARCH.
    i_main-vkbur = i_tvkol-vstel.

    READ TABLE i_vkbur WITH KEY vkbur = i_main-vkbur BINARY SEARCH.
    i_main-bezei = i_vkbur-bezei.

* Get forecast for each sales office 1 times only
    IF i_mard-lgort+2(2) = '00'.
* Forecast data
      CLEAR i_s801.
      READ TABLE i_s801 WITH KEY matnr = i_main-matnr
                                 vkbur = i_main-vkbur
                                 spmon = p_spmon
      BINARY SEARCH.
      i_main-m0      = i_s801-aftsqty.
      i_main-ftsm0w1 = i_s801-ftsw1qty.
      i_main-ftsm0w2 = i_s801-ftsw2qty.
      i_main-ftsm0w3 = i_s801-ftsw3qty.
      i_main-ftsm0w4 = i_s801-ftsw4qty.

      l_spmon = p_spmon + 1.
      IF l_spmon+4(2) = '13'.
        l_spmon+4(2) = '01'.
        l_spmon(4) = l_spmon(4) + 1.
      ENDIF.
      CLEAR i_s801.
      READ TABLE i_s801 WITH KEY matnr = i_main-matnr
                                 vkbur = i_main-vkbur
                                 spmon = l_spmon
      BINARY SEARCH.
      i_main-m1      = i_s801-aftsqty.
      i_main-ftsm1w1 = i_s801-ftsw1qty.
      i_main-ftsm1w2 = i_s801-ftsw2qty.
      i_main-ftsm1w3 = i_s801-ftsw3qty.
      i_main-ftsm1w4 = i_s801-ftsw4qty.

      l_spmon = l_spmon + 1.
      IF l_spmon+4(2) = '13'.
        l_spmon+4(2) = '01'.
        l_spmon(4) = l_spmon(4) + 1.
      ENDIF.
      CLEAR i_s801.
      READ TABLE i_s801 WITH KEY matnr = i_main-matnr
                                 vkbur = i_main-vkbur
                                 spmon = l_spmon
      BINARY SEARCH.
      i_main-m2      = i_s801-aftsqty.
      i_main-ftsm2w1 = i_s801-ftsw1qty.
      i_main-ftsm2w2 = i_s801-ftsw2qty.
      i_main-ftsm2w3 = i_s801-ftsw3qty.
      i_main-ftsm2w4 = i_s801-ftsw4qty.

      l_spmon = p_spmon + 1.
      IF l_spmon+4(2) = '13'.
        l_spmon+4(2) = '01'.
        l_spmon(4) = l_spmon(4) + 1.
      ENDIF.
      CLEAR i_s801.
      READ TABLE i_s801 WITH KEY matnr = i_main-matnr
                                 vkbur = i_main-vkbur
                                 spmon = l_spmon
      BINARY SEARCH.
      i_main-m3      = i_s801-aftsqty.
      i_main-ftsm3w1 = i_s801-ftsw1qty.
      i_main-ftsm3w2 = i_s801-ftsw2qty.
      i_main-ftsm3w3 = i_s801-ftsw3qty.
      i_main-ftsm3w4 = i_s801-ftsw4qty.

    ENDIF.

* Set sloc for itransit, canvas and unsaleable as main warehouse stock
    i_main-lgort = l_lgort.
    COLLECT i_main. CLEAR i_main.
  ENDLOOP.
  DELETE i_main WHERE vkbur = ''.

** Collect From MD_MDBS

  IF p_incsut = ''.
*    DELETE i_mdbs WHERE werks = '0201' AND lgort = '1100'.
    DELETE i_mdbs WHERE werks = '0201' AND lgort IN lr_lgort.
  ENDIF.

  LOOP AT i_mdbs.
    READ TABLE i_makt WITH KEY matnr = i_mdbs-matnr BINARY SEARCH.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    i_main-matkl = i_makt-matkl.
    i_main-maktx = i_makt-maktx.
    i_main-nfmat = i_makt-nfmat.
    i_main-kzaus = i_makt-kzaus.
    i_main-meins = i_makt-meins.
    i_main-zeiar = i_makt-zeiar.
    i_main-nfmat = i_makt-nfmat.
    i_main-kzaus = i_makt-kzaus.
    i_main-matnr = i_mdbs-matnr.
    i_main-werks = i_mdbs-werks.
    i_main-grsto = i_mdbs-wemng.
    i_main-totpo = i_mdbs-menge.
    READ TABLE i_werks WITH KEY werks = i_main-werks BINARY SEARCH.
    i_main-name1 = i_werks-name1.
    CASE i_mdbs-bsart.
      WHEN 'UB'.
        IF i_main-werks = '0200'.
        ELSE.
*          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
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
*          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnsto = i_mdbs-menge.
          i_main-opnpo = i_mdbs-menge - i_mdbs-wemng.
        ELSE.
*          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnpo = i_mdbs-menge - i_mdbs-glmng.
        ENDIF.
      WHEN 'ZSUT'.
        IF i_main-werks = '0200'.
*          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnsto = i_mdbs-menge.
          i_main-opnpo = i_mdbs-menge - i_mdbs-wemng.
        ELSE.
*          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
          i_main-opnpo = i_mdbs-menge - i_mdbs-glmng.
        ENDIF.
      WHEN 'ZRL'.
        IF i_main-werks = '0200'.
        ELSE.
*          i_main-intrs = i_mdbs-wamng - i_mdbs-wemng.
*          i_main-opnsto = i_mdbs-menge - i_mdbs-wamng.
*          i_main-opnsto1 = i_mdbs-menge.
          i_main-opnpo = i_mdbs-menge - i_mdbs-wamng.
        ENDIF.
    ENDCASE.

    CLEAR: l_lgort,i_tvkol.
    IF i_mdbs-lgort IS INITIAL.
      l_lgort = '1000'.
    ELSE.
      CONCATENATE i_mdbs-lgort(2) '00' INTO l_lgort.
    ENDIF.

    IF l_lgort(1) = '1'.
      l_lgort = '1000'.
    ENDIF.

    READ TABLE i_tvkol WITH KEY werks = i_mdbs-werks
                                lgort = l_lgort BINARY SEARCH.
    IF sy-subrc = 0.
      i_main-vkbur = i_tvkol-vstel.
      i_main-lgort = l_lgort.
    ELSE.
      READ TABLE i_tvkol WITH KEY werks = i_mdbs-werks
      BINARY SEARCH.
      i_main-vkbur = i_tvkol-vstel.
      i_main-lgort = i_tvkol-lgort.
    ENDIF.
    READ TABLE i_vkbur WITH KEY vkbur = i_main-vkbur BINARY SEARCH.
    i_main-bezei = i_vkbur-bezei.

    COLLECT i_main. CLEAR i_main.
    d_ebeln = i_mdbs-ebeln.
    COLLECT d_ebeln INTO t_ebeln.
  ENDLOOP.

*  PERFORM f_opening_stock TABLES lt_x039
*                          USING 'CALC'.

  DELETE i_s039 WHERE mbwbest = 0 AND lgort <> '1000'
                  AND lgort <> '2000' AND lgort <> '2100'
                  AND lgort <> '2200' AND lgort <> '2300'.
  IF p_incuns = ''.
    DELETE i_s039 WHERE lgort = '10U0'.
  ENDIF.

  LOOP AT i_s933s.
    IF i_s933s-lgort(1) = '1'.
      i_s933s-lgort = '1000'.
    ENDIF.
    COLLECT i_s933s INTO i_s933x.
  ENDLOOP.
  i_s933s[] = i_s933x[].

** Collect From S039
  LOOP AT i_s039.
    CLEAR i_main.
    IF p_incuns = '' AND i_s039-lgort+2(1) = 'U'. "Unsaleable
      CONTINUE.
    ENDIF.
    READ TABLE i_makt WITH KEY matnr = i_s039-matnr BINARY SEARCH.
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
    i_main-nfmat = i_makt-nfmat.
    i_main-kzaus = i_makt-kzaus.
    i_main-meins = i_makt-meins.
    i_main-zeiar = i_makt-zeiar.
    i_main-matnr = i_s039-matnr.
    i_main-werks = i_s039-werks.
    READ TABLE i_werks WITH KEY werks = i_main-werks BINARY SEARCH.
    i_main-name1 = i_werks-name1.
*    i_main-stkls = i_s039-gsbest.
    i_main-stkls = i_s039-mbwbest.

    CLEAR: l_lgort,i_tvkol.
    IF i_s039-lgort IS INITIAL.
* Intransit data -> request by ETP to breakdown to Sales Office
*       and i_s039-werks+2(2) <> '00'. "not DC
      CONTINUE.
      l_lgort = '1000'.
    ELSE.
      CONCATENATE i_s039-lgort(2) '00' INTO l_lgort.
    ENDIF.

    IF l_lgort(1) = '1'.
      l_lgort = '1000'.
    ENDIF.

    READ TABLE i_tvkol WITH KEY werks = i_s039-werks
                                lgort = l_lgort BINARY SEARCH.
    IF sy-subrc = 0.
      i_main-vkbur = i_tvkol-vstel.
      i_main-lgort = l_lgort.
*      break mmfm.
      IF l_lgort <> '1000'. "Check if stock point already live with SAP
        READ TABLE i_tvkol WITH KEY werks = i_main-vkbur
                                    lgort = '1000' BINARY SEARCH.
        IF sy-subrc = 0.
          i_main-werks = i_tvkol-vstel.
          i_main-vkbur = i_tvkol-vstel.
          i_main-lgort = '1000'.
          READ TABLE i_werks WITH KEY werks = i_main-werks BINARY SEARCH.
          i_main-name1 = i_werks-name1.
        ENDIF.
      ENDIF.
    ELSE. "In case vstel for lgort not found, get from plant
      READ TABLE i_tvkol WITH KEY werks = i_s039-werks
      BINARY SEARCH.
      i_main-vkbur = i_tvkol-vstel.
      i_main-lgort = i_tvkol-lgort.
    ENDIF.
    READ TABLE i_vkbur WITH KEY vkbur = i_main-vkbur BINARY SEARCH.
    i_main-bezei = i_vkbur-bezei.

    CLEAR: i_s933s, i_march, i_marc.
    IF p_incsut = '' AND
       i_s039-werks = '0201' AND i_s039-lgort IN lr_lgort.
    ELSE.
      READ TABLE i_s933s WITH KEY matnr = i_s039-matnr
                                  werks = i_s039-werks
                                  lgort = i_s039-lgort
      BINARY SEARCH.
    ENDIF.
* Only main branch
    IF i_s039-lgort = '1000'.
      READ TABLE i_march WITH KEY matnr = i_s039-matnr
                                  werks = i_s039-werks
                                  lfgja = v_lfgja
                                  lfmon = v_lfmon
      BINARY SEARCH.
      IF sy-subrc <> 0.
        READ TABLE i_marc WITH KEY matnr = i_s039-matnr
                                   werks = i_s039-werks
*                               lfgja = v_lfgja
*                               lfmon = v_lfmon
        BINARY SEARCH.
        IF ( i_marc-lfgja = v_lfgja AND i_marc-lfmon <= v_lfmon ) OR
           ( i_marc-lfgja < v_lfgja ).
        ELSE.
          CLEAR i_marc.
        ENDIF.
      ENDIF.
    ENDIF.

    i_main-stkls = i_main-stkls + i_s933s-menge "in transit
                                + i_march-umlmc "st transfer hist
                                + i_marc-umlmc. "st transfer

    COLLECT i_main. CLEAR i_main.
  ENDLOOP.

*  DELETE i_main where stkls = 0.
  SORT i_tvkol BY vstel.
* Collect From S603 - exclude SUT
  LOOP AT i_s603 INTO i_s603.
    READ TABLE i_makt WITH KEY matnr = i_s603-matnr BINARY SEARCH.
    IF sy-subrc NE 0.
      CONTINUE.
    ENDIF.
    i_main-matkl = i_makt-matkl.
    i_main-maktx = i_makt-maktx.
    i_main-nfmat = i_makt-nfmat.
    i_main-kzaus = i_makt-kzaus.
    i_main-meins = i_makt-meins.
    i_main-zeiar = i_makt-zeiar.
    i_main-matnr = i_s603-matnr.
    i_main-werks = i_s603-vkbur.
    READ TABLE i_werks WITH KEY werks = i_main-werks BINARY SEARCH.
    i_main-name1 = i_werks-name1.
    i_main-sales = ( i_s603-ummenge + i_s603-gumenge ) * -1.

    CLEAR: l_lgort,i_tvkol.
    READ TABLE i_tvkol WITH KEY vstel = i_s603-vkbur
    BINARY SEARCH.
    i_main-vkbur = i_tvkol-vstel.
    i_main-lgort = i_tvkol-lgort.

    IF i_main-lgort(1) = '1'.
      i_main-lgort = '1000'.
    ENDIF.

    READ TABLE i_vkbur WITH KEY vkbur = i_main-vkbur BINARY SEARCH.
    i_main-bezei = i_vkbur-bezei.

    COLLECT i_main. CLEAR i_main.
  ENDLOOP.

** Completed i_main
  SORT i_mat_b2b BY matnr.
  SORT i_main BY matnr werks vkbur.
  LOOP AT i_main.

    IF i_main-werks = '0200'.
      l_tabix = sy-tabix.
      lw_main = i_main.
    ELSE.
      ADD i_main-opnsto1 TO l_opnsto.
    ENDIF.

    READ TABLE i_marc WITH KEY matnr = i_main-matnr
                               werks = i_main-werks
    BINARY SEARCH.
    IF sy-subrc = 0.
      i_main-stdrt   = i_marc-kausf.
      i_main-maabc   = i_marc-maabc.

      READ TABLE i_mard WITH KEY matnr = i_main-matnr
                                 werks = i_main-werks
                                 lgort = i_main-lgort
      BINARY SEARCH.
      IF sy-subrc = 0.
        IF i_mard-exppg IS NOT INITIAL.
          i_main-maabc = i_mard-exppg.
        ENDIF.
      ENDIF.
*      lw_main-maabc  = i_marc-maabc.
    ENDIF.

    READ TABLE i_mat_b2b WITH KEY matnr = i_main-matnr
                         BINARY SEARCH TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      i_main-flg1 = 'X'.
      lw_main-flg1 = 'X'.
    ELSE.
      CLEAR: i_main-flg1, lw_main-flg1.
    ENDIF.

    MODIFY i_main TRANSPORTING stdrt flg1 maabc.


    IF i_main-werks = i_main-vkbur. "Only for main branch
*      READ TABLE i_s912cmsum WITH KEY matnr = i_main-matnr
*                                      werks = i_main-werks
*      BINARY SEARCH.
*      IF sy-subrc = 0.
*        i_main-tacm = i_s912cmsum-ktmng.
*      ENDIF.
*
*      READ TABLE i_s912nmsum WITH KEY matnr = i_main-matnr
*                                      werks = i_main-werks
*      BINARY SEARCH.
*      IF sy-subrc = 0.
*        i_main-tanm = i_s912nmsum-ktmng.
*      ENDIF.

*      IF i_s912-zavg_sls NE 0.
*        i_main-actrt =  i_main-stkls / i_s912-zavg_sls.
*        i_main-actrt1 =  i_main-stkcr / i_s912-zavg_sls.
*      ENDIF.

*      MODIFY i_main TRANSPORTING avrsl actrt actrt1 tacm tanm.
      MODIFY i_main TRANSPORTING tacm tanm.
    ENDIF.

    IF p_incsut = '' AND
       i_main-werks = '0201' AND i_main-lgort IN lr_lgort.
    ELSE.
      READ TABLE i_s933t WITH KEY matnr = i_main-matnr
                                  werks = i_main-werks
                                  lgort = i_main-lgort
      BINARY SEARCH
      TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        CLEAR lv_menge.
        LOOP AT i_s933t WHERE matnr = i_main-matnr
                          AND werks = i_main-werks
                          AND lgort = i_main-lgort.
          ADD i_s933t-menge TO lv_menge.
        ENDLOOP.
        i_main-intrs = lv_menge.

        "ADD condition for Intransit    20.10.2023
        IF i_s933int[] IS NOT INITIAL.
          CLEAR lv_menge.
          SORT i_s933int BY matnr werks.
          LOOP AT i_s933int WHERE matnr = i_main-matnr
                             AND werks = i_main-werks.
            ADD i_s933int-menge TO lv_menge.
          ENDLOOP.
          ADD lv_menge TO i_main-intrs.
        ENDIF.

        MODIFY i_main TRANSPORTING intrs.

      ELSE.
        IF i_s933int[] IS NOT INITIAL.
          CLEAR lv_menge.
          SORT i_s933int BY matnr werks.
          LOOP AT i_s933int WHERE matnr = i_main-matnr
                              AND werks = i_main-werks.
            ADD i_s933int-menge TO lv_menge.
          ENDLOOP.
          ADD lv_menge TO i_main-intrs.
        ENDIF.
        MODIFY i_main TRANSPORTING intrs.
      ENDIF.
    ENDIF.
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
  DELETE i_main WHERE vkbur NOT IN s_vkbur.

*  PERFORM f_opening_stock TABLES lt_x039
*                          USING 'MODIFY'.

* Get data Customer PO & OOS
  IF p_spmon = sy-datum(6). " Only for current month
    SELECT vkbur matnr poqty oosqty waers oosval INTO TABLE i_po_oos FROM zmm_po_oos.
*    SELECT vkbur matnr poqty oosqty INTO TABLE i_po_oos FROM zmm_po_oos.
  ENDIF.
  SORT i_po_oos BY vkbur matnr.
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
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      =
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = d_repid
*     i_callback_pf_status_set       = 'F_SET_PF_STATUS'
      i_callback_user_command = 'F_USER_COMMAND'
*     I_STRUCTURE_NAME        =
      i_grid_title            = title
      is_layout               = d_layout
      it_fieldcat             = t_alv_fieldcat[]
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
      it_sort                 = t_alv_isort[]
*     IT_FILTER               =
*     IS_SEL_HIDE             =
      i_default               = 'X'
      i_save                  = 'A'
      is_variant              = d_alv_variant
      it_events               = t_alv_event[]
      it_event_exit           = t_event_exit[]
      is_print                = d_print
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = i_main
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
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
      title            = TEXT-011
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
  TYPES : BEGIN OF t_dwn_field,
            txt_field(10),
          END OF t_dwn_field.
  DATA: canc(1),
        size         TYPE i,
        dwn_field    TYPE t_dwn_field OCCURS 0,
        wa_dwn_field TYPE t_dwn_field,
        filename     TYPE rlgrap-filename,
        wa_main      LIKE i_main,
        sw.

  DATA count TYPE i.

*Begin insert Unicode conversion - DEVK965577
*26.02.2020 - SOL_FELIX
  DATA: lv_p_filenm TYPE string,
        lv_filename TYPE string.
  CLEAR: lv_p_filenm, lv_filename.
  lv_p_filenm = p_filenm.
*End insert Unicode conversion - DEVK965577

  CLEAR count.
  DO 30 TIMES.
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
        wa_dwn_field-txt_field = 'Sloc'.
      WHEN '8'.
        wa_dwn_field-txt_field = 'SlOff'.
      WHEN '9'.
        wa_dwn_field-txt_field = 'SlOff Name'.
      WHEN '10'.
        wa_dwn_field-txt_field = 'Curr. Stock'.
      WHEN '11'.
        wa_dwn_field-txt_field = 'Intransit'.
      WHEN '12'.
        wa_dwn_field-txt_field = 'Open PO/STO'.
      WHEN '13'.
        wa_dwn_field-txt_field = 'DN'.
      WHEN '14'.
        wa_dwn_field-txt_field = 'Tot. PO/STO'.
      WHEN '15'.
        wa_dwn_field-txt_field = ''.
      WHEN '16'.
        wa_dwn_field-txt_field = 'GR PO/STO'.
      WHEN '17'.
        wa_dwn_field-txt_field = 'Opng Stock'.
      WHEN '18'.
        wa_dwn_field-txt_field = 'Av. Sales'.
      WHEN '19'.
        wa_dwn_field-txt_field = 'Std T'.
      WHEN '20'.
        wa_dwn_field-txt_field = 'Opng. T'.
      WHEN '21'.
        wa_dwn_field-txt_field = 'Curr. T'.
      WHEN '22'.
        wa_dwn_field-txt_field = 'Sales MTD'.
      WHEN '23'.
        wa_dwn_field-txt_field = ''.
      WHEN '24'.
        wa_dwn_field-txt_field = 'Tot Allo Curr. Month'.
      WHEN '25'.
        wa_dwn_field-txt_field = 'Tot Allo Next Month'.
      WHEN '26'.
        wa_dwn_field-txt_field = 'Sales M-1'.
      WHEN '27'.
        wa_dwn_field-txt_field = 'Sales M-2'.
      WHEN '28'.
        wa_dwn_field-txt_field = 'Sales M-3'.
      WHEN '29'.
        wa_dwn_field-txt_field = 'Sales M-4'.
      WHEN '30'.
        wa_dwn_field-txt_field = 'Sales M-5'.
      WHEN '31'.
        wa_dwn_field-txt_field = 'Sales M-6'.
    ENDCASE.
    APPEND wa_dwn_field TO dwn_field.
  ENDDO.

  SORT i_main BY werks matnr.
  sw = ''.
  LOOP AT i_main INTO i_main.
    ON CHANGE OF i_main-werks.

*Begin remark Unicode conversion - DEVK965577
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
*End remark Unicode conversion - DEVK965577
*Begin insert Unicode conversion - DEVK965577
*26.02.2020 - SOL_FELIX
      IF sw = 'X'.
*    CALL FUNCTION 'DOWNLOAD'
        CALL METHOD cl_gui_frontend_services=>gui_download
          EXPORTING
            filename   = lv_filename
            filetype   = 'DBF'
            fieldnames = dwn_field
          CHANGING
            data_tab   = i_original[].
        REFRESH i_original.
      ELSE.
        sw = 'X'.
      ENDIF.
    ENDON.
    i_original = i_main.
    APPEND i_original.
    CONCATENATE lv_p_filenm 'Alokasi ' i_main-werks
             '.xls' INTO lv_filename.
*End insert Unicode conversion - DEVK965577
  ENDLOOP.

*Begin remark Unicode conversion - DEVK965577
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
*End remark Unicode conversion - DEVK965577
*Begin insert Unicode conversion - DEVK965577
*26.02.2020 - SOL_FELIX
  CALL METHOD cl_gui_frontend_services=>gui_download
    EXPORTING
      filename                = lv_filename
      filetype                = 'DBF'
      fieldnames              = dwn_field
    CHANGING
      data_tab                = i_original[]
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      not_supported_by_gui    = 22
      error_no_gui            = 23
      OTHERS                  = 24.
  IF sy-subrc <> 0.
*   MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
*End insert Unicode conversion - DEVK965577
ENDFORM.                    " f_download_local

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_SAC7
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_get_data_sac7 .
  DATA: ld_x1	      TYPE mc_ummenge,
        ld_x2	      TYPE mc_ummenge,
        ld_x3	      TYPE mc_ummenge,
        ld_x4	      TYPE mc_ummenge,
        ld_x5	      TYPE mc_ummenge,
        ld_x6	      TYPE mc_ummenge,
        ld_avqty    TYPE mc_ummenge,
        ld_tabix    TYPE sytabix,
        ld_sales    TYPE mc_ummenge,
        ld_filename	TYPE localfile,
        ld_date     TYPE datum,
        ld_dnqty    TYPE s619-lfimg,
        ld_dnval    TYPE zsac7_tmp-avamt.

  DATA : lv_char(1500).

  SORT i_main BY vkbur werks matnr.
  IF p_spmon = sy-datum(6).
    CONCATENATE pa_path sy-datum '.txt' INTO ld_filename.
  ELSE.
    CONCATENATE pa_path 'Monthly/' p_spmon '.txt' INTO ld_filename.
  ENDIF.

*  CALL METHOD zcl_util=>m_open_dataset
  CALL METHOD zcl_sac7=>m_open_dataset
    EXPORTING
      param_name = ld_filename
    IMPORTING
      t_return   = gt_string.

  IF gt_string[] IS INITIAL.
    ld_date = sy-datum.
    ld_date+6(2) = '01'.
    ld_date = ld_date - 1.
    CONCATENATE pa_path ld_date '.txt' INTO ld_filename.
*    CALL METHOD zcl_util=>m_open_dataset
    CALL METHOD zcl_sac7=>m_open_dataset
      EXPORTING
        param_name = ld_filename
      IMPORTING
        t_return   = gt_string.
  ENDIF.

  IF sy-subrc = 0.
    LOOP AT gt_string INTO gs_string.
      gs_dataset = gs_string-string.
      IF gs_dataset-matnr NOT IN s_matnr AND s_matnr[] IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      CLEAR: ld_x1,ld_x2,ld_x3,ld_x4,ld_x5,ld_x6,ld_avqty,ld_dnqty,ld_dnval,ld_tabix.
      ld_x1 = gs_dataset-x1.
      ld_x2 = gs_dataset-x2.
      ld_x3 = gs_dataset-x3.
      ld_x4 = gs_dataset-x4.
      ld_x5 = gs_dataset-x5.
      ld_x6 = gs_dataset-x6.
      ld_sales = gs_dataset-ummenge + gs_dataset-gumenge.
      ld_avqty = gs_dataset-avqty.
      ld_dnqty = gs_dataset-dnqty.

      lv_char  = gs_dataset-dnval.
      CALL METHOD zcl_util=>m_replace_eol_flag
        EXPORTING
          pvi_char = lv_char
        IMPORTING
          pvo_char = lv_char.
      ld_dnval = lv_char.

      CLEAR ld_tabix.
      READ TABLE i_main WITH KEY vkbur = gs_dataset-vkbur
                                 werks = gs_dataset-werks
                                 matnr = gs_dataset-matnr
      BINARY SEARCH.
      IF sy-subrc <> 0.
        READ TABLE i_main WITH KEY vkbur = gs_dataset-vkbur
                                   matnr = gs_dataset-matnr
        BINARY SEARCH.
        IF sy-subrc = 0.
          ld_tabix = sy-tabix.
        ENDIF.
      ELSE.
        ld_tabix = sy-tabix.
      ENDIF.

      IF ld_tabix IS NOT INITIAL.
*        PERFORM f_modify_itab_xn USING i_main
*                                       ld_x1 ld_x2 ld_x3 ld_x4
*                                       ld_x5 ld_x6 ld_avqty ld_tabix.

        i_main-x1 = i_main-x1 + ld_x1.
        i_main-x2 = i_main-x2 + ld_x2.
        i_main-x3 = i_main-x3 + ld_x3.
        i_main-x4 = i_main-x4 + ld_x4.
        i_main-x5 = i_main-x5 + ld_x5.
        i_main-x6 = i_main-x6 + ld_x6.
        i_main-sales = ld_sales.
        i_main-avrsl = ld_avqty.
        i_main-avrslutd = i_main-avrsl. "transfer value
        i_main-dnqty = ld_dnqty.
        i_main-dnval = ld_dnval.
        i_main-avrfc = ( i_main-m0 + i_main-m1 + i_main-m2 +
                         i_main-x1 + i_main-x2 + i_main-x3 ) / 6.
        IF i_main-avrsl <> 0.
          i_main-actrt  = i_main-stkls / i_main-avrsl.
          i_main-actrt1 = i_main-stkcr / i_main-avrsl.
        ELSE.
          i_main-actrt  = 0.
*          i_main-actrt1 = 0.
          i_main-actrt1 = i_main-stkcr.
        ENDIF.
        MODIFY i_main INDEX ld_tabix FROM i_main
        TRANSPORTING x1 x2 x3 x4 x5 x6 sales avrsl avrslutd dnqty dnval actrt actrt1 avrfc.
*      ELSE.
*        SORT i_main BY vkbur matnr.
*        READ TABLE i_main WITH KEY vkbur = gs_dataset-vkbur
*                                   matnr = gs_dataset-matnr
*        BINARY SEARCH.
*        IF sy-subrc = 0.
*          ld_tabix = sy-tabix.
*          PERFORM f_modify_itab_xn USING i_main
*                                         ld_x1 ld_x2 ld_x3 ld_x4
*                                         ld_x5 ld_x6 ld_tabix.
*        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_DATA_SAC7

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_ITAB_XN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_modify_itab_xn  USING    fu_main STRUCTURE i_main
                                fu_x1
                                fu_x2
                                fu_x3
                                fu_x4
                                fu_x5
                                fu_x6
                                fu_avqty
                                fu_tabix.
  fu_main-x1 = fu_main-x1 + fu_x1.
  fu_main-x2 = fu_main-x2 + fu_x2.
  fu_main-x3 = fu_main-x3 + fu_x3.
  fu_main-x4 = fu_main-x4 + fu_x4.
  fu_main-x5 = fu_main-x5 + fu_x5.
  fu_main-x6 = fu_main-x6 + fu_x6.
  fu_main-avrsl = fu_avqty.
  IF fu_main-avrsl <> 0.
    fu_main-actrt  = fu_main-stkls / fu_main-avrsl.
    fu_main-actrt1 = fu_main-stkcr / fu_main-avrsl.
  ELSE.
    fu_main-actrt  = 0.
    fu_main-actrt1 = 0.
  ENDIF.
  MODIFY i_main INDEX fu_tabix FROM fu_main
  TRANSPORTING x1 x2 x3 x4 x5 x6 avrsl actrt actrt1.
ENDFORM.                    " F_MODIFY_ITAB_XN

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_SAC7_UNITED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_get_data_sac7_united .
  DATA: ld_tabix    TYPE sytabix,
        ld_filename	TYPE localfile,
        ld_path(52),
        ld_date     TYPE datum,
        ld_spmon    TYPE spmon,
        ld_year     TYPE i,
        ld_avrg     TYPE mc_ummenge.

  DATA : BEGIN OF lt_mard OCCURS 0,
           matnr LIKE  mard-matnr,
           werks LIKE  mard-werks,
           lgort LIKE  mard-lgort,
           labst LIKE  mard-labst,
           insme LIKE  mard-insme,
           speme LIKE  mard-speme,
           exppg LIKE  mard-exppg,
         END OF lt_mard.

  DATA: BEGIN OF i_s801 OCCURS 0.
          INCLUDE STRUCTURE s801.
        DATA: END OF i_s801.

  DATA: BEGIN OF lt_marm OCCURS 0.
          INCLUDE STRUCTURE marm.
        DATA: END OF lt_marm,
        l_spmon  LIKE  s039-spmon,
        lt_tvkol TYPE TABLE OF tvkol WITH HEADER LINE.

  DATA : lv_lines   TYPE i.

  "Get Plant SUT
  SELECT * INTO TABLE i_zplbc
    FROM zplbc WHERE reswk NE space
     AND bukrs = '8070'.

  IF p_united = 'X'.
    SELECT matnr mard~werks mard~lgort labst insme speme exppg
      INTO CORRESPONDING FIELDS OF TABLE lt_mard
      FROM mard
      JOIN zplbc
        ON mard~werks = zplbc~werks
      WHERE matnr IN s_matnr  AND
            reswk IN s_werks  AND
            mard~lgort IN gr_lgort.
*          ( mard~lgort NE '10D0' AND mard~lgort NE '10U0' ).

    SELECT * INTO CORRESPONDING FIELDS OF TABLE lt_tvkol
      FROM tvkol
      JOIN zplbc
        ON tvkol~werks = zplbc~werks
      WHERE reswk IN s_werks
        AND legacy_branch <> ''.

    SORT lt_tvkol BY werks lgort.
    SORT lt_mard  BY werks lgort.
    PERFORM get_forecast TABLES lt_mard
                                lt_marm
                                lt_tvkol
                                i_s801
                         USING  p_spmon.
    SORT i_s801 BY matnr vkbur spmon.
  ENDIF.

  "Get server path
  IF p_spmon = sy-datum(6).
    "Start Delete SOH Adj.
*    IF sy-opsys = 'AIX'.
*      ld_path = '/interface/SAC7/sut/'.
*    ELSE.
*      ld_path = '\\tdsdev01\interface\SAC7\sut\'.
*    ENDIF.
    "End Delete SOH Adj.
    ld_path = '/interface/SAC7/sut/'.
    CONCATENATE ld_path sy-datum '_N.txt' INTO ld_filename.
  ELSE.
    "Start Delete SOH Adj.
*    IF sy-opsys = 'AIX'.
*      ld_path = '/interface/SAC7/sut/monthly/'.
*    ELSE.
*      ld_path = '\\tdsdev01\interface\SAC7\sut\monthly\'.
*    ENDIF.
    "End Delete SOH Adj.
    ld_path = '/interface/SAC7/sut/monthly/'.
    CONCATENATE ld_path p_spmon '_N.txt' INTO ld_filename.
  ENDIF.

  " Get last month
*  CONCATENATE p_spmon '01' INTO ld_date.
*  SUBTRACT 1 FROM ld_date.
*  ld_spmon = ld_date(6).

  "Get textfile
  CLEAR: gs_dataset,gs_string,gt_string,gt_string[].
*  CONCATENATE ld_path ld_spmon '_N.txt' INTO ld_filename.

*  CALL METHOD zcl_util=>m_open_dataset
  CALL METHOD zcl_sac7=>m_open_dataset
    EXPORTING
      param_name = ld_filename
    IMPORTING
      t_return   = gt_string.

  IF sy-subrc = 0.
    SORT: i_main BY vkbur matnr,
          i_zplbc BY bukrs werks.

    IF p_united = 'X'.
      PERFORM f_add_itab TABLES lt_mard.
    ENDIF.

    LOOP AT gt_string INTO gs_string.
      CLEAR: i_zplbc,i_main,ld_tabix.
      i_dataset = gs_string-string.

      IF i_dataset-matnr NOT IN s_matnr." AND s_matnr[] IS NOT INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE i_zplbc WITH KEY bukrs = '8070'
                                  werks = i_dataset-werks BINARY SEARCH.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.

      READ TABLE i_main WITH KEY vkbur = i_zplbc-reswk
                                 matnr = i_dataset-matnr BINARY SEARCH.
      IF sy-subrc NE 0.
        CONTINUE.
      ENDIF.
      ld_tabix = sy-tabix.

      PERFORM f_cek_aix.
      i_dataset-werks = i_zplbc-reswk.
      MOVE-CORRESPONDING i_dataset TO i_outpl.

      IF p_united = 'X'.
        CLEAR i_s801.
        READ TABLE i_s801 WITH KEY matnr = i_main-matnr
                                   vkbur = i_zplbc-werks
                                   spmon = p_spmon
        BINARY SEARCH.
        i_main-m0 = i_main-m0 + i_s801-aftsqty.

        l_spmon = p_spmon + 1.
        IF l_spmon+4(2) = '13'.
          l_spmon+4(2) = '01'.
          l_spmon(4) = l_spmon(4) + 1.
        ENDIF.
        CLEAR i_s801.
        READ TABLE i_s801 WITH KEY matnr = i_main-matnr
                                   vkbur = i_zplbc-werks
                                   spmon = l_spmon
        BINARY SEARCH.
        i_main-m1 = i_main-m1 + i_s801-aftsqty.

        l_spmon = l_spmon + 1.
        IF l_spmon+4(2) = '13'.
          l_spmon+4(2) = '01'.
          l_spmon(4) = l_spmon(4) + 1.
        ENDIF.
        CLEAR i_s801.
        READ TABLE i_s801 WITH KEY matnr = i_main-matnr
                                   vkbur = i_zplbc-werks
                                   spmon = l_spmon
        BINARY SEARCH.
        i_main-m2 = i_main-m2 + i_s801-aftsqty.

        i_main-x1 = i_main-x1 + i_outpl-x1.
        i_main-x2 = i_main-x2 + i_outpl-x2.
        i_main-x3 = i_main-x3 + i_outpl-x3.
        i_main-x4 = i_main-x4 + i_outpl-x4.
        i_main-x5 = i_main-x5 + i_outpl-x5.
        i_main-x6 = i_main-x6 + i_outpl-x6.
        i_outpl-avqty = i_main-avrsl + i_outpl-avqty.
        IF i_main-avrsl <> 0 AND i_outpl-avqty <> 0.
          i_main-actrt  = i_main-stkls / i_outpl-avqty.
          i_main-actrt1 = i_main-stkcr / i_outpl-avqty.
        ELSE.
          i_main-actrt  = 0.
*          i_main-actrt1 = 0.
          i_main-actrt1 = i_main-stkcr.
        ENDIF.
      ENDIF.

      i_outpl-avamt = i_outpl-avqty * i_outpl-nsp.
      i_main-avrslutd = i_outpl-avqty.

      MODIFY i_main INDEX ld_tabix FROM i_main
      TRANSPORTING avrslutd actrt actrt1 x1 x2 x3 x4 x5 x6 m0 m1 m2.
    ENDLOOP.
  ENDIF.

  DATA : p_cov TYPE tvarvc-low.
  SELECT SINGLE low INTO p_cov
     FROM tvarvc WHERE name = 'ZMM_ZM68N_SLOB_COV'.
  IF p_cov = 0.
    p_cov = 1.
  ENDIF.

  SORT i_makt BY nfmat.
  LOOP AT i_main.
    IF p_spmon = sy-datum(6).
      READ TABLE i_po_oos WITH KEY vkbur = i_main-vkbur
                                   matnr = i_main-matnr
      BINARY SEARCH.
      IF sy-subrc = 0.
        i_main-poqty  = i_po_oos-poqty.
        i_main-oosqty = i_po_oos-oosqty.
        i_main-peroos = i_main-oosqty * 100 / i_main-poqty.
        i_main-waers  = i_po_oos-waers.
        i_main-oosval = i_po_oos-oosval.
      ENDIF.
    ENDIF.
    READ TABLE i_makt WITH KEY nfmat = i_main-matnr
    BINARY SEARCH.
    IF sy-subrc = 0.
      i_main-olmat  = i_makt-matnr.
    ENDIF.
    READ TABLE i_marm WITH KEY matnr = i_main-matnr
                               meinh = 'KAR'
    BINARY SEARCH.
    IF sy-subrc = 0.
      i_main-karton = i_marm-umrez / i_marm-umren.
    ENDIF.
    IF i_main-vkbur <> '0200'.
      CLEAR ld_avrg.
      ld_avrg = ( i_main-m0 + i_main-m1 + i_main-m2 + i_main-x1 + i_main-x2 + i_main-x3 ) * p_cov / 6 .
      IF ld_avrg < 0.
        ld_avrg = 0.
      ENDIF.
      i_main-slobop = i_main-stkls - ld_avrg.
      IF i_main-slobop < 0.
        i_main-slobop = 0.
      ENDIF.
      i_main-slobcr = i_main-stkcr + i_main-intrs - ld_avrg.
      IF i_main-slobcr < 0.
        i_main-slobcr = 0.
      ENDIF.
    ENDIF.

    SORT i_nsp BY matnr kbetr DESCENDING.
    READ TABLE i_nsp WITH KEY matnr = i_main-matnr BINARY SEARCH.
    IF sy-subrc = 0.
      i_main-nsp = i_nsp-kbetr.
    ENDIF.

    MODIFY i_main FROM i_main
    TRANSPORTING poqty oosqty peroos olmat slobop slobcr karton nsp waers oosval.
*    TRANSPORTING poqty oosqty peroos olmat slobop slobcr karton nsp.
    IF p_spmon = sy-datum(6).
      CLEAR i_main-dnqty.
      READ TABLE i_s931 WITH KEY matnr = i_main-matnr
                                 werks = i_main-werks
                                 lgort = i_main-lgort
      BINARY SEARCH.
      IF sy-subrc = 0.
        i_main-dnqty = i_s931-menge.
      ENDIF.
      MODIFY i_main FROM i_main TRANSPORTING dnqty.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_DATA_SAC7_UNITED

*&---------------------------------------------------------------------*
*&      Form  F_CEK_AIX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_cek_aix .
*  IF sy-opsys = 'AIX'.
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
*  ENDIF.
ENDFORM.                    " F_CEK_AIX
*&---------------------------------------------------------------------*
*&      Form  GET_INTRANSIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_T_S933S  text
*----------------------------------------------------------------------*
FORM get_intransit  TABLES  t_marc
                            p_t_s933s
                    USING   p_spmon LIKE s933-spmon.
  DATA: BEGIN OF t_s933 OCCURS 0,
          reswk LIKE ekko-reswk,
          bsart LIKE ekko-bsart,
          matnr LIKE s933-matnr,
          spmon LIKE s933-spmon,
          werks LIKE s933-werks,
          lgort LIKE s933-lgort,
          charg LIKE s933-charg,
          mblnr LIKE s933-mblnr,
          budat LIKE s933-budat,
          menge LIKE s933-menge,
          bwart LIKE s933-bwart,
          bedat LIKE s933-budat,
        END OF t_s933.

  DATA: BEGIN OF t_s933s OCCURS 0,
*          spmon LIKE s933-spmon,
          matnr LIKE s933-matnr,
          werks LIKE s933-werks,
          lgort LIKE s933-lgort,
          menge LIKE s933-menge,
*          bwart LIKE s933-bwart,
        END OF t_s933s.

  DATA: BEGIN OF t_reswk OCCURS 0,
          reswk LIKE ekko-reswk,
          bsart LIKE ekko-bsart,
          matnr LIKE s933-matnr,
        END OF t_reswk.

  DATA : BEGIN OF t_marc2 OCCURS 0,
           matnr LIKE  marc-matnr,
           werks LIKE  marc-werks,
           spmon LIKE  s933-spmon,
         END OF t_marc2.

  DATA: p_month  TYPE spmon.

  DATA: BEGIN OF t_x933 OCCURS 0,
          reswk LIKE ekko-reswk,
          bsart LIKE ekko-bsart,
          matnr LIKE s933-matnr,
          spmon LIKE s933-spmon,
          werks LIKE s933-werks,
          lgort LIKE s933-lgort,
          charg LIKE s933-charg,
          mblnr LIKE s933-mblnr,
          budat LIKE s933-budat,
          menge LIKE s933-menge,
          bwart LIKE s933-bwart,
          bedat LIKE s933-budat,
        END OF t_x933.


  LOOP AT t_marc.
    MOVE-CORRESPONDING t_marc TO t_marc2.
    p_month = p_spmon.
    DO 4 TIMES.
      p_month = p_month - 1.
      IF p_month+4(2) = 0.
        p_month+4(2) = 12.
        p_month(4) =  p_month(4) - 1.
      ENDIF.
      t_marc2-spmon = p_month.
      APPEND t_marc2.
    ENDDO.
  ENDLOOP.

  SELECT ekko~reswk ekko~bsart spmon s933~werks s933~matnr
         bwart charg mblnr budat ekpo~lgort s933~menge ekko~bedat
    FROM s933
    JOIN ekko ON ekko~ebeln = s933~ebeln
    JOIN ekpo ON ekpo~ebeln = s933~ebeln AND
                 ekpo~ebelp = s933~ebelp
    APPENDING CORRESPONDING FIELDS OF TABLE t_s933
     FOR ALL ENTRIES IN t_marc2
   WHERE spmon      = t_marc2-spmon
     AND s933~matnr = t_marc2-matnr
     AND s933~werks = t_marc2-werks
     AND bwart IN ('101', '102', '641', '642', '351', '352')
     AND ekko~bsart IN ('ZB', 'ZICO', 'UB', 'ZRL').

  DELETE : t_s933 WHERE bwart = '101' AND menge < 0,
           t_s933 WHERE bwart = '102' AND menge > 0.

  t_x933[] = t_s933[].
  DELETE t_x933 WHERE bwart <> '351' AND bwart <> '352'.
  DELETE t_s933[] WHERE bwart = '351' OR bwart = '352'.
  LOOP AT t_x933.
    IF t_x933-werks <> t_x933-reswk.
      APPEND t_x933 TO t_s933.
    ENDIF.
  ENDLOOP.

*****  LOOP AT t_s933 WHERE ( bwart = '351' OR bwart = '352' ).
*****    IF t_s933-werks = t_s933-reswk.
*****      DELETE t_s933 INDEX sy-tabix.
*****    ENDIF.
*****  ENDLOOP.

  SORT t_s933 BY matnr werks lgort.

* Get intransit intercompany
  t_reswk[] = t_s933[].
  SORT t_reswk BY reswk bsart matnr.
  DELETE ADJACENT DUPLICATES FROM t_reswk COMPARING reswk bsart matnr.
  DELETE t_reswk WHERE bsart <> 'ZB' AND bsart <> 'ZICO'.
  IF t_reswk[] IS NOT INITIAL.
* Be carefull this is not same with above, because we remap the plant data
* for intransit intercompany with below loop
    REFRESH t_marc2.
    LOOP AT t_reswk.
      t_marc2-matnr = t_reswk-matnr.
      t_marc2-werks = t_reswk-reswk.
      p_month = p_spmon.
      DO 4 TIMES.
        p_month = p_month - 1.
        IF p_month+4(2) = 0.
          p_month+4(2) = 12.
          p_month(4) =  p_month(4) - 1.
        ENDIF.
        t_marc2-spmon = p_month.
        APPEND t_marc2.
      ENDDO.
    ENDLOOP.
    SORT t_marc2 BY matnr spmon.
    SELECT ekko~reswk ekko~bsart spmon ekpo~werks s933~matnr
           bwart charg mblnr budat ekpo~lgort s933~menge ekko~bedat
      FROM s933
      JOIN ekko ON ekko~ebeln = s933~ebeln
      JOIN ekpo ON ekpo~ebeln = s933~ebeln AND
                   ekpo~ebelp = s933~ebelp
      APPENDING CORRESPONDING FIELDS OF TABLE t_s933
       FOR ALL ENTRIES IN t_marc2
*     FOR ALL ENTRIES IN t_reswk
     WHERE spmon      = t_marc2-spmon
       AND s933~matnr = t_marc2-matnr
       AND s933~werks = t_marc2-werks
       AND bwart IN ('645', '646', '907', '908', 'Z07', 'Z08')
       AND ekko~bsart IN ('ZB', 'ZICO').
*       AND ekko~bsart = t_reswk-bsart.

  ENDIF.
  DELETE t_s933 WHERE werks NOT IN s_werks.
  SORT t_s933 BY matnr werks lgort spmon mblnr.
  LOOP AT t_s933.
* Delete GR from last 3 month, with assumption
* no outstanding from 3 month transaction
    IF t_s933-bedat(6) < p_month.
      CONTINUE.
    ENDIF.
    MOVE-CORRESPONDING t_s933 TO t_s933s.
    CASE t_s933-bwart.
      WHEN '101' OR '102' OR '645' OR '646' OR
           '907' OR '908'.
        t_s933s-menge = t_s933s-menge * -1.
      WHEN '641' OR '642' OR '351' OR '352'.
        IF t_s933s-werks+2(2) = '00'.
          CONTINUE.
        ENDIF.
      WHEN OTHERS.
        CONTINUE.
    ENDCASE.
    IF t_s933s-werks+2(2) = '00'. "If HO sum all sloc
      t_s933s-lgort = '1000'.
    ENDIF.
    COLLECT t_s933s.
  ENDLOOP.
  SORT t_s933s BY matnr werks lgort.
  p_t_s933s[] = t_s933s[].
ENDFORM.                    " GET_INTRANSIT
*&---------------------------------------------------------------------*
*&      Form  GET_FORECAST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_MARD  text
*      -->T_TVKOL text
*      -->T_S801  text
*      -->P_SPMON text
*----------------------------------------------------------------------*
FORM get_forecast  TABLES   t_mard
                            t_marm  STRUCTURE marm
                            t_tvkol STRUCTURE tvkol
                            t_s801  STRUCTURE s801
                   USING    p_spmon LIKE s801-spmon.

  DATA : BEGIN OF t_mard2 OCCURS 0,
           matnr LIKE mard-matnr,
           vkorg LIKE s801-vkorg,
           vstel LIKE tvkol-vstel,
           spmon LIKE s801-spmon,
           werks LIKE mard-werks,
           lgort LIKE mard-lgort,
         END OF t_mard2.

  DATA : BEGIN OF t_matnr OCCURS 0,
           matnr LIKE mara-matnr,
         END OF t_matnr.

  DATA : BEGIN OF t_mara OCCURS 0,
           matnr LIKE mara-matnr,
           extwg LIKE mara-extwg,
         END OF t_mara.

  DATA: d_vrsio TYPE vrsio,
        p_month TYPE spmon.

*  break mmfm.
  t_matnr[] = t_mard[].
  DELETE ADJACENT DUPLICATES FROM t_matnr COMPARING matnr.

  SELECT matnr extwg INTO TABLE t_mara
    FROM mara
    FOR ALL ENTRIES IN t_matnr
    WHERE matnr = t_matnr-matnr.
  SORT t_mara BY matnr.

  SELECT matnr meinh umrez umren INTO
    CORRESPONDING FIELDS OF TABLE t_marm
    FROM marm
    FOR ALL ENTRIES IN t_matnr
    WHERE matnr = t_matnr-matnr
      AND ( meinh = 'KAR' OR meinh = 'PAL' ).
  SORT t_marm BY matnr meinh.

  SORT t_tvkol BY werks lgort.
  LOOP AT t_mard.
    MOVE-CORRESPONDING t_mard TO t_mard2.
    p_month = p_spmon.
    READ TABLE t_tvkol WITH KEY werks = t_mard2-werks
                                lgort = t_mard2-lgort
    BINARY SEARCH.
    t_mard2-vkorg(1)   = '8'.
    t_mard2-vkorg+1(2) = t_tvkol-vstel(2).
    t_mard2-vkorg+3(1) = '0'.
    t_mard2-vstel = t_tvkol-vstel.
    READ TABLE t_mara WITH KEY matnr = t_mard2-matnr
    BINARY SEARCH.
    IF t_mara-extwg = 'TSP'.
      t_mard2-werks = '0100'.
    ELSEIF t_mara-extwg = 'BCL'.
      t_mard2-werks = '1800'.
    ELSE.
      t_mard2-werks = '0200'.
*      CONTINUE.
    ENDIF.
    DO 3 TIMES.
      t_mard2-spmon = p_month.
      APPEND t_mard2.
      p_month = p_month + 1.
      IF p_month+4(2) = '13'.
        p_month+4(2) = '01'.
        p_month(4) =  p_month(4) + 1.
      ENDIF.
    ENDDO.
  ENDLOOP.
*  break mmfm.
  SORT t_mard2 BY werks matnr vkorg vstel spmon.
  DELETE ADJACENT DUPLICATES FROM t_mard2 COMPARING werks matnr vkorg vstel spmon.

  IF t_mard2[] IS NOT INITIAL.
    d_vrsio = p_spmon+3(3).
    IF d_vrsio = '001'.
      d_vrsio = '912'.
    ELSE.
      d_vrsio = d_vrsio - 1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = d_vrsio
        IMPORTING
          output = d_vrsio.

      IF d_vrsio+1(2) = '00'.
        d_vrsio+1(2) = '12'.
        d_vrsio(1) =  d_vrsio(1) - 1.
      ENDIF.
    ENDIF.
    SELECT spmon matnr vkbur aftsqty ftsw1qty ftsw2qty ftsw3qty ftsw4qty
      INTO CORRESPONDING FIELDS OF TABLE t_s801
      FROM s801
      FOR ALL ENTRIES IN t_mard2
      WHERE ssour = ''
        AND vrsio = d_vrsio
        AND spmon = t_mard2-spmon
        AND sptag EQ '00000000'
        AND spwoc EQ '000000'
        AND spbup EQ '000000'
        AND werks = t_mard2-werks
        AND vkorg = t_mard2-vkorg
        AND lifnr = '##########'
        AND matnr = t_mard2-matnr
        AND vkbur = t_mard2-vstel
        AND kvgr2 = space.
  ENDIF.
ENDFORM.                    " GET_FORECAST

*&---------------------------------------------------------------------*
*&      Form  F_DOWNLOAD_SERVER
*&---------------------------------------------------------------------*
FORM f_download_server .
  DATA: lt_zm68nst01    TYPE STANDARD TABLE OF zm68nst01 WITH HEADER LINE,
        lt_download     TYPE truxs_t_text_data,
        lv_command(125).

  LOOP AT i_main.
    CLEAR lt_zm68nst01.
    lt_zm68nst01-spmon = p_spmon.
    lt_zm68nst01-matnr = i_main-matnr.
*    lt_zm68nst01-maktx = i_main-maktx.
    lt_zm68nst01-werks = i_main-werks.
*    lt_zm68nst01-name1 = i_main-name1.
    lt_zm68nst01-lgort = i_main-lgort.
    lt_zm68nst01-vkbur = i_main-vkbur.
*    lt_zm68nst01-bezei = i_main-bezei.
    lt_zm68nst01-meins = i_main-meins.
*    lt_zm68nst01-zeiar = i_main-zeiar.
*    lt_zm68nst01-maabc = i_main-maabc.
*    lt_zm68nst01-flg1  = i_main-flg1.
*    WRITE i_main-stkcr TO lt_zm68nst01-stkcr UNIT i_main-meins.
*    WRITE i_main-stkcrpl TO lt_zm68nst01-stkcrpl UNIT i_main-meins.
*    WRITE i_main-blstkcr TO lt_zm68nst01-blstkcr UNIT i_main-meins.
    WRITE i_main-intrs TO lt_zm68nst01-intrs UNIT i_main-meins.
*    WRITE i_main-opnsto TO lt_zm68nst01-opnsto UNIT i_main-meins.
*    WRITE i_main-opnpo TO lt_zm68nst01-opnpo UNIT i_main-meins.
*    WRITE i_main-grsto TO lt_zm68nst01-grsto UNIT i_main-meins.
*    WRITE i_main-totpo TO lt_zm68nst01-totpo UNIT i_main-meins.
*    WRITE i_main-avrsl TO lt_zm68nst01-avrsl UNIT i_main-meins.
*    WRITE i_main-avrslutd TO lt_zm68nst01-avrslutd UNIT i_main-meins.
*    WRITE i_main-avrfc TO lt_zm68nst01-avrfc UNIT i_main-meins.
*    WRITE i_main-stdrt TO lt_zm68nst01-stdrt UNIT i_main-meins.
*    WRITE i_main-actrt TO lt_zm68nst01-actrt UNIT i_main-meins.
*    WRITE i_main-actrt1 TO lt_zm68nst01-actrt1 UNIT i_main-meins.
    WRITE i_main-stkls TO lt_zm68nst01-stkls UNIT i_main-meins.
*    WRITE i_main-sales TO lt_zm68nst01-sales UNIT i_main-meins.
*    WRITE i_main-tacm TO lt_zm68nst01-tacm UNIT i_main-meins.
*    WRITE i_main-tanm TO lt_zm68nst01-tanm UNIT i_main-meins.
*    WRITE i_main-x6 TO lt_zm68nst01-x6.
*    WRITE i_main-x5 TO lt_zm68nst01-x5.
*    WRITE i_main-x4 TO lt_zm68nst01-x4.
*    WRITE i_main-x3 TO lt_zm68nst01-x3.
*    WRITE i_main-x2 TO lt_zm68nst01-x2.
*    WRITE i_main-x1 TO lt_zm68nst01-x1.
*    WRITE i_main-m0 TO lt_zm68nst01-m0.
*    WRITE i_main-m1 TO lt_zm68nst01-m1.
*    WRITE i_main-m2 TO lt_zm68nst01-m2.
    APPEND lt_zm68nst01.
  ENDLOOP.

  CHECK lt_zm68nst01[] IS NOT INITIAL.

* Concatenate data with separator
  CALL METHOD zcl_util=>m_concate_text_separator
    EXPORTING
      pti_data      = lt_zm68nst01[]
      pvi_separator = ';'
    IMPORTING
      pto_data      = lt_download.

* Create filename
  CONCATENATE p_flnmsv 'ZM68N' INTO p_flnmsv.
  CONCATENATE p_flnmsv p_spmon INTO p_flnmsv
    SEPARATED BY '_'.
  CONCATENATE p_flnmsv '.csv' INTO p_flnmsv.

* Delete file exist
  OPEN DATASET p_flnmsv FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF sy-subrc = 0.
    DELETE DATASET p_flnmsv.
  ENDIF.

* Download data
  CALL METHOD zcl_util=>m_download_dataset
    EXPORTING
      param_name = p_flnmsv
      pti_data   = lt_download[].
*
*  CONCATENATE 'chmod 666' p_flnmsv INTO lv_command SEPARATED BY space.
*  CALL 'SYSTEM' ID 'COMMAND' FIELD lv_command
*                ID 'TAB' FIELD tabl-*sys*.
ENDFORM.                    " F_DOWNLOAD_SERVER

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ITAB
*&---------------------------------------------------------------------*
FORM f_add_itab  TABLES   t_mard.
  DATA : BEGIN OF lt_marc OCCURS 0,
           matnr LIKE marc-matnr,
           werks LIKE marc-werks,
         END OF lt_marc.
  DATA : lt_string     TYPE zdg2catt0002,
         ls_string     TYPE zdg2cast0002,
         lv_string(40),
         lv_subrc      TYPE sy-subrc.

  lt_marc[] = t_mard[].
  DELETE ADJACENT DUPLICATES FROM lt_marc COMPARING matnr werks.

  LOOP AT lt_marc.
    lv_subrc = 4.
    LOOP AT gt_string INTO gs_string.
      i_dataset = gs_string-string.
      IF i_dataset-matnr = lt_marc-matnr AND
        i_dataset-werks = lt_marc-werks.
        CLEAR lv_subrc.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF lv_subrc IS NOT INITIAL.
      lv_string(4)     = lt_marc-werks.
      lv_string+22(18) = lt_marc-matnr.
      ls_string-string = lv_string.
      APPEND ls_string TO lt_string.
      CLEAR : lv_string, ls_string.
    ENDIF.
  ENDLOOP.
  IF lt_string[] IS NOT INITIAL.
    LOOP AT lt_string INTO ls_string.
      APPEND ls_string TO gt_string.
      CLEAR ls_string.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_ADD_ITAB

*&---------------------------------------------------------------------*
*&      Form  F_GET_INTRANSIT_0249
*&---------------------------------------------------------------------*
FORM f_get_intransit_313 TABLES  ft_s933int.
  DATA: BEGIN OF t_s933s OCCURS 0,
          matnr LIKE s933-matnr,
          werks LIKE s933-werks,
          lgort LIKE s933-lgort,
          menge LIKE s933-menge,
        END OF t_s933s.

  DATA: lt_s933  TYPE TABLE OF s933 WITH HEADER LINE,
        lt_mkpf  TYPE TABLE OF mkpf WITH HEADER LINE,
        lt_mseg  TYPE TABLE OF mseg WITH HEADER LINE,
        lv_mblnr LIKE mseg-mblnr,
        lt_zcust TYPE STANDARD TABLE OF zmproject_ctrl,
        ls_zcust LIKE LINE OF lt_zcust,
        lr_werks TYPE RANGE OF werks_d,
        ls_werks LIKE LINE OF lr_werks.

  SELECT *
      FROM zmproject_ctrl
      INTO CORRESPONDING FIELDS OF TABLE lt_zcust
      WHERE zproject = 'ZINT_313'
        AND datab    <= sy-datum
        AND datbi    >= sy-datum.


  CLEAR : lr_werks[].
  LOOP AT lt_zcust INTO ls_zcust.
    CASE ls_zcust-fieldname1.
      WHEN 'WERKS'.
        ls_werks-low    = ls_zcust-low1.
        IF ls_zcust-option1 = 'BT'.
          ls_werks-high     = ls_zcust-high1.
        ENDIF.
        ls_werks-sign   = ls_zcust-sign1.
        ls_werks-option = ls_zcust-option1.
        IF ls_werks-low IN s_werks.
          APPEND ls_werks TO lr_werks.
        ENDIF.
        CLEAR ls_werks.
    ENDCASE.
  ENDLOOP.



  IF lr_werks[] IS NOT INITIAL.
    SELECT spmon werks matnr bwart charg mblnr budat lgort vrsio
      INTO CORRESPONDING FIELDS OF TABLE lt_s933
      FROM s933 WHERE spmon = p_spmon
                  AND werks IN lr_werks
                  AND matnr IN s_matnr
                  AND bwart = '313'
*                AND bwart IN ('313','316')
                  AND lgort = '10E0'.

    IF sy-subrc = 0.
      SELECT mblnr mjahr bldat budat xblnr
        INTO CORRESPONDING FIELDS OF TABLE lt_mkpf
        FROM mkpf FOR ALL ENTRIES IN lt_s933
        WHERE mblnr = lt_s933-mblnr
          AND mjahr = lt_s933-spmon(4)
          AND xblnr = space.

      IF lt_mkpf[] IS NOT INITIAL.
        SELECT mblnr mjahr zeile bwart xauto matnr werks lgort charg
               shkzg menge
          INTO CORRESPONDING FIELDS OF TABLE lt_mseg
          FROM mseg FOR ALL ENTRIES IN lt_mkpf
          WHERE mblnr = lt_mkpf-mblnr
            AND mjahr = lt_mkpf-mjahr
            AND bwart = '313'
*        AND bwart IN ('313','316')
            AND lgort = '10E0'
            AND smbln = space.

        IF sy-subrc = 0.
          LOOP AT lt_mseg.
            SELECT SINGLE mblnr INTO lv_mblnr
              FROM mseg
              WHERE smbln = lt_mseg-mblnr.
            IF sy-subrc = 0.
              CONTINUE.
            ELSE.
*        IF lt_mseg-shkzg = 'S'.
*          MULTIPLY lt_mseg-menge BY -1.
*        ENDIF.
              t_s933s-matnr = lt_mseg-matnr.
              t_s933s-werks = lt_mseg-werks.
              t_s933s-lgort = lt_mseg-lgort.
              t_s933s-menge = lt_mseg-menge.
              COLLECT t_s933s.
            ENDIF.
          ENDLOOP.
          ft_s933int[] = t_s933s[].
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_INTRANSIT_0249

*&---------------------------------------------------------------------*
*&      Form  F_OPENING_STOCK
*&---------------------------------------------------------------------*
FORM f_opening_stock  TABLES   ft_x039 STRUCTURE i_s039
                      USING    fu_proc.
  DATA : lt_x039  LIKE i_s039 OCCURS 0,
         ls_x039  LIKE i_s039,
         lr_lgort TYPE RANGE OF lgort_d,
         ls_lgort LIKE LINE OF lr_lgort.

  ls_lgort-low    = '1099'.
  ls_lgort-sign   = 'E'.
  ls_lgort-option = 'EQ'.
  APPEND ls_lgort TO lr_lgort.
  ls_lgort-low    = '**U*'.
  ls_lgort-sign   = 'E'.
  ls_lgort-option = 'CP'.
  APPEND ls_lgort TO lr_lgort.
  ls_lgort-low    = space.
  ls_lgort-sign   = 'E'.
  ls_lgort-option = 'EQ'.
  APPEND ls_lgort TO lr_lgort.

  CASE fu_proc.
    WHEN 'CALC'.
      CLEAR ft_x039[].
      lt_x039[] = i_s039[].
      SORT lt_x039 BY werks matnr.

      LOOP AT lt_x039 INTO ls_x039.
        IF ls_x039-lgort IN lr_lgort.
          CONTINUE.
        ELSE.
          ls_x039-lgort = '1000'.
          COLLECT ls_x039 INTO ft_x039.
        ENDIF.
        CLEAR i_s039.
      ENDLOOP.

*****        IF ls_x039-lgort(3) = '100'.
*****          ls_x039-lgort = '1000'.
*****          COLLECT ls_x039 INTO ft_x039.

    WHEN 'MODIFY'.
      LOOP AT i_main.
        CLEAR ls_x039.
        READ TABLE ft_x039 INTO ls_x039
                           WITH KEY werks = i_main-werks
                                    matnr = i_main-matnr.
        IF sy-subrc = 0.
          i_main-stkls  = ls_x039-mbwbest.
          MODIFY i_main TRANSPORTING stkls.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_OPENING_STOCK
