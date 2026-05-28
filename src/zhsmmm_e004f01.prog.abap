*&---------------------------------------------------------------------*
*&  Include           ZHSMMM_E004F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INIT_DATA
*&---------------------------------------------------------------------*
FORM f_init_data .
  DATA : lv_count  TYPE i,
         ls_badat  LIKE LINE OF gr_badat,
         ls_frgkz  LIKE LINE OF gr_frgkz,
         ls_icon   LIKE LINE OF gr_icon,
         lr_group  TYPE RANGE OF zgrpx,
         ls_group  LIKE LINE OF lr_group,
         ls_004    LIKE LINE OF gt_004,
         lv_zeile  TYPE zgdmmt0004x-zeile,
         lv_answer,
         lv_subrc  TYPE sy-subrc.

  DATA : lt_04z    TYPE STANDARD TABLE OF zgdmmt004z,
         ls_04z    LIKE LINE OF lt_04z,
         parameter TYPE STANDARD TABLE OF spar,
         ls_par    LIKE LINE OF parameter.

  gv_mail = 'X'.
  gv_po   = 'X'.

  gs_variant-report = gv_repid.
  gv_dynnr          = sy-dynnr.

  gv_frgkz  = '2'.

  gs_head-matnr = so_matnr-low.

  SELECT SINGLE maktx
    FROM makt
    INTO gs_head-maktx
    WHERE matnr = gs_head-matnr.

  gs_head-werks = so_werks-low.

  SELECT SINGLE name1
    FROM t001w
    INTO gs_head-name1w
    WHERE werks = gs_head-werks.

  PERFORM f_get_quarter USING '' ''.

  DO 4 TIMES.
    ADD 1 TO lv_count.
    CASE lv_count.
      WHEN 1.
        PERFORM f_get_quarter USING '01' ''.
      WHEN 2.
        PERFORM f_get_quarter USING '04' ''.
      WHEN 3.
        PERFORM f_get_quarter USING '07' ''.
      WHEN 4.
        PERFORM f_get_quarter USING '10' ''.
    ENDCASE.
  ENDDO.

  ls_frgkz-low    = ''.
  ls_frgkz-sign   = 'I'.
  ls_frgkz-option = 'EQ'.
  APPEND ls_frgkz TO gr_frgkz.
  CLEAR ls_frgkz.
  ls_frgkz-low    = '2'.
  ls_frgkz-sign   = 'I'.
  ls_frgkz-option = 'EQ'.
  APPEND ls_frgkz TO gr_frgkz.
  CLEAR ls_frgkz.

  CALL FUNCTION 'RP_CALC_DATE_IN_INTERVAL'
    EXPORTING
      date      = sy-datum
      days      = 0
      months    = 0
      signum    = '-'
      years     = 2
    IMPORTING
      calc_date = ls_badat-low.

  CONCATENATE ls_badat-low(4) '0101' INTO ls_badat-low.
  ls_badat-high   = sy-datum.
  ls_badat-sign   = 'I'.
  ls_badat-option = 'BT'.
  APPEND ls_badat TO gr_badat.
  CLEAR ls_badat.

  SELECT *
    FROM zmtnt_scor_aloc
    INTO CORRESPONDING FIELDS OF TABLE gt_alloc.

  ls_icon-low    = icon_led_red.
  ls_icon-sign   = 'I'.
  ls_icon-option = 'EQ'.
  APPEND ls_icon TO gr_icon.
  CLEAR ls_icon.
  ls_icon-low    = icon_led_yellow.
  ls_icon-sign   = 'I'.
  ls_icon-option = 'EQ'.
  APPEND ls_icon TO gr_icon.
  CLEAR ls_icon.

  CASE gv_quarter.
    WHEN 1.
      ls_group-low   = '1'.
      ls_group-high  = '1'.
    WHEN 2.
      ls_group-low   = '1'.
      ls_group-high  = '2'.
    WHEN 3.
      ls_group-low   = '1'.
      ls_group-high  = '3'.
    WHEN 4.
      ls_group-low   = '1'.
      ls_group-high  = '4'.
  ENDCASE.
  ls_group-sign   = 'I'.
  ls_group-option = 'BT'.
  APPEND ls_group TO lr_group.

  SELECT *
    FROM zgdmmt0004x
    INTO CORRESPONDING FIELDS OF TABLE gt_004
    WHERE type = 'NEW'
      AND ( zgroup1 = space
       OR   zgroup1 IN lr_group ).

  LOOP AT gt_004 INTO ls_004.
    ls_004-xeile  = ls_004-zeile.
    ADD 1 TO lv_zeile.
    ls_004-zeile = lv_zeile.
    MODIFY gt_004 FROM ls_004 TRANSPORTING zeile xeile.
  ENDLOOP.

  CLEAR lv_subrc.

  SELECT *
    FROM zgdmmt004z
    INTO CORRESPONDING FIELDS OF TABLE lt_04z
    WHERE submi = pa_submi
      AND werks = so_werks-low
      AND ekgrp = pa_ekgrp
      AND matnr = so_matnr-low.

  IF sy-subrc = 0.
    LOOP AT lt_04z INTO ls_04z.
      IF ls_04z-procstat <> '05' AND ls_04z-procstat <> '08'.
        lv_subrc = 4.
      ENDIF.
    ENDLOOP.
  ELSE.
    gv_trtyp = 'H'.
  ENDIF.

  SELECT *
    FROM zhsmmmdt005
    INTO CORRESPONDING FIELDS OF TABLE gt_05
    WHERE tcode = 'ZMME013'
      AND ekgrp = pa_ekgrp.

*  SELECT SINGLE *
*    FROM zgdmmt004z
*    INTO CORRESPONDING FIELDS OF gs_x04z
*    WHERE submi = pa_submi
*      AND werks = so_werks-low
*      AND ekgrp = pa_ekgrp
*      AND matnr = so_matnr-low.
*  IF sy-subrc = 0.
*    IF gs_x04z-frgco IS INITIAL.
*      gv_trtyp = 'V'.
*      SELECT SINGLE name1
*        FROM lfa1
*        INTO gs_head-name1l
*        WHERE lifnr = gs_x04z-lifnr.
*    ELSE.
*      gv_trtyp = 'A'.
*    ENDIF.
*  ELSE.
*    gv_trtyp = 'H'.
*  ENDIF.

  IF gv_trtyp <> 'H'.
    CALL SELECTION-SCREEN 1001 STARTING AT 10 10.
    CASE sy-subrc.
      WHEN 0.
        IF pa_zalno IS INITIAL AND lv_subrc = 0.
          gv_trtyp = 'H'.
          SORT lt_04z BY vrsio DESCENDING.
          READ TABLE lt_04z INTO ls_04z INDEX 1.
          gs_head-vrsio = ls_04z-vrsio.
        ELSEIF pa_zalno IS INITIAL AND lv_subrc <> 0.
          gv_subrc = 5.
        ELSE.
          gv_zalno = pa_zalno.
          READ TABLE lt_04z INTO gs_x04z
                            WITH KEY zalno = pa_zalno.
          IF sy-subrc = 0.
            IF gs_x04z-frgco IS INITIAL.
              gv_trtyp = 'V'.
              SELECT SINGLE name1
                FROM lfa1
                INTO gs_head-name1l
                WHERE lifnr = gs_x04z-lifnr.
            ELSE.
              gv_trtyp = 'A'.
            ENDIF.
          ELSE.
            gv_subrc = 4.
          ENDIF.
        ENDIF.
        IF gv_subrc = 0.
          PERFORM f_get_quarter USING '' gs_x04z-zaldt.
        ENDIF.
      WHEN 4.
        gv_subrc = 9.
    ENDCASE.
  ENDIF.

  lo_ixml = cl_ixml=>create( ).
  lo_ixml_sf = lo_ixml->create_stream_factory( ).
ENDFORM.                    " F_INIT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  CASE 'X'.
    WHEN radio1.
      PERFORM f_modify_screen USING : 'PPR' '' '' '0' '' '' ''.
    WHEN radio2.
  ENDCASE.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN
*&---------------------------------------------------------------------*
FORM f_selection_screen .
  DATA : ls_pgmi  TYPE pgmi,
         lv_subrc TYPE sy-subrc,
         lv_mess  TYPE t100-text,
         lv_prgrp TYPE pgmi-prgrp.

  DATA : lt_ekko TYPE STANDARD TABLE OF ekko,
         lt_ekpo TYPE STANDARD TABLE OF ekpo,
         lt_eket TYPE STANDARD TABLE OF eket,
         ls_ekko TYPE ekko,
         ls_eket TYPE eket.

  IF pa_ekgrp IS INITIAL.
    PERFORM f_error_message USING 'PEK' ''.
  ELSE.
    PERFORM f_check_number_range CHANGING lv_subrc.
    IF lv_subrc <> 0.
      PERFORM f_error_message USING 'PEK' 'Number range not maintained'.
    ENDIF.
  ENDIF.
  IF pa_submi IS INITIAL.
    PERFORM f_error_message USING 'PSU' ''.
  ENDIF.
  IF so_werks-low IS INITIAL.
    PERFORM f_error_message USING 'SWE' ''.
  ENDIF.
  IF so_matnr-low IS INITIAL.
    PERFORM f_error_message USING 'SMA' ''.
  ENDIF.

  CASE 'X'.
    WHEN radio1.
      CLEAR pa_prgrp.
    WHEN radio2.
      IF pa_prgrp IS INITIAL.
        PERFORM f_error_message USING 'PPR' ''.
      ELSE.
        PERFORM f_get_product_group.
        SELECT SINGLE *
          FROM pgmi
          INTO CORRESPONDING FIELDS OF ls_pgmi
          WHERE prgrp = pa_prgrp.
        IF sy-subrc = 0.
          PERFORM f_cek_product_group USING ls_pgmi-prgrp ls_pgmi-werks
                                      CHANGING lv_subrc.
          IF lv_subrc <> 0.
            CONCATENATE so_matnr-low 'not maintained in' INTO lv_mess
            SEPARATED BY space.
            CONCATENATE lv_mess 'PrdGrp' pa_prgrp INTO lv_mess
            SEPARATED BY space.
            PERFORM f_error_message USING 'PPR' lv_mess.
          ENDIF.
        ELSE.
          CONCATENATE 'Product Group' pa_prgrp 'not maintained' INTO lv_mess
          SEPARATED BY space.
          PERFORM f_error_message USING 'PPR' lv_mess.
        ENDIF.
      ENDIF.
  ENDCASE.

  IF pa_submi IS NOT INITIAL.
    SELECT *
      FROM ekko
      INTO CORRESPONDING FIELDS OF TABLE lt_ekko
      WHERE submi = pa_submi.
    IF lt_ekko[] IS NOT INITIAL.
      SELECT *
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
        FOR ALL ENTRIES IN lt_ekko
        WHERE ebeln = lt_ekko-ebeln
          AND matnr = so_matnr-low.
    ENDIF.
    IF lt_ekpo[] IS NOT INITIAL.
      SELECT *
        FROM eket
        INTO CORRESPONDING FIELDS OF TABLE lt_eket
        FOR ALL ENTRIES IN lt_ekpo
        WHERE ebeln = lt_ekpo-ebeln
          AND ebelp = lt_ekpo-ebelp.

      READ TABLE lt_eket INTO ls_eket INDEX 1.
      IF sy-subrc = 0.
        lv_prgrp  = ls_eket-licha.
      ENDIF.
    ENDIF.

**    CASE 'X'.
**      WHEN radio1.
**        IF lv_prgrp IS NOT INITIAL.
**          CONCATENATE 'Scoring by Product Group' lv_prgrp INTO lv_mess
**          SEPARATED BY space.
**          PERFORM f_error_message USING '' lv_mess.
**        ENDIF.
**      WHEN radio2.
**        IF lv_prgrp IS INITIAL.
**          lv_mess = 'Scoring by Material only'.
**          PERFORM f_error_message USING '' lv_mess.
**        ELSEIF lv_prgrp <> pa_prgrp(15).
**          CONCATENATE 'Scoring by Product Group' lv_prgrp INTO lv_mess
**          SEPARATED BY space.
**          PERFORM f_error_message USING '' lv_mess.
**        ENDIF.
**    ENDCASE.
  ENDIF.
ENDFORM.                    " F_SELECTION_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_F4_FILENAME
*&---------------------------------------------------------------------*
FORM f_f4_filename  CHANGING fc_fname.
  DATA : directory TYPE string,
         filetable TYPE filetable,
         line      TYPE LINE OF filetable,
         rc        TYPE i.

  CALL METHOD cl_gui_frontend_services=>get_temp_directory
    CHANGING
      temp_dir = directory.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title      = 'SELECT THE FILE'
      initial_directory = directory
      file_filter       = '*.*'
      multiselection    = ' '
    CHANGING
      file_table        = filetable
      rc                = rc.
  IF rc = 1.
    READ TABLE filetable INDEX 1 INTO line.
    fc_fname = line-filename.
  ENDIF.
ENDFORM.                    " F_F4_FILENAME

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group1 fu_group2 fu_name fu_active fu_input
                               fu_invisible fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-active  = fu_active.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-input  = fu_input.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-invisible  = fu_invisible.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF fu_group1 IS NOT INITIAL.
        IF screen-group1 = fu_group1.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      IF fu_group2 IS NOT INITIAL.
        IF screen-group2 = fu_group2.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      IF fu_name IS NOT INITIAL.
        IF screen-name = fu_name.
          screen-length  = fu_length.
        ENDIF.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.                    " F_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA
*&---------------------------------------------------------------------*
FORM f_get_data .
  DATA : lt_xekko TYPE STANDARD TABLE OF ekko,
         lt_xekpo TYPE STANDARD TABLE OF ekpo,
         lt_xeket TYPE STANDARD TABLE OF eket,
         lt_05    TYPE STANDARD TABLE OF zhsmmmdt005,
         ls_05    LIKE LINE OF lt_05,
         ls_ekko  LIKE LINE OF gt_ekko,
         ls_ekpo  LIKE LINE OF gt_ekpo.

  CLEAR gv_upir.

  CASE gv_trtyp.
    WHEN 'H'.
      PERFORM f_get_outstanding_pr.

      IF pa_submi IS INITIAL.
        PERFORM f_get_from_zm73n.
      ELSE.
        SELECT *
          FROM ekko
          INTO CORRESPONDING FIELDS OF TABLE gt_ekko
          WHERE submi = pa_submi
            AND ekgrp = pa_ekgrp
            AND loekz = space
            AND statu = 'A'
          ORDER BY PRIMARY KEY.

        IF gt_ekko[] IS NOT INITIAL.
          SELECT *
            FROM ekpo
            INTO CORRESPONDING FIELDS OF TABLE gt_ekpo
            FOR ALL ENTRIES IN gt_ekko
            WHERE ebeln = gt_ekko-ebeln
              AND loekz = space
              AND werks = gs_head-werks
              AND matnr = gs_head-matnr
            ORDER BY PRIMARY KEY.

          LOOP AT gt_ekko INTO ls_ekko.
            CLEAR ls_ekpo.
            READ TABLE gt_ekpo INTO ls_ekpo
                               WITH KEY ebeln = ls_ekko-ebeln.
            IF sy-subrc <> 0.
              DELETE TABLE gt_ekko FROM ls_ekko.
            ELSE.
              IF gs_head-werks = '1601'.
                TRANSLATE ls_ekpo-afnam TO UPPER CASE.
                CONDENSE: ls_ekpo-afnam.
                gv_plant = ls_ekpo-afnam.
              ENDIF.

            ENDIF.
          ENDLOOP.
        ELSE.
          gv_subrc = 1.
        ENDIF.

        IF gt_ekpo[] IS NOT INITIAL.
          SELECT *
            FROM eket
            INTO CORRESPONDING FIELDS OF TABLE gt_eket
            FOR ALL ENTRIES IN gt_ekpo
            WHERE ebeln = gt_ekpo-ebeln
              AND ebelp = gt_ekpo-ebelp
            ORDER BY PRIMARY KEY.
        ELSE.
          gv_subrc = 2.
        ENDIF.

        IF gv_subrc = 0.
          lt_xekko[] = gt_ekko[].
          SORT lt_xekko BY lifnr.
          DELETE ADJACENT DUPLICATES FROM lt_xekko COMPARING lifnr.
          IF lt_xekko[] IS NOT INITIAL.
            SELECT *
              FROM lfa1
              INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
              FOR ALL ENTRIES IN lt_xekko
              WHERE lifnr = lt_xekko-lifnr
              ORDER BY PRIMARY KEY.
          ENDIF.

          lt_xekpo[] = gt_ekpo[].
          SORT lt_xekpo BY matnr.
          DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING matnr.
          IF lt_xekpo[] IS NOT INITIAL.
            SELECT *
              FROM makt
              INTO CORRESPONDING FIELDS OF TABLE gt_makt
              FOR ALL ENTRIES IN lt_xekpo
              WHERE spras = sy-langu
                AND matnr = lt_xekpo-matnr
              ORDER BY PRIMARY KEY.
          ENDIF.

          PERFORM f_get_from_zm73n.
        ENDIF.
      ENDIF.

      PERFORM f_get_budget_price.

      PERFORM f_get_last_purchased.

*      PERFORM f_get_actual_po.

      IF gv_subrc = 0.
        PERFORM f_get_pembayaran.

        PERFORM f_get_outstanding_delivery.

        PERFORM f_get_actual_allocation.

        PERFORM f_alokasi_prgrp_fr_system.

        PERFORM f_alokasi_budget.

        gs_head-vrsio = gs_head-vrsio + 1.   "gs_x04z-vrsio + 1.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = gs_head-vrsio
          IMPORTING
            output = gs_head-vrsio.
      ENDIF.

    WHEN 'V' OR 'A'.
      SELECT *
        FROM zhsmmmdt005
        INTO CORRESPONDING FIELDS OF TABLE lt_05
        WHERE tcode = 'ZMME013'
          AND ekgrp = pa_ekgrp
        ORDER BY PRIMARY KEY.

      MOVE-CORRESPONDING gs_x04z TO gs_head.

      gs_head-vrsio = gs_x04z-vrsio.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
        EXPORTING
          input  = gs_head-vrsio
        IMPORTING
          output = gs_head-vrsio.

      SELECT *
        FROM zgdmmt004x
        INTO CORRESPONDING FIELDS OF TABLE gt_x04x
        WHERE zalno = gs_x04z-zalno
        ORDER BY PRIMARY KEY.

      SELECT *
        FROM zgdmmt004e
        INTO CORRESPONDING FIELDS OF TABLE gt_x04e
        WHERE zalno = gs_x04z-zalno
        ORDER BY PRIMARY KEY.

      SELECT *
        FROM zgdmmt004y
        INTO CORRESPONDING FIELDS OF TABLE gt_x04y
        WHERE zalno = gs_x04z-zalno
        ORDER BY PRIMARY KEY.

      IF gt_x04y[] IS NOT INITIAL.
        SELECT *
          FROM lfa1
          INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
          FOR ALL ENTRIES IN gt_x04y
          WHERE lifnr = gt_x04y-lifnr
          ORDER BY PRIMARY KEY.
      ENDIF.

      SELECT *
        FROM zgdmmt004p
        INTO CORRESPONDING FIELDS OF TABLE gt_x04p
        WHERE zalno = gs_x04z-zalno
        ORDER BY PRIMARY KEY.

      DELETE ADJACENT DUPLICATES FROM lt_05 COMPARING frgco.

      LOOP AT lt_05 INTO ls_05.
        CONCATENATE gs_head-anzef ls_05-frgco INTO gs_head-anzef
        SEPARATED BY space.
        IF ls_05-frgco = gs_x04z-frgco.
          IF ls_05-srno1 < 3.
            gv_upir = 'X'.
          ENDIF.
          EXIT.
        ENDIF.
      ENDLOOP.
      SHIFT gs_head-anzef LEFT DELETING LEADING space.

      SELECT *
        FROM zgdmmt004c
        INTO CORRESPONDING FIELDS OF TABLE gt_x04c
        WHERE zalno = gs_x04z-zalno
        ORDER BY PRIMARY KEY.

      PERFORM f_material_mpn.

*      PERFORM f_get_actual_po.

      PERFORM f_get_from_zm73n.

      PERFORM f_get_actual_allocation.

      PERFORM f_alokasi_prgrp.

      PERFORM f_alokasi_budget.
  ENDCASE.
ENDFORM.                    " F_GET_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_xekpo TYPE STANDARD TABLE OF ekpo,
         lt_xekko TYPE STANDARD TABLE OF ekko,
         lt_04y   TYPE STANDARD TABLE OF zgdmmt004y.

  DATA : ls_xekpo   LIKE LINE OF lt_xekpo,
         ls_xekko   LIKE LINE OF lt_xekko,
         ls_ekko    LIKE LINE OF gt_ekko,
         ls_ekpo    LIKE LINE OF gt_ekpo,
         ls_eket    LIKE LINE OF gt_eket,
         ls_eban    LIKE LINE OF gt_eban,
         ls_lfa1    LIKE LINE OF gt_lfa1,
         ls_mara    LIKE LINE OF gt_mara,
         ls_x04x    LIKE LINE OF gt_x04x,
         ls_x04y    LIKE LINE OF gt_x04y,
         ls_04y     LIKE LINE OF lt_04y,
         ls_x04p    LIKE LINE OF gt_x04p,
         ls_xsplitq LIKE LINE OF gt_xsplitq,
         ls_chart   LIKE LINE OF gt_chart.

  DATA : lv_menge         TYPE eket-menge,
         lv_smeng         TYPE eban-menge,
         lv_lifnr         TYPE lfa1-lifnr,
         lv_kbetr         TYPE konp-kbetr,
         lv_alloc         TYPE eban-menge,
         lv_meins         TYPE ekpo-meins,
         lv_fieldname(30),
         lv_ebeln         TYPE ekko-ebeln,
         lv_waers         TYPE ekko-waers,
         lv_netpr         TYPE ekpo-netpr,
         lv_matnr         TYPE ekpo-matnr.

  DATA : lv_po  TYPE i,
         lv_npo TYPE i.

  DATA : ls_eine LIKE LINE OF gt_eine,
         ls_eina LIKE LINE OF gt_eina.

  FIELD-SYMBOLS : <fs>        TYPE any.

  gs_head-submi   = pa_submi.

  CASE gv_trtyp.
    WHEN 'H'.
      CLEAR : lv_menge.
      LOOP AT gt_eban INTO ls_eban.
        lv_menge  = ls_eban-menge - ls_eban-bsmng.
        READ TABLE gt_ekpo INTO ls_ekpo
                           WITH KEY werks = ls_eban-werks
                                    matnr = ls_eban-matnr.
        IF sy-subrc = 0.
          IF ls_ekpo-meins <> ls_eban-meins.
            CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
              EXPORTING
                input                = lv_menge
                matnr                = ls_eban-matnr
                meinh                = ls_ekpo-meins
                meins                = ls_eban-meins
              IMPORTING
                output               = lv_menge
              EXCEPTIONS
                conversion_not_found = 1
                input_invalid        = 2
                material_not_found   = 3
                meinh_not_found      = 4
                meins_missing        = 5
                no_meinh             = 6
                output_invalid       = 7
                overflow             = 8
                OTHERS               = 9.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_ldetl> TO <fs>.
        <fs> = ls_eban-banfn.
        ASSIGN COMPONENT 'BNFPO' OF STRUCTURE <fs_ldetl> TO <fs>.
        <fs> = ls_eban-bnfpo.
        ASSIGN COMPONENT 'LGORT' OF STRUCTURE <fs_ldetl> TO <fs>.
        <fs> = ls_eban-lgort.
        ASSIGN COMPONENT 'FRGDT' OF STRUCTURE <fs_ldetl> TO <fs>.
        <fs> = ls_eban-frgdt.
        ASSIGN COMPONENT 'EINDT' OF STRUCTURE <fs_ldetl> TO <fs>.
        <fs> = ls_eban-lfdat.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_ldetl> TO <fs>.
        <fs> = lv_menge.
        ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_ldetl> TO <fs>.
        <fs> = ls_ekpo-meins.   "ls_eban-meins.
        ADD lv_menge TO lv_smeng.
        APPEND <fs_ldetl> TO <fs_detl>.
      ENDLOOP.
      CLEAR lv_menge.

      lt_xekko[] = gt_ekko[].
      SORT lt_xekko BY lifnr ebeln.

      PERFORM f_get_price_unit.

      lt_xekpo[] = gt_ekpo[].
      SORT lt_xekpo BY werks matnr.
      DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING werks matnr.
      LOOP AT gt_lfa1 INTO ls_lfa1.
        CLEAR : ls_xekko, lv_ebeln.
        LOOP AT lt_xekko INTO ls_xekko
                         WHERE lifnr = ls_lfa1-lifnr.
          LOOP AT gt_ekpo INTO ls_ekpo WHERE werks = gs_head-werks
                                         AND matnr = gs_head-matnr
                                         AND ebeln = ls_xekko-ebeln.
            lv_meins = ls_ekpo-meins.
            IF lv_netpr IS INITIAL.
              lv_netpr  = ls_ekpo-netpr.
            ENDIF.

            LOOP AT gt_eket INTO ls_eket WHERE ebeln = ls_ekpo-ebeln
                                           AND ebelp = ls_ekpo-ebelp.
              ADD ls_eket-menge TO lv_menge.
            ENDLOOP.
          ENDLOOP.

          IF sy-subrc = 0.
            IF lv_ebeln IS INITIAL.
              lv_waers  = ls_xekko-waers.
              lv_ebeln  = ls_xekko-ebeln.
            ENDIF.
          ENDIF.
        ENDLOOP.

        READ TABLE gt_ekpo INTO ls_ekpo
                           WITH KEY werks = gs_head-werks
                                    matnr = gs_head-matnr
                                    ebeln = lv_ebeln.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_lfa1-lifnr.
        ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_lfa1-name1.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = gs_head-matnr.
        ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = gs_head-maktx.
        ASSIGN COMPONENT 'MFRPN' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_lfa1-mfrpn.
        ASSIGN COMPONENT 'APLFZ' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_lfa1-aplfz.
        ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = lv_ebeln.
        ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = lv_meins.
        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = lv_menge.
*****        ASSIGN COMPONENT 'NETPR' OF STRUCTURE <fs_lmain> TO <fs>.
*****        <fs> = lv_netpr.
*****        ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_lmain> TO <fs>.
*****        <fs> = lv_waers.

        CLEAR : ls_eina, lv_matnr.
* cari berdasarkan material MPN
        CONDENSE ls_ekpo-idnlf.
        IF ls_ekpo-idnlf IS NOT INITIAL.
          lv_matnr = ls_ekpo-idnlf.
        ELSE.
          lv_matnr = ls_ekpo-matnr.
        ENDIF.
        READ TABLE gt_eina INTO ls_eina
                           WITH KEY lifnr = ls_lfa1-lifnr
                                    matnr = lv_matnr.

*        READ TABLE gt_eina INTO ls_eina
*                           WITH KEY lifnr = ls_lfa1-lifnr
*                                    matnr = gs_head-matnr.
        IF sy-subrc = 0.
          CLEAR ls_eine.
          READ TABLE gt_eine INTO ls_eine
                             WITH KEY infnr = ls_eina-infnr
                                      werks = space.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'NETPR' OF STRUCTURE <fs_lmain> TO <fs>.
            <fs> = ls_eine-netpr.
            ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_lmain> TO <fs>.
            <fs> = ls_eine-waers.
            ASSIGN COMPONENT 'PEINH' OF STRUCTURE <fs_lmain> TO <fs>.
            <fs> = ls_eine-peinh.
            ASSIGN COMPONENT 'BPRME' OF STRUCTURE <fs_lmain> TO <fs>.
            <fs> = ls_eine-bprme.
          ENDIF.
        ELSE.
        ENDIF.

        CASE gv_quarter.
          WHEN 1.
            PERFORM f_get_percen_alokasi TABLES gt_zm73_1
                                         USING ls_lfa1-lifnr
                                         CHANGING lv_kbetr.
          WHEN 2.
            PERFORM f_get_percen_alokasi TABLES gt_zm73_2
                                         USING ls_lfa1-lifnr
                                         CHANGING lv_kbetr.
          WHEN 3.
            PERFORM f_get_percen_alokasi TABLES gt_zm73_3
                                         USING ls_lfa1-lifnr
                                         CHANGING lv_kbetr.
          WHEN 4.
            PERFORM f_get_percen_alokasi TABLES gt_zm73_4
                                         USING ls_lfa1-lifnr
                                         CHANGING lv_kbetr.
        ENDCASE.
        ASSIGN COMPONENT 'KBETR' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = lv_kbetr.

        PERFORM f_calculate_alokasi USING lv_kbetr lv_smeng
                                    CHANGING lv_alloc.

        ASSIGN COMPONENT 'ALLOC' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = lv_alloc.

        PERFORM f_calculate_actual_alokasi USING ls_lfa1-lifnr.

        APPEND <fs_lmain> TO <fs_main>.
        CLEAR : lv_menge, lv_netpr.
      ENDLOOP.

    WHEN 'V' OR 'A'.

      PERFORM f_get_price_unit.

      LOOP AT gt_x04x INTO ls_x04x.
        ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-lifnr.
        ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-name1.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-matnr.
        SELECT SINGLE maktx
          FROM makt
          INTO ls_x04x-maktx
          WHERE matnr = ls_x04x-matnr.
        ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-maktx.
        ASSIGN COMPONENT 'MFRPN' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-mfrpn.
        ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-ebeln.
        ASSIGN COMPONENT 'NETPR' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-netpr.
        ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-waers.

        CLEAR ls_eina.
        READ TABLE gt_eina INTO ls_eina
                           WITH KEY lifnr = ls_x04x-lifnr
                                    matnr = ls_x04x-matnr.
        IF sy-subrc = 0.
          CLEAR ls_eine.
          READ TABLE gt_eine INTO ls_eine
                             WITH KEY infnr = ls_eina-infnr.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'PEINH' OF STRUCTURE <fs_lmain> TO <fs>.
            <fs> = ls_eine-peinh.
            ASSIGN COMPONENT 'BPRME' OF STRUCTURE <fs_lmain> TO <fs>.
            <fs> = ls_eine-bprme.
          ENDIF.
        ENDIF.

        ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-etmen.
        ASSIGN COMPONENT 'BOBOT' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-bobot.
        ASSIGN COMPONENT 'ALLOC' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-bamng.
        ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-bamei.
        ASSIGN COMPONENT 'KBETR' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-kbetr.
        ASSIGN COMPONENT 'REVIS' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-menge.
        ASSIGN COMPONENT 'KBETR1' OF STRUCTURE <fs_lmain> TO <fs>.
        <fs> = ls_x04x-kbet1.

        PERFORM f_calculate_actual_alokasi USING ls_x04x-lifnr.

        APPEND <fs_lmain> TO <fs_main>.

        ls_chart-lifnr = ls_x04x-lifnr.
        ls_chart-menge = ls_x04x-etmen.
        ls_chart-zeile    = 0.
        ls_chart-check    = 'X'.
        APPEND ls_chart TO gt_chart.
        ADD ls_chart-menge TO gv_menge.

        CLEAR : <fs_lmain>, ls_chart.
      ENDLOOP.

      lt_04y[] = gt_x04y[].
      SORT lt_04y BY banfn bnfpo.
      DELETE ADJACENT DUPLICATES FROM lt_04y COMPARING banfn bnfpo.
      CLEAR : gv_new, ls_04y.
      IF gt_x04e[] IS INITIAL.
        gv_new = space.
      ENDIF.

      LOOP AT lt_04y INTO ls_04y.
        LOOP AT gt_x04y INTO ls_x04y WHERE banfn = ls_04y-banfn
                                       AND bnfpo = ls_04y-bnfpo.
          ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_ldetl> TO <fs>.
          <fs> = ls_x04y-banfn.
          ASSIGN COMPONENT 'BNFPO' OF STRUCTURE <fs_ldetl> TO <fs>.
          <fs> = ls_x04y-bnfpo.
          ASSIGN COMPONENT 'LGORT' OF STRUCTURE <fs_ldetl> TO <fs>.
          <fs> = ls_x04y-lgort.
          ASSIGN COMPONENT 'FRGDT' OF STRUCTURE <fs_ldetl> TO <fs>.
          <fs> = ls_x04y-frgdt.
          ASSIGN COMPONENT 'EINDT' OF STRUCTURE <fs_ldetl> TO <fs>.
          <fs> = ls_x04y-lfdat.
          ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_ldetl> TO <fs>.
          <fs> = ls_x04y-menge.
          ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_ldetl> TO <fs>.
          <fs> = ls_x04y-meins.

          CONCATENATE 'REVIS' ls_x04y-lifnr INTO lv_fieldname.
          ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldetl> TO <fs>.
          <fs> = ls_x04y-bsmng.

          PERFORM f_temp_data USING 'VENDOR' ls_x04y-banfn ls_x04y-bnfpo
                                    ls_x04y-lifnr '' '' '' ls_x04y-bsmng.
        ENDLOOP.
        APPEND <fs_ldetl> TO <fs_detl>.
      ENDLOOP.

      LOOP AT gt_x04p INTO ls_x04p.
        MOVE-CORRESPONDING ls_x04p TO ls_xsplitq.
        ls_xsplitq-revis   = ls_x04p-menge.
        ls_xsplitq-split   = 'X'.
        APPEND ls_xsplitq TO gt_xsplitq.
        CLEAR ls_xsplitq.

        MOVE-CORRESPONDING ls_x04p TO ls_chart.
        APPEND ls_chart TO gt_chart.
        CLEAR ls_chart.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_DATA
*&---------------------------------------------------------------------*
FORM f_print_data .
*  IF gt_out[] IS NOT INITIAL.
  CALL SCREEN 101.
*  ENDIF.
ENDFORM.                    " F_PRINT_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DOCKING_SPLIT_CONTAINER
*&---------------------------------------------------------------------*
FORM f_docking_split_container .
  DATA : lv_contname(20).

  lv_contname   = 'CC_MAIN'.

  IF g_customcont IS INITIAL.
    CREATE OBJECT g_customcont
      EXPORTING
        container_name              = lv_contname
      EXCEPTIONS
        cntl_error                  = 1
        cntl_system_error           = 2
        create_error                = 3
        lifetime_error              = 4
        lifetime_dynpro_dynpro_link = 5.

    CREATE OBJECT g_splitter
      EXPORTING
        parent  = g_customcont
        rows    = 2
        columns = 1.

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 1
        column    = 1
      RECEIVING
        container = g_contain01.

    CALL METHOD g_splitter->set_row_sash
      EXPORTING
        id    = 1
        type  = cl_gui_splitter_container=>type_movable
        value = cl_gui_splitter_container=>false.

    g_splitter->set_row_height( id = 1 height = 30 ).

    CALL METHOD g_splitter->get_container
      EXPORTING
        row       = 2
        column    = 1
      RECEIVING
        container = g_contain02.
  ENDIF.
ENDFORM.                    " F_DOCKING_SPLIT_CONTAINER

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA : fcode    TYPE TABLE OF sy-ucomm.

  CREATE OBJECT event_receiver.

  IF gt_mess[] IS NOT INITIAL.
    dynlog-icon_id      = icon_error_protocol.
    dynlog-icon_text    = 'Error Log'.
  ELSE.
    CLEAR dynlog.
  ENDIF.

*  PERFORM f_modify_screen USING :
*    'MER' '' '' '0' '' '' ''.

  CASE sy-dynnr.
    WHEN '0101'.
      APPEND '&DIST_Q' TO fcode.
      APPEND '&DELE' TO fcode.
      "      APPEND '&FPKH' TO fcode.
      CASE gv_trtyp.
        WHEN 'A'.
          APPEND '&LOG' TO fcode.
*          APPEND '&PREV' TO fcode.
          APPEND '&POS' TO fcode.
          IF gv_new IS INITIAL.
            APPEND '&NEW' TO fcode.
          ENDIF.
          PERFORM f_modify_screen USING :
            '' '' 'GS_HEAD-MERGE' '' '0' '' ''.
        WHEN 'V'.
          IF gv_new IS INITIAL.
            APPEND '&NEW' TO fcode.
          ENDIF.
          PERFORM f_modify_screen USING :
            '002' '' '' '' '' '1' ''.
        WHEN 'H'.
          APPEND '&NEW' TO fcode.
          APPEND '&PIR' TO fcode.
          PERFORM f_modify_screen USING :
            '002' '' '' '' '' '1' ''.
      ENDCASE.

      IF gs_head-peinh IS INITIAL.
        PERFORM f_modify_screen USING :
          'PER' '' '' '0' '' '' ''.
      ENDIF.

*      CASE 'X'.
*        WHEN radio1.
      APPEND '&UPLD' TO fcode.
*      ENDCASE.

*      IF gv_upir IS INITIAL.
      IF gv_upir IS NOT INITIAL.
        APPEND '&PIR' TO fcode.
      ENDIF.

      SET TITLEBAR 'TITLE'.

    WHEN '0102'.
      APPEND '&NEW' TO fcode.
      APPEND '&LOG' TO fcode.
      APPEND '&PREV' TO fcode.
      APPEND '&DELE' TO fcode.
      APPEND '&UPLD' TO fcode.
      APPEND '&PIR' TO fcode.
      APPEND '&FPKH' TO fcode.

      CASE gv_trtyp.
        WHEN 'A'.
          APPEND '&POS' TO fcode.
      ENDCASE.

      SET TITLEBAR 'TITLE'.

    WHEN '0103'.
      APPEND '&NEW' TO fcode.
      APPEND '&LOG' TO fcode.
      APPEND '&PREV' TO fcode.
      APPEND '&DIST_Q' TO fcode.
      APPEND '&DELE' TO fcode.
      APPEND '&UPLD' TO fcode.
      APPEND '&PIR' TO fcode.
      APPEND '&FPKH' TO fcode.
