*----------------------------------------------------------------------*
*   INCLUDE ZGDFIE0001I01                                              *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  m_user_command_9010  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_9010 INPUT.

  DATA p_tc_name TYPE dynfnam.
  DATA: ld_masatx LIKE zgdtxdt0003-masatx.

  CASE sy-ucomm.
    WHEN 'SALL'.
      PERFORM f_select_deselect USING  'X'.
    WHEN 'DALL'.
      PERFORM f_select_deselect USING  ''.
    WHEN 'POST'.
      CLEAR: t_crb_head, t_crb_item, t_status, t_9010x,
             t_crb_head[], t_crb_item[], t_status[], t_9010x[],
             d_par.
      PERFORM f_process_selected_data.
      PERFORM f_post_acc_doc.
      IF d_par = 'LOG'.
        PERFORM f_free_memory.
        LEAVE TO SCREEN 0.
      ENDIF.
    WHEN 'OVIEW'.
      CLEAR: t_crb_head, t_crb_item, t_status, t_9010x,
             t_crb_head[], t_crb_item[], t_status[], t_9010x[].
      PERFORM f_process_selected_data.





      CONCATENATE bkpf-budat(4) bkpf-budat+4(2) INTO ld_masatx.

      PERFORM f_get_next_number_disp USING 'ZGDTXNR001'
                                  ' '
                                  '8160'
                                  ld_masatx
                                  ' '
                                  ' '
                                  bkpf-budat
                         CHANGING va_fakno sy-subrc.


      PERFORM f_print_form.
*    WHEN 'P--'.
*      PERFORM f_paging USING 'P--'.
*    WHEN 'P-'.
*      PERFORM f_paging USING 'P-'.
*    WHEN 'P+'.
*      PERFORM f_paging USING 'P+'.
*    WHEN 'P++'.
*      PERFORM f_paging USING 'P++'.
    WHEN 'P--' OR                     "top of list
         'P-'  OR                     "previous page
         'P+'  OR                     "next page
         'P++'.                       "bottom of list
      p_tc_name = 'TC_9010'.
      PERFORM compute_scrolling_in_tc1 USING p_tc_name
                                             sy-ucomm.
*      CLEAR p_ok.

    WHEN 'PRINT'.
    WHEN 'LOCK'.
      IF NOT t_lock[] IS INITIAL.
        PERFORM f_display_lock.
      ELSE.
        MESSAGE i000(zab) WITH 'No locked PO found'.
      ENDIF.

  ENDCASE.

ENDMODULE.                 " m_user_command_9010  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_exit  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_exit INPUT.

  CASE sy-ucomm.
    WHEN 'EXIT' OR 'BACK' OR 'CANC'.
      PERFORM f_free_memory.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " m_exit  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_display_detail_cust  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_display_detail_cust INPUT.

  DATA ld_line TYPE i.
  DATA ld_kunnr LIKE kna1-kunnr.
  DATA ld_bukrs1 LIKE t001-bukrs.

  CASE sy-dynnr.
    WHEN '9010'.
*-- get the current index selected by user
      GET CURSOR LINE ld_line.
      ld_kunnr = t_9010-kunnr.
    WHEN '9020'.
      ld_kunnr = kna1-kunnr.
  ENDCASE.

  ld_bukrs1 = d_tnt_bukrs.

  IF sy-subrc = 0 AND ld_kunnr <> '' AND ld_bukrs1 <> ''.
    SET PARAMETER ID 'KUN' FIELD ld_kunnr.
    SET PARAMETER ID 'BUK' FIELD ld_bukrs1.
    CALL TRANSACTION 'FD03' AND SKIP FIRST SCREEN.
  ENDIF.

ENDMODULE.                 " m_display_detail_cust  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_display_detail_po  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_display_detail_po INPUT.

  DATA ld_line1 TYPE i.
  DATA ld_ebeln LIKE ekko-ebeln.

  CASE sy-dynnr.
    WHEN '9010'.
*-- get the current index selected by user
      GET CURSOR LINE ld_line1.
