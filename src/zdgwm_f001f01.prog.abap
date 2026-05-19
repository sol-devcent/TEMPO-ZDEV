*----------------------------------------------------------------------*
*   INCLUDE ZDGWM_F001F01                                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  f_process_report
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_report.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_validate_data.
  PERFORM f_process_data.
  PERFORM f_print_form.
  PERFORM f_free_memory.
ENDFORM.                    " f_process_report
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
  DATA: lt_mara LIKE t_mseg OCCURS 0 WITH HEADER LINE,
        lt_lfa1 LIKE t_mseg OCCURS 0 WITH HEADER LINE,
        lt_mch1 LIKE t_mseg OCCURS 0 WITH HEADER LINE,
        lt_mlgn LIKE t_mseg OCCURS 0 WITH HEADER LINE.

  SELECT mblnr mjahr zeile matnr werks lgort charg lifnr menge meins
         ebeln aufnr bukrs lgnum
    FROM mseg
    INTO TABLE t_mseg
    WHERE mblnr EQ p_mblnr AND
          mjahr EQ p_mjahr AND
          bwart NE '261'.

  wa_header-mblnr = p_mblnr.
  READ TABLE t_mseg WITH KEY bukrs = '8230'
                             werks = '2300'
                             lgort = '2000'.
  IF sy-subrc EQ 0.
    SELECT SINGLE bktxt
      FROM mkpf
      INTO wa_header-bktxt
      WHERE mblnr EQ p_mblnr.
    IF wa_header-bktxt IS NOT INITIAL.
      wa_header-bktxt = 'FOR SET DEAL'.
    ENDIF.
  ENDIF.

  READ TABLE t_mseg INDEX 1.
  IF sy-subrc EQ 0.
    IF t_mseg-werks EQ '0501'.
      SELECT SINGLE name1
        FROM twlad AS a JOIN adrc AS b ON a~adrnr EQ b~addrnumber
        INTO wa_header-name1
        WHERE werks EQ t_mseg-werks AND
              lgort EQ t_mseg-lgort.
    ELSE.
      SELECT SINGLE butxt
        FROM t001k AS a JOIN t001 AS b ON a~bukrs EQ b~bukrs
        INTO wa_header-name1
        WHERE bwkey EQ t_mseg-werks.
    ENDIF.
  ENDIF.

  lt_mara[] = t_mseg[].
  SORT lt_mara BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_mara COMPARING matnr.
  IF lt_mara[] IS NOT INITIAL.
    SELECT a~matnr mtart maktx
      FROM mara AS a JOIN makt AS b ON a~matnr EQ b~matnr
      INTO TABLE t_mara
      FOR ALL ENTRIES IN lt_mara
      WHERE a~matnr EQ lt_mara-matnr.

    SELECT matnr meinh umrez
      FROM marm
      INTO TABLE t_marm
      FOR ALL ENTRIES IN t_mara
      WHERE matnr EQ t_mara-matnr.
  ENDIF.

  lt_mlgn[] = t_mseg[].
  SORT lt_mlgn BY matnr lgnum.
  DELETE ADJACENT DUPLICATES FROM lt_mlgn COMPARING matnr lgnum.
  IF lt_mlgn[] IS NOT INITIAL.
    SELECT matnr lgnum lhmg1
      FROM mlgn
      INTO TABLE t_mlgn
      FOR ALL ENTRIES IN lt_mlgn
      WHERE matnr EQ lt_mlgn-matnr AND
            lgnum EQ lt_mlgn-lgnum.
  ENDIF.

  lt_lfa1[] = t_mseg[].
  SORT lt_lfa1 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_lfa1 COMPARING lifnr.
  IF lt_lfa1[] IS NOT INITIAL.
    SELECT lifnr name1
      FROM lfa1
      INTO TABLE t_lfa1
      FOR ALL ENTRIES IN lt_lfa1
      WHERE lifnr EQ lt_lfa1-lifnr.
  ENDIF.

  lt_mch1[] = t_mseg[].
  SORT lt_mch1 BY matnr charg.
  DELETE ADJACENT DUPLICATES FROM lt_mch1 COMPARING matnr charg.
  IF lt_mch1[] IS NOT INITIAL.
    SELECT matnr charg vfdat licha lwedt hsdat
      FROM mch1
      INTO TABLE t_mch1
      FOR ALL ENTRIES IN lt_mch1
      WHERE matnr EQ lt_mch1-matnr AND
            charg EQ lt_mch1-charg.
  ENDIF.

  IF t_mseg[] IS NOT INITIAL.
    SELECT mblnr mjahr zeile prueflos
      FROM qamb
      INTO TABLE t_qamb
      FOR ALL ENTRIES IN t_mseg
      WHERE mblnr EQ t_mseg-mblnr AND
            mjahr EQ t_mseg-mjahr AND
            zeile EQ t_mseg-zeile.
  ENDIF.
