class ZIHQMR003_CLASS definition
  public
  final
  create public .

PUBLIC SECTION.
  TYPES: tt_matnr TYPE RANGE OF matnr,
         tt_datab TYPE RANGE OF kodatab.
  TYPES: tt_datum TYPE RANGE OF datum.

  METHODS: werks_selection_screen
    IMPORTING werks TYPE koth700-werks.

  METHODS: modify_screen_1000
    IMPORTING rad01 TYPE char1
              rad02 TYPE char1
    CHANGING  date  TYPE tt_datab
              date1 TYPE tt_datab.
  CLASS-METHODS: modify_screen
    IMPORTING lv_group     TYPE char3
              lv_active    TYPE char1
              lv_input     TYPE char1
              lv_invisible TYPE char1
              lv_required  TYPE char1.

  METHODS: validate_screen_1000
    IMPORTING werks TYPE koth700-werks
              mtart TYPE koth700-mtart
              matnr TYPE tt_matnr
              date  TYPE tt_datab
              date1 TYPE tt_datab
              rad01 TYPE char1
              rad02 TYPE char1.

  CLASS-METHODS: error_message
    IMPORTING lv_group   TYPE char3
    CHANGING  lv_message TYPE char100.

  METHODS: f4_for_variant_alv
    CHANGING lv_variant TYPE disvariant-variant.
  METHODS: run
    IMPORTING p_werks    TYPE koth700-werks
              p_mtart    TYPE koth700-mtart
              s_matnr    TYPE tt_matnr
              s_date     TYPE tt_datab
              s_date1    TYPE tt_datab
              p_vari     TYPE disvariant-variant
              p_rad01    TYPE char1
              p_rad02    TYPE char1
              lv_program TYPE sy-cprog
              title_name TYPE sy-title
              id         TYPE sy-sysid
              mandt      TYPE sy-mandt
              datum      TYPE sy-datum
              username   TYPE sy-uname
              uzeit      TYPE sy-uzeit.
PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zihqmr003_class IMPLEMENTATION.
  METHOD werks_selection_screen.
    SELECT SINGLE * INTO @DATA(ls_t001w) FROM t001w
    WHERE werks = @werks.
    IF ls_t001w IS INITIAL.
      MESSAGE 'Invalid plant' TYPE 'E'.
    ENDIF.
  ENDMETHOD.

  METHOD modify_screen_1000.
    DATA: ls_date1 LIKE LINE OF date1.
    CASE 'X'.
      WHEN rad01.
        modify_screen( lv_group = 'SD1' lv_active = '' lv_input = '0' lv_invisible = '' lv_required = '' ).
        CLEAR : date1[], date1.
      WHEN rad02.
        modify_screen( lv_group = 'SD0' lv_active = '' lv_input = '0' lv_invisible = '' lv_required = '' ).
        ls_date1-low     = sy-datum - 3.
        ls_date1-high    = sy-datum + 3.
        ls_date1-sign    = 'I'.
        ls_date1-option  = 'BT'.
        APPEND ls_date1 TO date1.
        CLEAR : date[], date.
    ENDCASE.
  ENDMETHOD.

  METHOD modify_screen.
    IF lv_input IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = lv_group.
          screen-input  = lv_input.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

    IF lv_active IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = lv_group.
          screen-active  = lv_active.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

    IF lv_invisible IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = lv_group.
          screen-invisible  = lv_invisible.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

    IF lv_required IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = lv_group.
          screen-required  = lv_required.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD validate_screen_1000.
    DATA: message TYPE char100.
    IF werks IS INITIAL.
      message = 'Please input Plant'.
      error_message( EXPORTING lv_group = 'PWE' CHANGING lv_message = message ).
    ENDIF.

    IF mtart IS INITIAL.
      message = 'Please input Material Type'.
      error_message( EXPORTING lv_group = 'PMT' CHANGING lv_message = message ).
    ENDIF.

    CASE 'X'.
      WHEN rad01.
        IF date[] IS INITIAL.
          message = 'Please input Next Inspection Date'.
          error_message( EXPORTING lv_group = 'SD0' CHANGING lv_message = message ).
        ENDIF.
      WHEN rad02.
        IF date1[] IS INITIAL.
          message = 'Please input Expiration Date'.
          error_message( EXPORTING lv_group = 'SD1' CHANGING lv_message = message ).
        ENDIF.
    ENDCASE.
  ENDMETHOD.

  METHOD error_message.
    IF lv_message IS INITIAL.
      lv_message = 'Fill in all required entry fields'.
    ENDIF.

    IF lv_group IS NOT INITIAL.
      LOOP AT SCREEN.
        IF screen-group1 = lv_group.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
        MODIFY SCREEN.
      ENDLOOP.
    ENDIF.

    MESSAGE lv_message TYPE 'E'.
  ENDMETHOD.

  METHOD f4_for_variant_alv.

    DATA: ld_variant TYPE disvariant.
    DATA: ld_repid   TYPE sy-repid.
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
      lv_variant = ld_variant-variant.
    ENDIF.

  ENDMETHOD.

  METHOD run.
    DATA(lo_obj) = NEW lcl_zihqmr003(  p_werks = p_werks p_mtart = p_mtart
    s_matnr = s_matnr s_date = s_date s_date1 = s_date1 p_vari = p_vari
    p_rad01 = p_rad01 p_rad02 = p_rad02 ).
    lo_obj->run( lv_program = lv_program title_name = title_name datum = datum id = id mandt = mandt username = username uzeit = uzeit ).
  ENDMETHOD.
ENDCLASS.
