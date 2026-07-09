*&----------------------------------------------------------------------
*& RICEF ID             : RCO-002
*& Program Name         : ZGDCO_R002
*& Functional Designer  : FAM
*& ABAP Developer       : Budi
*& Creation Date        : 03.10.2016
*& SAP Release          : ECC6.0
*& Description          : Process Order DLV Status Monitoring
*&
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  DEVK951300  FAM         Budi      Initial
*&
*&---------------------------------------------------------------------*
REPORT  zbud_alv_oo_temp NO STANDARD PAGE HEADING
                         LINE-SIZE 255.

*------------------common TOP includes for the program----------------*
INCLUDE zgdco_r002top.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
PARAMETERS:     p_bukrs LIKE caufv-bukrs OBLIGATORY DEFAULT '8010',
                p_werks LIKE caufv-werks OBLIGATORY.
SELECT-OPTIONS: s_plnbez FOR caufv-plnbez,
                s_mtart FOR mara-mtart,
                s_aufnr FOR caufv-aufnr,
                s_gstrp FOR caufv-gstrp OBLIGATORY DEFAULT sy-datum,
                s_udate FOR jcds-udate.
SELECTION-SCREEN END OF BLOCK b1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

END-OF-SELECTION.

*------------------common Routine includes for the program----------------*
  INCLUDE zgdco_r002f01.
