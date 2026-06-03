*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_EX01F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_SELECTION_SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection_screen_output .
  PERFORM f_modify_screen USING : '' '' '' '' ''.
ENDFORM.                    " F_SELECTION_SCREEN_OUTPUT

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
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

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_MODIFY_SCREEN

*&---------------------------------------------------------------------*
*&      Form  F_STATUS
*&---------------------------------------------------------------------*
FORM f_status .
  DATA fcode    TYPE TABLE OF sy-ucomm.

  CASE sy-dynnr.
    WHEN '0400'.
      SET PF-STATUS 'STATUS001'.
      SET TITLEBAR 'TITLE002'.
    WHEN '0900'.
      IF gt_caufv[] IS INITIAL.
        APPEND '&POS' TO fcode.
      ENDIF.
      IF gt_xerror[] IS INITIAL.
        APPEND '&LOG' TO fcode.
      ENDIF.

      SET PF-STATUS 'STATUS001' EXCLUDING fcode.
      SET TITLEBAR 'TITLE001'.
  ENDCASE.
ENDFORM.                    " F_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_EXIT
*&---------------------------------------------------------------------*
FORM f_exit .
  CASE sy-dynnr.
    WHEN '0400'.
      CLEAR : gt_notes[].
  ENDCASE.
  LEAVE TO SCREEN 0.
ENDFORM.                    " F_EXIT

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TC_ORDER
*&---------------------------------------------------------------------*
FORM f_fill_tc_order .

  READ TABLE gt_order INTO gs_order INDEX tc_order-current_line.

ENDFORM.                    " F_FILL_TC_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_READ_TC_ORDER
*&---------------------------------------------------------------------*
FORM f_read_tc_order .

ENDFORM.                    " F_READ_TC_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_PBO
*&---------------------------------------------------------------------*
FORM f_pbo .
  DATA : lv_field   TYPE vrm_id,
         ls_caufv   LIKE LINE OF gt_caufv,
         ls_values  TYPE vrm_value,
         lv_aufnr(12),
         ls_xmara   LIKE LINE OF gt_xmara.

  DATA : ls_order   LIKE LINE OF gt_order,
         lt_itab    TYPE ta_itab1 OCCURS 0 WITH HEADER LINE,
         ls_notes   LIKE LINE OF gt_notes.

  CASE sy-dynnr.
    WHEN '0400'.
      IF gt_notes[] IS INITIAL.
        lt_itab[] = i_itab1[].
        SORT lt_itab BY gstrp.
        DELETE ADJACENT DUPLICATES FROM lt_itab COMPARING gstrp.
        LOOP AT lt_itab.
          ls_notes-gstrp = lt_itab-gstrp.
          APPEND ls_notes TO gt_notes.
          CLEAR ls_notes.
        ENDLOOP.
      ENDIF.

      CLEAR fnotes.
      DESCRIBE TABLE gt_notes LINES fnotes.
      tc_notes-lines = fnotes.

    WHEN OTHERS.
      CLEAR : forder, fmaterial.

      gv_delete = icon_delete.

      PERFORM f_get_order.
      DESCRIBE TABLE gt_order LINES forder.
      tc_order-lines = forder.

      DESCRIBE TABLE gt_material LINES fmaterial.
      tc_material-lines = fmaterial.

      IF pa_order IS INITIAL.
        CLEAR gt_values[].
        LOOP AT gt_caufv INTO ls_caufv.
          lv_aufnr        = ls_caufv-aufnr.
          ls_values-key   = lv_aufnr.
          ls_values-text  = lv_aufnr.
          APPEND ls_values TO gt_values.
        ENDLOOP.

        lv_field = 'LIST_AUFNR'.
        CALL FUNCTION 'VRM_SET_VALUES'
          EXPORTING
            id     = lv_field
            values = gt_values.

        CLEAR gt_material[].
        IF list_aufnr IS NOT INITIAL.
          LOOP AT gt_xmara INTO ls_xmara WHERE aufnr = list_aufnr.
            APPEND ls_xmara TO gt_material.
            CLEAR ls_xmara.
          ENDLOOP.
        ENDIF.
      ELSE.
        PERFORM f_modify_screen USING : 'ORD' '0' '' '' ''.

        CLEAR gt_material[].

        LOOP AT gt_xmara INTO ls_xmara WHERE aufnr = list_aufnr.
          APPEND ls_xmara TO gt_material.
          CLEAR ls_xmara.
        ENDLOOP.
      ENDIF.
  ENDCASE.
ENDFORM.                    " F_PBO

*&---------------------------------------------------------------------*
*&      Form  F_PAI
*&---------------------------------------------------------------------*
FORM f_pai .
  DATA : ls_xmara    LIKE LINE OF gt_xmara.

  LOOP AT gt_xmara INTO ls_xmara
                   WHERE aufnr = list_aufnr.

  ENDLOOP.
ENDFORM.                    " F_PAI

*&---------------------------------------------------------------------*
*&      Form  F_GET_ORDER
*&---------------------------------------------------------------------*
FORM f_get_order .
  DATA : ls_caufv   LIKE LINE OF gt_caufv,
         ls_afpo    LIKE LINE OF gt_afpo,
         ls_order   LIKE LINE OF gt_order.

  CLEAR : ls_caufv, gt_order[].
  LOOP AT gt_caufv INTO ls_caufv.
    CLEAR ls_afpo.
    READ TABLE gt_afpo INTO ls_afpo
                       WITH KEY aufnr = ls_caufv-aufnr.
    IF sy-subrc = 0.
      ls_order-aufnr  = ls_caufv-aufnr.
      ls_order-ktext  = ls_caufv-ktext.
      ls_order-plnbez = ls_caufv-plnbez.
      ls_order-charg  = ls_afpo-charg.
      ls_order-gstrp  = ls_caufv-gstrp.
      APPEND ls_order TO gt_order.
      CLEAR ls_order.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_GET_ORDER

*&---------------------------------------------------------------------*
*&      Form  F_F4_AUFNR
*&---------------------------------------------------------------------*
FORM f_f4_aufnr .

ENDFORM.                    " F_F4_AUFNR

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TC_MATERIAL
*&---------------------------------------------------------------------*
FORM f_fill_tc_material .
  DATA : lv_mtart   TYPE mara-mtart.

  READ TABLE gt_material INTO gs_material INDEX tc_material-current_line.
  IF sy-subrc = 0.
    SELECT SINGLE meins maktx mtart
      FROM mara JOIN makt ON mara~matnr = makt~matnr
      INTO (gs_material-meins, gs_material-maktx, lv_mtart)
      WHERE mara~matnr = gs_material-matnr
        AND makt~spras = sy-langu.
    IF sy-subrc = 0.
      IF pa_mtart <> lv_mtart.
        IF gs_material-icon IS INITIAL.
          gs_material-icon = icon_led_red.
          PERFORM f_add_error_message USING 'Material' gs_material-matnr 'salah type' ''
                                            tc_material-current_line ''.
        ENDIF.
      ELSE.
        PERFORM f_bom_validate USING gs_material-matnr gs_material-bdmng
                                     tc_material-current_line
                               CHANGING gs_material-icon.
      ENDIF.
    ELSE.
      IF gs_material-icon IS INITIAL.
        gs_material-icon = icon_led_red.
        PERFORM f_add_error_message USING 'Material' gs_material-matnr 'salah' ''
                                          tc_material-current_line ''.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gt_material[] IS INITIAL.
    PERFORM f_cursor_position USING 'GS_MATERIAL-MATNR' 1.
  ELSE.
    IF gs_material-matnr IS INITIAL AND
      gs_material-bdmng IS INITIAL.
      IF gv_isi IS NOT INITIAL.
        PERFORM f_cursor_position USING 'GS_MATERIAL-MATNR'
                                        tc_material-current_line.
      ENDIF.
      CLEAR gv_isi.
    ELSEIF gs_material-matnr IS INITIAL.
      PERFORM f_cursor_position USING 'GS_MATERIAL-MATNR'
                                      tc_material-current_line.
    ELSEIF gs_material-bdmng IS INITIAL.
      PERFORM f_cursor_position USING 'GS_MATERIAL-BDMNG'
                                      tc_material-current_line.
      CLEAR gv_isi.
    ELSE.
      gv_isi = 'X'.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_FILL_TC_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_READ_TC_MATERIAL