**      CASE gv_trtyp.
**        WHEN 'A'.
**          APPEND '&POS' TO fcode.
**      ENDCASE.
      SET TITLEBAR 'TITLE'.

    WHEN '0104'.
      APPEND '&NEW' TO fcode.
      APPEND '&LOG' TO fcode.
      APPEND '&PREV' TO fcode.
      APPEND '&DIST_Q' TO fcode.
      APPEND '&DELE' TO fcode.
      APPEND '&UPLD' TO fcode.
      APPEND '&PIR' TO fcode.
      APPEND '&FPKH' TO fcode.

      SET TITLEBAR 'TITLE'.

    WHEN '0105'.
      APPEND '&NEW' TO fcode.
      APPEND '&LOG' TO fcode.
      APPEND '&PREV' TO fcode.
      APPEND '&DIST_Q' TO fcode.
      APPEND '&UPLD' TO fcode.
      APPEND '&PIR' TO fcode.
      APPEND '&FPKH' TO fcode.
      CASE gv_trtyp.
        WHEN 'A'.
          APPEND '&POS' TO fcode.
          APPEND '&DELE' TO fcode.
      ENDCASE.

      SET TITLEBAR 'TITLE_SPLIT'.

    WHEN '0106'.
      APPEND '&NEW' TO fcode.
      APPEND '&LOG' TO fcode.
      APPEND '&PREV' TO fcode.
      APPEND '&DIST_Q' TO fcode.
      APPEND '&DELE' TO fcode.
      APPEND '&UPLD' TO fcode.
      APPEND '&PIR' TO fcode.
      APPEND '&FPKH' TO fcode.

      SET TITLEBAR 'TITLE_PIR'.
  ENDCASE.

  SET PF-STATUS 'PFSTATUS' EXCLUDING fcode.

  IF pa_submi IS INITIAL.
    PERFORM f_modify_screen USING :
      '001' '' '' '' '' '1' ''.
  ENDIF.

  PERFORM f_excluding_toolbar CHANGING gs_exclude2.

ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  DATA : ls_xsplitq LIKE LINE OF gt_xsplitq,
         ls_ysplitq LIKE LINE OF gt_xsplitq.

  CASE sy-dynnr.
    WHEN '0101'.
      CLEAR : gt_vendor[], gt_vendor, gs_vendor.
      PERFORM f_lock_data USING ''.
    WHEN '0102'.
      IF gt_ysplitq[] IS NOT INITIAL.
        LOOP AT gt_xsplitq INTO ls_xsplitq.
          READ TABLE gt_ysplitq INTO ls_ysplitq
                                WITH KEY banfn = ls_xsplitq-banfn
                                         bnfpo = ls_xsplitq-bnfpo
                                         zeile = ls_xsplitq-zeile
                                         lifnr = ls_xsplitq-lifnr.
          IF sy-subrc = 0.
            DELETE gt_xsplitq FROM ls_xsplitq.
          ENDIF.
        ENDLOOP.
      ENDIF.
      CASE gv_trtyp.
        WHEN 'H'.
          CLEAR : gt_vendor[], gt_vendor, gs_vendor.
        WHEN OTHERS.
          CLEAR : gt_vendor[], gt_vendor, gs_vendor.
      ENDCASE.
    WHEN '0105'.
      CLEAR : gt_splitq[], gt_splitq.
    WHEN '0106'.
      CLEAR : gt_dpir[], gs_dpir, gs_hpir.
    WHEN OTHERS.
      CLEAR : gt_vendor[], gt_vendor, gs_vendor.
  ENDCASE.

  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND
*&---------------------------------------------------------------------*
FORM f_user_command .
  DATA : lv_ucomm  TYPE sy-ucomm,
         lv_valid  TYPE c,
         lt_fidx   TYPE lvc_t_fidx,
         ls_fidx   TYPE sy-tabix,
         ls_filter LIKE LINE OF gt_filter,
         lv_subrc  TYPE sy-subrc.

  DATA : ls_vendor  LIKE LINE OF gt_vendor,
         ls_splitq  LIKE LINE OF gt_splitq,
         ls_xsplitq LIKE LINE OF gt_xsplitq.

  DATA : lv_fieldname(30),
         ls_line          TYPE REF TO data,
         lv_nodekey       TYPE lvc_nkey.

  DATA : ls_mess         LIKE LINE OF gt_mess,
         lt_nodes        TYPE lvc_t_nkey,
         lv_nodes        TYPE lvc_nkey,
         lv_revis        TYPE ekpo-menge,
         lv_rtemp        TYPE ekpo-menge,
         lv_message(100),
         lv_url          TYPE zurl,
         lv_noform       TYPE char80. ",
  "         lv_lampiran     TYPE zurl.

  DATA : lv_zeile TYPE mseg-zeile,
         ls_x04c  LIKE LINE OF gt_x04c,
         ls_dpir  LIKE LINE OF gt_dpir.

  FIELD-SYMBOLS <fs>    TYPE any.

  lv_ucomm  = ok_code.
  CLEAR ok_code.

  CASE lv_ucomm.
    WHEN '&PIR'.
      CALL METHOD g_tabgrid01->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_change_pir.
      ENDIF.

    WHEN '&LOG'.
      PERFORM f_display_message USING '' ''.

    WHEN '&ALL'.
      CALL METHOD g_tabgrid01->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING 'X'.
      ENDIF.

    WHEN '&SAL'.
      CALL METHOD g_tabgrid01->check_changed_data
        IMPORTING
          e_valid = lv_valid.

      IF lv_valid IS NOT INITIAL.
        PERFORM f_select USING ''.
      ENDIF.

    WHEN '&POS'.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid01->check_changed_data
            IMPORTING
              e_valid = lv_valid.

          IF lv_valid IS NOT INITIAL.
            PERFORM f_prepare_data.
            PERFORM f_prepare_lampiran.
            PERFORM f_prepare_save.
            PERFORM f_save_data CHANGING lv_subrc lv_message.

            IF lv_subrc IS INITIAL.
              IF gt_heads[] IS INITIAL.
                PERFORM f_print_form USING lv_ucomm 'X' '' 'X' ''.
                IF gv_po IS INITIAL.
                  PERFORM f_print_lampiran_pr USING lv_ucomm '' 'X' 'X' 'X'.
                ELSE.
                  PERFORM f_print_lampiran_po USING lv_ucomm '' 'X' 'X' 'X'.
                ENDIF.
              ELSEIF pa_prgrp IS INITIAL.
                PERFORM f_print_form USING lv_ucomm 'X' '' 'X' ''.
                IF gv_po IS INITIAL.
                  PERFORM f_print_lampiran_pr USING lv_ucomm 'X' 'X' 'X' ''.
                ELSE.
                  PERFORM f_print_lampiran_po USING lv_ucomm 'X' 'X' 'X' ''.
                ENDIF.
                PERFORM f_print_lampiran USING lv_ucomm '' 'X' 'X' 'X'.
              ELSE.
                PERFORM f_print_form USING lv_ucomm 'X' '' 'X' ''.
                IF gv_po IS INITIAL.
                  PERFORM f_print_lampiran_pr USING lv_ucomm 'X' 'X' 'X' ''.
                ELSE.
                  PERFORM f_print_lampiran_po USING lv_ucomm 'X' 'X' 'X' ''.
                ENDIF.

                IF gt_006[] IS NOT INITIAL.
                  PERFORM f_print_lampiran USING lv_ucomm 'X' 'X' 'X' ''.
                  PERFORM f_print_lampiran_1 USING lv_ucomm '' 'X' 'X' 'X'.
                ELSE.
                  PERFORM f_print_lampiran USING lv_ucomm '' 'X' 'X' 'X'.
                ENDIF.
              ENDIF.

              MESSAGE s000(zab) WITH 'Data already processed'.
              LEAVE TO SCREEN 0.
            ELSE.
              MESSAGE s000(zab) WITH lv_message DISPLAY LIKE 'E'.
            ENDIF.
          ENDIF.

        WHEN '0102'.
          LOOP AT gt_vendor INTO ls_vendor.
            CONCATENATE 'REVIS' ls_vendor-lifnr INTO lv_fieldname.
            ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldetl> TO <fs>.
            <fs> = ls_vendor-revis.

            PERFORM f_temp_data USING 'VENDOR' gs_pr-banfn gs_pr-bnfpo
                                      ls_vendor-lifnr '' '' '' ls_vendor-revis.
            ADD ls_vendor-revis TO lv_revis.
          ENDLOOP.

          READ TABLE <fs_detl> ASSIGNING <fs_ldetl> INDEX gs_pr-tabix.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ldetl> TO <fs>.
            IF lv_revis <> 0.
              IF lv_revis > gs_pr-menge.
                PERFORM f_store_message USING '1' 'Qty Revisi greater than Qty Requested'.
                <fs> = icon_led_red.
              ELSEIF lv_revis < gs_pr-menge.
                PERFORM f_store_message USING '2' 'Qty Revisi less than Qty Requested'.
                <fs> = icon_led_yellow.
              ELSE.
                PERFORM f_store_message USING '' ''.
                <fs> = icon_led_green.
              ENDIF.
            ELSE.
              PERFORM f_store_message USING '' ''.
              CLEAR <fs>.
            ENDIF.
          ENDIF.

          MODIFY <fs_detl> FROM <fs_ldetl> INDEX gs_pr-tabix.
          CLEAR : gt_vendor[], gt_vendor, gs_vendor.

          PERFORM f_sum_revisi.
          LEAVE TO SCREEN 0.

        WHEN '0103'.
          READ TABLE <fs_main> ASSIGNING <fs_lmain> INDEX gs_quot-tabix.
          ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lmain> TO <fs>.
          <fs> = gs_quot-ebeln.
          ASSIGN COMPONENT 'NETPR' OF STRUCTURE <fs_lmain> TO <fs>.
          <fs> = gs_quot-netpr.
          ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_lmain> TO <fs>.
          <fs> = gs_quot-waers.

          MODIFY <fs_main> FROM <fs_lmain> INDEX gs_quot-tabix.

          PERFORM f_save_text.

          PERFORM f_prepare_data.
          PERFORM f_prepare_lampiran.

          PERFORM f_print_form USING lv_ucomm 'X' '' 'X' ''.
          IF gv_po IS INITIAL.
            PERFORM f_print_lampiran_pr USING lv_ucomm 'X' 'X' 'X' ''.
          ELSE.
            PERFORM f_print_lampiran_po USING lv_ucomm 'X' 'X' 'X' ''.
          ENDIF.
          IF pa_prgrp IS INITIAL.
            PERFORM f_print_lampiran USING lv_ucomm '' 'X' 'X' ''.
          ELSE.
            IF gt_006[] IS NOT INITIAL.
              PERFORM f_print_lampiran USING lv_ucomm 'X' 'X' 'X' ''.
              PERFORM f_print_lampiran_1 USING lv_ucomm '' 'X' 'X' ''.
            ELSE.
              PERFORM f_print_lampiran USING lv_ucomm '' 'X' 'X' ''.
            ENDIF.
          ENDIF.

          LEAVE TO SCREEN 0.

        WHEN '0104'.
          CASE gv_upload.
            WHEN '1'.
              PERFORM f_get_upload_data.
            WHEN '2'.
              PERFORM f_get_data_prgrp USING pa_submi pa_prgrp 'X'.
          ENDCASE.
          LEAVE TO SCREEN 0.

        WHEN '0105'.
          DELETE gt_xsplitq WHERE lifnr = gs_pr-lifnr
                              AND banfn = gs_pr-banfn
                              AND bnfpo = gs_pr-bnfpo.
          LOOP AT gt_splitq INTO ls_splitq.
            IF ls_splitq-revis IS NOT INITIAL AND
              ls_splitq-zeile IS INITIAL.
              lv_subrc = 4.
              EXIT.
            ENDIF.
            PERFORM f_temp_data USING 'SPLIT' gs_pr-banfn gs_pr-bnfpo
                                      gs_pr-lifnr gs_pr-meins gs_pr-lgort
                                      ls_splitq-zeile ls_splitq-revis.
            ADD ls_splitq-revis TO lv_revis.
          ENDLOOP.

          IF lv_revis > gs_pr-menge.    "gs_pr-alloc.
            MESSAGE i000(zab) WITH 'Split Qty greater than Scheduled Qty'
            DISPLAY LIKE 'E'.
*            MESSAGE i000(zab) WITH 'Split Qty greater than Allocation Qty'
*            DISPLAY LIKE 'E'.
          ELSEIF lv_subrc IS NOT INITIAL.
            MESSAGE i000(zab) WITH 'PO must be entries' DISPLAY LIKE 'E'.
          ELSE.
            CLEAR : ls_vendor-mark.
            ls_vendor-revis   = lv_revis.
            ls_vendor-split   = 'X'.
            ls_vendor-kbetr1  = ( ls_vendor-revis / gs_pr-menge ) * 100.
            MODIFY gt_vendor FROM ls_vendor
                             TRANSPORTING mark revis split kbetr1
                             WHERE lifnr = gs_pr-lifnr.

            CLEAR : gt_splitq[], gt_splitq.
            LEAVE TO SCREEN 0.
          ENDIF.

        WHEN '0106'.
          lv_zeile  = '18'.
          READ TABLE gt_dpir INTO ls_dpir
                             WITH KEY check = 'X'.
          IF sy-subrc = 0.
            PERFORM f_kbetr_calc USING ls_dpir-kbetr ls_dpir-skonwa
                                       ls_dpir-kpein ls_dpir-kmein
                                 CHANGING ls_x04c-value.

            MODIFY gt_x04c FROM ls_x04c
                           TRANSPORTING value
                           WHERE zalno = gs_hpir-zalno
                                    AND lifnr = gs_hpir-lifnr
                                    AND zeile = lv_zeile.
            TRY .
                UPDATE zgdmmt004c SET value = ls_x04c-value
                                  WHERE zalno = gs_hpir-zalno
                                    AND lifnr = gs_hpir-lifnr
                                    AND zeile = lv_zeile.
              CATCH cx_sy_open_sql_db.
            ENDTRY.
******* Update PIR untuk yg scale --- 3 feb 2025 - sekar
            PERFORM f_update_pir USING gs_hpir-lifnr gs_hpir-matnr ls_dpir-kbetr ls_dpir-skonwa.

          ENDIF.
          CLEAR : gt_dpir[], gs_dpir, gs_hpir.
          MESSAGE s000(zab) WITH 'Data PIR already updated'.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN '&DELE'.
      CASE sy-dynnr.
        WHEN '0105'.
          CLEAR : ls_vendor-mark, ls_vendor-revis, ls_vendor-split,
                  ls_vendor-kbetr1.
          MODIFY gt_vendor FROM ls_vendor
                           TRANSPORTING mark revis split kbetr1
                           WHERE lifnr = gs_pr-lifnr.

          DELETE gt_xsplitq WHERE lifnr = gs_pr-lifnr.
          CLEAR : gt_splitq[], gt_splitq.
          LEAVE TO SCREEN 0.
      ENDCASE.

    WHEN '&OUP' OR '&ODN' OR '&OL0'.
      CALL METHOD g_tabgrid01->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      gt_xout[] = gt_out[].

    WHEN '&ILT'.
      CALL METHOD g_tabgrid01->set_function_code
        CHANGING
          c_ucomm = lv_ucomm.

      CLEAR : gt_filter[].
      CALL METHOD g_tabgrid01->get_filtered_entries
        IMPORTING
          et_filtered_entries = lt_fidx.

      IF lt_fidx[] IS INITIAL.
        PERFORM f_select USING ''.
      ELSE.
        LOOP AT lt_fidx INTO ls_fidx.
          ls_filter-index = ls_fidx.
          APPEND ls_filter TO gt_filter.
        ENDLOOP.
      ENDIF.

    WHEN '&PREV'.
      PERFORM f_prepare_data.
      PERFORM f_prepare_lampiran.
      IF gt_heads[] IS INITIAL.
        PERFORM f_print_form USING lv_ucomm 'X' '' '' ''.
        IF gv_po IS INITIAL.
          PERFORM f_print_lampiran_pr USING lv_ucomm '' 'X' '' ''.
        ELSE.
          PERFORM f_print_lampiran_po USING lv_ucomm '' 'X' '' ''.
        ENDIF.
      ELSEIF pa_prgrp IS INITIAL.
        PERFORM f_print_form USING lv_ucomm 'X' '' '' ''.
        IF gv_po IS INITIAL.
          PERFORM f_print_lampiran_pr USING lv_ucomm 'X' 'X' '' ''.
        ELSE.
          PERFORM f_print_lampiran_po USING lv_ucomm 'X' 'X' '' ''.
        ENDIF.
        PERFORM f_print_lampiran USING lv_ucomm '' 'X' '' ''.
      ELSE.
        PERFORM f_print_form USING lv_ucomm 'X' '' '' ''.
        IF gv_po IS INITIAL.
          PERFORM f_print_lampiran_pr USING lv_ucomm 'X' 'X' '' ''.
        ELSE.
          PERFORM f_print_lampiran_po USING lv_ucomm 'X' 'X' '' ''.
        ENDIF.
        IF gt_006[] IS NOT INITIAL.
          PERFORM f_print_lampiran USING lv_ucomm 'X' 'X' '' ''.
          PERFORM f_print_lampiran_1 USING lv_ucomm '' 'X' '' ''.
        ELSE.
          PERFORM f_print_lampiran USING lv_ucomm '' 'X' '' ''.
        ENDIF.
      ENDIF.

    WHEN '&FPKH'.
      PERFORM f_print_fpkh USING 'HSM_FORMFPKH' 'X'
                           CHANGING lv_url lv_noform. " lv_lampiran.

    WHEN '&DIST_Q'.
      READ TABLE gt_vendor INTO ls_vendor
                           WITH KEY mark = 'X'.
      IF sy-subrc = 0.
        gs_pr-lifnr   = ls_vendor-lifnr.
        gs_pr-name1l  = ls_vendor-name1.
        gs_pr-kbetr   = ls_vendor-kbetr.
        gs_pr-alloc   = ls_vendor-alloc.
        gs_pr-lgort   = gs_pr-lgort.
        gs_pr-mein1   = gs_pr-meins.
        gs_pr-mein2   = gs_pr-meins.

        IF ls_vendor-split IS INITIAL.
          lv_rtemp  = ls_vendor-revis.
          CLEAR ls_vendor-revis.
          MODIFY TABLE gt_vendor FROM ls_vendor.
        ENDIF.

        READ TABLE gt_xsplitq INTO ls_xsplitq
                              WITH KEY lifnr = ls_vendor-lifnr
                                       banfn = gs_pr-banfn
                                       bnfpo = gs_pr-bnfpo.
        IF sy-subrc = 0.
          CLEAR ls_xsplitq.
          LOOP AT gt_xsplitq INTO ls_xsplitq WHERE lifnr = ls_vendor-lifnr
                                               AND banfn = gs_pr-banfn
                                               AND bnfpo = gs_pr-bnfpo.
            ls_splitq-zeile = ls_xsplitq-zeile.
            ls_splitq-revis = ls_xsplitq-revis.

            CASE gv_trtyp.
              WHEN 'H'.
              WHEN OTHERS.
                IF ls_xsplitq-revis = 0.
                  CONTINUE.
                ENDIF.
            ENDCASE.
            APPEND ls_splitq TO gt_splitq.
            CLEAR ls_splitq.
          ENDLOOP.
        ELSE.
          ls_splitq-zeile = 1.
          IF lv_rtemp IS NOT INITIAL.
            ls_splitq-revis = lv_rtemp.
          ELSE.
            ls_splitq-revis = ls_vendor-alloc.
          ENDIF.
          APPEND ls_splitq TO gt_splitq.
          CLEAR ls_splitq.
        ENDIF.
        CLEAR lv_rtemp.

        CALL SCREEN 105 STARTING AT 10 10.
      ELSE.
        MESSAGE i000(zab) WITH 'No data selected' DISPLAY LIKE 'E'.
      ENDIF.

    WHEN '&UPLD'.
      PERFORM f_upload_data USING lv_ucomm.

    WHEN OTHERS.
      CASE sy-dynnr.
        WHEN '0101'.
          CALL METHOD g_tabgrid02->set_function_code
            CHANGING
              c_ucomm = lv_ucomm.

        WHEN '0102'.
          LOOP AT gt_vendor INTO ls_vendor.
            ls_vendor-kbetr1 = ( ls_vendor-revis / gs_pr-menge ) * 100.
            MODIFY gt_vendor FROM ls_vendor
                             TRANSPORTING kbetr1.
          ENDLOOP.
      ENDCASE.
*      CALL METHOD g_tree->set_function_code
*        EXPORTING
*          i_ucomm = lv_ucomm.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND

*&---------------------------------------------------------------------*
*&      Form  F_MAIN_ALV
*&---------------------------------------------------------------------*
FORM f_main_alv .
  CREATE OBJECT g_tabgrid01
    EXPORTING
      i_appl_events = selected
      i_parent      = g_contain01.

  PERFORM f_build_layout USING 'MAIN'.
  PERFORM f_build_sort USING 'MAIN'.

  SET HANDLER event_receiver->handle_double_click
              event_receiver->handle_toolbar
              event_receiver->handle_menu_button
              event_receiver->handle_user_command FOR g_tabgrid01.

  CALL METHOD g_tabgrid01->set_table_for_first_display
    EXPORTING
      is_layout            = gs_main_layout
      i_save               = 'A'
      is_variant           = gs_variant
      i_default            = 'X'
      it_toolbar_excluding = gs_exclude1
    CHANGING
      it_sort              = gt_main_sort[]
      it_outtab            = <fs_main>[]
      it_fieldcatalog      = gt_main_fieldcat[].

  IF gt_xout[] IS INITIAL.
    gt_xout[] = gt_out[].
  ENDIF.
ENDFORM.                    " F_MAIN_ALV

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_LAYOUT
*&---------------------------------------------------------------------*
FORM f_build_layout USING   fu_container.
  CASE fu_container.
    WHEN 'MAIN'.
      gs_main_layout-box_fname           = 'CHECK'.
      gs_main_layout-s_dragdrop-row_ddid = g_handle_alv.
*  gs_main_layout-no_rowmark          = selected.
      gs_main_layout-cwidth_opt          = selected.
      gs_main_layout-stylefname          = 'STYLE'.
      gs_main_layout-ctab_fname          = 'COLOR'.
      gs_main_layout-zebra               = selected.
      gs_main_layout-no_toolbar          = selected.
*  gs_main_layout-totals_bef          = selected.
    WHEN 'DETL'.
*  gs_detl_layout-box_fname           = 'CHECK'.
      gs_detl_layout-s_dragdrop-row_ddid = g_handle_alv.
*  gs_detl_layout-no_rowmark          = selected.
      gs_detl_layout-cwidth_opt          = selected.
      gs_detl_layout-stylefname          = 'STYLE'.
      gs_detl_layout-ctab_fname          = 'COLOR'.
      gs_detl_layout-zebra               = selected.
*      gs_detl_layout-no_toolbar          = selected.
*  gs_detl_layout-totals_bef          = selected.
  ENDCASE.
ENDFORM.                    " F_BUILD_LAYOUT

*&---------------------------------------------------------------------*
*&      Form  F_BUILD_SORT
*&---------------------------------------------------------------------*
FORM f_build_sort USING   fu_container.
  CASE fu_container.
    WHEN 'MAIN'.
*      CLEAR gt_main_sort.
*      PERFORM f_alv_sort TABLES gt_main_sort
*                         USING : 1 'MATNR' 'X' '' ''.
    WHEN 'DETL'.
      CLEAR gt_detl_sort.
      PERFORM f_alv_sort TABLES gt_detl_sort
                         USING : 1 'BANFN' 'X' '' ''.
  ENDCASE.
ENDFORM.                    " F_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM  f_create_dyn_int_table .
  DATA : ls_lfa1 LIKE LINE OF gt_lfa1,
         ls_ekko LIKE LINE OF gt_ekko,
         ls_ekpo LIKE LINE OF gt_ekpo.

  DATA : lv_ebeln(30),
         lv_lifnr(30),
         lv_alloc(30),
         lv_revis(30),
         lv_percen(30),
         lv_title(100),
         lv_count      TYPE i,
         lv_index      TYPE i.

*  PERFORM f_dyn_int_table USING :
*    'MARK' '' '' '' '' '' 'X' '' '' 'X' '' '' '' 'X' '' ''
*    'X' 'X' '' '' ''.
  PERFORM f_dyn_int_table USING :
    'MAIN' 'LIFNR' '' '' '' '' '' '' 'LIFNR' 'EKKO' '' '' '' '' '' '' ''
    '' 'X' '' '' '' '',
    'MAIN' 'NAME1' '' '' '' '' '' '' 'NAME1' 'LFA1' 'Vendor Name'
    '' '' '' '' '' '' '' 'X' '' '' '' '',
    'MAIN' 'MATNR' '' '' '' '' '' '' 'MATNR' 'MARA' '' '' '' '' '' '' ''
    '' 'X' '' '' '' '',
    'MAIN' 'MAKTX' '' '' '' '' '' '' 'MAKTX' 'MAKT' '' '' '' '' '' '' ''
    '' 'X' '' '' '' '',
    'MAIN' 'MFRPN' '' '' '' '' '' '' 'MFRPN' 'MARA' '' '' '' '' '' '' ''
    '' 'X' '' '' '' '',
    'MAIN' 'EBELN' '' '' '' '' '' '' 'EBELN' 'EKKO' 'Quotation No.'
    '' '' '' '' '' '' '' 'X' '' '' '' '',
    'MAIN' 'MEINS' '' '' '' '' '' '' 'MEINS' 'EKPO' '' '' '' '' '' '' ''
    '' 'X' '' '' '' '',
    'MAIN' 'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'EKET' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAIN' 'NETPR' '' '' 'WAERS' '' '' '' 'NETPR' 'EKPO' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAIN' 'PEINH' '' '' '' '' 'BPRME' '' 'PEINH' 'EINE' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAIN' 'BPRME' '' '' '' '' '' '' 'BPRME' 'EINE' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAIN' 'WAERS' '' '' '' '' '' '' 'WAERS' 'EKKO' '' '' '' '' '' '' ''
    '' '' '' '' '' '',
    'MAIN' 'KBETR' '' '' '' '' '' '' 'KBETR' 'KONP' '% Alokasi' ''
    '' '' '' '' '' '' '' '' '' '' '',
    'MAIN' 'APLFZ' '' '' '' '' '' '' 'APLFZ' 'EINE' '' '' '' 'X' '' '' '' '' ''
    '' '' '' '',
    'MAIN' 'BOBOT' '' '' '' '' '' '' '' '' '' '' '' 'X' '' '' '' '' ''
    '' '' '' '',
    'MAIN' 'ALLOC' '' '' '' '' 'MEINS' '' 'MENGE' 'EKET' 'Quantity Alokasi' ''
    '' '' '' '' '' '' '' '' '' '' '',
    'MAIN' 'KBETR1' '' '' '' '' '' '' 'KBETR' 'KONP' '% Revisi' '' '' '' '' ''
    '' '' '' '' '' '' '',
    'MAIN' 'REVIS' '' '' '' '' 'MEINS' '' 'MENGE' 'EKET' 'Quantity Revisi' ''
    '' '' '' '' '' '' '' '' '' '' ''.

  PERFORM f_dyn_int_table USING :
    'DETL' 'ICON' '' '' '' '' '' '' '' '' 'Sts.' '' '' '' '' '' ''
    '' 'X' '' '' '' 1.

  PERFORM f_dyn_int_table USING :
    'DETL' 'BANFN' '' '' '' '' '' '' 'BANFN' 'EKET' '' '' '' '' '' '' ''
    '' 'X' '' '' '' 2,
    'DETL' 'BNFPO' '' '' '' '' '' '' 'BNFPO' 'EKET' '' '' '' '' '' '' ''
    '' 'X' '' '' '' 3,
    'DETL' 'LGORT' '' '' '' '' '' '' 'LGORT' 'EBAN' '' '' '' '' '' '' ''
    '' 'X' '' '' '' 4,
    'DETL' 'FRGDT' '' '' '' '' '' '' 'FRGDT' 'EBAN' '' '' 'D' '' '' '' ''
    '' 'X' '' '' '' 5,
    'DETL' 'EINDT' '' '' '' '' '' '' 'EINDT' 'EKET' '' '' 'D' '' '' '' ''
    '' 'X' '' '' '' 6,
    'DETL' 'MENGE' '' '' '' '' 'MEINS' '' 'MENGE' 'EBAN' '' '' '' '' '' '' ''
    '' 'X' '' '' '' 7,
*    'DETL' 'BSMNG' '' '' '' '' 'MEINS' '' 'BSMNG' 'EBAN' '' '' '' 'X' '' '' ''
*    '' 'X' '' '' '' '',
    'DETL' 'MEINS' '' '' '' '' '' '' 'MEINS' 'EKPO' '' '' '' '' '' '' ''
    '' 'X' '' '' '' 8.

  lv_count = 8.
  LOOP AT gt_lfa1 INTO ls_lfa1.
    IF gv_trtyp = 'H'.
      CLEAR lv_index.
      LOOP AT gt_ekko INTO ls_ekko WHERE lifnr = ls_lfa1-lifnr.
        LOOP AT gt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
          ADD 1 TO lv_index.
        ENDLOOP.
      ENDLOOP.
      IF lv_index = 0.
        CONTINUE.
      ENDIF.
    ENDIF.
    lv_count   = lv_count + 1.
    CONCATENATE 'REVIS' ls_lfa1-lifnr INTO lv_revis.
    PERFORM f_dyn_int_table USING :
      'DETL' lv_revis '' '' '' '' 'MEINS' '' 'MENGE' 'EKET' ls_lfa1-name1 ''
      '' '' '' '' '' '' '' '' '' '' lv_count.
  ENDLOOP.

  PERFORM f_create_dyn_label USING 1.
  PERFORM f_create_dyn_graph USING 1.

  PERFORM f_dyn_table USING 'MAIN'.
  PERFORM f_dyn_table USING 'DETL'.
  PERFORM f_dyn_table USING 'LABEL'.
  PERFORM f_dyn_table USING 'GRAPH'.
ENDFORM.                    " F_CREATE_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_INT_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_int_table  USING    fu_container fu_fieldname fu_tabname
                               fu_currency fu_cfieldname fu_quantity
                               fu_qfieldname fu_checkbox fu_ref_field
                               fu_ref_table fu_coltext fu_outputlen
                               fu_inttype fu_no_out fu_edit fu_tech
                               fu_just fu_key fu_fix fu_icon fu_sum
                               fu_nosum fu_colpos.
  DATA : ls_dyn_fcat       TYPE lvc_s_fcat.

  PERFORM f_isi_judul USING fu_coltext '' '' ''
                      CHANGING ls_dyn_fcat-reptext ls_dyn_fcat-scrtext_l
                               ls_dyn_fcat-scrtext_m ls_dyn_fcat-scrtext_s.

  ls_dyn_fcat-fieldname   = fu_fieldname.
  ls_dyn_fcat-tabname     = fu_tabname.
  ls_dyn_fcat-currency    = fu_currency.
  ls_dyn_fcat-cfieldname  = fu_cfieldname.
  ls_dyn_fcat-quantity    = fu_quantity.
  ls_dyn_fcat-qfieldname  = fu_qfieldname.
  ls_dyn_fcat-checkbox    = fu_checkbox.
  ls_dyn_fcat-ref_field   = fu_ref_field.
  ls_dyn_fcat-ref_table   = fu_ref_table.
  ls_dyn_fcat-coltext     = fu_coltext.
  ls_dyn_fcat-edit        = fu_edit.
  ls_dyn_fcat-outputlen   = fu_outputlen.
  ls_dyn_fcat-inttype     = fu_inttype.
  ls_dyn_fcat-no_out      = fu_no_out.
  ls_dyn_fcat-tech        = fu_tech.
  ls_dyn_fcat-just        = fu_just.
  ls_dyn_fcat-key         = fu_key.
  ls_dyn_fcat-fix_column  = fu_fix.
  ls_dyn_fcat-icon        = fu_icon.
  ls_dyn_fcat-do_sum      = fu_sum.
  ls_dyn_fcat-no_sum      = fu_nosum.
  ls_dyn_fcat-col_pos     = fu_colpos.

  CASE fu_container.
    WHEN 'MAIN'.
      APPEND ls_dyn_fcat TO gt_main_fieldcat.
    WHEN 'DETL'.
      APPEND ls_dyn_fcat TO gt_detl_fieldcat.
    WHEN 'LABEL'.
      APPEND ls_dyn_fcat TO gt_label_fieldcat.
    WHEN 'GRAPH'.
      APPEND ls_dyn_fcat TO gt_graph_fieldcat.
  ENDCASE.
  CLEAR ls_dyn_fcat.
ENDFORM.                    " F_DYN_INT_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_ISI_JUDUL
*&---------------------------------------------------------------------*
FORM f_isi_judul  USING    fu_coltext fu_l fu_m fu_s
                  CHANGING fc_reptext fc_scrtext_l fc_scrtext_m fc_scrtext_s.

  fc_reptext    = fu_coltext.
  fc_scrtext_l  = fu_coltext.
  fc_scrtext_m  = fu_coltext.
  fc_scrtext_s  = fu_coltext.
ENDFORM.                    " F_ISI_JUDUL

*&---------------------------------------------------------------------*
*&      Form  F_ALV_SORT
*&---------------------------------------------------------------------*
FORM f_alv_sort  TABLES   ft_sort   STRUCTURE lvc_s_sort
                 USING    fu_spos fu_fieldname fu_up fu_down fu_subtot.

  ft_sort-spos      = fu_spos.
  ft_sort-fieldname = fu_fieldname.
  ft_sort-up        = fu_up.
  ft_sort-down      = fu_down.
  ft_sort-subtot    = fu_subtot.
  APPEND ft_sort.
  CLEAR ft_sort.
ENDFORM.                    " F_ALV_SORT

*&---------------------------------------------------------------------*
*&      Form  F_SELECT
*&---------------------------------------------------------------------*
FORM f_select  USING    fu_check.
  DATA : ls_fieldcatalog    TYPE lvc_t_fcat WITH HEADER LINE.
  DATA : lv_style    TYPE lvc_s_styl-style,
         lt_stylerow TYPE lvc_t_styl,
         ls_stylerow TYPE lvc_s_styl,
         lv_tabix    TYPE sy-tabix,
         ls_filter   LIKE LINE OF gt_filter.

  DATA : ls_out             LIKE LINE OF gt_out.

  CALL METHOD g_tabgrid01->get_frontend_fieldcatalog
    IMPORTING
      et_fieldcatalog = ls_fieldcatalog[].

  READ TABLE ls_fieldcatalog WITH KEY fieldname = 'MARK'.
  IF sy-subrc = 0.
    IF ls_fieldcatalog-edit IS NOT INITIAL.
      LOOP AT gt_out INTO ls_out.
        READ TABLE ls_out-style INTO ls_stylerow
                                WITH KEY fieldname = 'MARK'.
        IF sy-subrc = 0 AND
            ls_stylerow-style = cl_gui_alv_grid=>mc_style_disabled.
          CONTINUE.
        ENDIF.

        IF fu_check IS NOT INITIAL.
*          CLEAR : ls_sort, lv_tabix.
*          READ TABLE gt_sort INTO ls_sort
*                             WITH KEY banfn = ls_out-banfn
*                                      bnfpo = ls_out-bnfpo.
          IF sy-subrc = 0.
            lv_tabix = sy-tabix.
            CLEAR ls_filter.
            READ TABLE gt_filter INTO ls_filter
                                 WITH KEY index = lv_tabix.
            IF sy-subrc = 0.
              CONTINUE.
            ENDIF.
          ENDIF.
        ENDIF.

        ls_out-mark = fu_check.
        MODIFY gt_out FROM ls_out.
        CLEAR ls_out.
      ENDLOOP.
    ENDIF.
    PERFORM f_alv_refresh USING 'X' ''.
  ENDIF.
ENDFORM.                    " F_SELECT

*&---------------------------------------------------------------------*
*&      Form  F_ALV_REFRESH
*&---------------------------------------------------------------------*
FORM f_alv_refresh  USING    fu_refresh fu_container.
  IF fu_refresh IS NOT INITIAL.
    gs_stable-row = 'X'.
    gs_stable-col = 'X'.
    CASE fu_container.
      WHEN 'MAIN'.
        IF g_tabgrid01 IS NOT INITIAL.
          CALL METHOD g_tabgrid01->refresh_table_display
            EXPORTING
              is_stable = gs_stable.
        ENDIF.
      WHEN 'DETL'.
        IF g_tabgrid02 IS NOT INITIAL.
          CALL METHOD g_tabgrid02->refresh_table_display
            EXPORTING
              is_stable = gs_stable.
        ENDIF.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_ALV_REFRESH

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_out   TYPE STANDARD TABLE OF ty_out.

  lt_out[] = gt_out[].
  DELETE lt_out WHERE mark IS INITIAL.
  IF lt_out[] IS NOT INITIAL.

  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_DYN_TABLE
