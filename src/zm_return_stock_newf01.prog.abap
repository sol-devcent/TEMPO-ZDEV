*----------------------------------------------------------------------*
*   INCLUDE ZM_RETURN_STOCK_NEWF01                                     *
*----------------------------------------------------------------------*
FORM f_init_data.
  CONCATENATE so_budat-low(6) '01' INTO va_budat.
  ra_budat-low     = va_budat.
  ra_budat-high    = so_budat-low.
  ra_budat-sign    = 'I'.
  ra_budat-option  = 'BT'.
  APPEND ra_budat.

  va_budat  = va_budat - 1.

* Blocked
  ra_bwart-low     = '349'.
  ra_bwart-high    = '350'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
  ra_bwart-low     = '343'.
  ra_bwart-high    = '344'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
  ra_bwart-low     = '555'.
  ra_bwart-high    = '556'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
  ra_bwart-low     = '707'.
  ra_bwart-high    = '708'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
* UU
  ra_bwart-low     = '321'.
  ra_bwart-high    = '322'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
  ra_bwart-low     = '601'.
  ra_bwart-high    = '602'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
  ra_bwart-low     = '653'.
  ra_bwart-high    = '654'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
  ra_bwart-low     = '701'.
  ra_bwart-high    = '702'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
* QI
  ra_bwart-low     = '655'.
  ra_bwart-high    = '656'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.
  ra_bwart-low     = '703'.
  ra_bwart-high    = '704'.
  ra_bwart-sign    = 'I'.
  ra_bwart-option  = 'BT'.
  APPEND ra_bwart.

* Blocked In
  ra_inblk-low     = '350'.
  ra_inblk-sign    = 'I'.
  ra_inblk-option  = 'EQ'.
  APPEND ra_inblk.
  ra_inblk-low     = '344'.
  ra_inblk-sign    = 'I'.
  ra_inblk-option  = 'EQ'.
  APPEND ra_inblk.
  ra_inblk-low     = '707'.
  ra_inblk-sign    = 'I'.
  ra_inblk-option  = 'EQ'.
  APPEND ra_inblk.
  ra_inblk-low     = '556'.
  ra_inblk-sign    = 'I'.
  ra_inblk-option  = 'EQ'.
  APPEND ra_inblk.
* Blocked Out
  ra_otblk-low     = '349'.
  ra_otblk-sign    = 'I'.
  ra_otblk-option  = 'EQ'.
  APPEND ra_otblk.
  ra_otblk-low     = '343'.
  ra_otblk-sign    = 'I'.
  ra_otblk-option  = 'EQ'.
  APPEND ra_otblk.
  ra_otblk-low     = '708'.
  ra_otblk-sign    = 'I'.
  ra_otblk-option  = 'EQ'.
  APPEND ra_otblk.
  ra_otblk-low     = '555'.
  ra_otblk-sign    = 'I'.
  ra_otblk-option  = 'EQ'.
  APPEND ra_otblk.

* UU In
  ra_inuu-low     = '321'.
  ra_inuu-sign    = 'I'.
  ra_inuu-option  = 'EQ'.
  APPEND ra_inuu.
  ra_inuu-low     = '343'.
  ra_inuu-sign    = 'I'.
  ra_inuu-option  = 'EQ'.
  APPEND ra_inuu.
  ra_inuu-low     = '602'.
  ra_inuu-sign    = 'I'.
  ra_inuu-option  = 'EQ'.
  APPEND ra_inuu.
  ra_inuu-low     = '653'.
  ra_inuu-sign    = 'I'.
  ra_inuu-option  = 'EQ'.
  APPEND ra_inuu.
  ra_inuu-low     = '701'.
  ra_inuu-sign    = 'I'.
  ra_inuu-option  = 'EQ'.
  APPEND ra_inuu.
* UU Out
  ra_otuu-low     = '322'.
  ra_otuu-sign    = 'I'.
  ra_otuu-option  = 'EQ'.
  APPEND ra_otuu.
  ra_otuu-low     = '344'.
  ra_otuu-sign    = 'I'.
  ra_otuu-option  = 'EQ'.
  APPEND ra_otuu.
  ra_otuu-low     = '601'.
  ra_otuu-sign    = 'I'.
  ra_otuu-option  = 'EQ'.
  APPEND ra_otuu.
  ra_otuu-low     = '654'.
  ra_otuu-sign    = 'I'.
  ra_otuu-option  = 'EQ'.
  APPEND ra_otuu.
  ra_otuu-low     = '702'.
  ra_otuu-sign    = 'I'.
  ra_otuu-option  = 'EQ'.
  APPEND ra_otuu.

* QI In
  ra_inqi-low     = '322'.
  ra_inqi-sign    = 'I'.
  ra_inqi-option  = 'EQ'.
  APPEND ra_inqi.
  ra_inqi-low     = '349'.
  ra_inqi-sign    = 'I'.
  ra_inqi-option  = 'EQ'.
  APPEND ra_inqi.
  ra_inqi-low     = '655'.
  ra_inqi-sign    = 'I'.
  ra_inqi-option  = 'EQ'.
  APPEND ra_inqi.
  ra_inqi-low     = '703'.
  ra_inqi-sign    = 'I'.
  ra_inqi-option  = 'EQ'.
  APPEND ra_inqi.
