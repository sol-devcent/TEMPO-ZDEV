*&---------------------------------------------------------------------*
*& Report  ZTNPWM_E001X
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ztnpwm_e001x NO STANDARD PAGE HEADING.

TABLES : ztnpwmst001, ltak.

TYPES : BEGIN OF ty_ltap.
        INCLUDE STRUCTURE ltap.
TYPES : zeile     TYPE ztnpwmst001-zeile,
        acqty     TYPE ztnpwmst001-acqty,
        packq     TYPE ztnpwmst001-packq,
        receh     TYPE ztnpwmst001-receh,
        pack(30),
        conversion(30).
TYPES : END OF ty_ltap.

DATA : gs_ltak    TYPE ltak,
       gt_ltap    TYPE STANDARD TABLE OF ty_ltap,
       gs_ltap    TYPE ty_ltap,
       gt_ltbk    TYPE STANDARD TABLE OF ltbk,
       gt_resb    TYPE STANDARD TABLE OF resb,
       gt_mara    TYPE STANDARD TABLE OF mara,
       gt_marc    TYPE STANDARD TABLE OF marc,
       gt_mch1    TYPE STANDARD TABLE OF mch1,
       gt_001     TYPE STANDARD TABLE OF ztnpwmst001,
       gs_001     TYPE ztnpwmst001,
       gt_save    TYPE STANDARD TABLE OF ztnpwm001.

DATA : gv_subrc   TYPE sy-subrc,
       ok_code    TYPE sy-ucomm,
       tap_index  TYPE sy-tabix VALUE 1,
       gv_record  TYPE sy-tabix,
       inp_100(100),
       gv_cursor.

DATA : gv_matnr   TYPE ztnpwmst001-matnr,
       gv_charg   TYPE ztnpwmst001-charg,
       gv_tapos   TYPE ltap-tapos,
       gv_werks   TYPE ltap-werks,
       gv_meins   TYPE ztnpwmst001-meins,
       gv_nista   TYPE ztnpwmst001-nista,
       gv_menge   TYPE ltap-nista,
       gv_pack(30).

DATA : message1(20),
       message2(20),
       message3(20),
       message4(20),
       message5(20),
       message6(20),
       message7(20).

START-OF-SELECTION.

  PERFORM f_get_whse_no.

  SET SCREEN 100.

*&---------------------------------------------------------------------*
*&      Form  F_GET_WHSE_NO
*&---------------------------------------------------------------------*
FORM f_get_whse_no .
  SELECT SINGLE lgnum
    FROM lrf_wkqu
    INTO ltak-lgnum
    WHERE bname = sy-uname
      AND statu = 'X'.
ENDFORM.                    " F_GET_WHSE_NO

*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  sy-lsind = 0.

  SET PF-STATUS 'MOBSTAT'.

  CASE sy-dynnr.
    WHEN '0100'.
      CLEAR : gv_subrc, ltak-tanum, gv_matnr, gv_charg, gt_save[].

    WHEN '0101'.
      CLEAR gv_cursor.

  ENDCASE.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  OUTPUT
*&---------------------------------------------------------------------*
MODULE validate_data OUTPUT.
  PERFORM f_validate_data.

  IF gv_subrc IS NOT INITIAL.
    CALL SCREEN 2999.
  ENDIF.