*&---------------------------------------------------------------------*
FORM f_dyn_table  USING    fu_tabname.
  DATA : lt_dyn_table TYPE REF TO data,
         ls_line      TYPE REF TO data.

  CASE fu_tabname.
    WHEN 'MAIN'.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_main_fieldcat
          i_length_in_byte          = 'X'
          i_style_table             = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc = 0.
        ASSIGN lt_dyn_table->* TO <fs_main>.
        CREATE DATA ls_line LIKE LINE OF <fs_main>.
        ASSIGN ls_line->* TO <fs_lmain>.
      ENDIF.

    WHEN 'DETL'.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_detl_fieldcat
          i_length_in_byte          = 'X'
          i_style_table             = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc = 0.
        ASSIGN lt_dyn_table->* TO <fs_detl>.
        CREATE DATA ls_line LIKE LINE OF <fs_detl>.
        ASSIGN ls_line->* TO <fs_ldetl>.
      ENDIF.

    WHEN 'LABEL'.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_label_fieldcat
          i_length_in_byte          = 'X'
          i_style_table             = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc = 0.
        ASSIGN lt_dyn_table->* TO <fs_label>.
        CREATE DATA ls_line LIKE LINE OF <fs_label>.
        ASSIGN ls_line->* TO <fs_slabel>.
      ENDIF.

    WHEN 'GRAPH'.
      CALL METHOD cl_alv_table_create=>create_dynamic_table
        EXPORTING
          it_fieldcatalog           = gt_graph_fieldcat
          i_length_in_byte          = 'X'
          i_style_table             = 'X'
        IMPORTING
          ep_table                  = lt_dyn_table
        EXCEPTIONS
          generate_subpool_dir_full = 1
          OTHERS                    = 2.
      IF sy-subrc = 0.
        ASSIGN lt_dyn_table->* TO <fs_graph>.
        CREATE DATA ls_line LIKE LINE OF <fs_graph>.
        ASSIGN ls_line->* TO <fs_sgraph>.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_DYN_TABLE

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_ITEM_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_item_double_click  USING    fu_fieldname fu_node_key.

ENDFORM.                    " F_HANDLE_ITEM_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_NODE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_node_double_click  USING    fu_node_key.

ENDFORM.                    " F_HANDLE_NODE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  DATA : ls_lfa1    LIKE LINE OF gt_lfa1,
         ls_vendor  LIKE LINE OF gt_vendor,
         ls_xvendor LIKE LINE OF gt_xvendor,
         ls_xsplitq LIKE LINE OF gt_xsplitq.

  DATA : lv_fieldname(30).

  FIELD-SYMBOLS : <fs>    TYPE any.

  CASE sy-dynnr.
    WHEN '0102'.
      PERFORM f_modify_screen USING :
        '' '' 'GS_PR-LGORT' '0' '' '' ''.

      IF gt_vendor[] IS INITIAL.
        LOOP AT <fs_main> ASSIGNING <fs_lmain>.
          ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
          ls_vendor-lifnr = <fs>.
          ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_lmain> TO <fs>.
          ls_vendor-name1 = <fs>.
          ls_vendor-meins = gs_pr-meins.
          ASSIGN COMPONENT 'KBETR' OF STRUCTURE <fs_lmain> TO <fs>.
          ls_vendor-kbetr = <fs>.
          IF ls_vendor-kbetr <> 0.
            ls_vendor-alloc = gs_pr-menge * ( ls_vendor-kbetr / 100 ).
          ENDIF.
          CLEAR ls_xvendor.
          READ TABLE gt_xvendor INTO ls_xvendor
                                WITH KEY banfn = gs_pr-banfn
                                         bnfpo = gs_pr-bnfpo
                                         lifnr = ls_vendor-lifnr.
          IF sy-subrc = 0.
            ls_vendor-revis   = ls_xvendor-revis.

            READ TABLE gt_xsplitq INTO ls_xsplitq
                                  WITH KEY banfn = gs_pr-banfn
                                           bnfpo = gs_pr-bnfpo
                                           lifnr = ls_xvendor-lifnr.
            IF sy-subrc = 0.
              ls_vendor-split   = 'X'.
            ENDIF.
          ENDIF.
          ls_vendor-kbetr1 = ( ls_vendor-revis / gs_pr-menge ) * 100.

          APPEND ls_vendor TO gt_vendor.
          CLEAR ls_vendor.
        ENDLOOP.
      ENDIF.

      DESCRIBE TABLE gt_vendor LINES fill.
      tc_vendor-lines = fill.

    WHEN '0103'.
      IF pa_submi IS NOT INITIAL.
        IF gs_quot-ebeln IS NOT INITIAL.
          PERFORM f_modify_screen USING :
            '002' '' '' '' '0' '' ''.
        ENDIF.
      ENDIF.

      IF gs_quot-netpr IS NOT INITIAL.
        PERFORM f_modify_screen USING :
          '003' '' '' '' '0' '' ''.
      ENDIF.

      IF gs_quot-menge IS NOT INITIAL.
        PERFORM f_modify_screen USING :
          '004' '' '' '' '0' '' ''.
      ENDIF.

      IF text_editor IS INITIAL .
        PERFORM f_create_text_editor.
      ENDIF.

      PERFORM f_diplay_text.

      PERFORM f_display_actual_alokasi.

      IF gs_quot-ebeln IS INITIAL.
        PERFORM f_set_cursor USING 'GS_QUOT-EBELN' ''.
      ELSEIF gs_quot-waers IS INITIAL.
        PERFORM f_set_cursor USING 'GS_QUOT-WAERS' ''.
      ELSEIF gs_quot-netpr IS INITIAL.
        PERFORM f_set_cursor USING 'GS_QUOT-NETPR' ''.
      ENDIF.

    WHEN '0105'.
      IF gt_splitq[] IS INITIAL.
        APPEND INITIAL LINE TO gt_splitq.
      ELSE.
        PERFORM f_prepare_chart_data.
      ENDIF.

      CLEAR : gs_pr-bsmng, gv_cursor.

      DESCRIBE TABLE gt_splitq LINES fill.
      tc_splitq-lines = fill.

    WHEN '0106'.
      DESCRIBE TABLE gt_dpir LINES fill.
      tc_pir-lines = fill.
  ENDCASE.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_fill_table_control .
  CASE sy-dynnr.
    WHEN '0102'.
      READ TABLE gt_vendor INTO gs_vendor INDEX tc_vendor-current_line.
      IF gs_vendor-split IS NOT INITIAL.
        PERFORM f_modify_screen USING :
          '' '' 'GS_VENDOR-REVIS' '' '0' '' ''.
      ENDIF.
      CASE gv_trtyp.
        WHEN 'A'.
          PERFORM f_modify_screen USING :
            '' '' 'GS_VENDOR-REVIS' '' '0' '' ''.
      ENDCASE.

    WHEN '0105'.
      READ TABLE gt_splitq INTO gs_splitq INDEX tc_splitq-current_line.
      ADD gs_splitq-revis TO gs_pr-bsmng.
      IF gs_splitq-revis IS INITIAL.
        IF gv_cursor IS INITIAL.
          gv_cursor = 'X'.
          PERFORM f_set_cursor USING 'GS_SPLITQ-REVIS' tc_splitq-current_line.
        ENDIF.
      ELSE.
        PERFORM f_set_cursor USING 'GS_SPLITQ-ZEILE' tc_splitq-current_line.
      ENDIF.

      CASE gv_trtyp.
        WHEN 'H'.
        WHEN 'A'.
          PERFORM f_modify_screen USING :
            '' '' 'GS_SPLITQ-REVIS' '' '0' '' '',
            '' '' 'GS_SPLITQ-ZEILE' '' '0' '' ''.
        WHEN OTHERS.
      ENDCASE.

    WHEN '0106'.
      READ TABLE gt_dpir INTO gs_dpir INDEX tc_pir-current_line.

  ENDCASE.
ENDFORM.                    " F_FILL_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Form  F_READ_TABLE_CONTROL
*&---------------------------------------------------------------------*
FORM f_read_table_control .
  CASE sy-dynnr.
    WHEN '0102'.
      MODIFY gt_vendor FROM gs_vendor
                       INDEX tc_vendor-current_line
                       TRANSPORTING mark revis.
    WHEN '0105'.
      MODIFY gt_splitq FROM gs_splitq
                       INDEX tc_splitq-current_line
                       TRANSPORTING zeile revis.
      IF sy-subrc <> 0.
        APPEND gs_splitq TO gt_splitq.
      ENDIF.
    WHEN '0106'.
      MODIFY gt_dpir FROM gs_dpir
                     INDEX tc_pir-current_line
                       TRANSPORTING check.
    WHEN OTHERS.
  ENDCASE.
ENDFORM.                    " F_READ_TABLE_CONTROL

*&---------------------------------------------------------------------*
*&      Form  F_VALIDATE_QUANTITY
*&---------------------------------------------------------------------*
FORM f_validate_quantity .

ENDFORM.                    " F_VALIDATE_QUANTITY

*&---------------------------------------------------------------------*
*&      Form  F_HANDLE_DOUBLE_CLICK
*&---------------------------------------------------------------------*
FORM f_handle_double_click  USING    fu_container fu_row fu_column.
  DATA : ls_ekpo LIKE LINE OF gt_ekpo,
         ls_eket LIKE LINE OF gt_eket,
         ls_eban LIKE LINE OF gt_eban,
         ls_lfa1 LIKE LINE OF gt_lfa1.

  DATA : lv_werks         TYPE ekpo-werks,
         lv_matnr         TYPE ekpo-matnr,
         lv_ebeln         TYPE ekpo-ebeln,
         lv_meins         TYPE ekpo-meins,
         lv_fieldname(30),
         lv_icon(4),
         lv_banfn         TYPE eban-banfn,
         lv_bnfpo         TYPE eban-bnfpo.

  FIELD-SYMBOLS : <fs>  TYPE any.

  CASE fu_container.
    WHEN 'MAIN'.
      CASE fu_column.
        WHEN 'LIFNR'.
          READ TABLE <fs_main> ASSIGNING <fs_lmain> INDEX fu_row.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
            gs_quot-lifnr = <fs>.
            ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_lmain> TO <fs>.
            gs_quot-name1l = <fs>.
            ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lmain> TO <fs>.
            gs_quot-ebeln = <fs>.
            ASSIGN COMPONENT 'NETPR' OF STRUCTURE <fs_lmain> TO <fs>.
            gs_quot-netpr = <fs>.
            ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_lmain> TO <fs>.
            gs_quot-waers = <fs>.
            ASSIGN COMPONENT 'MFRPN' OF STRUCTURE <fs_lmain> TO <fs>.
            gs_quot-mfrpn = <fs>.
            ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_lmain> TO <fs>.
            gs_quot-menge = <fs>.
            ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_lmain> TO <fs>.
            gs_quot-meins = <fs>.

            gs_quot-tabix = sy-tabix.
            CALL SCREEN 103 STARTING AT 10 10.

            PERFORM f_alv_refresh USING 'X' 'MAIN'.
          ENDIF.

        WHEN 'EBELN'.
          READ TABLE <fs_main> ASSIGNING <fs_lmain> INDEX fu_row.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lmain> TO <fs>.
            lv_ebeln = <fs>.
            ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_lmain> TO <fs>.
            lv_meins = <fs>.
            PERFORM f_display_popup USING lv_ebeln lv_meins.
          ENDIF.
      ENDCASE.

    WHEN 'DETL'.
      CASE fu_column.
        WHEN 'MENGE'.
*          CLEAR : gt_vendor
          READ TABLE <fs_detl> ASSIGNING <fs_ldetl> INDEX fu_row.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_ldetl> TO <fs>.
            gs_pr-banfn = <fs>.
            ASSIGN COMPONENT 'BNFPO' OF STRUCTURE <fs_ldetl> TO <fs>.
            gs_pr-bnfpo = <fs>.
            ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_ldetl> TO <fs>.
            gs_pr-menge = <fs>.
            ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_ldetl> TO <fs>.
            gs_pr-meins = <fs>.
            ASSIGN COMPONENT 'LGORT' OF STRUCTURE <fs_ldetl> TO <fs>.
            gs_pr-lgort = <fs>.
            gs_pr-tabix = sy-tabix.
            CALL SCREEN 102 STARTING AT 10 10.

            PERFORM f_alv_refresh USING 'X' 'MAIN'.
            PERFORM f_alv_refresh USING 'X' 'DETL'.
          ENDIF.

        WHEN 'ICON'.
          READ TABLE <fs_detl> ASSIGNING <fs_ldetl> INDEX fu_row.
          IF sy-subrc = 0.
            ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ldetl> TO <fs>.
            lv_icon = <fs>.
            IF lv_icon IN gr_icon.
              ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_ldetl> TO <fs>.
              lv_banfn = <fs>.
              ASSIGN COMPONENT 'BNFPO' OF STRUCTURE <fs_ldetl> TO <fs>.
              lv_bnfpo = <fs>.
              PERFORM f_display_message USING lv_banfn lv_bnfpo.
            ENDIF.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_HANDLE_DOUBLE_CLICK

*&---------------------------------------------------------------------*
*&      Form  F_DETAIL_ALV
*&---------------------------------------------------------------------*
FORM f_detail_alv .
  CREATE OBJECT g_tabgrid02
    EXPORTING
      i_appl_events = selected
      i_parent      = g_contain02.

  PERFORM f_build_layout USING 'DETL'.
  PERFORM f_build_sort USING 'DETL'.

  SET HANDLER event_receiver->handle_double_click1
              event_receiver->handle_toolbar1
              event_receiver->handle_menu_button1
              event_receiver->handle_user_command1 FOR g_tabgrid02.

  CALL METHOD g_tabgrid02->set_table_for_first_display
    EXPORTING
      is_layout            = gs_detl_layout
      i_save               = 'A'
      is_variant           = gs_variant
      i_default            = 'X'
      it_toolbar_excluding = gs_exclude2
    CHANGING
      it_sort              = gt_detl_sort[]
      it_outtab            = <fs_detl>[]
      it_fieldcatalog      = gt_detl_fieldcat[].
ENDFORM.                    " F_DETAIL_ALV

*&---------------------------------------------------------------------*
*&      Form  F_GET_QUARTER
*&---------------------------------------------------------------------*
FORM f_get_quarter  USING    fu_monat fu_date.
  DATA : lv_datum   TYPE sy-datum,
         ex_quarter TYPE p99sg_quarter,
         ls_datum   LIKE LINE OF gr_q1.

  IF fu_monat IS INITIAL.
    IF fu_date IS INITIAL.
      lv_datum  = sy-datum.
    ELSE.
      lv_datum = fu_date.
    ENDIF.
  ELSE.
    CONCATENATE pa_mjahr fu_monat '01' INTO lv_datum.
  ENDIF.

  CALL FUNCTION 'HR_99S_GET_QUARTER'
    EXPORTING
      im_date    = lv_datum
    IMPORTING
      ex_quarter = ex_quarter.

  ls_datum-low     = ex_quarter-begda.
  ls_datum-high    = ex_quarter-endda.
  ls_datum-sign    = 'I'.
  ls_datum-option  = 'BT'.

  CASE fu_monat.
    WHEN '01'.
      APPEND ls_datum TO gr_q1.
      gv_d1 = ex_quarter-begda.
    WHEN '04'.
      APPEND ls_datum TO gr_q2.
      gv_d2 = ex_quarter-begda.
    WHEN '07'.
      APPEND ls_datum TO gr_q3.
      gv_d3 = ex_quarter-begda.
    WHEN '10'.
      APPEND ls_datum TO gr_q4.
      gv_d4 = ex_quarter-begda.
    WHEN OTHERS.
      gv_quarter  = ex_quarter-q.
  ENDCASE.
ENDFORM.                    " F_GET_QUARTER

*&---------------------------------------------------------------------*
*&      Form  F_ZM73N
*&---------------------------------------------------------------------*
FORM f_zm73n  TABLES   ft_zm73   LIKE gt_zm73_1
              USING    fu_datum fu_quarter.

  DATA : lr_werks TYPE RANGE OF ekpo-werks,
         lr_ekgrp TYPE RANGE OF ekko-ekgrp,
         lr_matnr TYPE RANGE OF ekpo-matnr,
         lr_loekz TYPE RANGE OF ekpo-loekz,
         lr_lifnr TYPE RANGE OF lfa1-lifnr.

  DATA : ls_werks    LIKE LINE OF lr_werks,
         ls_ekgrp    LIKE LINE OF lr_ekgrp,
         ls_matnr    LIKE LINE OF lr_matnr,
         ls_loekz    LIKE LINE OF lr_loekz,
         ls_lifnr    LIKE LINE OF lr_lifnr,
         ls_lfa1     LIKE LINE OF gt_lfa1,
         ls_material LIKE LINE OF gt_material.

  DATA : lt_zm73  TYPE STANDARD TABLE OF ty_zm73,
         ls_zm73  LIKE LINE OF lt_zm73,
         lt_xm73  TYPE STANDARD TABLE OF ty_zm73,
         ls_xm73  LIKE LINE OF lt_zm73,
         lt_ym73  TYPE STANDARD TABLE OF ty_zm73,
         ls_ym73  LIKE LINE OF lt_zm73,
         lr_zm73n TYPE REF TO data,
         ls_zm73n TYPE REF TO data,
         ls_pgmit LIKE LINE OF gt_pgmit.

  DATA : lv_datum TYPE sy-datum,
         lv_bobot TYPE zbobottop,
         lv_lines TYPE numc2,
         lv_diff  TYPE i.

  FIELD-SYMBOLS : <fs_zm73n>  TYPE ANY TABLE,
                  <fs_lzm73n> TYPE any,
                  <fs>        TYPE any.

  ls_werks-sign   = 'I'.
  ls_werks-option = 'EQ'.
  ls_werks-low    = so_werks-low.
  APPEND ls_werks TO lr_werks.

  ls_ekgrp-sign   = 'I'.
  ls_ekgrp-option = 'EQ'.
  ls_ekgrp-low    = pa_ekgrp.
  APPEND ls_ekgrp TO lr_ekgrp.

  CASE 'X'.
    WHEN radio1.
      ls_matnr-sign   = 'I'.
      ls_matnr-option = 'EQ'.
      ls_matnr-low    = so_matnr-low.
      APPEND ls_matnr TO lr_matnr.
    WHEN radio2.
      LOOP AT gt_pgmit INTO ls_pgmit.
        ls_matnr-sign   = 'I'.
        ls_matnr-option = 'EQ'.
        ls_matnr-low    = ls_pgmit-matnr.
        APPEND ls_matnr TO lr_matnr.

        ls_material-matnr = ls_pgmit-matnr.
        APPEND ls_material TO gt_material.
        CLEAR ls_material.
      ENDLOOP.
  ENDCASE.

  IF pa_ean11 IS NOT INITIAL.
    ls_matnr-low    = pa_ean11.
    ls_matnr-sign   = 'I'.
    ls_matnr-option = 'EQ'.
    APPEND ls_matnr TO lr_matnr.
  ENDIF.

  SORT gt_material BY matnr.
  DELETE ADJACENT DUPLICATES FROM gt_material COMPARING matnr.

  ls_loekz-sign   = 'E'.
  ls_loekz-option = 'EQ'.
  ls_loekz-low    = 'L'.
  APPEND ls_loekz TO lr_loekz.

  LOOP AT gt_lfa1 INTO ls_lfa1.
    ls_lifnr-sign   = 'I'.
    ls_lifnr-option = 'EQ'.
    ls_lifnr-low    = ls_lfa1-lifnr.
    APPEND ls_lifnr TO lr_lifnr.
  ENDLOOP.

  lv_datum  = fu_datum - 1.

  cl_salv_bs_runtime_info=>set(
    EXPORTING display  = abap_false
              metadata = abap_false
              data     = abap_true ).

  SUBMIT zm_vendor_evaluation_newv3
    WITH so_werks  IN lr_werks
    WITH so_ekgrp  IN lr_ekgrp
    WITH so_matnr  IN lr_matnr
    WITH p_assdt   EQ lv_datum
    WITH so_loekz  IN lr_loekz
    WITH so_lifnr  IN lr_lifnr
    WITH p_nodisp  EQ 'X'
    WITH p_get6    EQ 'X'
    WITH p_old     EQ pa_ean11
    WITH p_quart   EQ fu_quarter
    WITH pa_mjahr  EQ pa_mjahr
    AND RETURN.

  TRY.
      cl_salv_bs_runtime_info=>get_data_ref(
        IMPORTING r_data = lr_zm73n ).
      ASSIGN lr_zm73n->* TO <fs_zm73n>.

      IF <fs_zm73n> IS ASSIGNED.
        CREATE DATA ls_zm73n LIKE LINE OF <fs_zm73n>.
        ASSIGN ls_zm73n->* TO <fs_lzm73n>.
      ENDIF.

    CATCH cx_salv_bs_sc_runtime_info.
      MESSAGE `Unable to retrieve ALV data` TYPE 'E'.
  ENDTRY.

  IF <fs_zm73n> IS ASSIGNED.
    LOOP AT <fs_zm73n> ASSIGNING <fs_lzm73n>.
      ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lzm73n> TO <fs>.
      ls_zm73-lifnr = <fs>.
      ASSIGN COMPONENT 'HARGA' OF STRUCTURE <fs_lzm73n> TO <fs>.
      ls_zm73-harga = <fs>.
      ASSIGN COMPONENT 'BOBOTTOTAL' OF STRUCTURE <fs_lzm73n> TO <fs>.
      ls_zm73-bobot = <fs>.
      IF ls_zm73-harga = 0.
        CONTINUE.
      ENDIF.
      APPEND ls_zm73 TO lt_zm73.
    ENDLOOP.
  ENDIF.


*  CASE 'X'.
*    WHEN radio1.
*    WHEN radio2.
  PERFORM f_calculate_average TABLES lt_zm73.
*  ENDCASE.

  cl_salv_bs_runtime_info=>clear_all( ).

  PERFORM f_calculate_top4_bobot TABLES lt_zm73
                                 CHANGING lv_bobot lv_lines.
  PERFORM f_calculate_score_diff TABLES lt_zm73
                                 USING  lv_bobot lv_lines
                                 CHANGING lv_diff.

  IF lv_diff IS NOT INITIAL.
    PERFORM f_calculate_under3% TABLES lt_zm73
                                USING  lv_diff.
  ENDIF.

  ft_zm73[] = lt_zm73[].
ENDFORM.                    " F_ZM73N

*&---------------------------------------------------------------------*
*&      Form  F_GET_FROM_ZM73N
*&---------------------------------------------------------------------*
FORM f_get_from_zm73n .
  CASE gv_quarter.
    WHEN 1.
      PERFORM f_zm73n TABLES gt_zm73_1
                      USING gv_d1 1.
      PERFORM f_sort_vendor TABLES gt_zm73_1.
    WHEN 2.
      PERFORM f_zm73n TABLES gt_zm73_1
                      USING gv_d1 1.
      PERFORM f_zm73n TABLES gt_zm73_2
                      USING gv_d2 2.
      PERFORM f_sort_vendor TABLES gt_zm73_2.
    WHEN 3.
      PERFORM f_zm73n TABLES gt_zm73_1
                      USING gv_d1 1.
      PERFORM f_zm73n TABLES gt_zm73_2
                      USING gv_d2 2.
      PERFORM f_zm73n TABLES gt_zm73_3
                      USING gv_d3 3.
      PERFORM f_sort_vendor TABLES gt_zm73_3.
    WHEN 4.
      PERFORM f_zm73n TABLES gt_zm73_1
                      USING gv_d1 1.
      PERFORM f_zm73n TABLES gt_zm73_2
                      USING gv_d2 2.
      PERFORM f_zm73n TABLES gt_zm73_3
                      USING gv_d3 3.
      PERFORM f_zm73n TABLES gt_zm73_4
                      USING gv_d4 4.
      PERFORM f_sort_vendor TABLES gt_zm73_4.
  ENDCASE.
ENDFORM.                    " F_GET_FROM_ZM73N

*&---------------------------------------------------------------------*
*&      Form  F_GET_OUTSTANDING_PR
*&---------------------------------------------------------------------*
FORM f_get_outstanding_pr .
  SELECT *
    FROM eban
    INTO CORRESPONDING FIELDS OF TABLE gt_eban
    WHERE ekgrp = pa_ekgrp
      AND matnr = so_matnr-low
      AND werks = so_werks-low
      AND loekz = space
*      AND statu IN gr_statu
      AND ebakz = space
      AND frgkz IN gr_frgkz
      AND badat IN gr_badat
      AND lfdat IN so_lfdat
    ORDER BY PRIMARY KEY.
ENDFORM.                    " F_GET_OUTSTANDING_PR

*&---------------------------------------------------------------------*
*&      Form  F_TEMP_DATA
*&---------------------------------------------------------------------*
FORM f_temp_data  USING    fu_type fu_banfn fu_bnfpo fu_lifnr fu_meins
                           fu_lgort fu_zeile fu_revis.
  DATA : ls_xvendor LIKE LINE OF gt_xvendor,
         ls_xsplitq LIKE LINE OF gt_xsplitq.

  CASE fu_type.
    WHEN 'VENDOR'.
      ls_xvendor-banfn    = fu_banfn.
      ls_xvendor-bnfpo    = fu_bnfpo.
      ls_xvendor-lifnr    = fu_lifnr.
      ls_xvendor-revis    = fu_revis.
      MODIFY TABLE gt_xvendor FROM ls_xvendor.
      IF sy-subrc <> 0.
        APPEND ls_xvendor TO gt_xvendor.
      ENDIF.
      CLEAR ls_xvendor.

    WHEN 'SPLIT'.
      ls_xsplitq-banfn    = fu_banfn.
      ls_xsplitq-bnfpo    = fu_bnfpo.
      ls_xsplitq-lifnr    = fu_lifnr.
      ls_xsplitq-zeile    = fu_zeile.
      ls_xsplitq-lgort    = fu_lgort.
      ls_xsplitq-meins    = fu_meins.
      ls_xsplitq-revis    = fu_revis.
      ls_xsplitq-split    = 'X'.
      MODIFY TABLE gt_xsplitq FROM ls_xsplitq.
      IF sy-subrc <> 0.
        APPEND ls_xsplitq TO gt_xsplitq.
      ENDIF.
*      APPEND ls_xsplitq TO gt_ysplitq.
      CLEAR ls_xsplitq.
  ENDCASE.
ENDFORM.                    " F_TEMP_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SUM_REVISI
*&---------------------------------------------------------------------*
FORM f_sum_revisi .
  DATA : lt_xvendor TYPE STANDARD TABLE OF ty_vendor,
         ls_xvendor LIKE LINE OF lt_xvendor.

  DATA : lv_fieldname(30),
         lv_revis         TYPE ekpo-menge,
         lv_lifnr         TYPE ekko-lifnr,
         lv_kbetr1        TYPE konp-kbetr,
         lv_alloc         TYPE ekpo-menge,
         lv_menge         TYPE ekpo-menge.

  FIELD-SYMBOLS : <fs>    TYPE any.

  LOOP AT <fs_detl> ASSIGNING <fs_ldetl>.
    ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_ldetl> TO <fs>.
    ADD <fs> TO lv_menge.
  ENDLOOP.

  LOOP AT <fs_main> ASSIGNING <fs_lmain>.
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
    lv_lifnr = <fs>.
    ASSIGN COMPONENT 'ALLOC' OF STRUCTURE <fs_lmain> TO <fs>.
    lv_alloc = <fs>.

    LOOP AT gt_xvendor INTO ls_xvendor WHERE lifnr = lv_lifnr.
      ADD ls_xvendor-revis TO lv_revis.
    ENDLOOP.
    lv_kbetr1 = ( lv_revis / lv_menge ) * 100.
    ASSIGN COMPONENT 'KBETR1' OF STRUCTURE <fs_lmain> TO <fs>.
    <fs> = lv_kbetr1.
    ASSIGN COMPONENT 'REVIS' OF STRUCTURE <fs_lmain> TO <fs>.
    <fs> = lv_revis.
    CLEAR : lv_revis, lv_lifnr, lv_alloc.
  ENDLOOP.
ENDFORM.                    " F_SUM_REVISI

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_TOP4_BOBOT
*&---------------------------------------------------------------------*
FORM f_calculate_top4_bobot  TABLES   ft_zm73 LIKE gt_zm73_1
                             CHANGING fc_bobot fc_lines.
  DATA : ls_zm73  TYPE ty_zm73,
         lv_count TYPE i.

  SORT ft_zm73 BY bobot DESCENDING lifnr.
  LOOP AT ft_zm73 INTO ls_zm73.
    ADD 1 TO lv_count.
    IF lv_count > 4.
      lv_count = 4.
      EXIT.
    ENDIF.
    ADD ls_zm73-bobot TO fc_bobot.
  ENDLOOP.
  fc_lines  = lv_count.
ENDFORM.                    " F_CALCULATE_TOP4_BOBOT

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_SCORE_DIFF
*&---------------------------------------------------------------------*
FORM f_calculate_score_diff  TABLES   ft_zm73 LIKE gt_zm73_1
                             USING    fu_bobot fu_lines
                             CHANGING fc_diff.

  DATA : ls_zm73    TYPE ty_zm73,
         lv_count   TYPE i,
         lv_bobot   TYPE zbobottop,
         ls_alloc   LIKE LINE OF gt_alloc,
         lv_aloctot TYPE zbobottop.

  LOOP AT ft_zm73 INTO ls_zm73.
    ADD 1 TO lv_count.
    IF lv_count = 1.
      IF ls_zm73-bobot <> 0.
        IF fu_lines = '01'.
          ls_zm73-%aloc = 100.
        ENDIF.
      ENDIF.
      lv_bobot  = ls_zm73-bobot.
    ELSEIF lv_count <= 4.
      ls_zm73-sdiff = lv_bobot - ls_zm73-bobot.
      LOOP AT gt_alloc INTO ls_alloc WHERE totsup = fu_lines.
        IF ls_zm73-sdiff <= ls_alloc-scordiff.
          CASE lv_count.
            WHEN 2.
              ls_zm73-%aloc = ls_alloc-rank2.
              ADD ls_zm73-%aloc TO lv_aloctot.
              IF ls_zm73-sdiff < 3.
                fc_diff = 2.
              ENDIF.
              EXIT.
            WHEN 3.
              ls_zm73-%aloc = ls_alloc-rank3.
              ADD ls_zm73-%aloc TO lv_aloctot.
              IF ls_zm73-sdiff < 3.
                fc_diff = 3.
              ENDIF.
              EXIT.
            WHEN 4.
              ls_zm73-%aloc = ls_alloc-rank4.
              ADD ls_zm73-%aloc TO lv_aloctot.
              IF ls_zm73-sdiff < 3.
                fc_diff = 4.
              ENDIF.
              EXIT.
          ENDCASE.
        ENDIF.
      ENDLOOP.
    ENDIF.

    MODIFY ft_zm73 FROM ls_zm73 TRANSPORTING sdiff %aloc.
  ENDLOOP.

  READ TABLE ft_zm73 INTO ls_zm73 INDEX 1.
  IF sy-subrc = 0.
    IF lv_aloctot <> 0.
      ls_zm73-%aloc = 100 - lv_aloctot.
      MODIFY TABLE ft_zm73 FROM ls_zm73 TRANSPORTING %aloc.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CALCULATE_SCORE_DIFF

*&---------------------------------------------------------------------*
*&      Form  F_GET_PERCEN_ALOKASI
*&---------------------------------------------------------------------*
FORM f_get_percen_alokasi  TABLES   ft_zm73 LIKE gt_zm73_1
                           USING    fu_lifnr
                           CHANGING fc_kbetr.
  DATA : ls_zm73    TYPE ty_zm73.

  CLEAR : ls_zm73, fc_kbetr.
  READ TABLE ft_zm73 INTO ls_zm73
                     WITH KEY lifnr = fu_lifnr.
  IF sy-subrc = 0.
    fc_kbetr  = ls_zm73-%aloc.
  ENDIF.
ENDFORM.                    " F_GET_PERCEN_ALOKASI

*&---------------------------------------------------------------------*
*&      Form  F_SORT_VENDOR
*&---------------------------------------------------------------------*
FORM f_sort_vendor  TABLES   ft_zm73 LIKE gt_zm73_1.
  DATA : ls_lfa1  LIKE LINE OF gt_lfa1,
         ls_zm73  TYPE ty_zm73,
         lt_xzm73 TYPE STANDARD TABLE OF ty_zm73,
         ls_xzm73 TYPE ty_zm73,
         ls_ekko  LIKE LINE OF gt_ekko,
         lt_xeban TYPE STANDARD TABLE OF eban,
         ls_xeban LIKE LINE OF lt_xeban,
         ls_ekpo  LIKE LINE OF gt_ekpo.

  IF gt_lfa1[] IS INITIAL.
    lt_xzm73[] = ft_zm73[].
    SORT lt_xzm73 BY lifnr.
    DELETE ADJACENT DUPLICATES FROM lt_xzm73 COMPARING lifnr.
    IF lt_xzm73[] IS NOT INITIAL.
      SELECT *
        FROM lfa1
        INTO CORRESPONDING FIELDS OF TABLE gt_lfa1
        FOR ALL ENTRIES IN lt_xzm73
        WHERE lifnr = lt_xzm73-lifnr.

      LOOP AT lt_xzm73 INTO ls_xzm73.
        ls_ekko-lifnr   = ls_xzm73-lifnr.
        APPEND ls_ekko TO gt_ekko.
        CLEAR ls_ekko.
      ENDLOOP.

      lt_xeban[] = gt_eban[].
      SORT lt_xeban BY werks matnr.
      DELETE ADJACENT DUPLICATES FROM lt_xeban COMPARING werks matnr.
      LOOP AT lt_xeban INTO ls_xeban.
        ls_ekpo-werks   = ls_xeban-werks.
        ls_ekpo-matnr   = ls_xeban-matnr.
        ls_ekpo-meins   = ls_xeban-meins.
        APPEND ls_ekpo TO gt_ekpo.
        CLEAR ls_ekpo.
      ENDLOOP.
    ENDIF.
  ENDIF.

*****  LOOP AT gt_lfa1 INTO ls_lfa1.
*****    CLEAR ls_zm73.
*****    READ TABLE ft_zm73 INTO ls_zm73
*****                       WITH KEY lifnr = ls_lfa1-lifnr.
*****    IF sy-subrc = 0.
*****      ls_lfa1-sortl   = sy-tabix.
*****    ELSE.
*****      ls_lfa1-sortl   = 999.
*****    ENDIF.
*****    MODIFY gt_lfa1 FROM ls_lfa1 TRANSPORTING sortl.
*****  ENDLOOP.
*****
*****  SORT gt_lfa1 BY sortl lifnr.
ENDFORM.                    " F_SORT_VENDOR

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_ALOKASI
*&---------------------------------------------------------------------*
FORM f_calculate_alokasi  USING    fu_kbetr fu_smeng
                          CHANGING fc_alloc.
  IF fu_kbetr IS NOT INITIAL.
    fc_alloc = fu_smeng * ( fu_kbetr / 100 ).
  ELSE.
    CLEAR fc_alloc.
  ENDIF.
ENDFORM.                    " F_CALCULATE_ALOKASI

*&---------------------------------------------------------------------*
*&      Form  F_STORE_MESSAGE
*&---------------------------------------------------------------------*
FORM f_store_message  USING    fu_icon fu_message.
  DATA : ls_mess    LIKE LINE OF gt_mess.

  IF fu_icon IS INITIAL.
    READ TABLE gt_mess INTO ls_mess
                       WITH KEY banfn = gs_pr-banfn
                                bnfpo = gs_pr-bnfpo.
    IF sy-subrc = 0.
      DELETE TABLE gt_mess FROM ls_mess.
    ENDIF.
  ELSE.
    CASE fu_icon.
      WHEN '1'.
        ls_mess-icon    = icon_led_red.
      WHEN '2'.
        ls_mess-icon    = icon_led_yellow.
    ENDCASE.

    ls_mess-banfn   = gs_pr-banfn.
    ls_mess-bnfpo   = gs_pr-bnfpo.
    ls_mess-message = fu_message.

    READ TABLE gt_mess INTO ls_mess
                       WITH KEY banfn = gs_pr-banfn
                                bnfpo = gs_pr-bnfpo
                       TRANSPORTING NO FIELDS.
    IF sy-subrc = 0.
      MODIFY gt_mess FROM ls_mess TRANSPORTING icon message
                     WHERE banfn = gs_pr-banfn
                       AND bnfpo = gs_pr-bnfpo.
    ELSE.
      APPEND ls_mess TO gt_mess.
    ENDIF.
    CLEAR ls_mess.
  ENDIF.
ENDFORM.                    " F_STORE_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
FORM f_display_message USING    fu_banfn fu_bnfpo.
  DATA : lt_list     TYPE STANDARD TABLE OF zhsmmmst002,
         ls_mess     LIKE LINE OF gt_mess,
         ls_selfield TYPE slis_selfield,
         lv_exit.

  IF fu_banfn IS INITIAL.
    LOOP AT gt_mess INTO ls_mess.
      APPEND ls_mess TO lt_list.
    ENDLOOP.
  ELSE.
    READ TABLE gt_mess INTO ls_mess
                       WITH KEY banfn = fu_banfn
                                bnfpo = fu_bnfpo.
    IF sy-subrc = 0.
      APPEND ls_mess TO lt_list.
    ENDIF.
  ENDIF.

  IF lt_list[] IS NOT INITIAL.
    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_title                 = 'List message'
        i_selection             = space
        i_allow_no_selection    = 'X'
        i_zebra                 = 'X'
        i_screen_start_column   = 2
        i_screen_start_line     = 2
        i_screen_end_column     = 150
        i_screen_end_line       = 15
        i_tabname               = 'GT_MESS'
        i_structure_name        = 'ZHSMMMST002'
        i_callback_program      = gv_repid
        i_callback_user_command = 'F_CALLBACK_USER_COMMAND'
      IMPORTING
        es_selfield             = ls_selfield
        e_exit                  = lv_exit
      TABLES
        t_outtab                = lt_list
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.
  ENDIF.
ENDFORM.                    " F_DISPLAY_MESSAGE

