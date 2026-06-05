*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0014I01                                           *
*----------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Module  USER_EXIT_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_exit_2100 INPUT.
  LEAVE TO TRANSACTION sy-tcode.
ENDMODULE.                 " USER_EXIT_2100  INPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_1300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_1300 INPUT.

  CASE sy-ucomm.
    WHEN 'ZBACK' OR 'ZCANC' OR 'ZEXIT'.
      PERFORM f_clear_data USING '02'.
      LEAVE LIST-PROCESSING.
    WHEN 'VLOG'.
      DELETE ADJACENT DUPLICATES FROM t_error COMPARING vbeln msg.
      CALL SCREEN 1400 STARTING AT 10 10 ENDING AT 130 22.
    WHEN 'SALL'.
      PERFORM f_select_deselect USING  'X'.
    WHEN 'DALL'.
      PERFORM f_select_deselect USING ' '.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_1300  INPUT

*&---------------------------------------------------------------------*
*&      Module  CHECK_BILLING  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE check_billing INPUT.
  MODIFY t_vbrkscr INDEX ctrl_1300-current_line.
ENDMODULE.                 " CHECK_BILLING  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT_SCREEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE exit_screen INPUT.
  PERFORM f_exit_screens USING d_dynnr.
ENDMODULE.                 " EXIT_SCREEN  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_9000_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_9000_exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " M_9000_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_9000_READ_TABLE_CONTROL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_9000_read_table_control INPUT.
  DATA ld_qty TYPE i.
  MODIFY s_9000_table
         FROM     s_9000_table
         INDEX    s_9000_tc-current_line.

  IF sy-ucomm <> 'BACK'.
    IF s_9000_table-nqty1 > s_9000_table-qty1 OR
       s_9000_table-nqty2 > s_9000_table-qty2 OR
       s_9000_table-nqty3 > s_9000_table-qty3.
      MESSAGE e000(zz) WITH 'New Quantity > Old Quantity'.
    ENDIF.

    CLEAR ld_qty.
    ld_qty = s_9000_table-nqty1 +
             s_9000_table-nqty2 +
             s_9000_table-nqty3.
    IF ld_qty <> s_9000_table-itqtylast.
      MESSAGE e000(zz) WITH 'Qty error'.
    ENDIF.
  ENDIF.

ENDMODULE.                 " M_9000_READ_TABLE_CONTROL  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_9000_CHECK_COLUMN_QTY  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_9000_check_column_qty INPUT.
  DATA: ld_flag_nqty1_empty,
        ld_flag_nqty2_empty,
        ld_flag_nqty3_empty,
        ld_temp_flag2,
        ld_tabix           LIKE sy-tabix.

  ld_flag_nqty1_empty = 'X'.
  ld_flag_nqty2_empty = 'X'.
  ld_flag_nqty3_empty = 'X'.

* 1. Which column of Qty1 / 2 / 3 is empty?
  LOOP AT s_9000_table.
    IF NOT s_9000_table-nqty1 IS INITIAL.
      CLEAR ld_flag_nqty1_empty.
    ENDIF.
    IF NOT s_9000_table-nqty2 IS INITIAL.
      CLEAR ld_flag_nqty2_empty.
    ENDIF.
    IF NOT s_9000_table-nqty3 IS INITIAL.
      CLEAR ld_flag_nqty3_empty.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " M_9000_CHECK_COLUMN_QTY  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_9000_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_9000_user_command INPUT.
  d_save_okcode = ok_code.
  CLEAR ok_code.

  CASE d_save_okcode.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      PERFORM f_ucomm_preview_save_print
              USING '9000'
                    'N'
                    'X'.
  ENDCASE.

ENDMODULE.                 " M_9000_USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_9000_EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE m_9100_exit INPUT.
  LEAVE TO SCREEN 0.
ENDMODULE.                 " M_9000_EXIT  INPUT

*---------------------------------------------------------------------*
*       MODULE m_9100_check_total_amtlast INPUT                       *
*---------------------------------------------------------------------*
MODULE m_9100_check_total_amtlast INPUT.
  DATA ld_total LIKE s_9100_io_namtlast1.
  IF sy-ucomm <> 'BACK'.
    ld_total = s_9100_io_namtlast1 + s_9100_io_namtlast2 +
               s_9100_io_namtlast3.
    IF ld_total <> d_9100_amtlasttotal.
      MESSAGE e000(zz)
            WITH 'Error, total split price not equal with total price!'.
    ENDIF.
  ENDIF.