*&---------------------------------------------------------------------*
FORM f_read_tc_material .

  IF pa_order IS INITIAL.
    IF list_aufnr IS NOT INITIAL.
      PERFORM f_add_material USING tc_material-current_line.
    ENDIF.
  ELSE.
    PERFORM f_add_material USING tc_material-current_line.
  ENDIF.
ENDFORM.                    " F_READ_TC_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_USER_COMMAND_900
*&---------------------------------------------------------------------*
FORM f_user_command_900 .
  DATA : lv_code    TYPE sy-ucomm,
         lv_line    TYPE i,
         ls_xmara   LIKE LINE OF gt_xmara.

  lv_code = ok_code.
  CLEAR ok_code.

  CASE lv_code.
    WHEN 'SELECT'.

    WHEN 'CONT'.
      PERFORM f_move_data.

    WHEN '&DELETE'.
      GET CURSOR LINE lv_line.
      PERFORM f_delete_data USING lv_line.

    WHEN '&STATUS'.
      GET CURSOR LINE lv_line.
      PERFORM f_display_message USING lv_line.

    WHEN '&LOG'.
      DESCRIBE TABLE gt_xerror LINES lv_line.
      IF lv_line = 1.
        APPEND INITIAL LINE TO gt_xerror.
      ENDIF.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = gt_xerror.

    WHEN '&POS'.
      CASE sy-dynnr.
        WHEN '0400'.
          LEAVE TO SCREEN 0.
        WHEN OTHERS.
          READ TABLE gt_xmara INTO ls_xmara
                              WITH KEY icon  = icon_led_red.
          IF sy-subrc <> 0.
            READ TABLE gt_xmara INTO ls_xmara
                        WITH KEY icon = icon_led_green
                                        bdmng = space.
            IF sy-subrc = 0.
              MESSAGE s000(zab) WITH 'Quantity kosong' DISPLAY LIKE 'E'.
            ELSE.
              PERFORM f_posting_data.
            ENDIF.
          ELSE.
            MESSAGE s000(zab) WITH 'Masih ada error data' DISPLAY LIKE 'E'.
          ENDIF.
      ENDCASE.
  ENDCASE.
ENDFORM.                    " F_USER_COMMAND_900

*&---------------------------------------------------------------------*
*&      Form  F_MOVE_DATA
*&---------------------------------------------------------------------*
FORM f_move_data .
  DATA : ls_material    LIKE LINE OF gt_material,
         ls_xmara       LIKE LINE OF gt_xmara.

  IF gt_material[] IS NOT INITIAL.
    READ TABLE gt_material INTO ls_material INDEX 1.
    IF sy-subrc = 0.
      DELETE gt_xmara WHERE aufnr = ls_material-aufnr.
    ENDIF.

    APPEND LINES OF gt_material TO gt_xmara.
  ENDIF.
ENDFORM.                    " F_MOVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_CURSOR_POSITION
*&---------------------------------------------------------------------*
FORM f_cursor_position USING fu_field fu_pos.
  IF list_aufnr IS NOT INITIAL.
    SET CURSOR FIELD fu_field LINE fu_pos.
  ENDIF.
ENDFORM.                    " F_CURSOR_POSITION

*&---------------------------------------------------------------------*
*&      Form  F_DELETE_DATA
*&---------------------------------------------------------------------*
FORM f_delete_data USING fu_line.
  DATA : ls_material  LIKE LINE OF gt_material.

  LOOP AT gt_material INTO ls_material WHERE mark IS NOT INITIAL.
    IF ls_material-icon = icon_led_red.
      DELETE gt_error WHERE row = fu_line.
    ENDIF.

    ls_material-icon  = icon_delete.
    MODIFY gt_material FROM ls_material
                       TRANSPORTING icon.

    MODIFY gt_xmara FROM ls_material
                    TRANSPORTING icon
                    WHERE aufnr = ls_material-aufnr
                      AND rspos = ls_material-rspos.
    CLEAR ls_material.
  ENDLOOP.
ENDFORM.                    " F_DELETE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_RESERVATION_CREATE
*&---------------------------------------------------------------------*
FORM f_reservation_create TABLES   ft_items    STRUCTURE bapiresbc
                                   ft_return   STRUCTURE bapiret2
                          USING    fs_header   TYPE bapirkpfc
                          CHANGING fc_reservation.

  DATA : erkpf    TYPE STANDARD TABLE OF erkpf.

  DATA : ls_return    TYPE bapiret2.

  CALL FUNCTION 'BAPI_RESERVATION_CREATE'
    EXPORTING
      reservation_header = fs_header
      no_commit          = 'X'
      movement_auto      = 'X'
    IMPORTING
      reservation        = fc_reservation
    TABLES
      reservation_items  = ft_items
      return             = ft_return.

  IF fc_reservation IS INITIAL.
    LOOP AT ft_return INTO ls_return.
      PERFORM f_bapi_message_get USING ls_return-id ls_return-number
                                 CHANGING ls_return-message_v1.
      APPEND ls_return TO gt_error.
      CLEAR ls_return.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_RESERVATION_CREATE

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA
*&---------------------------------------------------------------------*
FORM f_prepare_data  TABLES   ft_items    STRUCTURE bapiresbc
                              ft_ltba     STRUCTURE ltba
                     USING    fu_aufnr fu_gstrp
                     CHANGING fs_header   TYPE bapirkpfc.
  DATA : ls_xmara       LIKE LINE OF gt_xmara,
         ls_items       TYPE bapiresbc,
         ls_warehouse   LIKE LINE OF gt_warehouse,
         ls_ltba        LIKE LINE OF gt_ltba,
         lv_movtype     TYPE bwart,
         lv_no          TYPE i.

  CLEAR : fs_header, ft_items, ft_items[], ft_ltba, ft_ltba[].

  lv_movtype = '311'.

  fs_header-plant      = p_werks.
  fs_header-res_date   = fu_gstrp.
  fs_header-created_by = sy-uname.
  fs_header-move_type  = lv_movtype.
  fs_header-move_plant = p_werks.
  fs_header-move_stloc = p_lgort.
  IF fu_aufnr IS NOT INITIAL.
    fs_header-gr_rcpt    = fu_aufnr.
  ENDIF.

  LOOP AT gt_xmara INTO ls_xmara WHERE aufnr = fu_aufnr
                                   AND icon  = icon_led_green.
    ls_items-material   = ls_xmara-matnr.
    ls_items-plant      = p_werks.
    ls_items-store_loc  = p_umlgo.
    ls_items-quantity   = ls_xmara-bdmng.
    ls_items-unit       = ls_xmara-meins.
    ls_items-req_date   = ls_xmara-gstrp.
    APPEND ls_items TO ft_items.
    CLEAR ls_items.

    CLEAR ls_warehouse.
    READ TABLE gt_warehouse INTO ls_warehouse WITH KEY werks = p_werks
                                                       lgort = p_umlgo.
    IF sy-subrc = 0 AND ls_warehouse-lgnum <> ''.
      ADD 1 TO lv_no.
      ls_ltba-lgnum = ls_warehouse-lgnum.
      ls_ltba-matnr = ls_xmara-matnr.
      ls_ltba-werks = p_werks.
      ls_ltba-lgort = p_umlgo.
      ls_ltba-menga = ls_xmara-bdmng.
      ls_ltba-altme = ls_xmara-meins.
      ls_ltba-rspos = lv_no.
      ls_ltba-bwlvs = lv_movtype.
      APPEND ls_ltba TO ft_ltba.
      CLEAR ls_ltba.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_PREPARE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_GET_BOM
