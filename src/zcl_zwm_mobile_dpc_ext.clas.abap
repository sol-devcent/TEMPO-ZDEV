class ZCL_ZWM_MOBILE_DPC_EXT definition
  public
  inheriting from ZCL_ZWM_MOBILE_DPC
  create public .

public section.

  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~EXECUTE_ACTION
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~GET_EXPANDED_ENTITYSET
    redefinition .
  methods /IWBEP/IF_MGW_APPL_SRV_RUNTIME~CREATE_DEEP_ENTITY
    redefinition .
protected section.

  methods LOGINSET_GET_ENTITY
    redefinition .
  methods LOGOFFSET_GET_ENTITY
    redefinition .
private section.
ENDCLASS.



CLASS ZCL_ZWM_MOBILE_DPC_EXT IMPLEMENTATION.


  METHOD /iwbep/if_mgw_appl_srv_runtime~create_deep_entity.
    DATA : ls_deep     TYPE zcl_zwm_mobile_mpc_ext=>ts_login_entity,
           ls_hdr      TYPE zcl_zwm_mobile_mpc_ext=>ts_login,
           lt_dtl      TYPE STANDARD TABLE OF zcl_zwm_mobile_mpc_ext=>ts_menu,
           ls_dtl      LIKE LINE OF lt_dtl,
           ls_lrf_wkqu TYPE lrf_wkqu,
           lt_t3130a   TYPE STANDARD TABLE OF t3130a,
           ls_t3130a   TYPE t3130a.

    DATA : lv_subrc  TYPE sy-subrc,
           lv_mmenu  TYPE lrf_wkqu-mmenu,
           lockstate TYPE uslock.

*    DATA: cl_json_data TYPE REF TO zcl_trex_json_serializer,
*          lv_json      TYPE string.

    CASE iv_entity_set_name.
      WHEN 'loginSet'.
        TRY.
            CALL METHOD io_data_provider->read_entry_data
              IMPORTING
                es_data = ls_deep.
          CATCH /iwbep/cx_mgw_tech_exception .
        ENDTRY.

        IF ls_deep IS NOT INITIAL.
          MOVE-CORRESPONDING ls_deep TO ls_hdr.
          lt_dtl = CORRESPONDING #( ls_deep-nav_login MAPPING mmenu = mmenu ).

          CALL FUNCTION 'SUSR_USER_LOCKSTATE_GET'
            EXPORTING
              user_name           = ls_hdr-username
            IMPORTING
              lockstate           = lockstate
            EXCEPTIONS
              user_name_not_exist = 1
              OTHERS              = 2.

          IF lockstate-wrng_logon = 'L' OR
            lockstate-local_lock = 'L' OR
            lockstate-glob_lock = 'L'.
            lv_subrc = 4.
          ENDIF.

          IF lv_subrc = 0.

            SELECT SINGLE *
              FROM lrf_wkqu
              INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
              WHERE bname = ls_hdr-username
                AND statu = 'X'.

            ls_deep-warehouse_number  = ls_lrf_wkqu-lgnum.

            SELECT SINGLE werks
              FROM t320
              INTO ls_deep-plant
              WHERE lgnum = ls_lrf_wkqu-lgnum.

            SELECT *
              FROM t3130a
              INTO CORRESPONDING FIELDS OF TABLE lt_t3130a
              WHERE lgnum = ls_lrf_wkqu-lgnum.

            SELECT SINGLE *
              FROM t3130a
              INTO CORRESPONDING FIELDS OF ls_t3130a
              WHERE lgnum   = ls_lrf_wkqu-lgnum
                AND pro_typ = space.

            IF sy-subrc = 0.
              ls_deep-type      = 'S'.
              ls_deep-message   = 'Login success'.

              LOOP AT lt_t3130a INTO ls_t3130a WHERE mmenu = ls_lrf_wkqu-mmenu.
                IF ls_t3130a-pro_typ IS INITIAL.
                  ls_dtl-mmenu = ls_t3130a-men_trans.
                  APPEND ls_dtl TO ls_deep-nav_login.
                  CLEAR ls_dtl.
                ELSE.
                  lv_subrc = 4.
                  lv_mmenu = ls_t3130a-men_trans.
                  WHILE lv_subrc = 4.
                    CLEAR ls_t3130a.
                    READ TABLE lt_t3130a INTO ls_t3130a
                                         WITH KEY mmenu = lv_mmenu.
                    IF ls_t3130a-pro_typ IS INITIAL.
                      LOOP AT lt_t3130a INTO ls_t3130a WHERE mmenu = lv_mmenu.
                        ls_dtl-mmenu = ls_t3130a-men_trans.
                        APPEND ls_dtl TO ls_deep-nav_login.
                        CLEAR ls_dtl.
                      ENDLOOP.
                      CLEAR lv_subrc.
                    ELSE.
                      lv_mmenu = ls_t3130a-men_trans.
                    ENDIF.
                  ENDWHILE.
                ENDIF.
              ENDLOOP.
              SORT ls_deep-nav_login BY mmenu.
              DELETE ADJACENT DUPLICATES FROM ls_deep-nav_login.
