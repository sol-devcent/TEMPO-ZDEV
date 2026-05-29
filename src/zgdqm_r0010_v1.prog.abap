*&---------------------------------------------------------------------*
*& Program Name     : xxxxxxxxxxx                                      *
*& Module Name      : FI,CO,MM,SD,PM,QM,PP                             *
*& Author           : xxxxxx xxx , xxxxx xxxxx                         *
*& Functional       :                                                  *
*& Create Date      : dd/mm/yyyy                                       *
*& Program Type     : Report/Enhancement                               *
*& Transaction      :                                                  *
*& SAP Release      : 4.6C                                             *
*& Description      : xxxxxxxxxx xx xxxxxx xxxxxxx xxxx xxxx xxxxx     *
*&                    xxxx xx xxxxxxx xxxx xx xx xx xxxxxxxxx          *
*&---------------------------------------------------------------------*
*&                                                                     *
*& REVISION LOG                                                        *
*&                                                                     *
*& CRNO#    DATE         AUTHOR         DESCRIPTION                    *
*& ----     ----         ------         -----------                    *
*&                                                                     *
*&---------------------------------------------------------------------*
REPORT zgdqm_r0010_v1 NO STANDARD PAGE HEADING
                      MESSAGE-ID sap_doi.

*------------------standard common includes for the program-----------*
* Authorization checking macros
INCLUDE zabp_atz.

*------------------common TOP includes for the program----------------*
INCLUDE zgdqm_r0010_v1top.
INCLUDE zgdqm_r0010_v1int.

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE TEXT-001.
PARAMETERS:
  pa_werk  LIKE qals-werk MODIF ID wrk,
  pa_matnr LIKE mara-matnr MODIF ID mat.
SELECT-OPTIONS:
  so_datum FOR qals-pastrterm.
PARAMETERS:
  pa_art   LIKE qals-art MODIF ID qla.
SELECT-OPTIONS:
  so_prue  FOR qals-prueflos MODIF ID pru.
SELECTION-SCREEN BEGIN OF BLOCK data2 WITH FRAME TITLE TEXT-003.
SELECT-OPTIONS:
  so_aufnr FOR aufk-aufnr MODIF ID auf,
  so_erdat FOR aufk-erdat MODIF ID dat.
SELECTION-SCREEN END OF BLOCK data2.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK data1 WITH FRAME TITLE TEXT-002.
PARAMETERS: radio1 RADIOBUTTON GROUP grp1 USER-COMMAND dik DEFAULT 'X',
            radio2 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS: radio3 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN COMMENT 5(33) TEXT-004 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
PARAMETERS: radio4 RADIOBUTTON GROUP grp1.
SELECTION-SCREEN END OF BLOCK data1.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*
AT SELECTION-SCREEN ON pa_werk.
*-Authorization
  macro_atz_single_werks pa_werk c_atz_display.

*&---------------------------------------------------------------------*
*& selection-screen output
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN OUTPUT.
  PERFORM f_modify_screen_1000.

*&---------------------------------------------------------------------*
*& selection-screen.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'ONLI'.
      PERFORM f_validate_screen_1000.
    WHEN space.
      PERFORM f_validate_screen_1000.
  ENDCASE.

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_header.
  PERFORM f_process_detail.
  CASE pa_werk.
    WHEN '3301' OR '3302'.
      PERFORM f_result_with_bapi.
    WHEN OTHERS.
      PERFORM f_get_result.
  ENDCASE.
  IF t_vdata[] IS NOT INITIAL.
    PERFORM f_free_memory.
    PERFORM f_print_data.
  ELSE.
    MESSAGE i000(zab) WITH 'Data not found'.
  ENDIF.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zgdqm_r0010_v1f01.

*------------------common includes for the program---------------------*