*&---------------------------------------------------------------------*
FORM f_get_bom .
  DATA : lt_caufv   TYPE STANDARD TABLE OF caufv,
         ls_caufv   LIKE LINE OF lt_caufv,
         stb        TYPE STANDARD TABLE OF stpox,
         ls_stb     LIKE LINE OF stb,
         ls_bom     LIKE LINE OF gt_bom.

  DATA : ls_order_objects  LIKE bapi_pi_order_objects,
         lt_component      TYPE TABLE OF bapi_order_component WITH HEADER LINE.

  lt_caufv[] = gt_caufv[].
  SORT lt_caufv BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_caufv COMPARING aufnr.

  LOOP AT lt_caufv INTO ls_caufv.
    CLEAR: ls_order_objects,lt_component,lt_component[].
    ls_order_objects-components = 'X'.

    CALL FUNCTION 'BAPI_PROCORD_GET_DETAIL'
      EXPORTING
        number        = ls_caufv-aufnr
        order_objects = ls_order_objects
      TABLES
        component     = lt_component.

    LOOP AT lt_component.
      ls_bom-matnr  = lt_component-material.
      APPEND ls_bom TO gt_bom.
      CLEAR ls_bom.
    ENDLOOP.
  ENDLOOP.

*  lt_caufv[] = gt_caufv[].
*  SORT lt_caufv BY plnbez.
*  DELETE ADJACENT DUPLICATES FROM lt_caufv COMPARING plnbez.
*
*  LOOP AT lt_caufv INTO ls_caufv.
*    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
*      EXPORTING
*        capid                 = 'BEST'
*        datuv                 = sy-datum
*        mehrs                 = 'X'
*        mtnrv                 = ls_caufv-plnbez
*        werks                 = p_werks
*        stlal                 = ls_caufv-stlal
*        stlan                 = ls_caufv-stlan
*      TABLES
*        stb                   = stb
*      EXCEPTIONS
*        alt_not_found         = 1
*        call_invalid          = 2
*        material_not_found    = 3
*        missing_authorization = 4
*        no_bom_found          = 5
*        no_plant_data         = 6
*        no_suitable_bom_found = 7
*        conversion_error      = 8
*        OTHERS                = 9.
*
*    LOOP AT stb INTO ls_stb.
*      ls_bom-matnr  = ls_stb-idnrk.
*      APPEND ls_bom TO gt_bom.
*      CLEAR ls_bom.
*    ENDLOOP.
*  ENDLOOP.

  SORT gt_bom BY matnr.
  DELETE ADJACENT DUPLICATES FROM gt_bom COMPARING matnr.
ENDFORM.                    " F_GET_BOM

*&---------------------------------------------------------------------*
*&      Form  F_CREATE_TR
*&---------------------------------------------------------------------*
FORM f_create_tr .
  DATA : lv_objnr        LIKE jest-objnr,
         estat_inactive  LIKE tj30-estat VALUE 'E0001',
         estat_active    LIKE tj30-estat VALUE 'E0002',
         ls_chgsts       LIKE LINE OF i_chgsts.

  PERFORM f_aufnr_change_status.

  LOOP AT i_zgdppdt0001 INTO wa_zgdppdt0001.
*    IF p_mtart = 'ZRM'.
    CONCATENATE 'OR' wa_zgdppdt0001-aufnr INTO lv_objnr.

    CALL FUNCTION 'I_CHANGE_STATUS' IN UPDATE TASK
      EXPORTING
        objnr          = lv_objnr
        estat_inactive = estat_inactive
        estat_active   = estat_active.

    COMMIT WORK.
*    ENDIF.

    PERFORM f_change_status_detail USING wa_zgdppdt0001-aufnr.
  ENDLOOP.

  LOOP AT i_chgsts INTO ls_chgsts.
*    IF p_mtart = 'ZRM'.
    CONCATENATE 'OR' ls_chgsts-aufnr INTO lv_objnr.

    CALL FUNCTION 'I_CHANGE_STATUS' IN UPDATE TASK
      EXPORTING
        objnr          = lv_objnr
        estat_inactive = estat_inactive
        estat_active   = estat_active.

    COMMIT WORK.
*    ENDIF.

    PERFORM f_change_status_detail USING ls_chgsts-aufnr.
  ENDLOOP.

  IF gt_ltba[] IS NOT INITIAL.
    PERFORM f_call_func_create_tr.
  ENDIF.
ENDFORM.                    " F_CREATE_TR

*&---------------------------------------------------------------------*
*&      Form  F_ADD_MATERIAL
*&---------------------------------------------------------------------*
FORM f_add_material  USING    fu_line.
  DATA : ls_order   LIKE LINE OF gt_order,
         ls_xmara   LIKE LINE OF gt_xmara.

  gs_material-rspos = fu_line.
  gs_material-aufnr = list_aufnr.
  IF pa_order IS INITIAL.
    READ TABLE gt_order INTO ls_order
                        WITH KEY aufnr = list_aufnr.
  ELSE.
    READ TABLE gt_order INTO ls_order INDEX 1.
  ENDIF.

  IF sy-subrc = 0.
    gs_material-gstrp   = ls_order-gstrp.
  ENDIF.

  MODIFY gt_material FROM gs_material INDEX fu_line.
  IF sy-subrc <> 0.
    APPEND gs_material TO gt_material.
  ELSE.
    ls_xmara-icon  = gs_material-icon.
    ls_xmara-gstrp = gs_material-gstrp.
    MODIFY gt_xmara FROM ls_xmara
                    TRANSPORTING icon gstrp
                    WHERE aufnr = list_aufnr
                      AND rspos = gs_material-rspos.
  ENDIF.
ENDFORM.                    " F_ADD_MATERIAL

*&---------------------------------------------------------------------*
*&      Form  F_POSTING_DATA
*&---------------------------------------------------------------------*
FORM f_posting_data .
  DATA : lt_xmara   TYPE STANDARD TABLE OF ty_material,
         ls_xmara   LIKE LINE OF lt_xmara,
         lt_ltba    TYPE STANDARD TABLE OF ltba,
         ls_error   LIKE LINE OF gt_error.

  DATA : reservation_header   TYPE bapirkpfc,
         reservation          TYPE bapirkpfc-res_no,
         reservation_items    TYPE STANDARD TABLE OF bapiresbc,
         return               TYPE STANDARD TABLE OF bapiret2.

  IF pa_order IS INITIAL.
    lt_xmara[] = gt_xmara[].
    SORT lt_xmara BY aufnr.
    LOOP AT lt_xmara INTO ls_xmara.
      CLEAR : reservation_items[], reservation_header.

      PERFORM f_prepare_data TABLES reservation_items
                                    lt_ltba
                             USING  ls_xmara-aufnr ls_xmara-gstrp
                             CHANGING reservation_header.

      IF reservation_items[] IS NOT INITIAL.
        PERFORM f_reservation_create TABLES reservation_items
                                            return
                                     USING reservation_header
                                     CHANGING reservation.

        PERFORM f_save_data TABLES reservation_items
                            USING reservation.

        PERFORM f_prepare_data_tr TABLES lt_ltba
                                  USING reservation.
      ELSE.
        PERFORM f_add_error_message USING 'Tidak ada items data' '' '' ''
                                          '' ''.
      ENDIF.
    ENDLOOP.
  ELSE.
    READ TABLE gt_xmara INTO ls_xmara INDEX 1.
    IF sy-subrc = 0.
      PERFORM f_prepare_data TABLES reservation_items
                                    lt_ltba
                             USING  '' ls_xmara-gstrp
                             CHANGING reservation_header.

      IF reservation_items[] IS NOT INITIAL.
        PERFORM f_reservation_create TABLES reservation_items
                                            return
                                     USING reservation_header
                                     CHANGING reservation.

        PERFORM f_save_data TABLES reservation_items
                            USING reservation.

        PERFORM f_prepare_data_tr TABLES lt_ltba
                                  USING reservation.
      ELSE.
        PERFORM f_add_error_message USING 'Tidak ada items data' '' '' ''
                                          '' ''.
      ENDIF.
    ENDIF.
  ENDIF.

  IF gt_error[] IS NOT INITIAL.
    CLEAR ls_error.
    READ TABLE gt_error INTO ls_error WITH KEY row = space.
    IF sy-subrc = 0.
      MESSAGE s000(zab) WITH ls_error-message_v1 DISPLAY LIKE 'E'.
    ENDIF.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    PERFORM f_create_tr.

    MESSAGE s060(m7) WITH reservation.
    LEAVE TO SCREEN 0.
  ENDIF.