*            APPEND lt_dtl TO ls_deep-nav_login.
*            LOOP AT lt_dtl INTO ls_dtl.
*              ls_mmenu-mmenu = ls_menu-mmenu.
*              APPEND ls_mmenu TO lt_mmenu.
*              CLEAR ls_mmenu.
*            ENDLOOP.
            ENDIF.
          ELSE.
            ls_deep-type      = 'E'.
            ls_deep-message   = 'Login failed'.
          ENDIF.
        ELSE.
          ls_deep-type      = 'E'.
          ls_deep-message   = 'User is Locked, contact Admin'.
        ENDIF.

        TRY.
            CALL METHOD me->copy_data_to_ref
              EXPORTING
                is_data = ls_deep
              CHANGING
                cr_data = er_deep_entity.
          CATCH cx_root.
        ENDTRY.

    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~execute_action.
****    TYPES : BEGIN OF ty_mmenu,
****              username TYPE c LENGTH 12,
****              password TYPE c LENGTH 40,
****              lgnum    TYPE c LENGTH 3,
****              plant    TYPE c LENGTH 4,
****              mmenu    TYPE c LENGTH 5000,
****              type     TYPE c LENGTH 1,
****              message  TYPE c LENGTH 220,
****              nav_menu TYPE STANDARD TABLE OF zcl_zwm_mobile_mpc=>ts_menu WITH DEFAULT KEY,
****            END OF ty_mmenu.
***
***    DATA : ls_lrf_wkqu TYPE lrf_wkqu,
***           lt_t3130a   TYPE STANDARD TABLE OF t3130a,
***           ls_t3130a   LIKE LINE OF lt_t3130a,
***           lt_menu     TYPE STANDARD TABLE OF t3130a,
***           ls_menu     LIKE LINE OF lt_menu,
***           lt_mmenu    TYPE STANDARD TABLE OF zcl_zwm_mobile_mpc=>ts_menu,
***           ls_mmenu    LIKE LINE OF lt_mmenu.
***
***    DATA : lv_subrc TYPE sy-subrc,
***           lv_mmenu TYPE lrf_wkqu-mmenu.
***
***    CASE iv_action_name.
***      WHEN 'fget_menu'.
***        READ TABLE it_parameter INTO DATA(wa_parameter)
***          WITH KEY name = 'username'.
***        IF sy-subrc = 0.
****          ls_mmenu-username = wa_parameter-value.
***          DATA(lv_username) = wa_parameter-value.
***
***          SELECT SINGLE *
***            FROM lrf_wkqu
***            INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
***            WHERE bname = lv_username
***              AND statu = 'X'.
***
***          IF sy-subrc = 0.
****            ls_mmenu-lgnum    = ls_lrf_wkqu-lgnum.
****
****            SELECT SINGLE werks
****              FROM t320
****              INTO ls_mmenu-plant
****              WHERE lgnum = ls_lrf_wkqu-lgnum.
***
***            SELECT *
***              FROM t3130a
***              INTO CORRESPONDING FIELDS OF TABLE lt_t3130a
***              WHERE lgnum = ls_lrf_wkqu-lgnum.
***
***            IF sy-subrc = 0.
***              LOOP AT lt_t3130a INTO ls_t3130a WHERE mmenu = ls_lrf_wkqu-mmenu.
***                IF ls_t3130a-pro_typ IS INITIAL.
***                  ls_menu-mmenu = ls_t3130a-men_trans.
***                  APPEND ls_menu TO lt_menu.
***                  CLEAR ls_menu.
***                ELSE.
***                  lv_subrc = 4.
***                  lv_mmenu = ls_t3130a-men_trans.
***                  WHILE lv_subrc = 4.
***                    CLEAR ls_t3130a.
***                    READ TABLE lt_t3130a INTO ls_t3130a
***                                         WITH KEY mmenu = lv_mmenu.
***                    IF ls_t3130a-pro_typ IS INITIAL.
***                      LOOP AT lt_t3130a INTO ls_t3130a WHERE mmenu = lv_mmenu.
***                        ls_menu-mmenu = ls_t3130a-men_trans.
***                        APPEND ls_menu TO lt_menu.
***                        CLEAR ls_menu.
***                      ENDLOOP.
***                      CLEAR lv_subrc.
***                    ELSE.
***                      lv_mmenu = ls_t3130a-men_trans.
***                    ENDIF.
***                  ENDWHILE.
***                ENDIF.
***              ENDLOOP.
***              SORT lt_menu BY mmenu.
***              DELETE ADJACENT DUPLICATES FROM lt_menu.
****              ls_mmenu-nav_menu[] = lt_menu[].
****              APPEND ls_mmenu TO lt_mmenu.
***            ENDIF.
***          ENDIF.
***
***          CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
***            EXPORTING
***              is_data = lt_menu
***            CHANGING
***              cr_data = er_data.
***        ENDIF.
***    ENDCASE.
  ENDMETHOD.


  METHOD /iwbep/if_mgw_appl_srv_runtime~get_expanded_entityset.
    TYPES : BEGIN OF ty_mmenu,
              username TYPE c LENGTH 12,
              password TYPE c LENGTH 40,
              lgnum    TYPE c LENGTH 3,
              plant    TYPE c LENGTH 4,
              mmenu    TYPE c LENGTH 5000,
              type     TYPE c LENGTH 1,
              message  TYPE c LENGTH 220,
              nav_menu TYPE STANDARD TABLE OF zcl_zwm_mobile_mpc=>ts_menu WITH DEFAULT KEY,
            END OF ty_mmenu.

    DATA : ls_lrf_wkqu TYPE lrf_wkqu,
           lt_t3130a   TYPE STANDARD TABLE OF t3130a,
           ls_t3130a   LIKE LINE OF lt_t3130a,
           lt_menu     TYPE STANDARD TABLE OF t3130a,
           ls_menu     LIKE LINE OF lt_menu,
           lt_mmenu    TYPE STANDARD TABLE OF zcl_zwm_mobile_mpc_ext=>ts_menu,
           ls_mmenu    LIKE LINE OF lt_mmenu.

    DATA : lv_subrc  TYPE sy-subrc,
           lv_mmenu  TYPE lrf_wkqu-mmenu,
           lockstate TYPE uslock,
           user_name TYPE usr02-bname.

    DATA(lv_username) = VALUE #( it_key_tab[ name = 'username' ]-value OPTIONAL ). "New syntax
    lv_username = |{ lv_username ALPHA = IN }|.

    IF iv_entity_name = 'menu'.
      user_name = lv_username.
      CALL FUNCTION 'SUSR_USER_LOCKSTATE_GET'
        EXPORTING
          user_name           = user_name
        IMPORTING
          lockstate           = lockstate
        EXCEPTIONS
          user_name_not_exist = 1
          OTHERS              = 2.

      IF lockstate-wrng_logon = 'L' OR
        lockstate-local_lock = 'L' OR
        lockstate-glob_lock = 'L'.
        lv_subrc = 4.
      ENDIF.

      IF lv_subrc = 0.
        SELECT SINGLE *
          FROM lrf_wkqu
          INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
          WHERE bname = lv_username
            AND statu = 'X'.

        IF sy-subrc = 0.
