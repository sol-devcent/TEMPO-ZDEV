*&---------------------------------------------------------------------*
*& Report  ZDG2FI_E0007
*&
*&---------------------------------------------------------------------*

*&----------------------------------------------------------------------
*& D R A G O N   G L O R Y  2  P R O J E C T
*&----------------------------------------------------------------------
*& RICEF ID             : ISD-01
*& Program Name         : ZDG2FI_E0007
*& Functional Designer  : Lisa Yanty
*& ABAP Developer       :
*& Creation Date        : 30.07.2015
*& SAP Release          : ECC6.0
*& Description          : This program post GL balance
*&---------------------------------------------------------------------*
*& M O D I F I C A T I O N   L O G
*&---------------------------------------------------------------------*
*& Log  TR          FUNCTIONAL  ABAPER    DESCRIPTION
*&---------------------------------------------------------------------*
*& 001  DEVK944945  <name>      <name>    <description>
*&
*&---------------------------------------------------------------------*

REPORT  ZDG2FI_E0007.

*&---------------------------------------------------------------------*
*& I N C L U D E
*&---------------------------------------------------------------------*
break dg2_co01.
include ZDG2FI_E0007TOP.

AT SELECTION-SCREEN OUTPUT.
  PERFORM f_initialization.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'P_FILE'
    IMPORTING
      file_name     = p_file.

* F4 help for variant
AT SELECTION-SCREEN ON VALUE-REQUEST FOR variant.
* Display all existing variants
  x_variant-report = sy-repid.
* Utilizing the name of the report, this function module will search for a list of
* variants and will fetch the selected one into the parameter field for variants
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant = x_variant
      i_save     = g_save
    IMPORTING
      e_exit     = g_exit
      es_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE 'S'      NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF g_exit = space.
      variant = gx_variant-variant.
    ENDIF.
  ENDIF.

break dg2_co01.
START-OF-SELECTION.
  PERFORM f_get_data.
  IF t_data[] IS NOT INITIAL.
    PERFORM f_display_data.
  ENDIF.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*& ALV I N C L U D E
*&---------------------------------------------------------------------*

  include ZDG2FI_E0007F01.
  include ZDG2FI_E0007F02.


*Selection texts
*----------------------------------------------------------
* S_MATNR D       .
* VARIANT D       .