ENDFORM.                    " F_POSTING_DATA

*&---------------------------------------------------------------------*
*&      Form  F_BOM_VALIDATE
*&---------------------------------------------------------------------*
FORM f_bom_validate  USING    fu_matnr fu_bdmng fu_line
                     CHANGING fc_icon.
  DATA : ls_bom     LIKE LINE OF gt_bom.

  READ TABLE gt_bom INTO ls_bom
                    WITH KEY matnr = fu_matnr.
  IF sy-subrc <> 0.
    IF fc_icon IS INITIAL.
      fc_icon = icon_led_red.
      PERFORM f_add_error_message USING 'Material' fu_matnr 'bukan material BOM' ''
                                        fu_line ''.
    ENDIF.
  ELSE.
    IF fc_icon IS INITIAL AND fu_bdmng IS NOT INITIAL.
      fc_icon = icon_led_green.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_BOM_VALIDATE

*&---------------------------------------------------------------------*
*&      Form  F_ADD_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_add_error_message  USING    fu_v1 fu_v2 fu_v3 fu_v4 fu_row fu_err.

  DATA : ls_error   LIKE LINE OF gt_error.

  ls_error-type         = 'E'.
  ls_error-id           = 'ZAB'.
  ls_error-number       = '000'.
  ls_error-message_v1   = fu_v1.
  ls_error-message_v2   = fu_v2.
  ls_error-message_v3   = fu_v3.
  ls_error-message_v4   = fu_v4.
  ls_error-row          = fu_row.
  IF fu_err IS INITIAL.
    APPEND ls_error TO gt_error.
  ELSE.
    APPEND ls_error TO gt_xerror.
  ENDIF.
  CLEAR ls_error.
ENDFORM.                    " F_ADD_ERROR_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY_MESSAGE
*&---------------------------------------------------------------------*
FORM f_display_message  USING    fu_row.
  DATA : lt_error       TYPE STANDARD TABLE OF bapiret2,
         ls_error       LIKE LINE OF gt_error,
         ls_material    LIKE LINE OF gt_material,
         ls_xmara       LIKE LINE OF gt_xmara,
         lv_lines       TYPE i.

  READ TABLE gt_material INTO ls_material INDEX fu_row.
  IF sy-subrc = 0.
    IF ls_material-icon = icon_led_red.
      LOOP AT gt_error INTO ls_error WHERE row = fu_row.
        APPEND ls_error TO lt_error.
        CLEAR ls_error.
      ENDLOOP.
      DESCRIBE TABLE lt_error LINES lv_lines.
      IF lv_lines = 1.
        APPEND INITIAL LINE TO lt_error.
      ENDIF.
      CALL FUNCTION 'C14ALD_BAPIRET2_SHOW'
        TABLES
          i_bapiret2_tab = lt_error.
    ELSEIF ls_material-icon = icon_delete.
      CLEAR ls_xmara-icon.
      MODIFY gt_xmara FROM ls_xmara
                      TRANSPORTING icon
                      WHERE aufnr = ls_material-aufnr
                        AND rspos = ls_material-rspos
                        AND matnr = ls_material-matnr.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_DISPLAY_MESSAGE

*&---------------------------------------------------------------------*
*&      Form  F_BAPI_MESSAGE_GET
*&---------------------------------------------------------------------*
FORM f_bapi_message_get  USING    fu_id fu_number
                         CHANGING fc_message.
  DATA : return     TYPE bapiret2,
         lv_field(20),
         ls_erkpf   TYPE erkpf,
         message    TYPE bapiret2-message.

  FIELD-SYMBOLS <fs>  TYPE erkpf.

  SELECT SINGLE *
    FROM t100a
    WHERE arbgb = fu_id.
  IF sy-subrc <> 0.
    ASSIGN ('(SAPLMEWB)ERKPF') TO <fs>.
    ls_erkpf  = <fs>.
    CALL FUNCTION 'BAPI_MESSAGE_GETDETAIL'
      EXPORTING
        id         = ls_erkpf-msgid
        number     = ls_erkpf-msgno
        textformat = 'NON'
      IMPORTING
        message    = message.
    fc_message = message.
  ENDIF.
ENDFORM.                    " F_BAPI_MESSAGE_GET

*&---------------------------------------------------------------------*
*&      Form  F_NEW_VALIDATE_DATA_BAPI
*&---------------------------------------------------------------------*
FORM f_new_validate_data_bapi .
  DATA : lt_itab1 TYPE ta_itab1 OCCURS 0 WITH HEADER LINE,
         ls_itab1 LIKE LINE OF lt_itab1.
  DATA : lt_warehouse      TYPE STANDARD TABLE OF t320,
         ls_warehouse      TYPE t320,
         lt_ltba           TYPE STANDARD TABLE OF ltba,
         ls_ltba           LIKE LINE OF gt_ltba.

  DATA : lv_res_no    LIKE bapirkpfc-res_no,
         lv_movtype   TYPE bwart,
         lv_no        TYPE i.

  DATA : ls_notes     LIKE LINE OF gt_notes.

  REFRESH: i_bapiresbc, i_bapireturn, i_itab2, i_itab_tmp.
  CLEAR: wa_itab, wa_bapirkpfc, wa_bapiresbc, i_itab2, i_itab_tmp,
        i_bapiresbc,i_bapireturn.

  SELECT * INTO TABLE lt_warehouse
    FROM t320
    WHERE werks EQ p_werks
      AND lgort EQ p_umlgo.

  lt_itab1[] = i_itab1[].
  SORT lt_itab1 BY werks gstrp.
  DELETE ADJACENT DUPLICATES FROM lt_itab1 COMPARING werks gstrp.

  lv_movtype = '311'.

  LOOP AT lt_itab1 INTO ls_itab1.
    wa_bapirkpfc-plant      = ls_itab1-werks.
    wa_bapirkpfc-res_date   = ls_itab1-gstrp.
    wa_bapirkpfc-created_by = ls_itab1-name.
    wa_bapirkpfc-move_type  = lv_movtype.
    wa_bapirkpfc-move_plant = ls_itab1-werks.
    wa_bapirkpfc-move_stloc = p_lgort.

    CLEAR lv_no.
    LOOP AT i_itab1 INTO wa_itab1 WHERE werks = ls_itab1-werks
                                    AND gstrp = ls_itab1-gstrp.
      ADD 1 TO lv_no.
      wa_bapiresbc-material   = wa_itab1-matnr.
      wa_bapiresbc-plant      = p_werks.
      wa_bapiresbc-store_loc  = p_umlgo.
      wa_bapiresbc-quantity   = wa_itab1-bdmng.
      wa_bapiresbc-unit       = wa_itab1-meins.
      wa_bapiresbc-req_date   = wa_itab1-gstrp.
      CLEAR ls_notes.
      READ TABLE gt_notes INTO ls_notes
                          WITH KEY gstrp = ls_itab1-gstrp.
      IF sy-subrc = 0.
        wa_bapiresbc-short_text = ls_notes-sgtxt.
      ENDIF.
      APPEND wa_bapiresbc TO i_bapiresbc.
      APPEND wa_itab1 TO i_itab_tmp.

      CLEAR ls_warehouse.
      READ TABLE lt_warehouse INTO ls_warehouse WITH KEY werks = wa_itab1-werks
                                                         lgort = p_umlgo.
      IF sy-subrc = 0 AND ls_warehouse-lgnum <> ''.
        ls_ltba-lgnum = ls_warehouse-lgnum.
        ls_ltba-matnr = wa_itab1-matnr.
        ls_ltba-werks = wa_itab1-werks.
        ls_ltba-lgort = p_umlgo.
        ls_ltba-menga = wa_itab1-bdmng.
        ls_ltba-altme = wa_itab1-meins.
        ls_ltba-rspos = lv_no.
        ls_ltba-bwlvs = lv_movtype.
        APPEND ls_ltba TO lt_ltba.
        CLEAR ls_ltba.
      ENDIF.

      CLEAR: wa_itab1.
    ENDLOOP.

    CLEAR lv_res_no.
    PERFORM f_bapi_reservation CHANGING lv_res_no.

    CLEAR ls_ltba.
    LOOP AT lt_ltba INTO ls_ltba.
      ls_ltba-tbktx = lv_res_no.
      APPEND ls_ltba TO gt_ltba.
      CLEAR ls_ltba.
    ENDLOOP.

    REFRESH: i_itab_tmp, i_bapiresbc, lt_ltba.
    CLEAR: i_itab_tmp, i_bapiresbc, wa_bapiresbc, lt_ltba.
  ENDLOOP.

  DELETE ADJACENT DUPLICATES FROM i_link COMPARING ALL FIELDS.

