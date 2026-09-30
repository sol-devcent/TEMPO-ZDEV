*----------------------------------------------------------------------*
***INCLUDE LZHGFG001F03.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_CONFIM_PUTAWAY
*&---------------------------------------------------------------------*
FORM f_confim_putaway  TABLES   ft_to   STRUCTURE zhgwmst002
                       USING    p_json
                       CHANGING fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_data      TYPE ty_confirm,
         lt_to        TYPE STANDARD TABLE OF zhgwmst002,
         ls_to        LIKE LINE OF lt_to,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         ls_ltap      LIKE LINE OF lt_ltap.

  DATA : lv_subrc TYPE sy-subrc.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_data ).

  lt_to[] = ls_data-nav_conf[].
  IF lt_to[] IS NOT INITIAL.
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE lt_ltap
      FOR ALL ENTRIES IN lt_to
      WHERE lgnum = ls_data-warehouse_number
        AND tanum = lt_to-to_number.
  ENDIF.

  LOOP AT lt_to INTO ls_to.
    ls_to-type      = 'S'.
    ls_to-message   = 'Berhasil confirm'.
    APPEND ls_to TO ft_to.
    CLEAR : ls_to.
  ENDLOOP.

  IF fc_type = 'E'.
    fc_message   = 'TO confirm error'.
  ELSE.
    fc_type      = 'S'.
    fc_message   = 'Berhasil confirm'.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONFIRM_TO
*&---------------------------------------------------------------------*
FORM f_confirm_to  TABLES   t_ltap_conf   STRUCTURE ltap_conf
                   USING    fu_lgnum fu_tanum fu_squit fu_quknz
                   CHANGING fc_subrc.
  CALL FUNCTION 'L_TO_CONFIRM'
    EXPORTING
      i_lgnum                        = fu_lgnum
      i_tanum                        = fu_tanum
      i_squit                        = fu_squit
      i_quknz                        = fu_quknz
    TABLES
      t_ltap_conf                    = t_ltap_conf
    EXCEPTIONS
      to_confirmed                   = 1
      to_doesnt_exist                = 2
      item_confirmed                 = 3
      item_subsystem                 = 4
      item_doesnt_exist              = 5
      item_without_zero_stock_check  = 6
      item_with_zero_stock_check     = 7
      one_item_with_zero_stock_check = 8
      item_su_bulk_storage           = 9
      item_no_su_bulk_storage        = 10
      one_item_su_bulk_storage       = 11
      foreign_lock                   = 12
      squit_or_quantities            = 13
      vquit_or_quantities            = 14
      bquit_or_quantities            = 15
      quantity_wrong                 = 16
      double_lines                   = 17
      kzdif_wrong                    = 18
      no_difference                  = 19
      no_negative_quantities         = 20
      wrong_zero_stock_check         = 21
      su_not_found                   = 22
      no_stock_on_su                 = 23
      su_wrong                       = 24
      too_many_su                    = 25
      nothing_to_do                  = 26
      no_unit_of_measure             = 27
      xfeld_wrong                    = 28
      update_without_commit          = 29
      no_authority                   = 30
      lqnum_missing                  = 31
      charg_missing                  = 32
      no_sobkz                       = 33
      no_charg                       = 34
      nlpla_wrong                    = 35
      two_step_confirmation_required = 36
      two_step_conf_not_allowed      = 37
      pick_confirmation_missing      = 38
      quknz_wrong                    = 39
      hu_data_wrong                  = 40
      no_hu_data_required            = 41
      hu_data_missing                = 42
      hu_not_found                   = 43
      picking_of_hu_not_possible     = 44
      not_enough_stock_in_hu         = 45
      serial_number_data_wrong       = 46
      serial_numbers_not_required    = 47
      no_differences_allowed         = 48
      serial_number_not_available    = 49
      serial_number_data_missing     = 50
      to_item_split_not_allowed      = 51
      input_wrong                    = 52
      error_messages                 = 99
      OTHERS                         = 53.

  fc_subrc = sy-subrc.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_DATETIME