ENDFORM.                    " f_get_data
*&---------------------------------------------------------------------*
*&      Form  f_validate_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_validate_data.

ENDFORM.                    " f_validate_data
*&---------------------------------------------------------------------*
*&      Form  f_process_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_process_data.
  DATA: ld_qty      TYPE mseg-menge,
        ld_qty01    TYPE mseg-menge,
        ld_qty02    TYPE mseg-menge,
        ld_umrez    TYPE marm-umrez,
        ld_lhmg1    TYPE mlgn-lhmg1,
        ld_umrez1   TYPE marm-umrez,
        ld_lhmg11   TYPE mlgn-lhmg1,
        ld_label    TYPE zdgstwm_pl_detail-pallet,
        ld_flag     TYPE i,
        ld_popup    TYPE i,
        ld_subrc    TYPE sy-subrc,
        ld_pallet   TYPE mseg-menge,
        ld_table(4).

  LOOP AT t_mseg.
    t_detail-matnr  = t_mseg-matnr.
    READ TABLE t_mara WITH KEY matnr = t_mseg-matnr.
    IF sy-subrc EQ 0.
      t_detail-mtart  = t_mara-mtart.
      t_detail-maktx  = t_mara-maktx.
    ENDIF.
    t_detail-lifnr  = t_mseg-lifnr.
    READ TABLE t_lfa1 WITH KEY lifnr = t_mseg-lifnr.
    IF sy-subrc EQ 0.
      t_detail-name1  = t_lfa1-name1.
    ENDIF.
    t_detail-charg  = t_mseg-charg.
    READ TABLE t_mch1 WITH KEY matnr = t_mseg-matnr
                               charg = t_mseg-charg.
    IF sy-subrc EQ 0.
      IF t_mch1-licha IS NOT INITIAL.
        t_detail-licha  = t_mch1-licha.
      ELSE.
        t_detail-licha  = 'N/A'.
      ENDIF.
      IF t_mch1-hsdat IS NOT INITIAL.
        WRITE t_mch1-hsdat TO t_detail-hsdat DD/MM/YYYY.
      ELSE.
        t_detail-hsdat  = 'N/A'.
      ENDIF.
      IF t_mch1-vfdat IS NOT INITIAL.
        WRITE t_mch1-vfdat TO t_detail-vfdat DD/MM/YYYY.
      ELSE.
        t_detail-vfdat  = 'N/A'.
      ENDIF.
      IF t_mch1-lwedt IS NOT INITIAL.
        WRITE t_mch1-lwedt TO t_detail-lwedt DD/MM/YYYY.
      ELSE.
        t_detail-lwedt  = 'N/A'.
      ENDIF.
    ENDIF.
    READ TABLE t_qamb WITH KEY mblnr = t_mseg-mblnr
                               mjahr = t_mseg-mjahr
                               zeile = t_mseg-zeile.
    IF sy-subrc EQ 0.
      t_detail-prueflos = t_qamb-prueflos.
    ELSE.
      t_detail-prueflos = 'N/A'.
    ENDIF.

    IF t_mseg-ebeln IS INITIAL.
      t_detail-poordert = 'Order'.
      t_detail-poorder  = t_mseg-aufnr.
    ELSE.
      t_detail-poordert = 'PO'.
      t_detail-poorder  = t_mseg-ebeln.
    ENDIF.

    t_detail-werks  = t_mseg-werks.
    t_detail-lgort  = t_mseg-lgort.

    ld_table  = 'MLGN'.
    PERFORM f_get_marm USING 'PAL' t_mseg-matnr t_mseg-lgnum ld_table
                       CHANGING ld_umrez ld_lhmg1 ld_subrc.
    IF ld_lhmg1 IS INITIAL.
      CLEAR: ld_subrc.
      ld_table  = 'MARM'.
      PERFORM f_get_marm USING 'PAL' t_mseg-matnr t_mseg-lgnum ld_table
                         CHANGING ld_umrez ld_lhmg1 ld_subrc.
    ENDIF.
    IF ld_subrc IS INITIAL.
      CLEAR: ld_popup.
      CASE ld_table.
        WHEN 'MARM'.
          IF t_mseg-menge GT ld_umrez.
            IF ld_umrez IS NOT INITIAL.
              ld_pallet       = t_mseg-menge  / ld_umrez.
              t_detail-pallet = ceil( ld_pallet ).
              ld_umrez1       = ld_umrez.
              ld_qty          = ld_umrez.
            ENDIF.
          ELSE.
            t_detail-pallet = 1.
            ld_qty          = t_mseg-menge.
          ENDIF.
        WHEN 'MLGN'.
          IF t_mseg-menge GT ld_lhmg1.
            IF ld_lhmg1 IS NOT INITIAL.
              ld_pallet       = t_mseg-menge  / ld_lhmg1.
              t_detail-pallet = ceil( ld_pallet ).
              ld_lhmg11       = ld_lhmg1.
              ld_qty          = ld_lhmg1.
            ENDIF.
          ELSE.
            t_detail-pallet = 1.
            ld_qty          = t_mseg-menge.
          ENDIF.
      ENDCASE.
    ELSE.
      ld_popup  = 1.

      "Start - SOH Adjustment (2024/08/18)