*        ls_mmenu-lgnum    = ls_lrf_wkqu-lgnum.

*        SELECT SINGLE werks
*          FROM t320
*          INTO ls_mmenu-plant
*          WHERE lgnum = ls_lrf_wkqu-lgnum.

          SELECT *
            FROM t3130a
            INTO CORRESPONDING FIELDS OF TABLE lt_t3130a
            WHERE lgnum = ls_lrf_wkqu-lgnum.

          IF sy-subrc = 0.
            LOOP AT lt_t3130a INTO ls_t3130a WHERE mmenu = ls_lrf_wkqu-mmenu.
              IF ls_t3130a-pro_typ IS INITIAL.
                ls_menu-mmenu = ls_t3130a-men_trans.
                APPEND ls_menu TO lt_menu.
                CLEAR ls_menu.
              ELSE.
                lv_subrc = 4.
                lv_mmenu = ls_t3130a-men_trans.
                WHILE lv_subrc = 4.
                  CLEAR ls_t3130a.
                  READ TABLE lt_t3130a INTO ls_t3130a
                                       WITH KEY mmenu = lv_mmenu.
                  IF sy-subrc = 0.
                    IF ls_t3130a-pro_typ IS INITIAL.
                      LOOP AT lt_t3130a INTO ls_t3130a WHERE mmenu = lv_mmenu.
                        ls_menu-mmenu = ls_t3130a-men_trans.
                        APPEND ls_menu TO lt_menu.
                        CLEAR ls_menu.
                      ENDLOOP.
                      CLEAR lv_subrc.
                    ELSE.
                      lv_mmenu = ls_t3130a-men_trans.
                    ENDIF.
                  ELSE.
                    ls_menu-mmenu = lv_mmenu.
                    APPEND ls_menu TO lt_menu.
                    CLEAR : ls_menu, lv_subrc.
                  ENDIF.
                ENDWHILE.
              ENDIF.
            ENDLOOP.
            SORT lt_menu BY mmenu.
            DELETE ADJACENT DUPLICATES FROM lt_menu.
