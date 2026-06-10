*&---------------------------------------------------------------------*
*&  Include           ZSFASD_I0001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  %_OK_CODE_1000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_LOCK_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_lock_table .
*  CALL FUNCTION 'ENQUEUE_EZTKMSDDT002'
*    EXPORTING
*      vkorg    = p_vkorg
*      tplst    = p_tplst
*      scanid   = p_scanid
**        _wait          = 'X'
*    EXCEPTIONS
*      foreign_lock   = 1
*      system_failure = 2
*      OTHERS         = 3.

  CALL FUNCTION 'ENQUEUE_EZTKMSDDT001'
    EXPORTING
      vkorg    = p_vkorg
      tplst    = p_tplst
      nortm    = gv_nortm
*        _wait          = 'X'
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

ENDFORM.                    " F_LOCK_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_unlock_table .
*  CALL FUNCTION 'DEQUEUE_EZTKMSDDT002'
*    EXPORTING
*      vkorg    = p_vkorg
*      tplst    = p_tplst
*      scanid   = p_scanid
**        _wait          = 'X'
*    EXCEPTIONS
*      foreign_lock   = 1
*      system_failure = 2
*      OTHERS         = 3.

  CALL FUNCTION 'DEQUEUE_EZTKMSDDT001'
    EXPORTING
      vkorg    = p_vkorg
      tplst    = p_tplst
      nortm    = gv_nortm
*        _wait          = 'X'
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

ENDFORM.                    " F_UNLOCK_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_PROSES_PICK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_proses_pick .
  UPDATE ztkmsddt006 SET cuntime = p_time
                         cundate = p_date
                         cunname = sy-uname
                         status  = 'U'
          WHERE  vkorg = p_vkorg
            "AND  tplst = p_tplst
            AND  tknum = p_tknum.
  IF sy-subrc EQ 0.
    COMMIT WORK AND WAIT.
    WRITE: / 'Sukses Tulis ke table'.
    SKIP 1.
    WRITE: / 'Shipment No.  : ', p_tknum.
    WRITE: / 'Route         : ', p_route,' - ',p_bezei.
    SKIP 1.

    WRITE: / 'Tanggal Mulai Bongkar di Cabang : ', p_date.
    WRITE: / 'Jam Mulai Bongkar di Cabang     : ', p_time.
    WRITE: / 'PIC Entry/Scan                  : ', sy-uname.
  ELSE.
    ROLLBACK WORK.
    WRITE: / 'Mohon Proses ulang, data tidak tersimpan'.
    gv_message = 'Mohon Proses ulang, data tidak tersimpan'.
    MESSAGE i000(zb) WITH gv_message.
  ENDIF.
ENDFORM.                    " F_PROSES_PICK
*&---------------------------------------------------------------------*
*&      Form  F_FREE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_free_data .
  CLEAR: gs_ztkmsddt001, gs_ztkmsddt002, gs_ztkmsddt004, gv_nortm, gv_message.
ENDFORM.                    " F_FREE_DATA
*&---------------------------------------------------------------------*
*&      Form  f_get_f4
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FT_TABLE      text
*      -->FU_RETFIELD   text
*      -->FU_DYNPROFLD  text
*      -->FU_KOSTL      text
*      -->FU_FLAG       text
*----------------------------------------------------------------------*
FORM f_get_f4  TABLES   ft_table
               USING    fu_retfield fu_dynprofld fu_kostl fu_flag.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield    = fu_retfield
      dynpprog    = sy-repid
      dynpnr      = sy-dynnr
      dynprofield = fu_dynprofld
      value_org   = 'S'
    TABLES
      value_tab   = ft_table.
ENDFORM.                                                    " F_GET_F4