ENDMODULE.                 " VALIDATE_DATA  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_DATA
*&---------------------------------------------------------------------*
FORM f_validate_data .
  DATA : ls_ltap    LIKE LINE OF gt_ltap,
         ls_ltbk    LIKE LINE OF gt_ltbk,
         ls_resb    LIKE LINE OF gt_resb,
         ls_001     LIKE LINE OF gt_001,
         lv_subrc   TYPE sy-subrc.

  DATA : lv_zeile   TYPE ztnpwmst001-zeile.

  CASE sy-dynnr.
    WHEN '0100'.
      IF ltak-lgnum IS INITIAL.
        gv_subrc  = 1.
      ENDIF.

    WHEN '0101'.
      IF gv_subrc IS INITIAL.
        IF gs_ltak IS INITIAL OR gt_ltap[] IS INITIAL.
          gv_subrc = 2.
        ENDIF.
      ENDIF.

      IF gv_subrc IS INITIAL.
        IF ltak-tanum IS NOT INITIAL.
          CALL FUNCTION 'ENQUEUE_ELLTAKE'
            EXPORTING
              lgnum          = ltak-lgnum
              tanum          = ltak-tanum
            EXCEPTIONS
              foreign_lock   = 1
              system_failure = 2
              OTHERS         = 3.

          IF sy-subrc <> 0.
            gv_subrc = 3.
          ENDIF.
        ENDIF.
      ENDIF.

      IF gv_subrc IS INITIAL.
        LOOP AT gt_ltap INTO ls_ltap.
          IF ls_ltap-lgnum = '011' OR
            ls_ltap-lgnum = '012' OR
            ls_ltap-lgnum = '041' OR
            ls_ltap-lgnum = '042' OR
            ls_ltap-lgnum = '360' OR
            ls_ltap-lgnum = '361' OR
            ls_ltap-lgnum = '362' OR
            ls_ltap-lgnum = '190'.
            IF ls_ltap-acqty IS INITIAL AND
              ls_ltap-ndifm IS INITIAL.
              lv_subrc = 4.
            ENDIF.
          ELSE.
            IF ls_ltap-acqty IS INITIAL.
              lv_subrc = 4.
            ENDIF.
          ENDIF.

          CLEAR ls_ltbk.
          READ TABLE gt_ltbk INTO ls_ltbk
                             WITH KEY lgnum = ltak-lgnum
                                      tbnum = ltak-tbnum.
          IF sy-subrc = 0.
            CLEAR ls_resb.
            READ TABLE gt_resb INTO ls_resb
                               WITH KEY rsnum = ls_ltbk-rsnum
                                        matnr = ls_ltap-matnr.
            IF sy-subrc = 0.
              IF ls_resb-charg IS NOT INITIAL.
                IF ls_ltap-charg <> ls_resb-charg.
                  DELETE gt_ltap FROM ls_ltap.
                  CONTINUE.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
          ADD 1 TO lv_zeile.
          ls_ltap-zeile   = lv_zeile.
          MODIFY gt_ltap FROM ls_ltap TRANSPORTING zeile.
        ENDLOOP.
        DESCRIBE TABLE gt_ltap LINES gv_record.
      ENDIF.

      IF lv_subrc IS NOT INITIAL.
        PERFORM f_modify_screen USING : 'PCF' '' '' '1' ''.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_VALIDATE_DATA

*&---------------------------------------------------------------------*
*&      Module  EXIT_COMMANDS  INPUT
*&---------------------------------------------------------------------*
MODULE exit_commands INPUT.
  CASE sy-dynnr.
    WHEN '0100'.
      CASE ok_code.
        WHEN 'BACK'.
          LEAVE PROGRAM.
      ENDCASE.

    WHEN '0101'.
      CASE ok_code.
        WHEN 'BACK'.
          CALL FUNCTION 'DEQUEUE_ELLTAKE'
            EXPORTING
              lgnum = ltak-lgnum
              tanum = ltak-tanum.

          CLEAR : ltak-tanum, gv_matnr, gv_charg, gv_meins,
                  gv_tapos, gv_nista, gv_menge.

          SET SCREEN 100.
      ENDCASE.

    WHEN '2999'.
      CASE ok_code.
        WHEN 'BACK'.
          CASE gv_subrc.
            WHEN '1'.
              LEAVE PROGRAM.
            WHEN '2' OR '3'.
              SET SCREEN 100.
            WHEN OTHERS.
              LEAVE TO SCREEN 0.
          ENDCASE.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " EXIT_COMMANDS  INPUT

*&---------------------------------------------------------------------*
*&      Module  MESSAGE  OUTPUT
*&---------------------------------------------------------------------*
MODULE message OUTPUT.
  CLEAR : message1, message2, message3, message4, message5, message6,
          message7.
  CASE gv_subrc.
    WHEN '1'.
      message1 = 'Whse.No is empty'.
    WHEN '2'.
      message1 = 'TO Number'.
      message2 = 'not found or'.
      message3 = 'already confirm'.
    WHEN '3'.
      message1 = 'TO No.'.
      message2 = 'Lock by'.
      message3 = 'another user'.
    WHEN '4'.
      message1 = 'TO cannot'.
      message2 = 'confirm'.
    WHEN '5'.
      message1 = 'Qty Confirm'.
      message2 = 'lebih besar daripada'.
      message3 = 'Qty Picking'.
    WHEN '99'.
      message1 = 'TO confirm'.
  ENDCASE.

  IF gv_subrc = 5.
    CLEAR gv_subrc.
  ENDIF.
