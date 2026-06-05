*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE0014O01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_2100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_2100 OUTPUT.
* { Changed on 30.05.2002 Temporary Delete p_fakdat
  TYPES: BEGIN OF tab_type,
          fcode LIKE rsmpe-func,
        END OF tab_type.

  DATA: tab TYPE STANDARD TABLE OF tab_type WITH
                 NON-UNIQUE DEFAULT KEY INITIAL SIZE 10,
        wa_tab TYPE tab_type.

  CLEAR tab.
  MOVE 'SALL' TO wa_tab-fcode.   "Select All
  APPEND wa_tab TO tab.
  MOVE 'DALL' TO wa_tab-fcode.   "DeSelect All
  APPEND wa_tab TO tab.
  SET PF-STATUS '2100' EXCLUDING tab.
* } Changed on 30.05.2002 Temporary Delete p_fakdat

  SET TITLEBAR '2100'.
ENDMODULE.                 " STATUS_2100  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  DISPLAY_BILLING  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_billing OUTPUT.
  DATA : lv_faktur(20).
  DATA : gt_vat   LIKE zfvatnr_dtl OCCURS 0 WITH HEADER LINE.

  t_vbrkscr = t_vbrkscr.
  CALL FUNCTION 'ZF_FAKTUR'
    EXPORTING
      bukrs     = p_bukrs
      fakdat    = t_vbrkscr-fakdat
      masatx    = t_vbrkscr-masatx
      fakturin  = t_vbrkscr-fktno
    IMPORTING
      fakturout = t_vbrkscr-fktno1.

  IF t_vbrkscr-fktno1 IS INITIAL.
    CONCATENATE t_vbrkscr-fktno(3) '.' t_vbrkscr-fktno+3(3) '-'
                t_vbrkscr-fktno+6(2) '.' t_vbrkscr-fktno+8(8)
    INTO t_vbrkscr-fktno1.
  ENDIF.
ENDMODULE.                 " DISPLAY_BILLING  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_1400  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_1400 OUTPUT.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_error_list.
ENDMODULE.                 " LIST_PROCESSING_1400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  STATUS_1400  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_1400 OUTPUT.
  SET PF-STATUS space.
*  SET TITLEBAR 'xxx'.
ENDMODULE.                 " STATUS_1400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_9000_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_9000_status OUTPUT.
  SET PF-STATUS 'STAT909192'.
  SET TITLEBAR  'TITLE9000'.
ENDMODULE.                 " M_9000_STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_9000_PREPARESCREEN  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_9000_preparescreen OUTPUT.
  DATA ld_lin9000 TYPE i.
  DESCRIBE TABLE s_9000_table LINES ld_lin9000.
  s_9000_tc-lines = ld_lin9000.
  SORT s_9000_table BY posnr.
ENDMODULE.                 " M_9000_PREPARESCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_9092_SET_TBLCNTRL_VISIBLE  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_9092_set_tblcntrl_visible OUTPUT.
  DATA ld_flag_initial.
  CASE sy-dynnr.
    WHEN '9000'.
      IF s_9000_table-ppnlast IS INITIAL.
        ld_flag_initial = 'X'.
      ENDIF.
    WHEN '9200'.
      IF s_9200_table-ppnlast IS INITIAL.
        ld_flag_initial = 'X'.
      ENDIF.
  ENDCASE.

  CHECK NOT ld_flag_initial IS INITIAL.
  DATA ld_flag_modify.
  LOOP AT SCREEN.
    CASE sy-dynnr.
      WHEN '9000'.
        IF screen-name CS 'S_9000_TABLE-QTY1' OR
           screen-name CS 'S_9000_TABLE-QTY2' OR
           screen-name CS 'S_9000_TABLE-QTY3'.
          ld_flag_modify = 'X'.
        ENDIF.
      WHEN '9200'.
        IF screen-name CS 'S_9200_TABLE-KODE'.
          ld_flag_modify = 'X'.
        ENDIF.
    ENDCASE.
    IF NOT ld_flag_modify IS INITIAL.
      screen-active = 0.
      MODIFY SCREEN.
      CLEAR ld_flag_modify.
    ENDIF.
  ENDLOOP.

ENDMODULE.                 " M_9092_SET_TBLCNTRL_VISIBLE  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  M_9100_STATUS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_9100_status OUTPUT.
  SET PF-STATUS 'STAT909192'.
  SET TITLEBAR  'TITLE9100'.
ENDMODULE.                 " M_9100_STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_9100_PREPARESCREEN  OUTPUT
*&---------------------------------------------------------------------*
MODULE m_9100_preparescreen OUTPUT.
  SORT s_9100_table BY posnr.
ENDMODULE.                 " M_9000_PREPARESCREEN  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  M_STATUS_9500  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE m_status_9500 OUTPUT.
  SET PF-STATUS 'STATUS_BLANK'.
  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING.
  d_leave_to_screen_0 = 'X'.

  DATA ld_intensified.
  WRITE : / 'Tax Number Created = ' COLOR COL_HEADING.

  LOOP AT t_zgdtxdt0003.
    IF ld_intensified IS INITIAL.
      FORMAT INTENSIFIED ON.
      ld_intensified = 'X'.
    ELSE.
      FORMAT INTENSIFIED OFF.
      CLEAR ld_intensified.
    ENDIF.
    WRITE / t_zgdtxdt0003-fakturno COLOR COL_NORMAL.
  ENDLOOP.
ENDMODULE.                 " M_STATUS_9500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  M_9600_SET_SCREEN  OUTPUT
*&---------------------------------------------------------------------*
MODULE m_9600_set_screen OUTPUT.
  SET PF-STATUS 'BLANK'.
* Option 3 & 4 (Radio button Kacab & KaAdm) for Tax Approval only appear
* if the branch use Head office's PKP
***modified by Rahmadi
*--Head office applicable condition only
*  IF NOT d_nr_gsber CS '000'.
  IF d_hoind IS INITIAL.
***end of modification
    LOOP AT SCREEN.
      IF screen-name = 'S_9600_RB_PETUGAS3' OR
         screen-name = 'S_9600_RB_PETUGAS4' OR
         screen-name = 'S_9600_IO_PETUGAS3' OR
         screen-name = 'S_9600_IO_PETUGAS4' OR
         screen-name = 'S_9600_TEXT_BRANCHOFFICE' OR
         screen-name = 'S_9600_TEXT_HEADOFFICE'.
        screen-active    = 0.
        screen-input     = 0.
        screen-output    = 0.
        screen-required  = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDMODULE.                 " M_9600_SET_SCREEN  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  list_processing_5000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE list_processing_5000 OUTPUT.

  SUPPRESS DIALOG.
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.
  PERFORM f_call_function USING 'X'
                                'X'
                                ' '
                                p_mpage
                                p_dest
                                space
                                p_cust
                       CHANGING d_subrcp.

ENDMODULE.                 " list_processing_5000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  status_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_3000 OUTPUT.

  SET PF-STATUS 'STAT_3000'.
  SET TITLEBAR 'TITLE_3000'.
  d_dynnr = sy-dynnr.

ENDMODULE.                 " status_3000  OUTPUT