ENDFORM.                    " F_NEW_VALIDATE_DATA_BAPI

*&---------------------------------------------------------------------*
*&      Form  F_CALL_FUNC_CREATE_TR
*&---------------------------------------------------------------------*
FORM f_call_func_create_tr .
  DATA : lw_ltba     TYPE ltba.
  DATA : lt_ltba     TYPE STANDARD TABLE OF ltba,
         lt_xltba    TYPE STANDARD TABLE OF ltba,
         ls_ltba     LIKE LINE OF lt_ltba.

  lt_ltba[] = gt_ltba[].
  SORT lt_ltba BY tbktx.
  DELETE ADJACENT DUPLICATES FROM lt_ltba COMPARING tbktx.

  LOOP AT lt_ltba INTO ls_ltba.
    CLEAR : lt_xltba[].
    LOOP AT gt_ltba INTO lw_ltba WHERE tbktx = ls_ltba-tbktx.
      APPEND lw_ltba TO lt_xltba.
      CLEAR lw_ltba.
    ENDLOOP.

    CALL FUNCTION 'L_TR_CREATE'
      EXPORTING
        i_single_item         = ''
        i_save_only_all       = 'X'
      TABLES
        t_ltba                = lt_xltba
      EXCEPTIONS
        item_error            = 1
        no_entry_in_int_table = 2
        item_without_number   = 3
        no_update_item_error  = 4
        OTHERS                = 5.

    LOOP AT lt_xltba INTO ls_ltba.
      lw_ltba-tbnum = ls_ltba-tbnum.
      MODIFY gt_ltba FROM lw_ltba TRANSPORTING tbnum
                                  WHERE tbktx = ls_ltba-tbktx.
    ENDLOOP.
  ENDLOOP.

  LOOP AT gt_ltba INTO lw_ltba WHERE tbnum IS INITIAL.
    MESSAGE i000(zgd) WITH 'Failed to create TR for reservation ' lw_ltba-tbktx.
    EXIT.
  ENDLOOP.

  IF gt_ltba[] IS INITIAL.
    MESSAGE i000(zgd) WITH 'Failed to create TR for reservation'.
    EXIT.
  ENDIF.

  READ TABLE gt_ltba INTO lw_ltba INDEX 1.
  IF lw_ltba-tbnum IS NOT INITIAL.
    MESSAGE s015(zpp) WITH lw_ltba-tbnum lw_ltba-tbktx.
  ENDIF.
ENDFORM.                    " F_CALL_FUNC_CREATE_TR

*&---------------------------------------------------------------------*
*&      Form  F_PREPARE_DATA_TR
*&---------------------------------------------------------------------*
FORM f_prepare_data_tr  TABLES   ft_ltba STRUCTURE ltba
                        USING    fu_reservation.
  DATA : ls_ltba    LIKE LINE OF gt_ltba.

  IF fu_reservation IS NOT INITIAL.
    LOOP AT ft_ltba INTO ls_ltba.
      ls_ltba-tbktx = fu_reservation.
      APPEND ls_ltba TO gt_ltba.
      CLEAR ls_ltba.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_PREPARE_DATA_TR

*&---------------------------------------------------------------------*
*&      Form  F_RESERVATION
*&---------------------------------------------------------------------*
FORM f_reservation .
  DATA : lt_xresb     TYPE STANDARD TABLE OF resb,
         ls_xresb     LIKE LINE OF lt_xresb,
         status       TYPE STANDARD TABLE OF jstat,
         ls_status    LIKE LINE OF status,
         ls_resb      LIKE LINE OF gt_resb,
         lv_objnr     TYPE caufv-objnr,
         line         TYPE bsvx-sttxt,
         lv_subrc     TYPE sy-subrc.

  DATA : lt_afko      TYPE STANDARD TABLE OF afko,
         lt_afvc      TYPE STANDARD TABLE OF afvc,
         ls_afko      LIKE LINE OF lt_afko,
         ls_afvc      LIKE LINE OF lt_afvc.

  IF i_matnr[] IS NOT INITIAL.
    SELECT rsnum rspos aufnr matnr charg werks lgort bdter umlgo
      enmng bdmng meins baugr vornr
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      FOR ALL ENTRIES IN i_matnr
      WHERE matnr = i_matnr-matnr
        AND werks = i_matnr-werks
        AND lgort = p_lgort
        AND aufnr <> space
        AND xloek <> 'X'
        AND kzear <> 'X'.
  ENDIF.

* Check Status INIT
  lt_xresb[] = gt_resb[].
  SORT lt_xresb BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING aufnr.
*  LOOP AT lt_xresb INTO ls_xresb.
*    CLEAR lv_objnr.
*    CONCATENATE 'OR' ls_xresb-aufnr INTO lv_objnr.
*    CALL FUNCTION 'STATUS_READ'
*      EXPORTING
*        objnr            = lv_objnr
*        only_active      = 'X'
*      TABLES
*        status           = status
*      EXCEPTIONS
*        object_not_found = 1
*        OTHERS           = 2.
*
*    READ TABLE status INTO ls_status
*                      WITH KEY stat = 'E0001'.
*    IF sy-subrc = 0.
*      DELETE gt_resb WHERE aufnr = ls_xresb-aufnr.
*    ENDIF.
*  ENDLOOP.

  IF lt_xresb[] IS NOT INITIAL.
    SELECT *
      FROM afko
      INTO CORRESPONDING FIELDS OF TABLE lt_afko
      FOR ALL ENTRIES IN lt_xresb
      WHERE aufnr = lt_xresb-aufnr.

    IF lt_afko[] IS NOT INITIAL.
      SELECT *
        FROM afvc
        INTO CORRESPONDING FIELDS OF TABLE lt_afvc
        FOR ALL ENTRIES IN lt_afko
        WHERE aufpl = lt_afko-aufpl.
    ENDIF.
  ENDIF.

  LOOP AT gt_resb INTO ls_resb.
    CLEAR : ls_afko, ls_afvc.
    READ TABLE lt_afko INTO ls_afko
                       WITH KEY aufnr = ls_resb-aufnr.
    IF sy-subrc = 0.
      READ TABLE lt_afvc INTO ls_afvc
                         WITH KEY aufpl = ls_afko-aufpl
                                  vornr = ls_resb-vornr.
      IF sy-subrc = 0.
        CALL FUNCTION 'STATUS_READ'
          EXPORTING
            objnr            = ls_afvc-objnr
            only_active      = 'X'
          TABLES
            status           = status
          EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.

        READ TABLE status INTO ls_status
                          WITH KEY stat = 'E0002'.
        IF sy-subrc <> 0.
          DELETE TABLE gt_resb FROM ls_resb.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_RESERVATION

*&---------------------------------------------------------------------*
*&      Form  F_RESERVATION_311
*&---------------------------------------------------------------------*
FORM f_reservation_311 .
  CLEAR gt_resb[].
  SORT i_matnr BY matnr werks lgort.
  IF i_matnr[] IS NOT INITIAL.
    SELECT rsnum rspos aufnr matnr charg werks lgort bdter umlgo
      enmng bdmng meins baugr vornr
      FROM resb
      INTO CORRESPONDING FIELDS OF TABLE gt_resb
      FOR ALL ENTRIES IN i_matnr
      WHERE matnr = i_matnr-matnr
        AND werks = i_matnr-werks
        AND lgort = p_umlgo
        AND umlgo = i_matnr-lgort
        AND aufnr = space
        AND bwart = '311'
        AND xloek <> 'X'
        AND kzear <> 'X'.
  ENDIF.
ENDFORM.                    " F_RESERVATION_311