*      READ TABLE t_9010 INDEX ld_line1.
      ld_ebeln = t_9010-ebeln.
    WHEN '9020'.
      ld_ebeln = s911-ebeln.
  ENDCASE.

  IF sy-subrc = 0 AND ld_ebeln <> ''.
    SET PARAMETER ID 'BES' FIELD ld_ebeln.
    CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
  ENDIF.

ENDMODULE.                 " m_display_detail_po  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_user_command_9020  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_9020 INPUT.

  CASE sy-ucomm.
    WHEN 'SAVE'.
      PERFORM f_save_po_change ON COMMIT.
      COMMIT WORK AND WAIT.
      IF sy-subrc = 0.
        LEAVE TO SCREEN 0.
        MESSAGE i000(zab) WITH 'PO'
                               p_ebeln
                               p_vrsio
                               'has been successfully updated'.
      ELSE.
        MESSAGE a000(zab) WITH 'Error when updating S911 table'.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " m_user_command_9020  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_display_detail_doc  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_display_detail_doc INPUT.

  DATA ld_belnr LIKE s911-belnr.
  DATA ld_bukrs LIKE t001-bukrs.
  DATA ld_stjah LIKE s911-stjah.

  ld_belnr = s911-belnr.
  ld_bukrs = t001-bukrs.
  ld_stjah = s911-stjah.
*-- get the current index selected by user
  IF ld_belnr <> '' AND
     ld_bukrs <> '' AND
     ld_stjah <> ''.
    SET PARAMETER ID 'RBN' FIELD ld_belnr.
    SET PARAMETER ID 'BUK' FIELD ld_bukrs.
    SET PARAMETER ID 'GJR' FIELD ld_stjah.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.

ENDMODULE.                 " m_display_detail_doc  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_edit_record  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_edit_record INPUT.

  MODIFY t_9010 INDEX tc_9010-current_line.
  d_line_count = sy-loopc.

ENDMODULE.                 " m_edit_record  INPUT

* INPUT MODULE FOR TABLECONTROL 'TC_9030': MARK TABLE
MODULE tc_9030_mark INPUT.
  MODIFY t_fidt0003
    INDEX tc_9030-current_line
    TRANSPORTING sel.
ENDMODULE.                    "tc_9030_mark INPUT

* INPUT MODULE FOR TABLECONTROL 'TC_9030': PROCESS USER COMMAND
MODULE tc_9030_user_command INPUT.
  ok_code = sy-ucomm.
  PERFORM user_ok_tc USING    'TC_9030'
                              'T_FIDT0003'
                              'SEL'
                     CHANGING ok_code.
ENDMODULE.                    "tc_9030_user_command INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_9030  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_9030 INPUT.

  CASE ok_code.

    WHEN 'YES'.
      READ TABLE t_fidt0003 WITH KEY sel = 'X'.
      d_kunnr = t_fidt0003-kunnr.
      LEAVE TO SCREEN 0.

    WHEN 'NO'.
      CLEAR d_kunnr.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " user_command_9030  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_user_command_9040  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_9040 INPUT.

  CASE sy-ucomm.
    WHEN 'SAVE'.
      PERFORM f_save_po_special.
      COMMIT WORK AND WAIT.
      IF sy-subrc = 0.
        IF d_mess = 'J'.
          MESSAGE i000(zab) WITH 'PO'
                                 s911-ebeln
                                 s911-vrsio
                                 'has been successfully updated'.
        ENDIF.
        CLEAR d_mess.
        LEAVE TO SCREEN 0.
      ELSE.
        MESSAGE a000(zab) WITH 'Error when updating S911 table'.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " m_user_command_9040  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_check_zgdfidt0001  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_zgdfidt0001 INPUT.

  SELECT SINGLE * FROM zgdfidt0001
                  WHERE ekgrp = s911-ekgrp AND
                        bsart = s911-bsart.
  IF sy-subrc <> 0.
    MESSAGE e000(zab) WITH s911-ekgrp
                           'is not matched with'
                           s911-bsart.
  ENDIF.

ENDMODULE.                 " m_check_zgdfidt0001  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_check_ekko  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_ekko INPUT.