*&---------------------------------------------------------------------*
* &      Form  F_GET_LAST_PURCHASED
*&---------------------------------------------------------------------*
FORM f_get_last_purchased .
  DATA : lt_xeipa TYPE STANDARD TABLE OF eipa,
         ls_xeipa LIKE LINE OF lt_xeipa,
         lt_xekpo TYPE STANDARD TABLE OF ekpo,
         ls_t026z TYPE t026z,
         lt_eine  TYPE STANDARD TABLE OF eine,
         lt_eina  TYPE STANDARD TABLE OF eina,
         lt_a018  TYPE STANDARD TABLE OF a018,
         lt_konp  TYPE STANDARD TABLE OF konp,
         lt_eipa  TYPE STANDARD TABLE OF eipa,
         ls_eipa  LIKE LINE OF lt_eipa,
         lt_konv  TYPE STANDARD TABLE OF konv,
         ls_konv  LIKE LINE OF lt_konv,
         ls_eina  LIKE LINE OF lt_eina,
         ls_eine  LIKE LINE OF lt_eine,
         ls_mara  LIKE LINE OF gt_mara,
         ls_lfa1  LIKE LINE OF gt_lfa1,
         ls_a018  LIKE LINE OF lt_a018,
         ls_konp  LIKE LINE OF lt_konp,
         ls_xekpo LIKE LINE OF gt_xekpo,
         ls_xekko LIKE LINE OF gt_xekko.

  DATA : lv_knumv TYPE ekko-knumv,
         lv_index TYPE sy-index,
         lv_subrc TYPE sy-subrc,
         lv_matnr TYPE mara-matnr.

  DATA : ls_ekpo      LIKE LINE OF gt_ekpo.

  PERFORM f_material_mpn.

  SELECT SINGLE *
    FROM t026z
    INTO CORRESPONDING FIELDS OF ls_t026z
    WHERE ekgrp = pa_ekgrp.

  IF gt_mara[] IS NOT INITIAL.
    SELECT *
      FROM eina
      INTO CORRESPONDING FIELDS OF TABLE lt_eina
      FOR ALL ENTRIES IN gt_mara
      WHERE matnr = gt_mara-matnr
        AND loekz = space
      ORDER BY PRIMARY KEY.
  ENDIF.

  IF lt_eina[] IS NOT INITIAL.
    SELECT *
      FROM a018
      INTO CORRESPONDING FIELDS OF TABLE lt_a018
      FOR ALL ENTRIES IN lt_eina
      WHERE kappl = 'M'
        AND kschl = 'ZPB0'
        AND lifnr = lt_eina-lifnr
        AND matnr = lt_eina-matnr
        AND ekorg = 'TNT'
        AND esokz = '0'
        AND datbi >= sy-datum
        AND datab <= sy-datum
      ORDER BY PRIMARY KEY.

    IF lt_a018[] IS NOT INITIAL.
      SELECT *
        FROM konp
        INTO CORRESPONDING FIELDS OF TABLE lt_konp
        FOR ALL ENTRIES IN lt_a018
        WHERE knumh    = lt_a018-knumh
          AND kappl    = 'M'
          AND kschl    = 'ZPB0'
          AND loevm_ko = space
        ORDER BY PRIMARY KEY.
    ENDIF.

    SELECT *
      FROM eine
      INTO CORRESPONDING FIELDS OF TABLE lt_eine
      FOR ALL ENTRIES IN lt_eina
      WHERE infnr = lt_eina-infnr
        AND ekorg = 'TNT'
        AND loekz = space
      ORDER BY PRIMARY KEY.
  ENDIF.

  IF lt_eine[] IS NOT INITIAL.
    SELECT *
      FROM eipa
      INTO CORRESPONDING FIELDS OF TABLE lt_eipa
      FOR ALL ENTRIES IN lt_eine
      WHERE infnr = lt_eine-infnr
        AND werks = so_werks-low
      ORDER BY PRIMARY KEY.
  ENDIF.

*  IF lt_eipa[] IS NOT INITIAL.
  lt_xeipa[] = lt_eipa[].
  SORT lt_xeipa BY infnr.
  DELETE ADJACENT DUPLICATES FROM lt_xeipa COMPARING infnr.
  SORT lt_a018 BY lifnr matnr datab DESCENDING.

  LOOP AT lt_eina INTO ls_eina.
    CLEAR ls_mara.
    READ TABLE gt_mara INTO ls_mara
                       WITH KEY matnr = ls_eina-matnr.
    IF sy-subrc = 0.
      CLEAR ls_lfa1.
      READ TABLE gt_lfa1 INTO ls_lfa1
                         WITH KEY lifnr = ls_eina-lifnr.
      IF sy-subrc = 0.
        CLEAR ls_eine.
        READ TABLE lt_eine INTO ls_eine
                           WITH KEY infnr = ls_eina-infnr. "ls_xeipa-infnr.
        IF sy-subrc = 0.
          ls_lfa1-aplfz   = ls_eine-aplfz.
        ENDIF.
        ls_lfa1-mfrpn   = ls_mara-mfrpn.
        ls_lfa1-mfrnr   = ls_mara-mfrnr.

        CLEAR ls_ekpo.
        READ TABLE gt_ekpo INTO ls_ekpo
                           WITH KEY idnlf = ls_eina-matnr.
        IF ls_ekpo-idnlf IS NOT INITIAL.
          lv_matnr  = ls_ekpo-idnlf.
        ELSE.
          lv_matnr  = so_matnr-low.
        ENDIF.

        CLEAR ls_a018.
        READ TABLE lt_a018 INTO ls_a018
                           WITH KEY lifnr = ls_lfa1-lifnr
                                    matnr = lv_matnr.
        IF sy-subrc = 0.
          READ TABLE lt_konp INTO ls_konp
                             WITH KEY knumh = ls_a018-knumh.
          IF sy-subrc = 0.
            ls_lfa1-kbetr   = ls_konp-kbetr.
            ls_lfa1-konwa   = ls_konp-konwa.
            ls_lfa1-kpein   = ls_konp-kpein.
            ls_lfa1-kmein   = ls_konp-kmein.
          ENDIF.
          ls_lfa1-datab   = ls_a018-datab.
        ENDIF.
        CLEAR : ls_a018, ls_konp.

        IF ls_lfa1-kbetr IS INITIAL.
          gv_subrc = 7.
          gv_lifnr = ls_lfa1-lifnr.
          EXIT.
        ENDIF.

        MODIFY gt_lfa1 FROM ls_lfa1
                       TRANSPORTING mfrpn mfrnr aplfz datab
                                    kbetr konwa kpein kmein
                       WHERE lifnr = ls_eina-lifnr.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF gv_subrc = 0.
    IF lt_eipa[] IS NOT INITIAL.
      SELECT *
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE gt_xekpo
        FOR ALL ENTRIES IN lt_eipa
        WHERE ebeln = lt_eipa-ebeln
          AND ebelp = lt_eipa-ebelp
          AND loekz = space
        ORDER BY PRIMARY KEY.

      lt_xekpo[] = gt_xekpo[].
      SORT lt_xekpo BY ebeln.
      DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING ebeln.
      IF lt_xekpo[] IS NOT INITIAL.
        SELECT *
          FROM ekko
          INTO CORRESPONDING FIELDS OF TABLE gt_xekko
          FOR ALL ENTRIES IN lt_xekpo
          WHERE ebeln = lt_xekpo-ebeln
            AND ekgrp = pa_ekgrp
          ORDER BY PRIMARY KEY.

        SELECT *
          FROM eket
          INTO CORRESPONDING FIELDS OF TABLE gt_xeket
          FOR ALL ENTRIES IN lt_xekpo
          WHERE ebeln = lt_xekpo-ebeln
          ORDER BY PRIMARY KEY.
      ENDIF.
    ENDIF.

    PERFORM f_check_currency TABLES lt_eine
                                    lt_eipa.

    PERFORM f_get_highest_price TABLES lt_eipa
                                CHANGING gs_head-highp gs_head-pwaer
                                         gs_head-ppeinh gs_head-pprme
                                         gs_head-aedat.

    SORT lt_eipa BY bedat DESCENDING preis DESCENDING.
    lv_index  = 1.

    WHILE lv_subrc IS INITIAL.
      READ TABLE lt_eipa INTO ls_eipa INDEX lv_index.
      IF sy-subrc = 0.
        CLEAR ls_xekpo.
        READ TABLE gt_xekpo INTO ls_xekpo
                            WITH KEY ebeln = ls_eipa-ebeln
                                     ebelp = ls_eipa-ebelp.
        IF sy-subrc = 0.
          lv_subrc = 4.
          gs_head-ebeln = ls_eipa-ebeln.
          gs_head-bedat = ls_eipa-bedat.

          IF ls_eipa-bprme = ls_xekpo-meins.
            gs_head-menge = ls_xekpo-menge.
          ELSE.
            gs_head-menge = ls_eipa-menge.
          ENDIF.

          gs_head-meins = ls_eipa-bprme.

          CLEAR ls_xekko.
          READ TABLE gt_xekko INTO ls_xekko
                              WITH KEY ebeln  = ls_eipa-ebeln.
          IF sy-subrc = 0.
            SELECT SINGLE lifnr name1
              FROM lfa1
              INTO (gs_head-lifnr, gs_head-name1l)
              WHERE lifnr = ls_xekko-lifnr.

            gs_head-waers = ls_xekko-waers.
            lv_knumv      = ls_xekko-knumv.
          ENDIF.

          SELECT *
            FROM konv
            INTO CORRESPONDING FIELDS OF TABLE lt_konv
            WHERE knumv = lv_knumv
              AND kposn = ls_eipa-ebelp
            ORDER BY PRIMARY KEY.

          LOOP AT lt_konv INTO ls_konv.
            IF ls_konv-kschl(3) = 'ZPB'.
              gs_head-preis = ls_konv-kbetr.
              gs_head-bwaer = ls_konv-waers.
              gs_head-peinh = ls_konv-kpein.
              gs_head-bprme = ls_konv-kmein.
              EXIT.
            ENDIF.
          ENDLOOP.
        ELSE.
          ADD 1 TO lv_index.
          IF lv_index = 10.
            lv_subrc = 4.
          ENDIF.
        ENDIF.
      ELSE.
        lv_subrc = 4.
      ENDIF.
    ENDWHILE.
  ENDIF.
*  ENDIF.
ENDFORM.                    " F_GET_LAST_PURCHASED

*&---------------------------------------------------------------------*
*&      Form  F_MATERIAL_MPN
*&---------------------------------------------------------------------*
FORM f_material_mpn .
  DATA : ls_mara  TYPE mara,
         lr_matnr TYPE RANGE OF matnr,
         ls_matnr LIKE LINE OF lr_matnr,
         lv_matnr TYPE mara-matnr,
         ls_lfa1  LIKE LINE OF gt_lfa1,
         lr_mfrnr TYPE RANGE OF mfrnr,
         ls_mfrnr LIKE LINE OF lr_mfrnr.

  DATA : lt_mara  TYPE STANDARD TABLE OF mara,
         lt_xmara TYPE STANDARD TABLE OF mara,
         ls_xmara LIKE LINE OF lt_xmara.

  ls_xmara-matnr = so_matnr-low.
  APPEND ls_xmara TO lt_xmara.
  IF pa_ean11 IS NOT INITIAL.
    ls_xmara-matnr = pa_ean11.
    APPEND ls_xmara TO lt_xmara.
  ENDIF.

  IF lt_xmara[] IS NOT INITIAL.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE lt_mara
      FOR ALL ENTRIES IN lt_xmara
      WHERE matnr = lt_xmara-matnr
      ORDER BY PRIMARY KEY.
  ENDIF.

  LOOP AT lt_mara INTO ls_mara.
    CONCATENATE ls_mara-matnr '*' INTO lv_matnr.
    ls_matnr-sign   = 'I'.
    ls_matnr-option = 'CP'.
    ls_matnr-low    = lv_matnr.
    APPEND ls_matnr TO lr_matnr.
  ENDLOOP.

  LOOP AT gt_lfa1 INTO ls_lfa1.
    ls_mfrnr-sign   = 'I'.
    ls_mfrnr-option = 'CP'.
    ls_mfrnr-low    = ls_lfa1-lifnr.
    APPEND ls_mfrnr TO lr_mfrnr.
    CLEAR ls_mfrnr.
  ENDLOOP.

  IF ls_mara-mprof EQ 'Z001'.
    SELECT *
      FROM mara
      INTO CORRESPONDING FIELDS OF TABLE gt_mara
      WHERE matnr IN lr_matnr
        AND lvorm = space
        AND mtart = 'HERS'
        AND mfrnr IN lr_mfrnr
      ORDER BY PRIMARY KEY.
  ELSE.
    gt_mara[] = lt_mara[].
  ENDIF.
ENDFORM.                    " F_MATERIAL_MPN

*&---------------------------------------------------------------------*
*&      Form  F_GET_BUDGET_PRICE
*&---------------------------------------------------------------------*
FORM f_get_budget_price .
  DATA : lt_a049 TYPE STANDARD TABLE OF a049,
         lt_a501 TYPE STANDARD TABLE OF a501,
         lt_k049 TYPE STANDARD TABLE OF konp,
         lt_k501 TYPE STANDARD TABLE OF konp,
         ls_a501 LIKE LINE OF lt_a501,
         ls_a049 LIKE LINE OF lt_a049,
         ls_k501 LIKE LINE OF lt_k501,
         ls_k049 LIKE LINE OF lt_k501.

  DATA : lv_budget    LIKE konp-kbetr,
         lv_datbi     TYPE sy-datum,
         lv_datab     TYPE sy-datum,
         lv_kpein(20).

  CASE gv_quarter.
    WHEN 1.
      CONCATENATE pa_mjahr '0101' INTO lv_datbi.
      CONCATENATE pa_mjahr '0630' INTO lv_datab.
    WHEN 2.
      CONCATENATE pa_mjahr '0101' INTO lv_datbi.
      CONCATENATE pa_mjahr '0630' INTO lv_datab.
    WHEN 3.
      CONCATENATE pa_mjahr '0701' INTO lv_datbi.
      CONCATENATE pa_mjahr '1231' INTO lv_datab.
    WHEN 4.
      CONCATENATE pa_mjahr '0701' INTO lv_datbi.
      CONCATENATE pa_mjahr '1231' INTO lv_datab.
  ENDCASE.

  SELECT matnr inco1 knumh
    FROM a501
    INTO CORRESPONDING FIELDS OF TABLE lt_a501
    WHERE kappl = 'M'
      AND kschl = 'ZBGT'
      AND ekorg = 'TNT'
      AND esokz = '0'
      AND matnr = so_matnr-low
      AND datbi >= lv_datbi
      AND datab <= lv_datab.

  SORT lt_a501 BY matnr inco1 knumh.

  IF lt_a501[] IS NOT INITIAL.
    SELECT knumh kopos kbetr kpein konwa kmein
      FROM konp
      INTO CORRESPONDING FIELDS OF TABLE lt_k501
      FOR ALL ENTRIES IN lt_a501
      WHERE knumh EQ lt_a501-knumh
        AND kopos EQ '1'
        AND loevm_ko EQ space
      ORDER BY PRIMARY KEY.
  ENDIF.

  CLEAR ls_a501.
  LOOP AT lt_a501 INTO ls_a501.
    CLEAR ls_k501.
    READ TABLE lt_k501 INTO ls_k501
                       WITH KEY knumh = ls_a501-knumh.
    IF sy-subrc = 0.
      gs_head-konwa  = ls_k501-konwa.
      gs_head-kbetr  = ls_k501-kbetr.
      gs_head-kpein  = ls_k501-kpein.
      gs_head-kmein  = ls_k501-kmein.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF gs_head-konwa IS INITIAL.
    SELECT matnr knumh
      FROM a049
      INTO CORRESPONDING FIELDS OF TABLE lt_a049
      WHERE kappl = 'M'
        AND kschl = 'ZBGT'
        AND ekorg = 'TNT'
        AND esokz = '0'
        AND matnr = so_matnr-low
        AND datbi >= lv_datbi
        AND datab <= lv_datab.

    SORT lt_a049 BY matnr knumh.

    IF lt_a049[] IS NOT INITIAL.
      SELECT knumh kopos kbetr kpein konwa kmein
        FROM konp
        INTO CORRESPONDING FIELDS OF TABLE lt_k049
        FOR ALL ENTRIES IN lt_a049
        WHERE knumh = lt_a049-knumh
          AND kopos EQ '1'
          AND loevm_ko EQ space
        ORDER BY PRIMARY KEY.
    ENDIF.

    CLEAR ls_a049.
    LOOP AT lt_a049 INTO ls_a049.
      CLEAR ls_k049.
      READ TABLE lt_k049 INTO ls_k049
                         WITH KEY knumh = ls_a049-knumh.
      IF sy-subrc = 0.
        gs_head-konwa  = ls_k049-konwa.
        gs_head-kbetr  = ls_k049-kbetr.
        gs_head-kpein  = ls_k049-kpein.
        gs_head-kmein  = ls_k049-kmein.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_BUDGET_PRICE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data .
  DATA : lv_peinh(20),
         lv_bprme(10),
         lv_ppeinh(20),
         lv_pprme(10).

  CLEAR : gt_detail[], gt_detail, gt_xsuppl[], gt_xsuppl, gt_palloc[],
          gt_palloc, gt_sub[], gt_sub.

  gs_header-zalno   = pa_zalno.
  gs_header-submi   = pa_submi.

  IF gv_trtyp = 'H'.
    gs_header-gjahr = sy-datum(4).
  ELSE.
    gs_header-gjahr = gs_x04z-zaldt(4).
  ENDIF.

  gs_header-matnr   = gs_head-matnr.
  gs_header-maktx   = gs_head-maktx.
  gs_header-datlb   = gs_head-bedat.
  gs_header-waers   = gs_head-bwaer.
  gs_header-meins   = gs_head-meins.
  gs_header-vrsio   = gs_head-vrsio.

  WRITE gs_head-kbetr TO gs_header-budget CURRENCY gs_head-konwa.
  CONDENSE gs_header-budget NO-GAPS.
  gs_header-konwa = gs_head-konwa.

  gs_header-kpein = gs_head-kpein.
  gs_header-kmein = gs_head-kmein.

  WRITE gs_head-preis TO gs_header-netprt CURRENCY gs_head-bwaer.
  CONDENSE gs_header-netprt NO-GAPS.
  IF gs_head-peinh IS NOT INITIAL.
    lv_peinh  = gs_head-peinh.
    CONDENSE lv_peinh NO-GAPS.

    PERFORM f_meins_conversion USING gs_head-bprme
                               CHANGING lv_bprme.

    CONCATENATE gs_header-netprt '/' lv_peinh lv_bprme
    INTO gs_header-netprt
    SEPARATED BY space.
  ENDIF.

  WRITE gs_head-highp TO gs_header-hight CURRENCY gs_head-pwaer.
  CONDENSE gs_header-hight NO-GAPS.
  gs_header-pwaer = gs_head-pwaer.
  gs_header-aedat = gs_head-aedat.

  IF gs_head-ppeinh IS NOT INITIAL.
    lv_ppeinh = gs_head-ppeinh.
    CONDENSE lv_ppeinh.
    PERFORM f_meins_conversion USING gs_head-pprme
                               CHANGING lv_pprme.
    CONCATENATE gs_header-hight '/' lv_ppeinh lv_pprme
    INTO gs_header-hight
    SEPARATED BY space.
  ENDIF.

  gs_header-name1   = gs_head-name1l.

  WRITE gs_head-menge TO gs_header-menget UNIT gs_head-meins.
  CONDENSE gs_header-menget NO-GAPS.

  PERFORM f_meins_conversion USING gs_head-meins
                             CHANGING gs_header-meinst.

  PERFORM f_form_detail.
  PERFORM f_form_supplier.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FORM
*&---------------------------------------------------------------------*
FORM f_print_form  USING    fu_ucomm fu_close fu_open fu_nodialog fu_mail.
  DATA : lt_supplier TYPE STANDARD TABLE OF zgdmmst0053,
         ls_supplier TYPE zgdmmst0053,
         ls_lfa1     TYPE lfa1.

  DATA : lv_menget  LIKE eket-menge,
         lv_record  TYPE i,
         lv_totpage TYPE i,
         lv_lines   TYPE i,
         lv_times   TYPE i,
         lv_count   TYPE i,
         lv_div     TYPE i,
         lv_mod     TYPE i.

  DATA : x1 TYPE i,
         x2 TYPE i.

  DATA : lt_nsupl     TYPE STANDARD TABLE OF zgdmmst0055.

  DATA : ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop.

  p_tdform  = 'ZHSMMMSF0011'.
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_close = fu_close.

  CASE fu_ucomm.
    WHEN '&POS'.
      d_output_opt-tdnoprev     = 'X'.
      d_ctrl_param-no_dialog    = fu_nodialog.
      d_ctrl_param-preview      = space.
      d_ctrl_param-getotf       = 'X'.
    WHEN '&PREV'.
      d_output_opt-tdnoprint    = 'X'.
      d_ctrl_param-preview      = 'X'.
  ENDCASE.

  DESCRIBE TABLE gt_sub LINES lv_totpage.
  DESCRIBE TABLE gt_lfa1 LINES lv_record.
  lv_div  = lv_record DIV 3.
  lv_mod  = lv_record MOD 3.

  IF lv_mod <> 0.
    lv_times = lv_div + 1.
  ELSE.
    lv_times = lv_div.
  ENDIF.

  IF x1 IS INITIAL.
    x1 = 1.
    x2 = x1 + 2.
  ENDIF.

  DO lv_times TIMES.
    CLEAR lv_count.
    LOOP AT gt_lfa1 INTO ls_lfa1 FROM x1 TO x2.
      ADD 1 TO lv_count.
      CASE lv_count.
        WHEN 1.
          ls_supplier-lifnr1  = ls_lfa1-lifnr.
        WHEN 2.
          ls_supplier-lifnr2  = ls_lfa1-lifnr.
        WHEN 3.
          ls_supplier-lifnr3  = ls_lfa1-lifnr.
      ENDCASE.
    ENDLOOP.

    APPEND ls_supplier TO lt_supplier.
    CLEAR ls_supplier.

    x1 = x2 + 1.
    x2 = x1 + 2.
  ENDDO.

  DESCRIBE TABLE lt_supplier LINES lv_lines.

*  gs_header-ekgrp = pa_ekgrp.

  LOOP AT lt_supplier INTO ls_supplier.
    PERFORM f_supplier_data TABLES lt_nsupl
                            USING ls_supplier-lifnr1 ls_supplier-lifnr2
                                  ls_supplier-lifnr3.

    IF fu_open IS INITIAL AND
      fu_close IS INITIAL.
      AT FIRST.
        d_ctrl_param-no_close = 'X'.
      ENDAT.

      AT LAST.
        d_ctrl_param-no_close = space.
      ENDAT.
    ENDIF.

    CALL FUNCTION d_smrt_funcmod
      EXPORTING
        control_parameters = d_ctrl_param
        output_options     = d_output_opt
        user_settings      = space
        t_header           = gs_header
        wa_supplier        = ls_supplier
        va_menget          = lv_menget
        va_record          = lv_record
        va_totpage         = lv_totpage
        va_lines           = lv_lines
      IMPORTING
        job_output_info    = ls_info
        job_output_options = ls_options
      TABLES
        t_detail           = gt_detail
        t_sub              = gt_sub
        t_suppl            = gt_xsuppl
        t_nsupl            = lt_nsupl.

    IF fu_open IS INITIAL AND
      fu_close IS INITIAL.
      d_ctrl_param-no_open = 'X'.
    ELSEIF lv_lines > 1.
      d_ctrl_param-no_open = 'X'.
    ENDIF.
  ENDLOOP.

  IF fu_mail IS NOT INITIAL.
    PERFORM f_send_mail USING ls_info ls_options ''.
  ENDIF.
ENDFORM.                    " F_PRINT_FORM

*&---------------------------------------------------------------------*
*&      Form  F_SUB_TOTAL
*&---------------------------------------------------------------------*
FORM f_sub_total  USING    fu_total fu_matnr fu_bprme fu_meins.
  DATA : lv_menge      TYPE eban-menge,
         lv_menget(17),
         ls_sub        LIKE LINE OF gt_sub.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input                = fu_total
      matnr                = fu_matnr
      meinh                = fu_bprme
      meins                = fu_meins
    IMPORTING
      output               = lv_menge
    EXCEPTIONS
      conversion_not_found = 1
      input_invalid        = 2
      material_not_found   = 3
      meinh_not_found      = 4
      meins_missing        = 5
      no_meinh             = 6
      output_invalid       = 7
      overflow             = 8
      OTHERS               = 9.

  IF sy-subrc = 0.
    WRITE lv_menge TO lv_menget DECIMALS 3.
    SPLIT lv_menget AT ',' INTO ls_sub-menget ls_sub-decimal.
    CONDENSE ls_sub-menget NO-GAPS.
    CONDENSE ls_sub-decimal NO-GAPS.
    APPEND ls_sub TO gt_sub.
  ENDIF.
ENDFORM.                    " F_SUB_TOTAL

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_SAVE
*&---------------------------------------------------------------------*
FORM f_prepare_save .
  CLEAR : gt_04a[], gt_04b[], gt_04d[].

  IF gv_trtyp = 'H'.
    PERFORM f_get_next_number CHANGING gs_header-zalno.
  ELSE.
    gs_header-zalno = gs_x04z-zalno.
  ENDIF.

*  PERFORM f_04a USING gs_header-zalno.
*  PERFORM f_04b USING gs_header-zalno.
  PERFORM f_04c USING gs_header-zalno.
*  PERFORM f_04d USING gs_header-zalno.

  PERFORM f_04p USING gs_header-zalno.
  PERFORM f_04x USING gs_header-zalno.
  PERFORM f_04y USING gs_header-zalno.
  PERFORM f_04z USING gs_header-zalno.
  PERFORM f_006 USING gs_header-zalno.
  PERFORM f_007 USING gs_header-zalno.
ENDFORM.                    " F_PREPARE_SAVE

*&---------------------------------------------------------------------*
*&      Form  F_GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
FORM f_get_next_number  CHANGING fc_zalno.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      nr_range_nr             = '01'
      object                  = 'ZALNO'
*     subobject               = pa_ekgrp
*     toyear                  = pa_mjahr
    IMPORTING
      number                  = fc_zalno
    EXCEPTIONS
      interval_not_found      = 1
      number_range_not_intern = 2
      object_not_found        = 3
      quantity_is_0           = 4
      quantity_is_not_1       = 5
      interval_overflow       = 6
      buffer_overflow         = 7
      OTHERS                  = 8.
ENDFORM.                    " F_GET_NEXT_NUMBER

*&---------------------------------------------------------------------*
*&      Form  F_04A
*&---------------------------------------------------------------------*
FORM f_04a  USING    fu_zalno.
  DATA : ls_04a   LIKE LINE OF gt_04a.

  ls_04a-zalno    = fu_zalno.
  ls_04a-zaldt    = sy-datum.
  ls_04a-werks    = so_werks-low.
  ls_04a-ekgrp    = pa_ekgrp.
  ls_04a-mjahr    = pa_mjahr.
  CASE gv_quarter.
    WHEN 1.
      ls_04a-quart = 'p_q1'.
    WHEN 2.
      ls_04a-quart = 'p_q2'.
    WHEN 3.
      ls_04a-quart = 'p_q3'.
    WHEN 4.
      ls_04a-quart = 'p_q4'.
  ENDCASE.
  ls_04a-matnr    = gs_header-matnr.
  ls_04a-maktx    = gs_header-maktx.
  ls_04a-konwa    = gs_header-konwa.
  ls_04a-budget   = gs_header-budget.
  ls_04a-datlb    = gs_header-datlb.
  ls_04a-waers    = gs_header-waers.
  ls_04a-meins    = gs_header-meins.
  ls_04a-netprt   = gs_header-netprt.
  ls_04a-menget   = gs_header-menget.
  ls_04a-name1    = gs_header-name1.
  APPEND ls_04a TO gt_04a.
ENDFORM.                    " F_04A

*&---------------------------------------------------------------------*
*&      Form  F_04B
*&---------------------------------------------------------------------*
FORM f_04b  USING    fu_zalno.
  DATA : ls_04b    LIKE LINE OF gt_04b,
         ls_detail LIKE LINE OF gt_detail.

  LOOP AT gt_detail INTO ls_detail.
    ls_04b-zalno    = fu_zalno.
    ls_04b-banfn    = ls_detail-banfn.
    ls_04b-bnfpo    = ls_detail-bnfpo.
    ls_04b-frgdt    = ls_detail-frgdt.
    ls_04b-menge    = ls_detail-menge.
    ls_04b-bsmng    = ls_detail-bsmng.
    ls_04b-meins    = ls_detail-meins.
    ls_04b-lfdat    = ls_detail-lfdat.
    APPEND ls_04b TO gt_04b.
    CLEAR ls_04b.
  ENDLOOP.
ENDFORM.                    " F_04B

*&---------------------------------------------------------------------*
*&      Form  F_04C
*&---------------------------------------------------------------------*
FORM f_04c  USING    fu_zalno.
  DATA : ls_04c    LIKE LINE OF gt_04c,
         ls_xsuppl LIKE LINE OF gt_xsuppl,
         ls_004    LIKE LINE OF gt_004,
         lv_posnr  TYPE zgdmmt004c-posnr.

  LOOP AT gt_xsuppl INTO ls_xsuppl.
    ls_04c-zalno        = fu_zalno.
    ls_04c-lifnr        = ls_xsuppl-lifnr.
    CLEAR ls_004.
    READ TABLE gt_004 INTO ls_004
                      WITH KEY zeile = ls_xsuppl-zeile.
    IF sy-subrc = 0.
      ls_04c-zeile        = ls_004-xeile.
    ENDIF.
    IF ls_04c-zeile = 1.
      ADD 1 TO lv_posnr.
    ENDIF.
    ls_04c-posnr        = lv_posnr.
    ls_04c-value        = ls_xsuppl-value.
    APPEND ls_04c TO gt_04c.
    CLEAR ls_04c.
  ENDLOOP.
ENDFORM.                    " F_04C

*&---------------------------------------------------------------------*
*&      Form  F_04D
*&---------------------------------------------------------------------*
FORM f_04d  USING    fu_zalno.
  DATA : ls_04d   LIKE LINE OF gt_04d,
         ls_heads LIKE LINE OF gt_heads,
         ls_detls LIKE LINE OF gt_detls.

  LOOP AT gt_heads INTO ls_heads WHERE count <> 1.
    LOOP AT gt_detls INTO ls_detls WHERE lifnr = ls_heads-lifnr.
      ls_04d-zalno    = fu_zalno.
      ls_04d-lifnr    = ls_detls-lifnr.
      ls_04d-ebeln    = ls_detls-ebeln.
      ls_04d-ebelp    = ls_detls-ebelp.
      ls_04d-etenr    = ls_detls-etenr.
      ls_04d-eindt    = ls_detls-eindt.
      ls_04d-menge    = ls_detls-menge.
      ls_04d-meins    = ls_detls-meins.
      APPEND ls_04d TO gt_04d.
      CLEAR ls_04d.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_04D

*&---------------------------------------------------------------------*
*&      Form  F_FORM_DETAIL
*&---------------------------------------------------------------------*
FORM f_form_detail .
  DATA : ls_detail    LIKE LINE OF gt_detail.

  DATA : lv_icon(4),
         lv_nou(3),
         lv_menge      TYPE eban-menge,
         lv_total      TYPE eban-menge,
         lv_menget(17),
         lv_count      TYPE  i.

  FIELD-SYMBOLS : <fs>    TYPE any.

  LOOP AT <fs_detl> ASSIGNING <fs_ldetl>.
    ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ldetl> TO <fs>.
    lv_icon = <fs>.
    ADD 1 TO lv_nou.
    ADD 1 TO lv_count.
    ls_detail-nou = lv_nou.
    ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_ldetl> TO <fs>.
    ls_detail-banfn = <fs>.
    ASSIGN COMPONENT 'BNFPO' OF STRUCTURE <fs_ldetl> TO <fs>.
    ls_detail-bnfpo = <fs>.
    ASSIGN COMPONENT 'FRGDT' OF STRUCTURE <fs_ldetl> TO <fs>.
    ls_detail-frgdt = <fs>.
    ASSIGN COMPONENT 'EINDT' OF STRUCTURE <fs_ldetl> TO <fs>.
    ls_detail-lfdat = <fs>.
    ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_ldetl> TO <fs>.
    ls_detail-menge = <fs>.
    ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_ldetl> TO <fs>.
    ls_detail-meins = <fs>.

    IF gs_head-bprme IS INITIAL.
      gs_head-bprme = ls_detail-meins.
    ENDIF.

    CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
      EXPORTING
        input                = ls_detail-menge
        matnr                = gs_head-matnr
        meinh                = gs_head-bprme
        meins                = ls_detail-meins
      IMPORTING
        output               = lv_menge
      EXCEPTIONS
        conversion_not_found = 1
        input_invalid        = 2
        material_not_found   = 3
        meinh_not_found      = 4
        meins_missing        = 5
        no_meinh             = 6
        output_invalid       = 7
        overflow             = 8
        OTHERS               = 9.

    IF sy-subrc = 0.
      WRITE lv_menge TO lv_menget DECIMALS 3.
      SPLIT lv_menget AT ',' INTO ls_detail-menget ls_detail-decimal.
      CONDENSE ls_detail-menget NO-GAPS.
      CONDENSE ls_detail-decimal NO-GAPS.
    ENDIF.

    ADD lv_menge TO lv_total.
    IF lv_count = 50.
      PERFORM f_sub_total USING lv_total ls_detail-matnr gs_head-bprme
                                ls_detail-meins.
      CLEAR : lv_count.
    ENDIF.
    APPEND ls_detail TO gt_detail.
    CLEAR ls_detail.
  ENDLOOP.

  PERFORM f_sub_total USING lv_total gs_head-matnr gs_head-bprme
                            gs_head-bprme.
ENDFORM.                    " F_FORM_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_FORM_SUPPLIER
*&---------------------------------------------------------------------*
FORM f_form_supplier .
  DATA : ls_lfa1   LIKE LINE OF gt_lfa1,
         ls_004    LIKE LINE OF gt_004,
         ls_xsuppl LIKE LINE OF gt_xsuppl,
         ls_x04c   LIKE LINE OF gt_x04c,
         ls_palloc LIKE LINE OF gt_palloc.

  DATA : lv_qcode(10),
         lv_value(100).

  LOOP AT gt_lfa1 INTO ls_lfa1.
    LOOP AT gt_004 INTO ls_004.
      ls_xsuppl-lifnr        = ls_lfa1-lifnr.
      ls_xsuppl-zeile        = ls_004-zeile.
      ls_xsuppl-nou          = ls_004-nou.
      ls_xsuppl-description  = ls_004-description.
      ls_xsuppl-zend         = ls_004-zend.

      CASE gv_quarter.
        WHEN 1.
          lv_qcode = 'p_q1'.
        WHEN 2.
          lv_qcode = 'p_q2'.
        WHEN 3.
          lv_qcode = 'p_q3'.
        WHEN 4.
          lv_qcode = 'p_q4'.
      ENDCASE.

      PERFORM f_replace_code USING lv_qcode ls_004-period ls_004-zgroup1 pa_mjahr
                             CHANGING ls_xsuppl-description ls_palloc-description.

      CASE gv_trtyp.
        WHEN 'H'.
          IF ls_004-field IS NOT INITIAL.
            PERFORM f_get_value USING ls_xsuppl-lifnr ls_004-field ls_lfa1-datab
                                      ls_lfa1-kbetr ls_lfa1-konwa
                                      ls_lfa1-kpein ls_lfa1-kmein
                                      ls_palloc-description
                                CHANGING ls_xsuppl-value  ls_palloc-value.
          ELSE.
            PERFORM f_get_value USING ls_xsuppl-lifnr ls_004-description
                                      '' '' '' '' ''
                                      ls_palloc-description
                                CHANGING ls_xsuppl-value ls_palloc-value.
          ENDIF.
        WHEN OTHERS.
          IF ls_004-description = 'Pertimbangan/Alasan'.
            PERFORM f_get_value USING ls_xsuppl-lifnr ls_004-description
                                      '' '' '' '' ''
                                      ls_palloc-description
                                CHANGING ls_xsuppl-value ls_palloc-value.
          ELSEIF ls_004-field(4) = 'ALOC'.
            PERFORM f_get_value USING ls_xsuppl-lifnr ls_004-field
                                      '' '' '' '' ''
                                      ls_palloc-description
                                CHANGING ls_xsuppl-value ls_palloc-value.
          ELSEIF ls_004-field(5) = 'ACTLK'.
            PERFORM f_get_value USING ls_xsuppl-lifnr ls_004-field
                                      '' '' '' '' ''
                                      ls_palloc-description
                                CHANGING ls_xsuppl-value ls_palloc-value.
          ELSE.
            CLEAR ls_x04c.
            READ TABLE gt_x04c INTO ls_x04c
                               WITH KEY lifnr = ls_xsuppl-lifnr
                                        zeile = ls_004-xeile.
            IF sy-subrc = 0.
              ls_xsuppl-value = ls_x04c-value.
              IF ls_palloc-description IS NOT INITIAL.
                ls_palloc-value = ls_x04c-value.
              ENDIF.
            ENDIF.
          ENDIF.
      ENDCASE.

      IF ls_palloc-description IS NOT INITIAL AND
        ls_palloc-value IS NOT INITIAL.
        ls_palloc-lifnr  = ls_xsuppl-lifnr.
        APPEND ls_palloc TO gt_palloc.
      ENDIF.
      CLEAR : ls_palloc, lv_value.

      APPEND ls_xsuppl TO gt_xsuppl.
      CLEAR ls_xsuppl.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_FORM_SUPPLIER

