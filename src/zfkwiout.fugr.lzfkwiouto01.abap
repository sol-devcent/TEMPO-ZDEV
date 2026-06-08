*----------------------------------------------------------------------*
***INCLUDE LZFKWIOUTO01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VALIDASI_CELL  OUTPUT
*&---------------------------------------------------------------------*
MODULE validasi_cell OUTPUT.
  DATA: lv_usrgrp    TYPE xuclass.

  SELECT SINGLE usergroup
    FROM usgrp_user
    INTO lv_usrgrp
    WHERE bname     EQ sy-uname
      AND usergroup EQ 'FINHO'.

  LOOP AT SCREEN.
    IF screen-name EQ 'ZFKWIOUT-ZHIT' OR
      screen-name EQ 'ZFKWIOUT-ZUSERC' OR
      screen-name EQ 'ZFKWIOUT-ZDATC' OR
      screen-name EQ 'ZFKWIOUT-ZUSERL' OR
      screen-name EQ 'ZFKWIOUT-ZDATL'.
      screen-input  = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  IF lv_usrgrp IS INITIAL.
    LOOP AT SCREEN.
      IF screen-name EQ 'ZFKWIOUT-ZSTS' OR
        screen-name EQ 'ZFKWIOUT-STATUS'.
        screen-input  = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " VALIDASI_CELL  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  CHANGE_LOCKING  OUTPUT
*&---------------------------------------------------------------------*
MODULE change_locking OUTPUT.
  DATA : lv_bukrs   TYPE bukrs,
         lv_vkbur   TYPE vkbur.

  LOOP AT dba_sellist.
    CASE dba_sellist-viewfield.
      WHEN 'BUKRS'.
        lv_bukrs  = dba_sellist-value.
      WHEN 'VKBUR'.
        lv_vkbur  = dba_sellist-value.
    ENDCASE.
  ENDLOOP.

  CALL FUNCTION 'ENQUEUE_EZFKWIOUT'
    EXPORTING
      bukrs          = lv_bukrs
      vkbur          = lv_vkbur
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.
  IF sy-subrc NE 0.
    LOOP AT SCREEN.
      screen-input = 0.
      MODIFY SCREEN.
    ENDLOOP.
    MESSAGE i000(zab) WITH 'Transaction is locked by another user'.
  ENDIF.
ENDMODULE.                 " CHANGE_LOCKING  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_ENTRY  INPUT
*&---------------------------------------------------------------------*
MODULE user_entry INPUT.
  SELECT SINGLE usergroup
    FROM usgrp_user
    INTO lv_usrgrp
    WHERE bname     EQ sy-uname
      AND usergroup EQ 'FINHO'.

  CASE lv_usrgrp.
    WHEN 'FINHO'.
      zfkwiout-zuserc   = sy-uname.
      zfkwiout-zdatc    = sy-datum.
      IF zfkwiout-status IS NOT INITIAL.
        zfkwiout-zuserl   = sy-uname.
        zfkwiout-zdatl    = sy-datum.
      ENDIF.
    WHEN OTHERS.
      zfkwiout-zuserc   = sy-uname.
      zfkwiout-zdatc    = sy-datum.
      IF zfkwiout-status IS INITIAL.
        SELECT SINGLE name1
          FROM kna1
          INTO zfkwiout-status
          WHERE kunnr EQ zfkwiout-kunnr.
      ENDIF.

      IF sy-ucomm EQ 'DELE'.
        MESSAGE 'You are not authorized' TYPE 'E' DISPLAY LIKE 'I'.
      ENDIF.
  ENDCASE.
ENDMODULE.                 " USER_ENTRY  INPUT

*&---------------------------------------------------------------------*
*&      Module  SORT  OUTPUT
*&---------------------------------------------------------------------*
MODULE sort OUTPUT.
  DATA : lt_zfkwiout  LIKE zfkwiout OCCURS 0 WITH HEADER LINE.

  IF sy-ucomm EQ 'OKAY' OR sy-ucomm EQ 'BACK'.
    lt_zfkwiout[] = extract[].
    SORT lt_zfkwiout BY zsts kunnr.
    CLEAR : extract[], extract.
    extract[] = lt_zfkwiout[].
  ENDIF.
ENDMODULE.                 " SORT  OUTPUT
