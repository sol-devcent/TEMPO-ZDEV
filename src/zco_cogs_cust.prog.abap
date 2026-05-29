*&---------------------------------------------------------------------*
*& Report  ZCO_COGS_CUST
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zco_cogs_cust NO STANDARD PAGE HEADING.

INCLUDE zco_cogs_custtop.

INCLUDE zco_cogs_custcl1.

SELECTION-SCREEN BEGIN OF BLOCK general WITH FRAME TITLE text-001.
PARAMETER pa_werks  TYPE mseg-werks OBLIGATORY.
PARAMETER pa_monat  TYPE bkpf-monat OBLIGATORY DEFAULT sy-datum+4(2).
PARAMETER pa_gjahr  TYPE bkpf-gjahr OBLIGATORY DEFAULT sy-datum(4).
SELECTION-SCREEN END OF BLOCK general.

*----------------------------------------------------------------------*
* INITIALIZATION.
*----------------------------------------------------------------------*
INITIALIZATION.
  gv_repid = sy-repid.

*---------------------------------------------------------------------*
*AT SELECTION-SCREEN ON ( PARAMETERS )
*---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN OUTPUT
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

*------------------------------------------------------
* AT SELECTION SCREEN ON VALUE REQUEST
*------------------------------------------------------

*----------------------------------------------------------------------*
* START-OF-SELECTION.
*----------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM f_init_data.
  PERFORM f_get_data.
  PERFORM f_process_data.
  PERFORM f_print_data.
  PERFORM f_free_memory.

*----------------------------------------------------------------------*
* END-OF-SELECTION.
*----------------------------------------------------------------------*
END-OF-SELECTION.

  INCLUDE zco_cogs_custf01.
