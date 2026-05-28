*&---------------------------------------------------------------------*
*&  Include           ZTNTFI_E001F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_DATA
*&---------------------------------------------------------------------*
FORM f_process_data .
  DATA : lt_vbrk TYPE STANDARD TABLE OF vbrk,
         ls_vbrk LIKE LINE OF lt_vbrk.

  DATA : BEGIN OF lt_data OCCURS 0,
           bukrs TYPE bkpf-bukrs,
           budat TYPE bkpf-budat,
           belnr TYPE bkpf-belnr,
         END OF lt_data.

  DATA : lv_memory(30),
         lv_subrc   TYPE sy-subrc.

  DATA : lv_mode,
         lv_update,
         lv_budat(10),
         lv_id(30).

  DATA: BEGIN OF t_bdcdata OCCURS 10.    " Internal table that stores
          INCLUDE STRUCTURE bdcdata.     " the BDC table data for the
        DATA: END OF t_bdcdata.                " Call Transaction
  DATA: BEGIN OF t_bdcmsg OCCURS 10.     " Internal table that stores
          INCLUDE STRUCTURE bdcmsgcoll.  " the BDC table data for the
        DATA: END OF t_bdcmsg.                 " Call Transaction

  PERFORM f_coretax_validate.

  CASE 'X'.
    WHEN radio1.
      CALL TRANSACTION 'VF04'.

      CONCATENATE 'VF04' sy-uname INTO lv_id.
      IMPORT lt_data FROM MEMORY ID lv_id.

*      lv_mode   = 'A'.
*      lv_update = 'S'.

* commmand for coretax
      LOOP AT lt_data.
        IF lt_data-budat IN gr_coretax.
          CALL FUNCTION 'ZFIFP_VF04'
            EXPORTING
              i_vbeln = lt_data-belnr
              i_bukrs = lt_data-bukrs
              i_budat = lt_data-budat
            IMPORTING
              e_subrc = lv_subrc.
        ENDIF.


**        CLEAR t_bdcdata.
**        t_bdcdata-dynbegin  = 'X'.
**        t_bdcdata-program   = 'ZGDTX_E0002'.
**        t_bdcdata-dynpro    = '1000'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'BDC_OKCODE'.
**        t_bdcdata-fval    = '=ONLI'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'P_BRNCH'.
**        t_bdcdata-fval    = lt_data-bukrs.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'P_BUSLN'.
**        t_bdcdata-fval    = '01'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'P_FLAG'.
**        t_bdcdata-fval    = '3'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        WRITE lt_data-budat TO lv_budat DDMMYY.
**        t_bdcdata-fnam    = 'S_FKDAT-LOW'.
**        t_bdcdata-fval    = lv_budat.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'S_VBELN-LOW'.
**        t_bdcdata-fval    = lt_data-belnr.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'P_CURR'.
**        t_bdcdata-fval    = 'IDR'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'P_CUST'.
**        t_bdcdata-fval    = space.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'P_STAN'.
**        t_bdcdata-fval    = 'X'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-dynbegin  = 'X'.
**        t_bdcdata-program   = 'ZGDTX_E0002'.
**        t_bdcdata-dynpro    = '1300'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'BDC_OKCODE'.
**        t_bdcdata-fval    = '=SAVE'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'BDC_CURSOR'.
**        t_bdcdata-fval    = 'T_VBRKSCR-VBELN(01)'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'R_ACT1'.
**        t_bdcdata-fval    = 'X'.
**        APPEND t_bdcdata.
**
**        CLEAR t_bdcdata.
**        t_bdcdata-fnam    = 'T_VBRKSCR-SEL(01)'.
**        t_bdcdata-fval    = 'X'.
**        APPEND t_bdcdata.
**
**        CALL TRANSACTION 'ZGDTXE0002_02' USING t_bdcdata
**                                         MODE lv_mode
**                                         UPDATE lv_update
**                                         MESSAGES INTO t_bdcmsg.
      ENDLOOP.

      FREE MEMORY ID lv_id.
    WHEN radio2.
      CALL TRANSACTION 'VF03'.
    WHEN radio3.
      CALL TRANSACTION 'VF11'.
    WHEN radio4.
      CALL TRANSACTION 'ZGDTXR0004'.
    WHEN radio5.
      SELECT *
        FROM vbrk
        INTO CORRESPONDING FIELDS OF TABLE lt_vbrk
        WHERE vkorg = pa_vkorg
          AND vbeln IN so_vbeln
          AND fkdat IN so_fkdat.

      LOOP AT lt_vbrk INTO ls_vbrk.
        CALL FUNCTION 'ZFIFP_VF04'
          EXPORTING
            i_vbeln = ls_vbrk-vbeln
            i_bukrs = ls_vbrk-vkorg
            i_budat = ls_vbrk-fkdat
          IMPORTING
            e_subrc = lv_subrc.
      ENDLOOP.
  ENDCASE.