*&---------------------------------------------------------------------*
FORM f_datetime  USING    fu_value
                 CHANGING fc_datum fc_uzeit.
  DATA : lv_value   TYPE string.

  SPLIT fu_value AT space INTO fc_datum lv_value.
  TRANSLATE lv_value USING ': '.
  CONDENSE lv_value NO-GAPS.
  fc_uzeit  = lv_value.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CONFIRM
*&---------------------------------------------------------------------*
FORM f_confirm  USING    p_json
                CHANGING fc_type fc_message.
  DATA : lv_json_data TYPE string,
         ls_data      TYPE ty_conf,
         lt_ltap      TYPE STANDARD TABLE OF ltap,
         ls_ltap      LIKE LINE OF lt_ltap,
         lt_xltap     TYPE STANDARD TABLE OF ltap,
         ls_xltap     LIKE LINE OF lt_xltap,
         t_ltap_conf  TYPE STANDARD TABLE OF ltap_conf,
         ls_ltap_conf LIKE LINE OF t_ltap_conf.

  DATA : lv_subrc TYPE sy-subrc,
         lv_qdatu TYPE ltap-qdatu,
         lv_qzeit TYPE ltap-qzeit,
         lv_uname TYPE sy-uname,
         lv_squit TYPE rl03t-squit,
         lv_quknz TYPE rl03t-quknz.

  lv_json_data = p_json.
  zcl_json=>deserialize(
        EXPORTING
          json             = lv_json_data
        CHANGING
          data             = ls_data ).

  SELECT *
    FROM ltap
    INTO CORRESPONDING FIELDS OF TABLE lt_ltap
    WHERE matnr = ls_data-material_number
      AND nltyp = ls_data-destination_storage_type
      AND nlpla = ls_data-destination_storage_bin
      AND pquit = space.

  IF lt_ltap[] IS INITIAL.
    fc_type     = 'E'.
    fc_message   = 'TO already confirm'.
  ELSE.
    lt_xltap[] = lt_ltap[].
    SORT lt_xltap BY lgnum tanum.
    DELETE ADJACENT DUPLICATES FROM lt_xltap COMPARING lgnum tanum.

    lv_squit  = 'X'.
    lv_quknz  = '2'.

    LOOP AT lt_xltap INTO ls_xltap.
      CLEAR : t_ltap_conf[].
      LOOP AT lt_ltap INTO ls_ltap WHERE tanum = ls_xltap-tanum.
        MOVE-CORRESPONDING ls_ltap TO ls_ltap_conf.
        APPEND ls_ltap_conf TO t_ltap_conf.
        CLEAR ls_ltap_conf.
      ENDLOOP.

      lv_uname  = ls_data-username.
      PERFORM f_datetime USING ls_data-putaway_date
                         CHANGING lv_qdatu lv_qzeit.

      PERFORM f_confirm_to TABLES t_ltap_conf
                           USING ls_data-warehouse_number ls_xltap-tanum
                                 lv_squit lv_quknz
                           CHANGING lv_subrc.

      IF lv_subrc = 0.
        fc_type      = 'S'.
        fc_message   = 'TO already confirm'.

        TRY .
            UPDATE ltap SET qdatu = lv_qdatu
                            qzeit = lv_qzeit
                            qname = lv_uname
                        WHERE lgnum = ls_data-warehouse_number
                          AND tanum = ls_xltap-tanum.
          CATCH cx_sy_open_sql_db.
        ENDTRY.
      ELSE.
        fc_type     = 'E'.
        CALL FUNCTION 'ZWMSFM002'
          EXPORTING
            pi_subrc    = lv_subrc
            pi_function = 'L_TO_CONFIRM'
          IMPORTING
            pe_message  = fc_message.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