*      CALL FUNCTION 'POPUP_TO_FILL_COMMAND_LINE'
*        EXPORTING
*          popuptitle   = 'Jumlah Pallet Label'
*          text1        = t_detail-maktx
*        IMPORTING
*          command_line = t_detail-pallet.

      DATA: lv_rtncd(1),
            gt_fields TYPE STANDARD TABLE OF sval,
            wa_fields LIKE LINE OF gt_fields.

          wa_fields-tabname   = 'ZDGSTWM_PL_DETAIL'.
          wa_fields-fieldname = 'PALLET'.
          APPEND wa_fields TO gt_fields.

      CALL FUNCTION 'POPUP_GET_VALUES'
        EXPORTING
          popup_title     = 'Jumlah Pallet Label'
          start_column    = '20'
          start_row       = '5'
        IMPORTING
          returncode      = lv_rtncd
        TABLES
          fields          = gt_fields
        EXCEPTIONS
          error_in_fields = 1
          OTHERS          = 2.
      IF sy-subrc = 0.
        READ TABLE gt_fields INTO wa_fields INDEX 1.
        t_detail-pallet = wa_fields-value.
      ELSE.
* Implement suitable error handling here
      ENDIF.
      "End - SOH Adjustment (2024/08/18)

    ENDIF.

    IF t_detail-werks EQ '0200' AND
      t_detail-lgort EQ '1000'.
      t_detail-barcode = 'X'.
    ELSEIF t_detail-werks EQ '2300' AND
      t_detail-mtart EQ 'ZCGB'.
      t_detail-barcode  = 'X'.
    ELSEIF t_detail-werks EQ '0501' AND
      t_detail-lgort EQ '1150'.
      t_detail-barcode = 'X'.
    ENDIF.

    IF ld_popup IS INITIAL.
      IF t_detail-pallet GT 1.
        DO t_detail-pallet TIMES.
          ADD 1 TO ld_flag.
          IF ld_flag LT t_detail-pallet.
            IF ld_subrc IS INITIAL.
              IF ld_lhmg1 IS INITIAL.
                ld_table  = 'MARM'.
              ELSE.
                ld_table  = 'MLGN'.
              ENDIF.
              CASE ld_table.
                WHEN 'MARM'.
                  ld_qty  = ld_umrez1.
                WHEN 'MLGN'.
                  ld_qty  = ld_lhmg11.
              ENDCASE.
            ELSE.
              ld_qty  = t_mseg-menge.
            ENDIF.
          ELSE.
            IF ld_lhmg1 IS INITIAL.
              ld_table  = 'MARM'.
            ELSE.
              ld_table  = 'MLGN'.
            ENDIF.
            CASE ld_table.
              WHEN 'MARM'.
                ld_qty  = t_mseg-menge - ( ld_umrez1 * ( t_detail-pallet - 1 ) ).
              WHEN 'MLGN'.
                ld_qty  = t_mseg-menge - ( ld_lhmg11 * ( t_detail-pallet - 1 ) ).
            ENDCASE.
          ENDIF.

          WRITE ld_qty TO t_detail-qty01 UNIT t_mseg-meins.
          ld_qty01  = ld_qty.
          CLEAR: t_detail-qty02, t_detail-uom02, ld_qty02.