ENDMODULE.                 " MESSAGE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  CASE sy-dynnr.
    WHEN '0100'.
      CASE ok_code.
        WHEN 'CONT'.
          PERFORM f_get_data_to.
          SET SCREEN 101.
      ENDCASE.

    WHEN '0101'.
      CASE ok_code.
        WHEN 'CONT'.
          IF inp_100 IS NOT INITIAL.
            PERFORM f_split_input.
            CLEAR inp_100.
          ELSE.
          ENDIF.

        WHEN 'CONF'.
          PERFORM f_confirm_to.
          CALL FUNCTION 'DEQUEUE_ELLTAKE'
            EXPORTING
              lgnum = ltak-lgnum
              tanum = ltak-tanum.

          CALL SCREEN 2999.
          SET SCREEN 100.

        WHEN 'PGUP'.
          CLEAR gv_subrc.
          tap_index  = tap_index - 1.
          SET SCREEN 101.

        WHEN 'PGDN'.
          CLEAR gv_subrc.
          tap_index  = tap_index + 1.
          IF tap_index > gv_record.
            tap_index  = gv_record.
          ENDIF.
          SET SCREEN 101.
      ENDCASE.

    WHEN '2999'.
      CASE ok_code.
        WHEN 'CONT'.
          LEAVE PROGRAM.
      ENDCASE.
  ENDCASE.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_TO
*&---------------------------------------------------------------------*
FORM f_get_data_to .
  DATA : ls_ltbk    LIKE LINE OF gt_ltbk,
         lt_ltap    TYPE STANDARD TABLE OF ty_ltap,
         ls_ltap    LIKE LINE OF gt_ltap.

  CLEAR : gs_ltak, gt_ltap[], gt_ltbk[], gt_resb[], gt_mara[].

  SELECT SINGLE *
    FROM ltak
    INTO CORRESPONDING FIELDS OF gs_ltak
    WHERE lgnum = ltak-lgnum
      AND tanum = ltak-tanum
      AND kquit = space.

  IF gs_ltak IS NOT INITIAL.
    SELECT *
      FROM ltbk
      INTO CORRESPONDING FIELDS OF TABLE gt_ltbk
      WHERE lgnum = gs_ltak-lgnum
        AND tbnum = gs_ltak-tbnum.

    IF gt_ltbk[] IS NOT INITIAL.
      LOOP AT gt_ltbk INTO ls_ltbk.
        ls_ltbk-rsnum   = ls_ltbk-tbktx.
        MODIFY gt_ltbk FROM ls_ltbk TRANSPORTING rsnum.
        CLEAR ls_ltbk.
      ENDLOOP.

      SELECT *
        FROM resb
        INTO CORRESPONDING FIELDS OF TABLE gt_resb
        FOR ALL ENTRIES IN gt_ltbk
        WHERE rsnum = gt_ltbk-rsnum
          AND bwart = '311'.
    ENDIF.

*{   REPLACE        P01K910473                                        1
*\    SELECT *
*\      FROM ltap
*\      INTO CORRESPONDING FIELDS OF TABLE gt_ltap
*\      WHERE lgnum = gs_ltak-lgnum
*\        AND tanum = gs_ltak-tanum
*\        AND pquit = space
*\        AND pvqui NE space.
    "Start  SOH: Shell SCI Adjustment 20240223 KRS
    SELECT *
      FROM ltap
      INTO CORRESPONDING FIELDS OF TABLE gt_ltap
      WHERE lgnum = gs_ltak-lgnum
        AND tanum = gs_ltak-tanum
        AND pquit = space
        AND pvqui NE space
    ORDER BY PRIMARY KEY.
     "End  SOH: Shell SCI Adjustment 20240223 KRS
*}   REPLACE

    lt_ltap[] = gt_ltap[].
    SORT lt_ltap BY matnr.
    DELETE ADJACENT DUPLICATES FROM lt_ltap COMPARING matnr.
    SELECT mara~matnr mtart maktx
      FROM mara JOIN makt ON mara~matnr = makt~matnr
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      FOR ALL ENTRIES IN lt_ltap
      WHERE mara~matnr = lt_ltap-matnr
        AND makt~spras = sy-langu.

    READ TABLE gt_ltap INTO ls_ltap INDEX 1.
    IF sy-subrc = 0.
      gv_werks = ls_ltap-werks.
    ENDIF.

    SELECT matnr werks qmatv
      FROM marc
      INTO CORRESPONDING FIELDS OF TABLE gt_marc
      FOR ALL ENTRIES IN lt_ltap
      WHERE matnr = lt_ltap-matnr
        AND werks = gv_werks.

    SELECT *
      FROM mch1
      INTO CORRESPONDING FIELDS OF TABLE gt_mch1
      FOR ALL ENTRIES IN lt_ltap
      WHERE matnr = lt_ltap-matnr.
  ENDIF.