*&---------------------------------------------------------------------*
*&      Form  F_TAMBAH_STOCK
*&---------------------------------------------------------------------*
FORM f_tambah_stock USING fu_field.
  DATA : lt_xresb     TYPE STANDARD TABLE OF resb,
         ls_xresb     LIKE LINE OF lt_xresb,
         lv_lgort     TYPE resb-lgort.

* Tambah stock material dari reservation
  lt_xresb[] = gt_resb[].

  CASE fu_field.
    WHEN 'LGORT'.
      SORT lt_xresb BY werks lgort matnr.
      DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING werks lgort matnr.
    WHEN 'UMLGO'.
      SORT lt_xresb BY werks umlgo matnr.
      DELETE ADJACENT DUPLICATES FROM lt_xresb COMPARING werks umlgo matnr.
  ENDCASE.

  CLEAR ls_xresb.
  LOOP AT lt_xresb INTO ls_xresb.
    CASE fu_field.
      WHEN 'LGORT'.
        lv_lgort  = ls_xresb-lgort.
      WHEN 'UMLGO'.
        lv_lgort  = ls_xresb-umlgo.
    ENDCASE.

    READ TABLE i_mard INTO wa_mard
                      WITH KEY werks = ls_xresb-werks
                               lgort = lv_lgort
                               matnr = ls_xresb-matnr.
    IF sy-subrc <> 0.
      wa_mard-werks    = ls_xresb-werks.
      wa_mard-lgort    = lv_lgort.
      wa_mard-matnr    = ls_xresb-matnr.
      SELECT SINGLE mtart
        FROM mara
        INTO wa_mard-mtart
        WHERE matnr = ls_xresb-matnr.
      wa_mard-labst    = 0.
      wa_mard-qtymin   = 0.
      APPEND wa_mard TO i_mard.
      CLEAR wa_mard.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_TAMBAH_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_CALCULATE_STOCK
*&---------------------------------------------------------------------*
FORM f_calculate_stock USING fu_field.
  DATA : ls_resb    LIKE LINE OF gt_resb,
         ls_afko    LIKE LINE OF gt_afko,
         ls_afvc    LIKE LINE OF gt_afvc,
         status     TYPE STANDARD TABLE OF jstat,
         ls_status  LIKE LINE OF status.

  CASE fu_field.
    WHEN 'LGORT'.
      CLEAR wa_mard.
      SORT i_mard BY werks lgort matnr.
      SORT gt_resb BY werks lgort matnr.
      LOOP AT i_mard INTO wa_mard.
        LOOP AT gt_resb INTO ls_resb WHERE werks = wa_mard-werks
                                       AND lgort = wa_mard-lgort
                                       AND matnr = wa_mard-matnr.
          ls_resb-bdmng = ls_resb-bdmng - ls_resb-enmng.
          IF ls_resb-bdmng > wa_mard-labst.
            wa_mard-qtymin  = wa_mard-qtymin + ls_resb-bdmng - wa_mard-labst.
            wa_mard-labst   = 0.
          ELSE.
            wa_mard-labst   = wa_mard-labst - ls_resb-bdmng.
          ENDIF.
        ENDLOOP.
        MODIFY i_mard FROM wa_mard TRANSPORTING labst qtymin.
      ENDLOOP.

    WHEN 'UMLGO'.
      CLEAR wa_mard.
      SORT i_mard BY werks lgort matnr.
      SORT gt_resb BY werks umlgo matnr.
      LOOP AT i_mard INTO wa_mard.
        LOOP AT gt_resb INTO ls_resb WHERE werks = wa_mard-werks
                                       AND umlgo = wa_mard-lgort
                                       AND matnr = wa_mard-matnr.
          wa_mard-labst = wa_mard-labst + ls_resb-bdmng - ls_resb-enmng.
        ENDLOOP.
        IF wa_mard-labst > wa_mard-qtymin.
          wa_mard-labst    = wa_mard-labst - wa_mard-qtymin.
          wa_mard-qtymin   = 0.
        ELSE.
          wa_mard-qtymin   = wa_mard-qtymin - wa_mard-labst.
          wa_mard-labst    = 0.
        ENDIF.
        MODIFY i_mard FROM wa_mard TRANSPORTING labst qtymin.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_CALCULATE_STOCK

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_STATUS
*&---------------------------------------------------------------------*
FORM f_change_status .
  DATA: estat_inactive  LIKE tj30-estat VALUE 'E0001',
        estat_active    LIKE tj30-estat VALUE 'E0002',
        lv_objnr        TYPE resb-objnr,
        lv_status(5),
        status          TYPE STANDARD TABLE OF jstat,
        ls_status       LIKE LINE OF status.

  LOOP AT i_status. " INTO wa_status.
*    IF p_mtart = 'ZRM'.
    CONCATENATE 'OR' i_status-aufnr INTO lv_objnr.

    CALL FUNCTION 'STATUS_READ'
      EXPORTING
        objnr            = lv_objnr
        only_active      = 'X'
      TABLES
        status           = status
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.

    READ TABLE status INTO ls_status
                      WITH KEY stat = 'E0001'.
    IF sy-subrc = 0.
      CALL FUNCTION 'I_CHANGE_STATUS' IN UPDATE TASK
        EXPORTING
          objnr          = lv_objnr
          estat_inactive = estat_inactive
          estat_active   = estat_active.
      COMMIT WORK.
    ENDIF.
    CLEAR lv_objnr.
*    ENDIF.

    PERFORM f_change_status_detail USING i_status-aufnr.
  ENDLOOP.
ENDFORM.                    " F_CHANGE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_ADD_AUFNR_FOR_CHANGE_STATUS
*&---------------------------------------------------------------------*
FORM f_add_aufnr_for_change_status .
  DATA : lt_xitab    TYPE ta_itab OCCURS 0,
         ls_xitab    LIKE LINE OF lt_xitab,
         ls_itab     LIKE LINE OF i_itab,
         ls_mard     LIKE LINE OF i_mard,
         lv_subrc    TYPE sy-subrc.

  CLEAR i_status[].

  lt_xitab[] = i_itab[].
  SORT lt_xitab BY matnr werks lgort.
  DELETE ADJACENT DUPLICATES FROM lt_xitab COMPARING matnr werks lgort.
  LOOP AT lt_xitab INTO ls_xitab.
    CLEAR ls_mard.
    READ TABLE i_mard INTO ls_mard
                      WITH KEY matnr = ls_xitab-matnr
                               werks = p_werks
                               lgort = p_lgort.
    IF sy-subrc = 0.
      IF ls_mard-labst = 0.
        lv_subrc = 4.
        EXIT.
      ENDIF.
    ELSE.
      lv_subrc = 4.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF lv_subrc IS INITIAL.
    lt_xitab[] = i_itab[].
    SORT lt_xitab BY aufnr.
    DELETE ADJACENT DUPLICATES FROM lt_xitab COMPARING aufnr.
    LOOP AT lt_xitab INTO ls_xitab.
      wa_status-aufnr = ls_xitab-aufnr.
      MOVE-CORRESPONDING wa_status TO i_status.
      APPEND i_status.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_ADD_AUFNR_FOR_CHANGE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_CALC_RESERVATION_QTY
*&---------------------------------------------------------------------*
FORM f_calc_reservation_qty  USING    fwa_itab  TYPE ta_itab1
                             CHANGING fc_bdmng.
  DATA : mod LIKE wa_itab-bdmng.

  mod = fwa_itab-bdmng MOD fwa_itab-bstrf.

  IF fwa_itab-werks = '0101' OR
    fwa_itab-werks = '0102'.
    IF fwa_itab-matkl = 'PMPP'.
      mod  = 0.
    ENDIF.
  ENDIF.

  IF mod <> 0.
    fc_bdmng = fwa_itab-bdmng - mod + fwa_itab-bstrf.
  ENDIF.
