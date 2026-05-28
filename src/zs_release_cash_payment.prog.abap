REPORT zs_release_so MESSAGE-ID zs NO STANDARD PAGE HEADING
                                  LINE-COUNT 63(3)
                                  LINE-SIZE  180.


************************************************************************
*                  REPORT                                              *
*----------------------------------------------------------------------*
* ABAP Name   :                                                        *
* Created by  :                                                        *
* Created on  :                                                        *
* Version     : 0.0                                                    *
* Include     :                                                        *
*----------------------------------------------------------------------*
* Description :                                                        *
*----------------------------------------------------------------------*
* Modification Log :                                                   *
* Date    Programmer  Correction  Description
*
*----------------------------------------------------------------------*

INCLUDE zs_release_cash_paymenttop.

****************************************************
*        Parameters                                *
****************************************************
SELECTION-SCREEN BEGIN OF BLOCK block1 WITH FRAME TITLE TEXT-001.
PARAMETERS pa_vkorg LIKE tvko-vkorg  OBLIGATORY DEFAULT '8020'.
PARAMETERS pa_vkbur LIKE tvkbz-vkbur OBLIGATORY.
SELECT-OPTIONS: so_vtweg FOR  tvkov-vtweg,
                so_vkgrp FOR  tvbvk-vkgrp,
                so_kunnr FOR  kna1-kunnr,
                so_vbeln FOR  vbak-vbeln,
                so_audat FOR  vbak-audat,
                so_erdat FOR  vbak-erdat.
SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN END OF BLOCK block1.
************************************************************************
* PROGRAM                                                              *
************************************************************************
************************************************************************
* AT SELECTION-SCREEN
************************************************************************
AT SELECTION-SCREEN ON pa_vkbur.
  AUTHORITY-CHECK OBJECT 'ZV_VBKAVKO'
      ID 'VKBUR' FIELD pa_vkbur.
  IF sy-subrc NE 0.
    MESSAGE e002(zz) WITH 'You are not authorized with Sales Office'
             pa_vkbur.
  ENDIF.

************************************************************************
* INITIALIZATION
************************************************************************
INITIALIZATION.
  LOOP AT SCREEN.
    IF screen-group1 = 'REA'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

  NEW-PAGE LINE-SIZE 122.
  panjang = 122.


  PERFORM f_init_column.
************************************************************************
* START-OF-SELECTION
************************************************************************
START-OF-SELECTION.
  PERFORM f_initial.
*  NEW-PAGE LINE-SIZE 120.
*  panjang = 107.
*  NEW-PAGE LINE-SIZE 133.
  panjang = 132.
  NEW-PAGE LINE-SIZE 160.
  PERFORM f_get_data.
  PERFORM f_proses_data.

END-OF-SELECTION.


TOP-OF-PAGE.
  NEW-PAGE LINE-SIZE 160.
*  panjang = 150.
  panjang = 134.  "162.
  PERFORM f_write_header.
  FORMAT COLOR 4.
  PERFORM f_write_column_header.

END-OF-PAGE.


************************************************************************
* AT USER-COMMAND.
************************************************************************
AT USER-COMMAND.
  CASE sy-ucomm.
    WHEN 'EXECUTE'.
      LOOP AT %_list INTO va_list.
        CLEAR: va_vbeln.
        IF va_list-line+3(1) = 'X'.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
            EXPORTING
              input  = va_list-line+23(10)
            IMPORTING
              output = va_vbeln.

          WRITE: / 'No. So : ', va_vbeln.
          PERFORM f_order_change USING va_vbeln.
        ENDIF.
      ENDLOOP.
      LEAVE TO SCREEN 0.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN 'SELECT'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0.
          EXIT.
        ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark FROM 'X'.
      ENDDO.
    WHEN 'DESELECT'.
      DO.
        READ LINE sy-index.
        IF sy-subrc NE 0. EXIT. ENDIF.
        MODIFY CURRENT LINE FIELD VALUE va_mark FROM space.
      ENDDO.
    WHEN 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'CANCL'.
      LEAVE PROGRAM.
  ENDCASE.


************************************************************************
* AT LINE-SELECTION.
************************************************************************
AT LINE-SELECTION.
  IF sy-lsind = 1.
    GET CURSOR FIELD va_fieldname VALUE va_value.
    CASE va_fieldname.
      WHEN 'WA_ITAB1-VBELN'.
        SET PARAMETER ID  'AUN' FIELD va_value.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
      WHEN 'WA_ITAB1-IHREZ_E'.
        SET PARAMETER ID  'AUN' FIELD va_value.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
    ENDCASE.
  ENDIF.



  INCLUDE zs_release_cash_paymentf01.