ENDFORM.                    " F_GET_DATA_TO

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.

ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDATE_DATA  INPUT
*&---------------------------------------------------------------------*
MODULE validate_data INPUT.
  PERFORM f_validate_data.
  IF gv_subrc IS NOT INITIAL.
    CALL SCREEN 2999.
  ENDIF.
ENDMODULE.                 " VALIDATE_DATA  INPUT

*&---------------------------------------------------------------------*
*&      Module  TAP_DISPLAY  OUTPUT
*&---------------------------------------------------------------------*
MODULE tap_display OUTPUT.
  DATA : ls_marc    LIKE LINE OF gt_marc.

  IF gv_subrc = 5.
    CLEAR gv_subrc.
  ENDIF.

  IF ltak-lgnum = '011' OR
    ltak-lgnum = '012' OR
    ltak-lgnum = '041' OR
    ltak-lgnum = '042' OR
    ltak-lgnum = '360' OR
    ltak-lgnum = '361' OR
    ltak-lgnum = '362' OR
    ltak-lgnum = '190'.
    IF gs_ltap-acqty > gs_ltap-nista.
      CLEAR : gs_ltap-acqty, gs_ltap-packq,
              gs_ltap-receh, gs_ltap-ndifm.
      gv_subrc = 5.
      CALL SCREEN 2999.
    ENDIF.
  ENDIF.

  IF gv_subrc IS INITIAL.
    gs_001-zeile  = gs_ltap-zeile.
    gs_001-matnr  = gs_ltap-matnr.
    gs_001-charg  = gs_ltap-charg.
    gs_001-meins  = gs_ltap-meins.
    gs_001-nista  = gs_ltap-nista.
    gs_001-acqty  = gs_ltap-acqty.
    gs_001-packq  = gs_ltap-packq.
    gs_001-receh  = gs_ltap-receh.
    gs_001-ndifm  = gs_ltap-ndifm.
    gs_001-kzdif  = gs_ltap-kzdif.

    READ TABLE gt_marc INTO ls_marc
                       WITH KEY matnr = gs_ltap-matnr
                                werks = gs_ltap-werks.
    IF sy-subrc = 0.
      IF ls_marc-qmatv IS INITIAL.
        PERFORM f_modify_screen USING : 'MOD' '' '1' '' ''.
        PERFORM f_set_cursor.
      ENDIF.
    ENDIF.

    IF gv_matnr IS NOT INITIAL AND
      gv_charg IS NOT INITIAL.
      IF gs_001-matnr = gv_matnr AND
        gs_001-charg = gv_charg.
        PERFORM f_modify_screen USING : 'MOD' '' '1' '' ''.
        PERFORM f_set_cursor.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " TAP_DISPLAY  OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_required.
  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_required IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-required  = fu_required.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_SPLIT_INPUT
*&---------------------------------------------------------------------*
FORM f_split_input .
  DATA : lv_count(20),
         lv_nista(20),
         lt_clbatch TYPE STANDARD TABLE OF clbatch.

  CLEAR : gv_matnr, gv_charg, gv_tapos, gv_meins, gv_nista, gv_menge.

  SPLIT inp_100 AT ';' INTO gv_matnr gv_charg lv_nista lv_count.