ENDMODULE.                    "m_9100_check_total_amtlast INPUT

*---------------------------------------------------------------------*
*       MODULE m_9100_check_total_amt INPUT                           *
*---------------------------------------------------------------------*
MODULE m_9100_check_total_amt INPUT.
  IF sy-ucomm <> 'BACK'.
    IF ( s_9100_io_namtlast1 > s_9100_io_amtlast1 ) OR
       ( s_9100_io_namtlast2 > s_9100_io_amtlast2 ) OR
       ( s_9100_io_namtlast3 > s_9100_io_amtlast3 ).
      MESSAGE e000(zz)
              WITH 'Error, Price is greater than Previous!'.
    ENDIF.
  ENDIF.
ENDMODULE.                    "m_9100_check_total_amt INPUT

*---------------------------------------------------------------------*
*       MODULE m_9100_check_total_disc INPUT                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
MODULE m_9100_check_total_disc INPUT.
  IF sy-ucomm <> 'BACK'.
    IF ( s_9100_io_ndisc1 > s_9100_io_disc1 ) OR
       ( s_9100_io_ndisc2 > s_9100_io_disc2 ) OR
       ( s_9100_io_ndisc3 > s_9100_io_disc3 ).
      MESSAGE e000(zz)
              WITH 'Error, Discount is greater than Previous!'.
    ENDIF.
  ENDIF.
ENDMODULE.                    "m_9100_check_total_disc INPUT


*---------------------------------------------------------------------*
*       MODULE m_9100_check_total_discount INPUT                      *
*---------------------------------------------------------------------*
MODULE m_9100_check_total_discount INPUT.
  IF sy-ucomm <> 'BACK'.
    ld_total = s_9100_io_ndisc1 + s_9100_io_ndisc2 +
               s_9100_io_ndisc3.
    IF ld_total <> d_9100_totaldisc.
      MESSAGE e000(zz)
         WITH
         'Error Total discount price not equal with total disc price!'.
    ENDIF.
  ENDIF.
ENDMODULE.                    "m_9100_check_total_discount INPUT

*---------------------------------------------------------------------*
*       MODULE m_9100_user_command INPUT                              *
*---------------------------------------------------------------------*
MODULE m_9100_user_command INPUT.
  d_save_okcode = ok_code.
  CLEAR ok_code.

  CASE d_save_okcode.
    WHEN 'BACK' OR 'CANC'.
      LEAVE TO SCREEN 0.

    WHEN 'SAVE'.
      PERFORM f_ucomm_preview_save_print
              USING '9100'
                    'N'
                    'X'.

  ENDCASE.
ENDMODULE.                    "m_9100_user_command INPUT

*&---------------------------------------------------------------------*
*&      Module  M_USER_COMMAND_9500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_user_command_9500 INPUT.
  d_save_okcode = ok_code.
  CLEAR ok_code.
  CASE d_save_okcode.
    WHEN 'BACK' OR 'CANC' OR 'EXIT'.
      LEAVE TO SCREEN 0.
  ENDCASE.
ENDMODULE.                 " M_USER_COMMAND_9500  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_2100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_2100 INPUT.

  IF ok-code = c_satuan OR
     ok-code = c_gabungan OR
     ok-code = c_split.
    tabstrip-activetab = ok-code.
  ENDIF.

  CASE ok-code.
    WHEN c_satuan.
      PERFORM f_satuan.
    WHEN c_gabungan.
      PERFORM f_gabungan.
    WHEN c_split.
      PERFORM f_split.
  ENDCASE.

  CASE sy-ucomm.
    WHEN 'ZBACK' OR 'ZCANC' OR 'ZEXIT'.
      PERFORM f_clear_data USING '02'.
      SET SCREEN 0.
      LEAVE SCREEN.
    WHEN 'PROCS'.
      BREAK ibm_rahmadi.
      BREAK bcdik.
      PERFORM f_process TABLES t_vbrkscr.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_2100  INPUT