*&---------------------------------------------------------------------*
*&      Form  F_REPLACE_CODE
*&---------------------------------------------------------------------*
FORM f_replace_code  USING    fu_qcode fu_period fu_zgroup1 fu_mjahr
                     CHANGING fc_description fc_description1.
  DATA : lv_quart,
         lv_q1,
         lv_q2,
         lv_q3,
         lv_q4,
         lv_semester.

  CASE fu_qcode.
    WHEN 'p_q1'.
      lv_quart    = '1'.
      lv_q1       = '1'.
      lv_semester = '1'.
    WHEN 'p_q2'.
      lv_quart    = '2'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_semester = '1'.
    WHEN 'p_q3'.
      lv_quart    = '3'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_q3       = '3'.
      lv_semester = '2'.
    WHEN 'p_q4'.
      lv_quart    = '4'.
      lv_q1       = '1'.
      lv_q2       = '2'.
      lv_q3       = '3'.
      lv_q4       = '4'.
      lv_semester = '2'.
  ENDCASE.

  CASE fu_period.
    WHEN 'Q'.
      IF fu_zgroup1 IS NOT INITIAL.
        REPLACE ALL OCCURRENCES OF REGEX '&1' IN fc_description WITH lv_q1.
        PERFORM f_add_percen_alloc USING sy-subrc lv_q1
                                   CHANGING fc_description1.
        REPLACE ALL OCCURRENCES OF REGEX '&2' IN fc_description WITH lv_q2.
        PERFORM f_add_percen_alloc USING sy-subrc lv_q2
                                   CHANGING fc_description1.
        REPLACE ALL OCCURRENCES OF REGEX '&3' IN fc_description WITH lv_q3.
        PERFORM f_add_percen_alloc USING sy-subrc lv_q3
                                   CHANGING fc_description1.
        REPLACE ALL OCCURRENCES OF REGEX '&4' IN fc_description WITH lv_q4.
        PERFORM f_add_percen_alloc USING sy-subrc lv_q4
                                   CHANGING fc_description1.
      ELSE.
        REPLACE ALL OCCURRENCES OF REGEX '&1' IN fc_description WITH lv_quart.
      ENDIF.
    WHEN 'S'.
      REPLACE ALL OCCURRENCES OF REGEX '&1' IN fc_description WITH lv_semester.
  ENDCASE.

  REPLACE ALL OCCURRENCES OF REGEX '&y' IN fc_description WITH fu_mjahr.
ENDFORM.                    " F_REPLACE_CODE

*&---------------------------------------------------------------------*
*&      Form  F_GET_VALUE
*&---------------------------------------------------------------------*
FORM f_get_value  USING    fu_lifnr fu_field fu_datab fu_kbetr fu_konwa
                           fu_kpein fu_kmein fu_description
                  CHANGING fc_value fc_value1.
  DATA : lv_datum     TYPE sy-datum,
         lv_tmeng(20),
         lv_tmein(5),
         ls_zm73      TYPE ty_zm73,
         ls_lfm1      LIKE LINE OF gt_lfm1,
         ls_t052u     LIKE LINE OF gt_t052u.

  DATA : ls_heads  LIKE LINE OF gt_heads,
         ls_total  LIKE LINE OF gt_total,
         lv_tdname TYPE thead-tdname,
         lt_text   TYPE STANDARD TABLE OF ty_text,
         ls_text   LIKE LINE OF lt_text,
         ls_actal  LIKE LINE OF gt_actal.

  DATA : lv_datab TYPE sy-datum,
         ls_aloc  LIKE LINE OF gt_aloc,
         lv_aloc  TYPE p DECIMALS 0.

  FIELD-SYMBOLS : <fs>    TYPE any.

  CLEAR fc_value.

  CASE fu_field.
    WHEN 'KBETR'.
      PERFORM f_kbetr_calc USING fu_kbetr fu_konwa
                                 fu_kpein fu_kmein
                           CHANGING fc_value.

    WHEN 'MENGE'.
      PERFORM f_menge_calc USING '1' fu_lifnr
                           CHANGING fc_value.

    WHEN 'DATAB'.
      WRITE fu_datab TO fc_value DD/MM/YYYY.

    WHEN 'EBELN'.
      CLEAR ls_heads.
      READ TABLE gt_heads INTO ls_heads
                          WITH KEY lifnr = fu_lifnr.
      IF ls_heads-count = 1.
        fc_value = ls_heads-ebeln.
      ELSEIF ls_heads-count > 1.
        fc_value = 'Lihat lampiran'.
      ENDIF.

    WHEN 'LIFNR'.
*      READ TABLE gt_total INTO ls_total
*                          WITH KEY lifnr = fu_lifnr.
*      IF sy-subrc = 0.
      fc_value = 'Lihat lampiran'.
*      ENDIF.

    WHEN 'TOTAL'.
      PERFORM f_menge_calc USING '2' fu_lifnr
                           CHANGING fc_value.

    WHEN 'PO_MENGE'.
      CLEAR ls_heads.
      READ TABLE gt_heads INTO ls_heads
                          WITH KEY lifnr = fu_lifnr.
      IF ls_heads-count = 1.
        fc_value = ls_heads-totalt.
      ENDIF.

    WHEN 'PO_EINDT'.
      CLEAR ls_heads.
      READ TABLE gt_heads INTO ls_heads
                          WITH KEY lifnr = fu_lifnr.
      IF ls_heads-count = 1.
        WRITE ls_heads-eindt TO fc_value DD/MM/YYYY.
        CONDENSE fc_value NO-GAPS.
      ENDIF.

    WHEN 'NAME1'.
      READ TABLE <fs_main> ASSIGNING <fs_lmain>
                           WITH KEY ('LIFNR') = fu_lifnr.
      IF sy-subrc = 0.
        ASSIGN COMPONENT fu_field OF STRUCTURE <fs_lmain> TO <fs>.
        fc_value = <fs>.
      ENDIF.

    WHEN 'TDLINE'.
      READ TABLE <fs_main> ASSIGNING <fs_lmain>
                           WITH KEY ('LIFNR') = fu_lifnr.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'MFRPN' OF STRUCTURE <fs_lmain> TO <fs>.
        fc_value = <fs>.
      ENDIF.

    WHEN 'APLFZ'.
      READ TABLE <fs_main> ASSIGNING <fs_lmain>
                           WITH KEY ('LIFNR') = fu_lifnr.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'APLFZ' OF STRUCTURE <fs_lmain> TO <fs>.
        fc_value = <fs>.
        CONDENSE fc_value.
      ENDIF.

    WHEN 'BOBOTT'.
      CLEAR ls_zm73.
      CASE gv_quarter.
        WHEN 1.
          READ TABLE gt_zm73_1 INTO ls_zm73
                               WITH KEY lifnr = fu_lifnr.
        WHEN 2.
          READ TABLE gt_zm73_2 INTO ls_zm73
                               WITH KEY lifnr = fu_lifnr.
        WHEN 3.
          READ TABLE gt_zm73_3 INTO ls_zm73
                               WITH KEY lifnr = fu_lifnr.
        WHEN 4.
          READ TABLE gt_zm73_4 INTO ls_zm73
                               WITH KEY lifnr = fu_lifnr.
      ENDCASE.
      fc_value = ls_zm73-bobot.
      CONDENSE fc_value.

    WHEN 'Quotation'.
      READ TABLE <fs_main> ASSIGNING <fs_lmain>
                           WITH KEY ('LIFNR') = fu_lifnr.
      IF sy-subrc = 0.
        ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lmain> TO <fs>.
        fc_value = <fs>.
        CONDENSE fc_value.
      ENDIF.

    WHEN 'Pertimbangan/Alasan'.
      IF pa_zalno IS INITIAL.
        CONCATENATE pa_submi gs_head-vrsio fu_lifnr INTO lv_tdname.
      ELSE.
        CONCATENATE pa_submi pa_zalno gs_head-vrsio fu_lifnr INTO lv_tdname.
      ENDIF.
      READ TABLE gt_text INTO ls_text
                         WITH KEY head-tdname = lv_tdname.
      IF sy-subrc = 0.
        fc_value = 'Lihat lampiran'.
      ELSE.
        PERFORM f_read_text TABLES lt_text
                            USING  lv_tdname.
        IF lt_text[] IS NOT INITIAL .
          fc_value = 'Lihat lampiran'.
        ENDIF.
      ENDIF.

    WHEN 'TOP'.
      READ TABLE gt_lfm1 INTO ls_lfm1
                         WITH KEY lifnr = fu_lifnr.
      IF sy-subrc = 0.
        READ TABLE gt_t052u INTO ls_t052u
                            WITH KEY zterm = ls_lfm1-zterm.
        IF sy-subrc = 0.
          CONCATENATE ls_t052u-zterm '-' ls_t052u-text1 INTO fc_value
          SEPARATED BY space.
        ENDIF.
      ENDIF.

    WHEN 'LASTPUR'.
      PERFORM f_last_purchasing_date USING fu_lifnr
                                     CHANGING fc_value.

    WHEN 'PRICE'.
      PERFORM f_last_purchasing_price USING fu_lifnr
                                      CHANGING fc_value.

    WHEN OTHERS.
      IF fu_field(4) = 'ACTS'.
        CASE fu_field+4(1).
          WHEN 1.
            READ TABLE gt_zm73_1 INTO ls_zm73
                                 WITH KEY lifnr = fu_lifnr.
          WHEN 2.
            READ TABLE gt_zm73_2 INTO ls_zm73
                                 WITH KEY lifnr = fu_lifnr.
          WHEN 3.
            READ TABLE gt_zm73_3 INTO ls_zm73
                                 WITH KEY lifnr = fu_lifnr.
          WHEN 4.
            READ TABLE gt_zm73_4 INTO ls_zm73
                                 WITH KEY lifnr = fu_lifnr.
        ENDCASE.

        fc_value = ls_zm73-%aloc.
        CONDENSE fc_value.
        IF fu_description IS NOT INITIAL.
          fc_value1 = fc_value.
          TRANSLATE fc_value1 USING '.,'.
          CONDENSE fc_value1 NO-GAPS.
        ENDIF.
      ELSEIF fu_field(4) = 'ALOC'.
        CONCATENATE pa_mjahr '0630' INTO lv_datab.

        READ TABLE gt_aloc INTO ls_aloc
                           WITH KEY lifnr = fu_lifnr.

        LOOP AT gt_aloc INTO ls_aloc WHERE lifnr = fu_lifnr.
          lv_aloc = ls_aloc-kbetr / 10.
          IF ls_aloc-datab <= lv_datab.
            fc_value = lv_aloc.
          ELSE.
            fc_value = lv_aloc.
          ENDIF.
          CONDENSE fc_value.
        ENDLOOP.
      ELSEIF fu_field(5) = 'ACTLK'.
        CLEAR ls_actal.
        READ TABLE gt_actal INTO ls_actal
                            WITH KEY lifnr = fu_lifnr.
        CASE fu_field+5(1).
          WHEN 1.
            fc_value = ls_actal-act01.
            CONDENSE fc_value.
          WHEN 2.
            fc_value = ls_actal-act02.
            CONDENSE fc_value.
          WHEN 3.
            fc_value = ls_actal-act03.
            CONDENSE fc_value.
          WHEN 4.
            fc_value = ls_actal-act04.
            CONDENSE fc_value.
        ENDCASE.
      ENDIF.

*      PERFORM f_dyn_field USING fu_field '1'
*                          CHANGING fc_value.
*      SHIFT fc_value LEFT DELETING LEADING space.
  ENDCASE.
ENDFORM.                    " F_GET_VALUE

*&---------------------------------------------------------------------*
*&      Form  F_DYN_FIELD
*&---------------------------------------------------------------------*
FORM f_dyn_field  USING    fu_value fu_count
                  CHANGING fc_value.
  DATA : lv_field(50).
  FIELD-SYMBOLS : <fs>  TYPE any.

  CONCATENATE 'T_SUPPLIER-' fu_value fu_count INTO lv_field.
  ASSIGN (lv_field) TO <fs>.
  IF <fs> IS ASSIGNED.
    fc_value = <fs>.
  ENDIF.
ENDFORM.                    " F_DYN_FIELD

*&---------------------------------------------------------------------*
*&      Form  F_KBETR_CALC
*&---------------------------------------------------------------------*
FORM f_kbetr_calc  USING    fu_kbetr fu_konwa fu_kpein fu_kmein
                   CHANGING fc_value.

  DATA : lv_kbetr(50),
         lv_kpein(50),
         lv_kmein     TYPE konp-kmein.

  WRITE fu_kbetr TO lv_kbetr CURRENCY fu_konwa.
  CONDENSE lv_kbetr NO-GAPS.
  CONCATENATE fu_konwa lv_kbetr INTO lv_kbetr
  SEPARATED BY space.

  WRITE fu_kpein TO lv_kpein UNIT fu_kmein.
  CONDENSE lv_kpein NO-GAPS.

  PERFORM f_meins_conversion USING fu_kmein
                             CHANGING lv_kmein.

  CONCATENATE '( /' lv_kpein lv_kmein ')' INTO lv_kpein
  SEPARATED BY space.

  CONCATENATE lv_kbetr lv_kpein INTO fc_value
  SEPARATED BY space.
ENDFORM.                    " F_KBETR_CALC

*&---------------------------------------------------------------------*
*&      Form  F_MENGE_CALC
*&---------------------------------------------------------------------*
FORM f_menge_calc  USING    fu_count fu_lifnr
                   CHANGING fc_value.
  DATA : ls_sekko LIKE LINE OF gt_sekko,
         lv_meins TYPE konp-kmein.

  READ TABLE gt_sekko INTO ls_sekko
                      WITH KEY lifnr = fu_lifnr.
  IF sy-subrc = 0.
    CASE fu_count.
      WHEN '1'.
        WRITE ls_sekko-menge TO fc_value UNIT ls_sekko-meins.
      WHEN '2'.
        WRITE ls_sekko-total TO fc_value UNIT ls_sekko-meins.
    ENDCASE.
    CONDENSE fc_value NO-GAPS.

    PERFORM f_meins_conversion USING ls_sekko-meins
                               CHANGING lv_meins.

    CONCATENATE fc_value lv_meins INTO fc_value
    SEPARATED BY space.
  ENDIF.
ENDFORM.                    " F_MENGE_CALC

*&---------------------------------------------------------------------*
*&      Form  F_SUPPLIER_DATA
*&---------------------------------------------------------------------*
FORM f_supplier_data  TABLES   ft_nsupl STRUCTURE zgdmmst0055
                      USING    fu_lifnr1 fu_lifnr2 fu_lifnr3.
  DATA : lt_xsuppl TYPE STANDARD TABLE OF zgdmmst002x,
         ls_nsupl  TYPE zgdmmst0055,
         ls_xsuppl LIKE LINE OF gt_xsuppl,
         lt_lifnr  TYPE STANDARD TABLE OF range_lifnr,
         ls_004    LIKE LINE OF gt_004.

  DATA : lv_count   TYPE i.

  CLEAR : ft_nsupl[].

  PERFORM f_range_lifnr TABLES lt_lifnr
                        USING fu_lifnr1.
  PERFORM f_range_lifnr TABLES lt_lifnr
                        USING fu_lifnr2.
  PERFORM f_range_lifnr TABLES lt_lifnr
                        USING fu_lifnr3.

  LOOP AT gt_xsuppl INTO ls_xsuppl WHERE lifnr IN lt_lifnr.
    APPEND ls_xsuppl TO lt_xsuppl.
  ENDLOOP.

  LOOP AT gt_004 INTO ls_004.
    LOOP AT lt_xsuppl INTO ls_xsuppl WHERE zeile = ls_004-zeile.
      ls_nsupl-zeile       = ls_xsuppl-zeile.
      ls_nsupl-nou         = ls_xsuppl-nou.
      ls_nsupl-keterangan  = ls_xsuppl-description.
      ls_nsupl-zend        = ls_xsuppl-zend.
      ADD 1 TO lv_count.
      CASE lv_count.
        WHEN 1.
          ls_nsupl-csupl1      = ls_xsuppl-value.
        WHEN 2.
          ls_nsupl-csupl2      = ls_xsuppl-value.
        WHEN 3.
          ls_nsupl-csupl3      = ls_xsuppl-value.
      ENDCASE.
    ENDLOOP.
    APPEND ls_nsupl TO ft_nsupl.
    CLEAR : ls_nsupl, lv_count.
  ENDLOOP.
ENDFORM.                    " F_SUPPLIER_DATA

*&---------------------------------------------------------------------*
*&      Form  F_RANGE_LIFNR
*&---------------------------------------------------------------------*
FORM f_range_lifnr  TABLES   ft_lifnr STRUCTURE range_lifnr
                    USING    fu_lifnr.
  DATA : ls_lifnr   TYPE range_lifnr.

  IF fu_lifnr IS NOT INITIAL.
    ls_lifnr-low    = fu_lifnr.
    ls_lifnr-sign   = 'I'.
    ls_lifnr-option = 'EQ'.
    APPEND ls_lifnr TO ft_lifnr.
    CLEAR ls_lifnr.
  ENDIF.
ENDFORM.                    " F_RANGE_LIFNR

*&---------------------------------------------------------------------*
*&      Form  F_SET_CURSOR
*&---------------------------------------------------------------------*
FORM f_set_cursor  USING    fu_field fu_pos.
  SET CURSOR FIELD fu_field LINE fu_pos.
ENDFORM.                    " F_SET_CURSOR

*&---------------------------------------------------------------------*
*&      Form  F_GET_PEMBAYARAN
*&---------------------------------------------------------------------*
FORM f_get_pembayaran  .
  DATA : lt_lfm1    TYPE STANDARD TABLE OF lfm1.

  IF gt_lfa1[] IS NOT INITIAL.
    SELECT *
      FROM lfm1
      INTO CORRESPONDING FIELDS OF TABLE gt_lfm1
      FOR ALL ENTRIES IN gt_lfa1
      WHERE lifnr = gt_lfa1-lifnr
        AND ekorg = 'TNT'
      ORDER BY PRIMARY KEY.

    lt_lfm1[] = gt_lfm1[].
    SORT lt_lfm1 BY zterm.
    DELETE ADJACENT DUPLICATES FROM lt_lfm1 COMPARING zterm.
    IF lt_lfm1[] IS NOT INITIAL.
      SELECT *
        FROM t052u
        INTO CORRESPONDING FIELDS OF TABLE gt_t052u
        FOR ALL ENTRIES IN lt_lfm1
        WHERE spras = sy-langu
          AND zterm = lt_lfm1-zterm
        ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_PEMBAYARAN

*&---------------------------------------------------------------------*
*&      Form  F_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_upload_data USING fu_ucomm.

  CASE fu_ucomm.
    WHEN '&UPLOAD'.
      gv_upload = '1'.
      CALL SCREEN 104 STARTING AT 10 10.

      PERFORM f_alv_refresh USING 'X' 'MAIN'.
      PERFORM f_alv_refresh USING 'X' 'DETL'.

    WHEN '&UPLD'.
      gv_upload = '2'.
      CALL SCREEN 104 STARTING AT 10 10.
  ENDCASE.
ENDFORM.                    " F_UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_UPLOAD_DATA
*&---------------------------------------------------------------------*
FORM f_get_upload_data .
  TYPES : BEGIN OF ty_excel,
            row   LIKE alsmex_tabline-row,
            col   LIKE alsmex_tabline-col,
            value LIKE alsmex_tabline-value,
          END OF ty_excel.

  DATA : lt_excel   TYPE STANDARD TABLE OF ty_excel,
         ls_excel   LIKE LINE OF lt_excel,
         ls_fcat    LIKE LINE OF gt_detl_fieldcat,
         ls_line    TYPE REF TO data,
         ls_vendor  LIKE LINE OF gt_vendor,
         ls_xvendor LIKE LINE OF gt_xvendor.

  DATA : lv_banfn         TYPE eban-banfn,
         lv_bnfpo         TYPE eban-bnfpo,
         lv_datum         TYPE sy-datum,
         lv_fieldname(30),
         lv_tabix         TYPE sy-tabix,
         lv_revis         TYPE ekpo-menge,
         lv_menge         TYPE ekpo-menge,
         lv_trevis        TYPE ekpo-menge,
         lv_tmenge        TYPE ekpo-menge,
         lv_lifnr         TYPE ekko-lifnr,
         lv_kbetr         TYPE konp-kbetr.

  FIELD-SYMBOLS : <fs>        TYPE any,
                  <fs_ldetl1> TYPE any.

  CREATE DATA ls_line LIKE LINE OF <fs_detl>.
  ASSIGN ls_line->* TO <fs_ldetl1>.

  REFRESH lt_excel. CLEAR lt_excel.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = gv_filename
      i_begin_col             = 1
      i_begin_row             = 2
      i_end_col               = 75
      i_end_row               = 65000
    TABLES
      intern                  = lt_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  SORT lt_excel BY row col.
  LOOP AT lt_excel INTO ls_excel.
    READ TABLE gt_detl_fieldcat INTO ls_fcat WITH KEY col_pos = ls_excel-col.
    IF sy-subrc = 0.
      CASE ls_fcat-inttype.
        WHEN 'D'.
          ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_ldetl1> TO <fs>.
          CONCATENATE ls_excel-value+6(4) ls_excel-value+3(2) ls_excel-value(2)
          INTO <fs>.
        WHEN OTHERS.
          CASE ls_fcat-fieldname.
            WHEN 'MEINS'.
              PERFORM f_conversion_cunit CHANGING ls_excel-value.
          ENDCASE.

          IF ls_fcat-qfieldname IS NOT INITIAL.
            TRANSLATE ls_excel-value USING '. '.
            TRANSLATE ls_excel-value USING ',.'.
            CONDENSE ls_excel-value NO-GAPS.
          ENDIF.

          ASSIGN COMPONENT ls_fcat-fieldname OF STRUCTURE <fs_ldetl1> TO <fs>.
          <fs> = ls_excel-value.
          IF ls_fcat-fieldname(5) = 'REVIS'.
            ADD ls_excel-value TO lv_trevis.
          ENDIF.
      ENDCASE.

      CASE ls_fcat-fieldname.
        WHEN 'BANFN'.
          lv_banfn  = ls_excel-value.
        WHEN 'BNFPO'.
          lv_bnfpo  = ls_excel-value.
        WHEN 'MENGE'.
          lv_menge = ls_excel-value.
        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    AT END OF row.
      READ TABLE <fs_detl> ASSIGNING <fs_ldetl>
                           WITH KEY ('BANFN') = lv_banfn
                                    ('BNFPO') = lv_bnfpo.
      IF sy-subrc = 0.
        lv_tabix  = sy-tabix.
        ASSIGN COMPONENT 'ICON' OF STRUCTURE <fs_ldetl1> TO <fs>.
        IF lv_trevis <> 0.
          IF lv_trevis > lv_menge.
            PERFORM f_store_message USING '1' 'Qty Revisi greater than Qty Requested'.
            <fs> = icon_led_red.
          ELSEIF lv_trevis < lv_menge.
            PERFORM f_store_message USING '2' 'Qty Revisi less than Qty Requested'.
            <fs> = icon_led_yellow.
          ELSE.
            PERFORM f_store_message USING '' ''.
            <fs> = icon_led_green.
          ENDIF.
        ELSE.
          CLEAR <fs>.
        ENDIF.
        MODIFY <fs_detl> FROM <fs_ldetl1> INDEX lv_tabix.
      ELSE.
      ENDIF.
      CLEAR : lv_trevis, lv_menge.
    ENDAT.
  ENDLOOP.

  LOOP AT <fs_main> ASSIGNING <fs_lmain>.
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
    lv_lifnr = <fs>.
    CONCATENATE 'REVIS' lv_lifnr INTO lv_fieldname.
    CLEAR : lv_trevis, lv_tmenge.
    LOOP AT <fs_detl> ASSIGNING <fs_ldetl>.
      ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_ldetl> TO <fs>.
      lv_banfn = <fs>.
      ASSIGN COMPONENT 'BNFPO' OF STRUCTURE <fs_ldetl> TO <fs>.
      lv_bnfpo = <fs>.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldetl> TO <fs>.
      lv_revis = <fs>.
      ADD lv_revis TO lv_trevis.
      ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_ldetl> TO <fs>.
      lv_menge = <fs>.
      ADD lv_menge TO lv_tmenge.

      PERFORM f_temp_data USING 'VENDOR' lv_banfn lv_bnfpo
                                lv_lifnr '' '' '' lv_revis.
      CLEAR : lv_revis, lv_menge.
    ENDLOOP.

    ASSIGN COMPONENT 'REVIS' OF STRUCTURE <fs_lmain> TO <fs>.
    <fs> = lv_trevis.
    lv_kbetr = ( lv_trevis / lv_tmenge ) * 100.
    ASSIGN COMPONENT 'KBETR1' OF STRUCTURE <fs_lmain> TO <fs>.
    <fs> = lv_kbetr.
  ENDLOOP.
ENDFORM.                    " F_GET_UPLOAD_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_OUTSTANDING_DELIVERY
*&---------------------------------------------------------------------*
FORM f_get_outstanding_delivery .
  DATA : lt_yekko TYPE STANDARD TABLE OF ekko,
         ls_yekko LIKE LINE OF lt_yekko,
         ls_xekko LIKE LINE OF gt_xekko,
         ls_xekpo LIKE LINE OF gt_xekpo,
         ls_xeket LIKE LINE OF gt_xeket,
         ls_sekko LIKE LINE OF gt_sekko.

  DATA : lv_menge   TYPE ekpo-menge.

  lt_yekko[] = gt_xekko[].
  SORT lt_yekko BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_yekko COMPARING lifnr.
  IF lt_yekko[] IS NOT INITIAL.
    LOOP AT lt_yekko INTO ls_yekko.
      ls_sekko-lifnr    = ls_yekko-lifnr.
      LOOP AT gt_xekko INTO ls_xekko WHERE lifnr = ls_yekko-lifnr.
        LOOP AT gt_xekpo INTO ls_xekpo WHERE ebeln = ls_xekko-ebeln.
          IF ls_xekpo-elikz IS INITIAL.
            ls_sekko-meins    = ls_xekpo-meins.
            LOOP AT gt_xeket INTO ls_xeket WHERE ebeln = ls_xekpo-ebeln
                                             AND ebelp = ls_xekpo-ebelp.
              lv_menge  = ls_xeket-menge - ls_xeket-wemng.
              ADD lv_menge TO ls_sekko-menge.
              ADD ls_xeket-menge TO ls_sekko-total.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
      APPEND ls_sekko TO gt_sekko.
      CLEAR ls_sekko.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_OUTSTANDING_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_LAMPIRAN
*&---------------------------------------------------------------------*
FORM f_prepare_lampiran .
  DATA : lt_xdetls TYPE STANDARD TABLE OF zgdmmst0056,
         ls_heads  LIKE LINE OF gt_heads,
         ls_detls  LIKE LINE OF gt_detls,
         ls_texts  LIKE LINE OF gt_texts,
         ls_palloc LIKE LINE OF gt_palloc,
         ls_xsuppl LIKE LINE OF gt_xsuppl,
         lt_text   TYPE STANDARD TABLE OF ty_text,
         ls_text   LIKE LINE OF lt_text.

  DATA : lv_fieldname(30),
         lv_tdname        TYPE thead-tdname,
         lv_revis         TYPE ekpo-menge,
         lv_total         TYPE ekpo-menge,
         lv_menge         TYPE ekpo-menge,
         lv_subrc         TYPE sy-subrc,
         lv_subrc1        TYPE sy-subrc,
         lv_percen        TYPE konp-kbetr.

  DATA : lv_vrsio   TYPE zgdmmt004z-vrsio.

  FIELD-SYMBOLS <fs>    TYPE any.

  CLEAR : gt_heads[], gt_detls[], gt_heads, gt_detls,
          gt_texts[], gt_texts, gt_total[], gt_total.

  LOOP AT <fs_main> ASSIGNING <fs_lmain>.
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_heads-lifnr  = <fs>.
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_heads-name1  = <fs>.
    ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_heads-meins  = <fs>.

    lv_subrc  = 4.
    LOOP AT <fs_detl> ASSIGNING <fs_ldetl>.
      CONCATENATE 'REVIS' ls_heads-lifnr INTO lv_fieldname.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldetl> TO <fs>.
      lv_revis  = <fs>.
      ls_detls-lifnr  = ls_heads-lifnr.
      ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_detls-banfn  = <fs>.
      ASSIGN COMPONENT 'EINDT' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_detls-eindt  = <fs>.
      ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_detls-menge  = <fs>.
      ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_detls-meins  = <fs>.
      WRITE ls_detls-menge TO ls_detls-menget UNIT ls_detls-meins.
      CONDENSE ls_detls-menget NO-GAPS.
      WRITE lv_revis TO ls_detls-alloct UNIT ls_detls-meins.
      CONDENSE ls_detls-alloct NO-GAPS.
      lv_percen = ( lv_revis / ls_detls-menge ) * 100.
      WRITE lv_percen TO ls_detls-kbetrt DECIMALS 2.
      CONDENSE ls_detls-kbetrt NO-GAPS.
      ADD lv_revis TO lv_total.
      ADD ls_detls-menge TO lv_menge.
*      IF lv_revis IS INITIAL.
*        CONTINUE.
*      ENDIF.

      APPEND ls_detls TO gt_detls.
      CLEAR : ls_detls, lv_subrc.
    ENDLOOP.

    IF lv_subrc IS INITIAL.
      WRITE lv_total TO ls_heads-totalt UNIT ls_heads-meins.
      CONDENSE ls_heads-totalt NO-GAPS.
      lv_percen = ( lv_total / lv_menge ) * 100.
      WRITE lv_percen TO ls_heads-kbetrt DECIMALS 2.
      CONDENSE ls_heads-kbetrt NO-GAPS.
      WRITE lv_menge TO ls_heads-menget UNIT ls_heads-meins.
      CONDENSE ls_heads-menget NO-GAPS.

      CLEAR ls_palloc.
      READ TABLE gt_palloc INTO ls_palloc
                           WITH KEY lifnr = ls_heads-lifnr.
      IF sy-subrc = 0.
        CONCATENATE ls_palloc-description ':' ls_palloc-value
        INTO ls_heads-percen
        SEPARATED BY space.
      ENDIF.
      CLEAR ls_xsuppl.
      READ TABLE gt_xsuppl INTO ls_xsuppl
                           WITH KEY lifnr = ls_heads-lifnr
                                    nou   = '5'.
      IF sy-subrc = 0.
        ls_heads-preist = ls_xsuppl-value.
      ENDIF.
      APPEND ls_heads TO gt_heads.
    ENDIF.

    lv_subrc1 = 4.

    CASE gv_trtyp.
      WHEN 'H'.
        CONCATENATE pa_submi gs_head-vrsio ls_heads-lifnr INTO lv_tdname.
        LOOP AT gt_text INTO ls_text WHERE head-tdname = lv_tdname.
          ls_texts-lifnr    = ls_heads-lifnr.
          ls_texts-lines    = ls_text-line.
          APPEND ls_texts TO gt_texts.
          CLEAR : ls_texts, lv_subrc1.
        ENDLOOP.
      WHEN 'A' OR 'V'.
        lv_vrsio  = gs_head-vrsio.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vrsio
          IMPORTING
            output = lv_vrsio.
        IF pa_zalno IS INITIAL.
          CONCATENATE pa_submi lv_vrsio ls_heads-lifnr INTO lv_tdname.
        ELSE.
          CONCATENATE pa_submi pa_zalno lv_vrsio ls_heads-lifnr INTO lv_tdname.
        ENDIF.
        PERFORM f_read_text TABLES lt_text
                            USING  lv_tdname.
        LOOP AT lt_text INTO ls_text.
          ls_texts-lifnr    = ls_heads-lifnr.
          ls_texts-lines    = ls_text-line.
          APPEND ls_texts TO gt_texts.
          CLEAR : ls_texts, lv_subrc1.
        ENDLOOP.
        CLEAR lt_text[].
    ENDCASE.

    IF lv_subrc IS NOT INITIAL.
      IF lv_subrc1 IS INITIAL.
        APPEND ls_heads TO gt_heads.
      ENDIF.
    ENDIF.
    CLEAR : ls_heads, lv_total, lv_menge.
  ENDLOOP.

  PERFORM f_purchase_order_data.
ENDFORM.                    " F_PREPARE_LAMPIRAN

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LAMPIRAN
*&---------------------------------------------------------------------*
FORM f_print_lampiran  USING    fu_ucomm fu_close fu_open fu_nodialog fu_mail.
  DATA : ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop.

  DATA : lv_vrsio     TYPE zgdmmt004z-vrsio.

  p_tdform        = 'ZHSMMMSF002'.
  gs_header-prgrp = pa_prgrp.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_open  = fu_open.
  d_ctrl_param-no_close = fu_close.

  CASE fu_ucomm.
    WHEN '&POS'.
      d_output_opt-tdnoprev     = 'X'.
      d_ctrl_param-no_dialog    = fu_nodialog.
      d_ctrl_param-preview      = space.
      d_ctrl_param-getotf       = 'X'.
    WHEN '&PREV'.
      d_output_opt-tdnoprint    = 'X'.
  ENDCASE.

  CALL FUNCTION d_smrt_funcmod
    EXPORTING
      control_parameters = d_ctrl_param
      output_options     = d_output_opt
      user_settings      = space
      t_header           = gs_header
    IMPORTING
      job_output_info    = ls_info
      job_output_options = ls_options
    TABLES
      gt_heads           = gt_heads
      gt_detls           = gt_detls
      gt_texts           = gt_texts
      gt_lfa1            = gt_lfa1
      gt_total           = gt_total
      gt_xsuppl          = gt_xsuppl.

  IF fu_mail IS NOT INITIAL.
    PERFORM f_send_mail USING ls_info ls_options ''.
  ELSE.
    CASE gv_trtyp.
      WHEN 'A' OR 'V'.
        lv_vrsio  = gs_head-vrsio.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vrsio
          IMPORTING
            output = lv_vrsio.

        PERFORM f_send_mail USING ls_info ls_options lv_vrsio.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_PRINT_LAMPIRAN

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data CHANGING fc_subrc fc_message.
  DATA : oref      TYPE REF TO cx_root,
         lv_tdname TYPE thead-tdname.

  DATA : ls_lfa1 LIKE LINE OF gt_lfa1,
         lt_text TYPE STANDARD TABLE OF ty_text,
         ls_text LIKE LINE OF lt_text.

  DATA : header   TYPE thead,
         lines    TYPE STANDARD TABLE OF tline,
         ls_lines LIKE LINE OF lines.

  DATA : ls_04z LIKE LINE OF gt_04z,
         ls_006 LIKE LINE OF gt_006,
         ls_007 LIKE LINE OF gt_007.

  CLEAR fc_subrc.

  IF gs_x04z IS NOT INITIAL.
*    DELETE FROM zgdmmt004x WHERE zalno = gs_x04z-zalno.
*    DELETE FROM zgdmmt004y WHERE zalno = gs_x04z-zalno.
*    DELETE FROM zgdmmt004z WHERE zalno = gs_x04z-zalno.
*    DELETE FROM zgdmmt004c WHERE zalno = gs_x04z-zalno.
    DELETE FROM zgdmmt004p WHERE zalno = gs_x04z-zalno.
    IF gt_006[] IS NOT INITIAL.
      DELETE FROM zhsmmmdt006 WHERE zalno = gs_x04z-zalno.
    ENDIF.
    IF gt_007[] IS NOT INITIAL.
      DELETE FROM zhsmmmdt007 WHERE zalno = gs_x04z-zalno.
    ENDIF.
    COMMIT WORK AND WAIT.

    LOOP AT gt_lfa1 INTO ls_lfa1.
      IF ls_lfa1-modif IS INITIAL.
        CONTINUE.
      ENDIF.
      IF gs_header-zalno IS INITIAL.
        CONCATENATE gs_x04z-submi gs_head-vrsio ls_lfa1-lifnr
        INTO lv_tdname.
      ELSE.
        CONCATENATE gs_x04z-submi gs_header-zalno gs_head-vrsio ls_lfa1-lifnr
        INTO lv_tdname.
      ENDIF.

      CALL FUNCTION 'DELETE_TEXT'
        EXPORTING
          id        = 'ST'
          language  = sy-langu
          name      = lv_tdname
          object    = 'TEXT'
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
    ENDLOOP.
  ELSE.
    LOOP AT gt_lfa1 INTO ls_lfa1.
      CONCATENATE gs_head-submi gs_head-vrsio ls_lfa1-lifnr
      INTO lv_tdname.

      CALL FUNCTION 'DELETE_TEXT'
        EXPORTING
          id        = 'ST'
          language  = sy-langu
          name      = lv_tdname
          object    = 'TEXT'
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
    ENDLOOP.
  ENDIF.

  LOOP AT gt_lfa1 INTO ls_lfa1.
    IF gs_x04z IS INITIAL.
      CONCATENATE pa_submi gs_head-vrsio ls_lfa1-lifnr
      INTO lv_tdname.
    ELSE.
      CONCATENATE pa_submi gs_header-zalno gs_head-vrsio ls_lfa1-lifnr
      INTO lv_tdname.
    ENDIF.

    LOOP AT gt_text INTO ls_text WHERE head-tdname = lv_tdname.
      ls_text-head-tdobject  = 'TEXT'.
      CONCATENATE pa_submi gs_header-zalno gs_head-vrsio ls_lfa1-lifnr
      INTO lv_tdname.
      ls_text-head-tdname    = lv_tdname.
      ls_text-head-tdid      = 'ST'.
      ls_text-head-tdspras   = sy-langu.
      ls_text-head-tdform    = 'SYSTEM'.

      ls_lines-tdline        = ls_text-line.
      APPEND ls_lines TO lines.
      CLEAR ls_lines.
    ENDLOOP.

    IF lines[] IS INITIAL.
      IF gs_header-zalno IS INITIAL.
        CONCATENATE pa_submi gs_head-vrsio ls_lfa1-lifnr
        INTO lv_tdname.
      ELSE.
        CONCATENATE pa_submi gs_header-zalno gs_head-vrsio ls_lfa1-lifnr
        INTO lv_tdname.
      ENDIF.

      PERFORM f_read_text TABLES lt_text
                          USING  lv_tdname.

      LOOP AT lt_text INTO ls_text WHERE head-tdname = lv_tdname.
        ls_text-head-tdobject  = 'TEXT'.
        ls_text-head-tdname    = lv_tdname.
        ls_text-head-tdid      = 'ST'.
        ls_text-head-tdspras   = sy-langu.
        ls_text-head-tdform    = 'SYSTEM'.

        ls_lines-tdline        = ls_text-line.
        APPEND ls_lines TO lines.
        CLEAR ls_lines.
      ENDLOOP.
    ENDIF.

    IF lines[] IS NOT INITIAL.
      CALL FUNCTION 'SAVE_TEXT'
        EXPORTING
          header   = ls_text-head
        TABLES
          lines    = lines
        EXCEPTIONS
          id       = 1
          language = 2
          name     = 3
          object   = 4
          OTHERS   = 5.
    ENDIF.

    CLEAR : lines[], lines, ls_text.
  ENDLOOP.

  IF fc_message IS INITIAL.
    TRY .
        MODIFY zgdmmt004y FROM TABLE gt_04y.
      CATCH cx_sy_open_sql_db INTO oref.