*  SPLIT lv_count AT '/' INTO gv_tapos lv_count.
*  SPLIT lv_nista AT space INTO lv_nista gv_meins.
*  TRANSLATE lv_nista USING '. '.
*  TRANSLATE lv_nista USING ',.'.
*  CONDENSE lv_nista NO-GAPS.
*  gv_nista  = lv_nista.

  PERFORM f_vb_batch_get_detail USING gv_matnr gv_charg gv_werks
                                CHANGING gv_menge gv_pack.

  PERFORM f_zwmpalvnd USING ltak-lgnum gv_matnr gv_charg gv_werks
                      CHANGING gv_menge.
ENDFORM.                    " F_SPLIT_INPUT

*&---------------------------------------------------------------------*
*&      Form  F_SET_CURSOR
*&---------------------------------------------------------------------*
FORM f_set_cursor .
  DATA : ls_ltap  TYPE ty_ltap.

  IF gv_cursor IS INITIAL.
    gv_cursor = 'X'.
    SET CURSOR FIELD 'GS_001-ACQTY' LINE sy-stepl.
  ENDIF.
ENDFORM.                    " F_SET_CURSOR

*&---------------------------------------------------------------------*
*&      Form  F_VB_BATCH_GET_DETAIL
*&---------------------------------------------------------------------*
FORM f_vb_batch_get_detail  USING    fu_matnr fu_charg fu_werks
                            CHANGING fc_menge fc_pack.
  DATA : lt_clbatch   TYPE STANDARD TABLE OF clbatch,
         ls_clbatch   LIKE LINE OF lt_clbatch,
         ls_mara      LIKE LINE OF gt_mara,
         ls_mch1      LIKE LINE OF gt_mch1.

  DATA : lv_mtart     TYPE mara-mtart,
         lv_cuobj_bm  TYPE mch1-cuobj_bm,
         lv_atinn     TYPE ausp-atinn,
         lv_atnam(30).

  CALL FUNCTION 'VB_BATCH_GET_DETAIL'
    EXPORTING
      matnr              = fu_matnr
      charg              = fu_charg
      werks              = fu_werks
      get_classification = 'X'
    TABLES
      char_of_batch      = lt_clbatch
    EXCEPTIONS
      no_material        = 1
      no_batch           = 2
      no_plant           = 3
      material_not_found = 4
      plant_not_found    = 5
      no_authority       = 6
      batch_not_exist    = 7
      lock_on_batch      = 8
      OTHERS             = 9.

  IF fc_menge IS INITIAL.
    READ TABLE lt_clbatch INTO ls_clbatch WITH KEY atnam = 'QTY_CONVERSION'.
    IF sy-subrc = 0.
      TRANSLATE ls_clbatch-atwtb USING '. '.
      TRANSLATE ls_clbatch-atwtb USING ',.'.
      CONDENSE ls_clbatch-atwtb NO-GAPS.
      fc_menge  = ls_clbatch-atwtb.
    ENDIF.
  ENDIF.

  CLEAR : ls_mara, ls_mch1.
  READ TABLE gt_mara INTO ls_mara
                     WITH KEY matnr = fu_matnr.
  IF sy-subrc = 0.
    lv_mtart  = ls_mara-mtart.
  ENDIF.

  CASE lv_mtart.
    WHEN 'ZPM'.
      lv_atnam  = 'PM_PACKAGING'.
    WHEN 'ZRM'.
      lv_atnam  = 'RM_PACKAGING'.
  ENDCASE.

  READ TABLE lt_clbatch INTO ls_clbatch WITH KEY atnam = lv_atnam.
  IF sy-subrc = 0.
    fc_pack  = ls_clbatch-atwtb.
  ENDIF.