*&---------------------------------------------------------------------*
*&      Module  M_9600_USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE m_9600_user_command INPUT.
  d_save_okcode = ok_code.
  CASE d_save_okcode.
    WHEN 'FCT_OK'.
      d_save = 'X'.
      CLEAR: d_display, d_cancel.
      LEAVE TO SCREEN 0.
***added by Rahmadi to display Debit memo 16/07/2004
    WHEN 'VIEW'.
      d_display = 'X'.
      CLEAR: d_save, d_cancel.
      LEAVE TO SCREEN 0.
    WHEN 'CANC'.
      d_cancel = 'X'.
      CLEAR: d_save, d_display.
      LEAVE TO SCREEN 0.
***end of addition
  ENDCASE.
ENDMODULE.                 " M_9600_USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  display_detail  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_detail INPUT.

  PERFORM f_display_billing.

ENDMODULE.                 " display_detail  INPUT

*&---------------------------------------------------------------------*
*&      Module  user_command_3000  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_3000 INPUT.

  CASE sy-ucomm.
    WHEN 'YES'.
      LEAVE TO SCREEN 0.
    WHEN 'NO'.
      CLEAR d_fakno_screen.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " user_command_3000  INPUT

*&---------------------------------------------------------------------*
*&      Module  m_check_fakno  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_check_fakno INPUT.

  DATA ld_fakturno LIKE zgdtxdt0003-fakturno.
  DATA: ld_vatfr LIKE zfvatnr-vatfr,
        ld_vatto LIKE zfvatnr-vatto.

  IF radio1 EQ 'X'.
    IF d_nofp IS INITIAL.
      MESSAGE e000(zab) WITH 'Faktur Pajak number cannot be blank'.
    ENDIF.
    CONCATENATE d_fpone
                d_fptwo
                d_nofp
                INTO d_fakno_screen
                SEPARATED BY '-'.

    SELECT SINGLE fakturno INTO ld_fakturno
                           FROM zgdtxdt0003
                           WHERE brnch = p_brnch AND
                                 fakturno = d_fakno_screen.
    IF sy-subrc = 0.
      MESSAGE e000(zab) WITH 'Faktur pajak number has been used '
                             'by other billing in the same branch'.
    ELSE.
      SELECT SINGLE * FROM nriv
                     WHERE object = d_objrange AND
                           subobject = p_brnch AND
                           nrlevel <> 0.
      IF d_nofp GE nriv-fromnumber AND
         d_nofp LE nriv-tonumber.
        MESSAGE e000(zab) WITH 'Faktur pajak number cannot be within'
                               'current running number'.
      ENDIF.
    ENDIF.
  ELSE.
    IF d_nofp1 IS INITIAL AND
      d_nofp2 IS INITIAL AND
      d_nofp3 IS INITIAL AND
      d_nofp4 IS INITIAL.
      MESSAGE e000(zab) WITH 'Faktur Pajak number cannot be blank'.
    ENDIF.

    CONCATENATE d_nofp1
                d_nofp2
                d_nofp3
                d_nofp4
                INTO d_fakno_screen.

    IF ( p_bukrs EQ '8220' OR
      p_bukrs EQ '8180' OR
      p_bukrs EQ '8210' OR
      p_bukrs EQ '8040' ).
      BREAK bcdik.
    ELSE.
      SELECT SINGLE fakturno INTO ld_fakturno
                             FROM zgdtxdt0003
                             WHERE brnch = p_brnch AND
                                   fakturno = d_fakno_screen.
      IF sy-subrc = 0.
        MESSAGE e000(zab) WITH 'Faktur pajak number has been used '
                               'by other billing in the same branch'.
      ELSE.
        SELECT SINGLE vatfr vatto FROM zfvatnr
                       INTO (ld_vatfr, ld_vatto)
                       WHERE vkorg = p_brnch.
        IF d_nofp4 LT ld_vatfr AND
           d_nofp4 GT ld_vatto.
          MESSAGE e000(zab) WITH 'Faktur pajak number cannot be within'
                                 'current running number'.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
ENDMODULE.                 " m_check_fakno  INPUT