***External PO must not exist in SAP
  SELECT SINGLE * FROM ekko
                  WHERE ebeln = s911-ebeln.
  IF sy-subrc = 0.
    MESSAGE e000(zab) WITH 'Invalid external PO'.
  ELSE.
    IF s911-ebeln(1) <> 'X'.
      MESSAGE e000(zab) WITH 'First character must be X'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " m_check_ekko  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_fill_hwaer  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_fill_hwaer INPUT.

  d_hwaer1 = s911-hwaer.

ENDMODULE.                 " m_fill_hwaer  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_lock_record  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_lock_record INPUT.

  DATA ld_uname LIKE sy-uname.

  PERFORM f_lock_s911_rec USING s911
                          CHANGING ld_uname.
  IF NOT ld_uname IS INITIAL.
    MESSAGE e000(zab) WITH 'PO' s911-ebeln
                           'is locked by' ld_uname.
  ENDIF.

ENDMODULE.                 " m_lock_record  INPUT


*&---------------------------------------------------------------------*
*&      Form  f_get_next_number_disp
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FU_OBJECT    text
*      -->FU_GSBER     text
*      -->FU_BRNCH     text
*      -->FU_MASATX    text
*      -->FU_FORM      text
*      -->FU_ASSET     text
*      -->FC_FAKTURNO  text
*      -->FC_SUBRC     text
*----------------------------------------------------------------------*
FORM f_get_next_number_disp USING fu_object
                             fu_gsber
                             fu_brnch
                             fu_masatx
                             fu_form
                             fu_asset
                             fu_fakdat
                    CHANGING fc_fakturno fc_subrc.

  DATA lw_nriv     LIKE nriv.
  DATA ld_nrlevel  LIKE nriv-tonumber.
  DATA ld_fakturno LIKE nriv-nrlevel.
  DATA ld_fakno    LIKE nriv-nrlevel.
  DATA ld_vatno    LIKE zfvatnr-vatno.
  DATA ld_posnr    LIKE zfvatnr-posnr.
  DATA lc_vatno(8).
  DATA ld_vatbr(3).
  DATA ld_vattrn   LIKE zfvattrn-vattrn.
  DATA ld_vatno1(10).
  DATA: lv_datum LIKE sy-datum.
  DATA: lv_date LIKE sy-datum.
  DATA: lt_fakturno    TYPE STANDARD TABLE OF zgdtxdt0011
                        WITH HEADER LINE,
        lt_zfvatnr     TYPE STANDARD TABLE OF zfvatnr
                        WITH HEADER LINE,
        lt_zfvatnr_dtl TYPE STANDARD TABLE OF zfvatnr_dtl
                        WITH HEADER LINE,
        ld_reuse,

        ld_masatx      LIKE zgdtxdt0011-masatx.
  DATA: l_len    TYPE i, l_posisi TYPE i.

  RANGES: lr_masatx FOR zgdtxdt0011-masatx.

  CLEAR: ld_masatx, lr_masatx.
  REFRESH lr_masatx.

  ld_masatx = fu_masatx - 1.
  lr_masatx-sign   = 'I'.
  lr_masatx-option = 'EQ'.
  lr_masatx-low    = ld_masatx.
  APPEND lr_masatx.
  lr_masatx-low    = fu_masatx.
  APPEND lr_masatx.

  CLEAR: fc_subrc, ld_posnr.
  fc_subrc = 3.
  ld_posnr = 10.
*  IF fu_masatx(4) GT 2006.

  SELECT SINGLE vattrn vatbr
    FROM zfvattrn
    INTO (ld_vattrn, ld_vatbr)
    WHERE vkorg EQ fu_brnch AND
          gform EQ 'A1'.

  IF fu_asset EQ 'X'.
    ld_vattrn = '09'.
  ENDIF.

  IF fu_fakdat > gs_dpp-datab.
    IF ld_vattrn = '01'.
      ld_vattrn = '04'.
    ENDIF.
  ENDIF.

  IF fu_fakdat IN gr_coretax.
  ELSE.