* Get Carton
          ld_table  = 'MARM'.
          PERFORM f_get_marm USING 'KAR' t_mseg-matnr t_mseg-lgnum ld_table
                             CHANGING ld_umrez ld_lhmg1 ld_subrc.
          IF ld_umrez IS NOT INITIAL.
            ld_qty          = ld_qty / ld_umrez.
            t_detail-qty02  = ceil( ld_qty ).
            ld_qty02        = ceil( ld_qty ).
            t_detail-uom02  = 'CAR'.
          ENDIF.

          CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
            EXPORTING
              input          = t_mseg-meins
              language       = sy-langu
            IMPORTING
              output         = t_detail-uom01
            EXCEPTIONS
              unit_not_found = 1
              OTHERS         = 2.

          IF ld_qty01 EQ 0.
            CLEAR: t_detail-qty01, t_detail-uom01, ld_qty01.
          ENDIF.
          IF ld_qty02 EQ 0.
            CLEAR: t_detail-qty02, t_detail-uom02, ld_qty02.
          ENDIF.
          APPEND t_detail.
        ENDDO.
      ELSE.
        WRITE ld_qty TO t_detail-qty01 UNIT t_mseg-meins.
        ld_qty01  = ld_qty.
* Get Carton
        ld_table  = 'MARM'.
        PERFORM f_get_marm USING 'KAR' t_mseg-matnr t_mseg-lgnum ld_table
                           CHANGING ld_umrez ld_lhmg1 ld_subrc.
        IF ld_umrez IS NOT INITIAL.
          ld_qty          = ld_qty / ld_umrez.
          t_detail-qty02  = ceil( ld_qty ).
          ld_qty02        = ceil( ld_qty ).
          t_detail-uom02  = 'CAR'.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = t_mseg-meins
            language       = sy-langu
          IMPORTING
            output         = t_detail-uom01
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.

        IF ld_qty01 EQ 0.
          CLEAR: t_detail-qty01, t_detail-uom01, ld_qty01.
        ENDIF.
        IF ld_qty02 EQ 0.
          CLEAR: t_detail-qty02, t_detail-uom02, ld_qty02.
        ENDIF.
        APPEND t_detail.
      ENDIF.
    ELSE.
      DO t_detail-pallet TIMES.
        ADD 1 TO ld_flag.
        IF ld_subrc IS INITIAL.
          IF ld_lhmg1 IS INITIAL.
            ld_table  = 'MARM'.
          ELSE.
            ld_table  = 'MLGN'.
          ENDIF.
          CASE ld_table.
            WHEN 'MARM'.
              ld_qty  = ld_umrez1.
            WHEN 'MLGN'.
              ld_qty  = ld_lhmg11.
          ENDCASE.
        ELSE.
          ld_qty  = t_mseg-menge.
        ENDIF.
        WRITE ld_qty TO t_detail-qty01 UNIT t_mseg-meins.
        ld_qty01  = ld_qty.
        CLEAR: t_detail-qty02, t_detail-uom02.

