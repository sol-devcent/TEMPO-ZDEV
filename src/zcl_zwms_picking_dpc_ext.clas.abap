class ZCL_ZWMS_PICKING_DPC_EXT definition
  public
  inheriting from ZCL_ZWMS_PICKING_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
protected section.

  methods GETPICKHSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZWMS_PICKING_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    DATA : lt_getpickd TYPE STANDARD TABLE OF zcl_zwms_picking_mpc_ext=>ts_getpickd.

    DATA : lv_lgnum TYPE ltap-lgnum,
           lv_tanum TYPE c LENGTH 20,
           lv_json  TYPE string.

    lv_lgnum = VALUE #( it_key_tab[ name = 'warehouse_number' ]-value OPTIONAL ).
    lv_tanum = VALUE #( it_key_tab[ name = 'to_number' ]-value OPTIONAL ).

    IF iv_entity_name = 'getpickd'.
      CALL FUNCTION 'ZWMSFM003'
        EXPORTING
          pi_process   = 'GET_PICKING_AKHIR'
          pi_data      = lv_json
          pi_lgnum     = lv_lgnum
          pi_tanum     = lv_tanum
        TABLES
          pt_pickakhir = lt_getpickd.

      IF lt_getpickd[] IS NOT INITIAL.
        CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
          EXPORTING
            is_data = lt_getpickd
          CHANGING
            cr_data = er_entityset.
      ENDIF.
    ENDIF.
  ENDMETHOD.


  METHOD getpickhset_get_entity.
*    DATA : ls_ltak TYPE ltak,
*            ls_likp TYPE likp,
*            lt_ltap TYPE STANDARD TABLE OF ltap,
*            ls_ltap LIKE LINE OF lt_ltap.

    DATA : lv_length TYPE i,
           lv_subrc  TYPE sy-subrc.

    CASE iv_entity_set_name.
      WHEN 'getpickhSet'.
        er_entity-warehouse_number = VALUE #( it_key_tab[ name = 'warehouse_number' ]-value OPTIONAL ).
        er_entity-to_number = VALUE #( it_key_tab[ name = 'to_number' ]-value OPTIONAL ).

        lv_length = strlen( er_entity-to_number ).
        IF lv_length = 15.
*          SELECT SINGLE *
*            FROM ltak
*            INTO CORRESPONDING FIELDS OF ls_ltak
          SELECT lgnum, tanum, lznum, vbeln, kquit
            INTO TABLE @DATA(lt_ltak)
            FROM ltak
            WHERE lgnum = @er_entity-warehouse_number
              AND lznum = @er_entity-to_number.
        ELSE.
*          SELECT SINGLE *
*            FROM ltak
*            INTO CORRESPONDING FIELDS OF ls_ltak
          SELECT lgnum tanum lznum vbeln kquit
            INTO TABLE lt_ltak
            FROM ltak
            WHERE lgnum = er_entity-warehouse_number
              AND tanum = er_entity-to_number.
        ENDIF.

*        SELECT *
*          FROM ltap
*          INTO CORRESPONDING FIELDS OF TABLE lt_ltap
*          WHERE lgnum = ls_ltak-lgnum
*            AND tanum = ls_ltak-tanum.
*
*        SELECT SINGLE *
*          FROM likp
*          INTO CORRESPONDING FIELDS OF ls_likp
*          WHERE vbeln = ls_ltak-vbeln.

        IF lt_ltak[] IS NOT INITIAL.
*          IF ls_ltak-kquit = space.
*            er_entity-confirm_status = 'X'.
*          ENDIF.

*          IF ls_ltak-kquit IS INITIAL.
*            lv_subrc = 2.
*          ENDIF.

          IF line_exists( lt_ltak[ kquit = space ] ).
            er_entity-confirm_status = 'X'.
            lv_subrc = 2.
          ENDIF.

          SELECT lgnum, tanum, tapos, posnr, matnr, pvqui
            INTO TABLE @DATA(lt_ltap)
            FROM ltap FOR ALL ENTRIES IN @lt_ltak
            WHERE lgnum = @lt_ltak-lgnum
              AND tanum = @lt_ltak-tanum.

*          CLEAR ls_ltap.
*          READ TABLE lt_ltap INTO ls_ltap
*                             WITH KEY pvqui = space.
*          IF sy-subrc = 0.
*            lv_subrc = 3.
*          ENDIF.
          IF line_exists( lt_ltap[ pvqui = space ] ).
            lv_subrc = 3.
          ENDIF.

          SELECT vbeln, wadat_ist
            INTO TABLE @DATA(lt_likp)
            FROM likp FOR ALL ENTRIES IN @lt_ltak
            WHERE vbeln = @lt_ltak-vbeln.

*          IF ls_likp-wadat_ist = '00000000'.
*            lv_subrc = 1.
*          ENDIF.
          IF line_exists( lt_likp[ wadat_ist = '00000000' ] ).
            lv_subrc = 1.
          ENDIF.

          IF lt_ltap[] IS NOT INITIAL.
            SELECT mtart INTO TABLE @DATA(lt_mtart)
              FROM mara FOR ALL ENTRIES IN @lt_ltap
              WHERE matnr = @lt_ltap-matnr.
            IF line_exists( lt_mtart[ mtart = 'ZCGB' ] ).
              er_entity-fg = 'X'.
            ELSEIF line_exists( lt_mtart[ mtart = 'ZPHA' ] ).
              er_entity-fg = 'X'.
            ELSEIF line_exists( lt_mtart[ mtart = 'ZCGN' ] ).
              er_entity-fg = 'X'.
            ELSE.
              er_entity-fg = ' '.
            ENDIF.
          ENDIF.

          CASE lv_subrc.
            WHEN 0.
              er_entity-type    = 'S'.
              er_entity-message = 'TO Akhir bulan'.
            WHEN 1.
              er_entity-type    = 'E'.
              er_entity-message = 'DN belum PGI'.
            WHEN 2.
              er_entity-type    = 'E'.
              er_entity-message = 'Checker belum confirm'.
            WHEN 3.
              er_entity-type    = 'E'.
              er_entity-message = 'Picker belum confirm'.
          ENDCASE.
        ENDIF.
    ENDCASE.
  ENDMETHOD.
ENDCLASS.