* QI Out
  ra_otqi-low     = '321'.
  ra_otqi-sign    = 'I'.
  ra_otqi-option  = 'EQ'.
  APPEND ra_otqi.
  ra_otqi-low     = '350'.
  ra_otqi-sign    = 'I'.
  ra_otqi-option  = 'EQ'.
  APPEND ra_otqi.
  ra_otqi-low     = '656'.
  ra_otqi-sign    = 'I'.
  ra_otqi-option  = 'EQ'.
  APPEND ra_otqi.
  ra_otqi-low     = '704'.
  ra_otqi-sign    = 'I'.
  ra_otqi-option  = 'EQ'.
  APPEND ra_otqi.

  SELECT werks
    FROM t001w
    INTO CORRESPONDING FIELDS OF TABLE t_werks
    WHERE werks IN so_werks.

  SELECT matkl
    FROM t023
    INTO CORRESPONDING FIELDS OF TABLE t_matkl
    WHERE matkl IN so_matkl.

  LOOP AT t_werks.
    AUTHORITY-CHECK OBJECT 'M_MSEG_WWA'
        ID 'WERKS' FIELD t_werks-werks.
    IF sy-subrc NE 0.
      MESSAGE e002(zz) WITH
        'You have no authorization for Plant ' t_werks-werks.
    ENDIF.
  ENDLOOP.

  LOOP AT t_matkl.
    AUTHORITY-CHECK OBJECT 'M_MATE_WGR'
      ID 'BEGRU' FIELD t_matkl-matkl.
    IF sy-subrc NE 0.
      MESSAGE e002(zz) WITH 'You are not authorized with Material Group'
          t_matkl-matkl.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "f_init_data

*---------------------------------------------------------------------*
*       FORM f_get_data                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_get_data.
  DATA : s_main      LIKE t_vdata,
         ld_spmon    LIKE s931-spmon,
         lt_s931     LIKE zmm_ret_stock OCCURS 0 WITH HEADER LINE.

* Get opening stock from ZMM_RET_STOCK
  SELECT *
  FROM zmm_ret_stock AS a JOIN makt AS b ON a~matnr EQ b~matnr
  INTO CORRESPONDING FIELDS OF TABLE t_open
  WHERE a~budat EQ va_budat AND
        a~werks IN so_werks AND
        a~lgort IN so_lgort AND
        a~matkl IN so_matkl AND
        a~matnr IN so_matnr AND
        b~spras EQ sy-langu