* check reuseable faktur number
    SELECT *
      FROM zgdtxdt0011
      INTO TABLE lt_fakturno
      WHERE brnch    EQ fu_brnch  AND
            masatx   IN lr_masatx AND
            objrange EQ fu_object.
    IF sy-subrc EQ 0.
      LOOP AT lt_fakturno.
        CALL FUNCTION 'ENQUEUE_EZGDTXDT0011'
          EXPORTING
            mode_zgdtxdt0011 = 'E'
            mandt            = sy-mandt
*           gsber            = fu_gsber
            brnch            = fu_brnch
            fakturno         = lt_fakturno-fakturno
            masatx           = lt_fakturno-masatx
            objrange         = lt_fakturno-objrange
          EXCEPTIONS
            foreign_lock     = 1
            system_failure   = 2
            OTHERS           = 3.
        IF sy-subrc = 0.
          CLEAR ld_reuse.
          MOVE-CORRESPONDING lt_fakturno TO t_zgdtxdt0011.
          APPEND t_zgdtxdt0011.
          EXIT.
        ELSE.
          ld_reuse = 'X'.
          CONTINUE.
        ENDIF.
      ENDLOOP.

      fc_fakturno = lt_fakturno-fakturno.
*    DELETE zgdtxdt0011 FROM t_zgdtxdt0011.
    ELSE.
*--- Tambahan kondisi penomoran faktur pajak mulai dari tahun 2013

      SELECT SINGLE *
        FROM zfvatnr
        INTO lt_zfvatnr
        WHERE vkorg EQ fu_brnch AND
              vkbur EQ ld_vatbr AND
              gjahr EQ fu_masatx(4).
      IF lt_zfvatnr-posnr EQ 0.
        SELECT SINGLE *
          FROM zfvatnr_dtl
          INTO lt_zfvatnr_dtl
          WHERE vkorg EQ fu_brnch AND
                vkbur EQ ld_vatbr AND
                gjahr EQ fu_masatx(4) AND
                posnr EQ ld_posnr.
        IF sy-subrc EQ 0.
          CONDENSE lt_zfvatnr_dtl-vatpr.
          l_len = strlen( lt_zfvatnr_dtl-vatpr ).
          IF l_len > 4.
            fc_subrc = 2.
          ELSE.
            lc_vatno = lt_zfvatnr_dtl-vatfr.
            l_posisi = l_len.
            l_len = 8 - l_len.
            lc_vatno = lc_vatno+l_posisi(l_len).
            CONCATENATE ld_vattrn '0' lt_zfvatnr_dtl-vatcd fu_masatx+2(2) lt_zfvatnr_dtl-vatpr lc_vatno
            INTO fc_fakturno.
            CLEAR fc_subrc.
*          ENDIF.
          ENDIF.
        ELSE.
          fc_subrc = 3.
        ENDIF.
      ELSE.
        ld_vatno = lt_zfvatnr-vatno + 1.
        IF ld_vatno <= lt_zfvatnr-vatto.
          CONDENSE lt_zfvatnr-vatpr.
          l_len = strlen( lt_zfvatnr-vatpr ).
          IF l_len > 4.
            fc_subrc = 2.
          ELSE.
            l_posisi = l_len.
            l_len = 8 - l_len.
            lc_vatno = ld_vatno+l_posisi(l_len).

            CONCATENATE ld_vattrn '0' lt_zfvatnr-vatcd fu_masatx+2(2) lt_zfvatnr-vatpr lc_vatno
            INTO fc_fakturno.
            CLEAR fc_subrc.
          ENDIF.
        ELSE.
          lt_zfvatnr-posnr = lt_zfvatnr-posnr + 10.
          SELECT SINGLE *
            FROM zfvatnr_dtl
            INTO lt_zfvatnr_dtl
            WHERE vkorg EQ fu_brnch AND
                  vkbur EQ ld_vatbr AND
                  gjahr EQ fu_masatx(4) AND
                  posnr EQ lt_zfvatnr-posnr.
          IF sy-subrc EQ 0.
            CONCATENATE ld_vattrn '0' lt_zfvatnr_dtl-vatcd fu_masatx+2(2) lt_zfvatnr_dtl-vatpr lt_zfvatnr_dtl-vatfr
            INTO fc_fakturno.
            CLEAR fc_subrc.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " F_GET_NEXT_NUMBER
