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
REPORT zpm_breakdown NO STANDARD PAGE HEADING
                     LINE-SIZE 255
                     MESSAGE-ID sap_doi.

* common report header and other functions
INCLUDE zabp_header.

* ALV common functions
INCLUDE zabp_alv_common.

*------------------common TOP includes for the program----------------*
INCLUDE zpm_breakdowntop.
INCLUDE zpm_breakdown_chart.
INCLUDE zpm_breakdown_excel_interface.

*------------------common TOP includes for the program----------------*

*&---------------------------------------------------------------------*
*& selection-screen -> Selection
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK data WITH FRAME TITLE text-001.
PARAMETERS:
pa_iwerk    LIKE viqmel-iwerk MODIF ID iwe.
SELECT-OPTIONS:
so_monat    FOR bsis-monat MODIF ID smo NO-EXTENSION.
PARAMETERS:
pa_gjahr    LIKE bsis-gjahr MODIF ID gja.
SELECT-OPTIONS:
so_tplnr    FOR itob-tplnr MODIF ID tpl.
PARAMETERS:
pa_perce    TYPE bbp_percnt MODIF ID per.
PARAMETERS:
pa_totmh    TYPE p DECIMALS 0 MODIF ID tot.
SELECTION-SCREEN END OF BLOCK data.

SELECTION-SCREEN BEGIN OF BLOCK process WITH FRAME TITLE text-002.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
radio1 RADIOBUTTON GROUP grp2 USER-COMMAND rad DEFAULT 'X' MODIF ID ra1.
SELECTION-SCREEN : COMMENT 5(52) text-003 FOR FIELD radio1.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
radio2 RADIOBUTTON GROUP grp2 MODIF ID ra2.
SELECTION-SCREEN : COMMENT 5(54) text-004 FOR FIELD radio2.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
PARAMETERS:
radio3 RADIOBUTTON GROUP grp2 MODIF ID ra3.
SELECTION-SCREEN : COMMENT 5(31) text-005 FOR FIELD radio3.
SELECTION-SCREEN END OF LINE.
*SELECTION-SCREEN BEGIN OF LINE.
*SELECTION-SCREEN POSITION 3.
*PARAMETERS: pa_chart DEFAULT 'X' AS CHECKBOX MODIF ID cha.
*SELECTION-SCREEN : COMMENT 6(10) text-006 FOR FIELD pa_chart MODIF ID cha.
*SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK process.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON (parameters)
*---------------------------------------------------------------------*

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

  CASE 'X'.
    WHEN radio3.
      PERFORM f_process_data_radio3.
*      IF pa_chart EQ 'X'.
** USAGE allowed in SAP internal test reports, only
*        INCLUDE applg_auto_test_init.
*        CALL SCREEN '110'.
*      ELSE.
        PERFORM f_print_data.
*      ENDIF.

    WHEN OTHERS.
      PERFORM f_process_data USING pa_gjahr so_monat-low so_monat-high.

      IF t_vdata[] IS NOT INITIAL.
        doc_classname  = 'ZBREAKDOWN'.
        doc_classtype  = 'OT'.
        doc_object_key = 'ZOBJECT'.
        CALL SCREEN 100.
      ENDIF.
  ENDCASE.

  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

*--------------common FORM INCLUDE for the program---------------------*
  INCLUDE zpm_breakdownf01.
* USAGE allowed in SAP internal test reports, only
*  INCLUDE applg_auto_test_form.

*------------------common includes for the program---------------------*