* Get Carton
        ld_table  = 'MARM'.
        PERFORM f_get_marm USING 'KAR' t_mseg-matnr t_mseg-lgnum ld_table
                           CHANGING ld_umrez ld_lhmg1 ld_subrc.
        IF ld_umrez IS NOT INITIAL.
          ld_qty          = ld_qty / ld_umrez.
          t_detail-qty02  = ceil( ld_qty ).
          ld_qty02        = ceil( ld_qty ).
          t_detail-uom02  = 'CAR'.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
          EXPORTING
            input          = t_mseg-meins
            language       = sy-langu
          IMPORTING
            output         = t_detail-uom01
          EXCEPTIONS
            unit_not_found = 1
            OTHERS         = 2.

        IF ld_qty01 EQ 0.
          CLEAR: t_detail-qty01, t_detail-uom01, ld_qty01.
        ENDIF.
        IF ld_qty02 EQ 0.
          CLEAR: t_detail-qty02, t_detail-uom02, ld_qty02.
        ENDIF.
        APPEND t_detail.
      ENDDO.
    ENDIF.
    CLEAR: t_detail, ld_subrc, ld_flag.
  ENDLOOP.
ENDFORM.                    " f_process_data
*&---------------------------------------------------------------------*
*&      Form  f_print_form
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_form.
  DATA: i_detail  LIKE t_detail OCCURS 0 WITH HEADER LINE.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  IF d_frm_subrc IS INITIAL.
    d_output_opt-tdimmed  = nast-dimme.
    d_output_opt-tddelete = nast-delet.
    d_output_opt-tdcopies = nast-anzal.

    LOOP AT t_detail.
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.
      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.
      CALL FUNCTION d_smrt_funcmod
        EXPORTING
          control_parameters = d_ctrl_param
          output_options     = d_output_opt
          user_settings      = space
          wa_header          = wa_header
          t_detail           = t_detail.
      d_ctrl_param-no_open = 'X'.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " f_print_form
*&---------------------------------------------------------------------*
*&      Form  f_free_memory
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_memory.
  CLEAR: wa_header, t_detail.
  REFRESH: t_detail.
ENDFORM.                    " f_free_memory

*&---------------------------------------------------------------------*
*&      Form  F_GET_MARM
*&---------------------------------------------------------------------*
FORM f_get_marm  USING    fu_meinh fu_matnr fu_lgnum fu_table
                 CHANGING fc_umrez fc_lhmg1 fc_subrc.

  CASE fu_table.
    WHEN 'MARM'.
      READ TABLE t_marm WITH KEY matnr = fu_matnr
                                 meinh = fu_meinh.
      IF sy-subrc EQ 0.
        fc_umrez  = t_marm-umrez.
      ELSE.
        fc_umrez  = 0.
        fc_subrc  = 1.
      ENDIF.
    WHEN 'MLGN'.
      READ TABLE t_mlgn WITH KEY matnr = fu_matnr
                                 lgnum = fu_lgnum.
      IF sy-subrc EQ 0.
        fc_lhmg1  = t_mlgn-lhmg1.
      ELSE.
        fc_umrez  = 0.
        fc_subrc  = 1.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_GET_MARM
