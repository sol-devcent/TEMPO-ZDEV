FUNCTION ztwsit_f0002.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PROSES) TYPE  CHAR15
*"     VALUE(VKBUR) TYPE  VSTEL
*"  EXPORTING
*"     VALUE(STATUS) TYPE  CHAR1
*"     VALUE(MESSAGE) TYPE  CHAR100
*"----------------------------------------------------------------------

  TYPES : BEGIN OF ty_matlp,
              sales_office           TYPE string,
              material_code           TYPE string,
            END OF ty_matlp.

 DATA : gv_return(1).
 data: p_mess type string.
"  DATA: gv_str TYPE string.
  clear: gt_matlp[].
  gv_return = 0.
  gv_vkbur = vkbur.
  PERFORM f_get_data USING proses vkbur CHANGING gv_str gv_return.
  if gv_return = 0.
    Perform f_proses using gv_str. " CHANGING gt_matlp.
    PERFORM f_update ON COMMIT. " using vkbur .
    COMMIT WORK AND WAIT.
    PERFORM f_send_to_api using vkbur proses CHANGING p_mess.
    message = p_mess.
    status = 'S'.
  else.
    status = 'E'.
    message = gv_str.
  endif.

ENDFUNCTION.