ENDFORM.                    " F_CALC_RESERVATION_QTY

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DATA
*&---------------------------------------------------------------------*
FORM f_save_data  TABLES   ft_items    STRUCTURE bapiresbc
                  USING    fu_rsnum.
  DATA : ls_items   TYPE bapiresbc,
         ls_001     TYPE zgdppdt0001,
         ls_caufv   TYPE caufv,
         ls_order   LIKE LINE OF gt_order.

  IF fu_rsnum IS NOT INITIAL.
    LOOP AT gt_order INTO ls_order.
      LOOP AT ft_items INTO ls_items.
        ls_001-werks    = ls_items-plant.
        ls_001-rsnum    = fu_rsnum.
        CLEAR ls_caufv.
        READ TABLE gt_caufv INTO ls_caufv
                            WITH KEY aufnr = ls_order-aufnr.
        IF sy-subrc = 0.
          ls_001-fevor    = ls_caufv-fevor.
        ENDIF.
        ls_001-gstrp    = ls_order-gstrp.
        ls_001-matnr    = ls_order-plnbez.
        ls_001-aufnr    = ls_order-aufnr.
        SELECT SINGLE mtart
          FROM mara
          INTO ls_001-mtart
          WHERE matnr = ls_items-material.
        ls_001-lgort    = p_lgort.
        ls_001-charg    = ls_order-charg.
        ls_001-uname    = sy-uname.
        ls_001-udate    = sy-datum.
        ls_001-utime    = sy-uzeit.
        MODIFY zgdppdt0001 FROM ls_001.
        APPEND ls_001 TO i_zgdppdt0001.
        CLEAR ls_001.
      ENDLOOP.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_SAVE_DATA

*&---------------------------------------------------------------------*
*&      Form  F_VALIDASI_PO
*&---------------------------------------------------------------------*
FORM f_validasi_po  CHANGING fc_subrc.
  DATA : ls_itab    LIKE LINE OF i_itab1.

  LOOP AT i_itab1 INTO ls_itab.
    IF ls_itab-bdmng < 0.
      fc_subrc = 4.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_VALIDASI_PO

*&---------------------------------------------------------------------*
*&      Form  F_GET_OPERATION_DETAIL
*&---------------------------------------------------------------------*
FORM f_get_operation_detail .
  CLEAR : gt_afko[], gt_afvc[].

  SELECT *
    FROM afko
    INTO CORRESPONDING FIELDS OF TABLE gt_afko
    FOR ALL ENTRIES IN i_caufv
    WHERE aufnr = i_caufv-aufnr.

  IF gt_afko[] IS NOT INITIAL.
    SELECT *
      FROM afvc
      INTO CORRESPONDING FIELDS OF TABLE gt_afvc
      FOR ALL ENTRIES IN gt_afko
      WHERE aufpl = gt_afko-aufpl.
  ENDIF.
ENDFORM.                    " F_GET_OPERATION_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_STATUS_DETAIL
*&---------------------------------------------------------------------*
FORM f_change_status_detail  USING    fu_aufnr.
  DATA : ls_afko      LIKE LINE OF gt_afko,
         ls_afvc      LIKE LINE OF gt_afvc,
         ls_resb      LIKE LINE OF i_resb,
         lt_resb      TYPE ta_resb OCCURS 0,
         lv_active    TYPE tj30-estat,
         lv_inactive  TYPE tj30-estat,
         status       TYPE STANDARD TABLE OF jstat,
         ls_status    LIKE LINE OF status.

  lt_resb[] = i_resb[].
  SORT lt_resb BY aufnr vornr.
  DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING aufnr vornr.

  READ TABLE gt_afko INTO ls_afko
                     WITH KEY aufnr = fu_aufnr.
  IF sy-subrc = 0.
    LOOP AT lt_resb INTO ls_resb WHERE aufnr = fu_aufnr.
      READ TABLE gt_afvc INTO ls_afvc
                         WITH KEY aufpl = ls_afko-aufpl
                                  vornr = ls_resb-vornr.
      IF sy-subrc = 0.
        lv_inactive = 'E0001'.
        lv_active   = 'E0002'.

        CALL FUNCTION 'STATUS_READ'
          EXPORTING
            objnr            = ls_afvc-objnr
            only_active      = 'X'
          TABLES
            status           = status
          EXCEPTIONS
            object_not_found = 1
            OTHERS           = 2.

        READ TABLE status INTO ls_status
                          WITH KEY stat = 'E0001'.
        IF sy-subrc = 0.
          CALL FUNCTION 'I_CHANGE_STATUS' IN UPDATE TASK
            EXPORTING
              objnr          = ls_afvc-objnr
              estat_inactive = lv_inactive
              estat_active   = lv_active.
          COMMIT WORK.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CHANGE_STATUS_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_CEK_OPERATION_DETAIL
*&---------------------------------------------------------------------*
FORM f_cek_operation_detail .
  DATA : ls_caufv   LIKE LINE OF i_caufv,
         ls_resb    LIKE LINE OF i_resb,
         ls_afko    LIKE LINE OF gt_afko,
         ls_afvc    LIKE LINE OF gt_afvc,
         lv_subrc   TYPE sy-subrc,
         status     TYPE STANDARD TABLE OF jstat,
         ls_status  LIKE LINE OF status.

  LOOP AT i_caufv INTO ls_caufv.
    CLEAR ls_resb.
    LOOP AT i_resb INTO ls_resb WHERE aufnr = ls_caufv-aufnr.
      CLEAR ls_afko.
      READ TABLE gt_afko INTO ls_afko
                         WITH KEY aufnr = ls_resb-aufnr.
      IF sy-subrc = 0.
        CLEAR ls_afvc.
        READ TABLE gt_afvc INTO ls_afvc
                           WITH KEY aufpl = ls_afko-aufpl
                                    vornr = ls_resb-vornr.
        IF sy-subrc = 0.
          CALL FUNCTION 'STATUS_READ'
            EXPORTING
              objnr            = ls_afvc-objnr
              only_active      = 'X'
            TABLES
              status           = status
            EXCEPTIONS
              object_not_found = 1
              OTHERS           = 2.

          READ TABLE status INTO ls_status
                            WITH KEY stat = 'E0002'.
          IF sy-subrc = 0.
            DELETE TABLE i_resb FROM ls_resb.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.
ENDFORM.                    " F_CEK_OPERATION_DETAIL

*&---------------------------------------------------------------------*
*&      Form  F_CHANGE_DETAIL_STATUS
*&---------------------------------------------------------------------*
FORM f_change_detail_status  USING    fu_rsnum fu_aufnr
                             CHANGING fc_subrc.
  DATA : ls_resb    LIKE LINE OF gt_resb,
         ls_afko    LIKE LINE OF gt_afko,
         ls_afvc    LIKE LINE OF gt_afvc,
         lv_inactive(5),
         lv_active(5),
         lt_ltbc    TYPE STANDARD TABLE OF ltbc,
         ls_ltbc    LIKE LINE OF lt_ltbc,
         ls_ltbp    LIKE LINE OF gt_ltbp,
         status     TYPE STANDARD TABLE OF jstat,
         ls_status  LIKE LINE OF status.

  LOOP AT gt_resb INTO ls_resb WHERE aufnr = fu_aufnr.
    IF fc_subrc = 0.
      CLEAR ls_afko.
      READ TABLE gt_afko INTO ls_afko
                         WITH KEY aufnr = fu_aufnr.
      IF sy-subrc = 0.
        READ TABLE gt_afvc INTO ls_afvc
                           WITH KEY aufpl = ls_afko-aufpl
                                    vornr = ls_resb-vornr.
        IF sy-subrc = 0.
          lv_inactive = 'E0002'.
          lv_active   = 'E0001'.
          CALL FUNCTION 'STATUS_READ'
            EXPORTING
              objnr            = ls_afvc-objnr
              only_active      = 'X'
            TABLES
              status           = status
            EXCEPTIONS
              object_not_found = 1
              OTHERS           = 2.

          READ TABLE status INTO ls_status
                            WITH KEY stat = 'E0002'.
          IF sy-subrc = 0.
            CALL FUNCTION 'I_CHANGE_STATUS' IN UPDATE TASK
              EXPORTING
                objnr          = ls_afvc-objnr
                estat_inactive = lv_inactive
                estat_active   = lv_active.

            IF sy-subrc <> 0.
              lv_subrc = sy-subrc.
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF lv_subrc = 0.
    LOOP AT gt_ltbp INTO ls_ltbp.
      ls_ltbc-lgnum   = ls_ltbp-lgnum.
      ls_ltbc-tbnum   = ls_ltbp-tbnum.
      ls_ltbc-tbpos   = ls_ltbp-tbpos.
      ls_ltbc-menga   = ls_ltbp-menga.
      APPEND ls_ltbc TO lt_ltbc.
    ENDLOOP.

    IF lt_ltbc[] IS NOT INITIAL.
      CALL FUNCTION 'L_TR_CANCEL'
        TABLES
          t_ltbc               = lt_ltbc
        EXCEPTIONS
          item_error           = 1
          no_update_item_error = 2
          no_update_no_entry   = 3
          OTHERS               = 4.

      lv_subrc = sy-subrc.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_CHANGE_DETAIL_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_ADDITIONAL_DATA_FOR_CANCEL