***          LOOP AT lt_menu INTO ls_menu.
***            IF ls_mmenu-mmenu IS INITIAL.
***              ls_mmenu-mmenu = ls_menu-mmenu.
***            ELSE.
***              CONCATENATE ls_mmenu-mmenu ls_menu-mmenu INTO ls_mmenu-mmenu
***              SEPARATED BY '","'.
***            ENDIF.
***          ENDLOOP.
***          APPEND ls_mmenu TO lt_mmenu.

            LOOP AT lt_menu INTO ls_menu.
              ls_mmenu-mmenu = ls_menu-mmenu.
              APPEND ls_mmenu TO lt_mmenu.
              CLEAR ls_mmenu.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.

      CALL METHOD me->/iwbep/if_mgw_conv_srv_runtime~copy_data_to_ref
        EXPORTING
          is_data = lt_mmenu
        CHANGING
          cr_data = er_entityset.
    ENDIF.
  ENDMETHOD.


  METHOD loginset_get_entity.
    DATA : process     TYPE zwmstm001,
           ls_lrf_wkqu TYPE lrf_wkqu,
           ls_t3130a   TYPE t3130a,
           lockstate   TYPE uslock,
           lv_subrc    TYPE sy-subrc.

    CASE iv_entity_set_name.
      WHEN 'loginSet'.
        er_entity-username = VALUE #( it_key_tab[ name = 'username' ]-value OPTIONAL ).

        TRANSLATE er_entity-username TO UPPER CASE.

        CALL FUNCTION 'SUSR_USER_LOCKSTATE_GET'
          EXPORTING
            user_name           = er_entity-username
          IMPORTING
            lockstate           = lockstate
          EXCEPTIONS
            user_name_not_exist = 1
            OTHERS              = 2.

        IF lockstate-wrng_logon = 'L' OR
          lockstate-local_lock = 'L' OR
          lockstate-glob_lock = 'L'.
          lv_subrc = 4.
        ENDIF.

        IF lv_subrc = 0.
          SELECT SINGLE *
            FROM lrf_wkqu
            INTO CORRESPONDING FIELDS OF ls_lrf_wkqu
            WHERE bname = er_entity-username
              AND statu = 'X'.

          er_entity-warehouse_number  = ls_lrf_wkqu-lgnum.
          IF ls_lrf_wkqu-lgnum(1) = 'C'.
            er_entity-warehouse_type = 'X'.
          ENDIF.
          er_entity-mmenu = ls_lrf_wkqu-mmenu.

          SELECT SINGLE werks
            FROM t320
            INTO er_entity-plant
            WHERE lgnum = ls_lrf_wkqu-lgnum.

          SELECT SINGLE *
            FROM t3130a
            INTO CORRESPONDING FIELDS OF ls_t3130a
            WHERE lgnum   = ls_lrf_wkqu-lgnum
              AND pro_typ = space.

          IF sy-subrc = 0.
            er_entity-type      = 'S'.
            er_entity-message   = 'Login success'.
          ELSE.
            er_entity-type      = 'E'.
            er_entity-message   = 'Login failed'.
          ENDIF.
        ELSE.
          er_entity-type      = 'E'.
          er_entity-message   = 'User is Locked, contact Admin'.
        ENDIF.
    ENDCASE.

*    LOOP AT it_key_tab INTO DATA(wa_key).
*      CASE wa_key-name.
*        WHEN 'username'.
*          er_entity-username    = wa_key-value.
*        WHEN 'password'.
*          er_entity-password    = wa_key-value.
*      ENDCASE.
*    ENDLOOP.
*
*    process-login = 'X'.
*
*    CALL FUNCTION 'ZWMFM_MOBILE'
*      EXPORTING
*        process = process
*      CHANGING
*        login   = er_entity.

  ENDMETHOD.


  METHOD logoffset_get_entity.
    DATA : process  TYPE zwmstm001.

    LOOP AT it_key_tab INTO DATA(wa_key).
      CASE wa_key-name.
        WHEN 'username'.
          er_entity-username    = wa_key-value.
        WHEN 'token'.
          er_entity-token       = wa_key-value.
      ENDCASE.
    ENDLOOP.

    process-logoff = 'X'.

    CALL FUNCTION 'ZWMFM_MOBILE'
      EXPORTING
        process = process
      CHANGING
        logoff  = er_entity.

  ENDMETHOD.
ENDCLASS.
