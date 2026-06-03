*&---------------------------------------------------------------------*
*&  Include           ZTSPPP_E001M01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS  OUTPUT
*&---------------------------------------------------------------------*
MODULE status OUTPUT.
  PERFORM f_status.
ENDMODULE.                 " STATUS  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  PBO  OUTPUT
*&---------------------------------------------------------------------*
MODULE pbo OUTPUT.
  PERFORM f_process_before_output.
ENDMODULE.                 " PBO  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
MODULE exit INPUT.
  CASE sy-dynnr.
    WHEN '0103'.
      gv_char = ''.
      LEAVE TO SCREEN 0.
    WHEN '1999'.
      gv_subrc = 9.
      LEAVE TO SCREEN 0.
    WHEN '0104'.
      CLEAR: gs_weights,gt_sanitasi,gs_sanitasi,gt_ztspppdt009,gs_ztspppdt009,
         gs_ztspppdt007,gs_zppresb_add,gv_valid,gv_sanitasi,gv_tools,
         gv_wuser,gv_wname,gv_wnrp,gv_wpass,gv_wcheck,gv_message.
      PERFORM f_clear_data USING 'PRINT'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      PERFORM f_clear_data USING ''.
      PERFORM f_exit.
  ENDCASE.
ENDMODULE.                 " EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  PAI  INPUT
*&---------------------------------------------------------------------*
MODULE pai INPUT.
  PERFORM f_process_after_input.
ENDMODULE.                 " PAI  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND  INPUT
*&---------------------------------------------------------------------*
MODULE user_command INPUT.
  PERFORM f_user_command.
ENDMODULE.                 " USER_COMMAND  INPUT

*&---------------------------------------------------------------------*
*&      Module  GENERATE_TABLE  OUTPUT
*&---------------------------------------------------------------------*
MODULE generate_table OUTPUT.
  PERFORM f_generate_table.
ENDMODULE.                 " GENERATE_TABLE  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  MODIFY_TABLE  INPUT
*&---------------------------------------------------------------------*
MODULE modify_table INPUT.
  PERFORM f_modify_table.
ENDMODULE.                 " MODIFY_TABLE  INPUT