*        fc_message = oref->get_text( ).
        fc_message = 'Error when Item overview modify'.
    ENDTRY.
  ENDIF.

  IF fc_message IS INITIAL.
    TRY .
        MODIFY zgdmmt004x FROM TABLE gt_04x.
      CATCH cx_sy_open_sql_db INTO oref.
*        fc_message = oref->get_text( ).
        fc_message = 'Error when Item detail modify'.
    ENDTRY.
  ENDIF.

  IF fc_message IS INITIAL.
    TRY .
        MODIFY zgdmmt004z FROM TABLE gt_04z.
      CATCH cx_sy_open_sql_db INTO oref.
*        fc_message = oref->get_text( ).
        fc_message = 'Error when Header modify'.
    ENDTRY.
  ENDIF.

  IF fc_message IS INITIAL.
    TRY .
        MODIFY zgdmmt004c FROM TABLE gt_04c.
      CATCH cx_sy_open_sql_db INTO oref.
*        fc_message = oref->get_text( ).
        fc_message = 'Error when Allocation form modify'.
    ENDTRY.
  ENDIF.

  IF fc_message IS INITIAL.
    TRY .
        INSERT zgdmmt004p FROM TABLE gt_04p.
      CATCH cx_sy_open_sql_db INTO oref.
*        fc_message = oref->get_text( ).
        fc_message = 'Error when Split PO modify'.
    ENDTRY.
  ENDIF.

  IF gs_x04z-submi IS INITIAL.
    CLEAR ls_04z.
    READ TABLE gt_04z INTO ls_04z INDEX 1.
    LOOP AT gt_006 INTO ls_006.
      ls_006-submi = ls_04z-submi.
      MODIFY gt_006 FROM ls_006 TRANSPORTING submi.
    ENDLOOP.
    LOOP AT gt_007 INTO ls_007.
      ls_007-submi = ls_04z-submi.
      MODIFY gt_007 FROM ls_007 TRANSPORTING submi.
    ENDLOOP.
  ENDIF.

  SORT gt_006 BY prgrp submi zalno banfn matnr zeile.
  DELETE ADJACENT DUPLICATES FROM gt_006
  COMPARING prgrp submi zalno banfn matnr zeile.
  IF gt_006[] IS NOT INITIAL.
    IF fc_message IS INITIAL.
      TRY .
          INSERT zhsmmmdt006 FROM TABLE gt_006.
        CATCH cx_sy_open_sql_db INTO oref.
*        fc_message = oref->get_text( ).
          fc_message = 'Error when Product Group/Material'.
      ENDTRY.
    ENDIF.
  ENDIF.

  SORT gt_007 BY prgrp submi zalno lifnr ebeln matnr zeile.
  DELETE ADJACENT DUPLICATES FROM gt_007
  COMPARING prgrp submi zalno lifnr ebeln matnr zeile.
  IF gt_007[] IS NOT INITIAL.
    IF fc_message IS INITIAL.
      TRY .
          INSERT zhsmmmdt007 FROM TABLE gt_007.
        CATCH cx_sy_open_sql_db INTO oref.
*        fc_message = oref->get_text( ).
          fc_message = 'Error when Product Group/Vendor'.
      ENDTRY.
    ENDIF.
  ENDIF.

  IF fc_message IS INITIAL.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    fc_subrc    = 4.
  ENDIF.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_SEND_MAIL
*&---------------------------------------------------------------------*
FORM f_send_mail  USING    ls_info      TYPE ssfcrescl
                           ls_options   TYPE ssfcresop
                           fu_vrsio.

  DATA : lt_otf          TYPE TABLE OF itcoo,
         lt_lines        TYPE TABLE OF tline,
         lv_xstring      TYPE xstring,
         lv_objlen       TYPE sood-objlen,
         lt_objbin       TYPE TABLE OF solix,
         lv_text         TYPE string,
         lt_message_body TYPE bcsy_text,
         lv_subject      TYPE so_obj_des,
         ls_document_bcs TYPE REF TO cx_document_bcs,
         lv_sent_to_all  TYPE os_boolean,
         lv_zalno(10),
         lv_filepath     TYPE string VALUE '/eprocurement',
         lv_filename     TYPE string,
         lv_path         TYPE string,
         lv_fullpath     TYPE string,
         ls_data         LIKE LINE OF lt_objbin,
         ls_05           LIKE LINE OF gt_05,
         lv_to           TYPE bapiadsmtp-e_mail,
         lv_cc           TYPE bapiadsmtp-e_mail,
         addsmtp         TYPE STANDARD TABLE OF bapiadsmtp,
         return          TYPE STANDARD TABLE OF bapiret2,
         ls_addsmtp      LIKE LINE OF addsmtp.

  DATA : lo_send_request TYPE REF TO cl_bcs,
         lo_document     TYPE REF TO cl_document_bcs,
         lo_sender       TYPE REF TO if_sender_bcs,
         lo_recipient    TYPE REF TO if_recipient_bcs VALUE IS INITIAL,
         lo_gui_services TYPE REF TO cl_gui_frontend_services.

  IF gv_mail IS NOT INITIAL.
    CLEAR : lt_otf[], lt_lines[].
    lt_otf[] = ls_info-otfdata[].
    IF lt_otf[] IS NOT INITIAL.
      CALL FUNCTION 'CONVERT_OTF'
        EXPORTING
          format                = 'PDF'
          max_linewidth         = 132
        IMPORTING
          bin_filesize          = lv_objlen
          bin_file              = lv_xstring
        TABLES
          otf                   = lt_otf
          lines                 = lt_lines
        EXCEPTIONS
          err_max_linewidth     = 1
          err_format            = 2
          err_conv_not_possible = 3
          OTHERS                = 4.

      CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
        EXPORTING
          buffer     = lv_xstring
        TABLES
          binary_tab = lt_objbin[].

      " create file to server
      IF gs_header-zalno IS INITIAL.
        gs_header-zalno = gs_x04z-zalno.
      ENDIF.

      IF fu_vrsio IS NOT INITIAL.
        gs_header-vrsio   = fu_vrsio.
      ENDIF.

      CONCATENATE gs_header-zalno gs_header-vrsio '.pdf' INTO lv_filename.
      CONCATENATE lv_filepath '/' lv_filename INTO lv_filename.
      OPEN DATASET lv_filename FOR OUTPUT IN BINARY MODE.
      IF sy-subrc = 0.
        LOOP AT lt_objbin INTO ls_data.
          TRANSFER ls_data TO lv_filename.
        ENDLOOP.
      ENDIF.
      CLOSE DATASET lv_filename.
*    PERFORM f_change_filemode USING lv_filename.
    ENDIF.

    IF fu_vrsio IS INITIAL.
      "create send request
      lo_send_request = cl_bcs=>create_persistent( ).

      "create message body
      CLEAR :  lt_message_body[].
      CONCATENATE 'Please approve Form Allocation No.' gs_header-zalno
      INTO lv_text
      SEPARATED BY space.
      APPEND lv_text TO lt_message_body.
      CONCATENATE 'Plant :' so_werks-low
      INTO lv_text
      SEPARATED BY space.
      APPEND lv_text TO lt_message_body.
      CONCATENATE 'Material :' so_matnr-low
      INTO lv_text
      SEPARATED BY space.
      APPEND lv_text TO lt_message_body.

      APPEND INITIAL LINE TO lt_message_body.

      lv_text = 'To approve please login to your SAP System and'.
      APPEND lv_text TO lt_message_body.
      APPEND INITIAL LINE TO lt_message_body.

      lv_text = 'go to Transaction Code : ZMME013'.
      APPEND lv_text TO lt_message_body.
      APPEND INITIAL LINE TO lt_message_body.

      "create subject
      lv_zalno  = gs_header-zalno.
      SHIFT lv_zalno LEFT DELETING LEADING '0'.
      CONCATENATE 'Appr.for' lv_zalno
      INTO lv_subject
      SEPARATED BY space.
      CONCATENATE lv_subject 'Material' so_matnr-low
      INTO lv_subject
      SEPARATED BY space.
      CONCATENATE lv_subject '- Plant' so_werks-low
      INTO lv_subject
      SEPARATED BY space.

      lo_document = cl_document_bcs=>create_document(
      i_type = 'RAW'
      i_text = lt_message_body
      i_subject = lv_subject ).

      TRY.
          lo_document->add_attachment(
          EXPORTING
          i_attachment_type    = 'PDF'
          i_attachment_subject = lv_subject
          i_att_content_hex    = lt_objbin[] ).
        CATCH cx_document_bcs INTO ls_document_bcs.
      ENDTRY.

      lo_send_request->set_document( lo_document ).

      lo_sender = cl_sapuser_bcs=>create( sy-uname ).

      lo_send_request->set_sender( lo_sender ).

      CLEAR lo_recipient.
* Add To
      READ TABLE gt_05 INTO ls_05
                       WITH KEY srno1 = 1.
      lv_to = ls_05-smtp_addr.
      IF lv_to IS NOT INITIAL.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                       i_address_string = lv_to ).
*        lo_recipient = cl_cam_address_bcs=>create_internet_address( 'sekar.mulya@thetempogroup.com' ).
        lo_send_request->add_recipient( i_recipient  = lo_recipient ).
      ENDIF.

* Add CC
      CALL FUNCTION 'BAPI_USER_GET_DETAIL'
        EXPORTING
          username = sy-uname
        TABLES
          return   = return
          addsmtp  = addsmtp.

      READ TABLE addsmtp INTO ls_addsmtp INDEX 1.
      IF sy-subrc = 0.
        lv_cc  = ls_addsmtp-e_mail.
      ENDIF.
      IF lv_cc IS NOT INITIAL.
        lo_recipient = cl_cam_address_bcs=>create_internet_address(
                       i_address_string = lv_cc ).
        lo_send_request->add_recipient( i_recipient  = lo_recipient
                                        i_copy       = 'X').
      ENDIF.

      lo_send_request->send(
      EXPORTING
      i_with_error_screen = abap_true
      RECEIVING
      result = lv_sent_to_all ).
    ENDIF.
  ENDIF.

  COMMIT WORK.
ENDFORM.                    " F_SEND_MAIL

*&---------------------------------------------------------------------*
*&      Form  F_04X
*&---------------------------------------------------------------------*
FORM f_04x  USING    fu_zalno.
  DATA : ls_04x     LIKE LINE OF gt_04x.

  FIELD-SYMBOLS <fs>  TYPE any.

  LOOP AT <fs_main> ASSIGNING <fs_lmain>.
    ls_04x-zalno    = fu_zalno.
    ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-lifnr = <fs>.
    ls_04x-matnr = gs_head-matnr.
    ls_04x-maktx = gs_head-maktx.
    ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-name1 = <fs>.
    ASSIGN COMPONENT 'MFRPN' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-mfrpn = <fs>.
    ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-ebeln = <fs>.
    ASSIGN COMPONENT 'NETPR' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-netpr = <fs>.
    ASSIGN COMPONENT 'WAERS' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-waers = <fs>.
    ASSIGN COMPONENT 'BOBOT' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-bobot = <fs>.
    ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-etmen = <fs>.
    ASSIGN COMPONENT 'ALLOC' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-bamng = <fs>.
    ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-bamei = <fs>.
    ASSIGN COMPONENT 'KBETR' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-kbetr = <fs>.
    ASSIGN COMPONENT 'REVIS' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-menge = <fs>.
    ASSIGN COMPONENT 'KBETR1' OF STRUCTURE <fs_lmain> TO <fs>.
    ls_04x-kbet1 = <fs>.
    APPEND ls_04x TO gt_04x.
    CLEAR ls_04x.
  ENDLOOP.
ENDFORM.                    " F_04X

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_POPUP
*&---------------------------------------------------------------------*
FORM f_display_popup  USING    fu_ebeln fu_meins.
  DATA : lt_list      TYPE STANDARD TABLE OF zhsmmmst003.

  DATA : ls_eket     LIKE LINE OF gt_eket,
         ls_list     LIKE LINE OF lt_list,
         ls_selfield TYPE slis_selfield,
         lv_exit.

  LOOP AT gt_eket INTO ls_eket WHERE ebeln = fu_ebeln.
    ls_list-ebeln = ls_eket-ebeln.
    ls_list-ebelp = ls_eket-ebelp.
    WRITE ls_eket-eindt TO ls_list-eeind DD/MM/YYYY.
    ls_list-menge = ls_eket-menge.
    ls_list-meins = fu_meins.
    APPEND ls_list TO lt_list.
    CLEAR ls_list.
  ENDLOOP.

  IF lt_list[] IS NOT INITIAL.
    CALL FUNCTION 'REUSE_ALV_POPUP_TO_SELECT'
      EXPORTING
        i_title                 = 'Schedule List'
        i_selection             = space
        i_allow_no_selection    = 'X'
        i_zebra                 = 'X'
        i_screen_start_column   = 2
        i_screen_start_line     = 2
        i_screen_end_column     = 150
        i_screen_end_line       = 15
        i_tabname               = 'LT_LIST'
        i_structure_name        = 'ZHSMMMST003'
        i_callback_program      = gv_repid
        i_callback_user_command = 'F_CALLBACK_USER_COMMAND'
      IMPORTING
        es_selfield             = ls_selfield
        e_exit                  = lv_exit
      TABLES
        t_outtab                = lt_list
      EXCEPTIONS
        program_error           = 1
        OTHERS                  = 2.
  ENDIF.
ENDFORM.                    " F_DISPLAY_POPUP

*&---------------------------------------------------------------------*
*&      Form  F_F4_SUBMI
*&---------------------------------------------------------------------*
FORM f_f4_submi  CHANGING fc_submi.

ENDFORM.                    " F_F4_SUBMI

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TEXT_EDITOR
*&---------------------------------------------------------------------*
FORM f_create_text_editor .
  CONSTANTS : line_length TYPE i VALUE 100.

  CREATE OBJECT editor_container
    EXPORTING
      container_name              = 'TEXTEDITOR'
    EXCEPTIONS
      cntl_error                  = 1
      cntl_system_error           = 2
      create_error                = 3
      lifetime_error              = 4
      lifetime_dynpro_dynpro_link = 5
      OTHERS                      = 6.

  CREATE OBJECT text_editor
    EXPORTING
      wordwrap_mode              = cl_gui_textedit=>wordwrap_at_fixed_position
      wordwrap_position          = line_length
      wordwrap_to_linebreak_mode = cl_gui_textedit=>true
      parent                     = editor_container.

  CALL METHOD text_editor->set_toolbar_mode
    EXPORTING
      toolbar_mode = cl_gui_textedit=>false.

  CALL METHOD text_editor->set_statusbar_mode
    EXPORTING
      statusbar_mode = cl_gui_textedit=>false.
ENDFORM.                    " F_CREATE_TEXT_EDITOR

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_TEXT
*&---------------------------------------------------------------------*
FORM f_save_text .
  DATA : lt_stext TYPE TABLE OF string,
         ls_stext LIKE LINE OF lt_stext,
         lt_text  TYPE STANDARD TABLE OF ty_text,
         ls_text  LIKE LINE OF lt_text,
         ls_lfa1  LIKE LINE OF gt_lfa1.

  DATA : header   TYPE thead,
         lines    TYPE STANDARD TABLE OF tline,
         ls_lines LIKE LINE OF lines.

  DATA : tab,
         cr,
         new,
         lv_tdname TYPE thead-tdname,
         lv_vrsio  TYPE zgdmmt004z-vrsio.

  tab = cl_abap_char_utilities=>horizontal_tab.
  cr  = cl_abap_char_utilities=>cr_lf.
  new = cl_abap_char_utilities=>newline.

  PERFORM f_get_text.
  PERFORM f_clear_text.

  CASE gv_trtyp.
    WHEN 'H'.
      lv_vrsio  = gs_head-vrsio.
    WHEN 'A' OR 'V'.
      lv_vrsio  = gs_head-vrsio.
  ENDCASE.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = lv_vrsio
    IMPORTING
      output = lv_vrsio.

  IF pa_zalno IS INITIAL.
    CONCATENATE gs_head-submi lv_vrsio gs_quot-lifnr INTO lv_tdname.
  ELSE.
    CONCATENATE gs_head-submi pa_zalno lv_vrsio gs_quot-lifnr INTO lv_tdname.
    ls_lfa1-modif = 'X'.
    MODIFY gt_lfa1 FROM ls_lfa1
                   TRANSPORTING modif
                   WHERE lifnr = gs_quot-lifnr.
  ENDIF.

  SPLIT text AT cr INTO TABLE lt_stext.
  DELETE gt_text WHERE head-tdname = lv_tdname.
  LOOP AT lt_stext INTO ls_stext.
    REPLACE new IN ls_stext WITH space.
    REPLACE cr IN ls_stext WITH space.

    ls_text-head-tdobject  = 'TEXT'.
    ls_text-head-tdname    = lv_tdname.
    ls_text-head-tdid      = 'ST'.
    ls_text-head-tdspras   = sy-langu.
    ls_text-head-tdform    = 'SYSTEM'.
    ls_text-line           = ls_stext.
    APPEND ls_text TO gt_text.
    CLEAR ls_text.

    ls_lines-tdline        = ls_stext.
    APPEND ls_lines TO lines.
    CLEAR ls_lines.
  ENDLOOP.

  ls_text-head-tdobject  = 'TEXT'.
  ls_text-head-tdname    = lv_tdname.
  ls_text-head-tdid      = 'ST'.
  ls_text-head-tdspras   = sy-langu.
  ls_text-head-tdform    = 'SYSTEM'.

  CALL FUNCTION 'SAVE_TEXT'
    EXPORTING
      header   = ls_text-head
    TABLES
      lines    = lines
    EXCEPTIONS
      id       = 1
      language = 2
      name     = 3
      object   = 4
      OTHERS   = 5.

  PERFORM f_set_blank.
  PERFORM f_length_check.
ENDFORM.                    " F_SAVE_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXT
*&---------------------------------------------------------------------*
FORM f_get_text .
  CALL METHOD text_editor->get_textstream
    IMPORTING
      text                   = text
    EXCEPTIONS
      error_cntl_call_method = 1
      not_supported_by_gui   = 2
      OTHERS                 = 3.
ENDFORM.                    " F_GET_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_CLEAR_TEXT
*&---------------------------------------------------------------------*
FORM f_clear_text .
  CALL METHOD cl_gui_cfw=>flush
    EXCEPTIONS
      cntl_system_error = 1
      cntl_error        = 2
      OTHERS            = 3.
ENDFORM.                    " F_CLEAR_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_SET_BLANK
*&---------------------------------------------------------------------*
FORM f_set_blank .
  DATA : lv_blank TYPE string.

  CALL METHOD text_editor->set_textstream
    EXPORTING
      text                   = lv_blank
    EXCEPTIONS
      error_cntl_call_method = 1
      not_supported_by_gui   = 2
      OTHERS                 = 3.
ENDFORM.                    " F_SET_BLANK

*&---------------------------------------------------------------------*
*&      Form  F_WRITE_TEXT
*&---------------------------------------------------------------------*
FORM f_write_text  TABLES   ft_text TYPE STANDARD TABLE.
  DATA : lt_tdline TYPE TABLE OF tdline,
         ls_text   TYPE ty_text.

  LOOP AT ft_text INTO ls_text.
    APPEND ls_text-line TO lt_tdline.
    CLEAR ls_text.
  ENDLOOP.

  CALL METHOD text_editor->set_text_as_r3table
    EXPORTING
      table = lt_tdline.
ENDFORM.                    " F_WRITE_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_LENGTH_CHECK
*&---------------------------------------------------------------------*
FORM f_length_check .
  DATA : lv_length    TYPE i.

  lv_length = strlen( text ).
  IF lv_length > 255.
*    CLEAR: text_editor.
  ENDIF.
ENDFORM.                    " F_LENGTH_CHECK

*&---------------------------------------------------------------------*
*&      Form  F_DIPLAY_TEXT
*&---------------------------------------------------------------------*
FORM f_diplay_text .
  DATA : lv_tdname TYPE thead-tdname,
         lt_text   TYPE STANDARD TABLE OF ty_text,
         ls_text   LIKE LINE OF lt_text,
         lv_vrsio  TYPE zgdmmt004z-vrsio.

  IF pa_zalno IS INITIAL.
    CONCATENATE gs_head-submi gs_head-vrsio gs_quot-lifnr INTO lv_tdname.
  ELSE.
    CONCATENATE gs_head-submi pa_zalno gs_head-vrsio gs_quot-lifnr INTO lv_tdname.
  ENDIF.

  LOOP AT gt_text INTO ls_text WHERE head-tdname = lv_tdname.
    ls_text-head-tdobject  = 'TEXT'.
    ls_text-head-tdname    = lv_tdname.
    ls_text-head-tdid      = 'ST'.
    ls_text-head-tdspras   = sy-langu.
    ls_text-head-tdform    = 'SYSTEM'.
    ls_text-line           = ls_text-line.
    APPEND ls_text TO lt_text.
    CLEAR ls_text.
  ENDLOOP.

  IF lt_text[] IS INITIAL.
    lv_vrsio  = gs_head-vrsio.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = lv_vrsio
      IMPORTING
        output = lv_vrsio.

    IF pa_zalno IS INITIAL.
      CONCATENATE gs_head-submi lv_vrsio gs_quot-lifnr INTO lv_tdname.
    ELSE.
      CONCATENATE gs_head-submi pa_zalno lv_vrsio gs_quot-lifnr INTO lv_tdname.
    ENDIF.
    PERFORM f_read_text TABLES lt_text
                        USING  lv_tdname.
  ENDIF.

  PERFORM f_write_text TABLES lt_text.

ENDFORM.                    " F_DIPLAY_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_04Y
*&---------------------------------------------------------------------*
FORM f_04y  USING    fu_zalno.
  DATA : ls_04y  TYPE zgdmmt004y,
         ls_04p  TYPE zgdmmt004p,
         ls_lfa1 LIKE LINE OF gt_lfa1.

  DATA : lv_fieldname(30).

  FIELD-SYMBOLS <fs>    TYPE any.

  LOOP AT gt_lfa1 INTO ls_lfa1.
    ls_04y-zalno    = fu_zalno.
    ls_04y-lifnr    = ls_lfa1-lifnr.
    CONCATENATE 'REVIS' ls_lfa1-lifnr INTO lv_fieldname.
    LOOP AT <fs_detl> ASSIGNING <fs_ldetl>.
      ASSIGN COMPONENT 'BANFN' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_04y-banfn  = <fs>.
      ASSIGN COMPONENT 'BNFPO' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_04y-bnfpo  = <fs>.
      ASSIGN COMPONENT 'LGORT' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_04y-lgort  = <fs>.
      ASSIGN COMPONENT 'EINDT' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_04y-lfdat  = <fs>.
      ASSIGN COMPONENT 'MEINS' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_04y-meins  = <fs>.
      ASSIGN COMPONENT 'MENGE' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_04y-menge  = <fs>.
      ASSIGN COMPONENT lv_fieldname OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_04y-bsmng  = <fs>.
      ASSIGN COMPONENT 'FRGDT' OF STRUCTURE <fs_ldetl> TO <fs>.
      ls_04y-frgdt  = <fs>.

      READ TABLE gt_04p INTO ls_04p
                        WITH KEY lifnr = ls_04y-lifnr
                                 banfn = ls_04y-banfn
                                 bnfpo = ls_04y-bnfpo.
      IF sy-subrc <> 0.
        ls_04p-zalno    = fu_zalno.
        ls_04p-lifnr    = ls_04y-lifnr.
        ls_04p-banfn    = ls_04y-banfn.
        ls_04p-bnfpo    = ls_04y-bnfpo.
        ls_04p-lgort    = ls_04y-lgort.
        ls_04p-zeile    = 1.
        ls_04p-meins    = ls_04y-meins.
        ls_04p-menge    = ls_04y-bsmng.
        APPEND ls_04p TO gt_04p.
        CLEAR ls_04p.
      ENDIF.

      APPEND ls_04y TO gt_04y.
      CLEAR ls_04y-bsmng.
    ENDLOOP.
    CLEAR ls_04y.
  ENDLOOP.
ENDFORM.                    " F_04Y

*&---------------------------------------------------------------------*
*&      Form  F_04Z
*&---------------------------------------------------------------------*
FORM f_04z  USING    fu_zalno.
  DATA : ls_04z   TYPE zgdmmt004z.

  MOVE-CORRESPONDING gs_head TO ls_04z.
  ls_04z-zalno  = fu_zalno.
  ls_04z-zaldt  = sy-datum.
  ls_04z-ekgrp  = pa_ekgrp.
  ls_04z-prgrp  = pa_prgrp.
  IF gv_trtyp = 'H'.
    ls_04z-erdat  = sy-datum.
    ls_04z-ernam  = sy-uname.
  ELSE.
    ls_04z-erdat  = gs_x04z-erdat.
    ls_04z-ernam  = gs_x04z-ernam.
    ls_04z-modda  = sy-datum.
    ls_04z-modbe  = sy-uname.
  ENDIF.

  PERFORM f_print_fpkh USING 'HSM_FORMFPKH' ''
                       CHANGING ls_04z-url ls_04z-noform." ls_04z-lampiran.

  APPEND ls_04z TO gt_04z.
ENDFORM.                    " F_04Z

*&---------------------------------------------------------------------*
*&      Form  F_READ_TEXT
*&---------------------------------------------------------------------*
FORM f_read_text  TABLES   ft_text  TYPE STANDARD TABLE
                  USING    fu_tdname.

  DATA : lines   TYPE STANDARD TABLE OF tline,
         ls_line LIKE LINE OF lines,
         lt_text TYPE STANDARD TABLE OF ty_text,
         ls_text LIKE LINE OF lt_text.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      id                      = 'ST'
      language                = sy-langu
      name                    = fu_tdname
      object                  = 'TEXT'
    TABLES
      lines                   = lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.

  ls_text-head-tdobject  = 'TEXT'.
  ls_text-head-tdname    = fu_tdname.
  ls_text-head-tdid      = 'ST'.
  ls_text-head-tdspras   = sy-langu.
  ls_text-head-tdform    = 'SYSTEM'.
  LOOP AT lines INTO ls_line.
    ls_text-line           = ls_line-tdline.
    APPEND ls_text TO ft_text.
    CLEAR ls_text.
  ENDLOOP.
ENDFORM.                    " F_READ_TEXT

*&---------------------------------------------------------------------*
*&      Form  F_GET_ACTUAL_ALLOCATION
*&---------------------------------------------------------------------*
FORM f_get_actual_allocation .
  DATA : lr_bsart TYPE RANGE OF bsart,
         ls_bsart LIKE LINE OF lr_bsart,
         lt_ekko  TYPE STANDARD TABLE OF ekko,
         lt_ekpo  TYPE STANDARD TABLE OF ekpo.

  DATA : ls_alpo LIKE LINE OF gt_alpo,
         ls_mara LIKE LINE OF gt_mara.

  ls_bsart-low    = 'ZIMP'.
  ls_bsart-sign   = 'I'.
  ls_bsart-option = 'EQ'.
  APPEND ls_bsart TO lr_bsart.
  CLEAR ls_bsart.
  ls_bsart-low    = 'ZLOC'.
  ls_bsart-sign   = 'I'.
  ls_bsart-option = 'EQ'.
  APPEND ls_bsart TO lr_bsart.
  CLEAR ls_bsart.

  IF gt_lfa1[] IS NOT INITIAL.
    SELECT *
      FROM ekko
      INTO CORRESPONDING FIELDS OF TABLE gt_alko
      FOR ALL ENTRIES IN gt_lfa1
      WHERE lifnr = gt_lfa1-lifnr
        AND ekorg = 'TNT'
        AND ekgrp = pa_ekgrp
        AND bsart IN lr_bsart
        AND loekz = space
        AND autlf = space
      ORDER BY PRIMARY KEY.

    IF gt_alko[] IS NOT INITIAL.
      SELECT *
        FROM ekpo
        INTO CORRESPONDING FIELDS OF TABLE gt_alpo
        FOR ALL ENTRIES IN gt_alko
        WHERE ebeln = gt_alko-ebeln
          AND loekz = space
          AND werks = so_werks-low
        ORDER BY PRIMARY KEY.

      gt_xalpo[] = gt_alpo[].

      LOOP AT gt_alpo INTO ls_alpo.
        CLEAR ls_mara.
        IF so_werks-low = '1601'.
          TRANSLATE ls_alpo-afnam TO UPPER CASE.
          CONDENSE: ls_alpo-afnam.
          gv_plant = ls_alpo-afnam.
        ENDIF.
        READ TABLE gt_mara INTO ls_mara
                           WITH KEY matnr = ls_alpo-ematn.
        IF sy-subrc <> 0.
          DELETE TABLE gt_alpo FROM ls_alpo.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

  lt_ekko[] = gt_alko[].
  lt_ekpo[] = gt_alpo[].

  PERFORM f_lampiran_po TABLES lt_ekko
                               lt_ekpo.
ENDFORM.                    " F_GET_ACTUAL_ALLOCATION

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_ACTUAL_ALOKASI
*&---------------------------------------------------------------------*
FORM f_calculate_actual_alokasi  USING    fu_lifnr.
  DATA : lr_1     TYPE RANGE OF datum,
         lr_2     TYPE RANGE OF datum,
         lr_3     TYPE RANGE OF datum,
         lr_4     TYPE RANGE OF datum,
         ls_datum TYPE range_date.

  DATA : lv_menge1 TYPE ekpo-menge,
         lv_menge2 TYPE ekpo-menge,
         lv_menge3 TYPE ekpo-menge,
         lv_menge4 TYPE ekpo-menge,
         lv_menge5 TYPE ekpo-menge,
         lv_menge6 TYPE ekpo-menge,
         lv_menge7 TYPE ekpo-menge,
         lv_menge8 TYPE ekpo-menge.

  DATA : ls_alpo LIKE LINE OF gt_alpo,
         ls_alko LIKE LINE OF gt_alko.

  ls_datum-sign   = 'I'.
  ls_datum-option = 'BT'.

  CONCATENATE pa_mjahr '0101' INTO ls_datum-low.
  CONCATENATE pa_mjahr '0331' INTO ls_datum-high.
  APPEND ls_datum TO lr_1.

  CONCATENATE pa_mjahr '0401' INTO ls_datum-low.
  CONCATENATE pa_mjahr '0630' INTO ls_datum-high.
  APPEND ls_datum TO lr_2.

  CONCATENATE pa_mjahr '0701' INTO ls_datum-low.
  CONCATENATE pa_mjahr '0930' INTO ls_datum-high.
  APPEND ls_datum TO lr_3.

  CONCATENATE pa_mjahr '1001' INTO ls_datum-low.
  CONCATENATE pa_mjahr '1231' INTO ls_datum-high.
  APPEND ls_datum TO lr_4.

  LOOP AT gt_alpo INTO ls_alpo.
    CLEAR ls_alko.
    READ TABLE gt_alko INTO ls_alko
                       WITH KEY ebeln = ls_alpo-ebeln.
    IF ls_alko-bedat IN lr_1.
      IF ls_alko-lifnr  = fu_lifnr.
        ADD ls_alpo-menge TO lv_menge1.
      ENDIF.
      ADD ls_alpo-menge TO lv_menge2.
    ENDIF.

    IF ls_alko-bedat IN lr_2.
      IF ls_alko-lifnr  = fu_lifnr.
        ADD ls_alpo-menge TO lv_menge3.
      ENDIF.
      ADD ls_alpo-menge TO lv_menge4.
    ENDIF.

    IF ls_alko-bedat IN lr_3.
      IF ls_alko-lifnr  = fu_lifnr.
        ADD ls_alpo-menge TO lv_menge5.
      ENDIF.
      ADD ls_alpo-menge TO lv_menge6.
    ENDIF.

    IF ls_alko-bedat IN lr_4.
      IF ls_alko-lifnr  = fu_lifnr.
        ADD ls_alpo-menge TO lv_menge7.
      ENDIF.
      ADD ls_alpo-menge TO lv_menge8.
    ENDIF.
  ENDLOOP.

  PERFORM f_divide_calculate USING : fu_lifnr '1' lv_menge1 lv_menge2,
                                     fu_lifnr '2' lv_menge3 lv_menge4,
                                     fu_lifnr '3' lv_menge5 lv_menge6,
                                     fu_lifnr '4' lv_menge7 lv_menge8.
ENDFORM.                    " F_CALCULATE_ACTUAL_ALOKASI

*&---------------------------------------------------------------------*
*&      Form  F_DIVIDE_CALCULATE
*&---------------------------------------------------------------------*
FORM f_divide_calculate  USING    fu_lifnr fu_count fu_menge1 fu_menge2.
  DATA : lv_actal   TYPE zbobottop.

  TRY .
      lv_actal  = ( fu_menge1 / fu_menge2 ) * 100.
    CATCH cx_sy_zerodivide.
  ENDTRY.

  CASE fu_count.
    WHEN '1'.
      gs_actal-act01  = lv_actal.
    WHEN '2'.
      gs_actal-act02  = lv_actal.
    WHEN '3'.
      gs_actal-act03  = lv_actal.
    WHEN '4'.
      gs_actal-act04  = lv_actal.
      gs_actal-lifnr  = fu_lifnr.
      APPEND gs_actal TO gt_actal.
      CLEAR gs_actal.
  ENDCASE.
ENDFORM.                    " F_DIVIDE_CALCULATE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_ACTUAL_ALOKASI
*&---------------------------------------------------------------------*
FORM f_display_actual_alokasi .
  DATA : ls_actal   LIKE LINE OF gt_actal.

  READ TABLE gt_actal INTO ls_actal
                      WITH KEY lifnr = gs_quot-lifnr.
  IF sy-subrc = 0.
    gs_quot-act01 = ls_actal-act01.
    gs_quot-act02 = ls_actal-act02.
    gs_quot-act03 = ls_actal-act03.
    gs_quot-act04 = ls_actal-act04.
  ENDIF.
ENDFORM.                    " F_DISPLAY_ACTUAL_ALOKASI

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_UNDER3%
*&---------------------------------------------------------------------*
FORM f_calculate_under3%  TABLES   ft_zm73 LIKE gt_zm73_1
                          USING    fu_diff.
  DATA : lv_count TYPE i,
         lv_%aloc TYPE zbobottop,
         lv_index TYPE i.

  lv_index  = 4.

  CASE fu_diff.
    WHEN 4.
      LOOP AT ft_zm73.
        ADD 1 TO lv_count.
        ft_zm73-%aloc = 100 / fu_diff.
        MODIFY ft_zm73 TRANSPORTING %aloc.
        IF lv_count = fu_diff.
          EXIT.
        ENDIF.
      ENDLOOP.
    WHEN 3.
      READ TABLE ft_zm73 INDEX lv_index.
      IF sy-subrc = 0.
        lv_%aloc  = ft_zm73-%aloc.
      ENDIF.
      LOOP AT ft_zm73.
        ADD 1 TO lv_count.
        ft_zm73-%aloc = ( 100 - lv_%aloc ) / fu_diff.
        MODIFY ft_zm73 TRANSPORTING %aloc.
        IF lv_count = fu_diff.
          EXIT.
        ENDIF.
      ENDLOOP.
    WHEN 2.
      DO 2 TIMES.
        READ TABLE ft_zm73 INDEX lv_index.
        IF sy-subrc = 0.
          ADD ft_zm73-%aloc TO lv_%aloc.
        ENDIF.
        lv_index = lv_index - 1.
      ENDDO.

      LOOP AT ft_zm73.
        ADD 1 TO lv_count.
        ft_zm73-%aloc = ( 100 - lv_%aloc ) / fu_diff.
        MODIFY ft_zm73 TRANSPORTING %aloc.
        IF lv_count = fu_diff.
          EXIT.
        ENDIF.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_CALCULATE_UNDER3%