ENDFORM.                    " F_PROCESS_DATA









*      IMPORT lv_memory FROM MEMORY id 'VF04'.
*      CONCATENATE 'VF04' sy-uname INTO lv_memory1.

*      IF lv_memory = lv_memory1.
*        ls_budat-low    = ls_bkpf-budat.
*        ls_budat-high   = ls_bkpf-budat.
*        ls_budat-sign   = 'I'.
*        ls_budat-option = 'BT'.
*        APPEND ls_budat TO lr_budat.
*        CLEAR ls_budat.
*
*        ls_vbeln-low    = ls_bkpf-belnr.
*        ls_vbeln-sign   = 'I'.
*        ls_vbeln-option = 'EQ'.
*        APPEND ls_vbeln TO lr_vbeln.
*        CLEAR ls_vbeln.

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN_OUTPUT
*&---------------------------------------------------------------------*
FORM f_selection-screen_output .
  PERFORM f_modify_screen USING : 'RA5' '0' '' '' ''.

  CASE 'X'.
    WHEN radio5.
      PERFORM f_modify_screen USING : 'PBU' '' '0' '' ''.
    WHEN OTHERS.
      PERFORM f_modify_screen USING : 'PBU' '0' '' '' '',
                                      'SBU' '0' '' '' '',
                                      'SBE' '0' '' '' ''.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_SELECTION-SCREEN
*&---------------------------------------------------------------------*
FORM f_selection-screen .
  CASE 'X'.
    WHEN radio5.
      IF pa_vkorg IS INITIAL.
        PERFORM f_error_message USING 'PBU' ''.
      ENDIF.
      IF so_vbeln[] IS INITIAL.
        PERFORM f_error_message USING 'SBE' ''.
      ENDIF.
  ENDCASE.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_MODIFY_SCREEN
*&---------------------------------------------------------------------*
FORM f_modify_screen  USING    fu_group fu_active fu_input fu_invisible
                               fu_length.
  IF fu_active IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-active  = fu_active.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_input IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = fu_input.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_invisible IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-invisible  = fu_invisible.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF fu_length IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-length  = fu_length.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_ERROR_MESSAGE
*&---------------------------------------------------------------------*
FORM f_error_message  USING    fu_group fu_mess.
  DATA: lv_mess(100) VALUE 'Fill in all required entry fields'.

  IF fu_mess IS NOT INITIAL.
    lv_mess = fu_mess.
  ENDIF.

  IF fu_group IS NOT INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 = fu_group.
        screen-input  = 1.
      ELSE.
        screen-input  = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDLOOP.
  ENDIF.

  IF lv_mess IS NOT INITIAL.
    MESSAGE e000(zab) WITH lv_mess.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  F_CORETAX_VALIDATE
*&---------------------------------------------------------------------*
FORM f_coretax_validate .
  DATA : ls_project TYPE zproject,
         ls_coretax LIKE LINE OF gr_coretax.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'CORETAX'.
  ls_coretax-low = ls_project-datab.

  CLEAR ls_project.
  SELECT SINGLE *
      FROM zproject
      INTO CORRESPONDING FIELDS OF ls_project
      WHERE name = 'ZGDCORETAX'.
  ls_coretax-high   = ls_project-datab.
  ls_coretax-sign   = 'E'.
  ls_coretax-option = 'BT'.
  APPEND ls_coretax TO gr_coretax.
ENDFORM.