*&---------------------------------------------------------------------*
FORM f_additional_data_for_cancel .
  TYPES : BEGIN OF ty_xresb,
            aufnr   TYPE resb-aufnr,
            matnr   TYPE resb-matnr,
          END OF ty_xresb.

  DATA : ls_resb          LIKE LINE OF gt_resb,
         ls_ltbp          LIKE LINE OF gt_ltbp,
         lt_resb          TYPE STANDARD TABLE OF resb,
         lt_xresb         TYPE STANDARD TABLE OF ty_xresb,
         ls_xresb         LIKE LINE OF lt_xresb,
         ls_zgdppdt0001   LIKE LINE OF i_zgdppdt0001.

  DATA : lv_subrc LIKE sy-subrc.

  CLEAR gv_subrc.

  IF option = 2 AND radio2 = 'X' AND
     ( p_werks = '0101' OR p_werks = '0102' ).
    SELECT SINGLE *
      FROM ltbk
      INTO CORRESPONDING FIELDS OF gs_ltbk
      WHERE tbktx = p_rsnum.
  ELSE.
    SELECT SINGLE *
      FROM ltbk
      INTO CORRESPONDING FIELDS OF gs_ltbk
      WHERE tbktx = p_rsnum
        AND statu = space.
  ENDIF.

  IF sy-subrc = 0.
    SELECT *
      FROM ltbp
      INTO CORRESPONDING FIELDS OF TABLE gt_ltbp
      WHERE lgnum = gs_ltbk-lgnum
        AND tbnum = gs_ltbk-tbnum.

    READ TABLE gt_ltbp INTO ls_ltbp
                       WITH KEY elikz = 'X'.
    lv_subrc = sy-subrc.

    IF option = 2 AND radio2 = 'X' AND
       ( p_werks = '0101' OR p_werks = '0102' ).
      lv_subrc = 4.
    ENDIF.

    IF lv_subrc = 0.      "sy-subrc = 0.
      gv_subrc = 1.
      CLEAR i_zgdppdt0001[].
    ELSE.
      SELECT *
        FROM resb
        INTO CORRESPONDING FIELDS OF TABLE lt_resb
        WHERE rsnum = p_rsnum
          AND werks = p_werks.

      LOOP AT i_zgdppdt0001 INTO ls_zgdppdt0001.
        LOOP AT lt_resb INTO ls_resb WHERE rsnum = ls_zgdppdt0001-rsnum.
          ls_xresb-aufnr  = ls_zgdppdt0001-aufnr.
          ls_xresb-matnr  = ls_resb-matnr.
          APPEND ls_xresb TO lt_xresb.
        ENDLOOP.
      ENDLOOP.

      IF lt_xresb[] IS NOT INITIAL.
        SELECT *
          FROM resb
          INTO CORRESPONDING FIELDS OF TABLE gt_resb
          FOR ALL ENTRIES IN lt_xresb
          WHERE aufnr = lt_xresb-aufnr
            AND werks = p_werks
            AND matnr = lt_xresb-matnr.

        SORT gt_resb BY aufnr matnr.
        DELETE ADJACENT DUPLICATES FROM gt_resb COMPARING aufnr matnr.
      ENDIF.

      SELECT *
        FROM afko
        INTO CORRESPONDING FIELDS OF TABLE gt_afko
        FOR ALL ENTRIES IN i_zgdppdt0001
        WHERE aufnr = i_zgdppdt0001-aufnr.

      IF gt_afko[] IS NOT INITIAL.
        SELECT *
          FROM afvc
          INTO CORRESPONDING FIELDS OF TABLE gt_afvc
          FOR ALL ENTRIES IN gt_afko
          WHERE aufpl = gt_afko-aufpl.
      ENDIF.
    ENDIF.
  ELSE.
    gv_subrc = 1.
    CLEAR i_zgdppdt0001[].
  ENDIF.
ENDFORM.                    " F_ADDITIONAL_DATA_FOR_CANCEL

*&---------------------------------------------------------------------*
*&      Form  F_AUFNR_CHANGE_STATUS
*&---------------------------------------------------------------------*
FORM f_aufnr_change_status .
  DATA : lt_resb        TYPE ta_resb OCCURS 0,
         ls_resb        LIKE LINE OF lt_resb,
         ls_zgdppdt0001 LIKE LINE OF i_zgdppdt0001,
         ls_chgsts      LIKE LINE OF i_chgsts.

  CLEAR i_chgsts[].
  lt_resb[] = i_resb[].
  SORT lt_resb BY aufnr.
  DELETE ADJACENT DUPLICATES FROM lt_resb COMPARING aufnr.

  LOOP AT lt_resb INTO ls_resb.
    READ TABLE i_zgdppdt0001 INTO ls_zgdppdt0001
                             WITH KEY aufnr = ls_resb-aufnr.
    IF sy-subrc <> 0.
      ls_chgsts-aufnr = ls_resb-aufnr.
      APPEND ls_chgsts TO i_chgsts.
      CLEAR ls_chgsts.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_AUFNR_CHANGE_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_FILL_TC_NOTES
*&---------------------------------------------------------------------*
FORM f_fill_tc_notes .
  READ TABLE gt_notes INTO gs_notes INDEX tc_notes-current_line.
ENDFORM.                    " F_FILL_TC_NOTES

*&---------------------------------------------------------------------*
*&      Form  F_READ_TC_NOTES
*&---------------------------------------------------------------------*
FORM f_read_tc_notes .
  MODIFY gt_notes FROM gs_notes INDEX tc_notes-current_line.
ENDFORM.                    " F_READ_TC_NOTES

*&---------------------------------------------------------------------*
*&      Form  F_CHECK_STATUS
*&---------------------------------------------------------------------*
FORM f_check_status .
  DATA : ls_caufv   LIKE LINE OF gt_caufv,
         status     TYPE STANDARD TABLE OF jstat,
         ls_status  LIKE LINE OF status.

  LOOP AT gt_caufv INTO ls_caufv.
    CALL FUNCTION 'STATUS_READ'
      EXPORTING
        objnr            = ls_caufv-objnr
        only_active      = 'X'
      TABLES
        status           = status
      EXCEPTIONS
        object_not_found = 1
        OTHERS           = 2.

    READ TABLE status INTO ls_status
                      WITH KEY stat = 'E0002'.
    IF sy-subrc <> 0.
      READ TABLE status WITH KEY stat = 'E0001'
                        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        PERFORM f_add_error_message USING 'Order' ls_caufv-aufnr 'belum RESV' ''
                                          '' 'X'.
        DELETE TABLE gt_caufv FROM ls_caufv.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " F_CHECK_STATUS

*&---------------------------------------------------------------------*
*&      Form  F_ADD_NEW_STATUS
*&---------------------------------------------------------------------*
FORM f_add_new_status .
  DATA : ls_caufv   LIKE LINE OF i_caufv,
         ls_status  LIKE LINE OF i_status.

  LOOP AT i_caufv INTO ls_caufv.
    READ TABLE i_status INTO ls_status
                        WITH KEY aufnr = ls_caufv-aufnr.
    IF sy-subrc = 0.
      CONTINUE.
    ENDIF.
    ls_status-aufnr = ls_caufv-aufnr.
    APPEND ls_status TO i_status.
    CLEAR ls_status.
  ENDLOOP.
ENDFORM.                    " F_ADD_NEW_STATUS