*&---------------------------------------------------------------------*
*&      Form  F_04P
*&---------------------------------------------------------------------*
FORM f_04p  USING    fu_zalno.
  DATA : ls_xsplitq LIKE LINE OF gt_xsplitq,
         ls_04p     LIKE LINE OF gt_04p.

  LOOP AT gt_xsplitq INTO ls_xsplitq.
    IF ls_xsplitq-revis = 0.
      CONTINUE.
    ENDIF.
    ls_04p-zalno    = fu_zalno.
    ls_04p-lifnr    = ls_xsplitq-lifnr.
    ls_04p-banfn    = ls_xsplitq-banfn.
    ls_04p-bnfpo    = ls_xsplitq-bnfpo.
    ls_04p-zeile    = ls_xsplitq-zeile.
    ls_04p-lgort    = ls_xsplitq-lgort.
    ls_04p-meins    = ls_xsplitq-meins.
    ls_04p-menge    = ls_xsplitq-revis.
    APPEND ls_04p TO gt_04p.
    CLEAR ls_04p.
  ENDLOOP.
ENDFORM.                    " F_04P

*&---------------------------------------------------------------------*
*&      Form  F_EXCLUDING_TOOLBAR
*&---------------------------------------------------------------------*
FORM f_excluding_toolbar CHANGING fs_exclude  TYPE ui_functions.
  DATA : ls_exclude   TYPE ui_func.

  CLEAR : fs_exclude.

  ls_exclude = cl_gui_alv_grid=>mc_fc_info.
  APPEND ls_exclude TO fs_exclude.
  CLEAR ls_exclude.

ENDFORM.                    " F_EXCLUDING_TOOLBAR