ENDFORM.                    " F_VB_BATCH_GET_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_DATA
*&---------------------------------------------------------------------*
FORM f_modify_data .
  DATA : lv_field(20),
         lv_line    TYPE i,
         lv_index   TYPE sy-tabix,
         ls_ltap    LIKE LINE OF gt_ltap,
         lv_menge   TYPE ltap-nista,
         lv_pack(30).

  GET CURSOR FIELD lv_field
             LINE  lv_line.
  lv_index   = ( tap_index + lv_line ) - 1.

  IF gs_001-acqty > gs_001-nista.
    gv_subrc = 5.
    CALL SCREEN 2999.
  ELSE.
    READ TABLE gt_ltap INTO ls_ltap INDEX lv_index.

    IF gs_001-zeile = ls_ltap-zeile.
      lv_menge = gv_menge.
      IF lv_menge IS INITIAL.
        PERFORM f_vb_batch_get_detail USING ls_ltap-matnr ls_ltap-charg gv_werks
                                      CHANGING lv_menge lv_pack.
        PERFORM f_zwmpalvnd USING ls_ltap-lgnum ls_ltap-matnr ls_ltap-charg gv_werks
                            CHANGING lv_menge.
      ELSE.
        PERFORM f_vb_batch_get_detail USING ls_ltap-matnr ls_ltap-charg gv_werks
                                      CHANGING lv_menge lv_pack.
      ENDIF.
      CASE lv_field.
        WHEN 'GS_001-ACQTY'.
          ls_ltap-acqty = gs_001-acqty.
          IF lv_menge IS NOT INITIAL.
            ls_ltap-packq = gs_001-acqty DIV lv_menge.
            ls_ltap-receh = gs_001-acqty MOD lv_menge.
          ENDIF.
        WHEN 'GS_001-PACKQ'.
          ls_ltap-packq = gs_001-packq.
          ls_ltap-acqty = ( gs_001-packq * lv_menge ) + gs_001-receh.
          ls_ltap-receh = gs_001-receh.
        WHEN 'GS_001-RECEH'.
          ls_ltap-packq = gs_001-packq.
          ls_ltap-receh = gs_001-receh.
          ls_ltap-acqty = ( gs_001-packq * lv_menge ) + gs_001-receh.
      ENDCASE.

      gs_001-ndifm = gs_001-nista - ls_ltap-acqty.
      IF gs_001-ndifm <> 0.
        gs_001-kzdif = 'R'.
      ELSE.
        CLEAR gs_001-kzdif.
      ENDIF.

      ls_ltap-ndifm = gs_001-ndifm.
      ls_ltap-kzdif = gs_001-kzdif.
      ls_ltap-pack  = lv_pack.
      WRITE lv_menge TO ls_ltap-conversion UNIT ls_ltap-meins.

*{   REPLACE        P01K910473                                        1
*\      MODIFY gt_ltap FROM ls_ltap
*\                     INDEX lv_index
*\                     TRANSPORTING acqty packq receh ndifm kzdif pack
*\                                  conversion.
      "Start SOH: Shell SCI Adjustment 20240223 KRS
      MODIFY gt_ltap FROM ls_ltap                                        "#CI_NOORDER
                     INDEX lv_index                                      "#CI_NOORDER
                     TRANSPORTING acqty packq receh ndifm kzdif pack     "#CI_NOORDER
                                  conversion.                            "#CI_NOORDER
      "End SOH: Shell SCI Adjustment 20240223 KRS
*}   REPLACE
    ENDIF.
  ENDIF.
ENDFORM.                    " F_MODIFY_DATA

*&---------------------------------------------------------------------*
*&      Module  MODIFY_DATA  INPUT
*&---------------------------------------------------------------------*
MODULE modify_data INPUT.
  IF ok_code = 'CONT'.
    PERFORM f_modify_data.
  ENDIF.
ENDMODULE.                 " MODIFY_DATA  INPUT

