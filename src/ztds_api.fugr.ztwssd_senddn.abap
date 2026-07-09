FUNCTION ztwssd_senddn.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(VBELN) TYPE  VBELN_VL
*"  EXCEPTIONS
*"      COMMUNICATION_FAILURE
*"      SYSTEM_FAILURE
*"      RESOURCE_FAILURE
*"      CUSTOM_EXCEPTION
*"----------------------------------------------------------------------
  DATA: lv_vbeln LIKE likp-vbeln.
  lv_vbeln = vbeln.
  SUBMIT zrvcfpr00 WITH p_vbeln = lv_vbeln
                   WITH p_rad1 = 'X'
                   WITH p_rad2 = ' '
                   WITH p_rad3 = ' ' AND RETURN.


ENDFUNCTION.