*&---------------------------------------------------------------------*
*&      Form  F_F4_PRGRP
*&---------------------------------------------------------------------*
FORM f_f4_prgrp  CHANGING fc_prgrp.
  DATA : lt_makt    TYPE STANDARD TABLE OF makt,
         lt_xprdgrp TYPE STANDARD TABLE OF ty_prdgrp,
         ls_prdgrp  LIKE LINE OF gt_prdgrp,
         ls_xprdgrp LIKE LINE OF lt_xprdgrp,
         ls_makt    LIKE LINE OF lt_makt.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lv_subrc       TYPE sy-subrc.

  CLEAR gt_prdgrp[].

  PERFORM f_get_product_group.

  IF gt_prdgrp[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN gt_prdgrp
      WHERE matnr = gt_prdgrp-matnr
        AND spras = sy-langu.

    LOOP AT gt_prdgrp INTO ls_prdgrp.
      MOVE-CORRESPONDING ls_prdgrp TO ls_xprdgrp.
      CLEAR ls_makt.
      READ TABLE lt_makt INTO ls_makt
                         WITH KEY matnr = ls_prdgrp-matnr.
      IF sy-subrc = 0.
        ls_xprdgrp-maktx   = ls_makt-maktx.
        APPEND ls_xprdgrp TO lt_xprdgrp.
      ENDIF.
    ENDLOOP.

    ASSIGN lt_xprdgrp[] TO <fs_tab>.

    CLEAR lv_subrc.
    PERFORM f_value_request TABLES return_tab
                            USING 'MATNR' 'PA_PRGRP'
                            CHANGING lv_subrc.
  ENDIF.
ENDFORM.                    " F_F4_PRGRP

*&---------------------------------------------------------------------*
*&      Form  F_F4_ZALNO
*&---------------------------------------------------------------------*
FORM f_f4_zalno  CHANGING fu_zalno.
  DATA : lt_04z   TYPE STANDARD TABLE OF zgdmmt004z,
         ls_04z   LIKE LINE OF lt_04z,
         lt_alloc TYPE STANDARD TABLE OF ty_alloc,
         ls_alloc LIKE LINE OF lt_alloc.

  DATA : return_tab TYPE STANDARD TABLE OF ddshretval INITIAL SIZE 0,
         ls_return  LIKE LINE OF return_tab.

  DATA : lv_subrc       TYPE sy-subrc.

  SELECT *
    FROM zgdmmt004z
    INTO CORRESPONDING FIELDS OF TABLE lt_04z
    WHERE submi = pa_submi
      AND werks = so_werks-low
      AND ekgrp = pa_ekgrp
      AND matnr = so_matnr-low.

  LOOP AT lt_04z INTO ls_04z.
    ls_alloc-zalno    = ls_04z-zalno.
    APPEND ls_alloc TO lt_alloc.
    CLEAR ls_alloc.
  ENDLOOP.

  SORT lt_alloc BY zalno.
  DELETE ADJACENT DUPLICATES FROM lt_alloc COMPARING zalno.

  ASSIGN lt_alloc[] TO <fs_tab>.

  CLEAR lv_subrc.
  PERFORM f_value_request TABLES return_tab
                          USING 'ZALNO' 'PA_ZALNO'
                          CHANGING lv_subrc.
ENDFORM.                    " F_F4_ZALNO

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRODUCT_GROUP
*&---------------------------------------------------------------------*
FORM f_get_product_group .
  DATA : lt_pgmi     TYPE STANDARD TABLE OF pgmi,
         lt_xpgmi    TYPE STANDARD TABLE OF pgmi,
         ls_pgmi     TYPE pgmi,
         ls_xpgmi    TYPE pgmi,
         ls_prdgrp   LIKE LINE OF gt_prdgrp,
         ls_material LIKE LINE OF gt_material.

  DATA : lv_subrc     TYPE sy-subrc.

  IF gt_prdgrp[] IS INITIAL.
    PERFORM f_dynp_value_read USING 'SO_MATNR-LOW'
                              CHANGING ls_material-matnr.
    APPEND ls_material TO gt_material.

    lv_subrc = 4.

    SELECT *
      FROM pgmi
      INTO CORRESPONDING FIELDS OF TABLE lt_pgmi
      WHERE nrmit = ls_material-matnr.

    IF lt_pgmi[] IS NOT INITIAL.
      WHILE lv_subrc IS NOT INITIAL.
        SELECT *
          FROM pgmi
          INTO CORRESPONDING FIELDS OF TABLE lt_xpgmi
          FOR ALL ENTRIES IN lt_pgmi
          WHERE nrmit = lt_pgmi-prgrp.
        IF sy-subrc <> 0.
          CLEAR lv_subrc.
        ELSE.
          lt_pgmi[] = lt_xpgmi[].
        ENDIF.
      ENDWHILE.
    ENDIF.

    CLEAR lt_xpgmi[].

    IF lt_pgmi[] IS NOT INITIAL.
      WHILE lv_subrc IS INITIAL.
        SELECT *
          FROM pgmi
          INTO CORRESPONDING FIELDS OF TABLE lt_xpgmi
          FOR ALL ENTRIES IN lt_pgmi
          WHERE prgrp = lt_pgmi-nrmit.
        IF sy-subrc <> 0.
          lv_subrc = sy-subrc.
        ELSE.
          LOOP AT lt_xpgmi INTO ls_xpgmi.
            ls_prdgrp-matnr = ls_xpgmi-prgrp.
            ls_prdgrp-werks = ls_xpgmi-werks.
            APPEND ls_prdgrp TO gt_prdgrp.
          ENDLOOP.
          lt_pgmi[] = lt_xpgmi[].
        ENDIF.
      ENDWHILE.
    ENDIF.

    SORT gt_prdgrp BY matnr.
    DELETE ADJACENT DUPLICATES FROM gt_prdgrp COMPARING matnr.

    LOOP AT gt_prdgrp INTO ls_prdgrp.
      PERFORM f_cek_product_group USING ls_prdgrp-matnr ls_prdgrp-werks
                                  CHANGING lv_subrc.
      IF lv_subrc <> 0.
        DELETE TABLE gt_prdgrp FROM ls_prdgrp.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_GET_PRODUCT_GROUP

*&---------------------------------------------------------------------*
*&      Form  F_DYNP_VALUE_READ
*&---------------------------------------------------------------------*
FORM f_dynp_value_read  USING    fieldname
                        CHANGING fc_value.

  DATA : lt_dynpfields TYPE STANDARD TABLE OF dynpread INITIAL SIZE 0,
         ls_dynpfields LIKE LINE OF lt_dynpfields.

  ls_dynpfields-fieldname   = fieldname.
  APPEND ls_dynpfields TO lt_dynpfields.
  CLEAR ls_dynpfields.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = sy-cprog
      dynumb               = sy-dynnr
      request              = 'A'
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      stepl_not_found      = 10
      OTHERS               = 11.

  LOOP AT lt_dynpfields INTO ls_dynpfields.
    CASE ls_dynpfields-fieldname.
      WHEN fieldname.
        fc_value  = ls_dynpfields-fieldvalue.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " F_DYNP_VALUE_READ

*&---------------------------------------------------------------------*
*&      Form  F_VALUE_REQUEST
*&---------------------------------------------------------------------*
FORM f_value_request  TABLES   return_tab STRUCTURE ddshretval
                      USING    fu_retfield fu_dynprofield
                      CHANGING fc_subrc.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield         = fu_retfield
      dynpprog         = sy-repid
      dynpnr           = sy-dynnr
      dynprofield      = fu_dynprofield
      value_org        = 'S'
      callback_program = sy-repid
      callback_form    = 'F4CALLBACK'
    TABLES
      value_tab        = <fs_tab>
      return_tab       = return_tab.

  fc_subrc  = sy-subrc.
ENDFORM.                    " F_VALUE_REQUEST

*&---------------------------------------------------------------------*
*&      Form  f4callback
*&---------------------------------------------------------------------*
FORM f4callback TABLES   record_tab STRUCTURE seahlpres
                CHANGING shlp TYPE shlp_descr
                         callcontrol LIKE ddshf4ctrl.

  shlp-intdescr-dialogtype = 'D'.
  callcontrol-no_maxdisp = ''.
  callcontrol-maxrecords = 500.
ENDFORM.                                                    "f4callback

*&---------------------------------------------------------------------*
*&      Form  F_CEK_PRODUCT_GROUP
*&---------------------------------------------------------------------*
FORM f_cek_product_group  USING    fu_matnr fu_werks
                          CHANGING fc_subrc.
  DATA : lt_pgbau TYPE STANDARD TABLE OF pgbau,
         lt_pgtab TYPE STANDARD TABLE OF pgtab,
         ls_pgmit LIKE LINE OF gt_pgmit.

  CLEAR fc_subrc.

  CALL FUNCTION 'MC_PG_STRUKTUR'
    EXPORTING
      iprgrp                       = fu_matnr
      iwerks                       = fu_werks
    TABLES
      ipgmit                       = gt_pgmit
    EXCEPTIONS
      pg_or_material_not_found     = 1
      unit_conversion_not_possible = 2
      OTHERS                       = 3.

  SORT gt_pgmit BY matnr.
  DELETE ADJACENT DUPLICATES FROM gt_pgmit COMPARING matnr.

  READ TABLE gt_pgmit INTO ls_pgmit
                      WITH KEY matnr = so_matnr-low.

  fc_subrc = sy-subrc.
ENDFORM.                    " F_CEK_PRODUCT_GROUP

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_AVERAGE
*&---------------------------------------------------------------------*
FORM f_calculate_average  TABLES   ft_zm73  LIKE gt_zm73_1.
  DATA : lt_xzm73 TYPE STANDARD TABLE OF ty_zm73,
         ls_xzm73 LIKE LINE OF lt_xzm73,
         ls_zm73  TYPE ty_zm73.

  DATA : lv_count    TYPE i.

  lt_xzm73[] = ft_zm73[].
  SORT lt_xzm73 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_xzm73 COMPARING lifnr.
  LOOP AT lt_xzm73 INTO ls_xzm73.
    CLEAR : lv_count, ls_xzm73-bobot.
    LOOP AT ft_zm73 INTO ls_zm73 WHERE lifnr = ls_xzm73-lifnr.
      ADD 1 TO lv_count.
      ADD ls_zm73-bobot TO ls_xzm73-bobot.
    ENDLOOP.
    ls_xzm73-bobot = ls_xzm73-bobot / lv_count.
    MODIFY lt_xzm73 FROM ls_xzm73 TRANSPORTING bobot.
  ENDLOOP.

  CLEAR ft_zm73[].
  ft_zm73[] = lt_xzm73[].
ENDFORM.                    " F_CALCULATE_AVERAGE

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_NUMBER_RANGE
*&---------------------------------------------------------------------*
FORM f_check_number_range CHANGING fc_subrc.
  DATA : ls_nriv    TYPE nriv.

  SELECT SINGLE *
    FROM nriv
    INTO CORRESPONDING FIELDS OF ls_nriv
    WHERE object    = 'ZALNO'
*      AND subobject = pa_ekgrp
      AND nrrangenr = '01'.
*      AND toyear    = pa_mjahr.

  fc_subrc = sy-subrc.
ENDFORM.                    " F_CHECK_NUMBER_RANGE

*&---------------------------------------------------------------------*
*&      Form  F_PURCHASE_ORDER_DATA
*&---------------------------------------------------------------------*
FORM f_purchase_order_data .
  DATA : lt_ekko  TYPE STANDARD TABLE OF ekko,
         lt_ekpo  TYPE STANDARD TABLE OF ekpo,
         lt_xekpo TYPE STANDARD TABLE OF ekpo,
         lt_makt  TYPE STANDARD TABLE OF makt,
         ls_ekko  LIKE LINE OF lt_ekko,
         ls_ekpo  LIKE LINE OF lt_ekpo,
         ls_xekpo LIKE LINE OF lt_xekpo,
         ls_pgmit LIKE LINE OF gt_pgmit,
         ls_lfa1  LIKE LINE OF gt_lfa1,
         ls_total LIKE LINE OF gt_total,
         ls_makt  LIKE LINE OF gt_makt.

  DATA : lr_bedat TYPE RANGE OF bedat,
         ls_bedat LIKE LINE OF lr_bedat.

  CONCATENATE sy-datum(4) '0101' INTO ls_bedat-low.
  CONCATENATE sy-datum(4) '1231' INTO ls_bedat-high.
  ls_bedat-sign   = 'E'.
  ls_bedat-option = 'BT'.
  APPEND ls_bedat TO lr_bedat.

  lt_ekko[] = gt_alko[].
  DELETE lt_ekko WHERE bedat IN lr_bedat.
  lt_xekpo[] = gt_xalpo[].
  SORT lt_xekpo BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING matnr.
  IF lt_xekpo[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN lt_xekpo
      WHERE matnr = lt_xekpo-matnr
        AND spras = sy-langu.
  ENDIF.
  LOOP AT gt_xalpo INTO ls_ekpo.
    CLEAR ls_pgmit.
    READ TABLE gt_pgmit INTO ls_pgmit
                        WITH KEY matnr = ls_ekpo-matnr.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
    CLEAR ls_ekko.
    READ TABLE lt_ekko INTO ls_ekko
                       WITH KEY ebeln = ls_ekpo-ebeln.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
    APPEND ls_ekpo TO lt_ekpo.
    CLEAR ls_ekpo.
  ENDLOOP.

  SORT lt_ekko BY lifnr ebeln.
  SORT lt_ekpo BY ebeln matnr.

  LOOP AT lt_ekko INTO ls_ekko.
    LOOP AT lt_ekpo INTO ls_ekpo WHERE ebeln = ls_ekko-ebeln.
      READ TABLE lt_makt INTO ls_makt
                         WITH KEY matnr = ls_ekpo-matnr.
      IF sy-subrc = 0.
        ls_total-lifnr    = ls_ekko-lifnr.
        ls_total-matnr    = ls_ekpo-matnr.
        ls_total-maktx    = ls_makt-maktx.
        ls_total-menge    = ls_ekpo-menge.
        ls_total-meins    = ls_ekpo-meins.
        COLLECT ls_total INTO gt_total.
        CLEAR ls_total.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  SORT gt_total BY lifnr matnr.
  LOOP AT gt_total INTO ls_total.
    WRITE ls_total-menge TO ls_total-menget UNIT ls_total-meins.
    CONDENSE ls_total-menget NO-GAPS.
    MODIFY gt_total FROM ls_total
                    TRANSPORTING menget.
  ENDLOOP.
ENDFORM.                    " F_PURCHASE_ORDER_DATA

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LAMPIRAN_1
*&---------------------------------------------------------------------*
FORM f_print_lampiran_1  USING    fu_ucomm fu_close fu_open fu_nodialog fu_mail.
  DATA : ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop,
         lt_lfa1    TYPE STANDARD TABLE OF lfa1,
         lt_total   TYPE STANDARD TABLE OF zgdmmst0056.

  DATA : lv_vrsio     TYPE zgdmmt004z-vrsio.

  p_tdform        = 'ZHSMMMSF003'.
  gs_header-prgrp = pa_prgrp.

  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_open  = fu_open.
  d_ctrl_param-no_close = fu_close.

  CASE fu_ucomm.
    WHEN '&POS'.
      d_output_opt-tdnoprev     = 'X'.
      d_ctrl_param-no_dialog    = fu_nodialog.
      d_ctrl_param-preview      = space.
      d_ctrl_param-getotf       = 'X'.
    WHEN '&PREV'.
      d_output_opt-tdnoprint    = 'X'.
  ENDCASE.

  PERFORM f_prepare_detail TABLES lt_lfa1 lt_total.

  CALL FUNCTION d_smrt_funcmod
    EXPORTING
      control_parameters = d_ctrl_param
      output_options     = d_output_opt
      user_settings      = space
      t_header           = gs_header
    IMPORTING
      job_output_info    = ls_info
      job_output_options = ls_options
    TABLES
      gt_heads           = gt_heads
      gt_detls           = gt_detls
      gt_texts           = gt_texts
      gt_lfa1            = lt_lfa1
      gt_total           = lt_total.

  IF fu_mail IS NOT INITIAL.
    PERFORM f_send_mail USING ls_info ls_options ''.
  ELSE.
    CASE gv_trtyp.
      WHEN 'A' OR 'V'.
        lv_vrsio  = gs_head-vrsio.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = lv_vrsio
          IMPORTING
            output = lv_vrsio.

        PERFORM f_send_mail USING ls_info ls_options lv_vrsio.
    ENDCASE.
  ENDIF.
ENDFORM.                    " F_PRINT_LAMPIRAN_1

*&---------------------------------------------------------------------*
*&      Form  F_ADD_PERCEN_ALLOC
*&---------------------------------------------------------------------*
FORM f_add_percen_alloc  USING    fu_subrc fu_quarter
                         CHANGING fc_description.
  IF gv_quarter = fu_quarter AND
    fu_subrc = 0.
    CONCATENATE 'Q' fu_quarter INTO fc_description.
  ENDIF.
ENDFORM.                    " F_ADD_PERCEN_ALLOC

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LAMPIRAN_PR
*&---------------------------------------------------------------------*
FORM f_print_lampiran_pr  USING    fu_ucomm fu_close fu_open fu_nodialog fu_mail.
  DATA : lt_supplier TYPE STANDARD TABLE OF zgdmmst0053,
         ls_supplier TYPE zgdmmst0053,
         ls_lfa1     TYPE lfa1.

  DATA : lv_menget  LIKE eket-menge,
         lv_record  TYPE i,
         lv_totpage TYPE i,
         lv_lines   TYPE i,
         lv_times   TYPE i,
         lv_count   TYPE i,
         lv_div     TYPE i,
         lv_mod     TYPE i.

  DATA : x1 TYPE i,
         x2 TYPE i.

  DATA : lt_nsupl     TYPE STANDARD TABLE OF zgdmmst0055.

  DATA : ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop.

  p_tdform  = 'ZHSMMMSF0012'.
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_open  = fu_open.
  d_ctrl_param-no_close = fu_close.

  CASE fu_ucomm.
    WHEN '&POS'.
      d_output_opt-tdnoprev     = 'X'.
      d_ctrl_param-no_dialog    = fu_nodialog.
      d_ctrl_param-preview      = space.
      d_ctrl_param-getotf       = 'X'.
    WHEN '&PREV'.
      d_output_opt-tdnoprint    = 'X'.
      d_ctrl_param-preview      = 'X'.
  ENDCASE.

  DESCRIBE TABLE gt_sub LINES lv_totpage.
*  DESCRIBE TABLE gt_lfa1 LINES lv_record.
*  lv_div  = lv_record DIV 50.
*  lv_mod  = lv_record MOD 50.
*
*  IF lv_mod <> 0.
*    lv_times = lv_div + 1.
*  ELSE.
*    lv_times = lv_div.
*  ENDIF.
*
*  IF x1 IS INITIAL.
*    x1 = 1.
*    x2 = x1 + 2.
*  ENDIF.

*  DO lv_times TIMES.
*    CLEAR lv_count.
*    LOOP AT gt_lfa1 INTO ls_lfa1 FROM x1 TO x2.
*      ADD 1 TO lv_count.
*      CASE lv_count.
*        WHEN 1.
*          ls_supplier-lifnr1  = ls_lfa1-lifnr.
*        WHEN 2.
*          ls_supplier-lifnr2  = ls_lfa1-lifnr.
*        WHEN 3.
*          ls_supplier-lifnr3  = ls_lfa1-lifnr.
*      ENDCASE.
*    ENDLOOP.
*
*    APPEND ls_supplier TO lt_supplier.
*    CLEAR ls_supplier.
*
*    x1 = x2 + 1.
*    x2 = x1 + 2.
*  ENDDO.

*  DESCRIBE TABLE lt_supplier LINES lv_lines.

*  LOOP AT lt_supplier INTO ls_supplier.
*    PERFORM f_supplier_data TABLES lt_nsupl
*                            USING ls_supplier-lifnr1 ls_supplier-lifnr2
*                                  ls_supplier-lifnr3.
*
*    IF fu_open IS INITIAL AND
*      fu_close IS INITIAL.
*      AT FIRST.
*        d_ctrl_param-no_close = 'X'.
*      ENDAT.
*
*      AT LAST.
*        d_ctrl_param-no_close = space.
*      ENDAT.
*    ENDIF.

  CALL FUNCTION d_smrt_funcmod
    EXPORTING
      control_parameters = d_ctrl_param
      output_options     = d_output_opt
      user_settings      = space
      t_header           = gs_header
      wa_supplier        = ls_supplier
      va_menget          = lv_menget
      va_record          = lv_record
      va_totpage         = lv_totpage
      va_lines           = lv_lines
    IMPORTING
      job_output_info    = ls_info
      job_output_options = ls_options
    TABLES
      t_detail           = gt_detail
      t_sub              = gt_sub
      t_suppl            = gt_xsuppl
      t_nsupl            = lt_nsupl.

  IF fu_open IS INITIAL AND
    fu_close IS INITIAL.
    d_ctrl_param-no_open = 'X'.
  ELSEIF lv_lines > 1.
    d_ctrl_param-no_open = 'X'.
  ENDIF.
*  ENDLOOP.

  IF fu_mail IS NOT INITIAL.
    PERFORM f_send_mail USING ls_info ls_options ''.
  ENDIF.
ENDFORM.                    " F_PRINT_LAMPIRAN_PR

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_FILEMODE
*&---------------------------------------------------------------------*
FORM f_change_filemode  USING    fu_filename TYPE string.
  DATA : BEGIN OF tabl OCCURS 10,
           line(200),
         END OF tabl,
         lv_command(125) TYPE c.

  CONCATENATE 'chmod 777' fu_filename INTO lv_command
  SEPARATED BY ' '.
  CALL 'SYSTEM' ID 'COMMAND' FIELD lv_command
                ID 'TAB' FIELD tabl-*sys*.
ENDFORM.                    " F_CHANGE_FILEMODE

*&---------------------------------------------------------------------*
*&      Form  F_ALOKASI_BUDGET
*&---------------------------------------------------------------------*
FORM f_alokasi_budget .
  DATA : lt_zm73  TYPE STANDARD TABLE OF ty_zm73,
         ls_zm73  LIKE LINE OF lt_zm73,
         lr_datum TYPE RANGE OF datum,
         ls_datum LIKE LINE OF lr_datum,
         lt_a968  TYPE STANDARD TABLE OF a968,
         ls_a968  LIKE LINE OF lt_a968,
         lt_konp  TYPE STANDARD TABLE OF konp,
         ls_konp  LIKE LINE OF lt_konp,
         ls_aloc  LIKE LINE OF gt_aloc.

  CASE gv_quarter.
    WHEN 1.
      CONCATENATE pa_mjahr '0101' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0630' INTO ls_datum-high.
      lt_zm73[] = gt_zm73_1[].
    WHEN 2.
      CONCATENATE pa_mjahr '0101' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0630' INTO ls_datum-high.
      lt_zm73[] = gt_zm73_2[].
    WHEN 3.
      CONCATENATE pa_mjahr '0701' INTO ls_datum-low.
      CONCATENATE pa_mjahr '1231' INTO ls_datum-high.
      lt_zm73[] = gt_zm73_3[].
    WHEN 4.
      CONCATENATE pa_mjahr '0701' INTO ls_datum-low.
      CONCATENATE pa_mjahr '1231' INTO ls_datum-high.
      lt_zm73[] = gt_zm73_4[].
  ENDCASE.

  SORT lt_zm73 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_zm73 COMPARING lifnr.
  IF lt_zm73[] IS NOT INITIAL.
    SELECT *
      FROM a968
      INTO CORRESPONDING FIELDS OF TABLE lt_a968
      FOR ALL ENTRIES IN lt_zm73
      WHERE kappl = 'M'
        AND kschl = 'ZBGA'
        AND ekorg = 'TNT'
        AND lifnr = lt_zm73-lifnr
        AND matnr = so_matnr-low
        AND datbi >= ls_datum-low
        AND datab <= ls_datum-high
      ORDER BY PRIMARY KEY.

    IF lt_a968[] IS NOT INITIAL.
      SELECT *
        FROM konp
        INTO CORRESPONDING FIELDS OF TABLE lt_konp
        FOR ALL ENTRIES IN lt_a968
        WHERE knumh = lt_a968-knumh
        ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.

  LOOP AT lt_a968 INTO ls_a968.
    ls_aloc-lifnr   = ls_a968-lifnr.
    ls_aloc-datab   = ls_a968-datab.

    CLEAR : lr_datum[], ls_datum.
    ls_datum-low    = ls_a968-datab.
    ls_datum-high   = ls_a968-datbi.
    ls_datum-sign   = 'I'.
    ls_datum-option = 'BT'.
    APPEND ls_datum TO lr_datum.
    CLEAR ls_datum.

    CLEAR ls_konp.
    READ TABLE lt_konp INTO ls_konp
                       WITH KEY knumh = ls_a968-knumh.
    IF sy-subrc = 0.
      ls_aloc-kbetr = ls_konp-kbetr.
      ls_aloc-konwa = ls_konp-konwa.
      APPEND ls_aloc TO gt_aloc.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_ALOKASI_BUDGET

*&---------------------------------------------------------------------*
*&      Form  F_MEINS_CONVERSION
*&---------------------------------------------------------------------*
FORM f_meins_conversion  USING    fu_meins
                         CHANGING fc_meins.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_OUTPUT'
    EXPORTING
      input          = fu_meins
    IMPORTING
      output         = fc_meins
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_MEINS_CONVERSION

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_CURRENCY
*&---------------------------------------------------------------------*
FORM f_check_currency  TABLES   ft_eine   STRUCTURE eine
                                ft_eipa   STRUCTURE eipa.
  DATA : ls_eipa TYPE eipa,
         ls_eine TYPE eine.

  LOOP AT ft_eipa INTO ls_eipa.
    IF ls_eipa-bwaer <> 'IDR'.
      CALL FUNCTION 'CONVERT_TO_LOCAL_CURRENCY'
        EXPORTING
          date             = sy-datum
          foreign_amount   = ls_eipa-preis
          foreign_currency = ls_eipa-bwaer
          local_currency   = 'IDR'
        IMPORTING
          local_amount     = ls_eipa-preis.

      ls_eipa-bwaer   = 'IDR'.

      MODIFY ft_eipa FROM ls_eipa
                     TRANSPORTING preis bwaer.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_CURRENCY

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_LAMPIRAN_PO
*&---------------------------------------------------------------------*
FORM f_print_lampiran_po  USING    fu_ucomm fu_close fu_open fu_nodialog fu_mail.
  DATA : lt_supplier TYPE STANDARD TABLE OF zgdmmst0053,
         ls_supplier TYPE zgdmmst0053,
         ls_lfa1     LIKE LINE OF gt_lfa1.

  DATA : lv_menget  LIKE eket-menge,
         lv_record  TYPE i,
         lv_totpage TYPE i,
         lv_lines   TYPE i,
         lv_times   TYPE i,
         lv_count   TYPE i,
         lv_div     TYPE i,
         lv_mod     TYPE i.

  DATA : x1 TYPE i,
         x2 TYPE i.

  DATA : lt_nsupl TYPE STANDARD TABLE OF zgdmmst0055,
         lt_xlfa1 TYPE STANDARD TABLE OF lfa1,
         ls_xlfa1 LIKE LINE OF lt_xlfa1,
         ls_lampo LIKE LINE OF gt_lampo.

  DATA : ls_info    TYPE ssfcrescl,
         ls_options TYPE ssfcresop.

  p_tdform  = 'ZHSMMMSF0013'.
  PERFORM f_determine_smrt_funcmod USING p_tdform
                                         d_smrt_funcmod
                                         d_frm_subrc.

  d_ctrl_param-no_open  = fu_open.
  d_ctrl_param-no_close = fu_close.

  CASE fu_ucomm.
    WHEN '&POS'.
      d_output_opt-tdnoprev     = 'X'.
      d_ctrl_param-no_dialog    = fu_nodialog.
      d_ctrl_param-preview      = space.
      d_ctrl_param-getotf       = 'X'.
    WHEN '&PREV'.
      d_output_opt-tdnoprint    = 'X'.
      d_ctrl_param-preview      = 'X'.
  ENDCASE.

  DESCRIBE TABLE gt_sub LINES lv_totpage.

  LOOP AT gt_lampo INTO ls_lampo.
    ADD ls_lampo-menge  TO lv_menget.
  ENDLOOP.

  LOOP AT gt_lfa1 INTO ls_lfa1.
    MOVE-CORRESPONDING ls_lfa1 TO ls_xlfa1.
    APPEND ls_xlfa1 TO lt_xlfa1.
    CLEAR ls_xlfa1.
  ENDLOOP.

  CALL FUNCTION d_smrt_funcmod
    EXPORTING
      control_parameters = d_ctrl_param
      output_options     = d_output_opt
      user_settings      = space
      t_header           = gs_header
      va_menget          = lv_menget
      va_record          = lv_record
      va_totpage         = lv_totpage
      va_lines           = lv_lines
    IMPORTING
      job_output_info    = ls_info
      job_output_options = ls_options
    TABLES
      t_detail           = gt_detail
      t_sub              = gt_sub
      t_lfa1             = lt_xlfa1
      t_lampo            = gt_lampo.

  IF fu_open IS INITIAL AND
    fu_close IS INITIAL.
    d_ctrl_param-no_open = 'X'.
  ELSEIF lv_lines > 1.
    d_ctrl_param-no_open = 'X'.
  ENDIF.
*  ENDLOOP.

  IF fu_mail IS NOT INITIAL.
    PERFORM f_send_mail USING ls_info ls_options ''.
  ENDIF.
ENDFORM.                    " F_PRINT_LAMPIRAN_PO

*&---------------------------------------------------------------------*
*&      Form  F_GET_HIGHEST_PRICE
*&---------------------------------------------------------------------*
FORM f_get_highest_price  TABLES   ft_eipa STRUCTURE eipa
                          CHANGING fc_highp fc_pwaer fc_ppeinh fc_pprme
                                   fc_bedat.
  DATA : lv_datum TYPE sy-datum,
         lt_eipa  TYPE STANDARD TABLE OF eipa,
         ls_eipa  LIKE LINE OF lt_eipa,
         lt_xeipa TYPE STANDARD TABLE OF eipa,
         ls_xeipa LIKE LINE OF lt_xeipa,
         ls_xekpo LIKE LINE OF gt_xekpo.

  CONCATENATE sy-datum(4) '0101' INTO lv_datum.
  lt_eipa[] = ft_eipa[].
  DELETE lt_eipa WHERE bedat < lv_datum.

  LOOP AT lt_eipa INTO ls_eipa.
    CLEAR ls_xekpo.
    READ TABLE gt_xekpo INTO ls_xekpo
                        WITH KEY ebeln = ls_eipa-ebeln
                                 ebelp = ls_eipa-ebelp.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
    IF ls_eipa-peinh IS INITIAL OR ls_eipa-peinh EQ 0.
      ls_eipa-peinh = 1.
    ENDIF.
    "    IF ls_eipa-bwaer <> 'IDR'.
    TRY .
        ls_eipa-preis = ls_eipa-preis / ls_eipa-peinh.
      CATCH cx_sy_zerodivide.
    ENDTRY.
    "    ENDIF.
    APPEND ls_eipa TO lt_xeipa.
    CLEAR ls_eipa.
  ENDLOOP.

  SORT lt_xeipa BY preis DESCENDING bedat DESCENDING.
  READ TABLE lt_xeipa INTO ls_eipa INDEX 1.
  IF sy-subrc = 0.
    SELECT SINGLE preis bwaer peinh bprme bedat
      FROM eipa
      INTO (fc_highp, fc_pwaer, fc_ppeinh, fc_pprme, fc_bedat)
      WHERE infnr = ls_eipa-infnr
        AND ebeln = ls_eipa-ebeln
        AND ebelp = ls_eipa-ebelp.
  ENDIF.
ENDFORM.                    " F_GET_HIGHEST_PRICE

*&---------------------------------------------------------------------*
*&      Form  F_GET_ACTUAL_PO
*&---------------------------------------------------------------------*
FORM f_get_actual_po .
  DATA : lt_eina  TYPE STANDARD TABLE OF eina,
         lt_eine  TYPE STANDARD TABLE OF eine,
         lt_eipa  TYPE STANDARD TABLE OF eipa,
         lt_ekko  TYPE STANDARD TABLE OF ekko,
         lt_ekpo  TYPE STANDARD TABLE OF ekpo,
         lt_xekpo TYPE STANDARD TABLE OF ekpo,
         lt_eket  TYPE STANDARD TABLE OF eket,
         lt_004x  TYPE STANDARD TABLE OF zgdmmt004x,
         lt_004y  TYPE STANDARD TABLE OF zgdmmt004y,
         lt_004z  TYPE STANDARD TABLE OF zgdmmt004z,
         ls_ekko  LIKE LINE OF lt_ekko,
         ls_ekpo  LIKE LINE OF lt_ekpo,
         ls_xekpo LIKE LINE OF lt_ekpo,
         ls_eket  LIKE LINE OF lt_eket,
         ls_004x  LIKE LINE OF lt_004x,
         ls_004y  LIKE LINE OF lt_004y,
         ls_004z  LIKE LINE OF lt_004z,
         ls_lampo LIKE LINE OF gt_lampo.

  DATA : lr_datum TYPE RANGE OF sy-datum,
         ls_datum LIKE LINE OF lr_datum.

  DATA : lv_menge(20),
         lv_etmen     TYPE zgdmmt004x-etmen.

  CLEAR : gt_lampo[].

  CASE gv_quarter.
    WHEN 1.
      CONCATENATE pa_mjahr '0101' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0331' INTO ls_datum-high.
    WHEN 2.
      CONCATENATE pa_mjahr '0401' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0630' INTO ls_datum-high.
    WHEN 3.
      CONCATENATE pa_mjahr '0701' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0930' INTO ls_datum-high.
    WHEN 4.
      CONCATENATE pa_mjahr '1001' INTO ls_datum-low.
      CONCATENATE pa_mjahr '1231' INTO ls_datum-high.
  ENDCASE.
  ls_datum-sign   = 'E'.
  ls_datum-option = 'BT'.
  APPEND ls_datum TO lr_datum.

  CASE gv_trtyp.
    WHEN 'H'.
      lt_ekko[] = gt_xekko[].
      lt_ekpo[] = gt_xekpo[].
    WHEN 'V' OR 'A'.
      IF gt_mara[] IS NOT INITIAL.
        SELECT *
          FROM eina
          INTO CORRESPONDING FIELDS OF TABLE lt_eina
          FOR ALL ENTRIES IN gt_mara
          WHERE matnr = gt_mara-matnr
            AND loekz = space.
      ENDIF.

      IF lt_eina[] IS NOT INITIAL.
        SELECT *
          FROM eine
          INTO CORRESPONDING FIELDS OF TABLE lt_eine
          FOR ALL ENTRIES IN lt_eina
          WHERE infnr = lt_eina-infnr
            AND ekorg = 'TNT'
            AND loekz = space.
      ENDIF.

      IF lt_eine[] IS NOT INITIAL.
        SELECT *
          FROM eipa
          INTO CORRESPONDING FIELDS OF TABLE lt_eipa
          FOR ALL ENTRIES IN lt_eine
          WHERE infnr = lt_eine-infnr
            AND werks = so_werks-low.
      ENDIF.

      IF lt_eipa[] IS NOT INITIAL.
        SELECT *
          FROM ekpo
          INTO CORRESPONDING FIELDS OF TABLE lt_ekpo
          FOR ALL ENTRIES IN lt_eipa
          WHERE ebeln = lt_eipa-ebeln
            AND ebelp = lt_eipa-ebelp
            AND loekz = space.

        SELECT *
          FROM ekko
          INTO CORRESPONDING FIELDS OF TABLE lt_ekko
          FOR ALL ENTRIES IN lt_eipa
          WHERE ebeln = lt_eipa-ebeln
            AND ekgrp = pa_ekgrp
            AND loekz = space.
      ENDIF.
  ENDCASE.

  DELETE lt_ekko WHERE aedat IN lr_datum.
  lt_xekpo[] = lt_ekpo[].
  SORT lt_xekpo BY bednr.
  DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING bednr.
  DELETE lt_xekpo WHERE bednr = space.
  IF lt_xekpo[] IS NOT INITIAL.
    SELECT *
      FROM zgdmmt004z
      INTO CORRESPONDING FIELDS OF TABLE lt_004z
      FOR ALL ENTRIES IN lt_xekpo
      WHERE zalno = lt_xekpo-bednr.
    IF lt_004z[] IS NOT INITIAL.
      SELECT *
        FROM zgdmmt004x
        INTO CORRESPONDING FIELDS OF TABLE lt_004x
        FOR ALL ENTRIES IN lt_004z
        WHERE zalno = lt_004z-zalno.
      SELECT *
        FROM zgdmmt004y
        INTO CORRESPONDING FIELDS OF TABLE lt_004y
        FOR ALL ENTRIES IN lt_004z
        WHERE zalno = lt_004z-zalno.
    ENDIF.
  ENDIF.

  LOOP AT lt_ekko INTO ls_ekko.
    ls_lampo-lifnr  = ls_ekko-lifnr.
    ls_lampo-ebeln  = ls_ekko-ebeln.
    CLEAR : ls_ekpo, lv_menge.
    READ TABLE lt_ekpo INTO ls_ekpo
                       WITH KEY ebeln = ls_ekko-ebeln.
    IF sy-subrc = 0.
      CLEAR ls_004z.
      READ TABLE lt_004z INTO ls_004z
                         WITH KEY zalno = ls_ekpo-bednr.
      IF sy-subrc = 0.
        ls_lampo-submi  = ls_004z-submi.
      ENDIF.
      ls_lampo-menge  = ls_ekpo-menge.
      WRITE ls_ekpo-menge TO lv_menge DECIMALS 3.
      SPLIT lv_menge AT ',' INTO ls_lampo-menget ls_lampo-decim1.
      ls_lampo-meins  = ls_ekpo-meins.

      CLEAR : ls_004x, lv_etmen.
      LOOP AT lt_004x INTO ls_004x WHERE zalno = ls_ekpo-bednr
                                     AND lifnr = ls_ekko-lifnr
                                     AND matnr = ls_ekpo-matnr.
        ADD ls_004x-etmen TO lv_etmen.
      ENDLOOP.
      ls_lampo-bsmng  = lv_etmen.
      WRITE lv_etmen TO lv_menge DECIMALS 3.
      SPLIT lv_menge AT ',' INTO ls_lampo-etment ls_lampo-decim2.
      CLEAR ls_004y.
      READ TABLE lt_004y INTO ls_004y
                         WITH KEY zalno = ls_ekpo-bednr
                                  lifnr = ls_ekko-lifnr.
      IF sy-subrc = 0.
        ls_lampo-lfdat  = ls_004y-lfdat.
      ENDIF.
    ENDIF.

    APPEND ls_lampo TO gt_lampo.
    CLEAR ls_lampo.
  ENDLOOP.
ENDFORM.                    " F_GET_ACTUAL_PO

*&---------------------------------------------------------------------*
*&      Form  F_LAMPIRAN_PO
*&---------------------------------------------------------------------*
FORM f_lampiran_po  TABLES   ft_ekko STRUCTURE ekko
                             ft_ekpo STRUCTURE ekpo.
  DATA : lr_datum TYPE RANGE OF sy-datum,
         ls_datum LIKE LINE OF lr_datum,
         ls_ekko  TYPE ekko,
         ls_ekpo  TYPE ekpo,
         lt_xekpo TYPE STANDARD TABLE OF ekpo,
         lt_004x  TYPE STANDARD TABLE OF zgdmmt004x,
         lt_004y  TYPE STANDARD TABLE OF zgdmmt004y,
         lt_004z  TYPE STANDARD TABLE OF zgdmmt004z,
         ls_xekpo LIKE LINE OF lt_xekpo,
         ls_004x  LIKE LINE OF lt_004x,
         ls_004y  LIKE LINE OF lt_004y,
         ls_004z  LIKE LINE OF lt_004z,
         ls_lampo LIKE LINE OF gt_lampo.

  DATA : lv_menge(20),
         lv_etmen     TYPE zgdmmt004x-etmen.

  CLEAR : gt_lampo[].

  CASE gv_quarter.
    WHEN 1.
      CONCATENATE pa_mjahr '0101' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0331' INTO ls_datum-high.
    WHEN 2.
      CONCATENATE pa_mjahr '0401' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0630' INTO ls_datum-high.
    WHEN 3.
      CONCATENATE pa_mjahr '0701' INTO ls_datum-low.
      CONCATENATE pa_mjahr '0930' INTO ls_datum-high.
    WHEN 4.
      CONCATENATE pa_mjahr '1001' INTO ls_datum-low.
      CONCATENATE pa_mjahr '1231' INTO ls_datum-high.
  ENDCASE.
  ls_datum-sign   = 'E'.
  ls_datum-option = 'BT'.
  APPEND ls_datum TO lr_datum.

  DELETE ft_ekko WHERE aedat IN lr_datum.
  lt_xekpo[] = ft_ekpo[].
  SORT lt_xekpo BY bednr.
  DELETE ADJACENT DUPLICATES FROM lt_xekpo COMPARING bednr.
  DELETE lt_xekpo WHERE bednr = space.
  IF lt_xekpo[] IS NOT INITIAL.
    SELECT *
      FROM zgdmmt004z
      INTO CORRESPONDING FIELDS OF TABLE lt_004z
      FOR ALL ENTRIES IN lt_xekpo
      WHERE zalno = lt_xekpo-bednr
      ORDER BY PRIMARY KEY.
    IF lt_004z[] IS NOT INITIAL.
      SELECT *
        FROM zgdmmt004x
        INTO CORRESPONDING FIELDS OF TABLE lt_004x
        FOR ALL ENTRIES IN lt_004z
        WHERE zalno = lt_004z-zalno
        ORDER BY PRIMARY KEY.
      SELECT *
        FROM zgdmmt004y
        INTO CORRESPONDING FIELDS OF TABLE lt_004y
        FOR ALL ENTRIES IN lt_004z
        WHERE zalno = lt_004z-zalno
        ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.

  LOOP AT ft_ekko INTO ls_ekko.
    ls_lampo-lifnr  = ls_ekko-lifnr.
    ls_lampo-ebeln  = ls_ekko-ebeln.
    CLEAR : ls_ekpo, lv_menge.
    READ TABLE ft_ekpo INTO ls_ekpo
                       WITH KEY ebeln = ls_ekko-ebeln.
    IF sy-subrc = 0.
      CLEAR ls_004z.
      READ TABLE lt_004z INTO ls_004z
                         WITH KEY zalno = ls_ekpo-bednr.
      IF sy-subrc = 0.
        ls_lampo-submi  = ls_004z-submi.
      ENDIF.
      ls_lampo-menge  = ls_ekpo-menge.
      WRITE ls_ekpo-menge TO lv_menge DECIMALS 3.
      SPLIT lv_menge AT ',' INTO ls_lampo-menget ls_lampo-decim1.
      ls_lampo-meins  = ls_ekpo-meins.

      CLEAR : ls_004x, lv_etmen.
      LOOP AT lt_004x INTO ls_004x WHERE zalno = ls_ekpo-bednr
                                     AND lifnr = ls_ekko-lifnr
                                     AND matnr = ls_ekpo-matnr.
        ADD ls_004x-etmen TO lv_etmen.
      ENDLOOP.
      ls_lampo-bsmng  = lv_etmen.
      WRITE lv_etmen TO lv_menge DECIMALS 3.
      SPLIT lv_menge AT ',' INTO ls_lampo-etment ls_lampo-decim2.
      CLEAR ls_004y.
      READ TABLE lt_004y INTO ls_004y
                         WITH KEY zalno = ls_ekpo-bednr
                                  lifnr = ls_ekko-lifnr.
      IF sy-subrc = 0.
        ls_lampo-lfdat  = ls_004y-lfdat.
      ENDIF.
    ELSE.
      CONTINUE.
    ENDIF.

    APPEND ls_lampo TO gt_lampo.
    CLEAR ls_lampo.
  ENDLOOP.
ENDFORM.                    " F_LAMPIRAN_PO

*&---------------------------------------------------------------------*
*&      Form  F_GET_DATA_PRGRP
*&---------------------------------------------------------------------*
FORM f_get_data_prgrp  USING    fu_submi fu_prgrp fu_new.
  CLEAR : gt_006[], gt_007[].

  CALL FUNCTION 'ZHSMMM_FM002'
    EXPORTING
      pi_submi            = fu_submi
      pi_filename         = gv_filename
      pi_new              = fu_new
      pi_prgrp            = fu_prgrp
*     pi_getoff           = 'X'
*     pi_tdnoprev         = 'X'
*     pi_nodialog         = 'X'
    TABLES
      pt_006              = gt_006
      pt_007              = gt_007
    EXCEPTIONS
      product_group_error = 1
      OTHERS              = 2.

  IF sy-subrc <> 0.
    MESSAGE s000(zab) WITH 'Product group error' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.                    " F_GET_DATA_PRGRP

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DETAIL
*&---------------------------------------------------------------------*
FORM f_prepare_detail  TABLES   ft_lfa1 STRUCTURE lfa1
                                ft_total STRUCTURE zgdmmst0056.
  DATA : lt_x006   TYPE STANDARD TABLE OF zhsmmmdt006,
         ls_x006   LIKE LINE OF lt_x006,
         lt_x007   TYPE STANDARD TABLE OF zhsmmmdt007,
         ls_x007   LIKE LINE OF lt_x007,
         ls_007    TYPE zhsmmmdt007,
         ls_total  TYPE zgdmmst0056,
         lt_makt   TYPE STANDARD TABLE OF makt,
         ls_makt   LIKE LINE OF lt_makt,
         lv_bstmg  TYPE zhsmmmdt007-bstmg,
         lv_bstmg1 TYPE zhsmmmdt007-bstmg,
         ls_04z    LIKE LINE OF gt_04z.

  DATA : lv_total TYPE mseg-menge,
         lv_kbetr TYPE konp-kbetr,
         ls_lfa1  TYPE lfa1.

  IF gs_header-prgrp IS NOT INITIAL.
    SELECT SINGLE maktx
      FROM makt
      INTO gs_header-maktx
      WHERE matnr = gs_header-prgrp.

    gs_header-matnr = gs_header-prgrp.
  ENDIF.

  lt_x006[] = gt_006[].
  SORT lt_x006 BY matnr.
  DELETE ADJACENT DUPLICATES FROM lt_x006 COMPARING matnr.
  IF lt_x006[] IS NOT INITIAL.
    SELECT *
      FROM makt
      INTO CORRESPONDING FIELDS OF TABLE lt_makt
      FOR ALL ENTRIES IN lt_x006
      WHERE matnr = lt_x006-matnr
        AND spras = sy-langu.
  ENDIF.

  LOOP AT gt_007 INTO ls_007.
    ADD ls_007-bstmg TO lv_total.
  ENDLOOP.

  lt_x007[] = gt_007[].
  SORT lt_x007 BY lifnr.
  DELETE ADJACENT DUPLICATES FROM lt_x007 COMPARING lifnr.
  IF lt_x007[] IS NOT INITIAL.
    SELECT *
      FROM lfa1
      INTO CORRESPONDING FIELDS OF TABLE ft_lfa1
      FOR ALL ENTRIES IN lt_x007
      WHERE lifnr = lt_x007-lifnr.

    LOOP AT lt_x007 INTO ls_x007.
      LOOP AT lt_x006 INTO ls_x006.
        LOOP AT gt_007 INTO ls_007 WHERE lifnr = ls_x007-lifnr
                                     AND matnr = ls_x006-matnr.
          ls_total-lifnr  = ls_007-lifnr.
          ADD ls_007-bstmg TO lv_bstmg.
          ls_total-meins  = ls_007-bstme.
        ENDLOOP.

        IF lv_bstmg IS NOT INITIAL.
          ls_total-matnr = ls_x006-matnr.
          CLEAR ls_makt.
          READ TABLE lt_makt INTO ls_makt
                             WITH KEY matnr = ls_x006-matnr.
          IF sy-subrc = 0.
            ls_total-maktx = ls_makt-maktx.
          ENDIF.
          ls_total-menge  = lv_bstmg.
          WRITE lv_bstmg TO ls_total-menget UNIT ls_total-meins.
          CONDENSE ls_total-menget NO-GAPS.
          APPEND ls_total TO ft_total.
          ADD lv_bstmg TO lv_bstmg1.
          CLEAR : ls_total, lv_bstmg.
        ENDIF.
      ENDLOOP.

      READ TABLE ft_lfa1 INTO ls_lfa1
                         WITH KEY lifnr = ls_x007-lifnr.
      IF sy-subrc = 0.
        TRY .
            lv_kbetr  = ( lv_bstmg1 / lv_total ) * 100.
          CATCH cx_sy_zerodivide.
        ENDTRY.
        WRITE lv_kbetr TO ls_lfa1-gbort DECIMALS 2.
        CONDENSE ls_lfa1-gbort NO-GAPS.
        MODIFY ft_lfa1 FROM ls_lfa1
                       TRANSPORTING gbort
                       WHERE lifnr = ls_x007-lifnr.
      ENDIF.
      CLEAR: lv_bstmg, lv_bstmg1.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PREPARE_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_006
*&---------------------------------------------------------------------*
FORM f_006  USING    fu_zalno.
  DATA : ls_006     LIKE LINE OF gt_006.

  LOOP AT gt_006 INTO ls_006.
    ls_006-zalno  = fu_zalno.
    MODIFY gt_006 FROM ls_006 TRANSPORTING zalno.
    CLEAR ls_006.
  ENDLOOP.
ENDFORM.                    " F_006

*&---------------------------------------------------------------------*
*&      Form  F_007
*&---------------------------------------------------------------------*
FORM f_007  USING    fu_zalno.
  DATA : ls_007     LIKE LINE OF gt_007.

  LOOP AT gt_007 INTO ls_007.
    ls_007-zalno  = fu_zalno.
    MODIFY gt_007 FROM ls_007 TRANSPORTING zalno.
    CLEAR ls_007.
  ENDLOOP.
ENDFORM.                    " F_007

*&---------------------------------------------------------------------*
*&      Form  F_LOCK_DATA
*&---------------------------------------------------------------------*
FORM f_lock_data  USING    fu_lock.
  DATA : lv_gname     TYPE seqg3-gname,
         lv_garg      TYPE seqg3-garg,
         enq          TYPE STANDARD TABLE OF seqg3,
         ls_enq       LIKE LINE OF enq,
         lv_mess(100).

  CLEAR : gv_guname.
  lv_gname       = 'ZGDMMT004L'.
  lv_garg(3)     = sy-mandt.
  lv_garg+3(3)   = pa_ekgrp.
  lv_garg+6(10)  = pa_submi.
  lv_garg+16(4)  = so_werks-low.
  lv_garg+20(18) = so_matnr-low.
  IF pa_zalno IS NOT INITIAL.
    lv_garg+38(10) = pa_zalno.
  ENDIF.

  IF fu_lock IS NOT INITIAL.
    CALL FUNCTION 'ENQUEUE_READ'
      EXPORTING
        gname                 = lv_gname
        guname                = space
      TABLES
        enq                   = enq
      EXCEPTIONS
        communication_failure = 1
        system_failure        = 2
        OTHERS                = 3.

    READ TABLE enq INTO ls_enq INDEX 1.
    IF sy-subrc = 0.
      IF pa_zalno IS NOT INITIAL.
        IF ls_enq-garg+38(10) = pa_zalno.
          gv_subrc = 6.
        ENDIF.
      ELSE.
        IF ls_enq-garg(38) = lv_garg(38).
          gv_subrc = 6.
        ENDIF.
      ENDIF.
      gv_guname = ls_enq-guname.
    ELSE.
      CALL FUNCTION 'ENQUEUE_EZGDMMT004L'
        EXPORTING
          ekgrp          = pa_ekgrp
          submi          = pa_submi
          werks          = so_werks-low
          matnr          = so_matnr-low
          zalno          = pa_zalno
        EXCEPTIONS
          foreign_lock   = 1
          system_failure = 2
          OTHERS         = 3.
    ENDIF.
  ELSE.
    CALL FUNCTION 'DEQUEUE_EZGDMMT004L'
      EXPORTING
        ekgrp = pa_ekgrp
        submi = pa_submi
        werks = so_werks-low
        matnr = so_matnr-low
        zalno = pa_zalno.
  ENDIF.
ENDFORM.                    " F_LOCK_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CONVERSION_CUNIT
*&---------------------------------------------------------------------*
FORM f_conversion_cunit  CHANGING fc_value.
  CALL FUNCTION 'CONVERSION_EXIT_CUNIT_INPUT'
    EXPORTING
      input          = fc_value
    IMPORTING
      output         = fc_value
    EXCEPTIONS
      unit_not_found = 1
      OTHERS         = 2.
ENDFORM.                    " F_CONVERSION_CUNIT

*&---------------------------------------------------------------------*
*&      Form  F_GET_PRICE_UNIT
*&---------------------------------------------------------------------*
FORM f_get_price_unit .
  CASE gv_trtyp.
    WHEN 'H'.
      IF gt_lfa1[] IS NOT INITIAL.
        SELECT *
          FROM eina
          INTO CORRESPONDING FIELDS OF TABLE gt_eina
          FOR ALL ENTRIES IN gt_lfa1
          WHERE lifnr = gt_lfa1-lifnr
            AND loekz = space.
      ENDIF.
    WHEN OTHERS.
      IF gt_x04x[] IS NOT INITIAL.
        SELECT *
          FROM eina
          INTO CORRESPONDING FIELDS OF TABLE gt_eina
          FOR ALL ENTRIES IN gt_x04x
          WHERE lifnr = gt_x04x-lifnr
            AND loekz = space.
      ENDIF.
  ENDCASE.

  IF gt_eina[] IS NOT INITIAL.
    SELECT *
      FROM eine
      INTO CORRESPONDING FIELDS OF TABLE gt_eine
      FOR ALL ENTRIES IN gt_eina
      WHERE infnr = gt_eina-infnr
        AND ekorg = 'TNT'.
  ENDIF.
ENDFORM.                    " F_GET_PRICE_UNIT

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_PIR
*&---------------------------------------------------------------------*
FORM f_change_pir .
  DATA : lt_rows  TYPE lvc_t_row,
         ls_rows  TYPE lvc_s_row,
         lt_koart TYPE STANDARD TABLE OF t685,
         ls_ekko  TYPE ekko,
         ls_ekpo  TYPE ekpo,
         lt_t685  TYPE STANDARD TABLE OF t685,
         lt_a016  TYPE STANDARD TABLE OF a016,
         lt_konm  TYPE STANDARD TABLE OF konm,
         ls_konm  LIKE LINE OF lt_konm,
         lt_konp  TYPE STANDARD TABLE OF konp,
         ls_konp  LIKE LINE OF lt_konp,
         ls_dpir  TYPE ty_pir.

  FIELD-SYMBOLS <fs>  TYPE any.

  CALL METHOD g_tabgrid01->get_selected_rows
    IMPORTING
      et_index_rows = lt_rows.

  IF sy-subrc = 0.
    READ TABLE lt_rows INTO ls_rows INDEX 1.
    IF sy-subrc = 0.
      READ TABLE <fs_main> ASSIGNING <fs_lmain> INDEX ls_rows-index.
      IF sy-subrc = 0.
        gs_hpir-zalno   = pa_zalno.
        gs_hpir-submi   = gs_head-submi.
        ASSIGN COMPONENT 'EBELN' OF STRUCTURE <fs_lmain> TO <fs>.
        gs_hpir-ebeln   = <fs>.
        ASSIGN COMPONENT 'LIFNR' OF STRUCTURE <fs_lmain> TO <fs>.
        gs_hpir-lifnr   = <fs>.
        ASSIGN COMPONENT 'NAME1' OF STRUCTURE <fs_lmain> TO <fs>.
        gs_hpir-name1   = <fs>.
        ASSIGN COMPONENT 'MATNR' OF STRUCTURE <fs_lmain> TO <fs>.
        gs_hpir-matnr   = <fs>.
        ASSIGN COMPONENT 'MAKTX' OF STRUCTURE <fs_lmain> TO <fs>.
        gs_hpir-maktx   = <fs>.

        SELECT SINGLE *
          FROM ekko
          INTO CORRESPONDING FIELDS OF ls_ekko
          WHERE ebeln = gs_hpir-ebeln
            AND lifnr = gs_hpir-lifnr.

        CALL FUNCTION 'ME_GET_CONDITIONS_TO_SEARCH'
          EXPORTING
            application        = 'M'
            pricing_scheme     = ls_ekko-kalsm
            tabelle            = '016'
          TABLES
            koart              = lt_t685
          EXCEPTIONS
            no_scheme          = 1
            no_success         = 2
            terminated_by_user = 3
            OTHERS             = 4.

        IF lt_t685[] IS NOT INITIAL.
          SELECT SINGLE *
            FROM ekpo
            INTO CORRESPONDING FIELDS OF ls_ekpo
            WHERE ebeln = gs_hpir-ebeln
              AND matnr = gs_hpir-matnr.

          SELECT *
            FROM a016
            INTO TABLE lt_a016
            FOR ALL ENTRIES IN lt_t685
            WHERE kappl = 'M'
              AND kschl = lt_t685-kschl
              AND evrtn = ls_ekpo-ebeln
              AND evrtp = ls_ekpo-ebelp
              AND datbi >= sy-datum
              AND datab <= sy-datum.

          IF lt_a016[] IS NOT INITIAL.
            SELECT *
              FROM konm
              INTO CORRESPONDING FIELDS OF TABLE lt_konm
              FOR ALL ENTRIES IN lt_a016
              WHERE knumh = lt_a016-knumh.

            IF lt_konm[] IS NOT INITIAL.
              SELECT *
                FROM konp
                INTO CORRESPONDING FIELDS OF TABLE lt_konp
                FOR ALL ENTRIES IN lt_konm
                WHERE knumh = lt_konm-knumh
                  AND kopos = lt_konm-kopos.
            ENDIF.

            LOOP AT lt_konm INTO ls_konm.
              ls_dpir-kstbm   = ls_konm-kstbm.
              ls_dpir-kbetr   = ls_konm-kbetr.
              READ TABLE lt_konp INTO ls_konp
                                 WITH KEY knumh = ls_konm-knumh
                                          kopos = ls_konm-kopos.
              IF sy-subrc = 0.
                ls_dpir-konms   = ls_konp-konms.
                ls_dpir-skonwa  = ls_konp-konwa.
                ls_dpir-kpein   = ls_konp-kpein.
                ls_dpir-kmein   = ls_konp-kmein.
              ENDIF.
              APPEND ls_dpir TO gt_dpir.
              CLEAR ls_dpir.
            ENDLOOP.
          ENDIF.
        ENDIF.

        CALL SCREEN 106 STARTING AT 10 10.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHANGE_PIR

*&---------------------------------------------------------------------*
*&      Form  F_ALOKASI_PRGRP
*&---------------------------------------------------------------------*
FORM f_alokasi_prgrp .
  SELECT *
    FROM zhsmmmdt006
    INTO CORRESPONDING FIELDS OF TABLE gt_006
    WHERE prgrp = gs_x04z-prgrp
      AND submi = gs_x04z-submi
      AND zalno = gs_x04z-zalno
    ORDER BY PRIMARY KEY.

  IF gt_006[] IS NOT INITIAL.
    SELECT *
      FROM zhsmmmdt007
      INTO CORRESPONDING FIELDS OF TABLE gt_007
      WHERE prgrp = gs_x04z-prgrp
        AND submi = gs_x04z-submi
        AND zalno = gs_x04z-zalno
      ORDER BY PRIMARY KEY.
  ELSE.
    IF radio2 IS NOT INITIAL.
      PERFORM f_alokasi_prgrp_fr_system.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_ALOKASI_PRGRP

*&---------------------------------------------------------------------*
*&      Form  F_ALOKASI_PRGRP_FR_SYSTEM
*&---------------------------------------------------------------------*
FORM f_alokasi_prgrp_fr_system .
  DATA : lt_xpgmit TYPE STANDARD TABLE OF pgmit,
         lt_ekpo   TYPE STANDARD TABLE OF ekpo,
         ls_xpgmit LIKE LINE OF lt_xpgmit,
         ls_ekpo   LIKE LINE OF lt_ekpo.

  DATA : ls_006   LIKE LINE OF gt_006,
         ls_007   LIKE LINE OF gt_007,
         ls_lfa1  LIKE LINE OF gt_lfa1,
         ls_alko  LIKE LINE OF gt_alko,
         ls_xalpo LIKE LINE OF gt_xalpo.

  DATA : lr_bedat TYPE RANGE OF datum,
         ls_bedat LIKE LINE OF lr_bedat.

  CONCATENATE sy-datum(4) '0101' INTO ls_bedat-low.
  CONCATENATE sy-datum(4) '1231' INTO ls_bedat-high.
  ls_bedat-sign     = 'E'.
  ls_bedat-option   = 'BT'.
  APPEND ls_bedat TO lr_bedat.
  CLEAR ls_bedat.

  lt_xpgmit[] = gt_pgmit[].
  DELETE lt_xpgmit WHERE werks <> so_werks-low.

  ls_006-prgrp    = pa_prgrp.
  ls_006-submi    = gs_x04z-submi.
  ls_006-zalno    = gs_x04z-zalno.
  LOOP AT gt_xalpo INTO ls_xalpo.
    READ TABLE lt_xpgmit INTO ls_xpgmit
                         WITH KEY matnr = ls_xalpo-matnr.
    IF sy-subrc <> 0.
      CONTINUE.
    ENDIF.
    ls_006-banfn    = ls_xalpo-banfn.
    ls_006-matnr    = ls_xalpo-matnr.
    APPEND ls_006 TO gt_006.
  ENDLOOP.

*ls_006-MATNR
*ls_006-ZEILE
*ls_006-LFDAT
*ls_006-BAMNG
*ls_006-BAMEI

  ls_007-prgrp    = pa_prgrp.
  ls_007-submi    = gs_x04z-submi.
  ls_007-zalno    = gs_x04z-zalno.
  LOOP AT gt_lfa1 INTO ls_lfa1.
    ls_007-lifnr    = ls_lfa1-lifnr.
    LOOP AT gt_alko INTO ls_alko WHERE lifnr = ls_lfa1-lifnr.
      IF ls_alko-bedat IN lr_bedat.
        CONTINUE.
      ENDIF.
      LOOP AT gt_xalpo INTO ls_xalpo WHERE ebeln = ls_alko-ebeln.
        READ TABLE lt_xpgmit INTO ls_xpgmit
                             WITH KEY matnr = ls_xalpo-matnr.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        ls_007-ebeln    = ls_xalpo-ebeln.
        ls_007-matnr    = ls_xalpo-matnr.
        ls_007-bstmg    = ls_xalpo-menge.
        ls_007-bstme    = ls_xalpo-meins.
        APPEND ls_007 TO gt_007.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

*  ls_007-ZEILE
*  ls_007-BEDAT
*  ls_007-NETPR
*  ls_007-PEINH
*  ls_007-BPRME
*  ls_007-NETWR
*  ls_007-WAERS
ENDFORM.                    " F_ALOKASI_PRGRP_FR_SYSTEM

*&---------------------------------------------------------------------*
*&      Form  F_LAST_PURCHASING_DATE
*&---------------------------------------------------------------------*
FORM f_last_purchasing_date  USING    fu_lifnr
                             CHANGING fc_value.
  DATA : lt_xekko TYPE STANDARD TABLE OF ekko,
         ls_xekko TYPE ekko.

  lt_xekko[] = gt_xekko[].
  DELETE lt_xekko WHERE lifnr <> fu_lifnr.
  SORT lt_xekko BY aedat DESCENDING ebeln DESCENDING.
  READ TABLE lt_xekko INTO ls_xekko INDEX 1.
  IF sy-subrc = 0.
    WRITE ls_xekko-aedat TO fc_value DD/MM/YYYY.
  ENDIF.
ENDFORM.                    " F_LAST_PURCHASING_DATE

*&---------------------------------------------------------------------*
*&      Form  F_LAST_PURCHASING_PRICE
*&---------------------------------------------------------------------*
FORM f_last_purchasing_price  USING    fu_lifnr
                              CHANGING fc_value.
  DATA : lt_xekko      TYPE STANDARD TABLE OF ekko,
         ls_xekko      TYPE ekko,
         ls_xekpo      TYPE ekpo,
         ls_xkonv      TYPE konv,
         lv_value1(30),
         lv_value2(30).

  lt_xekko[] = gt_xekko[].
  DELETE lt_xekko WHERE lifnr <> fu_lifnr.
  SORT lt_xekko BY aedat DESCENDING ebeln DESCENDING.
  READ TABLE lt_xekko INTO ls_xekko INDEX 1.
  IF sy-subrc = 0.
    CLEAR ls_xekpo.
    READ TABLE gt_xekpo INTO ls_xekpo
                        WITH KEY ebeln = ls_xekko-ebeln.

    SELECT SINGLE *
      FROM konv
      INTO CORRESPONDING FIELDS OF ls_xkonv
      WHERE knumv = ls_xekko-knumv
        AND kposn = ls_xekpo-ebelp
        AND kschl = 'ZPB0'.
    IF sy-subrc = 0.
      WRITE ls_xkonv-kbetr TO lv_value1 CURRENCY ls_xkonv-waers.
      CONDENSE lv_value1.
      WRITE ls_xkonv-kpein TO lv_value2 UNIT ls_xkonv-kmein.
      CONDENSE lv_value2.
      PERFORM f_meins_conversion USING ls_xkonv-kmein
                                 CHANGING ls_xkonv-kmein.
      CONCATENATE ls_xkonv-waers lv_value1 '/' lv_value2 ls_xkonv-kmein
      INTO lv_value1
      SEPARATED BY space.
      fc_value = lv_value1.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_LAST_PURCHASING_PRICE

*&---------------------------------------------------------------------*
*&      Form  F_PRINT_FPKH
*&---------------------------------------------------------------------*
FORM f_print_fpkh  USING    fu_proses fu_print
                   CHANGING fc_url fc_noform. " fc_lampiran.
  DATA : document     TYPE string.
  DATA: lv_werks TYPE werks_d.

  CLEAR : fc_url, fc_noform.
  TRANSLATE gv_plant TO UPPER CASE.
  CONDENSE: gv_plant.
  IF gv_plant IS NOT INITIAL.
    lv_werks = gv_plant.
  ELSE.
    lv_werks = so_werks-low.
  ENDIF.
  CALL FUNCTION 'ZHSMMM_FM004'
    EXPORTING
      proses  = fu_proses
      plant   = lv_werks
      matnr   = so_matnr-low
      tender  = pa_submi
    IMPORTING
      linkurl = fc_url
      noform  = fc_noform.
  " lampiran = fc_lampiran.

*  IF lv_url IS INITIAL.
*    lv_url = 'http://10.66.2.120:18080/tdn-middleware/controller/SAP/awb.php?file=shopee/2024-06-18/JT11257802898.pdf'.
*  ENDIF.

  document = fc_url.

  IF fu_print IS NOT INITIAL.
    CALL METHOD cl_gui_frontend_services=>execute
      EXPORTING
        document               = document
      EXCEPTIONS
        cntl_error             = 1
        error_no_gui           = 2
        bad_parameter          = 3
        file_not_found         = 4
        path_not_found         = 5
        file_extension_unknown = 6
        error_execute_failed   = 7
        synchronous_failed     = 8
        not_supported_by_gui   = 9
        OTHERS                 = 10.
  ENDIF.
ENDFORM.                    " F_PRINT_FPKH
*&---------------------------------------------------------------------*
*&      Form  F_UPDATE_PIR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_HPIR_LIFNR  text
*      -->P_GS_HPIR_MATNR  text
*      -->P_LS_DPIR_KBETR  text
*      -->P_LS_DPIR_SKONWA  text
*----------------------------------------------------------------------*
FORM f_update_pir  USING    p_lifnr
                            p_matnr
                            p_value
                            p_currency.

  DATA: lt_a018 TYPE STANDARD TABLE OF a018.
  DATA: ls_a018 TYPE a018.
  DATA: lt_bapieina LIKE bapieina OCCURS 0.
  DATA: lt_bapieine LIKE bapieine OCCURS 0.
  DATA: lt_bapireturn LIKE bapireturn OCCURS 0.
  DATA: "ls_a018 LIKE a018,
    ls_konp  LIKE konp,
    lv_harga LIKE konp-kbetr.
  DATA: ls_bapieina TYPE bapieina.
  DATA: ls_bapieine TYPE bapieine.
  DATA: lv_vendor   TYPE eina-lifnr,
        lv_material TYPE eina-matnr,
        lv_value    TYPE kbetr, "mewicondition_ty-cond_value,
        lv_currency TYPE mewicondition_ty-currency.

  DATA : lt_eina         TYPE mewieina_t,
         lt_eine         TYPE mewieine_t,
         t_eina          TYPE mewieina_t, "STANDARD TABLE OF mewieina,
         t_einax         TYPE mewieinax_t, "STANDARD TABLE OF
         t_eine          TYPE mewieine_t, "STANDARD TABLE OF
         t_einex         TYPE mewieinex_t, "STANDARD TABLE OF
         t_cond_validity TYPE mewivalidity_tt, "STANDARD TABLE OF
         t_condition     TYPE mewicondition_tt, "STANDARD TABLE OF
         t_return        TYPE mewi_tt_return. "STANDARD TABLE OF .
  DATA : ls_t_eina LIKE LINE OF lt_eina,
         ls_eina   LIKE LINE OF t_eina,
         ls_einax  LIKE LINE OF t_einax,
         ls_eine   LIKE LINE OF t_eine,
         ls_einex  LIKE LINE OF t_einex,
         ls_conval LIKE LINE OF t_cond_validity,
         ls_cond   LIKE LINE OF t_condition,
         ls_return LIKE LINE OF t_return.
  DATA: lv_text(20).

  lv_vendor = p_lifnr.
  lv_material = p_matnr.
  lv_value = p_value.
  lv_currency = p_currency.
  IF lv_currency = 'IDR'.
    WRITE lv_value TO lv_text CURRENCY lv_currency DECIMALS 0 NO-GROUPING NO-GAP.
  ELSE.
    WRITE lv_value TO lv_text CURRENCY lv_currency DECIMALS 2 NO-GROUPING NO-GAP.
  ENDIF.
  CONDENSE lv_text.
  REPLACE ALL OCCURRENCES OF ',' IN lv_text WITH '.' .
  lv_value = lv_text.
  CALL FUNCTION 'BAPI_INFORECORD_GETLIST'
    EXPORTING
      vendor              = lv_vendor
      material            = lv_material
      purch_org           = 'TNT'
      purchorg_data       = 'X'
      general_data        = 'X'
    TABLES
      inforecord_general  = lt_bapieina
      inforecord_purchorg = lt_bapieine
      return              = lt_bapireturn
    EXCEPTIONS
      OTHERS              = 0.

  IF sy-subrc EQ 0.
    LOOP AT lt_bapieina INTO ls_bapieina.
      IF ls_bapieina-info_rec IS INITIAL.
        CONTINUE.
      ENDIF.
      ls_eina-material  = ls_bapieina-material.
      ls_eina-vendor    = ls_bapieina-vendor.
      APPEND ls_eina TO t_eina.
      ls_einax-material  = 'X'.
      ls_einax-vendor    = 'X'.
      APPEND ls_einax TO t_einax.

    ENDLOOP.
    LOOP AT lt_bapieine  INTO ls_bapieine .
      IF ls_bapieine-info_rec IS INITIAL.
        CONTINUE.
      ENDIF.
      ls_eine-eine_indx  = '01'.
      ls_eine-purch_org  = ls_bapieine-purch_org.
      ls_eine-info_type  = ls_bapieine-info_type.
      ls_eine-pur_group  = ls_bapieine-pur_group.
      ls_eine-currency   = ls_bapieine-currency.
      ls_eine-plnd_delry = ls_bapieine-plnd_delry.
      APPEND ls_eine TO t_eine.
      ls_einex-eine_indx  = '01'.
      ls_einex-purch_org  = 'X'.
      ls_einex-info_type  = 'X'.
      ls_einex-pur_group  = 'X'.
      ls_einex-currency   = 'X'.
      ls_einex-plnd_delry = 'X'.
      APPEND ls_einex TO t_einex.

    ENDLOOP.

    SELECT SINGLE * INTO ls_a018
      FROM a018 WHERE kappl = 'M'
                  AND lifnr = lv_vendor
                  AND matnr = lv_material
                  AND ekorg = 'TNT'
                  AND datbi GE sy-datum
                  AND datab LE sy-datum.

    ls_conval-eine_indx  = '01'.
    ls_conval-serial_id  = '01'.
    ls_conval-valid_from = ls_a018-datab. "'20250205'.
    ls_conval-valid_to   = ls_a018-datbi. "'99991230'.
    APPEND ls_conval TO t_cond_validity.


    ls_cond-eine_indx   = '01'.
    ls_cond-serial_id   = '01'.
    ls_cond-cond_count = '00'.
    ls_cond-cond_type = 'ZPB0'.
    ls_cond-cond_value = lv_text. "lv_value.
    ls_cond-currency  = lv_currency.
    APPEND ls_cond TO t_condition.

    CALL FUNCTION 'ME_INFORECORD_MAINTAIN_MULTI'
      EXPORTING
        testrun       = ''
      IMPORTING
        et_eina       = lt_eina
        et_eine       = lt_eine
      TABLES
        t_eina        = t_eina
        t_einax       = t_einax
        t_eine        = t_eine
        t_einex       = t_einex
        cond_validity = t_cond_validity "MEWIVALIDITY_TT OPTIONAL
        condition     = t_condition "TYPE  MEWICONDITION_TT OPTIONAL
        return        = t_return.
    DATA: lv_return TYPE bapiret2.
    LOOP AT t_return INTO ls_return WHERE type = 'S'.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait   = 'X'
        IMPORTING
          return = lv_return.
    ENDLOOP.


  ENDIF.



ENDFORM.