*&---------------------------------------------------------------------*
*&      Form  F_CONFIRM_TO
*&---------------------------------------------------------------------*
FORM f_confirm_to .
  DATA : t_to_items    TYPE STANDARD TABLE OF ltap INITIAL SIZE 0,
         t_to_header   TYPE STANDARD TABLE OF ltak INITIAL SIZE 0,
         ls_to_items   LIKE LINE OF t_to_items,
         ls_to_header  LIKE LINE OF t_to_header,
         ls_ltap       TYPE ty_ltap,
         lv_memid(30).

  ls_to_header   = gs_ltak.
  APPEND ls_to_header TO t_to_header.
  CLEAR ls_to_header.

  LOOP AT gt_ltap INTO ls_ltap.
    MOVE-CORRESPONDING ls_ltap TO ls_to_items.

    IF ls_ltap-kzdif = 'R'.
      ls_to_items-nsola = ls_ltap-acqty.
      ls_to_items-nista = ls_ltap-acqty.
      ls_to_items-ndifa = ls_to_items-nsolm - ls_ltap-acqty.
    ENDIF.

    PERFORM f_prepare_to_save USING ls_to_items.

    APPEND ls_to_items TO t_to_items.
    CLEAR ls_to_items.
  ENDLOOP.

  CONCATENATE 'GT_LTAP' sy-uname INTO lv_memid.
  EXPORT gt_ltap TO MEMORY ID lv_memid.

  CALL FUNCTION 'CONFIRM_TO'
    EXPORTING
      i_lgnum                       = ltak-lgnum
      i_screen_type                 = 'DST'
    TABLES
      t_to_items                    = t_to_items
      t_to_header                   = t_to_header
    EXCEPTIONS
      to_confirmed                  = 1
      to_doesnt_exist               = 2
      item_confirmed                = 3
      item_subsystem                = 4
      item_doesnt_exist             = 5
      item_without_zero_stock_check = 6
      item_with_zero_stock_check    = 7
      item_su_bulk_storage          = 8
      item_no_su_bulk_storage       = 9
      foreign_lock                  = 10
      wrong_ind_or_quantities       = 11
      wrong_quantity                = 12
      double_lines                  = 13
      kzdif_wrong                   = 14
      no_difference                 = 15
      no_negative_quantities        = 16
      wrong_zero_stock_check        = 17
      su_not_found                  = 18
      no_stock_on_su                = 19
      su_wrong                      = 20
      too_many_su                   = 21
      nothing_to_do                 = 22
      no_unit_of_measure            = 23
      xfeld_wrong                   = 24
      update_without_commit         = 25
      no_authority                  = 26
      lqnum_missing                 = 27
      charg_missing                 = 28
      no_sobkz                      = 29
      no_charg                      = 30
      internal_error                = 31
      empty_header                  = 32
      empty_items                   = 33
      no_2step                      = 34
      wrong_hu_configuration        = 35
      OTHERS                        = 36.

  gv_subrc = sy-subrc.
  IF gv_subrc = 31.
    gv_subrc = 0.
  ENDIF.

  IF gv_subrc = 0.
    PERFORM f_save_data ON COMMIT.
    COMMIT WORK AND WAIT.
    gv_subrc = 99.
  ELSE.
    gv_subrc = 4.
    ROLLBACK WORK.
  ENDIF.
ENDFORM.                    " F_CONFIRM_TO

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_TO_SAVE
*&---------------------------------------------------------------------*
FORM f_prepare_to_save  USING    fs_ltap LIKE ltap.
  DATA : ls_save    LIKE LINE OF gt_save.

  ls_save-lgnum   = fs_ltap-lgnum.
  ls_save-tanum   = fs_ltap-tanum.
  ls_save-tapos   = fs_ltap-tapos.
  ls_save-matnr   = fs_ltap-matnr.
  ls_save-charg   = fs_ltap-charg.
  ls_save-meins   = fs_ltap-meins.
  ls_save-nista   = fs_ltap-nista.
  ls_save-ndifm   = fs_ltap-ndifm.
  APPEND ls_save TO gt_save.
  CLEAR ls_save.
ENDFORM.                    " F_PREPARE_TO_SAVE

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data .
*  INSERT ztnpwm001 FROM TABLE gt_save.
  MODIFY ztnpwm001 FROM TABLE gt_save.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_ZWMPALVND
*&---------------------------------------------------------------------*
FORM f_zwmpalvnd  USING    fu_lgnum fu_matnr fu_charg fu_werks
                  CHANGING fc_menge.
  DATA : ls_mch1    LIKE LINE OF gt_mch1,
         lv_lifnr   TYPE mch1-lifnr.

  IF fc_menge IS INITIAL.
    CLEAR ls_mch1.
    READ TABLE gt_mch1 INTO ls_mch1
                       WITH KEY matnr = fu_matnr
                                charg = fu_charg.
    IF sy-subrc = 0.
      lv_lifnr  = ls_mch1-lifnr.
    ENDIF.

    SELECT SINGLE leqty
      FROM zwmpalvnd
      INTO fc_menge
      WHERE lgnum = fu_lgnum
        AND matnr = fu_matnr
        AND lifnr = lv_lifnr.
  ENDIF.
ENDFORM.                    " F_ZWMPALVND
