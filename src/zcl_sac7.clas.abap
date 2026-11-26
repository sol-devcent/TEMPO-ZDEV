class ZCL_SAC7 definition
  public
  final
  create public .

public section.

  class-methods DELETE_SPECIAL_CHAR
    importing
      !PROJECT_NAME type CHAR18
      !PI_CHAR type CHAR1500
    exporting
      !PO_CHAR type CHAR1500 .
  class-methods M_OPEN_DATASET
    importing
      !PARAM_NAME type RLGRAP-FILENAME
    exporting
      !T_RETURN type ZDG2CATT0002 .
protected section.
private section.
ENDCLASS.



CLASS ZCL_SAC7 IMPLEMENTATION.


  METHOD delete_special_char.
    DATA: lv_ascii_code(2),
          lv_char(1),
          lv_length        TYPE int4,
          lv_subrc         TYPE sy-subrc,
          lv_pos_char      TYPE sy-fdpos,
          lv_pos_charx     TYPE sy-fdpos,
          lv_line          TYPE char1500.

    SELECT zchar, '  ' AS ascii_code
      INTO TABLE @DATA(lt_special_char)
      FROM zsac7_char WHERE project_name = @project_name.

    LOOP AT lt_special_char ASSIGNING FIELD-SYMBOL(<fs_spc_char>).
      CALL FUNCTION 'URL_ASCII_CODE_GET'
        EXPORTING
          trans_char = <fs_spc_char>-zchar
        IMPORTING
          char_code  = <fs_spc_char>-ascii_code.
    ENDLOOP.

    LOOP AT lt_special_char ASSIGNING <fs_spc_char>.
      CLEAR: lv_subrc,lv_line,lv_length.
      lv_pos_char = 1.

      WHILE lv_subrc IS INITIAL.
        SEARCH pi_char FOR <fs_spc_char>-zchar STARTING AT lv_pos_char.

        IF sy-subrc = 0.
          lv_subrc = sy-subrc.
          lv_pos_charx = lv_pos_char - 1.

          IF lv_pos_char = 1.
            lv_pos_char = sy-fdpos.
          ELSE.
            lv_pos_char = lv_pos_char + sy-fdpos - 1.
          ENDIF.

          lv_char = pi_char+lv_pos_char(1).

          CALL FUNCTION 'URL_ASCII_CODE_GET'
            EXPORTING
              trans_char = lv_char
            IMPORTING
              char_code  = lv_ascii_code.

          IF lv_ascii_code = <fs_spc_char>-ascii_code.
            IF lv_line IS INITIAL.
              lv_line = pi_char+lv_pos_charx(sy-fdpos).
            ELSE.
              lv_line = |{ lv_line }| & |{ pi_char+lv_pos_charx(sy-fdpos) }|.
            ENDIF.
          ENDIF.

          lv_pos_char = lv_pos_char + 2.

        ELSE.
          lv_subrc = sy-subrc.
        ENDIF.
      ENDWHILE.

      IF lv_line IS NOT INITIAL.
        lv_pos_charx = lv_pos_char - 1.
        lv_length = strlen( pi_char ).
        lv_length = lv_length - lv_pos_charx.
        lv_line = |{ lv_line }| & |{ pi_char+lv_pos_charx(lv_length) }|.
        po_char = lv_line.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD m_open_dataset.
    DATA: lv_text   TYPE string,
          ls_return TYPE zdg2cast0002.

    OPEN DATASET param_name FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc EQ 0.
      DO.
        READ DATASET param_name INTO lv_text.
        IF sy-subrc <> 0.
          EXIT.
        ENDIF.
        MOVE lv_text TO ls_return-string.
        APPEND ls_return TO t_return.
      ENDDO.
    ENDIF.
    CLOSE DATASET param_name.
  ENDMETHOD.
ENDCLASS.
