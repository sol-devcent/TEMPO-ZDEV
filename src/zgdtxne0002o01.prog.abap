*----------------------------------------------------------------------*
*   INCLUDE ZGDTXNE00002O01                                           *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_1300  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_1300 OUTPUT.

  PERFORM f_set_status.

ENDMODULE.                 " STATUS_1300  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DISPLAY_BILLING  OUTPUT
*&---------------------------------------------------------------------*
MODULE display_billing OUTPUT.

  t_vbrkscr = t_vbrkscr.

**Screen variant
  CASE d_tcode.
    WHEN c_tcode_satuan.
      LOOP AT ctrl_1300-cols INTO wa_cols.
        IF wa_cols-screen-name = 'T_VBRKSCR-NAME' OR
           wa_cols-screen-name = '%#AUTOTEXT014'.
          wa_cols-invisible = '1'.
          MODIFY ctrl_1300-cols FROM wa_cols.
        ENDIF.
      ENDLOOP.
      IF d_rpc IS INITIAL.
        LOOP AT ctrl_1300-cols INTO wa_cols.
          IF wa_cols-screen-name = 'T_VBRKSCR-STATUS' OR
             wa_cols-screen-name = '%#AUTOTEXT015'.
            wa_cols-invisible = '1'.
            MODIFY ctrl_1300-cols FROM wa_cols.
          ENDIF.
        ENDLOOP.
      ELSE.   "RPC only
        LOOP AT SCREEN.
          IF screen-name = 'T_VBRKSCR-TAX' OR
             screen-name = 'T_VBRKSCR-SEL'.
            screen-input = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
    WHEN c_tcode_sederhana OR
         c_tcode_sederhana_single.    "CR009 16/04/2002
      LOOP AT ctrl_1300-cols INTO wa_cols.
        IF wa_cols-screen-name = 'T_VBRKSCR-TAX' OR
           wa_cols-screen-name = '%#AUTOTEXT007' OR
           wa_cols-screen-name = 'T_VBRKSCR-STCEG' OR
           wa_cols-screen-name = '%#AUTOTEXT006' OR
           wa_cols-screen-name = 'T_VBRKSCR-PPNBMLAST' OR
           wa_cols-screen-name = '%#AUTOTEXT012' OR
           wa_cols-screen-name = 'T_VBRKSCR-STATUS' OR
           wa_cols-screen-name = '%#AUTOTEXT015'.
          wa_cols-invisible = '1'.
          MODIFY ctrl_1300-cols FROM wa_cols.
        ENDIF.
      ENDLOOP.
  ENDCASE.

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
ENDMODULE.                 " STATUS_1400  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  LIST_PROCESSING_1500  OUTPUT
*&---------------------------------------------------------------------*
MODULE list_processing_1500 OUTPUT.

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

ENDMODULE.                 " LIST_PROCESSING_1500  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  DISPLAY_HEADER  OUTPUT
*&---------------------------------------------------------------------*
MODULE display_header OUTPUT.

  CASE d_tcode.
    WHEN c_tcode_sederhana OR
         c_tcode_sederhana_single.  "CR009 16/04/2002
      LOOP AT SCREEN.
        IF screen-name = 'R_ACT1' OR
           screen-name = 'R_ACT2' OR
           screen-name = 'D_PETUGAS' OR
           screen-name = 'D_PETUGAS2' OR
           screen-name = '%#AUTOTEXT013' OR

           screen-name = 'R_ACT3' OR
           screen-name = 'R_ACT4' OR
           screen-name = 'D_NAME_KAADM' OR
           screen-name = 'D_NAME_KACAB' OR
           screen-name = '%#AUTOTEXT016' OR
           screen-name = '%#AUTOTEXT017' OR

           screen-name = 'R_ACT5' OR
           screen-name = 'D_PETUGAS_E' OR
           screen-name = 'D_JABAT_E' OR
           screen-name = '%#AUTOTEXT018' OR
           screen-name = '%#AUTOTEXT019' OR
           screen-name = '%#AUTOTEXT020'.

          screen-active = 0.
          screen-input = 0.
          screen-output = 0.
          screen-required = 0.
          screen-invisible = 1.
          MODIFY SCREEN.
        ENDIF.
      ENDLOOP.
    WHEN OTHERS.
*-----Option 3 & 4 only appear if the branch use Head office's PKP
*      IF NOT d_nr_gsber CS '000'.
      IF d_hoind IS INITIAL.
        LOOP AT SCREEN.
          IF screen-name = 'R_ACT3' OR
             screen-name = 'R_ACT4' OR
             screen-name = 'D_NAME_KAADM' OR
             screen-name = 'D_NAME_KACAB' OR
             screen-name = '%#AUTOTEXT016' OR
             screen-name = '%#AUTOTEXT017'.
            screen-active = 0.
            screen-input = 0.
            screen-output = 0.
            screen-required = 0.
            screen-invisible = 1.
            MODIFY SCREEN.
          ENDIF.
        ENDLOOP.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " DISPLAY_HEADER  OUTPUT