*{   REPLACE        P01K910604                                        1
*\        %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
*  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
   .
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE

* Get mutasi stock from ZMM_RET_STOCK
  SELECT *
  FROM zmm_ret_stock AS a JOIN makt AS b ON a~matnr EQ b~matnr
  INTO CORRESPONDING FIELDS OF TABLE t_vdata
  WHERE a~budat IN so_budat AND
        a~werks IN so_werks AND
        a~lgort IN so_lgort AND
        a~matkl IN so_matkl AND
        a~matnr IN so_matnr AND
        b~spras EQ sy-langu
*{   REPLACE        P01K910604                                        2
*\        %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
*  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
   .
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE

  IF sy-datum IN so_budat.
* Get today mutasi from S931 & ending stock from MARD
    SELECT *
    APPENDING CORRESPONDING FIELDS OF TABLE t_vdata
    FROM mard INNER JOIN mbew ON mard~matnr EQ mbew~matnr AND
                                 mard~werks EQ mbew~bwkey
              INNER JOIN mara ON mard~matnr EQ mara~matnr
              INNER JOIN makt ON mard~matnr EQ makt~matnr
    WHERE mard~matnr IN so_matnr AND
          matkl      IN so_matkl AND
          werks      IN so_werks AND
          lgort      IN so_lgort AND
          makt~spras EQ sy-langu
*{   REPLACE        P01K910604                                        3
*\          %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
*  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
   .
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE

    ld_spmon  = sy-datum(6).
    SELECT spmon werks lgort matnr bwart matkl shkzg umwrk umlgo
           menge magbb mzubb
      FROM s931
      INTO CORRESPONDING FIELDS OF TABLE t_s931
      WHERE spmon EQ ld_spmon AND
            werks IN so_werks AND
            lgort IN so_lgort AND
            matnr IN so_matnr AND
            bwart IN ra_bwart
*{   REPLACE        P01K910604                                        4
*\            %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
*  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
   .
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE
    LOOP AT t_s931.
      CLEAR: lt_s931.
      lt_s931-werks  = t_s931-werks.
      lt_s931-lgort  = t_s931-lgort.
      lt_s931-matnr  = t_s931-matnr.
      lt_s931-matkl  = t_s931-matkl.

* UU
      IF t_s931-bwart IN ra_inuu.
        IF t_s931-shkzg EQ 'S'.
          lt_s931-inuu  = t_s931-mzubb - t_s931-magbb.
        ENDIF.
      ENDIF.
      IF t_s931-bwart IN ra_otuu.
        IF t_s931-shkzg EQ 'H'.
          lt_s931-otuu  = ( t_s931-mzubb - t_s931-magbb ) * -1.
        ENDIF.
      ENDIF.

* QI
      IF t_s931-bwart IN ra_inqi.
        IF t_s931-shkzg EQ 'S'.
          lt_s931-inqi  = t_s931-mzubb - t_s931-magbb.
        ENDIF.
      ENDIF.
      IF t_s931-bwart IN ra_otqi.
        IF t_s931-shkzg EQ 'H'.
          lt_s931-otqi  = ( t_s931-mzubb - t_s931-magbb ) * -1.
        ENDIF.
      ENDIF.

* Block
      IF t_s931-bwart IN ra_inblk.
        IF t_s931-shkzg EQ 'S'.
          lt_s931-inblk  = t_s931-mzubb - t_s931-magbb.
        ENDIF.
      ENDIF.
      IF t_s931-bwart IN ra_otblk.
        IF t_s931-shkzg EQ 'H'.
          lt_s931-otblk  = ( t_s931-mzubb - t_s931-magbb ) * -1.
        ENDIF.
      ENDIF.

      COLLECT lt_s931.
      CLEAR: lt_s931-inuu, lt_s931-otuu, lt_s931-inqi,
             lt_s931-otqi, lt_s931-inblk, lt_s931-otblk.
    ENDLOOP.
  ENDIF.

  LOOP AT t_vdata INTO s_main.
    IF s_main-budat IS INITIAL.
      s_main-budat  = sy-datum.
      READ TABLE lt_s931 WITH KEY matnr = s_main-matnr
                                  matkl = s_main-matkl
                                  werks = s_main-werks
                                  lgort = s_main-lgort.
      IF sy-subrc EQ 0.
        s_main-inuu    = lt_s931-inuu.
        s_main-otuu    = lt_s931-otuu.
        s_main-inqi    = lt_s931-inqi.
        s_main-otqi    = lt_s931-otqi.
        s_main-inblk   = lt_s931-inblk.
        s_main-otblk   = lt_s931-otblk.
      ENDIF.
    ENDIF.
    s_main-uuval   = s_main-labst * s_main-salk3 / s_main-lbkum.
    s_main-qival   = s_main-insme * s_main-salk3 / s_main-lbkum.
    s_main-blckval = s_main-speme * s_main-salk3 / s_main-lbkum.
    s_main-lbkum   = s_main-labst + s_main-insme + s_main-speme.
    s_main-salk3   = s_main-uuval + s_main-qival + s_main-blckval.
    READ TABLE t_open WITH KEY matnr = s_main-matnr
                               matkl = s_main-matkl
                               werks = s_main-werks
                               lgort = s_main-lgort.
    IF sy-subrc EQ 0.
      s_main-openb   = t_open-speme.
      s_main-openu   = t_open-labst.
      s_main-openq   = t_open-insme.

*      s_main-speme   = t_open-speme.
*      s_main-labst   = t_open-labst.
*      s_main-insme   = t_open-insme.
    ENDIF.
    MODIFY t_vdata FROM s_main.
    CLEAR: s_main.
  ENDLOOP.

  SORT t_vdata BY budat matnr werks.

* Detail mutasi
  SELECT spmon werks matnr bwart charg mblnr budat lgort vrsio menge basme
    FROM s934
    INTO CORRESPONDING FIELDS OF TABLE t_s934
    WHERE spmon EQ so_budat-low(6) AND
          werks IN so_werks        AND
          matnr IN so_matnr        AND
          bwart IN ra_bwart        AND
          lgort IN so_lgort        AND
          budat LE so_budat-low    AND
          vrsio EQ '000'
*{   REPLACE        P01K910604                                        5
*\          %_HINTS DB6 'USE_OPTLEVEL 0'.
"Start SOH: Shell SCI Adjustment 20240226 RZL
*  %_HINTS HDB 'OPTIMIZATION_LEVEL (MINIMAL)'. "#EC CI_HINTS
   .
"End SOH: Shell SCI Adjustment 20240226 RZL
*}   REPLACE
ENDFORM.                    "f_get_data

*---------------------------------------------------------------------*
*       FORM f_print_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_print_data.

  PERFORM f_alv TABLES t_result.

ENDFORM.                    "f_print_data

*---------------------------------------------------------------------*
*       FORM f_alv                                                    *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_DATA                                                       *
*---------------------------------------------------------------------*
FORM f_alv TABLES ft_report.

  PERFORM f_gui_message USING 'Write Data in Progress ...' ''.
  PERFORM f_clear_alv_data.
  PERFORM f_build_fieldcat    TABLES  ft_report.
  PERFORM f_build_layout     USING   d_layout.
  PERFORM f_build_sortfield  USING   t_alv_isort[].
  PERFORM f_build_event      TABLES  t_alv_event[].
  PERFORM f_build_event_exit.
  PERFORM f_build_print      USING   d_print.
  PERFORM f_alv_variant_exist USING   p_vari
                                      d_alv_variant.

  CALL FUNCTION 'REUSE_ALV_LIST_DISPLAY'
    EXPORTING
*   I_INTERFACE_CHECK              = ' '
*   I_BYPASSING_BUFFER             =
*   I_BUFFER_ACTIVE                = ' '
    i_callback_program             = d_repid
    i_callback_pf_status_set       = 'F_SET_PF_STATUS'
    i_callback_user_command        = 'F_USER_COMMAND'
*   I_STRUCTURE_NAME               =
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
      t_outtab                       = ft_report
   EXCEPTIONS
     program_error                  = 1
     OTHERS                         = 2
            .
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "f_alv

*---------------------------------------------------------------------*
*       FORM f_fieldcat                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_fieldcat TABLES ft_report.

  REFRESH: t_alv_fieldcat.

  PERFORM f_fieldcatg USING ft_report:
    'BUDAT' '' '' '' '10' 'Date' '' '' '' '' '' '' '' '' '' '',
    'WERKS' 'ZMM_RET_STOCK' 'WERKS' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'LGORT' 'ZMM_RET_STOCK' 'LGORT' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MATKL' 'ZMM_RET_STOCK' 'MATKL' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MATNR' 'ZMM_RET_STOCK' 'MATNR' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MAKTX' 'MAKT' 'MAKTX' '' '' '' '' '' '' '' '' '' '' '' '' '',
    'MEINS' 'ZMM_RET_STOCK' 'MEINS' '' '' '' '' '' '' '' '' '' '' '' '' ''.
  CASE 'X'.
    WHEN radio1.
      PERFORM f_fieldcatg USING ft_report:
* UU
        'OPENU1' '' '' '' '18' 'Open Stock UU' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'INUU' 'ZMM_RET_STOCK' 'INUU' '' '18' 'In UU' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'OTUU' 'ZMM_RET_STOCK' 'OTUU' '' '18' 'Out UU' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'ENDU1' '' '' '' '18' 'End Stock UU' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'UUVAL' '' '' '' '18' 'End Value in UU' 'X' '' '' 'IDR' '' '' '' '' '' '',
* QI
        'OPENQ1' '' '' '' '18' 'Open Stock QI' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'INQI' 'ZMM_RET_STOCK' 'INQI' '' '18' 'In QI' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'OTQI' 'ZMM_RET_STOCK' 'OTQI' '' '18' 'Out QI' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'ENDQ1' '' '' '' '18' 'End Stock QI' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'QIVAL' '' '' '' '18' 'End Value in QI' 'X' '' '' 'IDR' '' '' '' '' '' '',
* Block
        'OPENB1' '' '' '' '18' 'Open Stock Block' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'INBLK' 'ZMM_RET_STOCK' 'INBLK' '' '18' 'In Block' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'OTBLK' 'ZMM_RET_STOCK' 'OTBLK' '' '18' 'Out Block' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'ENDB1' '' '' '' '18' 'End Stock Block' 'X' '' '' '' '' '' 'MEINS' '' '' '',
        'BLCKVAL' '' '' '' '18' 'End Value in Block' 'X' '' '' 'IDR' '' '' '' '' '' ''.
    WHEN radio2.
      PERFORM f_fieldcatg USING ft_report:
* UU
        'OPENU' '' '' '' '18' 'Open Stock UU' '' '' '' '' '' '' '' '' '' '',
        'INU1' '' '' '' '18' 'In UU' '' '' '' '' '' '' '' '' '' '',
        'OTU1' '' '' '' '18' 'Out UU' '' '' '' '' '' '' '' '' '' '',
        'ENDU' '' '' '' '18' 'End Stock UU' '' '' '' '' '' '' '' '' '' '',
        'ENDVU' '' '' '' '18' 'End Value in UU' '' '' '' '' '' '' '' '' '' '',
* QI
        'OPENQ' '' '' '' '18' 'Open Stock QI' '' '' '' '' '' '' '' '' '' '',
        'INQ1' '' '' '' '18' 'In QI' '' '' '' '' '' '' '' '' '' '',
        'OTQ1' '' '' '' '18' 'Out QI' '' '' '' '' '' '' '' '' '' '',
        'ENDQ' '' '' '' '18' 'End Stock QI' '' '' '' '' '' '' '' '' '' '',
        'ENDVQ' '' '' '' '18' 'End Value in QI' '' '' '' '' '' '' '' '' '' '',
* Block
        'OPENB' '' '' '' '18' 'Open Stock Block' '' '' '' '' '' '' '' '' '' '',
        'INB1' '' '' '' '18' 'In Block' '' '' '' '' '' '' '' '' '' '',
        'OTB1' '' '' '' '18' 'Out Block' '' '' '' '' '' '' '' '' '' '',
        'ENDB' '' '' '' '18' 'End Stock Block' '' '' '' '' '' '' '' '' '' '',
        'ENDVB' '' '' '' '18' 'End Value in Block' '' '' '' '' '' '' '' '' '' ''.
  ENDCASE.
  PERFORM f_fieldcatg USING ft_report:
    'LBKUM' '' '' 'X' '18' 'Total Qty' '' '' '' '' '' '' 'MEINS' '' '' '',
    'SALK3' '' '' 'X' '18' 'Total Value' '' '' '' 'IDR' '' '' '' '' '' ''.
ENDFORM.                    " F_FIELDCAT


*---------------------------------------------------------------------*
*       FORM f_fieldcats                                              *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_FNAME                                                      *
*  -->  FU_OUTLEN                                                     *
*  -->  FU_NOSIGN                                                     *
*  -->  FU_NOOUT                                                      *
*  -->  FU_TEXT                                                       *
*  -->  FU_REFTB                                                      *
*  -->  FU_REFFNAME                                                   *
*  -->  FU_DECIMALS                                                   *
*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_FIELDCATG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_fieldcatg USING    value(fu_types)
                          value(fu_fname)
                          value(fu_reftb)
                          value(fu_refld)
                          value(fu_noout)
                          value(fu_outln)
                          value(fu_fltxt)
                          value(fu_dosum)
                          value(fu_hotsp)
                          value(fu_dec)
                          value(fu_waers)
                          value(fu_meins)
                          value(fu_waers_f)
                          value(fu_meins_f)
                          value(fu_checkbox)
                          value(fu_nozero)
                          value(fu_nosign).

  DATA: ld_fieldcat  TYPE  slis_fieldcat_alv.
  CLEAR: ld_fieldcat.
  ld_fieldcat-tabname           = fu_types.
  ld_fieldcat-fieldname         = fu_fname.
  ld_fieldcat-ref_tabname       = fu_reftb.
  ld_fieldcat-ref_fieldname     = fu_refld.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-outputlen         = fu_outln.
  ld_fieldcat-seltext_l         = fu_fltxt.
  ld_fieldcat-seltext_m         = fu_fltxt.
  ld_fieldcat-seltext_s         = fu_fltxt.
  ld_fieldcat-reptext_ddic      = fu_fltxt.
  ld_fieldcat-no_out            = fu_noout.
  ld_fieldcat-do_sum            = fu_dosum.
  ld_fieldcat-hotspot           = fu_hotsp.
  ld_fieldcat-decimals_out      = fu_dec.
  ld_fieldcat-currency          = fu_waers.
  ld_fieldcat-quantity          = fu_meins.
  ld_fieldcat-qfieldname        = fu_meins_f.
  ld_fieldcat-cfieldname        = fu_waers_f.
  ld_fieldcat-checkbox          = fu_checkbox.
  ld_fieldcat-no_zero           = fu_nozero.
  ld_fieldcat-no_sign           = fu_nosign.
  APPEND ld_fieldcat TO t_alv_fieldcat.
  CLEAR ld_fieldcat.

ENDFORM.                    " F_FIELDCATG

*---------------------------------------------------------------------*
*       FORM f_build_event                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FT_EVENTS                                                     *
*---------------------------------------------------------------------*
FORM f_build_event TABLES ft_events LIKE t_events.

  REFRESH: ft_events.
  CLEAR ft_events.
  ft_events-name = slis_ev_top_of_page.
  ft_events-form = 'F_TOP_OF_PAGE'.
  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_end_of_page.
*  ft_events-form = 'F_END_OF_PAGE'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_before_line_output.
*  ft_events-form = 'F_BEFORE_LINE_OUTPUT'.
*  APPEND ft_events.

*  CLEAR ft_events.
*  ft_events-name = slis_ev_after_line_output.
*  ft_events-form = 'F_AFTER_LINE_OUTPUT'.
*  APPEND ft_events.
*
*  CLEAR ft_events.
*  ft_events-name = slis_ev_subtotal_text.
*  ft_events-form = 'F_SUBTOTAL'.
*  APPEND ft_events.
ENDFORM.                    "f_build_event

*---------------------------------------------------------------------*
*       FORM f_build_event_exit                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_build_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&OUP'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

  CLEAR t_event_exit.
  t_event_exit-ucomm = '&ODN'.
  t_event_exit-after = 'X'.
  APPEND t_event_exit.

ENDFORM.                    "f_build_event_exit

*---------------------------------------------------------------------*
*       FORM f_build_layout                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_LAYOUT                                                     *
*---------------------------------------------------------------------*
FORM f_build_layout USING fu_layout TYPE slis_layout_alv.
* fu_layout-f2code             = '&ETA'.
* fu_layout-zebra              = 'X'.
  fu_layout-colwidth_optimize  = space.
  fu_layout-no_colhead         = space.
  fu_layout-group_change_edit  = 'X'.
  fu_layout-info_fieldname     = 'COLOR'.
ENDFORM.                    "f_build_layout

*---------------------------------------------------------------------*
*       FORM f_build_print                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_PRINT                                                      *
*---------------------------------------------------------------------*
FORM f_build_print USING fu_print TYPE slis_print_alv.
  fu_print-no_print_listinfos = 'X'.
  fu_print-no_print_selinfos  = 'X'.
  fu_print-no_coverpage       = 'X'.
  fu_print-no_print_hierseq_item = 'X'.
ENDFORM.                    "f_build_print

*---------------------------------------------------------------------*
*       FORM f_build_sortfield                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  FU_SORT                                                       *
*---------------------------------------------------------------------*
FORM f_build_sortfield USING fu_sort TYPE slis_t_sortinfo_alv.
  DATA: ld_sort TYPE slis_sortinfo_alv.

  CASE 'X'.
    WHEN radio1.
      CLEAR ld_sort.
      ld_sort-fieldname = 'WERKS'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'MATNR'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'ROWS'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'BUDAT'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
    WHEN radio2.
      CLEAR ld_sort.
      ld_sort-fieldname = 'LINES'.
      ld_sort-up        = 'X'.
      APPEND ld_sort TO fu_sort.
      CLEAR ld_sort.
      ld_sort-fieldname = 'BREAK'.
      ld_sort-up        = 'X'.
      ld_sort-group     = 'UL'.
      APPEND ld_sort TO fu_sort.

*      CLEAR ld_sort.
*      ld_sort-fieldname = 'WERKS'.
*      ld_sort-up        = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'MATNR'.
*      ld_sort-up        = 'X'.
*      ld_sort-group     = 'UL'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'ROWS'.
*      ld_sort-up        = 'X'.
*      APPEND ld_sort TO fu_sort.
*      CLEAR ld_sort.
*      ld_sort-fieldname = 'BUDAT'.
*      ld_sort-down      = 'X'.
*      APPEND ld_sort TO fu_sort.
  ENDCASE.

ENDFORM.                    "f_build_sortfield

*---------------------------------------------------------------------*
*       FORM f_top_of_page                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM f_top_of_page.

  PERFORM f_header USING sy-title so_budat-low.
*  PERFORM f_hdr_uline.
*  PERFORM f_hdr_line1 USING sy-title.
*  PERFORM f_hdr_line2 USING ''.
*  PERFORM f_hdr_line3 USING ''.
*  PERFORM f_hdr_uline.
ENDFORM.                    "f_top_of_page

*&---------------------------------------------------------------------*
*&      Form  F_FREE_MEMORY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.

* here free all the internal table used in the program.

ENDFORM.                    " F_FREE_MEMORY
*&---------------------------------------------------------------------*
*&      Form  f_clear_alv_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear_alv_data.


  CLEAR:t_alv_fieldcat,
        t_alv_event,
        t_events,
        t_alv_isort,
        t_alv_filter,
        t_event_exit,
        d_alv_isort,
        d_alv_variant,
        d_alv_list_scroll,
        d_alv_sort_postn,
        d_alv_keyinfo,
        d_alv_fieldcat,
        d_alv_formname,
        d_alv_ucomm,
        d_alv_print,
        d_alv_repid,
        d_alv_tabix,
        d_alv_subrc,
        d_alv_screen_start_column,
        d_alv_screen_start_line,
        d_alv_screen_end_column,
        d_alv_screen_end_line,
        d_alv_layout,
        d_layout,
        d_repid,
        d_print.


  REFRESH: t_alv_fieldcat,
           t_alv_event,
           t_events,
           t_alv_isort,
           t_alv_filter,
           t_event_exit.

  d_repid = sy-repid.
ENDFORM.                    " f_clear_alv_data



*---------------------------------------------------------------------*
*       FORM f_set_pf_status                                          *
*---------------------------------------------------------------------*
FORM f_set_pf_status USING rt_extab TYPE slis_t_extab.
  sy-lsind = 0.
  CASE 'X'.
    WHEN radio1.
      SET PF-STATUS 'STANDARD'.
  ENDCASE.
ENDFORM.                    " F_SET_PF_STATUS

*---------------------------------------------------------------------*
*       FORM f_gui_message                                            *
*---------------------------------------------------------------------*
FORM f_gui_message USING fu_text1 fu_text2.
  DATA: ld_text1(100)    TYPE c.

  CONCATENATE fu_text1 fu_text2 INTO ld_text1
              SEPARATED BY space.
  CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
    EXPORTING
      percentage = 0
      text       = ld_text1.
ENDFORM.                    "f_gui_message


*&---------------------------------------------------------------------*
*&      Form  F_ALV_VARIANT_EXIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_alv_variant_exist USING     fu_vari
                         CHANGING  fc_alv_variant STRUCTURE disvariant.

  IF NOT fu_vari IS INITIAL.
    MOVE fu_vari TO fc_alv_variant-variant.
    fc_alv_variant-report = d_repid.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = fc_alv_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.
    IF sy-subrc <> 0.
      IF NOT sy-msgid IS INITIAL.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    CLEAR fc_alv_variant.
    fc_alv_variant-report = sy-repid.
  ENDIF.


ENDFORM.                    " F_ALV_VARIANT_EXIST

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data .
  DATA: ld_rows    TYPE i,
        ld_openu(15),
        ld_sw      TYPE i,
        ld_werks   LIKE s934-werks.
  DATA: ld_openut  LIKE zmm_ret_stock-labst,
        ld_inuut   LIKE zmm_ret_stock-inuu.
  DATA: lt_subt    LIKE t_result OCCURS 0 WITH HEADER LINE,
        lt_total   LIKE t_result OCCURS 0 WITH HEADER LINE.

  LOOP AT t_s934.
    t_mutasi-matnr  = t_s934-matnr.
    t_mutasi-werks  = t_s934-werks.
    t_mutasi-lgort  = t_s934-lgort.
    t_mutasi-budat  = t_s934-budat.
    IF t_s934-bwart IN ra_inblk.
      t_mutasi-inblk  = t_s934-menge.
    ENDIF.
    IF t_s934-bwart IN ra_otblk.
      t_mutasi-otblk  = t_s934-menge.
    ENDIF.
    IF t_s934-bwart IN ra_inuu.
      t_mutasi-inuu  = t_s934-menge.
    ENDIF.
    IF t_s934-bwart IN ra_otuu.
      t_mutasi-otuu  = t_s934-menge.
    ENDIF.
    IF t_s934-bwart IN ra_inqi.
      t_mutasi-inqi  = t_s934-menge.
    ENDIF.
    IF t_s934-bwart IN ra_otqi.
      t_mutasi-otqi  = t_s934-menge.
    ENDIF.
    COLLECT t_mutasi.
    CLEAR: t_mutasi.
  ENDLOOP.

  SORT t_vdata BY werks matnr.
  LOOP AT t_vdata.
    IF ld_sw IS INITIAL.
      ld_sw  = 1.
      ld_werks  = t_vdata-werks.
    ENDIF.

    IF t_vdata-werks NE ld_werks.
      ld_werks         = t_vdata-werks.
      t_result-rows    = 999.
      t_result-matnr   = 'Sub Total'.
      t_result-color   = 'C31'.
      PERFORM f_write_sub_total TABLES lt_subt lt_total t_result
                                USING 'SUB'.
      CLEAR: t_result-budat, t_result-matkl, t_result-meins,
             t_result-maktx.
      CLEAR: lt_subt.
      REFRESH: lt_subt.
      APPEND t_result.
    ENDIF.

    MOVE-CORRESPONDING t_vdata TO t_result.
    t_result-color  = 'C30'.
    ADD 1 TO ld_rows.
    t_result-rows  = ld_rows.

    WRITE t_vdata-inuu TO t_result-inu1 UNIT t_vdata-meins NO-SIGN.
    WRITE t_vdata-otuu TO t_result-otu1 UNIT t_vdata-meins NO-SIGN.
    WRITE t_vdata-inqi TO t_result-inq1 UNIT t_vdata-meins NO-SIGN.
    WRITE t_vdata-otqi TO t_result-otq1 UNIT t_vdata-meins NO-SIGN.
    WRITE t_vdata-inblk TO t_result-inb1 UNIT t_vdata-meins NO-SIGN.
    WRITE t_vdata-otblk TO t_result-otb1 UNIT t_vdata-meins NO-SIGN.

    WRITE t_vdata-openu TO t_result-openu UNIT t_vdata-meins.
    WRITE t_vdata-openq TO t_result-openq UNIT t_vdata-meins.
    WRITE t_vdata-openb TO t_result-openb UNIT t_vdata-meins.

    WRITE t_vdata-labst TO t_result-endu UNIT t_vdata-meins.
    WRITE t_vdata-insme TO t_result-endq UNIT t_vdata-meins.
    WRITE t_vdata-speme TO t_result-endb UNIT t_vdata-meins.

    t_result-openu1 = t_vdata-openu.
    t_result-openq1 = t_vdata-openq.
    t_result-openb1 = t_vdata-openb.

    t_result-endu1 = t_vdata-labst.
    t_result-endq1 = t_vdata-insme.
    t_result-endb1 = t_vdata-speme.

    PERFORM f_calc_sub_total TABLES t_vdata lt_subt lt_total.
    APPEND t_result.

    LOOP AT t_mutasi WHERE werks EQ t_vdata-werks AND
                           matnr EQ t_vdata-matnr AND
                           lgort EQ t_vdata-lgort.
      MOVE-CORRESPONDING t_mutasi TO t_result.
      IF ld_rows EQ 1.
        ADD 1 TO ld_rows.
      ENDIF.

      WRITE t_mutasi-inuu TO t_result-inu1 UNIT t_vdata-meins NO-SIGN.
      WRITE t_mutasi-otuu TO t_result-otu1 UNIT t_vdata-meins NO-SIGN.
      WRITE t_mutasi-inqi TO t_result-inq1 UNIT t_vdata-meins NO-SIGN.
      WRITE t_mutasi-otqi TO t_result-otq1 UNIT t_vdata-meins NO-SIGN.
      WRITE t_mutasi-inblk TO t_result-inb1 UNIT t_vdata-meins NO-SIGN.
      WRITE t_mutasi-otblk TO t_result-otb1 UNIT t_vdata-meins NO-SIGN.

      t_result-rows   = ld_rows.
      t_result-meins  = t_vdata-meins.
      t_result-color  = 'C20'.
      CLEAR: t_result-openu, t_result-openq, t_result-openb,
             t_result-endu, t_result-endq, t_result-endb.
      APPEND t_result.
    ENDLOOP.
    CLEAR: ld_rows.
  ENDLOOP.

  t_result-rows   = 998.
  t_result-matnr  = 'Sub total'.
  t_result-color  = 'C31'.
  PERFORM f_write_sub_total TABLES lt_subt lt_total t_result
                            USING 'SUB'.
  CLEAR: t_result-budat, t_result-matkl, t_result-meins,
         t_result-maktx.
  CLEAR: lt_subt.
  REFRESH: lt_subt.
  APPEND t_result.

  t_result-rows   = 999.
  t_result-matnr  = 'Total'.
  t_result-werks  = '9999'.
  t_result-color  = 'C31'.
  PERFORM f_write_sub_total TABLES lt_subt lt_total t_result
                            USING 'TOTAL'.
  CLEAR: t_result-budat, t_result-matkl, t_result-meins,
         t_result-maktx.
  CLEAR: lt_subt.
  REFRESH: lt_subt.
  APPEND t_result.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.
  DATA: ld_break  TYPE i.

  CASE 'X'.
    WHEN radio1.
      DELETE t_result WHERE color EQ 'C20'.
      DELETE t_result WHERE color EQ 'C31'.
      LOOP AT t_result.
        t_result-color  = 'C20'.
        WRITE t_result-uuval TO t_result-endvu CURRENCY 'IDR'.
        WRITE t_result-qival TO t_result-endvq CURRENCY 'IDR'.
        WRITE t_result-blckval TO t_result-endvb CURRENCY 'IDR'.
        MODIFY t_result TRANSPORTING color endvu endvq endvb.
      ENDLOOP.
    WHEN radio2.
      SORT t_result BY werks matnr rows budat DESCENDING.
      LOOP AT t_result.
        ADD 1 TO t_result-lines.
        IF t_result-inuu LT 0.
          t_result-inuu = t_result-inuu * -1.
        ENDIF.
        IF t_result-inqi LT 0.
          t_result-inqi = t_result-inqi * -1.
        ENDIF.
        IF t_result-inblk LT 0.
          t_result-inblk = t_result-inblk * -1.
        ENDIF.
        IF t_result-otuu LT 0.
          t_result-otuu = t_result-otuu * -1.
        ENDIF.
        IF t_result-otqi LT 0.
          t_result-otqi = t_result-otqi * -1.
        ENDIF.
        IF t_result-otblk LT 0.
          t_result-otblk = t_result-otblk * -1.
        ENDIF.

        IF t_result-color EQ 'C30'.
          WRITE t_result-uuval TO t_result-endvu CURRENCY 'IDR'.
          WRITE t_result-qival TO t_result-endvq CURRENCY 'IDR'.
          WRITE t_result-blckval TO t_result-endvb CURRENCY 'IDR'.
        ELSE.
          CLEAR: t_result-endvu, t_result-endvq, t_result-endvb.
        ENDIF.

        ON CHANGE OF t_result-werks OR t_result-matnr.
          ADD 1 TO ld_break.
        ENDON.

        IF t_result-werks EQ '9999'.
          CLEAR: t_result-werks.
        ENDIF.

        t_result-break  = ld_break.
        MODIFY t_result TRANSPORTING lines break werks
                                     inuu inqi inblk
                                     otuu otqi otblk
                                     endvu endvq endvb.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " f_validate_data

*---------------------------------------------------------------------*
*       FORM f_user_command                                           *
*---------------------------------------------------------------------*
FORM f_user_command USING fu_ucomm LIKE sy-ucomm
                          fu_selfield TYPE slis_selfield.

  DATA: lt_dynpread    LIKE dynpread OCCURS 0 WITH HEADER LINE.
  REFRESH: lt_dynpread.

  CASE fu_ucomm.
    WHEN '&POS'.
      PERFORM f_post_entries.
  ENDCASE.

ENDFORM.                    "f_user_command

*&---------------------------------------------------------------------*
*&      Form  f_post_entries
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_post_entries.

ENDFORM.                    " f_post_entries

*&---------------------------------------------------------------------*
*&      Form  F_F4_FOR_VARIANT_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f_f4_for_variant_alv CHANGING fc_variant.

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
ENDFORM.                    " F_F4_FOR_VARIANT_ALV

*data: gs_lineinfo type kkblo_lineinfo.
FORM f_after_line_output USING lineinfo TYPE slis_lineinfo.
  BREAK-POINT.
ENDFORM.                    "f_after_line_output

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_SCREEN_1000
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_screen_1000 .
  DATA: ld_mess(50) VALUE 'Fill in all required entry fields'.

  IF so_budat-low IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 EQ 'BDT'.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE e000(zab) WITH ld_mess.
    CLEAR: sscrfields-ucomm.
  ELSE.
    IF so_budat-high IS NOT INITIAL.
      IF so_budat-low(6) NE so_budat-high(6).
        LOOP AT SCREEN.
          IF screen-group1 EQ 'BDT'.
            screen-input  = 1.
          ELSE.
            screen-input  = 0.
          ENDIF.
          MODIFY SCREEN.
        ENDLOOP.
        MESSAGE e000(zab) WITH 'Period error'.
        CLEAR: sscrfields-ucomm.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_VALIDATE_SCREEN_1000

*&---------------------------------------------------------------------*
*&      Form  F_HEADER
*&---------------------------------------------------------------------*
FORM f_header  USING    fu_title fu_budat.
  DATA: ld_tanggal(50).
  WRITE fu_budat TO ld_tanggal.
  CONCATENATE 'Per' ld_tanggal INTO ld_tanggal
  SEPARATED BY space.
  WRITE: / fu_title.
  WRITE: / ld_tanggal.
  SKIP 1.
ENDFORM.                    " F_HEADER

*&---------------------------------------------------------------------*
*&      Form  F_CALC_SUB_TOTAL
*&---------------------------------------------------------------------*
FORM f_calc_sub_total  TABLES   ft_vdata STRUCTURE t_vdata
                                ft_sub STRUCTURE t_result
                                ft_total STRUCTURE t_result.

  ADD ft_vdata-openu TO ft_sub-openu.
  ADD ft_vdata-inuu TO ft_sub-inuu.
  ADD ft_vdata-otuu TO ft_sub-otuu.
  ADD ft_vdata-labst TO ft_sub-endu.

  ADD ft_vdata-openq TO ft_sub-openq.
  ADD ft_vdata-inqi TO ft_sub-inqi.
  ADD ft_vdata-otqi TO ft_sub-otqi.
  ADD ft_vdata-insme TO ft_sub-endq.

  ADD ft_vdata-openb TO ft_sub-openb.
  ADD ft_vdata-inblk TO ft_sub-inblk.
  ADD ft_vdata-otblk TO ft_sub-otblk.
  ADD ft_vdata-speme TO ft_sub-endb.

  ADD ft_vdata-openu TO ft_total-openu.
  ADD ft_vdata-inuu TO ft_total-inuu.
  ADD ft_vdata-otuu TO ft_total-otuu.
  ADD ft_vdata-labst TO ft_total-endu.

  ADD ft_vdata-openq TO ft_total-openq.
  ADD ft_vdata-inqi TO ft_total-inqi.
  ADD ft_vdata-otqi TO ft_total-otqi.
  ADD ft_vdata-insme TO ft_total-endq.

  ADD ft_vdata-openb TO ft_total-openb.
  ADD ft_vdata-inblk TO ft_total-inblk.
  ADD ft_vdata-otblk TO ft_total-otblk.
  ADD ft_vdata-speme TO ft_total-endb.
ENDFORM.                    " F_CALC_SUB_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_SUB_TOTAL
*&---------------------------------------------------------------------*
FORM f_write_sub_total  TABLES   ft_res1 STRUCTURE t_result
                                 ft_res2 STRUCTURE t_result
                                 ft_res3 STRUCTURE t_result
                        USING    fu_write.

  CASE fu_write.
    WHEN 'SUB'.
      WRITE ft_res1-openu TO ft_res3-openu DECIMALS 0.
      WRITE ft_res1-inuu TO ft_res3-inu1 DECIMALS 0 NO-SIGN.
      WRITE ft_res1-otuu TO ft_res3-otu1 DECIMALS 0 NO-SIGN.
      WRITE ft_res1-endu TO ft_res3-endu DECIMALS 0 NO-SIGN.

      WRITE ft_res1-openq TO ft_res3-openq DECIMALS 0.
      WRITE ft_res1-inqi TO ft_res3-inq1 DECIMALS 0 NO-SIGN.
      WRITE ft_res1-otqi TO ft_res3-otq1 DECIMALS 0 NO-SIGN.
      WRITE ft_res1-endq TO ft_res3-endq DECIMALS 0 NO-SIGN.

      WRITE ft_res1-openb TO ft_res3-openb DECIMALS 0.
      WRITE ft_res1-inblk TO ft_res3-inb1 DECIMALS 0 NO-SIGN.
      WRITE ft_res1-otblk TO ft_res3-otb1 DECIMALS 0 NO-SIGN.
      WRITE ft_res1-endb TO ft_res3-endb DECIMALS 0 NO-SIGN.

    WHEN 'TOTAL'.
      WRITE ft_res2-openu TO ft_res3-openu DECIMALS 0.
      WRITE ft_res2-inuu TO ft_res3-inu1 DECIMALS 0 NO-SIGN.
      WRITE ft_res2-otuu TO ft_res3-otu1 DECIMALS 0 NO-SIGN.
      WRITE ft_res2-endu TO ft_res3-endu DECIMALS 0 NO-SIGN.

      WRITE ft_res2-openq TO ft_res3-openq DECIMALS 0.
      WRITE ft_res2-inqi TO ft_res3-inq1 DECIMALS 0 NO-SIGN.
      WRITE ft_res2-otqi TO ft_res3-otq1 DECIMALS 0 NO-SIGN.
      WRITE ft_res2-endq TO ft_res3-endq DECIMALS 0 NO-SIGN.

      WRITE ft_res2-openb TO ft_res3-openb DECIMALS 0.
      WRITE ft_res2-inblk TO ft_res3-inb1 DECIMALS 0 NO-SIGN.
      WRITE ft_res2-otblk TO ft_res3-otb1 DECIMALS 0 NO-SIGN.
      WRITE ft_res2-endb TO ft_res3-endb DECIMALS 0 NO-SIGN.
  ENDCASE.
ENDFORM.                    " F_WRITE_SUB_TOTAL
